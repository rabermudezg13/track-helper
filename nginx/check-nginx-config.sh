#!/bin/bash
# Script para verificar la configuración de nginx en el servidor

echo "=== Verificando configuración de nginx para trackhelper.fromcolombiawithcoffees.com ==="
echo ""

# Buscar configuraciones de nginx que mencionen trackhelper
echo "1. Buscando configuraciones de nginx:"
if [ -d "/etc/nginx/sites-available" ]; then
    echo "   Archivos en /etc/nginx/sites-available:"
    grep -r "trackhelper" /etc/nginx/sites-available/ 2>/dev/null || echo "   No se encontró trackhelper en sites-available"
fi

if [ -d "/etc/nginx/conf.d" ]; then
    echo "   Archivos en /etc/nginx/conf.d:"
    grep -r "trackhelper" /etc/nginx/conf.d/ 2>/dev/null || echo "   No se encontró trackhelper en conf.d"
fi

echo ""
echo "2. Verificando si nginx está corriendo:"
systemctl status nginx 2>/dev/null || service nginx status 2>/dev/null || echo "   No se pudo verificar el estado de nginx"

echo ""
echo "3. Verificando puertos en uso:"
netstat -tuln | grep -E ':(80|443|3030|3031)' || ss -tuln | grep -E ':(80|443|3030|3031)' || echo "   No se pudo verificar puertos"

echo ""
echo "4. Verificando contenedores Docker:"
docker ps | grep -E 'trackercheck|nginx' || echo "   No se encontraron contenedores relacionados"

echo ""
echo "=== Para solucionar: ==="
echo "1. Verifica qué app está respondiendo en trackhelper.fromcolombiawithcoffees.com"
echo "2. Modifica la configuración de nginx para que apunte a localhost:3031 (frontend) y localhost:3030 (API)"
echo "3. O usa el nginx del contenedor Docker en puertos diferentes (8080/8443)"
