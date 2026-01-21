#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     🔍 DIAGNÓSTICO COMPLETO DE CONECTIVIDAD              ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. IPs
echo -e "${YELLOW}[1] Verificando IPs...${NC}"
IP_INTERNA=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
IP_PUBLICA=$(curl -s --max-time 5 ifconfig.me)
echo "  IP Interna: $IP_INTERNA"
echo "  IP Pública: $IP_PUBLICA"
echo ""

# 2. Gateway (Router)
echo -e "${YELLOW}[2] Verificando gateway (router)...${NC}"
GATEWAY=$(netstat -nr | grep default | awk '{print $2}' | head -1)
echo "  Gateway: $GATEWAY"
ping -c 2 $GATEWAY > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✅ Router alcanzable${NC}"
else
    echo -e "  ${RED}❌ No se puede alcanzar el router${NC}"
fi
echo ""

# 3. DNS
echo -e "${YELLOW}[3] Verificando DNS...${NC}"
for domain in kellyapp.fromcolombiawithcoffees.com wimi.fromcolombiawithcoffees.com trackhelper.fromcolombiawithcoffees.com; do
    IP=$(dig +short $domain | head -1)
    echo "  $domain → $IP"
done
echo ""

# 4. Nginx
echo -e "${YELLOW}[4] Verificando nginx...${NC}"
if ps aux | grep -v grep | grep -q "nginx: master"; then
    echo -e "  ${GREEN}✅ nginx corriendo${NC}"
    if netstat -an | grep '\.80.*LISTEN' > /dev/null; then
        echo -e "  ${GREEN}✅ nginx en puerto 80${NC}"
    else
        echo -e "  ${RED}❌ nginx NO en puerto 80${NC}"
    fi
else
    echo -e "  ${RED}❌ nginx NO está corriendo${NC}"
fi
echo ""

# 5. Docker
echo -e "${YELLOW}[5] Verificando Docker apps...${NC}"
docker ps --format "  {{.Names}}: {{.Status}}" | grep -E "(kelly|wimi|rowg|cupping)"
echo ""

# 6. Test local
echo -e "${YELLOW}[6] Test de acceso local...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null)
echo "  http://localhost → HTTP $HTTP_CODE"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$IP_INTERNA 2>/dev/null)
echo "  http://$IP_INTERNA → HTTP $HTTP_CODE"
echo ""

# 7. Test acceso por IP pública desde el Mac
echo -e "${YELLOW}[7] Intentando acceder por IP pública desde tu Mac...${NC}"
echo "  (Esto puede fallar por NAT loopback)"
timeout 5 curl -s http://$IP_PUBLICA > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✅ Accesible por IP pública${NC}"
else
    echo -e "  ${YELLOW}⚠️  No accesible (puede ser NAT loopback normal)${NC}"
fi
echo ""

# 8. Verificar si hay reglas de firewall
echo -e "${YELLOW}[8] Verificando firewall de macOS...${NC}"
FIREWALL=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null)
echo "  $FIREWALL"
echo ""

# 9. Verificar uptime del Mac
echo -e "${YELLOW}[9] Uptime del Mac...${NC}"
uptime
echo ""

# Resumen
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                      RESUMEN Y RECOMENDACIONES              ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
    echo -e "${GREEN}✅ Tu Mac está funcionando correctamente${NC}"
    echo ""
    echo -e "${YELLOW}El problema es el ROUTER o el ISP${NC}"
    echo ""
    echo "Acciones a tomar:"
    echo ""
    echo "1. ${BLUE}REINICIAR EL ROUTER${NC}"
    echo "   - Desconecta el cable de corriente"
    echo "   - Espera 30 segundos"
    echo "   - Conéctalo de nuevo"
    echo "   - Espera 3 minutos"
    echo "   - Prueba de nuevo desde tu celular"
    echo ""
    echo "2. ${BLUE}VERIFICAR PORT FORWARDING${NC}"
    echo "   - Abre: http://$GATEWAY"
    echo "   - Busca: Port Forwarding"
    echo "   - Verifica reglas para puerto 80 y 443"
    echo "   - IP destino debe ser: $IP_INTERNA"
    echo ""
    echo "3. ${BLUE}VERIFICAR IP WAN DEL ROUTER${NC}"
    echo "   - En el router, busca 'Status' o 'WAN Status'"
    echo "   - Verifica que WAN IP = $IP_PUBLICA"
    echo "   - Si es diferente, tienes CGNAT (no puedes usar port forwarding)"
    echo ""
    echo "4. ${BLUE}SOLUCIÓN TEMPORAL: USAR NGROK${NC}"
    echo "   brew install ngrok"
    echo "   ngrok http 80"
    echo ""
else
    echo -e "${RED}❌ Hay problemas en tu Mac${NC}"
    echo ""
    echo "nginx o las apps no están respondiendo correctamente."
    echo ""
    echo "Verifica:"
    echo "  - nginx corriendo: sudo nginx"
    echo "  - Docker apps: docker ps"
    echo "  - Logs de nginx: tail -f /opt/homebrew/var/log/nginx/error.log"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
