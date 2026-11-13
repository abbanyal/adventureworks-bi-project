-- 01: Create the warehouse database and schemas
-- Run on the SQL Server instance that holds AdventureWorks2025.
USE master;
GO
IF DB_ID('AW_DW') IS NULL CREATE DATABASE AW_DW;
GO
USE AW_DW;
GO
IF SCHEMA_ID('stg')  IS NULL EXEC('CREATE SCHEMA stg');
IF SCHEMA_ID('dim')  IS NULL EXEC('CREATE SCHEMA dim');
IF SCHEMA_ID('fact') IS NULL EXEC('CREATE SCHEMA fact');
GO
SELECT name FROM sys.schemas WHERE name IN ('stg','dim','fact');
