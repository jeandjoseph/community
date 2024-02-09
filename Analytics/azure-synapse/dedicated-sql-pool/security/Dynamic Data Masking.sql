CREATE SCHEMA DataMasking; 
GO


CREATE TABLE DataMasking.Membership (
  MemberID int IDENTITY(1,1) NOT NULL,
  FirstName varchar(100) MASKED WITH (FUNCTION = 'partial(1, "xxxxx", 1)') NULL,
  LastName varchar(100) NOT NULL,
  Phone varchar(12) MASKED WITH (FUNCTION = 'default()') NULL,
  Email varchar(100) MASKED WITH (FUNCTION = 'email()') NOT NULL,
  DiscountCode smallint MASKED WITH (FUNCTION = 'random(1, 100)') NULL,
  BirthDay datetime MASKED WITH (FUNCTION = 'default()') NULL
);
GO



INSERT INTO DataMasking.Membership (FirstName, LastName, Phone, Email, DiscountCode, BirthDay) 
VALUES ('Roberto', 'Tamburello', '555.123.4567', 'RTamburello@contoso.com', 10, '1985-01-25 03:25:05');

INSERT INTO DataMasking.Membership (FirstName, LastName, Phone, Email, DiscountCode, BirthDay) 
VALUES ('Janice', 'Galvin', '555.123.4568', 'JGalvin@contoso.com.co', 5,'1990-05-14 11:30:00');

INSERT INTO DataMasking.Membership (FirstName, LastName, Phone, Email, DiscountCode, BirthDay) 
VALUES ('Shakti', 'Menon', '555.123.4570', 'SMenon@contoso.net', 50,'2004-02-29 14:20:10');

INSERT INTO DataMasking.Membership (FirstName, LastName, Phone, Email, DiscountCode, BirthDay) 
VALUES ('Zheng', 'Mu', '555.123.4569', 'ZMu@contoso.net', 40,'1990-03-01 06:00:00');
GO


select * from DataMasking.Membership

/* Let us create a new user to demo Column Level Security */
-- add user to role(s) in db 

-- Switch to MASTER DB
-- DROP LOGIN User_DataMasking
CREATE LOGIN [User_DataMasking]
WITH PASSWORD = 'Pa$$W@rD!1' 
GO

-- Creating User and map it to the login
-- Switch to USER DB
-- DROP USER User_DataMasking
CREATE USER [User_DataMasking] 
FOR LOGIN [User_DataMasking] 
WITH DEFAULT_SCHEMA = dbo; 
GO


-- Give it Read only access
EXEC sp_addrolemember 'db_datareader', 'User_DataMasking';
GO

-- Our data

EXECUTE AS USER = 'User_DataMasking';  
  SELECT * FROM DataMasking.Membership
REVERT;


--Grant column level UNMASK permission to ServiceAttendant  
GRANT UNMASK ON DataMasking.Membership(FirstName) TO User_DataMasking;  


EXECUTE AS USER = 'User_DataMasking';  
  SELECT * FROM DataMasking.Membership
REVERT;


-- Grant table level UNMASK permission to ServiceLead  
GRANT UNMASK ON DataMasking.Membership TO User_DataMasking;  


EXECUTE AS USER = 'User_DataMasking';  
  SELECT * FROM DataMasking.Membership
REVERT;

-- Grant schema level UNMASK permission to ServiceManager  
GRANT UNMASK ON SCHEMA::DataMasking TO User_DataMasking;  
 

--Grant database level UNMASK permission to ServiceHead;  
GRANT UNMASK TO User_DataMasking;


-- Revoke data masking at the column level
REVOKE UNMASK ON DataMasking.Membership(FirstName) FROM User_DataMasking; 
GO

EXECUTE AS USER = 'User_DataMasking';  
  SELECT * FROM DataMasking.Membership
REVERT;

-- Revoke data masking at the table level
REVOKE UNMASK ON DataMasking.Membership FROM User_DataMasking; 


-- Revoke data masking at the schema level
REVOKE UNMASK ON SCHEMA::DataMasking FROM User_DataMasking; 


-- Revoke data masking at the schema level
REVOKE UNMASK FROM User_DataMasking; 


EXECUTE AS USER = 'User_DataMasking';  
  SELECT * FROM DataMasking.Membership
REVERT;


-- User with high access will still be able to see your data
SELECT * FROM DataMasking.Membership


--Clean
DROP TABLE DataMasking.Membership 

DROP SCHEMA DataMasking;