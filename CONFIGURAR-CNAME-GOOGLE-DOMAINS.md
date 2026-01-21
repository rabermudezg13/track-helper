# 🚀 Configurar CNAME en Google Domains

## 📋 PASOS EXACTOS

### PASO 1: Ir a Google Domains

https://domains.google.com/

### PASO 2: Seleccionar tu dominio

Click en: **fromcolombiawithcoffees.com**

### PASO 3: Ir a DNS

Menú lateral → **DNS**

### PASO 4: Scroll hasta "Custom resource records"

Busca la sección que dice "Custom resource records" o "Registros de recursos personalizados"

---

## 📝 REGISTROS A AGREGAR

Para **CADA subdominio**, agrega un registro CNAME:

### 1. TrackerCheck

```
Name: trackhelper
Type: CNAME
TTL: 1H (o 3600)
Data: 3ddca40e-bf23-478d-af5b-ef489a997ad5.cfargotunnel.com
```

### 2. Kelly App

```
Name: kellyapp
Type: CNAME
TTL: 1H
Data: 3ddca40e-bf23-478d-af5b-ef489a997ad5.cfargotunnel.com
```

### 3. Wimi

```
Name: wimi
Type: CNAME
TTL: 1H
Data: 3ddca40e-bf23-478d-af5b-ef489a997ad5.cfargotunnel.com
```

### 4. ROWG

```
Name: rowg
Type: CNAME
TTL: 1H
Data: 3ddca40e-bf23-478d-af5b-ef489a997ad5.cfargotunnel.com
```

### 5. Cupping

```
Name: cupping
Type: CNAME
TTL: 1H
Data: 3ddca40e-bf23-478d-af5b-ef489a997ad5.cfargotunnel.com
```

### 6. Automations

```
Name: automations
Type: CNAME
TTL: 1H
Data: 3ddca40e-bf23-478d-af5b-ef489a997ad5.cfargotunnel.com
```

---

## ⚠️ IMPORTANTE: Eliminar Registros A Antiguos

Si ves registros tipo **A** para estos subdominios apuntando a `166.166.133.211`, **ELIMÍNALOS**.

Google Domains no permite tener tanto A como CNAME para el mismo nombre.

---

## 💾 VALOR PARA COPY-PASTE

Para todos los subdominios, el **Data/Target** es el mismo:

```
3ddca40e-bf23-478d-af5b-ef489a997ad5.cfargotunnel.com
```

---

## 📸 EJEMPLO VISUAL

Así debería verse cada registro:

```
┌──────────────┬──────────┬─────┬────────────────────────────────────────────────┐
│ Name         │ Type     │ TTL │ Data                                           │
├──────────────┼──────────┼─────┼────────────────────────────────────────────────┤
│ trackhelper  │ CNAME    │ 1H  │ 3ddca40e-bf23-478d-af5b-ef489a997ad5.cfargo... │
│ kellyapp     │ CNAME    │ 1H  │ 3ddca40e-bf23-478d-af5b-ef489a997ad5.cfargo... │
│ wimi         │ CNAME    │ 1H  │ 3ddca40e-bf23-478d-af5b-ef489a997ad5.cfargo... │
│ rowg         │ CNAME    │ 1H  │ 3ddca40e-bf23-478d-af5b-ef489a997ad5.cfargo... │
│ cupping      │ CNAME    │ 1H  │ 3ddca40e-bf23-478d-af5b-ef489a997ad5.cfargo... │
│ automations  │ CNAME    │ 1H  │ 3ddca40e-bf23-478d-af5b-ef489a997ad5.cfargo... │
└──────────────┴──────────┴─────┴────────────────────────────────────────────────┘
```

---

## ⏰ TIEMPO DE PROPAGACIÓN

- **Google Domains**: 5-10 minutos (rápido)
- **Tu computadora**: 1-5 minutos (caché DNS)
- **Global**: 10-30 minutos

---

## 🧪 PROBAR DESPUÉS DE CONFIGURAR

### Limpiar caché DNS local

```bash
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

### Esperar un poco

```bash
# Esperar 5 minutos
echo "Esperando propagación DNS (5 minutos)..."
sleep 300
```

### Verificar DNS

```bash
# Ver si ya apunta al túnel
dig trackhelper.fromcolombiawithcoffees.com

# Debería mostrar CNAME apuntando a:
# trackhelper.fromcolombiawithcoffees.com. 3600 IN CNAME 3ddca40e-bf23-478d-af5b-ef489a997ad5.cfargotunnel.com.
```

### Probar acceso

```bash
curl -I https://trackhelper.fromcolombiawithcoffees.com
curl -I https://kellyapp.fromcolombiawithcoffees.com
curl -I https://wimi.fromcolombiawithcoffees.com
```

### Abrir en navegador

```bash
open https://trackhelper.fromcolombiawithcoffees.com
open https://kellyapp.fromcolombiawithcoffees.com
open https://wimi.fromcolombiawithcoffees.com
```

---

## 🆘 TROUBLESHOOTING

### "Cannot add CNAME, A record exists"

**Solución**: Elimina el registro A primero, luego agrega el CNAME.

### "DNS still points to old IP"

**Solución**:
1. Limpiar caché DNS (comandos arriba)
2. Esperar 10 minutos más
3. Verificar que el CNAME esté bien escrito (sin punto final)

### "Tunnel not responding"

**Verificar túnel**:
```bash
# Ver estado
cloudflared tunnel list

# Ver logs
tail -f /tmp/cloudflared.log

# Si no hay conexiones, reiniciar:
ps aux | grep cloudflared | grep -v grep | awk '{print $2}' | xargs kill
cloudflared tunnel run fromcolombia &
```

---

## 📋 CHECKLIST

- [ ] Ir a https://domains.google.com/
- [ ] Seleccionar: fromcolombiawithcoffees.com
- [ ] Ir a: DNS
- [ ] Buscar: Custom resource records
- [ ] Para cada subdominio:
  - [ ] Eliminar registro A si existe
  - [ ] Agregar CNAME con target: `3ddca40e-bf23-478d-af5b-ef489a997ad5.cfargotunnel.com`
- [ ] Save/Guardar
- [ ] Esperar 5-10 minutos
- [ ] Limpiar caché DNS
- [ ] Probar dominios

---

## 🎯 RESUMEN

**Target para TODOS los subdominios**:
```
3ddca40e-bf23-478d-af5b-ef489a997ad5.cfargotunnel.com
```

**Subdominios a configurar**:
1. trackhelper
2. kellyapp
3. wimi
4. rowg
5. cupping
6. automations

**Después**: Esperar 5-10 minutos y probar.

---

## ✅ CUANDO ESTÉ LISTO

Avísame cuando hayas agregado los CNAME en Google Domains y esperaremos juntos a que se propague el DNS.

Luego probaremos todos los dominios y si funcionan, instalaremos el túnel como servicio para que se inicie automáticamente.

🚀 ¡Casi terminamos!
