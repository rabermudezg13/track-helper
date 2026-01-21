import streamlit as st
import pandas as pd
from datetime import datetime, timedelta
import openpyxl
from collections import defaultdict
import calendar

st.set_page_config(
    page_title="TrackerCheck",
    page_icon="📊",
    layout="wide"
)

def get_week_number(date):
    """Get ISO week number of the year"""
    if not date:
        return None
    iso_date = date.isocalendar()
    return iso_date[1]  # Week number

def parse_excel_date(value):
    """Converts Excel dates to Python datetime"""
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

def calculate_days_difference(date1, date2):
    """Calculate days difference between two dates"""
    if not date1 or not date2:
        return None
    diff = abs((date2 - date1).days)
    return diff

def process_excel(file):
    """Processes Excel file and extracts data similar to Node.js version"""
    try:
        # Read Excel file
        wb = openpyxl.load_workbook(file, data_only=True)
        ws = wb.active

        results = defaultdict(lambda: {
            'reclutador': '',
            'procesos': [],
            'semanas': defaultdict(lambda: {
                'semana': '',
                'tiempos': [],
                'promedio': 0
            }),
            'meses': defaultdict(lambda: {
                'mes': '',
                'tiempos': [],
                'promedio': 0
            })
        })

        # Iterate over rows (starting from row 2 to skip headers)
        for row_idx, row in enumerate(ws.iter_rows(min_row=2, values_only=True), start=2):
            # Get data from columns (same as Node.js version)
            # Columna A (index 0) y B (index 1) = iniciales del reclutador
            # Columna C (index 2) = nombre del aspirante
            # Columna F (index 5) = tiempo que se añadió
            # Columna AD (index 29) = tiempo que se activó

            inicial_a = str(row[0]).strip() if row[0] else ''
            inicial_b = str(row[1]).strip() if row[1] else ''
            reclutador = f"{inicial_a}{inicial_b}".strip()
            aspirante = str(row[2]).strip() if row[2] else ''
            fecha_anadido = parse_excel_date(row[5])
            fecha_activado = parse_excel_date(row[29])

            # Validate that we have necessary data (same logic as Node.js)
            if not reclutador or not fecha_anadido or not fecha_activado:
                continue

            # Calculate process time in days
            tiempo_proceso = calculate_days_difference(fecha_anadido, fecha_activado)
            if tiempo_proceso is None:
                continue

            # Get week and month from activation date
            semana = get_week_number(fecha_activado)
            mes = fecha_activado.month
            año = fecha_activado.year
            semana_key = f"{año}-W{str(semana).zfill(2)}"
            mes_key = f"{año}-M{str(mes).zfill(2)}"

            # Initialize recruiter structure if it doesn't exist
            if reclutador not in results:
                results[reclutador]['reclutador'] = reclutador

            # Add individual process
            results[reclutador]['procesos'].append({
                'aspirante': aspirante,
                'fechaAnadido': fecha_anadido.strftime('%Y-%m-%d'),
                'fechaActivado': fecha_activado.strftime('%Y-%m-%d'),
                'tiempoProceso': tiempo_proceso
            })

            # Add to week
            results[reclutador]['semanas'][semana_key]['semana'] = semana_key
            results[reclutador]['semanas'][semana_key]['tiempos'].append(tiempo_proceso)

            # Add to month
            results[reclutador]['meses'][mes_key]['mes'] = mes_key
            results[reclutador]['meses'][mes_key]['tiempos'].append(tiempo_proceso)

        # Calculate averages (same as Node.js version)
        formatted_results = []
        for reclutador_key, reclutador_data in results.items():
            # Calculate weekly averages
            semanas_list = []
            for semana_key, semana_data in reclutador_data['semanas'].items():
                if semana_data['tiempos']:
                    promedio = sum(semana_data['tiempos']) / len(semana_data['tiempos'])
                    semana_data['promedio'] = round(promedio, 2)
                    semanas_list.append(semana_data)
            
            # Calculate monthly averages
            meses_list = []
            for mes_key, mes_data in reclutador_data['meses'].items():
                if mes_data['tiempos']:
                    promedio = sum(mes_data['tiempos']) / len(mes_data['tiempos'])
                    mes_data['promedio'] = round(promedio, 2)
                    meses_list.append(mes_data)

            formatted_results.append({
                'reclutador': reclutador_data['reclutador'],
                'procesos': reclutador_data['procesos'],
                'semanas': sorted(semanas_list, key=lambda x: x['semana'], reverse=True),
                'meses': sorted(meses_list, key=lambda x: x['mes'], reverse=True)
            })

        return formatted_results

    except Exception as e:
        st.error(f"Error processing file: {str(e)}")
        return None

# Custom CSS for better styling
st.markdown("""
    <style>
    .big-font {
        font-size:2em !important;
        font-weight: bold;
    }
    .header-box {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 30px;
        border-radius: 15px;
        color: white;
        text-align: center;
        margin-bottom: 20px;
    }
    .recruiter-card {
        background-color: #f8f9fa;
        padding: 25px;
        border-radius: 15px;
        margin-bottom: 25px;
        border-left: 4px solid #667eea;
    }
    .stat-box {
        background-color: white;
        padding: 15px 20px;
        border-radius: 10px;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    }
    </style>
""", unsafe_allow_html=True)

