const express = require('express');
const multer = require('multer');
const XLSX = require('xlsx');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.API_PORT || 3030;

// Configuración mejorada de CORS
const corsOptions = {
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true,
  optionsSuccessStatus: 200
};

// Middleware
app.use(cors(corsOptions));
app.use(express.json());
app.use(express.static('public'));

// Configuración de multer para subir archivos
const upload = multer({ 
  dest: 'uploads/',
  fileFilter: (req, file, cb) => {
    const allowedTypes = [
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-excel',
      'text/csv'
    ];
    if (allowedTypes.includes(file.mimetype) || file.originalname.endsWith('.xlsx') || file.originalname.endsWith('.xls')) {
      cb(null, true);
    } else {
      cb(new Error('Solo se permiten archivos Excel (.xlsx, .xls)'));
    }
  }
});

// Función para obtener el número de semana del año
function getWeekNumber(date) {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const dayNum = d.getUTCDay() || 7;
  d.setUTCDate(d.getUTCDate() + 4 - dayNum);
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  return Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
}

// Función para obtener el mes de una fecha
function getMonth(date) {
  return date.getMonth() + 1; // 1-12
}

// Función para calcular la diferencia en días entre dos fechas
function calculateDaysDifference(date1, date2) {
  if (!date1 || !date2) return null;
  const diffTime = Math.abs(date2 - date1);
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  return diffDays;
}

// Función para parsear fechas de Excel
function parseExcelDate(value) {
  if (!value) return null;
  
  // Si es un número (serial date de Excel)
  if (typeof value === 'number') {
    // Excel cuenta desde 1900-01-01, pero tiene un bug del año 1900
    const excelEpoch = new Date(1899, 11, 30);
    const date = new Date(excelEpoch.getTime() + value * 86400000);
    return date;
  }
  
  // Si es una cadena, intentar parsearla
  if (typeof value === 'string') {
    const date = new Date(value);
    if (!isNaN(date.getTime())) {
      return date;
    }
  }
  
  // Si es un objeto Date
  if (value instanceof Date) {
    return value;
  }
  
  return null;
}

// Endpoint para procesar el archivo Excel
app.post('/api/process', upload.single('excelFile'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No se proporcionó ningún archivo' });
    }

    // Leer el archivo Excel
    const workbook = XLSX.readFile(req.file.path);
    const sheetName = workbook.SheetNames[0];
    const worksheet = workbook.Sheets[sheetName];
    
    // Convertir a JSON
    const data = XLSX.utils.sheet_to_json(worksheet, { 
      header: 1,
      defval: null,
      raw: false
    });

    // Procesar los datos
    const results = {};
    
    // Empezar desde la fila 1 (índice 1) para saltar el encabezado si existe
    for (let i = 1; i < data.length; i++) {
      const row = data[i];
      
      // Obtener datos de las columnas
      // Columna A (índice 0) y B (índice 1) = iniciales del reclutador
      // Columna C (índice 2) = nombre del aspirante
      // Columna F (índice 5) = tiempo que se añadió
      // Columna AD (índice 29) = tiempo que se activó

      const inicialA = row[0] ? String(row[0]).trim() : '';
      const inicialB = row[1] ? String(row[1]).trim() : '';
      const reclutador = `${inicialA}${inicialB}`.trim();
      const aspirante = row[2] ? String(row[2]).trim() : '';
      const fechaAnadido = parseExcelDate(row[5]);
      const fechaActivado = parseExcelDate(row[29]);
      
      // Validar que tenemos los datos necesarios
      if (!reclutador || !fechaAnadido || !fechaActivado) {
        continue;
      }
      
      // Calcular tiempo de proceso en días
      const tiempoProceso = calculateDaysDifference(fechaAnadido, fechaActivado);
      if (tiempoProceso === null) {
        continue;
      }
      
      // Obtener semana y mes de la fecha de activación
      const semana = getWeekNumber(fechaActivado);
      const mes = getMonth(fechaActivado);
      const año = fechaActivado.getFullYear();
      const semanaKey = `${año}-W${semana.toString().padStart(2, '0')}`;
      const mesKey = `${año}-M${mes.toString().padStart(2, '0')}`;
      
      // Inicializar estructura para el reclutador si no existe
      if (!results[reclutador]) {
        results[reclutador] = {
          reclutador: reclutador,
          procesos: [],
          semanas: {},
          meses: {}
        };
      }
      
      // Agregar proceso individual
      results[reclutador].procesos.push({
        aspirante: aspirante,
        fechaAnadido: fechaAnadido.toISOString().split('T')[0],
        fechaActivado: fechaActivado.toISOString().split('T')[0],
        tiempoProceso: tiempoProceso
      });
      
      // Agregar a la semana
      if (!results[reclutador].semanas[semanaKey]) {
        results[reclutador].semanas[semanaKey] = {
          semana: semanaKey,
          tiempos: [],
          promedio: 0
        };
      }
      results[reclutador].semanas[semanaKey].tiempos.push(tiempoProceso);
      
      // Agregar al mes
      if (!results[reclutador].meses[mesKey]) {
        results[reclutador].meses[mesKey] = {
          mes: mesKey,
          tiempos: [],
          promedio: 0
        };
      }
      results[reclutador].meses[mesKey].tiempos.push(tiempoProceso);
    }
    
    // Calcular promedios
    Object.keys(results).forEach(reclutador => {
      // Promedios semanales
      Object.keys(results[reclutador].semanas).forEach(semanaKey => {
        const semana = results[reclutador].semanas[semanaKey];
        if (semana.tiempos.length > 0) {
          semana.promedio = semana.tiempos.reduce((a, b) => a + b, 0) / semana.tiempos.length;
          semana.promedio = Math.round(semana.promedio * 100) / 100; // Redondear a 2 decimales
        }
      });
      
      // Promedios mensuales
      Object.keys(results[reclutador].meses).forEach(mesKey => {
        const mes = results[reclutador].meses[mesKey];
        if (mes.tiempos.length > 0) {
          mes.promedio = mes.tiempos.reduce((a, b) => a + b, 0) / mes.tiempos.length;
          mes.promedio = Math.round(mes.promedio * 100) / 100; // Redondear a 2 decimales
        }
      });
    });
    
    // Convertir objetos a arrays para facilitar el frontend
    const formattedResults = Object.keys(results).map(reclutador => ({
      reclutador: results[reclutador].reclutador,
      procesos: results[reclutador].procesos,
      semanas: Object.values(results[reclutador].semanas),
      meses: Object.values(results[reclutador].meses)
    }));
    
    res.json({
      success: true,
      data: formattedResults,
      totalReclutadores: formattedResults.length
    });
    
  } catch (error) {
    console.error('Error procesando archivo:', error);
    res.status(500).json({ 
      error: 'Error al procesar el archivo',
      message: error.message 
    });
  }
});

// Servir el index.html para todas las rutas que no sean API
app.get('*', (req, res) => {
  // Solo servir index.html si no es una ruta de API
  if (!req.path.startsWith('/api/')) {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
  }
});

// Iniciar servidor unificado
app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ TrackerCheck running on http://0.0.0.0:${PORT}`);
  console.log(`📊 API Endpoint: http://0.0.0.0:${PORT}/api/process`);
  console.log(`🌐 Frontend: http://0.0.0.0:${PORT}`);
});
