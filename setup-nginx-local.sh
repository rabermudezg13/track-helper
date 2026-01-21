#!/bin/bash

echo "🚀 Configurando nginx para trackhelper.fromcolombiawithcoffees.com"
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}📋 PASO 1: Copiar configuración de nginx${NC}"
echo "Ejecuta este comando (te pedirá tu contraseña):"
echo ""
echo "sudo cp trackerhelper-local.conf /opt/homebrew/etc/nginx/servers/trackhelper.conf"
echo ""
read -p "Presiona ENTER cuando hayas ejecutado el comando..."

echo ""
echo -e "${YELLOW}📋 PASO 2: Verificar configuración de nginx${NC}"
sudo nginx -t
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Hay un problema con la configuración. Revisa los errores arriba.${NC}"
    echo ""
    echo "Si hay problemas de permisos en otros archivos .conf, puedes:"
    echo "sudo chmod 644 /opt/homebrew/etc/nginx/servers/*.conf"
    echo ""
    read -p "¿Quieres que intente arreglar los permisos? (y/n): " fix_perms
    if [ "$fix_perms" = "y" ]; then
        sudo chmod 644 /opt/homebrew/etc/nginx/servers/*.conf
        echo "Intentando de nuevo..."
        sudo nginx -t
    fi
fi

echo ""
echo -e "${YELLOW}📋 PASO 3: Detener nginx si está corriendo${NC}"
sudo nginx -s stop 2>/dev/null || echo "nginx no estaba corriendo"

echo ""
echo -e "${YELLOW}📋 PASO 4: Iniciar nginx${NC}"
sudo nginx
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ nginx iniciado correctamente${NC}"
else
    echo -e "${YELLOW}⚠️  Error al iniciar nginx. Revisa los logs:${NC}"
    echo "tail -f /opt/homebrew/var/log/nginx/error.log"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ PASO 5: Verificar que nginx está escuchando en puerto 80${NC}"
sleep 2
if lsof -i :80 | grep -q nginx; then
    echo -e "${GREEN}✅ nginx escuchando en puerto 80${NC}"
else
    echo -e "${YELLOW}⚠️  nginx no está escuchando en puerto 80${NC}"
fi

echo ""
echo -e "${YELLOW}📋 PASO 6: Configurar Port Forwarding en tu router${NC}"
echo ""
echo "Necesitas abrir estos puertos en tu router:"
echo ""
echo "  Puerto Externo: 80"
echo "  Puerto Interno: 80"
echo "  IP Interna: 192.168.0.205"
echo "  Protocolo: TCP"
echo ""
echo "Pasos generales:"
echo "1. Abre http://192.168.0.1 en tu navegador (o la IP de tu router)"
echo "2. Ingresa usuario/contraseña (suele estar en el router)"
echo "3. Busca 'Port Forwarding' o 'Virtual Server' o 'NAT'"
echo "4. Agrega la regla con los datos de arriba"
echo "5. Guarda los cambios"
echo ""
read -p "Presiona ENTER cuando hayas configurado el port forwarding..."

echo ""
echo -e "${GREEN}🧪 PASO 7: Probando acceso...${NC}"
echo ""
echo "Probando acceso local:"
curl -I http://localhost 2>&1 | head -5

echo ""
echo -e "${YELLOW}📝 SIGUIENTE PASO:${NC}"
echo ""
echo "Prueba desde tu navegador:"
echo "  http://trackhelper.fromcolombiawithcoffees.com"
echo ""
echo "Si funciona localmente pero no desde afuera:"
echo "  1. Verifica el port forwarding en el router"
echo "  2. Verifica que tu firewall de macOS permita conexiones al puerto 80"
echo "     (Sistema > Privacidad y Seguridad > Firewall)"
echo ""
echo -e "${GREEN}✅ Configuración completada!${NC}"
