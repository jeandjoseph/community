-- You can even query delta file
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'https://azuredatalakelabs.dfs.core.windows.net/root/delta/Table/PurchaseOrderDetail/',
        FORMAT = 'DELTA'
    ) AS [result]