# Header with greeting (same as Node.js version)
st.markdown("""
    <div class="header-box">
        <h2 style="font-size: 2em; margin-bottom: 10px;">Good Morning Anthony! 👋</h2>
        <p style="font-size: 1.2em; opacity: 0.95;">I hope to help you a lot today!</p>
    </div>
""", unsafe_allow_html=True)

st.title("📊 TrackerCheck")
st.markdown("### Process Time Analysis by Recruiter")
st.markdown("---")

# File upload
uploaded_file = st.file_uploader(
    "📁 Select Excel File",
    type=['xlsx', 'xls'],
    help="Select the Excel file with tracker data"
)

if uploaded_file is not None:
    # Process file
    with st.spinner('⏳ Processing file...'):
        results = process_excel(uploaded_file)

    if results:
        st.success(f"✅ File processed successfully. Found {len(results)} recruiter(s).")
        
        st.markdown("---")
        st.markdown(f"## Results: {len(results)} Recruiter(s)")

        # Display results for each recruiter
        for reclutador_data in results:
            reclutador = reclutador_data['reclutador']
            procesos = reclutador_data['procesos']
            semanas = reclutador_data['semanas']
            meses = reclutador_data['meses']

            # Calculate overall average
            total_procesos = len(procesos)
            promedio_general = 0
            if total_procesos > 0:
                promedio_general = sum(p['tiempoProceso'] for p in procesos) / total_procesos

            # Recruiter card
            st.markdown(f"""
                <div class="recruiter-card">
                    <h2 style="color: #333; margin-bottom: 20px; padding-bottom: 15px; border-bottom: 2px solid #667eea;">
                        👤 {reclutador if reclutador else 'No name'}
                    </h2>
                </div>
            """, unsafe_allow_html=True)

            # Stats row
            col1, col2 = st.columns(2)
            with col1:
                st.metric("Total Processes", total_procesos)
            with col2:
                st.metric("Overall Average", f"{promedio_general:.2f} days")

            # Individual Processes Section
            st.markdown("### 📋 Individual Processes")
            if procesos:
                procesos_df = pd.DataFrame([
                    {
                        'Applicant': p['aspirante'] or 'N/A',
                        'Date Added': p['fechaAnadido'],
                        'Date Activated': p['fechaActivado'],
                        'Process Time (days)': p['tiempoProceso']
                    }
                    for p in procesos
                ])
                st.dataframe(procesos_df, use_container_width=True, hide_index=True)
            else:
                st.info("No registered processes")

            # Weekly Averages Section
            st.markdown("### 📅 Weekly Averages")
            if semanas:
                # Show most recent week
                semana_reciente = semanas[0]
                st.markdown(f"""
                    **Week {semana_reciente['semana']} (Most Recent)**
                    - Average: **{semana_reciente['promedio']} days** ({len(semana_reciente['tiempos'])} process(es))
                """)

                # Show older weeks if any
                if len(semanas) > 1:
                    with st.expander(f"Show {len(semanas) - 1} older week(s)"):
                        for semana in semanas[1:]:
                            st.markdown(f"""
                                **Week {semana['semana']}**
                                - Average: **{semana['promedio']} days** ({len(semana['tiempos'])} process(es))
                            """)
            else:
                st.info("No weekly data available")

            # Monthly Averages Section
            st.markdown("### 📆 Monthly Averages")
            if meses:
                # Show most recent month
                mes_reciente = meses[0]
                st.markdown(f"""
                    **Month {mes_reciente['mes']} (Most Recent)**
                    - Average: **{mes_reciente['promedio']} days** ({len(mes_reciente['tiempos'])} process(es))
                """)

                # Show older months if any
                if len(meses) > 1:
                    with st.expander(f"Show {len(meses) - 1} older month(s)"):
                        for mes in meses[1:]:
                            st.markdown(f"""
                                **Month {mes['mes']}**
                                - Average: **{mes['promedio']} days** ({len(mes['tiempos'])} process(es))
                            """)
            else:
                st.info("No monthly data available")

            st.markdown("---")

else:
    st.info("👆 Please upload an Excel file to begin analysis")

    # Additional information
    with st.expander("ℹ️ Information about expected format"):
        st.markdown("""
        The Excel file must have the following columns:

        - **Column A**: First initial of recruiter
        - **Column B**: Second initial of recruiter
        - **Column C**: Applicant name
        - **Column F**: Date added
        - **Column AD**: Date activated

        The application will analyze:
        1. Process time in days for each applicant
        2. Weekly averages by activation date
        3. Monthly averages by activation date
        4. Individual process details
        """)

# Footer
st.markdown("---")
st.markdown(
    "<div style='text-align: center; color: gray;'>TrackerCheck v1.0 | Made with ❤️ for efficient recruitment tracking</div>",
    unsafe_allow_html=True
)
st.markdown(
    "<div style='text-align: center; color: gray;'>© 2024 From Colombia With Coffees</div>",
    unsafe_allow_html=True
)
