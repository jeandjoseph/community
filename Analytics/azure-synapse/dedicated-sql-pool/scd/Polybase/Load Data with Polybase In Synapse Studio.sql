-- CREATE EXTERNAL DATA SOURCE
CREATE EXTERNAL DATA SOURCE AzDataLakeSecured_ds
WITH 
(  
	TYPE = Hadoop 
--,   LOCATION = 'wasbs://containername@storagename.blob.core.windows.net/'
,   LOCATION = 'abfss://root@adlesilabs.dfs.core.windows.net/'
-- absence of credential will work with public or use the caller's Azure AD identity to access files on storage
);



-- CREATE EXTERNAL FILE FORMAT
/*
	DATA COMPRESSION = 'org.apache.hadoop.io.compress.DefaultCodec'
	  - tradeoff between transferring less data and increased CPU cycle needed to compress and decompress the data.
	  - The ideal number of compressed files is the maximum number of data reader processes per compute node.
*/
-- DROP EXTERNAL FILE FORMAT AzExternalFileFormat
CREATE EXTERNAL FILE FORMAT AzExternalFileFormat
WITH (
    FORMAT_TYPE = DELIMITEDTEXT,
    FORMAT_OPTIONS (
        FIELD_TERMINATOR = ',',
        DATE_FORMAT = 'MM/dd/yyyy', 
        ENCODING = 'UTF8',
        FIRST_ROW = 2
    ),
    
        --STRING_DELIMITER = '0X0A',        
        DATA_COMPRESSION = 'org.apache.hadoop.io.compress.GzipCodec'
);



/************** INITIAL LOAD ****************
	1) Load stagging
	2) Load destination 
*/



-- Setting up & Load into stagging environment
-- CREATE SCHEMA stg
IF NOT EXISTS(SELECT 1 FROM sys.schemas WHERE name='stg')
BEGIN
    EXEC ('CREATE SCHEMA stg')
END
GO


--CREATE TABLE scd.DimProducts
-- DROP EXTERNAL TABLE stg.DimProducts
CREATE EXTERNAL TABLE stg.DimProducts
	(
	 [ProductId] bigint,
	 [Type] nvarchar(30),
	 [SKU] nvarchar(50),
	 [Name] nvarchar(50),
	 [Size] nvarchar(20),
	 [IsInStock] int
	)
WITH (
    LOCATION='scd/initial/products.csv',
    DATA_SOURCE = AzDataLakeSecured_ds,  
    FILE_FORMAT = AzExternalFileFormat,
    REJECT_TYPE = VALUE,
    REJECT_VALUE = 0
);
GO

--Verify if data there
SELECT * FROM stg.DimProducts
GO



-- Load data into final table destination
IF NOT EXISTS(SELECT 1 FROM sys.schemas WHERE name='prd')
BEGIN
    EXEC ('CREATE SCHEMA prd')
END
GO



-- DROP TABLE [prd].[Product] IF EXISTS
IF EXISTS (
	SELECT 1 FROM sys.objects O JOIN sys.schemas S 
	           ON O.schema_id = S.schema_id 
			 WHERE O.NAME = 'DimProducts' AND O.TYPE = 'U' AND S.NAME = 'prd'
)
DROP TABLE [prd].[DimProducts]
GO


/* WE NEED TO UNDERSTAND SCD BEFORE CREATING THE FINAL TABLE

-- Types of slowly changing dimensions
     [SurrogateKey] 
	 [ExpiredDate]
     [IsCurrent] BIT DEFAULT 1

     TYPE 2 TO KEEP HISTORY
*/

--CRATE TABLE [prd].[Product]
--Identity column is not supported as distribution column.
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


SELECT * FROM prd.DimProducts
GO



-- INITIAL LOAD DATA TO FINAL TABLE
INSERT INTO [prd].[DimProducts]
	(
	 [ProductId],
	 [Type],
	 [SKU],
	 [Name],
	 [Size],
	 [IsInStock]
	)
SELECT 
	 [ProductId],
	 [Type],
	 [SKU],
	 [Name],
	 [Size],
	 [IsInStock]
FROM [stg].[DimProducts]
GO




SELECT * FROM [prd].[DimProducts] ORDER BY [ProductID]
GO




/************ LOAD INCREMENTAL OR DELTA DATA 
	1) Truncate stage
	2) Update existing record(s) (expirer)
	3) Insert new record(s) plus the delta
*/


-- Truncate Stage Table
--TRUNCATE TABLE [stg].[DimProducts]
DROP EXTERNAL TABLE stg.DimProducts 
GO

CREATE EXTERNAL TABLE stg.DimProducts
	(
	 [ProductId] bigint,
	 [Type] nvarchar(30),
	 [SKU] nvarchar(50),
	 [Name] nvarchar(50),
	 [Size] nvarchar(20),
	 [IsInStock] int
	)
WITH (
    LOCATION='scd/delta/products_delta.csv',
    DATA_SOURCE = AzDataLakeSecured_ds,  
    FILE_FORMAT = AzExternalFileFormat,
    REJECT_TYPE = VALUE,
    REJECT_VALUE = 0
);



