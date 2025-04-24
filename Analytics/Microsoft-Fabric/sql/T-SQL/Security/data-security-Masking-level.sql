/*
	**********************************************
            DATA MASKING SECURITY DEMO
  	**********************************************

    Definition: 
    Data masking creates a fake but realistic version of your organizational data. 
    The goal is to protect sensitive data while providing a functional alternative 
    when real data is not needed

    Benefits:
     - Enhanced Security: Reduces the risk of data breaches and insider threats1.
     - Compliance: Helps meet regulatory requirements for data protection
*/
--******* Data Masking *******
CREATE SCHEMA DataMasking; 
GO


CREATE TABLE DataMasking.Membership (
  FirstName varchar(100) MASKED WITH (FUNCTION = 'partial(1, "xxxxx", 1)') NULL,
  LastName varchar(100) NOT NULL,
  Phone varchar(12) MASKED WITH (FUNCTION = 'default()') NULL,
  Email varchar(100),
  DiscountCode smallint MASKED WITH (FUNCTION = 'random(1, 100)') NULL,
  BirthDay datetime2(3) MASKED WITH (FUNCTION = 'default()') NULL
);
GO

-- new need to modify
-- For Email
ALTER TABLE DataMasking.Membership
ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');
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



SELECT * FROM DataMasking.Membership
GO

-- unmask a column
GRANT UNMASK ON DataMasking.Membership(FirstName) TO [johndoe@yourdomain.com];  
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
