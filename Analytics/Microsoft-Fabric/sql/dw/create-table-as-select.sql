SELECT *
FROM [LH01].[dbo].[BikeBell]
GO


SELECT ProductName
      ,ProductType
      ,Color
      ,Country
      ,count(1) AS ItemsCategoryByCountry
FROM [LH01].[dbo].[BikeBell]
GROUP BY ProductName,ProductType,Color,Country
GO



-- create a table
CREATE TABLE dimproduct_lh
AS
SELECT ProductName
      ,ProductType
      ,Color
      ,Country
      ,count(1) AS ItemsCategoryByCountry
FROM [LH01].[dbo].[BikeBell]
GROUP BY ProductName,ProductType,Color,Country
GO


-- real table
SELECT COUNT(1) AS NbrOfRows
FROM [LH01].[dbo].[BikeBell]
GO



INSERT INTO dimproduct_lh
SELECT TOP 3 ProductName
      ,ProductType
      ,Color
      ,Country
      ,count(1) AS ItemsCategoryByCountry
FROM [LH01].[dbo].[BikeBell]
GROUP BY ProductName,ProductType,Color,Country
GO



SELECT COUNT(1) AS NbrOfRows
FROM [LH01].[dbo].[BikeBell]
GO

