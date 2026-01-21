import streamlit as st
import pandas as pd
from datetime import datetime, timedelta
import openpyxl
from io import BytesIO

st.set_page_config(
    page_title="TrackerCheck",
    page_icon="📊",
    layout="wide"
)

def parse_excel_date(value):
    """Convierte fechas de Excel a datetime de Python"""
    if pd.isna(value) or value == '':
        return None

    if isinstance(value, datetime):
        return value

    if isinstance(value, (int, float)):
        try:
            excel_epoch = datetime(1899, 12, 30)
            return excel_epoch + timedelta(days=float(value))
        except:
            return None

    if isinstance(value, str):
        try:
            return pd.to_datetime(value)
        except:
            return None

    return None

def process_excel(file):
    """Procesa el archivo Excel y extrae los datos"""
    try:
        # Leer el archivo Excel
        wb = openpyxl.load_workbook(file, data_only=True)
        ws = wb.active

        aspirantes = []

        # Iterar sobre las filas (empezando desde la fila 2 para saltar encabezados)
        for row_idx, row in enumerate(ws.iter_rows(min_row=2, values_only=True), start=2):
            # Obtener datos de las columnas
            # Columna A (índice 0) y B (índice 1) = iniciales del reclutador
            # Columna C (índice 2) = nombre del aspirante
            # Columna F (índice 5) = tiempo que se añadió
            # Columna AD (índice 29) = tiempo que se activó

            inicial_a = str(row[0]).strip() if row[0] else ''
            inicial_b = str(row[1]).strip() if row[1] else ''
            reclutador = f"{inicial_a}{inicial_b}".strip()
            aspirante = str(row[2]).strip() if row[2] else ''
            fecha_anadido = parse_excel_date(row[5])
            fecha_activado = parse_excel_date(row[29])

            # Solo agregar si tiene datos relevantes
            if reclutador and aspirante:
                aspirantes.append({
                    'reclutador': reclutador,
                    'aspirante': aspirante,
                    'fecha_anadido': fecha_anadido,
                    'fecha_activado': fecha_activado,
                    'fila': row_idx
                })

        return aspirantes

    except Exception as e:
        st.error(f"Error procesando el archivo: {str(e)}")
        return None

def find_issues(aspirantes):
    """Encuentra los problemas en los datos"""
    issues = {
        'sin_fecha_anadido': [],
        'sin_fecha_activado': [],
        'activado_antes_anadido': []
    }

    for asp in aspirantes:
        # Verificar si falta fecha de añadido
        if not asp['fecha_anadido']:
            issues['sin_fecha_anadido'].append(asp)

        # Verificar si falta fecha de activado
        if not asp['fecha_activado']:
            issues['sin_fecha_activado'].append(asp)

        # Verificar si fue activado antes de ser añadido
        if asp['fecha_anadido'] and asp['fecha_activado']:
            if asp['fecha_activado'] < asp['fecha_anadido']:
                issues['activado_antes_anadido'].append(asp)

    return issues

# Título de la aplicación
st.title("📊 TrackerCheck")
st.markdown("### Verificador de Fechas en Tracker de Aspirantes")
st.markdown("---")

# Subir archivo
uploaded_file = st.file_uploader(
    "Sube tu archivo Excel (.xlsx)",
    type=['xlsx'],
    help="Selecciona el archivo Excel con los datos del tracker"
)

