/*
	**********************************************
            ROW LEVEL SECURITY DEMO
  	**********************************************

    Definition: 
    RLS restricts access to rows in a table based on the user’s identity or execution context. 
    This ensures that users can only access the data they are authorized to view

    Benefits:
     - Enhanced Security: Provides fine-grained access control, ensuring users only see data relevant to them1.
     - Simplified Application Logic: By handling access control at the database level, you reduce the complexity 
       of your application code
*/
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

INSERT INTO rowsecurity.Orders  VALUES (1, 'johndoe@yourdomain.com', 'Valve', 5);
INSERT INTO rowsecurity.Orders  VALUES (2, 'johndoe@yourdomain.com', 'Wheel', 2);
INSERT INTO rowsecurity.Orders  VALUES (3, 'johndoe@yourdomain.com', 'Valve', 4);
INSERT INTO rowsecurity.Orders  VALUES (4, 'jeangarellard@yourdomain.com', 'Bracket', 2);
INSERT INTO rowsecurity.Orders  VALUES (5, 'jeangarellard@yourdomain.com', 'Wheel', 5);
INSERT INTO rowsecurity.Orders  VALUES (6, 'jeangarellard@yourdomain.com', 'Seat', 5);
GO


-- View the 6 rows in the table  
SELECT * FROM rowsecurity.Orders;
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
GRANT SELECT ON Security.tvf_securitypredicate TO [johndoe@yourdomain.com];  
--GRANT SELECT ON Security.tvf_securitypredicate TO [jeangarellard@yourdomain.com];  
GO

-- As admin i cant see the data
SELECT * FROM rowsecurity.Orders

DELETE FROM rowsecurity.Orders
--Clean Up
DROP SECURITY POLICY SalesFilter;
DROP TABLE rowsecurity.Orders;
DROP FUNCTION Security.tvf_securitypredicate;
DROP SCHEMA Security;
DROP SCHEMA rowsecurity;
