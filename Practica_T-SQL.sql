USE master;
GO
 
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'bd_universidad')
BEGIN
    ALTER DATABASE bd_universidad SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE bd_universidad;
END
GO
 
 
-- ============================================================
-- EJERCICIO 01 - Crear la base de datos
-- ============================================================
 
CREATE DATABASE bd_universidad;
GO
 
USE bd_universidad;
GO
 
-- ============================================================
-- EJERCICIO 02 - Tablas sin llaves foraneas: CARRERA y MATERIA
-- ============================================================
 
CREATE TABLE CARRERA (
    id_carrera     INT            IDENTITY(1,1) PRIMARY KEY,
    nombre         NVARCHAR(100)  NOT NULL,
    duracion_anios INT            NOT NULL,
    modalidad      NVARCHAR(20)   NOT NULL,
    CONSTRAINT ck_modalidad_carrera
        CHECK (modalidad IN (N'Presencial', N'Virtual', N'Semipresencial'))
);
GO
 
CREATE TABLE MATERIA (
    id_materia  INT           IDENTITY(1,1),
    codigo      NVARCHAR(10)  NOT NULL UNIQUE,
    nombre      NVARCHAR(100) NOT NULL,
    creditos    TINYINT       NOT NULL,  -- TINYINT: numeros del 0 al 255, perfecto para creditos
    semestre    TINYINT       NOT NULL,
 
    CONSTRAINT pk_materia            PRIMARY KEY (id_materia),
    CONSTRAINT ck_creditos_positivos CHECK (creditos > 0),
    CONSTRAINT ck_semestre           CHECK (semestre BETWEEN 1 AND 10)
);
GO
 
 
-- ============================================================
-- EJERCICIO 03 - Tabla ESTUDIANTE con llave foranea
-- ============================================================
 
