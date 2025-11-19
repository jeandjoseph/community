IF OBJECT_ID('etl_process.usp_BulkInsertFromCSV','P') IS NOT NULL
DROP PROCEDURE etl_process.usp_BulkInsertFromCSV;
GO
CREATE PROCEDURE etl_process.usp_BulkInsertFromCSV
  @TableName VARCHAR(256),
  @FilePath VARCHAR(4000),
  @ErrorFilePath VARCHAR(4000)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @StartTime DATETIME = GETDATE();
  DECLARE @EndTime DATETIME;
  DECLARE @Sql NVARCHAR(MAX);

  BEGIN TRY
     SET @Sql = 'TRUNCATE TABLE ' + @TableName;
     EXEC(@Sql);

     SET @Sql = 'BULK INSERT ' + @TableName +
                ' FROM ''' + @FilePath + ''' WITH ( FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', ERRORFILE = ''' + @ErrorFilePath + ''')';
     EXEC(@Sql);

     SET @EndTime = GETDATE();
     EXEC etl_process.usp_get_process_log @processname = 'usp_BulkInsertFromCSV', @processtype = 'ETL', @objectname = @TableName, @starttime = @StartTime, @endtime = @EndTime;
  END TRY
  BEGIN CATCH
     SET @EndTime = GETDATE();
     DECLARE @ErrMsg VARCHAR(MAX) = ERROR_MESSAGE();
     EXEC etl_process.usp_get_error_log @processname = 'usp_BulkInsertFromCSV', @objectname = @TableName, @errormsg = @ErrMsg, @starttime = @StartTime, @endtime = @EndTime;
     THROW;
  END CATCH
END
GO