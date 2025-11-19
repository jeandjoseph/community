IF OBJECT_ID('etl_process.usp_load_bicycle_staging_data','P') IS NOT NULL
DROP PROCEDURE etl_process.usp_load_bicycle_staging_data;
GO
CREATE PROCEDURE etl_process.usp_load_bicycle_staging_data
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @StartTime DATETIME = GETDATE();
  DECLARE @EndTime DATETIME;
  BEGIN TRY
     INSERT INTO prd.sales (ProductId, ProductName, ProductType, Color, OrderQuantity, Size, Category, Country, [Date], PurchasePrice, SellingPrice)
     SELECT
       TRY_CAST(ProductId AS INT),
       ProductName,
       ProductType,
       Color,
       TRY_CAST(OrderQuantity AS INT),
       Size,
       Category,
       Country,
       TRY_CAST([Date] AS DATE),
       TRY_CAST(PurchasePrice AS DECIMAL(18,2)),
       TRY_CAST(REPLACE(REPLACE(SellingPrice, CHAR(13), ''), CHAR(10), '') AS DECIMAL(18,2))
     FROM stg.salestmp;

     SET @EndTime = GETDATE();
     EXEC etl_process.usp_get_process_log @processname = 'usp_load_bicycle_staging_data', @processtype = 'ETL', @objectname = 'prd.sales', @starttime = @StartTime, @endtime = @EndTime;
  END TRY
  BEGIN CATCH
     SET @EndTime = GETDATE();
     DECLARE @ErrMsg VARCHAR(MAX) = ERROR_MESSAGE();
     EXEC etl_process.usp_get_error_log @processname = 'usp_load_bicycle_staging_data', @objectname = 'prd.sales', @errormsg = @ErrMsg, @starttime = @StartTime, @endtime = @EndTime;
     THROW;
  END CATCH
END
GO