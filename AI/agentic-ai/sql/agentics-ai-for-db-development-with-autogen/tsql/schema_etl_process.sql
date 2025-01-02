
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'etl_process')
BEGIN
    EXEC('CREATE SCHEMA etl_process')
END
