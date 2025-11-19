-- Dynamically create schema stg if not exists
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg')
BEGIN
  EXEC ('CREATE SCHEMA stg');
END
GO