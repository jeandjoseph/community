/*
    https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/sql-data-warehouse-table-constraints

    https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/sql-data-warehouse-tables-overview
*/


-- Create table DemoConstraint
IF OBJECT_ID('DemoConstraint') IS NOT NULL
DROP TABLE DemoConstraint
GO




CREATE TABLE DemoConstraint (
    Id INT PRIMARY KEY NOT NULL
   ,ColValue INT
) 
WITH (DISTRIBUTION = ROUND_ROBIN)
GO








-- NOT ENFORCED   
CREATE TABLE DemoConstraint (
    Id INT PRIMARY KEY NOT ENFORCED
   ,ColValue INT
) 
WITH (DISTRIBUTION = ROUND_ROBIN)
GO











CREATE TABLE DemoConstraint (
    Id INT PRIMARY KEY NONCLUSTERED NOT ENFORCED
   ,ColValue INT
) 
WITH (DISTRIBUTION = ROUND_ROBIN)
GO

-- Insert values to table.

INSERT INTO DemoConstraint VALUES (1, 100)
INSERT INTO DemoConstraint VALUES (1, 1000)
INSERT INTO DemoConstraint VALUES (2, 200)
INSERT INTO DemoConstraint VALUES (3, 300)
INSERT INTO DemoConstraint VALUES (4, 400)
GO









-- Run this query.  No primary key or unique constraint.  4 rows returned. Correct result.
SELECT * FROM DemoConstraint
GO







--CREATE IDENTITY
-- Create table DemoConstraint
IF OBJECT_ID('DemoIdentity') IS NOT NULL
DROP TABLE DemoIdentity
GO



CREATE TABLE DemoIdentity (
    Id INT IDENTITY NOT NULL
   ,ColValue VARCHAR(5) DEFAULT 'TEST'
) 
WITH (DISTRIBUTION = ROUND_ROBIN)
GO

INSERT INTO DemoIdentity (ColValue) VALUES ('test')
GO

INSERT INTO DemoIdentity (ColValue) VALUES ('now')
GO


SELECT * FROM DemoIdentity
GO