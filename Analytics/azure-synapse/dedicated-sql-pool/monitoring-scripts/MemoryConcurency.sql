/* View the resource classes

    Resource classes are implemented as pre-defined database roles. 
    There are two types of resource classes: dynamic and static.

    https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/resource-classes-for-workload-management
*/

SELECT name--,*
FROM sys.database_principals
WHERE name LIKE '%rc%' AND type_desc = 'DATABASE_ROLE';


/*Change a user's resource class
    Resource classes are implemented by assigning users to database roles. 
    When a user runs a query, the query runs with the user's resource class. 
    For example, if a user is a member of the staticrc10 database role, 
    their queries run with small amounts of memory. 
    If a database user is a member of the xlargerc or staticrc80 database roles, their queries run with large amounts of memory.
*/
EXEC sp_addrolemember 'largerc', 'loaduser';
GO


/*Decrease the resource class
    use sp_droprolemember. If 'loaduser' is not a member or any other resource classes, 
    they go into the default smallrc resource class with a 3% memory grant.
*/
EXEC sp_droprolemember 'largerc', 'loaduser';
GO