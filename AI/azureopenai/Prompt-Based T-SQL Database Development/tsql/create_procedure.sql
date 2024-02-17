IF OBJECT_ID('prd.usp_GetTotalSalesByCountries', 'P') IS NOT NULL
    DROP PROCEDURE prd.usp_GetTotalSalesByCountries;
GO

CREATE PROCEDURE prd.usp_GetTotalSalesByCountries
    @country VARCHAR(50) = 'All'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Country,
        ProductName,
        ProductType,
        SUM(PurchasePrice) AS TotalPurchasePrice
    FROM 
        stg.salestmp
    WHERE 
        (@country = 'All' OR Country = @country)
    GROUP BY 
        Country,
        ProductName,
        ProductType
    ORDER BY 
        TotalPurchasePrice DESC;
END;
GO