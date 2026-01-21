# TrackerCheck - Streamlit Edition

## 📊 Verificador de Fechas en Tracker de Aspirantes

TrackerCheck es una aplicación web que te ayuda a verificar la consistencia de fechas en tu tracker de aspirantes.

## 🚀 Cómo usar

### Opción 1: Ejecutar localmente

1. Instala las dependencias:
```bash
pip install -r requirements.txt
```

2. Ejecuta la aplicación:
```bash
streamlit run streamlit_app.py
```

3. Abre tu navegador en `http://localhost:8501`

### Opción 2: Desplegar en Streamlit Cloud

1. Sube tu código a GitHub
2. Ve a [share.streamlit.io](https://share.streamlit.io)
3. Conecta tu repositorio de GitHub
4. Selecciona el archivo `streamlit_app.py`
5. ¡Listo! Tu app estará disponible en la nube

## 📝 Formato del archivo Excel

El archivo Excel debe tener las siguientes columnas:

- **Columna A**: Primera inicial del reclutador
- **Columna B**: Segunda inicial del reclutador
- **Columna C**: Nombre del aspirante
- **Columna F**: Fecha en que se añadió
- **Columna AD**: Fecha en que se activó

## ✅ Verificaciones

La aplicación verifica:

1. ✓ Que todos los aspirantes tengan fecha de añadido
2. ✓ Que todos los aspirantes tengan fecha de activado
3. ✓ Que la fecha de activado sea posterior a la fecha de añadido

## 🎨 Características

- 📤 Carga de archivos Excel (.xlsx)
- 📊 Análisis automático de datos
- 📈 Dashboard con métricas visuales
- 📋 Tablas detalladas de problemas encontrados
- 🎯 Interfaz intuitiva y responsive

## 🔧 Tecnologías

- **Streamlit**: Framework para la interfaz web
- **Pandas**: Manipulación de datos
- **OpenPyXL**: Lectura de archivos Excel

## 📄 Licencia

MIT License

---

**Desarrollado con ❤️ para mejorar la gestión de aspirantes**
