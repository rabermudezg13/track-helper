# 🚨 PROBLEMA URGENTE: Todos los Dominios Dejaron de Funcionar

## 📊 SITUACIÓN CRÍTICA

**Ayer**: Todos los dominios funcionaban ✅
**Hoy**: NINGÚN dominio funciona ❌

Dominios afectados:
- trackhelper.fromcolombiawithcoffees.com
- kellyapp.fromcolombiawithcoffees.com
- wimi.fromcolombiawithcoffees.com
- rowg.fromcolombiawithcoffees.com
- cupping.fromcolombiawithcoffees.com
- automations.fromcolombiawithcoffees.com

**Todos dan timeout desde Internet**

---

## 🔍 DIAGNÓSTICO: Qué Pudo Pasar

### Causa Más Probable: Router se Reinició

El router probablemente se reinició (corte de luz, actualización automática, etc.) y **perdió la configuración de port forwarding**.

### Otras Causas Posibles:

1. **ISP cambió tu IP pública** (y DNS no se actualizó)
2. **ISP bloqueó puertos** (cambio en política)
3. **Firewall del router** se activó
4. **Tu Mac perdió la IP estática** 192.168.0.205

---

## ✅ SOLUCIÓN RÁPIDA (5-10 minutos)

### PASO 1: Verificar que tu Mac esté bien

```bash
# 1. Verificar IP interna
ifconfig | grep "inet " | grep -v 127.0.0.1
# Debe mostrar: 192.168.0.205

# 2. Verificar IP pública
curl ifconfig.me
# Debe mostrar: 166.166.133.211

# 3. Verificar nginx corriendo
lsof -i :80 2>/dev/null || netstat -an | grep '\.80.*LISTEN'

# 4. Test local
curl -I http://localhost
```

Si todo eso funciona, tu Mac está bien. El problema es el router.

---

### PASO 2: Reconfigurar Port Forwarding en el Router

**A. Acceder al router**:

1. Abre: http://192.168.0.1 (o http://192.168.1.1)
2. Login: admin/admin (o mira el sticker del router)

**B. Buscar Port Forwarding**:
- Menú: "Port Forwarding", "Virtual Server", "NAT", "Applications"

**C. Verificar/Agregar reglas**:

```
Regla 1: HTTP
- Nombre: Web-HTTP
- Puerto Externo: 80
- Puerto Interno: 80
- IP Interna: 192.168.0.205
- Protocolo: TCP
- Estado: Enabled/Habilitado

Regla 2: HTTPS
- Nombre: Web-HTTPS
- Puerto Externo: 443
- Puerto Interno: 443
- IP Interna: 192.168.0.205
- Protocolo: TCP
- Estado: Enabled/Habilitado
```

**D. Guardar y reiniciar**:
1. Click "Save" o "Aplicar"
2. Reinicia el router si lo pide
3. Espera 2-3 minutos

**E. Probar**:
Desde tu celular (DATOS, no WiFi):
```
http://wimi.fromcolombiawithcoffees.com
```

---

### PASO 3: Si la IP Pública Cambió

Si `curl ifconfig.me` muestra una IP diferente a `166.166.133.211`:

**Necesitas actualizar el DNS** para que apunte a la nueva IP.

¿Dónde tienes configurado el DNS de `*.fromcolombiawithcoffees.com`?
- Cloudflare?
- GoDaddy?
- NameCheap?
- Otro?

---

## 🚀 SOLUCIÓN TEMPORAL INMEDIATA (2 minutos)

Mientras arreglas el router, usa **ngrok** para que todo vuelva a funcionar:

```bash
# 1. Instalar (si no lo tienes)
brew install ngrok

# 2. Registrarte GRATIS
# https://dashboard.ngrok.com/signup

# 3. Configurar token
ngrok config add-authtoken TU_TOKEN_AQUI

# 4. Crear túnel
ngrok http 80
```

**Resultado**: Te dará una URL como `https://abc123.ngrok.io`

Comparte esa URL y TODO funcionará mientras arreglas el router.

---

## 🔧 SOLUCIÓN PERMANENTE: Cloudflare Tunnel

