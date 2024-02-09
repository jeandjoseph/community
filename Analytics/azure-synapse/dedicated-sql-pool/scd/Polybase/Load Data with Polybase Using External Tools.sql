-- MASTER KEY
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Pa$$W@rD!1';
GO


-- CREATE DATABASE SCOPED CREDENTIAL
CREATE DATABASE SCOPED CREDENTIAL AzStorageMICredential 
	WITH IDENTITY = 'Managed Identity'
GO


-- CREATE EXTERNAL DATA SOURCE
CREATE EXTERNAL DATA SOURCE AzDataLakeSecured_ds
WITH 
(  
	TYPE = Hadoop 
--,   LOCATION = 'wasbs://containername@storagename.blob.core.windows.net/'
,   LOCATION = 'abfss://root@adlesilabs.dfs.core.windows.net/scd/'
-- absence of credential will work with public or use the caller's Azure AD identity to access files on storage
,	CREDENTIAL = AzStorageMICredential 
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




--CRATE TABLE
-- DROP EXTERNAL TABLE [stg].[Product]
CREATE EXTERNAL TABLE [stg].[Product]
	(
	 [ProductID] int,
	 [ProductSKU] nvarchar(4000),
	 [ProductName] nvarchar(4000),
	 [ProductCategory] nvarchar(4000),
	 [ItemGroup] nvarchar(4000),
	 [KitType] nvarchar(4000),
	 [Channels] int,
	 [Demographic] nvarchar(4000),
	 [RetailPrice] money
	)
WITH (
    LOCATION='scd/product.csv',
    DATA_SOURCE = AzDataLakeSecured_ds,  
    FILE_FORMAT = AzExternalFileFormat,
    REJECT_TYPE = VALUE,
    REJECT_VALUE = 0
);

SELECT * FROM [stg].[Product]




-- LOAD DATA TO FINAL DESTINATION

-- CREATE SCHEMA prd
IF NOT EXISTS(SELECT 1 FROM sys.schemas WHERE name='prd')
BEGIN
    EXEC ('CREATE SCHEMA prd')
END
GO



-- DROP TABLE [prd].[Product] IF EXISTS
IF EXISTS (
	SELECT * FROM sys.objects O JOIN sys.schemas S 
	           ON O.schema_id = S.schema_id 
			 WHERE O.NAME = 'DimProduct' AND O.TYPE = 'U' AND S.NAME = 'prd'
)
DROP TABLE [prd].[DimProduct]
GO


/* WE NEED TO UNDERSTAND SCD BEFORE CREATING THE FINAL TABLE

-- Types of slowly changing dimensions
     [ExpiredDate] DATE,
     [IsCurrent] BIT DEFAULT 1

     TYPE 2 TO KEEP HISTORY
*/

--CRATE TABLE [prd].[Product]
--Identity column is not supported as distribution column.
CREATE TABLE [prd].[DimProduct]
	(
	 [SurrogateKey] int  IDENTITY(1,1)
	 [ProductID] int,
	 [ProductSKU] nvarchar(4000),
	 [ProductName] nvarchar(4000),
	 [ProductCategory] nvarchar(4000),
	 [ItemGroup] nvarchar(4000),
	 [KitType] nvarchar(4000),
	 [Channels] int,
	 [Demographic] nvarchar(4000),
	 [RetailPrice] money,
     [ExpiredDate] DATE,
     [IsCurrent] BIT DEFAULT 1
	)
WITH
	(
	DISTRIBUTION = HASH(ProductID),
	CLUSTERED COLUMNSTORE INDEX
)
GO



-- INITIAL LOAD DATA TO FINAL TABLE
INSERT INTO [prd].[DimProduct]
	(
	 [ProductID],
	 [ProductSKU],
	 [ProductName],
	 [ProductCategory],
	 [ItemGroup],
	 [KitType],
	 [Channels],
	 [Demographic],
	 [RetailPrice]
	)
SELECT 
	 [ProductID],
	 [ProductSKU],
	 [ProductName],
	 [ProductCategory],
	 [ItemGroup],
	 [KitType],
	 [Channels],
	 [Demographic],
	 [RetailPrice]
FROM [stg].[Product]
GO




SELECT * FROM [prd].[DimProduct] ORDER BY [ProductID]
GO




/*
    CLEAN UP
*/

DROP EXTERNAL TABLE [stg].[Product]

DROP EXTERNAL FILE FORMAT AzExternalFileFormat
GO

DROP EXTERNAL DATA SOURCE AzDataLakeSecured_ds
GO

DROP DATABASE SCOPED CREDENTIAL AzStorageMICredential
GO

DROP MASTER KEY
GO













