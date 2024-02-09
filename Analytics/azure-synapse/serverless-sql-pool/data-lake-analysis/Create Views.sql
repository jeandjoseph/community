DROP DATABASE IF EXISTS DP203Demo
GO

CREATE DATABASE DP203Demo
GO

USE DP203Demo
GO


ALTER DATABASE DP203Demo 
    COLLATE Latin1_General_100_BIN2_UTF8;
GO


/* Compare Previous Close Price with the current date*/
CREATE VIEW [dbo].[GetPreviousAndCurrentClosePrice]
	AS 
SELECT CONVERT(VARCHAR(10),poh.OrderDate,110) AS OrderDate
      ,SUM(TotalDue) AS ClosePrice
      ,LAG(SUM(TotalDue)) OVER(ORDER BY poh.OrderDate) AS PrevClosePrice
      ,SUM(LineTotal) - LAG(SUM(TotalDue)) OVER(ORDER BY poh.OrderDate) AS ClosePriceDifference
     -- ,LAST_VALUE(LineTotal) OVER(PARTITION BY MONTH(poh.OrderDate),YEAR(poh.OrderDate) ORDER BY poh.OrderDate) AS FirstClosePrice
FROM
    OPENROWSET(
        BULK 'https://adlesilabs.dfs.core.windows.net/root/demofiles/csv/PurchaseOrderHeader.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = True
    ) AS [poh]
INNER JOIN (
 SELECT *
FROM
    OPENROWSET(
        BULK 'https://adlesilabs.dfs.core.windows.net/root/demofiles/csv/PurchaseOrderDetail.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = True
    ) AS [PurchaseOrderDetail]   
)pod
ON poh.PurchaseOrderID = pod.PurchaseOrderID
GROUP BY poh.OrderDate	
GO




SELECT TOP 5 * FROM [dbo].[GetPreviousAndCurrentClosePrice]
GO