SELECT * FROM stg.DimProducts
GO

SELECT * FROM [prd].[DimProducts] WHERE ProductId = 58;
GO


SELECT stg.Size AS Delta, target.Size AS DW,* 
FROM [prd].[DimProducts] target 
INNER JOIN [stg].[DimProducts] stg 
   ON target.[ProductId] = stg.[ProductId]


--
BEGIN TRY
	BEGIN TRANSACTION
		UPDATE target
		SET 	target.[ExpiredDate]= CONVERT(VARCHAR(8),GETDATE(),110),
				target.[IsCurrent] 	= 0 --SELECT stg.Size AS Delta, target.Size AS DW,* 
		FROM [prd].[DimProducts] target 
		INNER JOIN [stg].[DimProducts] stg 
		ON target.[ProductId] = stg.[ProductId]		
		--there is something wrong here
		INSERT INTO [prd].[DimProducts]
		([ProductId],	[Type],	[SKU], [Name],[Size],[IsInStock])
		SELECT * FROM [stg].[DimProducts]
		--there is something wrong here
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE
	ROLLBACK
END CATCH



SELECT * FROM [prd].[DimProducts] ORDER BY ProductId;
GO




/* MERGE WILL NOT WORK FOR TABLE THAT HAS IDENTITY
https://learn.microsoft.com/en-us/sql/t-sql/statements/merge-transact-sql?view=azure-sqldw-latest&preserve-view=true#remarks
*/
MERGE [prd].[DimProducts] AS target
USING (SELECT [ProductId],	[Type],	[SKU], [Name],[Size],[IsInStock] FROM [stg].[DimProducts]) AS source
   ON (target.ProductId = source.ProductId)
WHEN MATCHED THEN 
	UPDATE SET 
			target.[ExpiredDate]= CONVERT(VARCHAR(8),GETDATE(),110),
			target.[IsCurrent] 	= 0
WHEN NOT MATCHED THEN 
	INSERT ([ProductId],	[Type],	[SKU],	[Name],	[Size],	[IsInStock])
	VALUES (source.[ProductId],	source.[Type], source.[SKU], source.[Name],	source.[Size], source.[IsInStock]);



-- HASHBYTE
SELECT stg.Size AS Delta, target.Size AS DW,* 
FROM [prd].[DimProducts] target 
INNER JOIN [stg].[DimProducts] stg 
   ON target.[ProductId] = stg.[ProductId]
   AND HASHBYTES('SHA2_256', CONCAT(stg.ProductId,'|',stg.[Type],'|',stg.[SKU],'|',stg.Name,'|',stg.[Size])) <> 
	   HASHBYTES('SHA2_256', CONCAT(target.ProductId,'|',target.[Type],'|',target.[SKU],'|',target.Name,'|',target.[Size]))

BEGIN TRY
	BEGIN TRANSACTION
		--expirer old rows
		UPDATE target
		SET 	target.[ExpiredDate]= CONVERT(VARCHAR(8),GETDATE(),110),
				target.[IsCurrent] 	= 0 --SELECT stg.Size AS Delta, target.Size AS DW,* 
		FROM [prd].[DimProducts] target 
		INNER JOIN [stg].[DimProducts] stg 
		ON target.[ProductId] = stg.[ProductId]		
		AND HASHBYTES('SHA2_256', CONCAT(stg.ProductId,'|',stg.[Type],'|',stg.[SKU],'|',stg.Name,'|',stg.[Size])) <> 
			HASHBYTES('SHA2_256', CONCAT(target.ProductId,'|',target.[Type],'|',target.[SKU],'|',target.Name,'|',target.[Size]))
		AND [IsCurrent]=1
		--Insert the delta
		INSERT INTO [prd].[DimProducts]
		([ProductId],	[Type],	[SKU], [Name],[Size],[IsInStock])
		SELECT * FROM [stg].[DimProducts] stg
		WHERE NOT EXISTS(
			SELECT 1
			FROM [prd].[DimProducts] target
			WHERE HASHBYTES('SHA2_256', CONCAT(stg.ProductId,'|',stg.[Type],'|',stg.[SKU],'|',stg.Name,'|',stg.[Size])) =
				  HASHBYTES('SHA2_256', CONCAT(target.ProductId,'|',target.[Type],'|',target.[SKU],'|',target.Name,'|',target.[Size]))
		)
		--there is something wrong here
	COMMIT
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE
	ROLLBACK
END CATCH

/*
    CLEAN UP
*/

DROP EXTERNAL TABLE [stg].[DimProducts]

DROP TABLE [prd].[DimProducts]

DROP EXTERNAL FILE FORMAT AzExternalFileFormat
GO

DROP EXTERNAL DATA SOURCE AzDataLakeSecured_ds
GO







DROP DATABASE SCOPED CREDENTIAL AzStorageMICredential
GO

DROP MASTER KEY
GO













