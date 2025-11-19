CREATE TABLE etl_process.error_log (
  id INT IDENTITY(1,1) NOT NULL,
  processid INT NULL,
  processname VARCHAR(50) NULL,
  objectname VARCHAR(50) NULL,
  errormsg VARCHAR(MAX) NULL,
  starttime DATETIME NULL,
  endtime DATETIME NULL
);