/*
	COLUMN LEVEL SECURITY DEMO
*/
/* Let us generate some data to demo Column Level Security */
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT 1 FROM sys.tables WHERE name ='Product' AND schema_id=schema_id('dbo'))
DROP TABLE [dbo].[Product]
GO


--Create table if exists
CREATE TABLE [dbo].[Product](
	[ProductID] [int] NOT NULL,
	[ProductSKU] [nvarchar](50) NOT NULL,
	[ProductName] [nvarchar](50) NOT NULL,
	[ProductCategory] [nvarchar](50) NOT NULL,
	[ItemGroup] [nvarchar](50) NOT NULL,
	[KitType] [nchar](3) NOT NULL,
	[Channels] [tinyint] NOT NULL,
	[Demographic] [nvarchar](50) NOT NULL,
	[RetailPrice] [money] NOT NULL
) 
GO


INSERT INTO [dbo].[Product]
SELECT 1,'1010-GL120-3C','Trainer - Tailspin GL-120','Glider','Airplane','RTF',3,'Novice',79.15 UNION
SELECT 2,'1010-GL155-4C','Trainer - Tailspin GL-155','Glider','Airplane','RTF',4,'Intermediate',216.65 UNION
SELECT 3,'2030-PCUB-3C','Piper Cub 3 Channel','Trainer','Airplane','RTF',3,'Beginner',84.65 UNION
SELECT 4,'2030-PCUB-4C','Piper Cub 4 Channel','Trainer','Airplane','RTF',4,'Intermediate',193.55 UNION
SELECT 5,'2050-P47-4C','P47 4 Channel','Warbird','Airplane','RTF',4,'Intermediate',98.95 UNION
SELECT 6,'2050-P47-5C','P47 5 Channel','Warbird','Airplane','RTF',5,'Advanced',274.95 UNION
SELECT 7,'2055-P51-5C','P51','Warbird','Airplane','RTF',5,'Advanced',274.95 UNION
SELECT 8,'2060-SKYT-5C','SkyTrainer','Trainer','Airplane','RTF',5,'Advanced',179.25 UNION
SELECT 9,'3010-TAVM2-11-3C','Tailspin Aviator Mk2-11','Glider','Airplane','KIT',3,'Intermediate',169.35 UNION
SELECT 10,'3010-TAVM2-12-4C','Tailspin Aviator Mk2-12','Trainer','Airplane','KIT',4,'Intermediate',188.05 UNION
SELECT 11,'3010-TAVM2-15-4C','Tailspin Aviator Mk2-15','Trainer','Airplane','KIT',4,'Intermediate',204.55 UNION
SELECT 12,'3010-TWAR-BM32-5C','Tailspin Warbird BM32','Warbird','Airplane','KIT',5,'Advanced',349.75 UNION
SELECT 13,'3050-THeli-Co-Ax Pro-4C','Tailspin Heli - Co-Ax Pro Mk I - 4ch','Co-Axial','Helicopter','KIT',4,'Intermediate',389.95 UNION
SELECT 14,'3050-THeli-MaxPro-6C','Tailspin Heli - Max Pro Flight - 6ch','Collective pitch','Helicopter','KIT',6,'Professional',579.55 UNION
SELECT 15,'3050-THeli-Pro-5C','Tailspin Heli - Pro Mk III - 5ch','Fixed pitch','Helicopter','KIT',5,'Advanced',401.95 UNION
SELECT 16,'4010-3CAX-B-3C','3CAX-B Helicopter','Co-Axial','Helicopter','RTF',3,'Novice',63.55 UNION
SELECT 17,'4010-3CFP-I-3C','3CFP-I Helicopter','Fixed pitch','Helicopter','RTF',3,'Beginner',149.95 UNION
SELECT 18,'4030-4CAX-B-4C','4CAX-B Helicopter','Co-Axial','Helicopter','RTF',4,'Intermediate',151.15 UNION
SELECT 19,'4030-4CFP-I-4C','4CFP-I Helicopter','Fixed pitch','Helicopter','RTF',4,'Beginner',176.35 UNION
SELECT 20,'4040-6CCP-A-6C','6CCP-A Helicopter','Collective pitch','Helicopter','RTF',6,'Professional',239.95 
GO

