-- Configure 

-- run under master
CREATE LOGIN etl_user WITH PASSWORD = 'My@ZuR&2022v';
GO

CREATE USER etl_user FOR LOGIN etl_user;
GO


-- run under Data Warehouse Database
GRANT CONTROL ON DATABASE::[SQLPool01] to etl_user;




-- run under Data Warehouse Database
REVOKE CONTROL ON DATABASE::[SQLPool01] to etl_user;