from autogen_agentchat.base import TaskResult  # Represents the final result of a task
from autogen_agentchat.messages import TextMessage, BaseMessage  # Message types for streaming responses
import asyncio
import re
import os
from dotenv import load_dotenv
load_dotenv()
# -------------------------------
# Utility function: Read SQL prompt from file
# -------------------------------
def read_sql_prompt(file_path: str) -> str:
    """
    Reads the content of a file and returns it as a string.
    If the file does not exist, returns an error message.
    """
    if os.path.exists(file_path):
        with open(file_path, "r", encoding="utf-8") as f:
            return f.read()
    else:
        return f"❌ File not found: {file_path}"

# Path to the file containing the SQL generation prompt
prompt_file = "generate_sql_prompt.txt"

# -------------------------------
# Import the custom T-SQL Generator Agent class
# -------------------------------
from TSQLGeneratorAgent import TSQLGeneratorAgent

# -------------------------------
# Async function: Stream task execution and display responses
# -------------------------------
To_Generate_SQL = 0
if To_Generate_SQL == 1:
    async def stream_task(orchestrator, user_request: str):
        """
        Streams messages from the orchestrator's team while executing the given task.
        Displays intermediate messages and the final result.
        """
        async for item in orchestrator.team.run_stream(task=user_request):
            if isinstance(item, TextMessage):  # ✅ Use TextMessage for actual text
                print(f"\n### {item.source.upper()} ###", flush=True)
                print(item.content, flush=True)
            elif isinstance(item, TaskResult):
                print("\n### FINAL RESULT ###", flush=True)
                print(f"Stop reason: {item.stop_reason}", flush=True)

    # -------------------------------
    # Main entry point
    # -------------------------------
    if __name__ == "__main__":
        orchestrator = TSQLGeneratorAgent()
        # Read user request (SQL generation prompt) from file
        user_request = read_sql_prompt(prompt_file)
        print("🚀 Starting live conversation...\n", flush=True)
        asyncio.run(stream_task(orchestrator, user_request))





## *************** SQL EXECUTOR AGENT ****************** ##
# Read T-SQL scripts from files and execute them against Azure SQL Database
## ----------------------------------------------------------------------##

# import TSQLExecutorAgent class to generate and save T-SQL scripts
from TSQLExecutorAgent import SQLAgentExecutor  # Your renamed class



# -------------------------------------------------
# Orchestration logic: stream and display responses
# -------------------------------------------------
To_Execute_SQL = 0

if To_Execute_SQL == 1:
    # Instantiate the orchestrator
    orchestrator = SQLAgentExecutor()    
    async def orchestrate_ai_agent_workflow(team, task):
        async for msg in team.run_stream(task=task):
            if isinstance(msg, TextMessage):
                # Remove markdown headers before printing
                cleaned_content = re.sub(r'^#{1,6}\s*', '', msg.content)
                print(f"{msg.source}: {cleaned_content.strip()}")
            elif isinstance(msg, TaskResult):
                print(f"Stop reason: {msg.stop_reason}")

    # -------------------------------
    # Run the task
    # -------------------------------
    async def main():
        task = "Run all SQL scripts in order using execute_sql_script tool."
        print("🚀 Starting live conversation...\n")
        
        # Use the team from orchestrator
        await orchestrate_ai_agent_workflow(orchestrator.team, task)
        
        print("\n✅ Task completed.")

    if __name__ == "__main__":
        asyncio.run(main())

To_Load_CSV = 1

from external_tools import ExternalTools

if To_Load_CSV == 1:
    csv_file = os.getenv("csv_file_dir")  # e.g., C:\DemoEnv\AgenticAI\csv\bicycle_data.csv
    table_name = os.getenv("sql_stage_table_name")  # e.g., stg.salestmp
    print(f"Loading CSV file '{csv_file}' into SQL table '{table_name}'...")
    # Load CSV data into SQL database

    result = ExternalTools.load_csv_to_sql_db(csv_file, table_name)
    print(result)

Stage_to_Sql_DB = 1
if Stage_to_Sql_DB == 1:
    result = ExternalTools.execute_stored_procedure("etl_process.usp_load_bicycle_staging_data")
    print(result)
