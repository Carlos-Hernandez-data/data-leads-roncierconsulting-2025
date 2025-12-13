------------------------------------------------------------
-- 0. Contexto del proyecto
-- Base: Leads de prospección de Roncier Consulting
-- Objetivo: Limpieza, modelado estrella y análisis básico
------------------------------------------------------------

USE LeadsRC;
GO

------------------------------------------------------------
-- 1. Crear tabla limpia a partir de la tabla importada
--    (BaseLeads$ viene del asistente de importación de Excel)
------------------------------------------------------------

-- Verificación rápida de la tabla cruda
SELECT TOP 20 *
FROM dbo.[BaseLeads$];

SELECT COUNT(*) AS TotalFilas_Raw
FROM dbo.[BaseLeads$];

-- Crear tabla limpia: solo filas con ID y EMAIL válidos
SELECT
    [ID DEL LEAD],
    [TIPO DE LEAD],
    [DIAS SIN CONTACTO],
    [FECHA Y HORA DE 1ER CONTACTO],
    PRIORIDAD,
    ESTADO,
    [ABRIÓ 1ER COR#],       -- nombre tal como llegó de la importación
    EMPRESA,
    MARCA,
    PAIS,
    PRODUCTO,
    [ENLACE DEL PRODUCTO],
    EMAIL,
    [ULTIMA ACCION],
    [ABRIÓ SEG#],
    [FECHA ULTIMA ACCION],
    [PROXIMO PASO],
    [FECHA PROXIMO PASO],
    [PASO PROGRAMADO],
    [NOTAS/COMENTARIOS]
INTO dbo.Leads_Clean
FROM dbo.[BaseLeads$]
WHERE EMAIL IS NOT NULL
  AND [ID DEL LEAD] IS NOT NULL;

-- Verificar filas limpias
SELECT COUNT(*) AS TotalFilas_Leads_Clean
FROM dbo.Leads_Clean;

SELECT TOP 20 *
FROM dbo.Leads_Clean
ORDER BY [ID DEL LEAD] ASC;

------------------------------------------------------------
-- 2. Normalizar nombres de columnas problemáticas
--    (quitar tildes, # y espacios raros)
------------------------------------------------------------

EXEC sp_rename 'Leads_Clean.[ABRIÓ 1ER COR#]', 'ABRIO_1ER_CORREO', 'COLUMN';
EXEC sp_rename 'Leads_Clean.[ABRIÓ SEG#]',     'ABRIO_SEG',        'COLUMN';

------------------------------------------------------------
-- 3. Consultas de análisis directo sobre Leads_Clean
------------------------------------------------------------

-- Leads por país
SELECT 
    PAIS,
    COUNT(*) AS Total_Leads
FROM dbo.Leads_Clean
GROUP BY PAIS
ORDER BY Total_Leads DESC;

-- Distribución del pipeline (ESTADO)
SELECT 
    ESTADO,
    COUNT(*) AS Total_Leads
FROM dbo.Leads_Clean
GROUP BY ESTADO
ORDER BY Total_Leads DESC;

-- Cantidad de leads según la última acción
SELECT 
    [ULTIMA ACCION],
    COUNT(*) AS Total_Leads
FROM dbo.Leads_Clean
WHERE [ULTIMA ACCION] IS NOT NULL
GROUP BY [ULTIMA ACCION]
ORDER BY Total_Leads DESC;

-- % de leads en cada última acción
SELECT 
    [ULTIMA ACCION],
    COUNT(*) AS Total_Leads,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM dbo.Leads_Clean) AS DECIMAL(5,2)) AS Porcentaje
FROM dbo.Leads_Clean
GROUP BY [ULTIMA ACCION]
ORDER BY Total_Leads DESC;

-- Última acción por país
SELECT 
    PAIS,
    [ULTIMA ACCION],
    COUNT(*) AS Total_Leads
FROM dbo.Leads_Clean
GROUP BY PAIS, [ULTIMA ACCION]
ORDER BY PAIS, Total_Leads DESC;

-- Tasa de apertura del primer correo (global)
SELECT
    COUNT(*) AS Total_Leads,
    SUM(CASE WHEN ABRIO_1ER_CORREO = 'Si' THEN 1 ELSE 0 END) AS Abrio_Primer_Correo,
    CAST(SUM(CASE WHEN ABRIO_1ER_CORREO = 'Si' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Porcentaje_Apertura_1er_Correo
FROM dbo.Leads_Clean;

-- Tasa de apertura del primer correo por país
SELECT
    PAIS,
    COUNT(*) AS Total_Leads,
    SUM(CASE WHEN ABRIO_1ER_CORREO = 'Si' THEN 1 ELSE 0 END) AS Abrio_Primer_Correo,
    CAST(SUM(CASE WHEN ABRIO_1ER_CORREO = 'Si' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Porcentaje_Apertura_1er_Correo
FROM dbo.Leads_Clean
GROUP BY PAIS
ORDER BY Porcentaje_Apertura_1er_Correo DESC;

-- Tasa de apertura del seguimiento (global)
SELECT
    COUNT(*) AS Total_Leads,
    SUM(CASE WHEN ABRIO_SEG = 'Si' THEN 1 ELSE 0 END) AS Abrio_Seguimiento,
    CAST(SUM(CASE WHEN ABRIO_SEG = 'Si' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Porcentaje_Apertura_Seguimiento
FROM dbo.Leads_Clean;

------------------------------------------------------------
-- 4. Modelo dimensional: creación de tablas de dimensión
------------------------------------------------------------

-- a) Dimensión de país
CREATE TABLE dbo.Dim_Pais (
    IdPais INT IDENTITY(1,1) PRIMARY KEY,
    NombrePais NVARCHAR(100) NOT NULL
);

INSERT INTO dbo.Dim_Pais (NombrePais)
SELECT DISTINCT PAIS
FROM dbo.Leads_Clean
WHERE PAIS IS NOT NULL;

SELECT * FROM dbo.Dim_Pais;

-- b) Dimensión de prioridad
CREATE TABLE dbo.Dim_Prioridad (
    IdPrioridad INT IDENTITY(1,1) PRIMARY KEY,
    Prioridad NVARCHAR(20) NOT NULL
);

INSERT INTO dbo.Dim_Prioridad (Prioridad)
SELECT DISTINCT PRIORIDAD
FROM dbo.Leads_Clean
WHERE PRIORIDAD IS NOT NULL;

SELECT * FROM dbo.Dim_Prioridad;

-- c) Dimensión de estado del lead (columna ESTADO)
CREATE TABLE dbo.Dim_Estado (
    IdEstado INT IDENTITY(1,1) PRIMARY KEY,
    Estado NVARCHAR(80) NOT NULL
);

INSERT INTO dbo.Dim_Estado (Estado)
SELECT DISTINCT ESTADO
FROM dbo.Leads_Clean
WHERE ESTADO IS NOT NULL;

SELECT * FROM dbo.Dim_Estado;

-- d) Dimensión de última acción
CREATE TABLE dbo.Dim_UltimaAccion (
    IdUltimaAccion INT IDENTITY(1,1) PRIMARY KEY,
    UltimaAccion NVARCHAR(100) NOT NULL
);

INSERT INTO dbo.Dim_UltimaAccion (UltimaAccion)
SELECT DISTINCT [ULTIMA ACCION]
FROM dbo.Leads_Clean
WHERE [ULTIMA ACCION] IS NOT NULL;

SELECT * FROM dbo.Dim_UltimaAccion;

-- e) Dimensión de próximo paso
CREATE TABLE dbo.Dim_ProximoPaso (
    IdProximoPaso INT IDENTITY(1,1) PRIMARY KEY,
    ProximoPaso NVARCHAR(100) NOT NULL
);

INSERT INTO dbo.Dim_ProximoPaso (ProximoPaso)
SELECT DISTINCT [PROXIMO PASO]
FROM dbo.Leads_Clean
WHERE [PROXIMO PASO] IS NOT NULL;

SELECT * FROM dbo.Dim_ProximoPaso;

------------------------------------------------------------
-- 5. Tabla de hechos: Fact_Leads
------------------------------------------------------------

CREATE TABLE dbo.Fact_Leads (
    IdFactLead INT IDENTITY(1,1) PRIMARY KEY,
    IdDelLead INT NOT NULL,              -- ID DEL LEAD original
    IdPais INT NOT NULL,
    IdPrioridad INT NULL,
    IdEstado INT NULL,
    IdUltimaAccion INT NULL,
    IdProximoPaso INT NULL,
    DiasSinContacto INT NULL,
    FechaHora1erContacto DATETIME2(0) NULL,
    Abrio1erCorreo BIT NULL,
    AbrioSeg BIT NULL,
    Empresa NVARCHAR(150) NULL,
    Marca NVARCHAR(150) NULL,
    Producto NVARCHAR(255) NULL,
    EnlaceDelProducto NVARCHAR(500) NULL,
    Email NVARCHAR(255) NULL,
    FechaUltimaAccion DATETIME2(0) NULL,
    FechaProximoPaso DATETIME2(0) NULL,
    PasoProgramado BIT NULL,
    NotasComentarios NVARCHAR(MAX) NULL
);

-- Poblado de Fact_Leads desde Leads_Clean + dimensiones
INSERT INTO dbo.Fact_Leads (
    IdDelLead,
    IdPais,
    IdPrioridad,
    IdEstado,
    IdUltimaAccion,
    IdProximoPaso,
    DiasSinContacto,
    FechaHora1erContacto,
    Abrio1erCorreo,
    AbrioSeg,
    Empresa,
    Marca,
    Producto,
    EnlaceDelProducto,
    Email,
    FechaUltimaAccion,
    FechaProximoPaso,
    PasoProgramado,
    NotasComentarios
)
SELECT
    L.[ID DEL LEAD]                                   AS IdDelLead,
    P.IdPais,
    PR.IdPrioridad,
    E.IdEstado,
    UA.IdUltimaAccion,
    PP.IdProximoPaso,
    L.[DIAS SIN CONTACTO],
    L.[FECHA Y HORA DE 1ER CONTACTO],
    CASE WHEN L.ABRIO_1ER_CORREO = 'Si' THEN 1 ELSE 0 END AS Abrio1erCorreo,
    CASE WHEN L.ABRIO_SEG        = 'Si' THEN 1 ELSE 0 END AS AbrioSeg,
    L.EMPRESA,
    L.MARCA,
    L.PRODUCTO,
    L.[ENLACE DEL PRODUCTO],
    L.EMAIL,
    L.[FECHA ULTIMA ACCION],
    L.[FECHA PROXIMO PASO],
    CASE WHEN L.[PASO PROGRAMADO] = 'Si' THEN 1 ELSE 0 END AS PasoProgramado,
    L.[NOTAS/COMENTARIOS]
FROM dbo.Leads_Clean AS L
LEFT JOIN dbo.Dim_Pais          AS P  ON P.NombrePais   = L.PAIS
LEFT JOIN dbo.Dim_Prioridad     AS PR ON PR.Prioridad   = L.PRIORIDAD
LEFT JOIN dbo.Dim_Estado        AS E  ON E.Estado       = L.ESTADO
LEFT JOIN dbo.Dim_UltimaAccion  AS UA ON UA.UltimaAccion = L.[ULTIMA ACCION]
LEFT JOIN dbo.Dim_ProximoPaso   AS PP ON PP.ProximoPaso = L.[PROXIMO PASO];

-- Validar filas en Fact_Leads
SELECT COUNT(*) AS TotalFactLeads
FROM dbo.Fact_Leads;

SELECT TOP 20 *
FROM dbo.Fact_Leads;

------------------------------------------------------------
-- 6. Normalización de NULL en PRIORIDAD y ULTIMA ACCION
------------------------------------------------------------

-- Agregar 'SIN PRIORIDAD' a Dim_Prioridad
INSERT INTO dbo.Dim_Prioridad (Prioridad)
VALUES ('SIN PRIORIDAD');

-- Actualizar Fact_Leads para apuntar a esa prioridad donde IdPrioridad es NULL
UPDATE F
SET IdPrioridad = P.IdPrioridad
FROM dbo.Fact_Leads AS F
CROSS JOIN dbo.Dim_Prioridad AS P
WHERE F.IdPrioridad IS NULL
  AND P.Prioridad = 'SIN PRIORIDAD';

-- Agregar 'SIN ACCION REGISTRADA' a Dim_UltimaAccion
INSERT INTO dbo.Dim_UltimaAccion (UltimaAccion)
VALUES ('SIN ACCION REGISTRADA');

-- Actualizar Fact_Leads para apuntar a esa acción donde IdUltimaAccion es NULL
UPDATE F
SET IdUltimaAccion = UA.IdUltimaAccion
FROM dbo.Fact_Leads AS F
CROSS JOIN dbo.Dim_UltimaAccion AS UA
WHERE F.IdUltimaAccion IS NULL
  AND UA.UltimaAccion = 'SIN ACCION REGISTRADA';

-- Validar que ya no haya NULL en las FKs clave
SELECT COUNT(*) AS Null_IdPais
FROM dbo.Fact_Leads
WHERE IdPais IS NULL;

SELECT COUNT(*) AS Null_IdPrioridad
FROM dbo.Fact_Leads
WHERE IdPrioridad IS NULL;

SELECT COUNT(*) AS Null_IdEstado
FROM dbo.Fact_Leads
WHERE IdEstado IS NULL;

SELECT COUNT(*) AS Null_IdUltimaAccion
FROM dbo.Fact_Leads
WHERE IdUltimaAccion IS NULL;

------------------------------------------------------------
-- Fin de script
------------------------------------------------------------
