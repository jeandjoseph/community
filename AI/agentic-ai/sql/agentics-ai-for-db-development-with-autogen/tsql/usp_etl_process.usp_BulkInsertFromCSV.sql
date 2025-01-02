
IF OBJECT_ID('etl_process.usp_BulkInsertFromCSV', 'P') IS NOT NULL
    DROP PROCEDURE etl_process.usp_BulkInsertFromCSV;
GO

CREATE PROCEDURE etl_process.usp_BulkInsertFromCSV
    @tableName NVARCHAR(128),
    @filePath NVARCHAR(255),
    @errorFilePath NVARCHAR(255)
AS
BEGIN
    DECLARE @startTime DATETIME = GETDATE();
    DECLARE @endTime DATETIME;

    BEGIN TRY
        DECLARE @sql NVARCHAR(MAX) = 'TRUNCATE TABLE ' + @tableName;
        EXEC sp_executesql @sql;

        SET @sql = 'BULK INSERT ' + @tableName + ' FROM ''' + @filePath + ''' 
                    WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''
'', ERRORFILE = ''' + @errorFilePath + ''')';
        EXEC sp_executesql @sql;

        SET @endTime = GETDATE();
        EXEC etl_process.usp_get_process_log 'BulkInsertFromCSV', 'BULK INSERT', @tableName, @startTime, @endTime;
    END TRY
    BEGIN CATCH
        SET @endTime = GETDATE();
        DECLARE @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE();
        EXEC etl_process.usp_get_error_log 'BulkInsertFromCSV', @tableName, @errorMsg, @startTime, @endTime;
    END CATCH
END
