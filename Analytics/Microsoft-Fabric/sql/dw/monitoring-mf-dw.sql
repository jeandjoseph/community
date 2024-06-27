
/* get sessioons details
https://learn.microsoft.com/en-us/fabric/data-warehouse/monitor-using-dmv
*/
/* Find the relationship between connections and sessions */
SELECT connections.connection_id,
 connections.connect_time,
 sessions.session_id, sessions.login_name, sessions.login_time, sessions.status
FROM sys.dm_exec_connections AS connections
INNER JOIN sys.dm_exec_sessions AS sessions
ON connections.session_id=sessions.session_id
--WHERE sessions.status='running'
--AND sessions.session_id<> @@SPID
;
GO


/* Identify and KILL a long-running query 

WHILE (1=1)
BEGIN
    SELECT 1
END
*/
SELECT request_id, session_id, start_time, total_elapsed_time
FROM sys.dm_exec_requests
WHERE status = 'running'
AND session_id<> @@SPID
ORDER BY total_elapsed_time DESC;
GO


SELECT login_name
FROM sys.dm_exec_sessions
WHERE session_id = 53;
GO

-- or
-- get the type of operation
SELECT connections.connection_id
      ,sessions.session_id, sessions.login_name
      ,sessions.login_time
      ,requests.command
      ,requests.start_time
      ,requests.total_elapsed_time
FROM sys.dm_exec_connections AS connections
INNER JOIN sys.dm_exec_sessions AS sessions
    ON connections.session_id=sessions.session_id
INNER JOIN sys.dm_exec_requests AS requests
    ON requests.session_id = sessions.session_id
WHERE requests.status = 'running'
    AND requests.database_id = DB_ID()
ORDER BY requests.total_elapsed_time DESC;
GO

KILL 53
GO

/* Explore query insights */
SELECT * FROM queryinsights.exec_requests_history;
GO


SELECT * FROM queryinsights.frequently_run_queries;
GO


SELECT * FROM queryinsights.long_running_queries;
GO

/* STATSTICIS INFO
https://learn.microsoft.com/en-us/fabric/data-warehouse/statistics
*/
-- get all queries where statistics were automatically created
SELECT
    object_name(s.object_id) AS [object_name],
    c.name AS [column_name],
    s.name AS [stats_name],
    s.stats_id,
    STATS_DATE(s.object_id, s.stats_id) AS [stats_update_date], 
    s.auto_created,
    s.user_created,
    s.stats_generation_method_desc 
FROM sys.stats AS s 
INNER JOIN sys.objects AS o 
ON o.object_id = s.object_id 
INNER JOIN sys.stats_columns AS sc 
ON s.object_id = sc.object_id 
AND s.stats_id = sc.stats_id 
INNER JOIN sys.columns AS c 
ON sc.object_id = c.object_id 
AND c.column_id = sc.column_id
WHERE o.type = 'U' -- Only check for stats on user-tables
    AND s.auto_created = 1
   -- AND o.name = '<YOUR_TABLE_NAME>'
ORDER BY object_name, column_name;
GO

-- update stats
DBCC SHOW_STATISTICS ('<YOUR_TABLE_NAME>', '<statistics_name>');
GO

/* TABLE MAINTENANCE

https://learn.microsoft.com/en-us/fabric/data-engineering/lakehouse-table-maintenance#table-maintenance-operations

https://learn.microsoft.com/en-us/fabric/data-engineering/delta-optimization-and-v-order?tabs=sparksql

https://learn.microsoft.com/en-us/azure/synapse-analytics/spark/low-shuffle-merge-for-apache-spark
*/


