# Análisis de Prospección de Leads — Roncier Consulting

**Autor:** Carlos Hernández Godoy  
**Perfil:** Analista de Datos | Ingeniero Industrial  
**Año:** 2025  

## Contexto del proyecto

Este proyecto presenta un análisis de prospección de leads orientado a mejorar la eficiencia comercial y la toma de decisiones estratégicas.

El análisis se basa en una base real de leads utilizada en procesos de prospección B2B, con el objetivo de identificar patrones de calidad, comportamiento de aperturas y distribución del pipeline comercial, facilitando la priorización de esfuerzos y recursos.

## Objetivos del análisis

- Analizar la calidad de los leads por país, estado y última acción.
- Medir el comportamiento de aperturas del primer correo y seguimientos.
- Identificar cuellos de botella dentro del pipeline de prospección.
- Priorizar mercados y segmentos con mayor potencial de respuesta.
- Construir un dashboard ejecutivo orientado a toma de decisiones.

## Estructura del repositorio
```
data-leads-roncierconsulting-2025/
├── 01_data/leads_clean.xlsx
├── 02_dax/medidas_dax.txt
├── 03_img/captura_dashboard.png
├── 04_pbix/leads-rc-dashboard.pbix
├── 05_sql/sql_modelado_y_analisis.sql
└── 06_README.md
```
## Datos utilizados

- **Fuente:** Base interna de prospección (datos anonimizados).
- **Registros:** 499 leads únicos.
- **Tratamiento de datos sensibles:**  
  Se eliminaron o anonimizaron columnas como empresa, marca, correo y enlaces, manteniendo únicamente variables relevantes para el análisis.

## Tecnologías y herramientas

### SQL Server
- Importación, limpieza y validación de datos.
- Análisis exploratorio y métricas clave.
- Modelado dimensional (Star Schema).
- Creación de tablas de dimensiones y tabla de hechos (`Fact_Leads`).
- Archivo: `05_sql/sql_modelado_y_analisis.sql`

### Power BI
- Power Query para carga y validación.
- Modelo estrella para análisis eficiente.
- Medidas DAX enfocadas en KPIs clave.
- Dashboard ejecutivo interactivo.
- Archivo: `04_pbix/leads-rc-dashboard.pbix`

### IA (ChatGPT)
- Apoyo en estructuración del análisis.
- Generación y validación de consultas SQL.
- Soporte en definición de métricas y narrativa analítica.
- Uso como herramienta de productividad, no sustituto del criterio analítico.

## Modelado y lógica analítica

El proyecto utiliza un **modelo estrella** compuesto por:

- **Tabla de hechos:** `Fact_Leads`
- **Tablas de dimensión:**  
  - Dim_Pais  
  - Dim_Prioridad  
  - Dim_Estado  
  - Dim_UltimaAccion  
  - Dim_ProximoPaso  

Este enfoque permite un análisis claro, escalable y optimizado para visualización en Power BI.

## Medidas DAX (principales)

Las medidas fueron diseñadas para ser **mínimas, claras y no redundantes**:

- Total Leads
- Apertura 1er Correo %
- Apertura Seguimiento %
- Leads Activos
- Leads Descartados
- Distribución por Estado
- Distribución por Última Acción

Documentadas en `02_dax/medidas_dax.txt`.

## Dashboard — Resumen Ejecutivo

El dashboard incluye:

- KPIs de apertura y volumen de leads.
- Distribución del pipeline por estado y última acción.
- Comparación de tasas de apertura por país.
- Segmentadores para análisis dinámico por mercado y estado.

Captura disponible en `03_img/captura_dashboard.png`.

## Principales insights

- La tasa global de apertura del primer correo es **19.04%**.
- La tasa de apertura de seguimiento es **12.83%**.
- Países como España y EE. UU. concentran mayor volumen y resultados más representativos.
- Países con pocos envíos pueden mostrar tasas altas no significativas estadísticamente.
- El **92.18%** de los leads se encuentran en estado descartado, reflejando un proceso de filtrado estricto.
- Las acciones avanzadas (PDF, presupuesto, seguimiento) representan una fracción pequeña pero valiosa del pipeline.

## Conclusión

Proyecto completo de análisis de datos aplicado a prospección comercial, integrando **SQL Server, modelado dimensional y Power BI**, con enfoque en claridad ejecutiva, métricas accionables y toma de decisiones basada en datos.

## Contacto

Carlos Hernández Godoy  
Analista de Datos | SQL Server + Power BI | Ingeniero Industrial  
**Correo:** carloshernandez.data@gmail.com

