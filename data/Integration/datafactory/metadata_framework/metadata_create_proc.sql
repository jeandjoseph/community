-- make sure you change the values
CREATE PROC metadata.usp_get_etl_salesbike_metadata 
AS
BEGIN
	SELECT SVR.svrid
		,APP.appid
		,SVR.servername
		,APP.appname
		,files.[filename] as tablename
		,files.fileextension
		,files.containername
		,files.storageendpoint
		,files.incomingdir
		,files.archiveddir
		,files.archivedworkareadir
		,tblscript.schemaname
		,REPLACE(tblscript.scripttocreateschemas,'<<SCHEMANAME>>',tblscript.schemaname)scripttocreateschemas
		,REPLACE(tblscript.scripttocreatetables,'<<SCHEMANAME>>.<<TABLENAME>>',tblscript.schemaname+'.'+files.filename)scripttocreatetables
        ,CONVERT(VARCHAR(20),GETDATE(),112)+REPLACE(CONVERT(VARCHAR(20),GETDATE(),108),':','')processid
		--,REPLACE(REPLACE(scripttoinsert,'<<ONELAKE>>.<<SCHEMANAME>>.<<TABLENAME>>',files.storagename+'.dbo.'+files.[filename]),'<<SCHEMANAME>>.<<TABLENAME>>',tblscript.schemaname+'.'+files.[filename])scripttoinsert
	FROM [metadata].[servers] SVR 
	INNER JOIN [metadata].[application] APP 
	ON SVR.svrid = APP.svrid
	INNER JOIN [metadata].[filestorage] files
	ON files.appid = APP.appid
	INNER JOIN [metadata].[tablecontrol] tblscript
	ON tblscript.appid = APP.appid
    WHERE files.isactive = 1
END
GO
-- login
CREATE PROC [metadata].[usp_logPipelineExecution] 
(
     @appid INT
    ,@sourcedir VARCHAR(70)
    ,@destinationdir VARCHAR(70)
    ,@archiveddir VARCHAR(70)
    ,@loaddate VARCHAR(35)
    ,@starttime VARCHAR(35)
    ,@endtime VARCHAR(35)
    ,@processid BIGINT  
    ,@rowscopied INT =NULL
)
AS
BEGIN
    INSERT INTO [metadata].[logPipelineExecution]
    (processid,appid,sourcedir,destinationdir,archiveddir,rowscopied,loaddate,starttime,endtime,duration)
    SELECT @processid
          ,@appid
          ,@sourcedir
          ,@destinationdir
          ,@archiveddir
          ,@rowscopied
          ,@loaddate
          ,@starttime
          ,@endtime
          ,CONCAT(format(DATEDIFF(SECOND, CAST(@starttime AS DATETIME), CAST(@endtime AS DATETIME))/3600,'00'),':'
          ,format(DATEDIFF(SECOND, CAST(@starttime AS DATETIME), CAST(@endtime AS DATETIME))%3600/60,'00'),':'
          ,format(DATEDIFF(SECOND, CAST(@starttime AS DATETIME), CAST(@endtime AS DATETIME))%3600%60,'00')
          )duration
END
GO

-- error exception
CREATE PROC [metadata].[usp_batcherrorlog] 
(
    ,@processid BIGINT
    ,@appid VARCHAR(70)
    ,@errormsg VARCHAR(MAX)
    ,@starttime VARCHAR(35)
    ,@endtime VARCHAR(35)  
)
AS
BEGIN
    INSERT INTO [metadata].[batcherrorlog]
    (processid,appid,errormsg,starttime,endtime,duration)
    SELECT @processid
          ,@appid
          ,@errormsg
          ,@starttime
          ,@endtime
          ,CONCAT(format(DATEDIFF(SECOND, CAST(@starttime AS DATETIME), CAST(@endtime AS DATETIME))/3600,'00'),':'
          ,format(DATEDIFF(SECOND, CAST(@starttime AS DATETIME), CAST(@endtime AS DATETIME))%3600/60,'00'),':'
          ,format(DATEDIFF(SECOND, CAST(@starttime AS DATETIME), CAST(@endtime AS DATETIME))%3600%60,'00')
          )
END


