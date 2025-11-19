# -*- coding: utf-8 -*-
"""
Requires Microsoft AutoGen 0.4+ split packages:
    autogen-core, autogen-agentchat, autogen-ext

pip install:
    autogen-core>=0.4
    autogen-agentchat>=0.4
    autogen-ext>=0.4
    pyodbc
    python-dotenv
"""

import os
import asyncio
import logging
from dotenv import load_dotenv

from autogen_ext.models.openai import AzureOpenAIChatCompletionClient
from autogen_agentchat.agents import AssistantAgent, CodeExecutorAgent
from autogen_agentchat.teams import RoundRobinGroupChat
from autogen_agentchat.conditions import TextMentionTermination
from autogen_ext.code_executors.local import LocalCommandLineCodeExecutor
from autogen_core.tools import FunctionTool
from autogen_agentchat.base import TaskResult # run_stream return TaskResult

"""
    🔹 These agents are designed to produce T-SQL codes, not execute them.

    🔹 Each T-SQL script block is saved into a separate .sql file.

    🔹 File saving is handled by a tool (save_sql_script) that writes the generated SQL text to the ./sql_scripts directory.

    🔹 Agents collaborate: one agent generates the T‑SQL, another ensures file handling.

    🔹 Output is modular — you end up with reusable .sql files for each requested script.
"""


class TSQLGeneratorAgent:
    def __init__(self, scripts_dir: str = "./sql_scripts"):
        # -------------------------------
        # Load environment variables
        # -------------------------------
        load_dotenv()
        #logging.basicConfig(level=logging.INFO)

        self.scripts_dir = scripts_dir
        os.makedirs(self.scripts_dir, exist_ok=True)

        # Azure OpenAI credentials
        azure_openai_model_name = os.getenv("MODEL")
        azure_openai_api_key = os.getenv("API_KEY")
        azure_openai_endpoint = os.getenv("BASE_URL")
        azure_openai_api_version = os.getenv("API_VERSION")

        # -------------------------------
        # Initialize Azure OpenAI client
        # -------------------------------
        self.llm_client = AzureOpenAIChatCompletionClient(
            azure_deployment=azure_openai_model_name,
            azure_endpoint=azure_openai_endpoint,
            model=azure_openai_model_name,
            api_version=azure_openai_api_version,
            api_key=azure_openai_api_key
        )

        # -------------------------------
        # Define helper tool
        # -------------------------------
        def save_sql_script(script: str, filename: str) -> str:
            filepath = os.path.join(self.scripts_dir, filename)
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(script)
            return f"✅ Saved T-SQL script to {filepath}"

        self.save_tool = FunctionTool(
            func=save_sql_script,
            description="Save a T-SQL script to a .sql file in the ./sql_scripts directory."
        )

        # -------------------------------
        # Agents
        # -------------------------------
        self.tsql_generator = AssistantAgent(
            name="TSQL_Generator",
            model_client=self.llm_client,
            system_message=(
                "You are a T-SQL expert. Generate optimized T-SQL scripts per user request" 
                "and call 'save_sql_script' for each. Use this schema:schema=[('ProductId','INT'),('ProductName','VARCHAR(50)')" 
                ",('ProductType','VARCHAR(30)'),('Color','VARCHAR(15)'),('OrderQuantity','INT'),('Size','VARCHAR(15)')," 
                "('Category','VARCHAR(15)'),('Country','VARCHAR(30)'),('Date','DATE'),('PurchasePrice','DECIMAL(18,2)'),('SellingPrice','DECIMAL(18,2)')]"
                "End with 'done'."

            ),
            tools=[self.save_tool]
        )

        self.file_saver = CodeExecutorAgent(
            name="File_Saver",
            code_executor=LocalCommandLineCodeExecutor(work_dir=self.scripts_dir),
            system_message="You can execute shell commands if needed. Then End with: 'done'",
            approval_func=lambda code: True
        )

        # -------------------------------
        # Team Orchestration
        # -------------------------------
        self.team = RoundRobinGroupChat(
            participants=[self.tsql_generator, self.file_saver],
            max_turns=3,
            termination_condition=TextMentionTermination("done")
        )

