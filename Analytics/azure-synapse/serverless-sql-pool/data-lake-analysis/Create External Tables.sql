-- CREATE OBEJECT AND WRITE BACK TO AZURE DATA LAKE
/*
DROP DATABASE IF EXISTS DP203Demo
GO

CREATE DATABASE DP203Demo
GO
*/

USE DP203Demo
GO


ALTER DATABASE DP203Demo 
    COLLATE Latin1_General_100_BIN2_UTF8;
GO





-- Write back to the data lake
-- 1: Create external data source
CREATE EXTERNAL DATA SOURCE [CuratedFiles] WITH
(
	LOCATION = 'https://adlesilabs.dfs.core.windows.net/root/curatedfiles/' -- No credentail needed as we are using synapse workspace
)
GO

-- 2: Create external file format
CREATE EXTERNAL FILE FORMAT [Parquestff] WITH
(
	FORMAT_TYPE = PARQUET,
	DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
)
GO

-- 3: Create external table
CREATE EXTERNAL TABLE [ExternalDataSource] WITH
(
	LOCATION    = 'top5sales/',--this folder should not be existed
	DATA_SOURCE = CuratedFiles,
	FILE_FORMAT = Parquestff
) AS
SELECT TOP 5
      CONVERT(VARCHAR(10),OrderDate,110) AS OrderDate
     ,CAST(SUM(SubTotal) AS DECIMAL(18,2)) AS subTotalByDate
FROM
    OPENROWSET(
        BULK 'https://adlesilabs.dfs.core.windows.net/root/demofiles/csv/SalesOrderHeader.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = True
    ) AS [result]
GROUP BY OrderDate
ORDER BY subTotalByDate DESC
GO


--   view the data
SELECT * FROM [ExternalDataSource]
GO