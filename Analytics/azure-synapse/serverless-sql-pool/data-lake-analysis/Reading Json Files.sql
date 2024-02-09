/*
    format has to be CSV

    fieldterminator, fieldquote and rowterminator values have to be set as 0x0b

    Use JSON_VALUE to retrieve scalar values

    Use JSON_QUERY to extract objects and arrays

    Use OPENJSON to explode objects into rows or iterates over the elements of the array or the properties of the object (CROSS APPLY)
*/

/* Use JSON_VALUE to retrieve scalar values */
SELECT TOP 100
     jsonContent
    ,JSON_VALUE (jsonContent, '$[0].visitorId')

FROM
    OPENROWSET(
        BULK 'https://adlesilabs.dfs.core.windows.net/root/demofiles/json/0001.json',
        FORMAT = 'CSV',
        FIELDQUOTE = '0x0b',
        FIELDTERMINATOR ='0x0b',
        ROWTERMINATOR = '0x0b'
    )
    WITH (
        jsonContent varchar(MAX)
    ) AS [result]















/* Use JSON_QUERY to extract objects and arrays */
SELECT TOP 100
     jsonContent
     ,JSON_VALUE (jsonContent, '$[0].visitorId') AS visitorId
    ,JSON_QUERY (jsonContent, '$[1].topProductPurchases') AS topProductPurchases
FROM
    OPENROWSET(
        BULK 'https://adlesilabs.dfs.core.windows.net/root/demofiles/json/0001.json',
        FORMAT = 'CSV',
        FIELDQUOTE = '0x0b',
        FIELDTERMINATOR ='0x0b',
        ROWTERMINATOR = '0x0b'
    )
    WITH (
        jsonContent varchar(MAX)
    ) AS [result] 

















-- JSON | Flatten File
SELECT TOP 3
     visitorId
    ,productId
    ,itemsPurchasedLast12Months
    ,jsonContent
FROM
    OPENROWSET(
         BULK 'https://adlesilabs.dfs.core.windows.net/root/demofiles/json/0001.json',
        FORMAT = 'CSV',
        FIELDQUOTE = '0x0b',
        FIELDTERMINATOR ='0x0b',
        ROWTERMINATOR = '0x0b'
    )
    WITH (
        jsonContent varchar(MAX)
    ) AS [result]
    CROSS APPLY OPENJSON (jsonContent,'$')
    WITH (
           visitorId BIGINT '$.visitorId'
          ,topProductPurchases NVARCHAR(MAX) '$.topProductPurchases' AS JSON
    ) AS visitors
   CROSS APPLY OPENJSON (visitors.topProductPurchases)
    WITH(
           productId BIGINT '$.productId' 
          ,itemsPurchasedLast12Months BIGINT '$.itemsPurchasedLast12Months' 
    ) AS Data