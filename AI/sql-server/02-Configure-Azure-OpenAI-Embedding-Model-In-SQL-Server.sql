/*==============================================================================
SQL Server 2025: Step-by-step execution template
Purpose:
  - Enable PREVIEW_FEATURES at the database scope
  - Enable external AI runtimes at the instance scope
  - Ensure a Database Master Key exists (required for secrets/credentials)
  - Create a database-scoped credential for Azure OpenAI endpoint
  - Create an external model pointing to an Azure OpenAI embeddings deployment

Prerequisites:
  - You are connected with a login that can:
      - ALTER DATABASE SCOPED CONFIGURATION on the target database
      - Run sp_configure and RECONFIGURE (typically sysadmin)
      - Create master key, credentials, and external models in the target database
  - Replace all placeholders: <DB_NAME>, <StrongPassword>, <AOAI_ENDPOINT>, <AOAI_KEY>, <DEPLOYMENT_NAME>, <API_VERSION>

Notes:
  - PREVIEW_FEATURES is database-scoped, so you must run Step 2 in the correct database.
  - external AI runtimes is instance-scoped, so Step 3 is run once per SQL Server instance.
==============================================================================*/

-------------------------------------------------------------------------------
-- STEP 1) Set your target database context
-------------------------------------------------------------------------------
USE master
GO

CREATE DATABASE [TestDB]
GO

USE [TestDB]
GO

-------------------------------------------------------------------------------
-- STEP 2) Enable database-scoped preview features
--         This unlocks preview-only capabilities that require opt-in.
-------------------------------------------------------------------------------
ALTER DATABASE SCOPED CONFIGURATION SET PREVIEW_FEATURES = ON;
GO

-- Optional: Verify PREVIEW_FEATURES status (0 = OFF, 1 = ON)
SELECT name, value, value_for_secondary
FROM sys.database_scoped_configurations
WHERE name = N'PREVIEW_FEATURES';
GO

-------------------------------------------------------------------------------
-- STEP 3) Enable external AI runtimes at the instance level
--         Requires elevated permissions (usually sysadmin).
-------------------------------------------------------------------------------
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO

EXEC sp_configure 'external AI runtimes enabled', 1;
RECONFIGURE WITH OVERRIDE;
GO

-- Optional: Verify configuration
EXEC sp_configure 'external AI runtimes enabled';
GO

-------------------------------------------------------------------------------
-- STEP 4) Ensure a Database Master Key exists in the target database
--         This is required to protect secrets used by credentials.
-------------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1
    FROM sys.symmetric_keys
    WHERE [name] = N'##MS_DatabaseMasterKey##'
)
BEGIN
    PRINT 'Creating Database Master Key...';
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = N'sqlD&m@2025!';
END
ELSE
BEGIN
    PRINT 'Database Master Key already exists. Skipping creation.';
END
GO

-------------------------------------------------------------------------------
-- STEP 5) Create (or recreate) the Database Scoped Credential
--         The credential name is the base endpoint URL.
--         IDENTITY must be HTTPEndpointHeaders for header-based auth.
--         The secret is a JSON payload containing the API key.
-------------------------------------------------------------------------------
DECLARE @EndpointBaseUrl sysname = N'https://<your azure openai name>.openai.azure.com/';

-- If the credential already exists, drop it to allow updates
IF EXISTS (
    SELECT 1
    FROM sys.database_scoped_credentials
    WHERE name = @EndpointBaseUrl
)
BEGIN
    PRINT 'Dropping existing database scoped credential...';
    DECLARE @sqlDropCred nvarchar(max) =
        N'DROP DATABASE SCOPED CREDENTIAL ' + QUOTENAME(@EndpointBaseUrl) + N';';
    EXEC sys.sp_executesql @sqlDropCred;
END
GO

-- Create the credential
CREATE DATABASE SCOPED CREDENTIAL [https://<your azure openai name>.openai.azure.com/]
WITH
    IDENTITY = 'HTTPEndpointHeaders',
    SECRET = '{"api-key":"<your api key>"}';
GO

-------------------------------------------------------------------------------
-- STEP 6) Create (or recreate) the External Model for embeddings
--         LOCATION points to the Azure OpenAI embeddings endpoint for your deployment.
--         MODEL_TYPE is EMBEDDINGS for embedding generation workloads.
-------------------------------------------------------------------------------
-- If the model exists, drop it to allow updates
IF EXISTS (
    SELECT 1
    FROM sys.external_models
    WHERE name = N'MyAzureOpenAIModel'
)
BEGIN
    PRINT 'Dropping existing external model...';
    DROP EXTERNAL MODEL MyAzureOpenAIModel;
END
GO

CREATE EXTERNAL MODEL MyAzureOpenAIModel
WITH (
    LOCATION = 'https://<your azure openai name>.openai.azure.com/openai/deployments/<your deployment name>/embeddings?api-version=<API_VERSION>',
    API_FORMAT = 'Azure OpenAI',
    MODEL_TYPE = EMBEDDINGS,
    MODEL = <your deployment name>,  -- Example: text-embedding-ada-002 (if your deployment uses that model)
    CREDENTIAL = [https://<your azure openai name>.openai.azure.com/]
);
GO

-------------------------------------------------------------------------------
-- STEP 7) Post-deployment verification queries
-------------------------------------------------------------------------------
-- Confirm credential exists
SELECT name
FROM sys.database_scoped_credentials
WHERE name = N'https://<your azure openai name>.openai.azure.com/';
GO

-- Confirm model exists
SELECT name, location, api_format, model
FROM sys.external_models
WHERE name = N'MyAzureOpenAIModel';
GO

PRINT 'Setup complete.';
GO

/*
-- Verify credential exists
SELECT name FROM sys.database_scoped_credentials;

-- Verify external model exists
SELECT name, location FROM sys.external_models;


-- Run these in your TestDB to troubleshoot
EXEC sp_configure 'external AI runtimes enabled';

SELECT value FROM sys.database_scoped_configurations 
WHERE name = 'PREVIEW_FEATURES';

SELECT * FROM sys.database_scoped_credentials;

SELECT name, location, model FROM sys.external_models;
*/