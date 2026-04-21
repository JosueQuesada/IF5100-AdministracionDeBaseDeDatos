-- Elimina la base de datos si ya existe
DROP DATABASE IF EXISTS EmpresaDB;
GO

-- Crea la base de datos
CREATE DATABASE EmpresaDB;
GO

-- Selecciona la base de datos
USE EmpresaDB;
GO

--Creación de la Tabla

-- Tabla de clientes
CREATE TABLE Clientes (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50),               
    Email VARCHAR(50)                 
);

-- Tabla de pedidos
CREATE TABLE Pedidos (
    Id INT PRIMARY KEY IDENTITY(1,1), 
    ClienteId INT,                 
    Producto VARCHAR(50),            
    FOREIGN KEY (ClienteId) REFERENCES Clientes(Id) 
);

-- Insertar clientes de prueba
INSERT INTO Clientes (Nombre, Email) VALUES
('Juan Perez', 'juan@gmail.com'),
('Maria Lopez', 'maria@gmail.com');

-- Insertar pedidos asociados a clientes
INSERT INTO Pedidos (ClienteId, Producto) VALUES
(1, 'Laptop'),
(2, 'Mouse');

Select * from Clientes
Select * from Pedidos

--Configurar la base de datos para entrar en modo Back up/Recuperación

-- Permite backups de log y recuperación a un punto en el tiempo
ALTER DATABASE EmpresaDB SET RECOVERY FULL;

-- BACKUP COMPLETO


-- Guarda toda la base de datos
BACKUP DATABASE EmpresaDB
TO DISK = 'C:\Backups\EmpresaDB_Full.bak'
WITH FORMAT, NAME = 'Backup Completo';


--  SIMULACIÓN DE BASE ESPEJO

-- Restaura el backup en otra base llamada EmpresaDB_Espejo
RESTORE DATABASE EmpresaDB_Espejo
FROM DISK = 'C:\Backups\EmpresaDB_Full.bak'
WITH 
REPLACE,
MOVE 'EmpresaDB' TO 'C:\Backups\EmpresaDB_Espejo.mdf', 
MOVE 'EmpresaDB_log' TO 'C:\Backups\EmpresaDB_Espejo.ldf',
RECOVERY;


-- CAMBIOS DESPUÉS DEL BACKUP COMPLETO

-- Insertar nuevo cliente 
INSERT INTO Clientes (Nombre, Email)
VALUES ('Carlos Ruiz', 'carlos@gmail.com');


-- BACKUP DIFERENCIAL

-- Guarda solo los cambios desde el último completo
BACKUP DATABASE EmpresaDB
TO DISK = 'C:\Backups\EmpresaDB_Diff.bak'
WITH DIFFERENTIAL, NAME = 'Backup Diferencial';


--  MÁS CAMBIOS EN LA BASE

INSERT INTO Pedidos (ClienteId, Producto)
VALUES (1, 'Teclado');

--  BACKUP LOG (INCREMENTAL)

-- Guarda el momento exacto para restauración futura
DECLARE @TiempoValido DATETIME = GETDATE();

-- Backup de transacciones (cambios recientes)
BACKUP LOG EmpresaDB
TO DISK = 'C:\Backups\EmpresaDB_Log.trn';

-- Mostrar el tiempo para usar con STOPAT
SELECT @TiempoValido AS TiempoParaSTOPAT;

--2026-04-16 21:37:41.687

--  FILEGROUP (BACKUP PARCIAL)

-- Crear grupo de archivos adicional
ALTER DATABASE EmpresaDB
ADD FILEGROUP GrupoSecundario;

-- Agregar archivo físico al filegroup
ALTER DATABASE EmpresaDB
ADD FILE (
    NAME = ArchivoSecundario,
    FILENAME = 'C:\Backups\ArchivoSecundario.ndf',
    SIZE = 5MB
)
TO FILEGROUP GrupoSecundario;

-- Crear tabla en el filegroup secundario
CREATE TABLE Productos (
    Id INT PRIMARY KEY,
    Nombre VARCHAR(50)
) ON GrupoSecundario;

-- Insertar datos en la tabla Productos
INSERT INTO Productos VALUES (1, 'Monitor'), (2, 'Teclado');

-- Backup solo del filegroup (parcial)
BACKUP DATABASE EmpresaDB
FILEGROUP = 'GrupoSecundario'
TO DISK = 'C:\Backups\EmpresaDB_FileGroup.bak';

--SIMULACIÓN DE ERROR
-- =========================================

-- Desactiva restricciones y se elimina la tabla
ALTER TABLE Pedidos NOCHECK CONSTRAINT ALL;

DELETE FROM Clientes;

-- Verificar que la tabla quedó vacía
SELECT * FROM Clientes;

--  PROCESO DE RESTAURACIÓN

USE master;
GO

-- Poner la base en modo usuario único
ALTER DATABASE EmpresaDB
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

-- RESTORE FULL

-- Restaura backup completo (base queda en restoring)
RESTORE DATABASE EmpresaDB
FROM DISK = 'C:\Backups\EmpresaDB_Full.bak'
WITH REPLACE, NORECOVERY;


-- RESTORE DIFERENCIAL

-- Aplica cambios posteriores al full
RESTORE DATABASE EmpresaDB
FROM DISK = 'C:\Backups\EmpresaDB_Diff.bak'
WITH NORECOVERY;


--  RESTORE LOG (PUNTO EN EL TIEMPO)



-- Recupera hasta un momento exacto antes del error
RESTORE LOG EmpresaDB
FROM DISK = 'C:\Backups\EmpresaDB_Log.trn'
WITH STOPAT = '2026-04-16 21:37:41.687',
 RECOVERY;

 --Se reestaura la base de datos 

 RESTORE DATABASE EmpresaDB WITH RECOVERY;

-- VOLVER A MULTI USER

-- Permite acceso normal a múltiples usuarios
ALTER DATABASE EmpresaDB
SET MULTI_USER;

USE EmpresaDB;
GO

--VERIFICACIÓN FINAL


-- Verificar datos restaurados
SELECT * FROM Clientes;
SELECT * FROM Pedidos;
SELECT * FROM Productos;

-- Verificar datos en la base espejo
SELECT * FROM EmpresaDB_Espejo.dbo.Clientes;
Select * from EmpresaDB_Espejo.dbo.Pedidos



