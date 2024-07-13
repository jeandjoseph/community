--**************READ TABLE CONTROL
--SERVER INFO
SELECT TOP (5) * FROM [metadata].[servers]
GO

-- APP TABLE
SELECT TOP (5) * FROM [metadata].[application]
GO

-- APP STORAGE
SELECT TOP (5) * FROM [metadata].[filestorage]
GO

-- OBJECT CREATION DETAILS
SELECT TOP (5) * FROM [metadata].[tablecontrol]
GO

-- GET METEDATA FOR THE PIPELINE
EXEC [metadata].[usp_get_etl_salesbike_metadata]
GO

-- load only activated file
EXEC SP_HELPTEXT '[metadata].[usp_get_etl_salesbike_metadata]'


--process log details
EXEC SP_HELPTEXT '[metadata].[usp_logPipelineExecution]'
-- READ TABLE LOG
SELECT TOP (5) * FROM [metadata].[logPipelineExecution]
GO

DECLARE @processid BIGINT
SELECT @processid = MAX(processid) FROM [metadata].[logPipelineExecution]

SELECT * FROM [metadata].[logPipelineExecution] WHERE processid=@processid

--process error details
EXEC SP_HELPTEXT '[metadata].[usp_batcherrorlog]'
GO

SELECT TOP (5) * FROM [metadata].[batcherrorlog]
GO

DECLARE @processid BIGINT

SELECT @processid = MAX(processid) FROM [metadata].[batcherrorlog]

SELECT * FROM  [metadata].[batcherrorlog] WHERE processid=@processid






