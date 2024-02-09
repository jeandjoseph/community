-- CSV | does not auto detect field(s) name
SELECT
    TOP 10 *
FROM
    OPENROWSET(
        BULK 'https://adlesilabs.dfs.core.windows.net/root/demofiles/csv/SalesOrderHeader.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0'
    ) AS [result]











-- filter out unwanted columns
SELECT
    TOP 10 SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate
FROM
    OPENROWSET(
        BULK 'https://adlesilabs.dfs.core.windows.net/root/demofiles/csv/SalesOrderHeader.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    ) AS [result]













-- CSV | does not auto detect field(s) data type(s)
EXEC sp_describe_first_result_set N'
SELECT
    TOP 5 *
FROM
    OPENROWSET(
        BULK ''https://adlesilabs.dfs.core.windows.net/root/demofiles/csv/SalesOrderHeader.csv'',
        FORMAT = ''CSV'',
        PARSER_VERSION = ''2.0'',
        HEADER_ROW=TRUE
    ) AS [result]
'
GO











-- Overwrite the data types
SELECT
    TOP 10 SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate
FROM
    OPENROWSET(
        BULK 'https://adlesilabs.dfs.core.windows.net/root/demofiles/csv/SalesOrderHeader.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    ) 
WITH(
     SalesOrderID INT
   , RevisionNumber VARCHAR(20)
   , OrderDate DATE
   , DueDate DATE
   , ShipDate  DATE
)AS [result]













-- VERIFY 
EXEC sp_describe_first_result_set N'
SELECT
    TOP 5 *
FROM
    OPENROWSET(
        BULK ''https://adlesilabs.dfs.core.windows.net/root/demofiles/csv/SalesOrderHeader.csv'',
        FORMAT = ''CSV'',
        PARSER_VERSION = ''2.0'',
        HEADER_ROW=TRUE
    ) 
WITH(
     SalesOrderID INT
   , RevisionNumber VARCHAR(20)
   , OrderDate DATE
   , DueDate DATE
   , ShipDate  DATE
)AS [result]
'
GO
