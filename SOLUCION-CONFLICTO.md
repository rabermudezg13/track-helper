# Solución: El dominio trackhelper apunta a otra app

Si al acceder a `trackhelper.fromcolombiawithcoffees.com` entras a otra aplicación, significa que tu nginx principal ya tiene una configuración para ese dominio apuntando a otra app.

## Solución Rápida

Tienes dos opciones:

### Opción 1: Modificar tu nginx principal (Recomendado)

1. **Encuentra la configuración actual:**
```bash
# Buscar dónde está configurado trackhelper
sudo grep -r "trackhelper" /etc/nginx/
```

2. **Edita el archivo de configuración** (probablemente en `/etc/nginx/sites-available/` o `/etc/nginx/conf.d/`)

3. **Reemplaza la configuración** con esta:

```nginx
server {
    listen 80;
    server_name trackhelper.fromcolombiawithcoffees.com;

    location / {
        proxy_pass http://localhost:3031;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        proxy_connect_timeout 300;
        proxy_send_timeout 300;
        proxy_read_timeout 300;
        send_timeout 300;
        
        client_max_body_size 100M;
    }

    location /api/ {
        proxy_pass http://localhost:3030;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_connect_timeout 300;
        proxy_send_timeout 300;
        proxy_read_timeout 300;
        send_timeout 300;
        
        client_max_body_size 100M;
    }
}
```

4. **Verifica la configuración:**
```bash
sudo nginx -t
```

5. **Recarga nginx:**
```bash
sudo systemctl reload nginx
# o
sudo service nginx reload
```

6. **Asegúrate de que la app Docker esté corriendo:**
```bash
cd /ruta/a/trackercheck
docker-compose up -d
```

### Opción 2: Usar un subdominio diferente

Si no puedes modificar la configuración de trackhelper, puedes:

1. Usar otro subdominio (ej: `trackhelper-app.fromcolombiawithcoffees.com`)
2. O usar un puerto diferente (ej: `trackhelper.fromcolombiawithcoffees.com:8080`)

## Verificar que funciona

1. **Verifica que los contenedores estén corriendo:**
```bash
docker-compose ps
```

2. **Verifica que los puertos estén abiertos:**
```bash
curl http://localhost:3031
curl http://localhost:3030/api/process
```

3. **Prueba el dominio:**
```bash
curl http://trackhelper.fromcolombiawithcoffees.com
```

## Diagnóstico

Ejecuta este script para ver qué está pasando:
```bash
bash nginx/check-nginx-config.sh
```

O manualmente:
```bash
# Ver qué app está respondiendo
curl -I http://trackhelper.fromcolombiawithcoffees.com

# Ver configuración de nginx
sudo nginx -T | grep -A 20 "trackhelper"

# Ver procesos en los puertos
sudo lsof -i :80
sudo lsof -i :3031
```
