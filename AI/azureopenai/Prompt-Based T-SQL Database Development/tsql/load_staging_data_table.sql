CREATE PROCEDURE etl_process.usp_bulk_insert_csv
    @table_name NVARCHAR(255),
    @file_path NVARCHAR(255),
    @error_file_path NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @process_name NVARCHAR(255) = 'Bulk Insert CSV';
    DECLARE @process_type NVARCHAR(255) = 'ETL';
    DECLARE @start_time DATETIME2(7) = GETDATE();
    DECLARE @end_time DATETIME2(7);
    DECLARE @error_message NVARCHAR(MAX);

    BEGIN TRY
        DECLARE @sql NVARCHAR(MAX);

        SET @sql = 'BULK INSERT ' + @table_name + ' FROM ''' + @file_path + ''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', ERRORFILE = ''' + @error_file_path + ''')';

        EXEC sp_executesql @sql;

        SET @end_time = GETDATE();

        EXEC etl_process.usp_get_process_log @process_name, @process_type, @table_name, @start_time, @end_time;
    END TRY
    BEGIN CATCH
        SET @end_time = GETDATE();
        SET @error_message = ERROR_MESSAGE();

        EXEC etl_process.usp_get_error_log @process_name, @table_name, @error_message, @start_time, @end_time;
    END CATCH;
END;