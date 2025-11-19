-- Dynamically create schema etl_process if not exists
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'etl_process')
BEGIN
  EXEC ('CREATE SCHEMA etl_process');
END
GO