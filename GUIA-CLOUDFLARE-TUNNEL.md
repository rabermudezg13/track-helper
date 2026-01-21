# 🚀 Guía Completa: Cloudflare Tunnel

## ✅ REQUISITOS PREVIOS

Antes de comenzar, asegúrate de tener:

1. ✅ Cuenta en Cloudflare (gratis): https://dash.cloudflare.com/sign-up
2. ✅ Tu dominio `fromcolombiawithcoffees.com` en Cloudflare
   - Si aún no está en Cloudflare, necesitas transferirlo (toma 5 minutos)
3. ✅ cloudflared instalado (ejecutándose ahora)

---

## 🎯 QUÉ VAMOS A LOGRAR

Después de esta configuración:

- ✅ **TODAS** tus 6 apps accesibles desde Internet
- ✅ Con **tus dominios propios** (*.fromcolombiawithcoffees.com)
- ✅ **HTTPS automático** (certificados gratis)
- ✅ **Sin depender del router** (no más port forwarding)
- ✅ **DDoS protection** incluido
- ✅ **$0/mes** para siempre

---

## 📋 PASOS DE CONFIGURACIÓN

### Opción A: Script Automático (RECOMENDADO) ⚡

**Tiempo: 5-10 minutos**

```bash
cd /Users/rodrigobermudez/trackercheck
./setup-cloudflare-tunnel.sh
```

Este script hará TODO automáticamente:
1. Verificar instalación de cloudflared
2. Login en Cloudflare (abre navegador)
3. Crear túnel
4. Configurar archivo config.yml
5. Configurar DNS para cada dominio
6. Validar configuración

**Simplemente sigue las instrucciones en pantalla.**

---

### Opción B: Manual (Si prefieres ver cada paso)

#### PASO 1: Verificar instalación

```bash
cloudflared --version
```

Deberías ver algo como: `cloudflared version 2024.x.x`

---

#### PASO 2: Login en Cloudflare

```bash
cloudflared tunnel login
```

Esto abrirá tu navegador.

**En el navegador**:
1. Inicia sesión en Cloudflare
2. Selecciona tu dominio: `fromcolombiawithcoffees.com`
3. Click en "Authorize"

**Resultado**: Verás un mensaje de éxito y se creará un archivo en `~/.cloudflared/cert.pem`

---

#### PASO 3: Crear el túnel

```bash
cloudflared tunnel create fromcolombia
```

**Resultado**: Se creará un túnel con ID único (algo como `abc123-def456-ghi789`)

Para ver tus túneles:
```bash
cloudflared tunnel list
```

---

#### PASO 4: Crear archivo de configuración

```bash
# Obtener ID del túnel
TUNNEL_ID=$(cloudflared tunnel list | grep fromcolombia | awk '{print $1}')

# Crear directorio
mkdir -p ~/.cloudflared

# Crear archivo de configuración
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
```

---

#### PASO 5: Configurar DNS

Para cada dominio, ejecuta:

```bash
TUNNEL_NAME="fromcolombia"

cloudflared tunnel route dns $TUNNEL_NAME trackhelper.fromcolombiawithcoffees.com
cloudflared tunnel route dns $TUNNEL_NAME kellyapp.fromcolombiawithcoffees.com
cloudflared tunnel route dns $TUNNEL_NAME wimi.fromcolombiawithcoffees.com
cloudflared tunnel route dns $TUNNEL_NAME rowg.fromcolombiawithcoffees.com
cloudflared tunnel route dns $TUNNEL_NAME cupping.fromcolombiawithcoffees.com
cloudflared tunnel route dns $TUNNEL_NAME automations.fromcolombiawithcoffees.com
```

Esto crea registros CNAME en Cloudflare automáticamente.

---

#### PASO 6: Validar configuración

```bash
cloudflared tunnel ingress validate
```

Deberías ver: "Configuration is valid"

---

#### PASO 7: Iniciar el túnel (PRIMERA VEZ - PARA PROBAR)

```bash
cloudflared tunnel run fromcolombia
```

**Verás algo como**:
```
INF Connection registered connIndex=0
INF Starting tunnel fromcolombia
INF Registered tunnel connection
```

**Deja esta terminal abierta** (el túnel está corriendo).

---

#### PASO 8: Probar los dominios

**En otra terminal o desde tu celular**:

```bash
curl -I https://trackhelper.fromcolombiawithcoffees.com
curl -I https://kellyapp.fromcolombiawithcoffees.com
curl -I https://wimi.fromcolombiawithcoffees.com
```

Deberías ver respuestas HTTP 200 o 301.

**Abre en el navegador**:
- https://trackhelper.fromcolombiawithcoffees.com
- https://kellyapp.fromcolombiawithcoffees.com
- https://wimi.fromcolombiawithcoffees.com

✨ **¡Deberían funcionar!**

---

#### PASO 9: Instalar como servicio (PARA QUE SE INICIE AUTOMÁTICAMENTE)

Una vez que confirmes que funciona, instala el servicio:

```bash
sudo cloudflared service install
```

Esto hace que el túnel:
- ✅ Se inicie automáticamente al encender tu Mac
- ✅ Se reinicie si falla
- ✅ Corra en segundo plano

**Comandos útiles del servicio**:

```bash
# Ver estado
sudo launchctl list | grep cloudflared

# Detener
sudo cloudflared service uninstall

# Ver logs
tail -f /usr/local/var/log/cloudflared.log
```

