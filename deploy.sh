#!/bin/bash

# Script de despliegue para TrackerCheck
# Uso: ./deploy.sh

set -e

echo "🚀 Iniciando despliegue de TrackerCheck..."
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar que Docker está corriendo
if ! docker info > /dev/null 2>&1; then
    print_error "Docker no está corriendo. Por favor inicia Docker Desktop."
    exit 1
fi
print_success "Docker está corriendo"

# Crear red si no existe
echo ""
echo "📡 Verificando red Docker..."
if ! docker network inspect nginx_default > /dev/null 2>&1; then
    docker network create nginx_default
    print_success "Red nginx_default creada"
else
    print_success "Red nginx_default ya existe"
fi

# Detener contenedores antiguos
echo ""
echo "🛑 Deteniendo contenedores anteriores..."
docker-compose down -v 2>/dev/null || true
print_success "Contenedores anteriores detenidos"

# Construir imagen
echo ""
echo "🔨 Construyendo imagen Docker..."
if docker-compose build; then
    print_success "Imagen construida exitosamente"
else
    print_error "Error al construir la imagen"
    exit 1
fi

# Levantar servicios
echo ""
echo "🚀 Levantando servicios..."
if docker-compose up -d; then
    print_success "Servicios levantados"
else
    print_error "Error al levantar los servicios"
    exit 1
fi

# Esperar a que el servidor inicie
echo ""
echo "⏳ Esperando a que el servidor inicie..."
sleep 5

# Verificar que los contenedores estén corriendo
echo ""
echo "🔍 Verificando estado de los contenedores..."
if docker-compose ps | grep -q "Up"; then
    print_success "Contenedores corriendo correctamente"
else
    print_warning "Los contenedores pueden no estar corriendo correctamente"
    docker-compose ps
fi

# Mostrar logs
echo ""
echo "📋 Últimos logs:"
echo "----------------------------------------"
docker-compose logs --tail=20
echo "----------------------------------------"

# Información final
echo ""
echo "========================================="
print_success "¡Despliegue completado!"
echo "========================================="
echo ""
echo "📊 Aplicación disponible en:"
echo "   - Frontend: http://localhost:3031"
echo "   - API: http://localhost:3030/api/process"
echo ""
echo "🌐 Configuración del dominio:"
echo "   trackhelper.fromcolombiawithcoffees.com"
echo ""
echo "📝 Comandos útiles:"
echo "   - Ver logs: docker-compose logs -f"
echo "   - Reiniciar: docker-compose restart"
echo "   - Detener: docker-compose down"
echo "   - Estado: docker-compose ps"
echo ""
print_warning "Asegúrate de configurar nginx según QUICK-START.md"
echo ""
