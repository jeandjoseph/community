    /*
DROP SECURITY POLICY SalesFilter;
DROP FUNCTION rls.tvf_securitypredicate;
DROP SCHEMA rls;
*/
-- Drop table if exists
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Product' AND schema_id = schema_id('base'))
DROP TABLE [base].[Product]
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Product' AND schema_id = schema_id('clone'))
DROP TABLE [clone].[Product]
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Product_cls' AND schema_id = schema_id('clone'))
DROP TABLE [clone].[Product_cls]
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Product_rls' AND schema_id = schema_id('clone'))
DROP TABLE [clone].[Product_rls]
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Product_dm' AND schema_id = schema_id('clone'))
DROP TABLE [clone].[Product_dm]
GO
-- Drop schema if exists
IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'base')
DROP SCHEMA [base]
GO

IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'clone')
DROP SCHEMA [clone]
GO

-- Create schema
CREATE SCHEMA [base]
GO

-- Create schema
CREATE SCHEMA [clone]
GO


--Create table if exists
CREATE TABLE [base].[Product](
	[ProductID] [int] NOT NULL,
	[ProductSKU] [VARCHAR](50) NOT NULL,
	[ProductName] [VARCHAR](50) NOT NULL,
	[ProductCategory] [VARCHAR](50) NOT NULL,
	[ItemGroup] [VARCHAR](50) NOT NULL,
	[KitType] [char](3) NOT NULL,
	[Channels] [INT] NOT NULL,
	[Demographic] [VARCHAR](50) NOT NULL,
	[RetailPrice] [DECIMAL](12,2) NOT NULL,
    [SalesRep] VARCHAR(50) NOT NULL
) 
GO

-- Insert Data
INSERT INTO [base].[Product]
SELECT 1,'1010-GL120-3C','Trainer - Tailspin GL-120','Glider','Airplane','RTF',3,'Novice',79.15,'email1' UNION
SELECT 2,'1010-GL155-4C','Trainer - Tailspin GL-155','Glider','Airplane','RTF',4,'Intermediate',216.65,'email1' UNION
SELECT 3,'2030-PCUB-3C','Piper Cub 3 Channel','Trainer','Airplane','RTF',3,'Beginner',84.65,'email1' UNION
SELECT 4,'2030-PCUB-4C','Piper Cub 4 Channel','Trainer','Airplane','RTF',4,'Intermediate',193.55,'email1' UNION
SELECT 5,'2050-P47-4C','P47 4 Channel','Warbird','Airplane','RTF',4,'Intermediate',98.95, 'email2' UNION
SELECT 6,'2050-P47-5C','P47 5 Channel','Warbird','Airplane','RTF',5,'Advanced',274.95, 'email2' UNION
SELECT 7,'2055-P51-5C','P51','Warbird','Airplane','RTF',5,'Advanced',274.95, 'email3' UNION
SELECT 8,'2060-SKYT-5C','SkyTrainer','Trainer','Airplane','RTF',5,'Advanced',179.25, 'email3' UNION
SELECT 9,'3010-TAVM2-11-3C','Tailspin Aviator Mk2-11','Glider','Airplane','KIT',3,'Intermediate',169.35, 'email3' UNION
SELECT 10,'3010-TAVM2-12-4C','Tailspin Aviator Mk2-12','Trainer','Airplane','KIT',4,'Intermediate',188.05, 'email3' 


-- Validate data has been loaded
SELECT TOP (5) * FROM [base].[Product]
GO


-- Clone Table: The ‘Product’ table from the ‘base’ schema is cloned into the ‘clone’ schema.
CREATE TABLE clone.Product AS CLONE OF [base].[Product];
GO

-- Validate that the table has been cloned and is the same as the source.
SELECT COUNT(1) AS base FROM [base].[Product]
GO

SELECT COUNT(1) AS clone FROM [clone].[Product]
GO

-- Validate data has been loaded
SELECT TOP (5) * FROM [clone].[Product]
GO


-- FYI - there are two independent tables.
INSERT INTO [base].[Product]
SELECT 11,'3010-TAVM2-15-4C','Tailspin Aviator Mk2-15','Trainer','Airplane','KIT',4,'Intermediate',204.55, 'jeangarellard@MngEnvMCAP734805.onmicrosoft.com' UNION
SELECT 12,'3010-TWAR-BM32-5C','Tailspin Warbird BM32','Warbird','Airplane','KIT',5,'Advanced',349.75, 'johndoe@mngenvmcap734805.onmicrosoft.com' UNION
SELECT 13,'3050-THeli-Co-Ax Pro-4C','Tailspin Heli - Co-Ax Pro Mk I - 4ch','Co-Axial','Helicopter','KIT',4,'Intermediate',389.95,'jeangarellard@MngEnvMCAP734805.onmicrosoft.com'
GO

