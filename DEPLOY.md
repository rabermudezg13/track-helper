# Guía de Despliegue - TrackerCheck

## Configuración de Docker y Nginx

Esta aplicación está configurada para ejecutarse en Docker con Nginx como proxy reverso, accesible a través del dominio `trackhelper.fromcolombiawithcoffees.com`.

## Características de la Configuración

- ✅ **Aislada**: La configuración de nginx está en un archivo específico que NO afecta otras aplicaciones
- ✅ **Dockerizada**: Toda la aplicación corre en contenedores Docker
- ✅ **Proxy Reverso**: Nginx actúa como proxy para el frontend (puerto 3031) y API (puerto 3030)

## Estructura de Archivos

```
trackercheck/
├── Dockerfile              # Imagen de la aplicación Node.js
├── docker-compose.yml      # Orquestación de servicios
├── nginx/
│   ├── trackerhelper.conf  # Configuración específica de nginx (NO afecta otras apps)
│   └── ssl/                # Directorio para certificados SSL (opcional)
└── ...
```

## Instrucciones de Despliegue

### 1. Preparar el Servidor

Asegúrate de tener Docker y Docker Compose instalados:

```bash
docker --version
docker-compose --version
```

### 2. Configurar el Dominio

Asegúrate de que el DNS apunte `trackhelper.fromcolombiawithcoffees.com` a la IP de tu servidor.

### 3. Elegir Método de Despliegue

Tienes **dos opciones** dependiendo de si ya tienes nginx corriendo en tu servidor:

#### Opción A: Si NO tienes nginx en el servidor (o quieres usar el del contenedor)

```bash
# Usar la versión standalone
docker-compose -f docker-compose.standalone.yml up -d --build
```

Esto expondrá nginx en los puertos 80 y 443.

#### Opción B: Si YA tienes nginx en el servidor (Recomendado)

1. **Usar docker-compose.yml** (puertos 8080/8443 para evitar conflictos):
```bash
docker-compose up -d --build
```

2. **Configurar tu nginx principal** para que apunte a este servicio:
   - Copia el contenido de `nginx/nginx-main-server.conf.example`
   - Agrégalo a tu configuración de nginx principal
   - Asegúrate de que apunte a `http://localhost:3031` para el frontend
   - Y a `http://localhost:3030` para la API
   - Reinicia tu nginx: `sudo systemctl restart nginx`

### 4. Verificar que Funciona

- Accede a: `http://trackhelper.fromcolombiawithcoffees.com`
- O si tienes SSL: `https://trackhelper.fromcolombiawithcoffees.com`

## Configuración de Nginx en el Servidor Principal

**IMPORTANTE**: Esta configuración NO interfiere con otras apps porque:

1. El archivo `trackerhelper.conf` solo se monta en el contenedor de nginx de esta app
2. Si tienes un nginx principal en el servidor, este contenedor usa puertos internos (3030, 3031)
3. La configuración solo responde al dominio específico `trackhelper.fromcolombiawithcoffees.com`
4. El docker-compose.yml por defecto usa puertos 8080/8443 para evitar conflictos con nginx principal

### Si ya tienes Nginx corriendo en el servidor (Opción Recomendada):

1. Usa `docker-compose.yml` (ya configurado con puertos 8080/8443)
2. Agrega la configuración de `nginx/nginx-main-server.conf.example` a tu nginx principal
3. Tu nginx principal hará el proxy a `localhost:3031` y `localhost:3030`
4. Así mantienes todas tus apps bajo un solo nginx y no hay conflictos

## Configuración SSL (HTTPS)

Si quieres habilitar HTTPS:

1. Coloca tus certificados SSL en `nginx/ssl/`:
   - `cert.pem` (certificado)
   - `key.pem` (clave privada)

2. Descomenta la sección HTTPS en `nginx/trackerhelper.conf`

3. Reinicia los contenedores:
```bash
docker-compose restart nginx
```

## Comandos Útiles

```bash
# Ver logs
docker-compose logs -f trackercheck
docker-compose logs -f nginx

# Detener servicios
docker-compose down

# Reiniciar servicios
docker-compose restart

# Reconstruir después de cambios
docker-compose up -d --build

# Acceder al contenedor
docker exec -it trackercheck-app sh
```

## Solución de Problemas

### El dominio no carga
- Verifica que el DNS apunte correctamente
- Verifica que los puertos 80/443 estén abiertos
- Revisa los logs: `docker-compose logs nginx`

### Error 502 Bad Gateway
- Verifica que la app esté corriendo: `docker-compose ps`
- Revisa los logs de la app: `docker-compose logs trackercheck`

### No se pueden subir archivos grandes
- Aumenta `client_max_body_size` en la configuración de nginx
- Verifica que hay suficiente espacio en disco

## Notas Importantes

- Los archivos subidos se guardan en `./uploads/` (persistente gracias a volumes)
- La configuración de nginx es específica para este dominio y NO afecta otras apps
- Si necesitas cambiar puertos, modifica `docker-compose.yml` y la configuración de nginx