Si quieres evitar este problema en el futuro, usa **Cloudflare Tunnel**:

**Ventajas**:
- ✅ No depende del router
- ✅ Usa tus dominios reales
- ✅ HTTPS automático
- ✅ Gratis
- ✅ Si el router se reinicia, sigue funcionando

**Instalación (15 minutos)**:

```bash
# 1. Instalar
brew install cloudflare/cloudflare/cloudflared

# 2. Login (abre navegador)
cloudflared tunnel login

# 3. Crear túnel
cloudflared tunnel create fromcolombia

# 4. Configurar para cada dominio
cloudflared tunnel route dns fromcolombia trackhelper.fromcolombiawithcoffees.com
cloudflared tunnel route dns fromcolombia kellyapp.fromcolombiawithcoffees.com
cloudflared tunnel route dns fromcolombia wimi.fromcolombiawithcoffees.com
# ... etc para cada dominio

# 5. Crear archivo de configuración
cat > ~/.cloudflared/config.yml << 'EOF'
tunnel: fromcolombia
credentials-file: /Users/rodrigobermudez/.cloudflared/fromcolombia.json

ingress:
  - hostname: trackhelper.fromcolombiawithcoffees.com
    service: http://localhost:3051
  - hostname: kellyapp.fromcolombiawithcoffees.com
    service: http://localhost:3025
  - hostname: wimi.fromcolombiawithcoffees.com
    service: http://localhost:3080
  - hostname: rowg.fromcolombiawithcoffees.com
    service: http://localhost:3010
  - hostname: cupping.fromcolombiawithcoffees.com
    service: http://localhost:8080
  - hostname: automations.fromcolombiawithcoffees.com
    service: http://localhost:5678
  - service: http_status:404
EOF

# 6. Iniciar túnel
cloudflared tunnel run fromcolombia
```

Esto hace que tus apps sean accesibles **sin depender del router**.

---

## 📋 CHECKLIST DE DIAGNÓSTICO

Verifica cada punto:

### En tu Mac:
- [ ] IP interna: 192.168.0.205
- [ ] IP pública: 166.166.133.211
- [ ] nginx corriendo en puerto 80
- [ ] `curl http://localhost` funciona
- [ ] Docker containers corriendo

### En el Router:
- [ ] Puedes acceder al router (http://192.168.0.1)
- [ ] Port forwarding existe para puerto 80
- [ ] Port forwarding existe para puerto 443
- [ ] IP en port forwarding es 192.168.0.205
- [ ] Estado es "Enabled"

### DNS:
- [ ] `dig trackhelper.fromcolombiawithcoffees.com` → 166.166.133.211
- [ ] `dig kellyapp.fromcolombiawithcoffees.com` → 166.166.133.211

---

## 🎯 ACCIÓN INMEDIATA RECOMENDADA

### Opción A: Arreglar Router (10 minutos)
1. Entra al router
2. Reconfigura port forwarding
3. Reinicia router
4. Prueba

### Opción B: ngrok Temporal (2 minutos)
1. Instala ngrok
2. Crea túnel
3. Comparte URL
4. Arregla router después

### Opción C: Cloudflare Tunnel (15 minutos)
1. Instala cloudflared
2. Configura túneles
3. Olvídate del router para siempre

---

## 💡 MI RECOMENDACIÓN

**AHORA**: Usa **ngrok** (2 minutos) para que todo funcione temporalmente

**DESPUÉS**: Configura **Cloudflare Tunnel** (15 minutos) para solución permanente

**POR QUÉ**:
- Evitas problemas con router
- No depende de port forwarding
- HTTPS incluido
- Gratis
- Más estable

---

## 📞 SIGUIENTE PASO

Dime cuál opción prefieres:

1. **ngrok ahora** (te guío)
2. **Cloudflare Tunnel** (configuración completa)
3. **Arreglar router** (te ayudo a entrar y configurar)

O si prefieres, ejecuta este diagnóstico primero:

```bash
cd /Users/rodrigobermudez/trackercheck
./test-port-forwarding.sh
```

Y muéstrame el resultado.
