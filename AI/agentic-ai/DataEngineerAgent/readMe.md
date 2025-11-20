

- `TSQLExecutorAgent.py`: Executes SQL scripts by reading files and running them against the target database, ensuring proper connection handling and error reporting.
- `TSQLGeneratorAgent.py`: Creates SQL scripts based on predefined prompts or templates, then saves them for later execution in the workflow.
- `Orchestrator.py`: Manages the entire process flow, deciding which agents run, in what order, and enforcing execution rules.
- `env.env / .env`: Stores environment variables such as database credentials, file paths, and configuration settings for secure and centralized access.
- `external_tools.py`: Provides helper functions for tasks like loading raw data and cleaning datasets before SQL operations.
- `generate_sql_prompt.txt`: Contains the text prompt used by TSQLGeneratorAgent.py to guide SQL script generation.
- `dependencies`: Lists all required packages and libraries (e.g., pyodbc, sqlalchemy, python-dotenv) for smooth execution.
- `sql_script_validation`: Includes SQL queries for validating process states, ensuring integrity before and after execution.
