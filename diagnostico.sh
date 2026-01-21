#!/bin/bash

echo "=== DIAGNÓSTICO DE TRACKERCHECK ==="
echo ""

echo "1. Verificando contenedores Docker:"
docker ps -a | grep -E 'trackercheck|CONTAINER' || echo "   No se encontraron contenedores"

echo ""
echo "2. Verificando si los puertos están en uso:"
echo "   Puerto 3030 (API):"
lsof -i :3030 2>/dev/null || netstat -an | grep 3030 || echo "   No está en uso"
echo "   Puerto 3031 (Frontend):"
lsof -i :3031 2>/dev/null || netstat -an | grep 3031 || echo "   No está en uso"

echo ""
echo "3. Verificando logs de la aplicación:"
docker-compose logs --tail=20 trackercheck 2>/dev/null || echo "   No se pueden ver los logs (¿está corriendo docker-compose?)"

echo ""
echo "4. Probando conectividad local:"
echo "   Probando puerto 3031:"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:3031 2>/dev/null || echo "   No responde"
echo "   Probando puerto 3030:"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:3030 2>/dev/null || echo "   No responde"

echo ""
echo "5. Verificando archivos de configuración:"
if [ -f "docker-compose.yml" ]; then
    echo "   ✓ docker-compose.yml existe"
else
    echo "   ✗ docker-compose.yml NO existe"
fi

if [ -f "Dockerfile" ]; then
    echo "   ✓ Dockerfile existe"
else
    echo "   ✗ Dockerfile NO existe"
fi

echo ""
echo "=== SOLUCIÓN RÁPIDA ==="
echo "1. Inicia los contenedores:"
echo "   docker-compose up -d --build"
echo ""
echo "2. Verifica que estén corriendo:"
echo "   docker-compose ps"
echo ""
echo "3. Revisa los logs si hay errores:"
echo "   docker-compose logs -f trackercheck"
