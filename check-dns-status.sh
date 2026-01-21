#!/bin/bash

# Script para verificar estado de propagación DNS

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=== ESTADO DE PROPAGACIÓN DNS ==="
echo ""

check_domain() {
    local subdomain=$1
    local full_domain="${subdomain}.fromcolombiawithcoffees.com"
    local ips=$(dig +short $full_domain | head -2)

    echo -n "$subdomain: "

    if echo "$ips" | grep -q "104.21\|172.67\|cfargotunnel"; then
        echo -e "${GREEN}✅ Funcionando${NC}"
        return 0
    elif [ -z "$ips" ]; then
        echo -e "${YELLOW}⏳ Sin DNS${NC}"
        return 1
    else
        echo -e "${RED}❌ DNS antiguo ($ips)${NC}"
        return 1
    fi
}

# Verificar todos
check_domain "trackhelper"
check_domain "kellyapp"
check_domain "wimi"
check_domain "rowg"
check_domain "cupping"
check_domain "automations"

echo ""
echo "Nota: Los que muestran ❌ aún están propagando (puede tardar 5-15 min más)"
