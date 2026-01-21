# 🚀 Guía de Despliegue - TrackerCheck

## Acceso al Dominio
La aplicación estará disponible en: **trackhelper.fromcolombiawithcoffees.com**

## Requisitos Previos

- Docker y Docker Compose instalados
- Nginx configurado en el servidor
- Dominio apuntando al servidor
- Puertos 3030 y 3031 disponibles

## Pasos de Despliegue

### 1. Configurar DNS
Asegúrate de que el dominio `trackhelper.fromcolombiawithcoffees.com` apunte a la IP de tu servidor.

```bash
# Verificar DNS
nslookup trackhelper.fromcolombiawithcoffees.com
```

### 2. Clonar o Actualizar el Repositorio

```bash
cd /ruta/a/tu/servidor
git clone <tu-repositorio> trackercheck
cd trackercheck
```

### 3. Configurar Variables de Entorno (Opcional)

```bash
cp .env.example .env
# Editar .env si necesitas cambiar configuraciones
nano .env
```

### 4. Asegurar que Nginx tenga la Red Docker

```bash
# Crear la red compartida si no existe
docker network create nginx_default 2>/dev/null || true

# Conectar tu contenedor de nginx a esta red (si usas nginx en Docker)
docker network connect nginx_default nginx_container_name
```

### 5. Construir y Levantar los Contenedores

```bash
# Detener contenedores antiguos si existen
docker-compose down

# Construir la imagen
docker-compose build

# Levantar los servicios
docker-compose up -d

# Verificar que estén corriendo
docker-compose ps
docker-compose logs -f
```

### 6. Configurar Nginx en el Servidor

El archivo de configuración ya está en `nginx/trackerhelper.conf`. Debes copiarlo o crear un enlace simbólico:

#### Opción A: Si Nginx está en el host (no en Docker)

```bash
# Copiar configuración
sudo cp nginx/trackerhelper.conf /etc/nginx/sites-available/trackhelper.conf

# Crear enlace simbólico
sudo ln -s /etc/nginx/sites-available/trackhelper.conf /etc/nginx/sites-enabled/

# Verificar configuración
sudo nginx -t

# Recargar nginx
sudo systemctl reload nginx
```

#### Opción B: Si Nginx está en Docker

```bash
# La configuración ya está en el docker-compose comentada
# Descomenta la sección de nginx en docker-compose.yml
```

### 7. Verificar el Despliegue

```bash
# Verificar que los contenedores estén corriendo
docker ps | grep trackercheck

# Verificar logs
docker-compose logs -f trackercheck

# Probar el backend
curl http://localhost:3030/api/process

# Probar el frontend
curl http://localhost:3031
```

### 8. Probar desde el Navegador

Abre en tu navegador:
- **Frontend**: http://trackhelper.fromcolombiawithcoffees.com
- **API**: http://trackhelper.fromcolombiawithcoffees.com/api/process

## 🔒 Configuración SSL/HTTPS (Recomendado)

### Usando Certbot (Let's Encrypt)

```bash
# Instalar certbot
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx

# Obtener certificado
sudo certbot --nginx -d trackhelper.fromcolombiawithcoffees.com

# Certbot configurará automáticamente nginx con SSL
```

### Configuración Manual SSL

Si ya tienes certificados:

```bash
# Copiar certificados a la carpeta ssl
cp tu_certificado.crt nginx/ssl/cert.pem
cp tu_llave.key nginx/ssl/key.pem

# Editar nginx/trackerhelper.conf y descomentar la sección HTTPS
# Recargar nginx
sudo nginx -t
sudo systemctl reload nginx
```

## 🔄 Actualizar la Aplicación

```bash
cd /ruta/a/trackercheck

# Detener contenedores
docker-compose down

# Actualizar código
git pull

# Reconstruir y levantar
docker-compose build
docker-compose up -d

# Verificar logs
docker-compose logs -f
```

## 🐛 Solución de Problemas

### Los contenedores no inician

```bash
# Ver logs detallados
docker-compose logs trackercheck

# Verificar puertos en uso
sudo netstat -tulpn | grep -E '3030|3031'

# Reiniciar contenedores
docker-compose restart
```

### Error de red Docker

```bash
# Recrear la red
docker network rm nginx_default
docker network create nginx_default

# Reconectar contenedores
docker-compose down
docker-compose up -d
```

### Nginx no puede conectar al contenedor

```bash
# Verificar que estén en la misma red
docker network inspect nginx_default

# Verificar que el nombre del contenedor sea correcto
docker ps --format "table {{.Names}}\t{{.Status}}"

# Probar conexión desde el host
curl http://localhost:3030/api/process
curl http://localhost:3031
```

### Error 502 Bad Gateway

```bash
# Verificar que los contenedores estén corriendo
docker-compose ps

# Verificar logs del backend
docker-compose logs trackercheck

# Verificar configuración de nginx
sudo nginx -t

# Verificar que nginx pueda resolver el nombre del contenedor
docker exec -it nginx_container ping trackercheck-app
```

## 📊 Monitoreo

### Ver logs en tiempo real

```bash
# Logs de todos los servicios
docker-compose logs -f

# Logs solo del backend
docker-compose logs -f trackercheck

# Ver últimas 100 líneas
docker-compose logs --tail=100 trackercheck
```

### Verificar uso de recursos

```bash
# Ver uso de CPU y memoria
docker stats trackercheck-app
```

## 🔧 Mantenimiento

### Limpiar archivos subidos antiguos

```bash
# Eliminar archivos de más de 7 días
find ./uploads -name "*.xlsx" -mtime +7 -delete
find ./uploads -name "*.xls" -mtime +7 -delete
```

### Backup de datos

```bash
# Backup de uploads
tar -czf backup-uploads-$(date +%Y%m%d).tar.gz uploads/

# Backup de configuración
tar -czf backup-config-$(date +%Y%m%d).tar.gz nginx/ .env docker-compose.yml
```

## 📝 Notas Importantes

1. **Puertos**: La aplicación usa los puertos 3030 (API) y 3031 (Frontend)
2. **Red Docker**: Asegúrate de que nginx y la aplicación estén en la misma red Docker
3. **CORS**: Configurado para aceptar todas las peticiones. Ajusta en producción si es necesario
4. **Uploads**: Los archivos subidos se almacenan en `./uploads` y persisten entre reinicios
5. **SSL**: Altamente recomendado para producción

## 🆘 Soporte

Si encuentras problemas:

1. Revisa los logs: `docker-compose logs -f`
2. Verifica la configuración de nginx: `sudo nginx -t`
3. Comprueba que los puertos estén disponibles: `netstat -tulpn | grep -E '3030|3031'`
4. Verifica la conectividad de red: `docker network inspect nginx_default`

## 📧 Contacto

Para soporte adicional, contacta al equipo de desarrollo.

---

**TrackerCheck v1.0** | Made with ❤️ for efficient recruitment tracking
