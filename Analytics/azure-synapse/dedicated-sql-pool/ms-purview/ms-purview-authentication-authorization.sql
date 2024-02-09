 /* SERVERLESS SQL POOL

    Synapse Serverless Purview Setting up 
        Authentication & authorization
 */
 CREATE LOGIN [az-ms-purview-esi-demo] FROM EXTERNAL PROVIDER;
 GO

 CREATE USER [az-ms-purview-esi-demo] FOR LOGIN [az-ms-purview-esi-demo];
 GO

 ALTER ROLE db_datareader ADD MEMBER [az-ms-purview-esi-demo];
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

 /* DEDICATED SQL POOL

    Synapse Serverless Purview Setting up 
        Authentication & authorization
 */

CREATE USER [az-ms-purview-esi-demo] FROM EXTERNAL PROVIDER;
GO

EXEC sp_addrolemember 'db_datareader', [az-ms-purview-esi-demo];
GO