-- Active: 1783948575995@@127.0.0.1@1444@master
USE master;
GO

DROP DATABASE IF EXISTS DataWarehouse;
GO

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;

-- Create Schema
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO