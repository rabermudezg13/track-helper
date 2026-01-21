#!/bin/bash

echo "🚀 Iniciando TrackerCheck..."
echo ""

# Verificar que Docker está corriendo
if ! docker ps > /dev/null 2>&1; then
    echo "❌ Error: Docker no está corriendo"
    echo "   Por favor inicia Docker Desktop (Mac) o el servicio docker (Linux)"
    exit 1
fi

echo "✓ Docker está corriendo"
echo ""

# Construir e iniciar contenedores
echo "📦 Construyendo e iniciando contenedores..."
docker-compose up -d --build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Contenedores iniciados correctamente"
    echo ""
    echo "📊 Estado de los contenedores:"
    docker-compose ps
    echo ""
    echo "🌐 La aplicación está disponible en:"
    echo "   - Frontend: http://localhost:3031"
    echo "   - API: http://localhost:3030"
    echo ""
    echo "📝 Para ver los logs:"
    echo "   docker-compose logs -f"
    echo ""
    echo "🔍 Para diagnosticar problemas:"
    echo "   ./diagnostico.sh"
else
    echo ""
    echo "❌ Error al iniciar contenedores"
    echo "   Revisa los logs con: docker-compose logs"
    exit 1
fi
