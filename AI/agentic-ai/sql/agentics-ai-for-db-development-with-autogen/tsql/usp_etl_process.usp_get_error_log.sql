
IF OBJECT_ID('etl_process.usp_get_error_log', 'P') IS NOT NULL
    DROP PROCEDURE etl_process.usp_get_error_log;
GO

CREATE PROCEDURE etl_process.usp_get_error_log
    @processname VARCHAR(50),
    @objectname VARCHAR(50),
    @errormsg VARCHAR(MAX),
    @starttime DATETIME,
    @endtime DATETIME
AS
BEGIN
    INSERT INTO etl_process.error_log (processname, objectname, errormsg, starttime, endtime)
    VALUES (@processname, @objectname, @errormsg, @starttime, @endtime);
END