CREATE TABLE ESTUDIANTE (
    id_estudiante    INT           IDENTITY(1,1) PRIMARY KEY,
    carnet           NVARCHAR(10)  NOT NULL UNIQUE,
    nombre_completo  NVARCHAR(150) NOT NULL,
    fecha_nacimiento DATE          NULL,
    email            NVARCHAR(100) NOT NULL UNIQUE,
    id_carrera       INT           NOT NULL,
 
    CONSTRAINT fk_estudiante_carrera FOREIGN KEY (id_carrera)
        REFERENCES CARRERA (id_carrera)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO
 
-- ============================================================
-- EJERCICIO 04 - Tabla INSCRIPCION (relacion muchos a muchos)
-- ============================================================
 
CREATE TABLE INSCRIPCION (
    id_inscripcion INT          IDENTITY(1,1) PRIMARY KEY,
    id_estudiante  INT          NOT NULL,
    id_materia     INT          NOT NULL,
    anio           SMALLINT     NOT NULL,
    periodo        NVARCHAR(3)  NOT NULL,
    nota_final     DECIMAL(4,2) NULL,   
    CONSTRAINT fk_inscripcion_estudiante
    FOREIGN KEY (id_estudiante) REFERENCES ESTUDIANTE (id_estudiante)
    ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT fk_inscripcion_materia
    FOREIGN KEY (id_materia) REFERENCES MATERIA (id_materia)
    ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT ck_periodo_valido
    CHECK (periodo IN (N'I', N'II', N'III')),
    CONSTRAINT ck_anio_valido
    CHECK (anio BETWEEN 2000 AND 2099),
    CONSTRAINT uq_inscripcion
    UNIQUE (id_estudiante, id_materia, anio, periodo)
);
GO
 
 
-- ============================================================
-- EJERCICIO 05 - Agregar columnas con ALTER TABLE
-- ============================================================
ALTER TABLE ESTUDIANTE
    ADD telefono NVARCHAR(20) NULL;
GO
ALTER TABLE ESTUDIANTE
ADD estado NVARCHAR(10) NOT NULL
CONSTRAINT df_estado_activo DEFAULT N'Activo',
CONSTRAINT ck_estado_valido CHECK (estado IN (N'Activo', N'Inactivo'));
GO
ALTER TABLE MATERIA
ADD descripcion NVARCHAR(MAX) NULL;
GO
 
 
-- ============================================================
-- EJERCICIO 06 - Modificar y renombrar columnas
-- ============================================================

ALTER TABLE ESTUDIANTE
    ALTER COLUMN telefono NVARCHAR(25) NULL;
GO
EXEC sp_rename
    N'CARRERA.duracion_anios', 
    N'duracion',                 
    N'COLUMN';
GO
ALTER TABLE INSCRIPCION
ALTER COLUMN nota_final DECIMAL(5,2) NULL;
GO
 
 
-- ============================================================
-- EJERCICIO 07 - Agregar y eliminar constraints
-- ============================================================
ALTER TABLE CARRERA
    ADD CONSTRAINT ck_duracion_carrera
        CHECK (duracion BETWEEN 3 AND 6);
GO
CREATE NONCLUSTERED INDEX IX_estudiante_email
    ON ESTUDIANTE (email);
GO
ALTER TABLE MATERIA
    DROP CONSTRAINT ck_semestre;
GO
ALTER TABLE MATERIA
    ADD CONSTRAINT ck_semestre_valido
        CHECK (semestre BETWEEN 1 AND 10);
GO
-- ============================================================
-- EJERCICIO 08 - Eliminar una columna
-- ============================================================
ALTER TABLE MATERIA
    DROP COLUMN descripcion;
GO
 
-- ============================================================
-- EJERCICIO 09 - Eliminar tablas en el orden correcto
-- ============================================================
 
DROP TABLE IF EXISTS INSCRIPCION;
DROP TABLE IF EXISTS ESTUDIANTE;
DROP TABLE IF EXISTS MATERIA;
DROP TABLE IF EXISTS CARRERA;
GO
 
-- ============================================================
-- EJERCICIO 10 - DROP vs TRUNCATE vs DELETE
-- ============================================================
CREATE TABLE CARRERA (
id_carrera INT IDENTITY(1,1) PRIMARY KEY,
nombre NVARCHAR(100) NOT NULL,
duracion INT NOT NULL,
modalidad  NVARCHAR(20)  NOT NULL,
CONSTRAINT ck_modalidad_carrera3
CHECK (modalidad IN (N'Presencial', N'Virtual', N'Semipresencial'))
);
GO
 
CREATE TABLE MATERIA (
    id_materia INT           IDENTITY(1,1),
    codigo     NVARCHAR(10)  NOT NULL UNIQUE,
    nombre     NVARCHAR(100) NOT NULL,
    creditos   TINYINT       NOT NULL,
    semestre   TINYINT       NOT NULL,
    CONSTRAINT pk_materia3            PRIMARY KEY (id_materia),
    CONSTRAINT ck_creditos_positivos3 CHECK (creditos > 0),
    CONSTRAINT ck_semestre_valido3    CHECK (semestre BETWEEN 1 AND 10)
);
GO
 
CREATE TABLE ESTUDIANTE (
    id_estudiante INT IDENTITY(1,1) PRIMARY KEY,
    carnet NVARCHAR(10)  NOT NULL UNIQUE,
    nombre_completo NVARCHAR(150) NOT NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    id_carrera INT NOT NULL,
    estado NVARCHAR(10)  NOT NULL DEFAULT N'Activo',
    CONSTRAINT fk_carrera3 FOREIGN KEY (id_carrera)
        REFERENCES CARRERA (id_carrera)
        ON DELETE NO ACTION ON UPDATE CASCADE
);
GO
 
CREATE TABLE INSCRIPCION (
    id_inscripcion INT IDENTITY(1,1) PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_materia INT NOT NULL,
    anio SMALLINT NOT NULL,
    periodo NVARCHAR(3)  NOT NULL,
    nota_final DECIMAL(5,2) NULL,
    CONSTRAINT fk_est3  FOREIGN KEY (id_estudiante) REFERENCES ESTUDIANTE(id_estudiante),
    CONSTRAINT fk_mat3  FOREIGN KEY (id_materia)    REFERENCES MATERIA(id_materia),
    CONSTRAINT ck_per3  CHECK (periodo IN (N'I', N'II', N'III')),
    CONSTRAINT ck_anio3 CHECK (anio BETWEEN 2000 AND 2099),
    CONSTRAINT uq_ins3  UNIQUE (id_estudiante, id_materia, anio, periodo)
);
GO
 
INSERT INTO CARRERA (nombre, duracion, modalidad) VALUES
    (N'Ingenieria en Sistemas',     5, N'Presencial'),
    (N'Administracion de Empresas', 4, N'Virtual'),
    (N'Derecho',                    5, N'Presencial');
GO
 
INSERT INTO MATERIA (codigo, nombre, creditos, semestre) VALUES
    (N'BD-101',   N'Bases de Datos I',    4, 3),
    (N'PROG-101', N'Programacion I',      3, 1),
    (N'MAT-101',  N'Calculo Diferencial', 4, 1);
GO
INSERT INTO CARRERA (nombre, duracion, modalidad) VALUES
    (N'Medicina',      6, N'Presencial'),
    (N'Arquitectura',  5, N'Presencial'),
    (N'Contabilidad',  4, N'Virtual');
GO
 
DELETE FROM CARRERA WHERE id_carrera IN (4, 5, 6);
GO
INSERT INTO CARRERA (nombre, duracion, modalidad)
    VALUES (N'Enfermeria', 4, N'Presencial');
GO

TRUNCATE TABLE MATERIA;
GO
 
INSERT INTO MATERIA (codigo, nombre, creditos, semestre) VALUES
    (N'BD-101',   N'Bases de Datos I',    4, 3),
    (N'PROG-101', N'Programacion I',      3, 1),
    (N'MAT-101',  N'Calculo Diferencial', 4, 1);
GO

BEGIN TRANSACTION;
    TRUNCATE TABLE MATERIA;
ROLLBACK;
GO
 
-- ============================================================
-- VERIFICACIONES FINALES
-- ============================================================
 

SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'CARRERA'
ORDER BY ORDINAL_POSITION;
GO
 
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'MATERIA'
ORDER BY ORDINAL_POSITION;
GO
 
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'ESTUDIANTE'
ORDER BY ORDINAL_POSITION;
GO
 
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'INSCRIPCION'
ORDER BY ORDINAL_POSITION;
GO
 
-- Ver todos los constraints creados:
SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
ORDER BY TABLE_NAME;
GO
 
PRINT N'Script ejecutado correctamente.';
GO