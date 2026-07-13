USE master;

-- Create DB

IF DB_ID('DataWarehouse') IS NULL BEGIN CREATE
DATABASE DataWarehouse;

END

USE DataWarehouse;

-- Create Schema
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO