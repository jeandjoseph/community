/* Setting up stage table 
https://adlesilabs.dfs.core.windows.net/root/scd/initial/products.csv
*/
-- CREATE SCHEMA stg
IF NOT EXISTS(SELECT 1 FROM sys.schemas WHERE name='stg')
BEGIN
    EXEC ('CREATE SCHEMA stg')
END
GO

-- DROP TABLE stg.DimProducts IF EXISTS 
IF EXISTS (
	SELECT * FROM sys.objects O JOIN sys.schemas S 
	           ON O.schema_id = S.schema_id 
	        WHERE O.NAME = 'DimProducts' AND O.TYPE = 'U' AND S.NAME = 'stg'
)
DROP TABLE stg.DimProducts
GO


--CREATE TABLE scd.DimProducts
CREATE TABLE stg.DimProducts(
	 [ProductId] bigint,
	 [Type] varchar(30),
	 [SKU] varchar(50),
	 [Name] varchar(50),
	 [Size] varchar(20),
	 [IsInStock] int
)
GO

/* Setting up live table */
-- CREATE SCHEMA prd
IF NOT EXISTS(SELECT 1 FROM sys.schemas WHERE name='prd')
BEGIN
    EXEC ('CREATE SCHEMA prd')
END
GO

-- DROP TABLE scd.DimProducts IF EXISTS 
IF EXISTS (
	SELECT * FROM sys.objects O JOIN sys.schemas S 
	           ON O.schema_id = S.schema_id 
	        WHERE O.NAME = 'DimProducts' AND O.TYPE = 'U' AND S.NAME = 'prd'
)
DROP TABLE prd.DimProducts
GO


--CREATE TABLE scd.DimProducts
/*
Use a Unique Identifier: Instead of an auto-incrementing integer, you could use a unique identifier (UUID or GUID) for each row. 
                         This would ensure uniqueness across all rows.

Manual Increment: You could manually manage the incrementing of the identity column. This would involve retrieving the maximum value 
                  of the identity column and then incrementing it for each new row. However, this approach can have performance implications 
                  and may not be suitable for high-volume scenarios.

Use a Sequence: If your data source supports sequences, you could create a sequence and use it to generate unique values for your identity column. 
                However, this would also need to be managed manually.
*/

CREATE TABLE prd.DimProducts(
	 [SurrogateKey] int not null,
	 [ProductId] int not null,
	 [Type] varchar(30) not null,
	 [SKU] varchar(50) not null,
	 [Name] varchar(50) not null,
	 [Size] varchar(20) not null,
	 [IsInStock] int not null,
	 [ExpiredDate] DATETIME2(0), --only null values
     [IsCurrent] BIT  not null--,
	-- [CreateOn] DATETIME2(0),
	 --[UpdateOn] DATETIME2(0)
)
GO

ALTER TABLE prd.DimProducts ADD CONSTRAINT PK_PrimaryKeyDimProducts PRIMARY KEY NONCLUSTERED (SurrogateKey) NOT ENFORCED; 

-- Initial load
COPY INTO stg.DimProducts
(ProductId 1, Type 2, SKU 3, Name 4, Size 5, IsInStock 6)
FROM 'https://<adls-account-name>.dfs.core.windows.net/root/scd/initial/*.csv'
WITH
(
	FILE_TYPE = 'CSV'
	,MAXERRORS = 0
	,FIRSTROW = 2
	,ERRORFILE = 'https://<adls-account-name>.dfs.core.windows.net/root/scd/'
)
GO

SELECT * 
FROM stg.DimProducts ORDER BY ProductId
GO

--****** Load data into the live table (initial load) *****

INSERT INTO prd.DimProducts(
    [SurrogateKey],[ProductId],[Type],[SKU],[Name],
    [Size],[IsInStock],[IsCurrent]
)
SELECT ROW_NUMBER() OVER (ORDER BY ProductId) AS RowNumber
       ,* 
       ,1
FROM stg.DimProducts ORDER BY ProductId
GO


SELECT * 
FROM prd.DimProducts

