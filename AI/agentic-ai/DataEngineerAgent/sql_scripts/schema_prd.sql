-- Dynamically create schema prd if not exists
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'prd')
BEGIN
  EXEC ('CREATE SCHEMA prd');
END
GO