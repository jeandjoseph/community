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
    CAST(SellingPrice AS DECIMAL(18,2))
FROM stg.salestmp;