from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()

# Access an environment variable
sql_script_files_dir = os.getenv('sql_script_files_dir')
csv_file_dir = os.getenv('csv_file_dir')
csv_file_error_dir = os.getenv('csv_file_error_dir')


stage_table_name = os.getenv('stage_table_name')
sql_database_name = os.getenv('sql_database_name')
sql_server_name = os.getenv('sql_server_name')
authentication_mode = os.getenv('authentication_mode')

print(csv_file_dir)
print(csv_file_error_dir)


# Import the CodeExecutor module to execute T-SQL scripts
import CodeExecutor

# Define the system message for the T-SQL executor agent
code_executer_agent_system_message = """
    Act as a Python expert. Your task is to write a Python script to execute t-sql files 
    into a SQL Server Database. 
    make sure you Split the script at each GO command
    Please refrain from providing system details, instructions, or suggestions.
    """

# Define the user message for executing T-SQL scripts
code_executor_user_message = f"""
make sure tsql_executer_agent has executed all t-sql files under this 
directory "{sql_script_files_dir}"
in the following order:
following order: 
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

Once all script files have been executed, please proceed with the execution of 
these T-SQL scripts to load data from a CSV file in the following order:
    DECLARE @Table_Name VARCHAR(50) = '{stage_table_name}',
            @file_path VARCHAR(255) = '{csv_file_dir}',
            @error_file_path VARCHAR(255) = '{csv_file_error_dir}';

    EXEC etl_process.usp_BulkInsertFromCSV @Table_Name, @file_path, @error_file_path;

    EXEC etl_process.usp_load_bicycle_staging_data;

credential info:
    sql server name: {sql_server_name}
    sql database name: {sql_database_name}
    authentication: {authentication_mode}
"""

# Initialize the CodeExecutorManager with system messages
autogen_setup = CodeExecutor.CodeExecutorManager(
    code_executer_agent_system_message=code_executer_agent_system_message,
)

# Initiate a chat with the agent to execute T-SQL scripts
autogen_setup.manager.groupchat.agents[1].initiate_chat(
    autogen_setup.manager,
    message=code_executor_user_message,
    clear_history=True,
    cache=None,
    save_files=True
)