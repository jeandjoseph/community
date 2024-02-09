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
CREATE TABLE stg.DimProducts
	(
	 [ProductId] bigint,
	 [Type] nvarchar(30),
	 [SKU] nvarchar(50),
	 [Name] nvarchar(50),
	 [Size] nvarchar(20),
	 [IsInStock] int
	)
WITH
	(
	 DISTRIBUTION = HASH(ProductId),
	 CLUSTERED COLUMNSTORE INDEX
	)
GO



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
CREATE TABLE prd.DimProducts
	(
	 [SurrogateKey] int  IDENTITY(1,1),
	 [ProductId] int,
	 [Type] nvarchar(30),
	 [SKU] nvarchar(50),
	 [Name] nvarchar(50),
	 [Size] nvarchar(20),
	 [IsInStock] int,
	 [ExpiredDate] DATE,
     [IsCurrent] BIT DEFAULT 1--,
	-- [CreateOn] DATETIME DEFAULT getdate(),
	-- [UpdateOn] DATETIME DEFAULT getdate()
	)
WITH
	(
	 DISTRIBUTION = HASH(ProductId),
	 CLUSTERED COLUMNSTORE INDEX
	)
GO



/********* INITIAL LOAD*****
	NO NEED TO LEVERAGE STAGING ENVIRONMENT UNLESS TRANSFORMATION NEEDED
*/
COPY INTO prd.DimProducts
(ProductId 1, Type 2, SKU 3, Name 4, Size 5, IsInStock 6)
FROM 'https://adlesilabs.dfs.core.windows.net/root/scd/initial/products.csv'
WITH
(
	FILE_TYPE = 'CSV'
	,MAXERRORS = 0
	,FIRSTROW = 2
	,ERRORFILE = 'https://adlesilabs.dfs.core.windows.net/root/scd/'
)
GO

SELECT TOP 100 * FROM prd.DimProducts
GO



/********** LOAD INCREMENTAL OR DELTA *******
	1) 	Load stage table
	2)	Insert into final table
*/


-- LOAD DELTA DATA
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


SELECT * FROM stg.DimProducts
GO

SELECT * FROM [prd].[DimProducts] WHERE ProductId = 58;
GO


SELECT * 
FROM [prd].[DimProducts] target 
INNER JOIN [stg].[DimProducts] stg 
   ON target.[ProductId] = stg.[ProductId]



--
BEGIN TRY
	BEGIN TRANSACTION
		UPDATE target
		SET 	target.[ExpiredDate]= CONVERT(VARCHAR(8),GETDATE(),110),
				target.[IsCurrent] 	= 0
		FROM [prd].[DimProducts] target 
		INNER JOIN [stg].[DimProducts] stg 
		ON target.[ProductId] = stg.[ProductId]		

		INSERT INTO [prd].[DimProducts]
		([ProductId],	[Type],	[SKU], [Name],[Size],[IsInStock])
		SELECT * FROM [stg].[DimProducts]
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE
	ROLLBACK
END CATCH



SELECT * FROM [prd].[DimProducts] ORDER BY ProductId;
GO



-- CLEAN UP
DROP TABLE [stg].[DimProducts]

DROP TABLE [prd].[DimProducts]



/*
select * from sys.database_scoped_credentials
select * from sys.database_role_members
select * from sys.database_principals

select * from sys.external_tables
select * from sys.external_data_sources
select * from sys.external_file_formats

*/