if uploaded_file is not None:
    # Procesar archivo
    with st.spinner('Procesando archivo...'):
        aspirantes = process_excel(uploaded_file)

    if aspirantes:
        st.success(f"✅ Archivo procesado correctamente. Se encontraron {len(aspirantes)} aspirantes.")

        # Encontrar problemas
        issues = find_issues(aspirantes)

        # Contar total de problemas
        total_issues = (
            len(issues['sin_fecha_anadido']) +
            len(issues['sin_fecha_activado']) +
            len(issues['activado_antes_anadido'])
        )

        # Mostrar resumen
        st.markdown("---")
        st.header("📋 Resumen de Resultados")

        col1, col2, col3, col4 = st.columns(4)

        with col1:
            st.metric("Total Aspirantes", len(aspirantes))

        with col2:
            st.metric("Total Problemas", total_issues, delta=None if total_issues == 0 else f"-{total_issues}")

        with col3:
            st.metric("Sin Fecha Añadido", len(issues['sin_fecha_anadido']))

        with col4:
            st.metric("Sin Fecha Activado", len(issues['sin_fecha_activado']))

        # Mostrar detalles de problemas
        st.markdown("---")

        if total_issues == 0:
            st.success("🎉 ¡Excelente! No se encontraron problemas en el tracker.")
        else:
            st.warning(f"⚠️ Se encontraron {total_issues} problema(s)")

            # Tab para cada tipo de problema
            tab1, tab2, tab3 = st.tabs([
                f"Sin Fecha Añadido ({len(issues['sin_fecha_anadido'])})",
                f"Sin Fecha Activado ({len(issues['sin_fecha_activado'])})",
                f"Activado Antes de Añadido ({len(issues['activado_antes_anadido'])})"
            ])

            with tab1:
                if issues['sin_fecha_anadido']:
                    st.markdown("### Aspirantes sin fecha de añadido")
                    df = pd.DataFrame([
                        {
                            'Fila': asp['fila'],
                            'Reclutador': asp['reclutador'],
                            'Aspirante': asp['aspirante'],
                            'Fecha Activado': asp['fecha_activado'].strftime('%Y-%m-%d') if asp['fecha_activado'] else 'N/A'
                        }
                        for asp in issues['sin_fecha_anadido']
                    ])
                    st.dataframe(df, use_container_width=True)
                else:
                    st.info("No hay problemas de este tipo")

            with tab2:
                if issues['sin_fecha_activado']:
                    st.markdown("### Aspirantes sin fecha de activado")
                    df = pd.DataFrame([
                        {
                            'Fila': asp['fila'],
                            'Reclutador': asp['reclutador'],
                            'Aspirante': asp['aspirante'],
                            'Fecha Añadido': asp['fecha_anadido'].strftime('%Y-%m-%d') if asp['fecha_anadido'] else 'N/A'
                        }
                        for asp in issues['sin_fecha_activado']
                    ])
                    st.dataframe(df, use_container_width=True)
                else:
                    st.info("No hay problemas de este tipo")

            with tab3:
                if issues['activado_antes_anadido']:
                    st.markdown("### Aspirantes activados antes de ser añadidos")
                    df = pd.DataFrame([
                        {
                            'Fila': asp['fila'],
                            'Reclutador': asp['reclutador'],
                            'Aspirante': asp['aspirante'],
                            'Fecha Añadido': asp['fecha_anadido'].strftime('%Y-%m-%d'),
                            'Fecha Activado': asp['fecha_activado'].strftime('%Y-%m-%d'),
                            'Diferencia (días)': (asp['fecha_anadido'] - asp['fecha_activado']).days
                        }
                        for asp in issues['activado_antes_anadido']
                    ])
                    st.dataframe(df, use_container_width=True)
                else:
                    st.info("No hay problemas de este tipo")

else:
    st.info("👆 Por favor, sube un archivo Excel para comenzar el análisis")

    # Información adicional
    with st.expander("ℹ️ Información sobre el formato esperado"):
        st.markdown("""
        El archivo Excel debe tener las siguientes columnas:

        - **Columna A**: Primera inicial del reclutador
        - **Columna B**: Segunda inicial del reclutador
        - **Columna C**: Nombre del aspirante
        - **Columna F**: Fecha en que se añadió
        - **Columna AD**: Fecha en que se activó

        La aplicación verificará:
        1. Que todos los aspirantes tengan fecha de añadido
        2. Que todos los aspirantes tengan fecha de activado
        3. Que la fecha de activado sea posterior a la fecha de añadido
        """)

# Footer
st.markdown("---")
st.markdown(
    "<div style='text-align: center; color: gray;'>TrackerCheck v2.0 - Streamlit Edition</div>",
    unsafe_allow_html=True
)
