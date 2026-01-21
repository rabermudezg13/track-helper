# 🚀 Guía de Despliegue en Streamlit Cloud

## Paso 1: Preparar el Repositorio

Tu repositorio ya está listo con:
- ✅ `streamlit_app.py` - Aplicación principal
- ✅ `requirements.txt` - Dependencias
- ✅ `.streamlit/config.toml` - Configuración

## Paso 2: Desplegar en Streamlit Cloud

1. **Ve a Streamlit Cloud**
   - Abre: https://share.streamlit.io
   - Haz clic en "Sign in" (usa tu cuenta de GitHub)

2. **Crear Nueva App**
   - Haz clic en "New app"
   - Selecciona:
     - **Repository**: `rabermudezg13/track-helper`
     - **Branch**: `main`
     - **Main file path**: `streamlit_app.py`

3. **Configuración Avanzada (Opcional)**
   - Python version: 3.11 o superior
   - App URL: Puedes personalizar la URL

4. **Deploy!**
   - Haz clic en "Deploy!"
   - Espera unos minutos mientras se instalan las dependencias

## Paso 3: URL de tu App

Tu aplicación estará disponible en:
```
https://track-helper-[tu-username].streamlit.app
```

## 🔄 Actualizaciones Automáticas

Cada vez que hagas `git push` al repositorio, Streamlit Cloud:
- ✅ Detectará los cambios automáticamente
- ✅ Reconstruirá la aplicación
- ✅ Desplegará la nueva versión

## 📊 Monitoreo

En el dashboard de Streamlit Cloud puedes:
- Ver logs en tiempo real
- Monitorear uso de recursos
- Ver analytics de visitantes
- Reiniciar la app si es necesario

## 🎯 Consejos

1. **Performance**: La versión gratuita tiene recursos limitados
2. **Sleeping**: Apps inactivas "duermen" después de un tiempo
3. **Límites**:
   - 1GB de RAM
   - 1 CPU
   - Ilimitado uso (con sleep)

## 🔗 Links Útiles

- **Dashboard**: https://share.streamlit.io
- **Docs**: https://docs.streamlit.io/deploy/streamlit-community-cloud
- **Tu Repo**: https://github.com/rabermudezg13/track-helper

---

¡Listo para desplegar! 🎉
