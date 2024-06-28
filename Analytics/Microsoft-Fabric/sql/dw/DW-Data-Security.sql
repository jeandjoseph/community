/*
	COLUMN LEVEL SECURITY DEMO
*/
/* Let us generate some data to demo Column Level Security */
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT 1 FROM sys.tables WHERE name ='Product' AND schema_id=schema_id('columnsecurity'))
DROP TABLE [columnsecurity].[Product]
GO

CREATE SCHEMA [columnsecurity]

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
REVOKE SELECT ON OBJECT::columnsecurity.Product FROM [email];  
GO  

-- Deny has enought access to overwrite share permission
DENY SELECT ON [columnsecurity].[Product] TO [email];
GO


-- Apply Colomn Level Security
GRANT SELECT ON [columnsecurity].[Product](
     [ProductID], [ProductSKU], [ProductCategory], [ItemGroup]
    ,[KitType], [Channels],[Demographic]   
    ) 
TO [email];
GO

--Clean Up
DROP TABLE [columnsecurity].[Product]

DROP SCHEMA  [columnsecurity]


--******* Data Masking *******
CREATE SCHEMA DataMasking; 
GO


CREATE TABLE DataMasking.Membership (
  FirstName varchar(100) MASKED WITH (FUNCTION = 'partial(1, "xxxxx", 1)') NULL,
  LastName varchar(100) NOT NULL,
  Phone varchar(12) MASKED WITH (FUNCTION = 'default()') NULL,
  Email varchar(100) MASKED WITH (FUNCTION = 'email()') NOT NULL,
  DiscountCode smallint MASKED WITH (FUNCTION = 'random(1, 100)') NULL,
  BirthDay datetime2(3) MASKED WITH (FUNCTION = 'default()') NULL
);
GO

select * from DataMasking.Membership


INSERT INTO DataMasking.Membership (FirstName, LastName, Phone, Email, DiscountCode, BirthDay) 
VALUES ('Roberto', 'Tamburello', '555.123.4567', 'RTamburello@contoso.com', 10, '1985-01-25 03:25:05');

INSERT INTO DataMasking.Membership (FirstName, LastName, Phone, Email, DiscountCode, BirthDay) 
VALUES ('Janice', 'Galvin', '555.123.4568', 'JGalvin@contoso.com.co', 5,'1990-05-14 11:30:00');

INSERT INTO DataMasking.Membership (FirstName, LastName, Phone, Email, DiscountCode, BirthDay) 
VALUES ('Shakti', 'Menon', '555.123.4570', 'SMenon@contoso.net', 50,'2004-02-29 14:20:10');

INSERT INTO DataMasking.Membership (FirstName, LastName, Phone, Email, DiscountCode, BirthDay) 
VALUES ('Zheng', 'Mu', '555.123.4569', 'ZMu@contoso.net', 40,'1990-03-01 06:00:00');
GO


-- unmask a column
GRANT UNMASK ON DataMasking.Membership(FirstName) TO [email];  
GO

-- Grant table level UNMASK permission
GRANT UNMASK ON DataMasking.Membership TO User_DataMasking;  


-- Grant schema level UNMASK permission 
GRANT UNMASK ON SCHEMA::DataMasking TO User_DataMasking;  
 

--Grant database level UNMASK permission 
GRANT UNMASK TO User_DataMasking;



--Clean
DROP TABLE DataMasking.Membership 

DROP SCHEMA DataMasking;



---***** Row Level Security
CREATE SCHEMA rowsecurity
GO

CREATE TABLE rowsecurity.Orders 
    (  
    OrderID int,  
    SalesRep varchar(128),  
    Product varchar(50),  
    Quantity smallint  
    );
GO

INSERT INTO rowsecurity.Orders  VALUES (1, 'email1', 'Valve', 5);
INSERT INTO rowsecurity.Orders  VALUES (2, 'email1', 'Wheel', 2);
INSERT INTO rowsecurity.Orders  VALUES (3, 'email1', 'Valve', 4);
INSERT INTO rowsecurity.Orders  VALUES (4, 'email2', 'Bracket', 2);
INSERT INTO rowsecurity.Orders  VALUES (5, 'email2', 'Wheel', 5);
INSERT INTO rowsecurity.Orders  VALUES (6, 'email2', 'Seat', 5);
GO


-- View the 6 rows in the table  
SELECT * FROM rowsecurity.Orders;
GO




GRANT SELECT ON rowsecurity.Orders TO [email1];  
GRANT SELECT ON rowsecurity.Orders TO [email2]; 
GO



CREATE SCHEMA Security;  
GO  

/*
Create a new schema, and an inline table-valued function. 
The function returns 1 when a row in the SalesRep column is the same as 
the user executing the query (@SalesRep = USER_NAME()) or 
if the user executing the query is the Manager user (USER_NAME() = 'Manager').
*/
CREATE FUNCTION Security.tvf_securitypredicate(@SalesRep AS nvarchar(50))  
    RETURNS TABLE  
WITH SCHEMABINDING  
AS  
    RETURN SELECT 1 AS tvf_securitypredicate_result
WHERE @SalesRep = USER_NAME() OR USER_NAME() = 'Manager';  
GO

-- still can see the data 
SELECT * FROM rowsecurity.Orders

delete from rowsecurity.Orders

/*
Create a security policy adding the function as a filter predicate. 
The state must be set to ON to enable the policy.
*/
CREATE SECURITY POLICY SalesFilter  
ADD FILTER PREDICATE Security.tvf_securitypredicate(SalesRep)
ON rowsecurity.Orders
WITH (STATE = ON);  
GO

/*
Allow SELECT permissions to the fn_securitypredicate function
*/
--GRANT SELECT ON Security.tvf_securitypredicate TO Manager;  
GRANT SELECT ON Security.tvf_securitypredicate TO [email1];  
GRANT SELECT ON Security.tvf_securitypredicate TO [email2];  
GO

-- As admin i cant see the data
SELECT * FROM rowsecurity.Orders

--Clean Up
DROP SECURITY POLICY SalesFilter;
DROP TABLE rowsecurity.Orders;
DROP FUNCTION Security.tvf_securitypredicate;
DROP SCHEMA Security;
DROP SCHEMA rowsecurity;

