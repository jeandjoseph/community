
IF OBJECT_ID('etl_process.usp_load_bicycle_staging_data', 'P') IS NOT NULL
    DROP PROCEDURE etl_process.usp_load_bicycle_staging_data;
GO

CREATE PROCEDURE etl_process.usp_load_bicycle_staging_data
AS
BEGIN
    DECLARE @startTime DATETIME = GETDATE();
    DECLARE @endTime DATETIME;

    BEGIN TRY
        INSERT INTO prd.sales (ProductId, ProductName, ProductType, Color, OrderQuantity, Size, Category, Country, Date, PurchasePrice, SellingPrice)
        SELECT 
            CAST(ProductId AS INT),
            ProductName,
            ProductType,
            Color,
            CAST(OrderQuantity AS INT),
            Size,
            Category,
            Country,
            CAST(Date AS DATE),
            CAST(PurchasePrice AS DECIMAL(18,2)),
            CAST(REPLACE(REPLACE(SellingPrice, CHAR(13), ''), CHAR(10), '') AS DECIMAL(18,2))
        FROM stg.salestmp;

        SET @endTime = GETDATE();
        EXEC etl_process.usp_get_process_log 'LoadBicycleStagingData', 'INSERT', 'prd.sales', @startTime, @endTime;
    END TRY
    BEGIN CATCH
        SET @endTime = GETDATE();
        DECLARE @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE();
        EXEC etl_process.usp_get_error_log 'LoadBicycleStagingData', 'prd.sales', @errorMsg, @startTime, @endTime;
    END CATCH
END
