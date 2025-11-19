import os
import logging
import pyodbc
from dotenv import load_dotenv
from autogen_ext.models.openai import AzureOpenAIChatCompletionClient
from autogen_agentchat.agents import AssistantAgent, CodeExecutorAgent
from autogen_agentchat.teams import RoundRobinGroupChat
from autogen_agentchat.conditions import TextMentionTermination
from autogen_ext.code_executors.local import LocalCommandLineCodeExecutor
from autogen_core.tools import FunctionTool
from autogen_agentchat.agents._code_executor_agent import ApprovalResponse

class SQLAgentExecutor:
    sql_folder="./sql_scripts"
    def __init__(self, sql_folder="sql_scripts"):
        # Load environment variables
        load_dotenv()
        self.sql_folder = sql_folder
        self.AZURE_SQL_CONN = os.getenv("AZURE_SQL_CONNECTION_STRING")
        self.AZURE_DEPLOYMENT = os.getenv("MODEL")
        self.AZURE_API_KEY = os.getenv("API_KEY")
        self.AZURE_ENDPOINT = os.getenv("BASE_URL")
        self.AZURE_API_VERSION = os.getenv("API_VERSION")

        logging.disable(logging.CRITICAL)

        # Initialize Azure OpenAI client
        self.llm_client = AzureOpenAIChatCompletionClient(
            azure_deployment=self.AZURE_DEPLOYMENT,
            azure_endpoint=self.AZURE_ENDPOINT,
            model=self.AZURE_DEPLOYMENT,
            api_version=self.AZURE_API_VERSION,
            api_key=self.AZURE_API_KEY,
        )

        # Create SQL execution tool
        self.execute_sql_tool = FunctionTool(
            name="execute_sql_script",
            description="Executes a SQL script on Azure SQL Database",
            func=self.execute_sql_script
        )

        # Define system messages
        self.system_message_text = """
        You are an expert of Python and T-SQL.
        Your task to use 'execute_sql_script' tool to ONLY READ EACH SQL file in the following order:
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
        Return all scripts in a **single Python dictionary** where keys are filenames and values are the SQL script text.
        Wrap the entire dictionary in a code block format like this:
        ```python
        # Example:
        ``` .
        Then end with 'done'.
        """

        # Initialize agents
        self.assistant = AssistantAgent(
            name="assistant",
            model_client=self.llm_client,
            tools=[self.execute_sql_tool],
            system_message=self.system_message_text
        )

        self.executor = CodeExecutorAgent(
            name="executor",
            code_executor=LocalCommandLineCodeExecutor(work_dir=self.sql_folder),
            system_message=(
                "You are a shell command executor. Only run commands inside markdown code blocks like ```sh ... ``` "
                "when explicitly required (e.g., saving files, listing directory). "
                "Do NOT attempt to execute T-SQL scripts. If no shell command is needed, respond with 'done'."
            ),
            approval_func=lambda code: ApprovalResponse(approved=True)
        )

        # Create team
        self.team = RoundRobinGroupChat(
            participants=[self.assistant, self.executor],
            max_turns=30,
            termination_condition=TextMentionTermination("done")
        )

    def execute_sql_script(self, file_path: str):
        """Executes a SQL script from the sql_folder on Azure SQL Database."""
        try:
            full_path = os.path.join(self.sql_folder, file_path)
            if not os.path.exists(full_path):
                return f"❌ File not found: {full_path}"

            conn = pyodbc.connect(self.AZURE_SQL_CONN)
            cursor = conn.cursor()

            with open(full_path, 'r', encoding='utf-8') as f:
                sql_script = f.read()

            # Split by GO and execute each batch
            batches = [batch.strip() for batch in sql_script.split("GO") if batch.strip()]
            for batch in batches:
                cursor.execute(batch)

            conn.commit()
            cursor.close()
            conn.close()
            return f"✅ Executed successfully: {full_path}"
        except Exception as e:
            logging.error(f"❌ Error executing {file_path}: {e}")
            return f"❌ Failed to execute {file_path}: {e}"
