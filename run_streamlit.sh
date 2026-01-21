#!/bin/bash

# Script para ejecutar TrackerCheck en Streamlit

echo "🚀 Iniciando TrackerCheck..."
echo ""

# Activar entorno virtual si existe
if [ -d "venv" ]; then
    echo "Activando entorno virtual..."
    source venv/bin/activate
else
    echo "Creando entorno virtual..."
    python3 -m venv venv
    source venv/bin/activate
    echo "Instalando dependencias..."
    pip install -r requirements.txt
fi

echo ""
echo "✅ Lanzando aplicación Streamlit..."
echo "📊 Abre tu navegador en: http://localhost:8501"
echo ""

streamlit run streamlit_app.py
