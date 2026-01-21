#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     🚀 Configuración de Cloudflare Tunnel              ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verificar que cloudflared esté instalado
if ! command -v cloudflared &> /dev/null; then
    echo -e "${RED}❌ cloudflared no está instalado${NC}"
    echo "Instalando..."
    brew install cloudflare/cloudflare/cloudflared
fi

echo -e "${GREEN}✅ cloudflared instalado${NC}"
echo ""

# Paso 1: Login
echo -e "${YELLOW}PASO 1: Login en Cloudflare${NC}"
echo ""
echo "Esto abrirá tu navegador para que autorices cloudflared"
echo "en tu cuenta de Cloudflare."
echo ""
read -p "Presiona ENTER para continuar..."

cloudflared tunnel login

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error en el login${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Login exitoso${NC}"
echo ""

# Paso 2: Crear túnel
echo -e "${YELLOW}PASO 2: Crear túnel${NC}"
echo ""

TUNNEL_NAME="fromcolombia"

# Verificar si ya existe
if cloudflared tunnel list | grep -q "$TUNNEL_NAME"; then
    echo -e "${YELLOW}⚠️  El túnel '$TUNNEL_NAME' ya existe${NC}"
    read -p "¿Quieres usar el existente? (y/n): " use_existing
    if [ "$use_existing" != "y" ]; then
        read -p "Nombre del nuevo túnel: " TUNNEL_NAME
        cloudflared tunnel create $TUNNEL_NAME
    fi
else
    cloudflared tunnel create $TUNNEL_NAME
fi

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error al crear túnel${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Túnel '$TUNNEL_NAME' listo${NC}"
echo ""

# Obtener ID del túnel
TUNNEL_ID=$(cloudflared tunnel list | grep "$TUNNEL_NAME" | awk '{print $1}')
echo "Túnel ID: $TUNNEL_ID"
echo ""

# Paso 3: Crear archivo de configuración
echo -e "${YELLOW}PASO 3: Configurar archivo config.yml${NC}"
echo ""

mkdir -p ~/.cloudflared

cat > ~/.cloudflared/config.yml << EOF
tunnel: $TUNNEL_ID
credentials-file: /Users/$USER/.cloudflared/$TUNNEL_ID.json

ingress:
  # TrackerCheck
  - hostname: trackhelper.fromcolombiawithcoffees.com
    service: http://localhost:4031
    originRequest:
      noTLSVerify: true

  # Kelly App
  - hostname: kellyapp.fromcolombiawithcoffees.com
    service: http://localhost:3025
    originRequest:
      noTLSVerify: true

  # Wimi
  - hostname: wimi.fromcolombiawithcoffees.com
    service: http://localhost:3080
    originRequest:
      noTLSVerify: true

  # ROWG
  - hostname: rowg.fromcolombiawithcoffees.com
    service: http://localhost:3010
    originRequest:
      noTLSVerify: true

  # Cupping
  - hostname: cupping.fromcolombiawithcoffees.com
    service: http://localhost:8080
    originRequest:
      noTLSVerify: true

  # Automations
  - hostname: automations.fromcolombiawithcoffees.com
    service: http://localhost:5678
    originRequest:
      noTLSVerify: true

  # Catch-all
  - service: http_status:404
EOF

echo -e "${GREEN}✅ Archivo de configuración creado${NC}"
echo ""

# Paso 4: Configurar DNS
echo -e "${YELLOW}PASO 4: Configurar DNS en Cloudflare${NC}"
echo ""
echo "Configurando DNS para cada dominio..."
echo ""

DOMAINS=(
    "trackhelper.fromcolombiawithcoffees.com"
    "kellyapp.fromcolombiawithcoffees.com"
    "wimi.fromcolombiawithcoffees.com"
    "rowg.fromcolombiawithcoffees.com"
    "cupping.fromcolombiawithcoffees.com"
    "automations.fromcolombiawithcoffees.com"
)

for domain in "${DOMAINS[@]}"; do
    echo "  Configurando: $domain"
    cloudflared tunnel route dns $TUNNEL_NAME $domain 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "    ${GREEN}✅${NC}"
    else
        echo -e "    ${YELLOW}⚠️  Ya existe o error${NC}"
    fi
done

echo ""
echo -e "${GREEN}✅ DNS configurado${NC}"
echo ""

# Paso 5: Probar configuración
echo -e "${YELLOW}PASO 5: Validar configuración${NC}"
echo ""

cloudflared tunnel ingress validate

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Configuración válida${NC}"
else
    echo -e "${RED}❌ Error en la configuración${NC}"
    exit 1
fi
echo ""

# Resumen
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                   ✅ CONFIGURACIÓN COMPLETA                 ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${GREEN}Túnel configurado correctamente!${NC}"
echo ""
echo -e "${YELLOW}📝 SIGUIENTE PASO: Iniciar el túnel${NC}"
echo ""
echo "Opción 1: Iniciar manualmente (para probar):"
echo -e "  ${BLUE}cloudflared tunnel run $TUNNEL_NAME${NC}"
echo ""
echo "Opción 2: Instalar como servicio (se inicia automáticamente):"
echo -e "  ${BLUE}sudo cloudflared service install${NC}"
echo ""
echo "Tus dominios estarán disponibles en ~1 minuto después de iniciar el túnel:"
echo ""
for domain in "${DOMAINS[@]}"; do
    echo "  ✨ https://$domain"
done
echo ""
echo -e "${YELLOW}💡 TIP: Usa 'cloudflared tunnel run $TUNNEL_NAME' para probarlo primero${NC}"
echo ""
