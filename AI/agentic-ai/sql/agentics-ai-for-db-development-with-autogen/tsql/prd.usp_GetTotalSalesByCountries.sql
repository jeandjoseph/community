
IF OBJECT_ID('prd.usp_GetTotalSalesByCountries', 'P') IS NOT NULL
    DROP PROCEDURE prd.usp_GetTotalSalesByCountries;
GO

CREATE PROCEDURE prd.usp_GetTotalSalesByCountries
    @country VARCHAR(50) = 'all'
AS
BEGIN
    IF @country = 'all'
    BEGIN
        SELECT 
            Country,
            ProductName,
            ProductType,
            SUM(PurchasePrice) AS TotalPurchasePrice
        FROM prd.sales
        GROUP BY Country, ProductName, ProductType
        ORDER BY TotalPurchasePrice DESC;
    END
    ELSE
    BEGIN
        SELECT 
            Country,
            ProductName,
            ProductType,
            SUM(PurchasePrice) AS TotalPurchasePrice
        FROM prd.sales
        WHERE Country = @country
        GROUP BY Country, ProductName, ProductType
        ORDER BY TotalPurchasePrice DESC;
    END
END
