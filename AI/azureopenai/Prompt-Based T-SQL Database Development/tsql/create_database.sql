IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'azureopenai')
BEGIN
    CREATE DATABASE azureopenai;
END
GO