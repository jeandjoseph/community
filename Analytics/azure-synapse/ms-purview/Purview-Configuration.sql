-- Configure Azure Synapse Serverless SQL Pool
CREATE DATABASE PurView --Optional
GO

CREATE LOGIN [az-ms-purview-esi-demo] FROM EXTERNAL PROVIDER;
GO
--Optional

CREATE USER [az-ms-purview-esi-demo] FROM EXTERNAL PROVIDER
GO

GRANT SELECT TO [az-ms-purview-esi-demo]
GO

CREATE VIEW  BicycleSalesData 
AS
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'https://adlesilabs.dfs.core.windows.net/contribution/salesbike/input/*.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW=TRUE 
    ) AS [result]

-- Configure Azure Synapse Dedicated SQL Pool
USE master
GO

CREATE LOGIN [az-ms-purview-esi-demo] FROM EXTERNAL PROVIDER;
GO

CREATE USER [az-ms-purview-esi-demo] FROM EXTERNAL PROVIDER
GO

EXEC sp_addrolemember 'db_datareader', [az-ms-purview-esi-demo]
GO