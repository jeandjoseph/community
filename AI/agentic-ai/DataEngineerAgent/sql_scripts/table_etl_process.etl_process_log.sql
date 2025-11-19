CREATE TABLE etl_process.etl_process_log (
  id INT IDENTITY(1,1) NOT NULL,
  processname VARCHAR(50) NULL,
  processtype VARCHAR(30) NULL,
  objectname VARCHAR(50) NULL,
  starttime DATETIME NULL,
  endtime DATETIME NULL
);