-- incremental load
-- #1 truncate staging
-- https://learn.microsoft.com/en-us/fabric/data-warehouse/tsql-surface-area#limitations
--   TRUNCATE TABLE is not a supported statement type.
-- DROP TABLE stg.DimProducts IF EXISTS 
IF EXISTS (
	SELECT * FROM sys.objects O JOIN sys.schemas S 
	           ON O.schema_id = S.schema_id 
	        WHERE O.NAME = 'DimProducts' AND O.TYPE = 'U' AND S.NAME = 'stg'
)
DROP TABLE stg.DimProducts
GO


--CREATE TABLE scd.DimProducts
CREATE TABLE stg.DimProducts(
	 [ProductId] bigint,
	 [Type] varchar(30),
	 [SKU] varchar(50),
	 [Name] varchar(50),
	 [Size] varchar(20),
	 [IsInStock] int
)
GO

-- verify there is no data
SELECT * FROM stg.DimProducts
GO

-- load the delta into staging table
COPY INTO stg.DimProducts
(ProductId 1, Type 2, SKU 3, Name 4, Size 5, IsInStock 6)
FROM 'https://adlesilabs.dfs.core.windows.net/root/scd/delta/products_delta.csv'
WITH
(
	FILE_TYPE = 'CSV'
	,MAXERRORS = 0
	,FIRSTROW = 2
	,ERRORFILE = 'https://adlesilabs.dfs.core.windows.net/root/scd/'
)
GO

-- verify there is data
SELECT * FROM stg.DimProducts
GO


SELECT stg.Size AS stg_Size,target.Size AS target_size,* 
FROM [prd].[DimProducts] target 
INNER JOIN [stg].[DimProducts] stg 
   ON target.[ProductId] = stg.[ProductId]

SELECT * FROM [stg].[DimProducts] WHERE ProductId = 58;
GO

SELECT * FROM [prd].[DimProducts] WHERE ProductId = 58;
GO







-- manual identity generation
DECLARE @Max_SurrogateKey BIGINT

SELECT @Max_SurrogateKey = MAX([SurrogateKey]) FROM [prd].[DimProducts]
--SELECT @Max_SurrogateKey

SELECT @Max_SurrogateKey + ROW_NUMBER() OVER (ORDER BY ProductId) AS RowNumber
       ,* 
       ,1
FROM stg.DimProducts ORDER BY ProductId
GO

SELECT * FROM [prd].[DimProducts];
GO

-- expire old records
UPDATE target
SET 	target.[ExpiredDate]= CONVERT(VARCHAR(8),GETDATE(),110),
        target.[IsCurrent] 	= 0
FROM [prd].[DimProducts] target 
INNER JOIN [stg].[DimProducts] stg 
ON target.[ProductId] = stg.[ProductId]	

SELECT * FROM [prd].[DimProducts];
GO

-- load the delta
DECLARE @Max_SurrogateKey BIGINT

SELECT @Max_SurrogateKey = MAX([SurrogateKey]) FROM [prd].[DimProducts]

INSERT INTO [prd].[DimProducts]
(
 [SurrogateKey],[ProductId],[Type],[SKU],[Name],
 [Size],[IsInStock],[IsCurrent]
)
SELECT @Max_SurrogateKey + ROW_NUMBER() OVER (ORDER BY ProductId) AS RowNumber
    ,* 
    ,1
FROM stg.DimProducts ORDER BY ProductId
GO


SELECT * FROM [prd].[DimProducts] ORDER BY ProductId;
GO


-- Check key referential integrity
-- It’s your responsibility to maintain data integrity
INSERT INTO [prd].[DimProducts]
SELECT * FROM [prd].[DimProducts] WHERE ProductId = 58;
GO

-- focus on ProductId
SELECT * FROM [prd].[DimProducts] ORDER BY ProductId;
GO


-- CLEAN UP
DROP TABLE [stg].[DimProducts]
GO
DROP TABLE [prd].[DimProducts]
GO

DROP SCHEMA [stg]
GO
DROP SCHEMA [prd]
GO
