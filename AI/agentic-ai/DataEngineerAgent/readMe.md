## Welcome to this demo for data and analytics professionals!
This session is designed for those who want to explore how [Microsoft AutoGen](https://microsoft.github.io/autogen/dev/index.html), powered by Azure [OpenAI](https://azure.microsoft.com/en-us/products/ai-foundry/models/openai?msockid=1215ff17aded6042147ae933acea6173), can help automate digital processes in ways that mimic human interaction. You’ll see how agentic AI can generate, validate, and execute workflows—bringing intelligence and autonomy to tasks that traditionally required manual effort. Get ready to experience a new level of efficiency and collaboration in your data ecosystem.

#### Setting up your environment
Install the following package:

**mac:**
```python
python3 -m venv .venv
source .venv/bin/activate
```

**pc:**
```python
# The command may be `python3` instead of `python` depending on your setup
python -m venv .venv
.venv\Scripts\activate.bat
```


- `TSQLExecutorAgent.py`: Executes SQL scripts by reading files and running them against the target database, ensuring proper connection handling and error reporting.
- `TSQLGeneratorAgent.py`: Creates SQL scripts based on predefined prompts or templates, then saves them for later execution in the workflow.
- `Orchestrator.py`: Manages the entire process flow, deciding which agents run, in what order, and enforcing execution rules.
- `env.env / .env`: Stores environment variables such as database credentials, file paths, and configuration settings for secure and centralized access.
- `external_tools.py`: Provides helper functions for tasks like loading raw data and cleaning datasets before SQL operations.
- `generate_sql_prompt.txt`: Contains the text prompt used by TSQLGeneratorAgent.py to guide SQL script generation.
- `dependencies`: Lists all required packages and libraries (e.g., pyodbc, sqlalchemy, python-dotenv) for smooth execution.
- `sql_script_validation`: Includes SQL queries for validating process states, ensuring integrity before and after execution.
