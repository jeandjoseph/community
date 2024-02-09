SELECT TOP 5 * 
FROM OPENROWSET(
      BULK 'https://adlesilabs.dfs.core.windows.net/root/demofiles/parquet/sale-small-20191231.parquet'
    , FORMAT='PARQUET'
) as rows;
GO












EXEC sp_describe_first_result_set N'
SELECT
    TOP 5 *
FROM
    OPENROWSET(
        BULK ''https://adlesilabs.dfs.core.windows.net/root/demofiles/parquet/sale-small-20191231.parquet'',
        FORMAT = ''PARQUET''
    ) AS [result]
'








SELECT TOP 5 * 
FROM OPENROWSET(
      BULK 'https://adlesilabs.dfs.core.windows.net/root/demofiles/parquet/sale-small-20191231.parquet'
    , FORMAT='PARQUET'
) 
WITH(
       TransactionId VARCHAR(128)
      ,Price DECIMAL(18,2)
      ,TotalAmount DECIMAL(18,2)
      ,TransactionDate INT
    ) AS [result]
GO







EXEC sp_describe_first_result_set N'
SELECT
    TOP 5 *
FROM
    OPENROWSET(
        BULK ''https://adlesilabs.dfs.core.windows.net/root/demofiles/parquet/sale-small-20191231.parquet'',
        FORMAT = ''PARQUET''
    ) 
WITH(
       TransactionId VARCHAR(128)
      ,Price DECIMAL(18,2)
      ,TotalAmount DECIMAL(18,2)
      ,TransactionDate INT
    ) AS [result]
'









-- Get file name
SELECT
    [result].filename(),COUNT(1) AS NumberOfRowsByFiles
FROM
    OPENROWSET(
        BULK 'https://adlesilabs.dfs.core.windows.net/root/serverless/partition/parquet/sale-small/**',
        FORMAT = 'PARQUET'
    ) AS [result]
GROUP BY [result].filename()
GO








-- Get file directory
SELECT
   TOP 10 * ,[result].filepath(1),[result].filepath()--,COUNT(1) AS NumberOfRowsByFiles
FROM
    OPENROWSET(
        BULK 'https://adlesilabs.dfs.core.windows.net/root/demofiles/partition/sale-small/*/Quarter=*/Month=*/Day=*/*.parquet',
        FORMAT = 'PARQUET'
    ) AS [result]

GO


-- Log records
SELECT
   DISTINCT 
            [result].filepath(1) AS [Year]
           ,[result].filepath(2) AS [Quarter]
           ,[result].filepath(3) AS [Month]
           ,[result].filepath(4) AS [Day]
           ,0 AS IsLoaded
           ,[result].filepath() AS FullPath           
           --,COUNT(2) AS NumberOfRowsByFiles
FROM
    OPENROWSET(
        BULK 'https://adlesilabs.dfs.core.windows.net/root/demofiles/partition/sale-small/*/Quarter=*/Month=*/Day=*/*.parquet',
        FORMAT = 'PARQUET'
    ) AS [result]

GO
