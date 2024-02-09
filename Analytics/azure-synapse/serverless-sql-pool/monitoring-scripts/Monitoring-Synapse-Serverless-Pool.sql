-- Monitoring Synapse serverless SQL open connections
SELECT     
    DB_NAME(s.database_id) as DBName, 
    COUNT(s.database_id) as NumberOfConnections,
    nt_user_name as username, 
    login_name as LoginName,
    program_name as ApplicationName 
FROM 
    sys.dm_exec_requests req
    JOIN sys.dm_exec_sessions s ON req.session_id = s.session_id
GROUP BY 
    s.database_id, nt_user_name, login_name, program_name






--Finding users that are connected to the server
SELECT login_name ,COUNT(session_id) AS session_count   
FROM sys.dm_exec_sessions   
GROUP BY login_name;  







-- Find number of open connection per application
SELECT
    DB_NAME(database_id) as DBName, 
    nt_user_name as username, 
    login_name as LoginName,
    program_name as ApplicationName,
	host_name,
	program_name,
	COUNT(*) AS NB_Connections
from sys.dm_exec_sessions
GROUP BY DB_NAME(database_id) , 
    nt_user_name , 
    login_name ,
    program_name ,
	host_name,
	program_name




    

-- Finding information about a queries own connection
SELECT   
    c.session_id, c.net_transport, c.encrypt_option,   
    c.auth_scheme, s.host_name, s.program_name,   
    s.client_interface_name, s.login_name, s.nt_domain,   
    s.nt_user_name, s.original_login_name, c.connect_time,   
    s.login_time   
FROM sys.dm_exec_connections AS c  
JOIN sys.dm_exec_sessions AS s  
    ON c.session_id = s.session_id  
WHERE c.session_id = @@SPID;  





-- Kill long running session(s)
-- Find the session which you want to kill using query bellow.
    SELECT 
     'Running' as [Status],
     Transaction_id as [Request ID],
     'SQL serverless' as [SQL Resource],
     s.login_name as [Submitter],
     s.Session_Id as [Session ID],
     req.start_time as [Submit time],
     req.command as [Request Type],
     SUBSTRING(
         sqltext.text, 
         (req.statement_start_offset/2)+1,   
         (
             (
                 CASE req.statement_end_offset  
                     WHEN -1 THEN DATALENGTH(sqltext.text)  
                     ELSE req.statement_end_offset  
                 END - req.statement_start_offset
             )/2
         ) + 1
     ) as [Query Text],
     req.total_elapsed_time as [Duration]
 FROM 
     sys.dm_exec_requests req
     CROSS APPLY sys.dm_exec_sql_text(sql_handle) sqltext
     JOIN sys.dm_exec_sessions s ON req.session_id = s.session_id 



SELECT * FROM sys.dm_pdw_sql_requests     
