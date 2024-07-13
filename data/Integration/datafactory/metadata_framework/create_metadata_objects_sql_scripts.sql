CREATE SCHEMA [metadata]
GO


CREATE TABLE [metadata].[servers](
    svrid INT IDENTITY(1,1),
    servername VARCHAR(255),
    createddate DATETIME2 DEFAULT GETDATE()
)
GO


CREATE TABLE [metadata].[application](
    appid INT IDENTITY(1,1),
    svrid  INT,
    appname VARCHAR(30),
    isactive BIT DEFAULT 1,
    createddate DATETIME2 DEFAULT GETDATE()
)
GO


CREATE TABLE [metadata].[filestorage](
    storageid INT IDENTITY(1,1),
    appid INT,
    filename VARCHAR(255),
    fileextension char(4),
    containername VARCHAR(50),
    storageendpoint VARCHAR(255),
    incomingdir VARCHAR(255),
    archiveddir VARCHAR(255),
    archivedworkareadir VARCHAR(255),  
    isactive BIT DEFAULT 1,
    createddate DATETIME2 DEFAULT GETDATE()
)
GO


CREATE TABLE [metadata].[tablecontrol](
    appid INT,
    schemaname VARCHAR(30),
    scripttocreateschemas VARCHAR(255),
    scripttocreatetables VARCHAR(1000),
    scripttoinsert VARCHAR(1000),
    createddate DATETIME2 DEFAULT GETDATE()
)
GO

CREATE TABLE [metadata].[logPipelineExecution](
     id INT IDENTITY(1,1)
    ,processid BIGINT
    ,appid INT
    ,sourcedir VARCHAR(70)
    ,destinationdir VARCHAR(70)
    ,archiveddir VARCHAR(70)
    ,rowscopied INT
    ,loaddate VARCHAR(35) DEFAULT CAST(GETDATE() AS VARCHAR(30))
    ,starttime VARCHAR(35)
    ,endtime VARCHAR(35)
    ,duration VARCHAR(8)
)

CREATE TABLE [metadata].[batcherrorlog] 
(
    batchid INT IDENTITY(1,1)
   ,processid BIGINT
   ,appid INT
   ,errormsg VARCHAR(MAX)
   ,starttime VARCHAR(35)
   ,endtime VARCHAR(35) 
   ,duration VARCHAR(8)  
   ,loaddate DATETIME DEFAULT GETDATE()
)