---

## 🔧 TROUBLESHOOTING

### Problema: "No se puede conectar al túnel"

**Verificar**:
```bash
# ¿El túnel está corriendo?
ps aux | grep cloudflared

# ¿Docker apps están corriendo?
docker ps

# ¿Los puertos están abiertos?
lsof -i :4031  # TrackerCheck
lsof -i :3025  # Kelly
lsof -i :3080  # Wimi
```

---

### Problema: "Invalid credentials"

**Solución**:
```bash
# Hacer login de nuevo
cloudflared tunnel login

# Verificar cert
ls -la ~/.cloudflared/cert.pem
```

---

### Problema: "DNS ya existe"

Esto es normal si ejecutas el comando de DNS dos veces. Ignóralo o verifica en Cloudflare Dashboard:

https://dash.cloudflare.com/ → Tu dominio → DNS

Deberías ver registros CNAME apuntando a `<TUNNEL_ID>.cfargotunnel.com`

---

### Problema: "Configuración inválida"

**Verificar**:
```bash
# Ver archivo de configuración
cat ~/.cloudflared/config.yml

# Validar sintaxis
cloudflared tunnel ingress validate

# Ver logs
cloudflared tunnel run fromcolombia --loglevel debug
```

---

## 📊 COMANDOS ÚTILES

### Ver túneles activos
```bash
cloudflared tunnel list
```

### Ver rutas DNS configuradas
```bash
cloudflared tunnel route dns list
```

### Ver información del túnel
```bash
cloudflared tunnel info fromcolombia
```

### Iniciar en modo debug
```bash
cloudflared tunnel run --loglevel debug fromcolombia
```

### Ver logs del servicio
```bash
tail -f /usr/local/var/log/cloudflared.log
```

---

## 🎯 DESPUÉS DE LA CONFIGURACIÓN

### Verificar en Cloudflare Dashboard

1. Ve a: https://dash.cloudflare.com/
2. Selecciona tu dominio
3. Ve a **Traffic** → **Cloudflare Tunnel**
4. Deberías ver tu túnel "fromcolombia" como **Healthy** (verde)

### Analytics

En el mismo dashboard puedes ver:
- 📊 Tráfico por dominio
- 🌍 Ubicación de visitantes
- 📈 Requests por segundo
- 🛡️ Amenazas bloqueadas

---

## ⚙️ AJUSTAR CONFIGURACIÓN

Si necesitas agregar o cambiar dominios:

1. **Editar archivo**:
   ```bash
   nano ~/.cloudflared/config.yml
   ```

2. **Agregar nueva app**:
   ```yaml
   - hostname: nueva.fromcolombiawithcoffees.com
     service: http://localhost:PUERTO
     originRequest:
       noTLSVerify: true
   ```

3. **Configurar DNS**:
   ```bash
   cloudflared tunnel route dns fromcolombia nueva.fromcolombiawithcoffees.com
   ```

4. **Reiniciar túnel**:
   ```bash
   sudo launchctl stop com.cloudflare.cloudflared
   sudo launchctl start com.cloudflare.cloudflared
   ```

---

## 🔒 SEGURIDAD ADICIONAL

### Agregar autenticación (opcional)

Puedes proteger tus apps con Cloudflare Access (email, Google, etc.):

1. Ve a https://dash.cloudflare.com/
2. **Zero Trust** → **Access** → **Applications**
3. **Add an application**
4. Configura reglas (ej: solo tu email)

---

## 💡 TIPS PRO

### 1. Monitoreo

Agrega healthchecks en el config.yml:

```yaml
ingress:
  - hostname: trackhelper.fromcolombiawithcoffees.com
    service: http://localhost:4031
    originRequest:
      noTLSVerify: true
      httpHostHeader: trackhelper.fromcolombiawithcoffees.com
```

### 2. Load Balancing

Si tienes réplicas de apps, Cloudflare puede balancear:

```yaml
- hostname: app.fromcolombiawithcoffees.com
  service: http://localhost:3000
  originRequest:
    connectTimeout: 10s
```

### 3. WebSocket Support

Para apps con WebSockets (como n8n):

```yaml
- hostname: automations.fromcolombiawithcoffees.com
  service: http://localhost:5678
  originRequest:
    noTLSVerify: true
    httpHostHeader: automations.fromcolombiawithcoffees.com
```

---

## 🎉 VENTAJAS QUE AHORA TIENES

Comparado con port forwarding:

✅ **No depende del router** (nunca más problemas de port forwarding)
✅ **HTTPS automático** (certificados gratis, se renuevan solos)
✅ **DDoS protection** (Cloudflare bloquea ataques automáticamente)
✅ **CDN global** (apps más rápidas en todo el mundo)
✅ **Analytics incluidos** (ves tráfico, visitantes, amenazas)
✅ **IP oculta** (tu IP real no se expone)
✅ **Zero Trust** (puedes agregar autenticación fácilmente)
✅ **$0/mes** (gratis para siempre)

---

## 📞 SIGUIENTE PASO

**Ejecuta el script**:

```bash
cd /Users/rodrigobermudez/trackercheck
./setup-cloudflare-tunnel.sh
```

Y sígueme mostrando la salida si hay algún error.

¡En 10 minutos todas tus apps estarán accesibles! 🚀
