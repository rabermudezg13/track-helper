# 🔧 Configurar DNS en Squarespace para Cloudflare Tunnel

## 📊 SITUACIÓN

Tu dominio `fromcolombiawithcoffees.com` está registrado en **Squarespace**, pero los **nameservers apuntan a Cloudflare**.

Cloudflare creó los registros CNAME, pero como el dominio viene de Squarespace, necesitamos asegurarnos de que TODO el DNS esté manejado por Cloudflare.

---

## ✅ SOLUCIÓN: Verificar Configuración

### OPCIÓN 1: DNS Manejado por Cloudflare (RECOMENDADO) ⭐

Si los nameservers ya apuntan a Cloudflare, no necesitas hacer nada en Squarespace.

**Verificar**:

```bash
# Ver nameservers actuales
dig NS fromcolombiawithcoffees.com +short
```

**Deberías ver algo como**:
```
aaa.ns.cloudflare.com.
bbb.ns.cloudflare.com.
```

Si ves eso, **TODO el DNS está en Cloudflare** y no necesitas tocar Squarespace.

---

### OPCIÓN 2: DNS Mixto (Squarespace + Cloudflare)

Si los nameservers AÚN apuntan a Squarespace (algo como `ns1.squarespace.com`), entonces necesitas:

#### Opción A: Transferir DNS completamente a Cloudflare (Recomendado)

1. **En Squarespace**:
   - Ve a: Settings → Domains → Advanced DNS Settings
   - Cambia los nameservers a los de Cloudflare:
     ```
     aaa.ns.cloudflare.com
     bbb.ns.cloudflare.com
     ```
   - (Cloudflare te dio estos nameservers cuando agregaste el dominio)

2. **Espera**: 1-24 horas (usualmente 1-2 horas)

3. **Verifica**:
   ```bash
   dig NS fromcolombiawithcoffees.com +short
   ```

#### Opción B: Agregar CNAME en Squarespace manualmente

Si prefieres mantener el DNS en Squarespace:

1. **En Squarespace**:
   - Ve a: Settings → Domains → DNS Settings

2. **Para cada subdominio**, agregar registro CNAME:

   ```
   Type: CNAME
   Host: trackhelper
   Data: 3ddca40e-bf23-478d-af5b-ef489a997ad5.cfargotunnel.com
   ```

   Repetir para:
   - `trackhelper`
   - `kellyapp`
   - `wimi`
   - `rowg`
   - `cupping`
   - `automations`

3. **Eliminar** registros A antiguos si existen

---

## 🎯 RECOMENDACIÓN

### Mejor opción: DNS en Cloudflare

**Por qué**:
- ✅ Más rápido (DNS de Cloudflare es el más rápido del mundo)
- ✅ Configuración automática con cloudflared
- ✅ Dashboard unificado (todo en un lugar)
- ✅ Features adicionales gratis (DDoS, analytics, etc.)
- ✅ No necesitas tocar Squarespace cada vez que agregues una app

**Cómo verificar si ya está así**:

```bash
dig NS fromcolombiawithcoffees.com +short
```

Si ves nameservers de Cloudflare (`*.ns.cloudflare.com`), **ya está configurado correctamente** y solo necesitas esperar a que el DNS se propague (10-30 minutos).

---

## 🕐 TIEMPOS DE PROPAGACIÓN

### Si el DNS ya está en Cloudflare:
- **Cloudflare**: 10-30 segundos (muy rápido)
- **Tu computadora**: 1-5 minutos (caché DNS local)
- **Global**: 5-15 minutos

### Si cambias nameservers ahora:
- **Propagación**: 1-24 horas (usualmente 1-2 horas)

---

## 🧪 PROBAR MIENTRAS ESPERAS

Puedes forzar a tu Mac a usar los DNS de Cloudflare directamente:

```bash
# Limpiar caché DNS
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

# Probar con DNS de Cloudflare
dig @1.1.1.1 trackhelper.fromcolombiawithcoffees.com

# Probar con curl
curl -I --resolve trackhelper.fromcolombiawithcoffees.com:443:$(dig +short 3ddca40e-bf23-478d-af5b-ef489a997ad5.cfargotunnel.com | head -1) https://trackhelper.fromcolombiawithcoffees.com
```

---

## 📋 CHECKLIST

**Verificar configuración actual**:

```bash
# 1. Ver nameservers
dig NS fromcolombiawithcoffees.com +short

# 2. Ver registros actuales
dig trackhelper.fromcolombiawithcoffees.com +short
dig kellyapp.fromcolombiawithcoffees.com +short
```

**Escenarios**:

### ✅ Escenario A: Nameservers en Cloudflare

```bash
$ dig NS fromcolombiawithcoffees.com +short
aaa.ns.cloudflare.com.
bbb.ns.cloudflare.com.
```

**Acción**: Solo esperar propagación (10-30 minutos)

---

### ⚠️ Escenario B: Nameservers en Squarespace

```bash
$ dig NS fromcolombiawithcoffees.com +short
ns1.squarespace.com.
ns2.squarespace.com.
```

**Acción**:
- Opción 1: Cambiar nameservers a Cloudflare (en Squarespace)
- Opción 2: Agregar CNAMEs en Squarespace manualmente

---

## 🔍 DIAGNÓSTICO ACTUAL

Ejecuta esto y muéstrame el resultado:

```bash
echo "=== NAMESERVERS ==="
dig NS fromcolombiawithcoffees.com +short
echo ""
echo "=== DNS ACTUAL ==="
dig trackhelper.fromcolombiawithcoffees.com +short
dig kellyapp.fromcolombiawithcoffees.com +short
echo ""
echo "=== TUNNEL STATUS ==="
cloudflared tunnel list
```

Con esa información te diré exactamente qué hacer.

---

## 💡 SOLUCIÓN TEMPORAL: Editar /etc/hosts

Mientras esperas la propagación, puedes probar localmente:

```bash
# Obtener IP del túnel
TUNNEL_IP=$(dig +short 3ddca40e-bf23-478d-af5b-ef489a997ad5.cfargotunnel.com | head -1)

# Agregar a hosts (temporal)
sudo bash -c "cat >> /etc/hosts << EOF

# Cloudflare Tunnel - Temporal para testing
$TUNNEL_IP trackhelper.fromcolombiawithcoffees.com
$TUNNEL_IP kellyapp.fromcolombiawithcoffees.com
$TUNNEL_IP wimi.fromcolombiawithcoffees.com
$TUNNEL_IP rowg.fromcolombiawithcoffees.com
$TUNNEL_IP cupping.fromcolombiawithcoffees.com
$TUNNEL_IP automations.fromcolombiawithcoffees.com
EOF"

# Probar
curl -I https://trackhelper.fromcolombiawithcoffees.com
```

Esto funciona solo en tu Mac, no para otros usuarios.

Para revertir:
```bash
sudo nano /etc/hosts
# Elimina las líneas que agregaste
```

---

## 🎯 SIGUIENTE PASO

Dime:

1. **¿Qué ves cuando ejecutas**:
   ```bash
   dig NS fromcolombiawithcoffees.com +short
   ```

2. **¿Prefieres**:
   - A) Dejar que el DNS se propague (esperar 10-30 min)
   - B) Probar localmente con /etc/hosts ahora
   - C) Cambiar algo en Squarespace

Con esa info te ayudo a completar la configuración. 🚀
