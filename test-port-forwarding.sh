#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     🔍 DIAGNÓSTICO DE PORT FORWARDING Y CONECTIVIDAD       ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. Verificar IP interna
echo -e "${YELLOW}[1/7] Verificando IP interna de tu Mac...${NC}"
IP_INTERNA=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
echo -e "IP Interna: ${GREEN}$IP_INTERNA${NC}"
if [ "$IP_INTERNA" != "192.168.0.205" ]; then
    echo -e "${RED}⚠️  ADVERTENCIA: Tu IP cambió. Actualiza el port forwarding en el router.${NC}"
fi
echo ""

# 2. Verificar IP pública
echo -e "${YELLOW}[2/7] Verificando IP pública...${NC}"
IP_PUBLICA=$(curl -s ifconfig.me)
echo -e "IP Pública: ${GREEN}$IP_PUBLICA${NC}"
if [ "$IP_PUBLICA" != "166.166.133.211" ]; then
    echo -e "${RED}⚠️  ADVERTENCIA: Tu IP pública cambió. Actualiza DNS.${NC}"
fi
echo ""

# 3. Verificar nginx en puerto 80
echo -e "${YELLOW}[3/7] Verificando nginx en puerto 80...${NC}"
if lsof -i :80 2>/dev/null | grep -q nginx; then
    echo -e "${GREEN}✅ nginx está escuchando en puerto 80${NC}"
else
    echo -e "${RED}❌ nginx NO está en puerto 80${NC}"
    echo "   Intenta: sudo nginx"
fi
echo ""

# 4. Verificar Docker containers
echo -e "${YELLOW}[4/7] Verificando apps en Docker...${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(trackercheck|wimi|kelly)" || echo "No hay apps corriendo"
echo ""

# 5. Test local
echo -e "${YELLOW}[5/7] Probando acceso LOCAL...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null)
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
    echo -e "${GREEN}✅ Acceso local funciona (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}❌ Acceso local NO funciona (HTTP $HTTP_CODE)${NC}"
fi
echo ""

# 6. Test IP interna
echo -e "${YELLOW}[6/7] Probando acceso por IP interna...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$IP_INTERNA 2>/dev/null)
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
    echo -e "${GREEN}✅ Acceso por IP interna funciona (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}❌ Acceso por IP interna NO funciona (HTTP $HTTP_CODE)${NC}"
fi
echo ""

# 7. Verificar firewall de macOS
echo -e "${YELLOW}[7/7] Verificando firewall de macOS...${NC}"
FIREWALL_STATUS=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null | grep -o "enabled\|disabled")
if [ "$FIREWALL_STATUS" = "enabled" ]; then
    echo -e "${YELLOW}⚠️  Firewall está ACTIVADO${NC}"
    echo "   Asegúrate que nginx tenga permiso para conexiones entrantes"
    echo "   Ubicación: Configuración del Sistema → Red → Firewall → Opciones"
elif [ "$FIREWALL_STATUS" = "disabled" ]; then
    echo -e "${GREEN}✅ Firewall está desactivado (no bloqueará conexiones)${NC}"
else
    echo -e "${YELLOW}❓ No se pudo verificar estado del firewall${NC}"
fi
echo ""

# Resumen y recomendaciones
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                         📋 RESUMEN                          ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
    echo -e "${GREEN}✅ Tu Mac está configurado correctamente${NC}"
    echo ""
    echo -e "${YELLOW}➡️  SIGUIENTE PASO: Configurar Port Forwarding en el router${NC}"
    echo ""
    echo "1. Abre tu router: http://192.168.0.1 o http://192.168.1.1"
    echo "2. Busca 'Port Forwarding' o 'Virtual Server'"
    echo "3. Agrega estas reglas:"
    echo ""
    echo "   Regla 1:"
    echo "   - Puerto Externo: 80"
    echo "   - Puerto Interno: 80"
    echo "   - IP Interna: $IP_INTERNA"
    echo "   - Protocolo: TCP"
    echo ""
    echo "   Regla 2:"
    echo "   - Puerto Externo: 443"
    echo "   - Puerto Interno: 443"
    echo "   - IP Interna: $IP_INTERNA"
    echo "   - Protocolo: TCP"
    echo ""
    echo "4. Guarda y reinicia el router"
    echo ""
    echo -e "${BLUE}📱 Después prueba desde tu celular (usando DATOS, no WiFi):${NC}"
    echo "   http://trackhelper.fromcolombiawithcoffees.com"
    echo ""
else
    echo -e "${RED}❌ Hay problemas en tu Mac${NC}"
    echo ""
    echo "Verifica:"
    echo "1. ¿Nginx está corriendo?"
    echo "   sudo nginx"
    echo ""
    echo "2. ¿Las apps de Docker están corriendo?"
    echo "   docker-compose up -d"
    echo ""
    echo "3. ¿Hay errores en nginx?"
    echo "   tail -f /opt/homebrew/var/log/nginx/error.log"
    echo ""
fi

# Opción alternativa
echo -e "${BLUE}═════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}💡 ALTERNATIVA RÁPIDA: ngrok (si el router es complicado)${NC}"
echo ""
echo "Si no puedes configurar el router, usa ngrok:"
echo ""
echo "  brew install ngrok"
echo "  ngrok config add-authtoken TU_TOKEN"
echo "  ngrok http 80"
echo ""
echo "Registro gratis: https://dashboard.ngrok.com/signup"
echo ""
