# Inicio Rápido - Solución de Problemas de Acceso

## Problema: No puedo acceder a la aplicación

### Paso 1: Verificar que Docker está corriendo

```bash
docker ps
```

Si ves un error como "Cannot connect to Docker daemon", necesitas:
- **En Mac**: Abrir Docker Desktop desde Aplicaciones
- **En Linux**: `sudo systemctl start docker`

### Paso 2: Construir e iniciar los contenedores

```bash
# Asegúrate de estar en el directorio del proyecto
cd /Users/rodrigobermudez/trackercheck

# Construir e iniciar
docker-compose up -d --build
```

### Paso 3: Verificar que los contenedores están corriendo

```bash
docker-compose ps
```

Deberías ver algo como:
```
NAME                    STATUS
trackercheck-app        Up
trackercheck-nginx       Up
```

### Paso 4: Verificar que los puertos están abiertos

```bash
# Probar localmente
curl http://localhost:3031
curl http://localhost:3030
```

### Paso 5: Ver logs si hay errores

```bash
# Ver logs de la aplicación
docker-compose logs trackercheck

# Ver logs de nginx
docker-compose logs nginx

# Ver todos los logs en tiempo real
docker-compose logs -f
```

### Paso 6: Configurar nginx en el servidor

Si estás en el servidor y quieres acceder desde el dominio:

1. **Encuentra la configuración de nginx:**
```bash
sudo grep -r "trackhelper" /etc/nginx/
```

2. **Edita el archivo encontrado** y cambia el `proxy_pass` a:
```nginx
location / {
    proxy_pass http://localhost:3031;
    # ... resto de la configuración
}

location /api/ {
    proxy_pass http://localhost:3030;
    # ... resto de la configuración
}
```

3. **Recarga nginx:**
```bash
sudo nginx -t  # Verificar sintaxis
sudo systemctl reload nginx
```

## Solución Rápida Completa

Ejecuta este script de diagnóstico:
```bash
./diagnostico.sh
```

O manualmente:

```bash
# 1. Iniciar contenedores
docker-compose up -d --build

# 2. Verificar estado
docker-compose ps

# 3. Ver logs
docker-compose logs -f

# 4. Probar localmente
curl http://localhost:3031
```

## Problemas Comunes

### Error: "port is already allocated"
Algún proceso está usando los puertos 3030 o 3031. Solución:
```bash
# Ver qué está usando el puerto
lsof -i :3031
# O cambiar los puertos en docker-compose.yml
```

### Error: "Cannot connect to Docker daemon"
Docker no está corriendo. Inicia Docker Desktop (Mac) o el servicio docker (Linux).

### La app carga pero muestra errores
Revisa los logs:
```bash
docker-compose logs trackercheck
```

### El dominio no carga pero localhost sí
El problema es la configuración de nginx en el servidor. Sigue el Paso 6 arriba.
