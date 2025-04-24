-- Ensure the schema exists before creating tables
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='stg')
BEGIN
    EXEC ('CREATE SCHEMA stg')
END
GO

-- Drop table if it exists
IF EXISTS (
    SELECT * FROM sys.objects O 
    JOIN sys.schemas S ON O.schema_id = S.schema_id 
    WHERE O.NAME = 'DimProducts' AND O.TYPE = 'U' AND S.NAME = 'stg'
)
DROP TABLE stg.DimProducts
GO

-- Create staging table
CREATE TABLE stg.DimProducts(
     [ProductId] BIGINT,
     [Type] VARCHAR(30),
     [SKU] VARCHAR(50),
     [Name] VARCHAR(50),
     [Size] VARCHAR(20),
     [IsInStock] INT
)
GO

/* Setting up the live table */
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='prd')
BEGIN
    EXEC ('CREATE SCHEMA prd')
END
GO

-- Drop table if it exists
IF EXISTS (
    SELECT * FROM sys.objects O 
    JOIN sys.schemas S ON O.schema_id = S.schema_id 
    WHERE O.NAME = 'DimProducts' AND O.TYPE = 'U' AND S.NAME = 'prd'
)
DROP TABLE prd.DimProducts
GO

-- Create live table
CREATE TABLE prd.DimProducts(
     [SurrogateKey] INT NOT NULL, -- Identity column handling in specific SQL editions
     [ProductId] INT NOT NULL,
     [Type] VARCHAR(30) NOT NULL,
     [SKU] VARCHAR(50) NOT NULL,
     [Name] VARCHAR(50) NOT NULL,
     [Size] VARCHAR(20) NOT NULL,
     [IsInStock] INT NOT NULL,
     [ExpiredDate] DATETIME2(0), -- Nullable
     [IsCurrent] BIT NOT NULL
)
GO

-- Define primary key (non-clustered, not enforced)
ALTER TABLE prd.DimProducts ADD CONSTRAINT PK_PrimaryKeyDimProducts PRIMARY KEY NONCLUSTERED (SurrogateKey) NOT ENFORCED; 
GO

/* Initial Data Load */
COPY INTO stg.DimProducts
(ProductId 1, Type 2, SKU 3, Name 4, Size 5, IsInStock 6)
FROM 'https://your-storage-name.dfs.core.windows.net/root/scd/initial/*.csv'
WITH
(
    FILE_TYPE = 'CSV',
    MAXERRORS = 0,
    FIRSTROW = 2,
    ERRORFILE = 'https://your-storage-name.dfs.core.windows.net/root/scd/'
)
GO

SELECT * FROM stg.DimProducts ORDER BY ProductId;
GO

/* Load data into live table */
INSERT INTO prd.DimProducts (
    [SurrogateKey], [ProductId], [Type], [SKU], [Name],
    [Size], [IsInStock], [IsCurrent]
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY ProductId) AS RowNumber,
    *,
    1
FROM stg.DimProducts ORDER BY ProductId;
GO

SELECT * FROM prd.DimProducts;
GO

/* Incremental Load */
-- Step 1: Truncate staging table
TRUNCATE TABLE stg.DimProducts;
GO

-- Step 2: Verify empty staging table
SELECT * FROM stg.DimProducts;
GO

-- Step 3: Load delta data into staging
COPY INTO stg.DimProducts
(ProductId 1, Type 2, SKU 3, Name 4, Size 5, IsInStock 6)
FROM 'https://your-storage-name.dfs.core.windows.net/root/scd/delta/products_delta.csv'
WITH
(
    FILE_TYPE = 'CSV',
    MAXERRORS = 0,
    FIRSTROW = 2,
    ERRORFILE = 'https://your-storage-name.dfs.core.windows.net/root/scd/'
)
GO

-- Step 4: Verify staging table data
SELECT * FROM stg.DimProducts;
GO

-- Search for expired records
SELECT 
    stg.*,
    HASHBYTES('SHA2_256', CONCAT(stg.[ProductId], stg.Type, stg.SKU, stg.Name, stg.Size, stg.IsInStock)) AS stg_hash,
    HASHBYTES('SHA2_256', CONCAT(target.[ProductId], target.Type, target.SKU, target.Name, target.Size, target.IsInStock)) AS prd_hash
FROM stg.DimProducts stg
INNER JOIN prd.DimProducts target
ON target.[ProductId] = stg.[ProductId]
WHERE target.[ExpiredDate] IS NULL;
GO

/* Expire old records and load delta */
BEGIN TRY
    BEGIN TRANSACTION
        -- Expire outdated records
        UPDATE target
        SET target.[ExpiredDate] = CONVERT(VARCHAR(8), GETDATE(), 110),
            target.[IsCurrent] = 0
        FROM prd.DimProducts target
        INNER JOIN stg.DimProducts stg 
        ON target.[ProductId] = stg.[ProductId]
        AND HASHBYTES('SHA2_256', CONCAT(stg.ProductId, '|', stg.[Type], '|', stg.[SKU], '|', stg.Name, '|', stg.[Size])) <> 
            HASHBYTES('SHA2_256', CONCAT(target.ProductId, '|', target.[Type], '|', target.[SKU], '|', target.Name, '|', target.[Size]))
        AND target.[IsCurrent] = 1;

        -- Load the delta
        DECLARE @Max_SurrogateKey BIGINT;
        SELECT @Max_SurrogateKey = MAX([SurrogateKey]) FROM prd.DimProducts;

        INSERT INTO prd.DimProducts
        (
            [SurrogateKey], [ProductId], [Type], [SKU], [Name],
            [Size], [IsInStock], [IsCurrent]
        )
        SELECT 
            @Max_SurrogateKey + ROW_NUMBER() OVER (ORDER BY ProductId) AS RowNumber,
            [ProductId], [Type], [SKU], [Name],
            [Size], [IsInStock], 1
        FROM stg.DimProducts;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

SELECT * FROM prd.DimProducts ORDER BY ProductId, SurrogateKey;
GO

/* Clean-Up */
DROP TABLE stg.DimProducts;
GO

DROP TABLE prd.DimProducts;
GO

DROP SCHEMA stg;
GO

DROP SCHEMA prd;
GO
