# TrackerCheck

📊 **Verificador de Fechas en Tracker de Aspirantes**

Aplicación para verificar la consistencia de fechas en tu tracker de aspirantes. Detecta problemas como fechas faltantes y inconsistencias temporales.

## 🚀 Versiones Disponibles

### ⚡ Versión Streamlit (Recomendada)

Interfaz web moderna con Python y Streamlit.

**Inicio Rápido:**
```bash
./run_streamlit.sh
```

O manualmente:
```bash
# Crear entorno virtual
python3 -m venv venv
source venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt

# Ejecutar
streamlit run streamlit_app.py
```

Abre tu navegador en `http://localhost:8501`

### 🐳 Versión Docker (Node.js + Express)

Aplicación containerizada con Docker Compose.

```bash
# Construir y ejecutar
docker-compose up -d

# Ver logs
docker-compose logs -f
```

Abre tu navegador en `http://localhost:3031`

## ✅ Verificaciones

La aplicación verifica:

1. ✓ Que todos los aspirantes tengan **fecha de añadido**
2. ✓ Que todos los aspirantes tengan **fecha de activado**
3. ✓ Que la **fecha de activado sea posterior** a la fecha de añadido

## 📋 Estructura del Excel

El archivo Excel debe tener las siguientes columnas:

- **Columna A**: Primera inicial del reclutador
- **Columna B**: Segunda inicial del reclutador
- **Columna C**: Nombre del aspirante
- **Columna F**: Fecha en que se añadió
- **Columna AD**: Fecha en que se activó

## 🌐 Desplegar en Streamlit Cloud

1. Sube este repositorio a GitHub
2. Ve a [share.streamlit.io](https://share.streamlit.io)
3. Conecta tu repositorio
4. Selecciona `streamlit_app.py`
5. ¡Listo! Tu app estará en la nube

## 📦 Dependencias

### Streamlit
- streamlit
- pandas
- openpyxl

### Docker/Node.js
- express
- multer
- xlsx
- openpyxl (Python)

## 🔧 Tecnologías

- **Frontend**: HTML5, CSS3, JavaScript
- **Backend**: Node.js + Express / Python + Streamlit
- **Processing**: Python + OpenPyXL
- **Deployment**: Docker / Streamlit Cloud

---

**Desarrollado con ❤️ para mejorar la gestión de aspirantes**
