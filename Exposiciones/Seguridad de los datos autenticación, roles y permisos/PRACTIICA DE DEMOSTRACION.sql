/* =====================================================
   PRACTICA DE SEGURIDAD EN SQL SERVER
   BASE DE DATOS: EQUIPO COMPUTO
   CONTENIDO:
   - Base de datos
   - 3 Tablas
   - 2 Logins
   - 3 Usuarios
   - 2 Roles
   - Permisos
   - Pruebas de seguridad
===================================================== */


-- =====================================================
-- 1 CREAR BASE DE DATOS
-- =====================================================

CREATE DATABASE EquipoComputoDB;
GO

USE EquipoComputoDB;
GO



-- =====================================================
-- 2 CREAR TABLAS
-- =====================================================

-- Tabla de equipos
CREATE TABLE Equipos(
    IdEquipo INT PRIMARY KEY IDENTITY(1,1),
    NombreEquipo VARCHAR(50),
    TipoEquipo VARCHAR(50),
    Marca VARCHAR(50)
);

-- Tabla de usuarios del sistema
CREATE TABLE UsuariosSistema(
    IdUsuario INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50),
    Departamento VARCHAR(50)
);

-- Tabla de mantenimiento
CREATE TABLE Mantenimiento(
    IdMantenimiento INT PRIMARY KEY IDENTITY(1,1),
    IdEquipo INT,
    Fecha DATE,
    Descripcion VARCHAR(100)
);



-- =====================================================
-- 3 INSERTAR DATOS DE PRUEBA
-- =====================================================

INSERT INTO Equipos (NombreEquipo, TipoEquipo, Marca)
VALUES
('PC-01','Computadora','Dell'),
('Laptop-02','Laptop','HP'),
('Servidor-01','Servidor','IBM');

INSERT INTO UsuariosSistema (Nombre, Departamento)
VALUES
('Carlos','Soporte'),
('Ana','Administracion'),
('Luis','TI');



-- =====================================================
-- 4 CREAR LOGINS (nivel servidor)
-- =====================================================

CREATE LOGIN loginAdmin
WITH PASSWORD = '123';

CREATE LOGIN loginTecnico
WITH PASSWORD = '123';



-- =====================================================
-- 5 CREAR USUARIOS EN LA BASE DE DATOS
-- =====================================================

CREATE USER usuarioAdmin
FOR LOGIN loginAdmin;

CREATE USER usuarioTecnico
FOR LOGIN loginTecnico;

CREATE USER usuarioConsulta
WITHOUT LOGIN;



-- =====================================================
-- 6 CREAR ROLES
-- =====================================================

CREATE ROLE RolAdministrador;
CREATE ROLE RolTecnico;



-- =====================================================
-- 7 ASIGNAR USUARIOS A ROLES
-- =====================================================

ALTER ROLE RolAdministrador
ADD MEMBER usuarioAdmin;

ALTER ROLE RolTecnico
ADD MEMBER usuarioTecnico;



-- =====================================================
-- 8 DAR PERMISOS A LOS ROLES
-- =====================================================

-- Administrador control total de Equipos
GRANT SELECT, INSERT, UPDATE, DELETE
ON Equipos
TO RolAdministrador;

-- Administrador manejo mantenimiento
GRANT SELECT, INSERT, UPDATE
ON Mantenimiento
TO RolAdministrador;


-- Tecnico solo consulta equipos
GRANT SELECT
ON Equipos
TO RolTecnico;

-- Tecnico registra mantenimiento
GRANT INSERT
ON Mantenimiento
TO RolTecnico;



-- =====================================================
-- 9 DAR PERMISOS DIRECTOS A USUARIO
-- =====================================================

GRANT SELECT
ON UsuariosSistema
TO usuarioConsulta;



-- =====================================================
-- 10 PRUEBAS DE PERMISOS
-- =====================================================

-- PRUEBA 1
-- Tecnico puede consultar Equipos

EXECUTE AS USER = 'usuarioTecnico';

SELECT * FROM Equipos;

REVERT;



-- PRUEBA 2
-- Tecnico NO puede eliminar Equipos

EXECUTE AS USER = 'usuarioTecnico';

DELETE FROM Equipos WHERE IdEquipo = 2;

REVERT;



-- =====================================================
-- 11 DAR PERMISO NUEVO AL ROL TECNICO
-- =====================================================

