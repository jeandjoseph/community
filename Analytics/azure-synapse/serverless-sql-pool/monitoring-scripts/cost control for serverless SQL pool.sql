/*
    Configure cost control for serverless SQL pool in T-SQL

    https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/data-processed
*/
-- See the current configuration execute the following T-SQL statement
SELECT * FROM sys.configurations
WHERE name like 'Data processed %';

-- see how much data was processed during the current day, week, or month
SELECT * FROM sys.dm_external_data_processed

-- daily
sp_set_data_processed_limit
	@type = N'daily',
	@limit_tb = 1

-- weekly
sp_set_data_processed_limit
	@type= N'weekly',
	@limit_tb = 2

-- monthly
sp_set_data_processed_limit
	@type= N'monthly',
	@limit_tb = 3334


USE <specific_database>;
GO


-- Identify External Table Metadata
USE <dbanme>;
GO

SELECT  et.[name] AS TableName,
        et.[location] AS TableLocation,
        ef.[name] AS FileFormatName,
        ef.[format_type] AS FileFormatType,
        es.[name] AS DataSourceName,
        es.[location] AS DataSourceLocation
FROM sys.external_tables et
INNER JOIN sys.external_file_formats ef ON ef.file_format_id = et.file_format_id
INNER JOIN sys.external_data_sources es ON es.data_source_id = et.data_source_id
GO

-- Check current usage versus limits
;WITH DataUsage
AS
(
    SELECT [type] AS DataUsageWindow,
    data_processed_mb AS DataProcessedMB,
    CAST(data_processed_mb AS DECIMAL(10,3)) / 1000 AS DataProcessedGB,
    (CAST(data_processed_mb AS DECIMAL(10,3)) / 1000) / 1000 AS DataProcessedTB
    FROM sys.dm_external_data_processed
),
DataLimit
AS
(
    SELECT [name] AS DataLimitWindow,
    CASE 
        WHEN [name] LIKE '%daily%' THEN 'daily'
        WHEN [name] LIKE '%weekly%' THEN 'weekly'
        WHEN [name] LIKE '%monthly%' THEN 'monthly'
    END AS DataUsageWindow,
    value AS TBValue,
    CAST(value_in_use AS INT) AS TBValueInUse
    FROM sys.configurations
    WHERE [name] LIKE 'Data processed %'
)
SELECT DL.DataUsageWindow,
    DL.TBValueInUse,
    DU.DataProcessedMB,
    DU.DataProcessedGB,
    DU.DataProcessedTB,
    (100 / DL.TBValueInUse) * DU.DataProcessedTB AS PercentTBUsed
FROM DataLimit DL
INNER JOIN DataUsage DU ON DL.DataUsageWindow = DU.DataUsageWindow