/*
	**********************************************
            COLUMN LEVEL SECURITY DEMO
  	**********************************************

    Definition: 
    CLS restricts access to individual columns in a table, rather than the entire table. 
    This is useful for protecting sensitive information like social security numbers, credit card details, 
    or personal addresses

    Benefits:
     - Granular Control: Provides fine-grained access control, enhancing data security13.
     - Compliance: Helps meet regulatory requirements by restricting access to sensitive data
*/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT 1 FROM sys.tables WHERE name ='Product' AND schema_id=schema_id('columnsecurity'))
DROP TABLE [columnsecurity].[Product]
GO

CREATE SCHEMA [columnsecurity]
GO



--Create table if exists
CREATE TABLE [columnsecurity].[Product](
	[ProductID] [int] NOT NULL,
	[ProductSKU] [VARCHAR](50) NOT NULL,
	[ProductName] [VARCHAR](50) NOT NULL,
	[ProductCategory] [VARCHAR](50) NOT NULL,
	[ItemGroup] [VARCHAR](50) NOT NULL,
	[KitType] [char](3) NOT NULL,
	[Channels] [INT] NOT NULL,
	[Demographic] [VARCHAR](50) NOT NULL,
	[RetailPrice] [DECIMAL](12,2) NOT NULL
) 
GO


INSERT INTO [columnsecurity].[Product]
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

-- Share Access all read access across all oibjects

-- run below script on ssms under johndoe credential
SELECT * FROM [columnsecurity].[Product] 
GO


-- Now let remove the read access against the product table
-- Revoke cannot ovevwrite share permission
REVOKE SELECT ON OBJECT::columnsecurity.Product FROM [demo.user@MngEnvMCAP017792.onmicrosoft.com];  
GO  

-- Deny has enought access to overwrite share permission
DENY SELECT ON [columnsecurity].[Product] TO [johndoe@yourdomain.com];
GO


-- Apply Colomn Level Security
GRANT SELECT ON [columnsecurity].[Product](
     [ProductID], [ProductSKU], [ProductCategory], [ItemGroup]
    ,[KitType], [Channels],[Demographic]   
    ) 
TO [johndoe@yourdomain.com];
GO


SELECT * FROM [columnsecurity].[Product] 
GO



SELECT [ProductID], [ProductSKU], [ProductCategory]
     , [ItemGroup],[KitType], [Channels],[Demographic]   
FROM [columnsecurity].[Product]
GO


--Clean Up
DROP TABLE [columnsecurity].[Product]

DROP SCHEMA  [columnsecurity]