GRANT DELETE
ON Equipos
TO RolTecnico;



-- =====================================================
-- 12 PROBAR NUEVAMENTE
-- =====================================================

EXECUTE AS USER = 'usuarioTecnico';

DELETE FROM Equipos WHERE IdEquipo = 2;

REVERT;



-- =====================================================
-- 13 PRUEBA TECNICO NO PUEDE ACTUALIZAR
-- =====================================================

EXECUTE AS USER = 'usuarioTecnico';

UPDATE Equipos
SET Marca = 'Lenovo'
WHERE IdEquipo = 1;

REVERT;



-- =====================================================
-- 14 TECNICO PUEDE INSERTAR MANTENIMIENTO
-- =====================================================

EXECUTE AS USER = 'usuarioTecnico';

INSERT INTO Mantenimiento
VALUES (1,GETDATE(),'Cambio de disco duro');

REVERT;



-- =====================================================
-- 15 USUARIO CONSULTA SOLO VE SU TABLA
-- =====================================================

EXECUTE AS USER = 'usuarioConsulta';

SELECT * FROM UsuariosSistema;

REVERT;



-- =====================================================
-- 16 USUARIO CONSULTA NO PUEDE VER EQUIPOS
-- =====================================================

EXECUTE AS USER = 'usuarioConsulta';

SELECT * FROM Equipos;

REVERT;



-- =====================================================
-- 17 DAR PERMISO NUEVO AL USUARIO CONSULTA
-- =====================================================

GRANT SELECT
ON Equipos
TO usuarioConsulta;



-- =====================================================
-- 18 PROBAR NUEVAMENTE
-- =====================================================

EXECUTE AS USER = 'usuarioConsulta';

SELECT * FROM Equipos;

REVERT;



-- =====================================================
-- 19 PERMITIR CREAR TABLAS AL ROL TECNICO
-- =====================================================

GRANT CREATE TABLE TO RolTecnico;



-- =====================================================
-- 20 TECNICO CREA TABLA
-- =====================================================

EXECUTE AS USER = 'usuarioTecnico';

CREATE TABLE PruebaTecnico(
    Id INT,
    Nombre VARCHAR(50)
);

REVERT;



-- =====================================================
-- 21 QUITAR PERMISO
-- =====================================================

REVOKE INSERT
ON Mantenimiento
FROM RolTecnico;



-- =====================================================
-- 22 PROBAR QUE YA NO PUEDE INSERTAR
-- =====================================================

EXECUTE AS USER = 'usuarioTecnico';

INSERT INTO Mantenimiento
VALUES (1,GETDATE(),'Prueba');

REVERT;



-- =====================================================
-- 23 DAR PERMISO NUEVAMENTE
-- =====================================================

GRANT INSERT
ON Mantenimiento
TO RolTecnico;



-- =====================================================
-- 24 PROBAR QUE FUNCIONA
-- =====================================================

EXECUTE AS USER = 'usuarioTecnico';

INSERT INTO Mantenimiento
VALUES (1,GETDATE(),'Nuevo mantenimiento');

REVERT;


/* =====================================================
   PRACTICA CON LOGINS
   DEMOSTRAR ACCESO AL SERVIDOR
===================================================== */


-- ==========================================
-- PRUEBA LOGIN ADMIN
-- ==========================================

PRINT 'Prueba del login administrador';


EXECUTE AS LOGIN = 'loginAdmin';

-- El administrador puede ver las tablas
SELECT * FROM EquipoComputoDB.dbo.Equipos;

REVERT;



-- ==========================================
-- PRUEBA LOGIN TECNICO
-- ==========================================

PRINT 'Prueba del login tecnico';


EXECUTE AS LOGIN = 'loginTecnico';

-- Puede consultar equipos
SELECT * FROM EquipoComputoDB.dbo.Equipos;

REVERT;



-- ==========================================
-- MOSTRAR LOGINS DEL SERVIDOR
-- ==========================================

SELECT name
FROM sys.server_principals
WHERE type_desc = 'SQL_LOGIN';



-- ==========================================
-- MOSTRAR USUARIOS DE LA BASE
-- ==========================================

USE EquipoComputoDB;

SELECT name
FROM sys.database_principals
WHERE type_desc = 'SQL_USER';



-- ==========================================
-- MOSTRAR ROLES
-- ==========================================

SELECT name
FROM sys.database_principals
WHERE type_desc = 'DATABASE_ROLE';