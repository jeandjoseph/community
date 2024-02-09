CREATE USER Manager WITHOUT LOGIN;  
CREATE USER SalesRep1 WITHOUT LOGIN;  
CREATE USER SalesRep2 WITHOUT LOGIN;
GO

CREATE SCHEMA Sales
GO

CREATE TABLE Sales.Orders 
    (  
    OrderID int,  
    SalesRep nvarchar(50),  
    Product nvarchar(50),  
    Quantity smallint  
    );
GO

INSERT INTO Sales.Orders  VALUES (1, 'SalesRep1', 'Valve', 5);
INSERT INTO Sales.Orders  VALUES (2, 'SalesRep1', 'Wheel', 2);
INSERT INTO Sales.Orders  VALUES (3, 'SalesRep1', 'Valve', 4);
INSERT INTO Sales.Orders  VALUES (4, 'SalesRep2', 'Bracket', 2);
INSERT INTO Sales.Orders  VALUES (5, 'SalesRep2', 'Wheel', 5);
INSERT INTO Sales.Orders  VALUES (6, 'SalesRep2', 'Seat', 5);
GO


-- View the 6 rows in the table  
SELECT * FROM Sales.Orders;
GO



GRANT SELECT ON Sales.Orders TO Manager;  
GRANT SELECT ON Sales.Orders TO SalesRep1;  
GRANT SELECT ON Sales.Orders TO SalesRep2; 
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

/*
Create a security policy adding the function as a filter predicate. 
The state must be set to ON to enable the policy.
*/
CREATE SECURITY POLICY SalesFilter  
ADD FILTER PREDICATE Security.tvf_securitypredicate(SalesRep)
ON Sales.Orders
WITH (STATE = ON);  
GO

/*
Allow SELECT permissions to the fn_securitypredicate function
*/
GRANT SELECT ON Security.tvf_securitypredicate TO Manager;  
GRANT SELECT ON Security.tvf_securitypredicate TO SalesRep1;  
GRANT SELECT ON Security.tvf_securitypredicate TO SalesRep2;  
GO

/*
Now test the filtering predicate, by selected from the Sales table as each user.
*/

EXECUTE AS USER = 'SalesRep1';  
SELECT * FROM Sales.Orders;
REVERT;  
  
EXECUTE AS USER = 'SalesRep2';  
SELECT * FROM Sales.Orders;
REVERT;  
  
EXECUTE AS USER = 'Manager';  
SELECT * FROM Sales.Orders;
REVERT; 



DROP USER SalesRep1;
DROP USER SalesRep2;
DROP USER Manager;

DROP SECURITY POLICY SalesFilter;
DROP TABLE Sales.Orders;
DROP FUNCTION Security.tvf_securitypredicate;
DROP SCHEMA Security;
DROP SCHEMA Sales;