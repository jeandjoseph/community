
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'MyP@wO2022v'
GO

CREATE LOGIN Synapse_link_User WITH PASSWORD = 'MyP@wO2022v'
GO

CREATE USER Synapse_link_User FOR LOGIN Synapse_link_User
GO

EXEC sp_addrolemember 'db_datareader', 'Synapse_link_User';
GO