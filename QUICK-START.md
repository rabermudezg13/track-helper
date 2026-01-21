# 🚀 Inicio Rápido - TrackerCheck

## Para acceder desde trackhelper.fromcolombiawithcoffees.com

### Paso 1: Preparar el Servidor

```bash
# Conectarse al servidor
ssh usuario@tu-servidor

# Navegar al directorio del proyecto
cd /ruta/donde/esta/trackercheck
```

### Paso 2: Crear la Red Docker (si no existe)

```bash
# Crear red compartida para nginx
docker network create nginx_default 2>/dev/null || echo "La red ya existe"

# Si tienes nginx en Docker, conectarlo a la red
# docker network connect nginx_default nombre-contenedor-nginx
```

### Paso 3: Levantar la Aplicación

```bash
# Detener contenedores anteriores si existen
docker-compose down

# Construir y levantar
docker-compose up -d --build

# Ver logs para verificar
docker-compose logs -f
```

Deberías ver:
```
✅ Backend API corriendo en http://0.0.0.0:3030
📊 Endpoint: http://0.0.0.0:3030/api/process
✅ Frontend servidor corriendo en http://0.0.0.0:3031
```

### Paso 4: Configurar Nginx

#### Si Nginx está en el HOST (no en Docker):

```bash
# Copiar la configuración
sudo cp nginx/trackerhelper.conf /etc/nginx/sites-available/trackhelper.conf

# Crear enlace simbólico
sudo ln -sf /etc/nginx/sites-available/trackhelper.conf /etc/nginx/sites-enabled/

# Verificar sintaxis
sudo nginx -t

# Recargar nginx
sudo systemctl reload nginx
```

#### Si Nginx está en Docker:

Asegúrate de que tu contenedor de nginx:
1. Esté conectado a la red `nginx_default`
2. Tenga montado el archivo de configuración
3. Pueda resolver el nombre `trackercheck-app`

```bash
# Conectar nginx a la misma red
docker network connect nginx_default tu-nginx-container

# Recargar configuración de nginx
docker exec tu-nginx-container nginx -s reload
```

### Paso 5: Verificar

```bash
# Verificar que los contenedores estén corriendo
docker ps | grep trackercheck

# Debería mostrar:
# trackercheck-app   ->  0.0.0.0:3030->3030/tcp, 0.0.0.0:3031->3031/tcp

# Probar el backend directamente
curl http://localhost:3030/api/process
# Debería responder con error 400 (normal, necesita archivo)

# Probar el frontend
curl http://localhost:3031
# Debería devolver HTML
```

### Paso 6: Acceder desde el Navegador

Abre tu navegador y ve a:
```
http://trackhelper.fromcolombiawithcoffees.com
```

Deberías ver la interfaz de TrackerCheck con el mensaje "Good Morning Anthony!"

## 🔧 Solución Rápida de Problemas

### Error: "Cannot connect to the Docker daemon"
```bash
sudo systemctl start docker
```

### Error: "port is already allocated"
```bash
# Ver qué está usando el puerto
sudo netstat -tulpn | grep -E '3030|3031'

# Detener el servicio que lo usa o cambiar el puerto en docker-compose.yml
```

### Error 502 Bad Gateway
```bash
# Verificar logs del contenedor
docker-compose logs trackercheck

# Verificar que nginx pueda resolver el nombre
docker exec nombre-nginx ping trackercheck-app

# Reiniciar todo
docker-compose restart
sudo systemctl reload nginx
```

### El dominio no carga
```bash
# Verificar DNS
nslookup trackhelper.fromcolombiawithcoffees.com

# Verificar configuración de nginx
sudo nginx -t

# Ver logs de nginx
sudo tail -f /var/log/nginx/error.log
```

## 📝 Comandos Útiles

```bash
# Ver logs en tiempo real
docker-compose logs -f

# Reiniciar la aplicación
docker-compose restart

# Reconstruir después de cambios en el código
docker-compose down
docker-compose up -d --build

# Ver estado de los contenedores
docker-compose ps

# Entrar al contenedor
docker exec -it trackercheck-app sh

# Ver uso de recursos
docker stats trackercheck-app
```

## 🔒 Siguiente Paso: SSL/HTTPS (Recomendado)

```bash
# Instalar certbot
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx

# Obtener certificado SSL gratis
sudo certbot --nginx -d trackhelper.fromcolombiawithcoffees.com

# Certbot configurará automáticamente HTTPS
```

---

**¿Necesitas más ayuda?** Consulta DEPLOYMENT.md para información detallada.
