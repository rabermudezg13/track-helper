# ⚡ Comandos Rápidos - TrackerCheck

## 🚀 Despliegue en el Servidor

Copia y pega estos comandos en tu servidor:

```bash
# ===== PASO 1: Crear red Docker =====
docker network create nginx_default 2>/dev/null || echo "Red ya existe"

# ===== PASO 2: Detener versiones anteriores =====
cd /ruta/a/trackercheck
docker-compose down

# ===== PASO 3: Construir y levantar =====
docker-compose up -d --build

# ===== PASO 4: Ver logs =====
docker-compose logs -f

# (Ctrl+C para salir de los logs)

# ===== PASO 5: Verificar estado =====
docker-compose ps
curl http://localhost:3031

# ===== PASO 6: Configurar Nginx =====
sudo cp nginx/trackerhelper.conf /etc/nginx/sites-available/trackhelper.conf
sudo ln -sf /etc/nginx/sites-available/trackhelper.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# ===== PASO 7: Probar =====
curl http://trackhelper.fromcolombiawithcoffees.com
```

## 🔒 Configurar SSL (Opcional pero Recomendado)

```bash
# Instalar certbot
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx

# Obtener certificado SSL GRATIS
sudo certbot --nginx -d trackhelper.fromcolombiawithcoffees.com

# Certbot configurará todo automáticamente
# Solo sigue las instrucciones en pantalla
```

## 🧪 Testing Local (En tu Mac)

```bash
# Probar sin Docker
npm install
node server.js

# Abrir en navegador: http://localhost:3031
```

## 🔧 Comandos Útiles

```bash
# Ver logs en tiempo real
docker-compose logs -f

# Ver solo últimas 50 líneas
docker-compose logs --tail=50

# Reiniciar contenedores
docker-compose restart

# Detener todo
docker-compose down

# Detener y eliminar volúmenes
docker-compose down -v

# Ver estado de contenedores
docker-compose ps

# Ver uso de recursos
docker stats trackercheck-app

# Entrar al contenedor (debug)
docker exec -it trackercheck-app sh

# Reconstruir después de cambios
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## 🐛 Solución de Problemas

```bash
# Si el puerto está ocupado
lsof -i :3030
lsof -i :3031
# Matar el proceso con: kill -9 PID

# Si docker-compose no funciona
docker-compose down
docker system prune -f
docker-compose up -d --build

# Si nginx da error
sudo nginx -t
sudo tail -f /var/log/nginx/error.log

# Reiniciar nginx
sudo systemctl restart nginx

# Ver qué está escuchando en los puertos
sudo netstat -tulpn | grep -E '3030|3031|80|443'
```

## 📊 Verificación Rápida

```bash
# ¿Contenedor corriendo?
docker ps | grep trackercheck

# ¿Backend responde?
curl http://localhost:3030/api/process
# Debería dar error 400 (normal, necesita archivo)

# ¿Frontend responde?
curl http://localhost:3031 | head -20

# ¿Dominio funciona?
curl http://trackhelper.fromcolombiawithcoffees.com

# ¿HTTPS funciona? (después de SSL)
curl https://trackhelper.fromcolombiawithcoffees.com
```

## 🔄 Actualizar la Aplicación

```bash
# Si haces cambios en el código:
cd /ruta/a/trackercheck

# Opción 1: Reconstruir todo
docker-compose down
docker-compose build
docker-compose up -d

# Opción 2: Solo reiniciar
docker-compose restart

# Ver logs para verificar
docker-compose logs -f
```

## 🗑️ Limpiar Docker

```bash
# Limpiar contenedores detenidos
docker container prune -f

# Limpiar imágenes no usadas
docker image prune -f

# Limpiar todo (cuidado!)
docker system prune -af --volumes
```

## 📁 Backup y Restore

```bash
# Backup de uploads
tar -czf backup-uploads-$(date +%Y%m%d).tar.gz uploads/

# Backup de configuración
tar -czf backup-config-$(date +%Y%m%d).tar.gz \
  nginx/ .env docker-compose.yml server.js public/

# Restore
tar -xzf backup-uploads-20240119.tar.gz
tar -xzf backup-config-20240119.tar.gz
```

## 🌐 URLs de Acceso

### Producción:
- Frontend: http://trackhelper.fromcolombiawithcoffees.com
- Frontend HTTPS: https://trackhelper.fromcolombiawithcoffees.com

### Local:
- Frontend: http://localhost:3031
- API: http://localhost:3030/api/process

---

💡 **Tip**: Guarda este archivo para referencia rápida!
