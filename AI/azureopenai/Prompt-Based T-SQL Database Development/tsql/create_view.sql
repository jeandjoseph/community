IF OBJECT_ID('prd.vw_GetSaleDetails', 'V') IS NOT NULL
    DROP VIEW prd.vw_GetSaleDetails;
GO

CREATE VIEW prd.vw_GetSaleDetails
AS
SELECT Country, Color, Category
FROM stg.salestmp;
GO