SELECT * FROM [dbo].[Product]
GO



/* Let us create a new user to demo Column Level Security */
-- add user to role(s) in db 

-- Switch to MASTER DB
-- DROP LOGIN ColomnLevelSecurity
CREATE LOGIN [ColomnLevelSecurity]
WITH PASSWORD = 'Pa$$W@rD!1' 
GO

-- Creating User and map it to the login
-- Switch to USER DB
-- DROP USER ColomnLevelSecurity
CREATE USER [ColomnLevelSecurity] 
FOR LOGIN [ColomnLevelSecurity] 
WITH DEFAULT_SCHEMA = dbo; 
GO


-- Our data

SELECT * FROM [dbo].[Product]
GO


-- ColomnLevelSecurity cant read ProductName and RetailPrice
GRANT SELECT ON [dbo].[Product](
     [ProductID], [ProductSKU], [ProductCategory], [ItemGroup]
    ,[KitType], [Channels],[Demographic]   
    ) 
TO [ColomnLevelSecurity];
GO


-- Execute as ColomnLevelSecurity user id
EXECUTE AS USER = 'ColomnLevelSecurity';  
	SELECT [ProductID], [ProductSKU], [ProductCategory], [ItemGroup]
		,[KitType], [Channels],[Demographic]  
	FROM [dbo].[Product]
REVERT;


-- Can ColomnLevelSecurity user id query the whole table
EXECUTE AS USER = 'ColomnLevelSecurity';  
	SELECT *  
	FROM [dbo].[Product]
REVERT;



-- Will this access overwrite the Column Security feature
-- Any idea?
EXEC sp_addrolemember 'db_datareader', 'ColomnLevelSecurity';
GO



-- after sp_addrolemember
-- Can ColomnLevelSecurity user id query the whole table
EXECUTE AS USER = 'ColomnLevelSecurity';  
	SELECT *  
	FROM [dbo].[Product]
REVERT;


-- remove db_datareader access
EXEC sp_droprolemember  'db_datareader', 'ColomnLevelSecurity';
GO


-- after sp_droprolemember
-- ColomnLevelSecurity user id cant query the whole table
EXECUTE AS USER = 'ColomnLevelSecurity';  
	SELECT *  
	FROM [dbo].[Product]
REVERT;



-- Let us bring this access back
EXEC sp_addrolemember 'db_datareader', 'ColomnLevelSecurity';
GO

-- ColomnLevelSecurity user id still can query the whole table
EXECUTE AS USER = 'ColomnLevelSecurity';  
	SELECT *  
	FROM [dbo].[Product]
REVERT;

-- REVOKE
REVOKE SELECT ON OBJECT::dbo.Product FROM ColomnLevelSecurity;  
GO  

-- after REVOKE
-- ColomnLevelSecurity user id still can query the whole table
EXECUTE AS USER = 'ColomnLevelSecurity';  
	SELECT *  
	FROM [dbo].[Product]
REVERT;




/*
-- create SQL auth login from master 
-- DROP LOGIN dp203demolab
CREATE LOGIN [dp203demolab]
WITH PASSWORD = 'Pa$$W@rD!1' 
GO


--Switch to user db
-- select your db in the dropdown and create a user mapped to a login 
CREATE USER [dp203demolab] 
FOR LOGIN [dp203demolab] 
WITH DEFAULT_SCHEMA = dbo; 
GO


-- add user to role(s) in db 
EXEC sp_addrolemember 'db_owner', 'dp203demolab';
GO



 
--  Now let us query the data 
--  Connect to SSMS using the SecurityLevelSecurity credential
SELECT [ProductID], [ProductSKU], [ProductCategory], [ItemGroup]
    ,[KitType], [Channels],[Demographic]  
FROM [dbo].[Product]
GO
*/








