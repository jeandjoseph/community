/*
https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/synapse-analytics/sql-data-warehouse/what-is-a-data-warehouse-unit-dwu-cdwu.md

COST OPTIMIZATION:
    https://techcommunity.microsoft.com/t5/azure-synapse-analytics-blog/azure-synapse-variable-dwu-level-usage-cost-optimization-using/ba-p/1893309
*/

SELECT  db.name [Database]
,        ds.edition [Edition]
,        ds.service_objective [Service Objective]
FROM    sys.database_service_objectives   AS ds
JOIN    sys.databases                     AS db ON ds.database_id = db.database_id
;
GO




--Change data warehouse units
ALTER DATABASE MySQLDW
MODIFY (SERVICE_OBJECTIVE = 'DW1000c')
;
GO




--Check status of DWU changes
SELECT    *
FROM      sys.dm_operation_status
WHERE     resource_type_desc = 'Database'
AND       major_resource_id = 'MySQLDW'
;



--check requests
SELECT 
    request_id, 
    submit_time,
    command, 
    total_elapsed_time,
    resource_allocation_percentage,
    result_cache_hit
FROM sys.dm_pdw_exec_requests
WHERE command LIKE '%DW%'
AND session_id != SESSION_ID()
ORDER BY submit_time DESC;