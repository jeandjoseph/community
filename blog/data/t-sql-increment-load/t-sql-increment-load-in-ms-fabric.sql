
-- Create schema 'stg' if it does not already exist
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg')
BEGIN
    EXEC ('CREATE SCHEMA stg')
END
GO

-- Drop the table 'stg.DimProducts' if it already exists
IF EXISTS (
    SELECT 1 
    FROM sys.objects O 
    JOIN sys.schemas S ON O.schema_id = S.schema_id
    WHERE O.name = 'DimProducts' AND O.type = 'U' AND S.name = 'stg'
)
BEGIN
    DROP TABLE stg.DimProducts
END
GO

-- Create the staging table 'stg.DimProducts'
CREATE TABLE stg.DimProducts (
    [ProductId] BIGINT,
    [Type] VARCHAR(30),
    [SKU] VARCHAR(50),
    [Name] VARCHAR(50),
    [Size] VARCHAR(20),
    [IsInStock] INT
)
GO

-- Create schema 'dw' if it does not already exist
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dw')
BEGIN
    EXEC ('CREATE SCHEMA dw')
END
GO

-- Drop the table 'dw.DimProducts' if it already exists
IF EXISTS (
    SELECT 1 
    FROM sys.objects O 
    JOIN sys.schemas S ON O.schema_id = S.schema_id
    WHERE O.name = 'DimProducts' AND O.type = 'U' AND S.name = 'dw'
)
BEGIN
    DROP TABLE dw.DimProducts
END
GO

-- Create the analytical table 'dw.DimProducts'
CREATE TABLE dw.DimProducts (
    [SurrogateKey] INT NOT NULL,       -- Unique identifier for each row
    [ProductId] INT NOT NULL,         -- Business identifier for products
    [Type] VARCHAR(30) NOT NULL,      -- Product type
    [SKU] VARCHAR(50) NOT NULL,       -- Stock keeping unit
    [Name] VARCHAR(50) NOT NULL,      -- Product name
    [Size] VARCHAR(20) NOT NULL,      -- Product size
    [IsInStock] INT NOT NULL,         -- Inventory status (0 or 1)
    [ExpiredDate] DATETIME2(0),       -- Expiration date (nullable)
    [IsCurrent] BIT NOT NULL          -- Indicates if the record is active
)
GO

-- Add a primary key constraint to the 'dw.DimProducts' table
ALTER TABLE dw.DimProducts
ADD CONSTRAINT PK_PrimaryKeyDimProducts 
PRIMARY KEY NONCLUSTERED (SurrogateKey) NOT ENFORCED;

-- Initial load: Load data into the 'stg.DimProducts' table
COPY INTO stg.DimProducts
(
    ProductId 1,     -- Column mapping: First column in the file maps to 'ProductId'
    Type 2,          -- Second column maps to 'Type'
    SKU 3,           -- Third column maps to 'SKU'
    Name 4,          -- Fourth column maps to 'Name'
    Size 5,          -- Fifth column maps to 'Size'
    IsInStock 6      -- Sixth column maps to 'IsInStock'
)
FROM 'https://your-storage-name.dfs.core.windows.net/root/scd/initial/*.csv' -- Source path for initial CSV files
WITH
(
    FILE_TYPE = 'CSV',         -- Specify the file format as CSV
    MAXERRORS = 0,             -- Stop loading if any errors occur
    FIRSTROW = 2,              -- Skip the header row in the CSV file
    ERRORFILE = 'https://your-storage-name.dfs.core.windows.net/root/scd/' -- Path for storing error logs
)
GO

-- Validate data loaded into 'stg.DimProducts'
SELECT * 
FROM stg.DimProducts 
ORDER BY ProductId;
GO

-- Load data into analytical table 'dw.DimProducts'
INSERT INTO dw.DimProducts (
    [SurrogateKey], [ProductId], [Type], [SKU], [Name],
    [Size], [IsInStock], [IsCurrent]
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY ProductId) AS RowNumber,
    *,
    1
FROM stg.DimProducts ORDER BY ProductId;
GO

-- Validate data loaded into 'dw.DimProducts'
SELECT * 
FROM dw.DimProducts 
ORDER BY ProductId;
GO

-- Incremental Load - Step 1: Truncate staging table
TRUNCATE TABLE stg.DimProducts;
GO

-- Verify empty staging table
SELECT * FROM stg.DimProducts;
GO

-- Load delta data into staging
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

-- Verify staging table data
SELECT * FROM stg.DimProducts;
GO

-- Search for expired records
SELECT stg.* 
    ,HASHBYTES('SHA2_256', CONCAT(stg.[ProductId], stg.Type, stg.SKU, stg.Name, stg.Size, stg.IsInStock)) AS stg_hash
    ,HASHBYTES('SHA2_256', CONCAT(target.[ProductId], target.Type, target.SKU, target.Name, target.Size, target.IsInStock))  AS prd_hash
FROM [stg].[DimProducts]  stg
INNER JOIN [prd].[DimProducts]  target
ON target.[ProductId] = stg.[ProductId]
WHERE target.[ExpiredDate] IS NULL
GO

-- Verify empty staging table
SELECT * FROM stg.DimProducts;
GO

-- Select specific record from 'stg.DimProducts'
SELECT * FROM [stg].[DimProducts] WHERE ProductId = 58;
GO

-- Expire old records and insert new rows
BEGIN TRY
    BEGIN TRANSACTION
        -- Expire old rows
        UPDATE target
        SET target.[ExpiredDate] = CONVERT(VARCHAR(8), GETDATE(), 110),
            target.[IsCurrent] = 0
        FROM [dw].[DimProducts] target
        INNER JOIN [stg].[DimProducts] stg
        ON target.[ProductId] = stg.[ProductId]
        AND HASHBYTES('SHA2_256', CONCAT(stg.ProductId, '|', stg.[Type], '|', stg.[SKU], '|', stg.Name, '|', stg.[Size])) <> 
            HASHBYTES('SHA2_256', CONCAT(target.ProductId, '|', target.[Type], '|', target.[SKU], '|', target.Name, '|', target.[Size]))
        AND target.[IsCurrent] = 1;
        -- Load the delta
        DECLARE @Max_SurrogateKey BIGINT;
        SELECT @Max_SurrogateKey = MAX([SurrogateKey]) FROM [dw].[DimProducts];
        -- Insert new rows
        INSERT INTO [dw].[DimProducts]
        (
            [SurrogateKey], [ProductId], [Type], [SKU], [Name],
            [Size], [IsInStock], [IsCurrent]
        )
        SELECT 
            @Max_SurrogateKey + ROW_NUMBER() OVER (ORDER BY ProductId) AS RowNumber,
            [ProductId], [Type], [SKU], [Name],
            [Size], [IsInStock], 1
        FROM [stg].[DimProducts];
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    -- Rollback transaction if an error occurs
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END
    -- Select error message
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Validate data loaded into 'dw.DimProducts'
SELECT * FROM [dw].[DimProducts] ORDER BY ProductId;
GO

-- Extra: Add primary key constraint to 'prd.DimProducts'
-- ALTER TABLE prd.DimProducts ADD CONSTRAINT PK_PrimaryKeyDimProducts PRIMARY KEY NONCLUSTERED (SurrogateKey) NOT ENFORCED; 

-- Check key referential integrity
-- It’s your responsibility to maintain data integrity
INSERT INTO [prd].[DimProducts]
SELECT * FROM [prd].[DimProducts] WHERE ProductId = 58;
GO
