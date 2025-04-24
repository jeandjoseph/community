-- Select top 10 rows records from the bikebell table
SELECT TOP 10 *
FROM [LH02].[dbo].[bikebell]
GO



-- Performing basic analysis
-- Select and count items by category and country from the bikebell table
SELECT ProductName
      ,ProductType
      ,Color
      ,Country
      ,count(1) AS ItemsCategoryByCountry
FROM [LH02].[dbo].[bikebell]
GROUP BY ProductName,ProductType,Color,Country
GO




-- Drop the dimproduct_lh table if it exists
DROP TABLE IF EXISTS [dbo].[dimproduct_lh];
GO




-- Create a new dimproduct_lh table with aggregated data from the bikebell table
CREATE TABLE [dbo].[dimproduct_lh]
AS
SELECT ProductName
      ,ProductType
      ,Color
      ,Country
      ,count(1) AS ItemsCategoryByCountry
FROM [LH02].[dbo].[bikebell]
GROUP BY ProductName,ProductType,Color,Country
GO




-- Count the number of rows in the dimproduct_lh table
SELECT COUNT(1) AS NbrOfRows
FROM [dbo].[dimproduct_lh]
GO




-- Insert the top 3 aggregated records into the dimproduct_lh table
INSERT INTO [dbo].[dimproduct_lh]
SELECT TOP 3 ProductName
      ,ProductType
      ,Color
      ,Country
      ,count(1) AS ItemsCategoryByCountry
FROM [LH02].[dbo].[bikebell]
GROUP BY ProductName,ProductType,Color,Country
GO




-- Count the number of rows in the dimproduct_lh table
SELECT COUNT(1) AS NbrOfRows
FROM [dbo].[dimproduct_lh]
GO




-- Count the number of rows in the bikebell table
SELECT COUNT(1) AS NbrOfRows
FROM [LH02].[dbo].[bikebell]
GO
