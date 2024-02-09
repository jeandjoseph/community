
/* Advance Data Analysis | Marketing Team */
SELECT YEAR(OrderDate) AS OrderDate
      ,SUM(TotalDue) AS TotalSalesByYear
      --,AVG(ISNULL(SalesOrderId,0)) AS AvgSalesByYear
      ,COUNT(ISNULL(SalesOrderId,0)) AS SalesOrderByYear
      ,RANK() OVER(ORDER BY SUM(TotalDue) DESC) AS RankSalesOrderByYear
      ,PERCENT_RANK() OVER(ORDER BY SUM(TotalDue)) AS [%RankSalesOrderByYear]
FROM
    OPENROWSET(
        BULK 'https://adlesilabs.dfs.core.windows.net/root/demofiles/csv/SalesOrderHeader.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = True
    ) 
WITH (
     OrderDate DATETIME2
    ,SalesOrderId BIGINT 
    ,TotalDue DECIMAL(18,2)
)   AS [result]  
GROUP BY YEAR(OrderDate)
ORDER BY RankSalesOrderByYear






/* Running Total */
SELECT CustomerID
      ,CONVERT(VARCHAR(10),OrderDate,110) AS OrderDate
      ,SalesOrderID
      ,SUM(TotalDue) OVER(ORDER BY SalesOrderID ROWS UNBOUNDED PRECEDING) AS RunningTotal--SELECT TOP 1 *
FROM
    OPENROWSET(
        BULK 'https://adlesilabs.dfs.core.windows.net/root/demofiles/csv/SalesOrderHeader.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = True
    ) AS [result]
WHERE OrderDate>='2014-06-01'
ORDER BY SalesOrderID, OrderDate;











/* Get First & Last Close Price */
SELECT CONVERT(VARCHAR(10),poh.OrderDate,110) AS OrderDate
      ,LineTotal AS ClosePrice
      ,FIRST_VALUE(LineTotal) OVER(PARTITION BY MONTH(poh.OrderDate),YEAR(poh.OrderDate) ORDER BY poh.OrderDate) AS FirstClosePrice
      ,LAST_VALUE(LineTotal) OVER(PARTITION BY MONTH(poh.OrderDate),YEAR(poh.OrderDate) ORDER BY poh.OrderDate) AS LastClosePrice
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
WHERE poh.OrderDate='01-08-2012'












/* Compare Previous Close Price with the current date*/
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
--ORDER BY poh.OrderDate