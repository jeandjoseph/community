from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()

# Access an environment variable
sql_script_files_dir = os.getenv('sql_script_files_dir')
print(sql_script_files_dir)

# Import the CodeGenerator module
import CodeGenerator 



# T-SQL coder agent system message
tsql_coder_agent_system_message = """
    Act as a T-SQL Developer expert. Your task is to write T-SQL scripts to create database objects and 
    import a CSV file with headers from a specified local directory into a SQL Server Database.
    Please refrain from providing system details, instructions, or suggestions.
    schema:
    {'ProductId':'INT', 
    'ProductName':'VARCHAR(50)',
    'ProductType':'VARCHAR(30) ',
    'Color':'VARCHAR(15)',
    'OrderQuantity':'INT',
    'Size':'VARCHAR(15)',
    'Category':'VARCHAR(15)',
    'Country':'VARCHAR(30)',
    'Date':'DATE',
    'PurchasePrice':'DECIMAL(18,2)',
    'SellingPrice':'DECIMAL(18,2)'
    }    
    """

# Python coder agent system message
python_coder_agent_system_message = F"""
    Act as a Python Developer expert. Your task is to write a Python script to save the output generated by 
    the tsql_coder_agent into "{sql_script_files_dir}" repository. 
    Ensure that the saved scripts are properly categorized and easily retrievable. Please refrain from providing 
    system details, instructions, or suggestions.
    """

# Define the user message for generating T-SQL scripts
codegenerator_user_message = """
1. generate a t-sql script to dynamically create a schemas named stg if not exists.
2. generate a t-sql script to dynamically create a schemas named prd if not exists.
3. generate a t-sql script to dynamically create a schemas named etl_process if not exists.
4. generate a t-sql script to create a staging table named stg.salestmp with all columns as varchar(255).
5. generate a t-sql script to create a table named prd.sales with the correct schema definition for each column.
6. Provide a tsql script to create the etl_process.etl_process_log table if it does not already exist 
   with the following fields name id integer auto generated identifier without primary key, processname 
   varchar 50 lenght, processtype varchar 30 lenght, objectname varchar 50 lenght, starttime and endtime: DATETIME
7. Provide a tsql script to create the etl_process.error_log table if it does not already exist with the following 
   fields name id integer auto generated identifier without primary key, processid integer, processname varchar, 
   objectname varchar 50 lenght, errormsg varchar, starttime and endtime DATETIME
8. Create a T-SQL stored procedure named etl_process.usp_get_process_log if it does not already exist with the 
   following input parameters: processname of type VARCHAR with a length of 50, processtype of type VARCHAR with a 
   length of 30, objectname of type VARCHAR with a length of 50, and starttime and endtime of type DATETIME. 
   This stored procedure should insert data into an existing table called etl_process.etl_process_log table. 
   Please refrain from providing system details, instructions, or suggestions
9. Create a T-sQL stored procedure named etl_process.usp_get_error_log if it does not already exist with the 
   following input parameters: processname VARCHAR (50), objectname VARCHAR (50), errormsg VARCHAR(MAX), and 
   starttime and endtime of type DATETIME. This stored procedure should insert data into  an existing table 
   called etl_process.error_log table.
10. Provide only the table truncation and bulk load T-SQL scripts, excluding the create table statement. 
    Ensure the truncation script is at the beginning. Convert this code into a stored procedure called 
    'etl_process.usp_BulkInsertFromCSV' that performs a bulk insert from a CSV file into a table with a 
    non-default schema. The procedure should accept three parameters: table name, file path, and error file path. 
    Use the following bulk insert options: first row = 2, field terminator = comma, row terminator = newline, 
    error file = error file path. Use try-catch blocks to handle errors and log details using 
    'etl_process.usp_get_process_log' and 'etl_process.usp_get_error_log'. Declare date variables before and after 
    SQL execution to track execution time. Do not use QUOTENAME. Make sure to drop the store procedure if it exists
    and the truncate and builk load should be a dynamic tsql.
11. provide just the insert t-sql script to load the data from stg.salestmp into prd.sales without create table statement. 
    keep in mind stg.salestmp has all columns as varchar(255) then Convert this code into a SQL Server stored procedure called
    'etl_process.usp_load_bicycle_staging_data'. Use try-catch blocks to handle errors and log details using 
    'etl_process.usp_get_process_log' and 'etl_process.usp_get_error_log'. Declare date variables before and after 
    SQL execution to track execution time. Do not use QUOTENAME. Refrain from providing system details, instructions, or suggestions.
    Make sure to drop the store procedure if it exists and removes carriage return and line feed characters from the SellingPrice column 
    and casts the result as a decimal with a precision of 18 and a scale of 2.
12. generate a script to create a stored procedure named prd.usp_GetTotalSalesByCountries with an input parameter called country 
    to calculate the total PurchasePrice by country, ProductName, and ProductType, ordered by total PurchasePrice in descending order. 
    The input parameter country should be of type varchar(50) and default to all countries but the user should be able to overwrite the default value.

Please save the T-SQL files in the following order:
   schema_stg.sql
   schema_prd.sql
   schema_etl_process.sql
   table_stg_salestmp.sql
   table_prd_sales.sql
   table_etl_process.etl_process_log.sql
   table_etl_process.error_log.sql
   usp_etl_process.usp_get_process_log.sql
   usp_etl_process.usp_get_error_log.sql
   usp_etl_process.usp_BulkInsertFromCSV.sql
   usp_load_staging_data_table.sql
   prd.usp_GetTotalSalesByCountries.sql
"""

# Initialize the CodeGeneratorManager with system messages
autogen_setup = CodeGenerator.CodeGeneratorManager(
    tsql_coder_agent_system_message=tsql_coder_agent_system_message,
    python_coder_agent_system_message=python_coder_agent_system_message
)

# Initiate a chat with the agent to generate T-SQL scripts
autogen_setup.manager.groupchat.agents[2].initiate_chat(
    autogen_setup.manager,
    message=codegenerator_user_message,
    clear_history=True,
    cache=None,
    save_files=True
)