SELECT COUNT(1) AS base FROM [base].[Product]
GO

SELECT COUNT(1) AS clone FROM [clone].[Product]
GO


INSERT INTO [clone].[Product]
SELECT 14,'3050-THeli-MaxPro-6C','Tailspin Heli - Max Pro Flight - 6ch','Collective pitch','Helicopter','KIT',6,'Professional',579.55,'jeangarellard@MngEnvMCAP734805.onmicrosoft.com' UNION
SELECT 15,'3050-THeli-Pro-5C','Tailspin Heli - Pro Mk III - 5ch','Fixed pitch','Helicopter','KIT',5,'Advanced',401.95,'jeangarellard@MngEnvMCAP734805.onmicrosoft.com' 
GO

-- Validate
SELECT COUNT(1) AS base FROM [base].[Product]
GO

SELECT COUNT(1) AS clone FROM [clone].[Product]
GO


-- Disaster Recovery
SELECT (GETDATE())
-- TIME example : 2024-03-31T16:35:34.937
-- TIME: 2024-06-26T19:17:12.3770000

--***** RESTORE DML OPERATION *****---
DELETE FROM [base].[Product]

SELECT * FROM [base].[Product]

CREATE TABLE clone.Product_restored AS CLONE OF [base].[Product] AT '2024-06-26T19:17:12.377';
GO

SELECT * FROM  clone.Product_restored


INSERT INTO [base].[Product]
SELECT * FROM  clone.Product_restored

SELECT * FROM [base].[Product]
GO

DROP TABLE clone.Product_restored


--***** RESTORE DDL OPERATION *****---
-- NO DDL OPERATIONS ARE SUPPORTED

-- Apply Colomn Level Security
-- NO access on [ProductName], [RetailPrice], [SalesPrep]
GRANT SELECT TO [email];
GO

DENY SELECT ON [base].[Product] TO [email];
GO

GRANT SELECT ON [base].[Product](
     [ProductID], [ProductSKU], [ProductCategory], [ItemGroup]
    ,[KitType], [Channels],[Demographic], [SalesRep]   
    ) 
TO [johndoe@mngenvmcap734805.onmicrosoft.com];
GO

CREATE TABLE clone.Product_cls AS CLONE OF [base].[Product];
GO

SELECT TOP (3) * FROM clone.Product_cls


-- ******* Apply Colomn Level Security ******
CREATE SCHEMA rls;  
GO  

CREATE FUNCTION rls.tvf_securitypredicate(@SalesRep AS varchar(50))  
    RETURNS TABLE  
WITH SCHEMABINDING  
AS  
    RETURN SELECT 1 AS tvf_securitypredicate_result
WHERE @SalesRep = USER_NAME() OR USER_NAME() = 'Manager';  
GO

-- still can see the data 
SELECT * FROM [base].[Product]


CREATE SECURITY POLICY SalesFilter  
ADD FILTER PREDICATE rls.tvf_securitypredicate(SalesRep)
ON [base].[Product]
WITH (STATE = ON);  
GO

GRANT SELECT ON rls.tvf_securitypredicate TO [email1];  
GRANT SELECT ON rls.tvf_securitypredicate TO [email2];  
GO


CREATE TABLE clone.Product_rls AS CLONE OF [base].[Product];
GO

SELECT * FROM clone.Product_rls

--Clean Up
DROP SECURITY POLICY SalesFilter;
DROP TABLE clone.Product_rls;
DROP FUNCTION rls.tvf_securitypredicate;
DROP SCHEMA rls;

SELECT * FROM [base].[Product]
-- Apply Colomn Data Masking Security
-- Add data masking to the 'ProductName' field
ALTER TABLE [base].[Product]
ALTER COLUMN [ProductName] ADD MASKED WITH (FUNCTION = 'partial(1,"XXXXXXX",0)');

-- Add data masking to the 'RetailPrice' field
ALTER TABLE [base].[Product]
ALTER COLUMN [RetailPrice] ADD MASKED WITH (FUNCTION = 'default()');

-- Add data masking to the 'SalesRep' field
ALTER TABLE [base].[Product]
ALTER COLUMN [SalesRep] ADD MASKED WITH (FUNCTION = 'email()');
GO

-- Remove Column Level Security
GRANT SELECT ON [base].[Product] TO [email];
GO

CREATE TABLE clone.Product_dm AS CLONE OF [base].[Product];
GO
