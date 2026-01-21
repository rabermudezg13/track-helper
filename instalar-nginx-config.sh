#!/bin/bash

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Instalador de Configuración nginx - TrackerCheck    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "trackerhelper-local.conf" ]; then
    echo -e "${RED}❌ Error: No se encuentra trackerhelper-local.conf${NC}"
    echo "Asegúrate de ejecutar este script desde /Users/rodrigobermudez/trackercheck"
    exit 1
fi

echo -e "${YELLOW}[1/5] Copiando configuración a nginx...${NC}"
echo "Este comando requiere tu contraseña de Mac:"
echo ""

sudo cp trackerhelper-local.conf /opt/homebrew/etc/nginx/servers/trackhelper.conf

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Archivo copiado${NC}"
else
    echo -e "${RED}❌ Error al copiar archivo${NC}"
    exit 1
fi
echo ""

echo -e "${YELLOW}[2/5] Verificando permisos de archivos...${NC}"
sudo chmod 644 /opt/homebrew/etc/nginx/servers/*.conf 2>/dev/null
echo -e "${GREEN}✅ Permisos actualizados${NC}"
echo ""

echo -e "${YELLOW}[3/5] Probando configuración de nginx...${NC}"
sudo nginx -t

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Configuración válida${NC}"
else
    echo -e "${RED}❌ Error en la configuración${NC}"
    echo ""
    echo "Posibles soluciones:"
    echo "1. Revisa los errores arriba"
    echo "2. Si hay problemas con otros archivos .conf, intenta:"
    echo "   sudo chmod 644 /opt/homebrew/etc/nginx/servers/watermark.conf"
    exit 1
fi
echo ""

echo -e "${YELLOW}[4/5] Recargando nginx...${NC}"
sudo nginx -s reload 2>/dev/null || sudo nginx

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ nginx recargado${NC}"
else
    echo -e "${RED}❌ Error al recargar nginx${NC}"
    echo "Intenta manualmente:"
    echo "  sudo nginx -s stop"
    echo "  sudo nginx"
    exit 1
fi
echo ""

echo -e "${YELLOW}[5/5] Verificando que nginx está escuchando...${NC}"
sleep 2
if lsof -i :80 2>/dev/null | grep -q nginx; then
    echo -e "${GREEN}✅ nginx escuchando en puerto 80${NC}"
else
    echo -e "${RED}❌ nginx NO está en puerto 80${NC}"
fi
echo ""

# Test local
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                     🧪 PRUEBA LOCAL                         ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Probando http://localhost...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null)
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
    echo -e "${GREEN}✅ Funciona localmente (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}❌ No responde localmente (HTTP $HTTP_CODE)${NC}"
fi
echo ""

# Resumen
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                      ✅ COMPLETADO                          ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${GREEN}La configuración de nginx está instalada.${NC}"
echo ""
echo -e "${YELLOW}📱 AHORA PRUEBA DESDE TU CELULAR (usando DATOS, NO WiFi):${NC}"
echo ""
echo "   http://trackhelper.fromcolombiawithcoffees.com"
echo ""
echo -e "${YELLOW}Si NO funciona desde Internet:${NC}"
echo ""
echo "1. Verifica port forwarding en el router:"
echo "   - Abre: http://192.168.0.1"
echo "   - Busca: Port Forwarding"
echo "   - Verifica que exista regla: Puerto 80 → 192.168.0.205"
echo ""
echo "2. Prueba con otro dominio que ya funciona:"
echo "   - ¿kellyapp o wimi funcionan desde Internet?"
echo "   - Si sí, entonces el port forwarding está bien"
echo "   - El problema es solo DNS o configuración de trackhelper"
echo ""
echo "3. Verifica DNS:"
echo "   dig +short trackhelper.fromcolombiawithcoffees.com"
echo "   Debe mostrar: 166.166.133.211"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}💡 TIP: Si quieres ver logs en tiempo real:${NC}"
echo "   tail -f /opt/homebrew/var/log/nginx/trackhelper.access.log"
echo "   tail -f /opt/homebrew/var/log/nginx/trackhelper.error.log"
echo ""
