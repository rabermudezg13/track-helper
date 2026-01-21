# 🌐 Configurar trackhelper.fromcolombiawithcoffees.com

## ✅ Estado Actual

- ✅ DNS configurado: `trackhelper.fromcolombiawithcoffees.com` → `166.166.133.211` (tu IP)
- ✅ Docker corriendo: Frontend en 3051, API en 3050
- ✅ Nginx instalado en tu Mac
- ✅ Configuración de nginx creada: `trackerhelper-local.conf`

---

## 🚀 Pasos para Activar el Dominio

### PASO 1: Copiar configuración a nginx

Abre tu Terminal y ejecuta:

```bash
cd /Users/rodrigobermudez/trackercheck
sudo cp trackerhelper-local.conf /opt/homebrew/etc/nginx/servers/trackhelper.conf
```

Te pedirá tu contraseña de Mac.

---

### PASO 2: Verificar configuración

```bash
sudo nginx -t
```

**Si hay errores de permisos en otros archivos** (watermark.conf, etc.):

```bash
sudo chmod 644 /opt/homebrew/etc/nginx/servers/*.conf
sudo nginx -t
```

---

### PASO 3: Reiniciar nginx

```bash
# Detener nginx si está corriendo
sudo nginx -s stop

# Iniciar nginx
sudo nginx
```

**Verificar que está corriendo:**

```bash
lsof -i :80 | grep nginx
```

Deberías ver algo como:
```
nginx   12345   root    6u  IPv4  ...  TCP *:http (LISTEN)
```

---

### PASO 4: Probar localmente

```bash
curl -I http://localhost
```

Deberías ver algo como:
```
HTTP/1.1 200 OK
...
```

**Prueba en tu navegador:**
- http://localhost
- http://trackhelper.fromcolombiawithcoffees.com (solo funcionará localmente por ahora)

---

### PASO 5: Configurar Port Forwarding en tu Router

Para que funcione desde Internet, necesitas abrir el puerto 80 en tu router.

#### 5.1 Acceder a tu router

Abre en tu navegador una de estas direcciones:
- http://192.168.0.1
- http://192.168.1.1
- http://192.168.1.254

**Usuario/contraseña comunes:**
- admin / admin
- admin / password
- admin / (vacío)
- Mira en tu router físico, suele tener una etiqueta

#### 5.2 Buscar Port Forwarding

Busca alguno de estos nombres en el menú:
- Port Forwarding
- Virtual Server
- NAT Forwarding
- Applications & Gaming
- Firewall → Port Forwarding

#### 5.3 Agregar regla

Crea una nueva regla con estos datos:

```
Nombre/Servicio: TrackerCheck
Puerto Externo: 80
Puerto Interno: 80
IP Interna: 192.168.0.205
Protocolo: TCP
Estado: Enabled/Habilitado
```

**Guarda los cambios** (suele requerir reiniciar el router)

---

### PASO 6: Verificar Firewall de macOS

Ve a:
```
 → Configuración del Sistema → Red → Firewall
```

Si el Firewall está activado:
1. Click en "Opciones..."
2. Busca "nginx" en la lista
3. Asegúrate que esté en "Permitir conexiones entrantes"

Si no aparece nginx, agrega una excepción manualmente.

---

### PASO 7: Probar desde Internet

#### Opción A: Desde tu celular (usando datos móviles, NO WiFi)

Abre en el navegador:
```
http://trackhelper.fromcolombiawithcoffees.com
```

#### Opción B: Desde cualquier otro lugar

Pídele a alguien que pruebe esa URL, o usa un proxy online como:
- https://www.whatsmysite.org/

---

## 🔍 Troubleshooting

### Problema: "nginx: [emerg] bind() to 0.0.0.0:80 failed (48: Address already in use)"

Algo más está usando el puerto 80:

```bash
# Ver qué está usando el puerto 80
sudo lsof -i :80

# Si es otro nginx o Apache, detenlo
sudo apachectl stop  # Si es Apache
sudo nginx -s stop   # Si es otro nginx
```

---

### Problema: Funciona localmente pero NO desde Internet

**1. Verifica que el port forwarding esté activo:**

Algunos routers requieren reinicio después de cambiar port forwarding.

**2. Verifica tu IP pública:**

```bash
curl ifconfig.me
```

Si la IP cambió (no es 166.166.133.211), necesitas actualizar el DNS.

**3. Prueba directamente con la IP:**

```
http://166.166.133.211
```

Si funciona con IP pero no con dominio, el problema es DNS (espera propagación, puede tardar hasta 24h).

---

### Problema: nginx no inicia

```bash
# Ver logs de error
tail -f /opt/homebrew/var/log/nginx/error.log

# Ver si hay errores de configuración
sudo nginx -t
```

---

### Problema: Permisos denegados

```bash
# Arreglar permisos de archivos de configuración
sudo chmod 644 /opt/homebrew/etc/nginx/servers/*.conf

# Arreglar permisos de directorios
sudo chmod 755 /opt/homebrew/etc/nginx/servers/
```

---

## ✅ Script Automático

También puedes usar el script que creé:

```bash
cd /Users/rodrigobermudez/trackercheck
./setup-nginx-local.sh
```

Este script te guiará paso a paso.

---

## 📊 Comandos Útiles

### Ver logs de nginx:
```bash
# Error log
tail -f /opt/homebrew/var/log/nginx/error.log

# Access log
tail -f /opt/homebrew/var/log/nginx/access.log

# Logs de trackhelper específicamente
tail -f /opt/homebrew/var/log/nginx/trackhelper.access.log
tail -f /opt/homebrew/var/log/nginx/trackhelper.error.log
```

### Controlar nginx:
```bash
# Iniciar
sudo nginx

# Detener
sudo nginx -s stop

# Reiniciar (reload de configuración sin downtime)
sudo nginx -s reload

# Verificar configuración
sudo nginx -t

# Ver procesos
ps aux | grep nginx
```

### Verificar conexiones:
```bash
# Ver qué está escuchando en puerto 80
lsof -i :80

# Ver conexiones activas
netstat -an | grep 80 | grep ESTABLISHED
```

---

## 🔒 SIGUIENTE PASO: HTTPS (SSL)

Una vez que funcione con HTTP, podemos configurar HTTPS:

```bash
# Instalar certbot
brew install certbot

# Obtener certificado SSL (GRATIS)
sudo certbot certonly --standalone -d trackhelper.fromcolombiawithcoffees.com

# Actualizar configuración de nginx para usar SSL
# (Te ayudaré con esto cuando llegues aquí)
```

---

## 📞 Ayuda Rápida

**¿Funciona localmente?**
```bash
curl http://localhost
```

**¿Docker está corriendo?**
```bash
docker-compose ps
```

**¿Nginx está corriendo?**
```bash
sudo nginx -t && ps aux | grep nginx
```

**¿Port forwarding configurado?**
- Intenta acceder desde tu celular (usando datos móviles, NO WiFi)

---

💡 **TIP**: Asegúrate de que tu Mac no se duerma si quieres que esté accesible 24/7:
```
 → Configuración → Batería → Opciones → Evitar que el Mac entre en reposo...
```
