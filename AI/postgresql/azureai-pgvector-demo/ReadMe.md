# **Interact Boldly. Your Data, Your Privacy.**

---

## 🚀 **Purpose of This Demo**
This demo showcases how you can **chat with your private data securely** using the combined power of:

- **PostgreSQL** – A robust, open-source relational database that now supports advanced AI scenarios with extensions like **pgvector**.
- **Azure AI Services** – Easily integrate **Large Language Models (LLMs)** and cognitive services for natural language understanding, sentiment analysis, and PII detection.
- **pgvector** – Enables **vector similarity search** for semantic queries, making your database AI-ready.
![](https://github.com/jeandjoseph/community/blob/main/AI/postgresql/azureai-pgvector-demo/flow_diagram.png)
---

## ✅ **Why This Matters**
Organizations often struggle to leverage AI on private data without compromising **privacy**, **scalability**, or **cost**. This solution solves that by:

- **Keeping your data private**: Queries run directly on your PostgreSQL database—no need to expose raw data to external systems.
- **Scaling effortlessly**: Azure services handle heavy AI workloads while PostgreSQL ensures reliable data storage and retrieval.
- **Controlling costs**: Pay only for what you use with Azure’s consumption-based model.

---

## 🔍 **What You Can Do**
- **Chat with your private data**: Ask natural language questions about products, reviews, or any domain-specific data.
- **Explore insights securely**: Use Azure Cognitive Services for sentiment analysis, PII redaction, and summarization.
- **Find similar items**: Leverage **pgvector** for semantic search and recommendations.
- **Get detailed product insights**: Combine structured queries with AI-driven summaries.

---

## 🛠 **Tech Stack**
- **PostgreSQLwith [pgvector](https://github.com/pgvector/pgvector) extension:**  Vector similarity search for semantic queries and embeddings storage.
- **OpenAI [text-embedding-ada-002](https://learn.microsoft.com/en-us/azure/ai-foundry/openai/tutorials/embeddings?tabs=command-line%2Cpython-new&pivots=programming-language-python):** Generates high-quality embeddings for semantic search and recommendation tasks.
- **Azure [AI Language](https://learn.microsoft.com/en-us/azure/ai-services/language-service/overview) Service:** Provides sentiment analysis, summarization, entity extraction, and PII detection for text data.
- **Azure [AI Translator](https://learn.microsoft.com/en-us/azure/ai-services/translator/) Service**: Enables real-time language translation for multilingual support.
- **[SQL](https://learn.microsoft.com/en-us/training/modules/introduction-to-transact-sql/1-introduction)** Used for orchestration and querying.
- **[Python](https://learn.microsoft.com/en-us/shows/intro-to-python-development/) (optional)** For orchestration, integration, and automation.
---

## 1️⃣ **Set Up PostgreSQL with pgvector**
Navigate to the `sql/` folder. It contains scripts to create tables, define functions, and integrate Azure AI services.
### first execute these Files in `sql/` in this order:
- `00_create_tables_insert_data.sql`: *Create base tables and insert sample data.*
- `01_create_pg_functions.sql`: *Define Postgres functions for semantic search and chat operations.*
- `02_setting_up_azure_openai_n_ai_svc.sql`: *Configure Azure OpenAI and AI Language services integration.*
- `03_populate_products_vector_summarise_data.sql`: *Generate embeddings and populate vector columns for semantic queries.*
- `04_chat_on_az_postgresql_data.sql`: *Enable chat-based interaction with PostgreSQL data.*
- `042_advance_chat_on_az_postgresql_data.sql`: *Advanced chat features (optional).*


### ✅ Update the `.env` file & install Python libraries (for Streamlit app):
Navigate to the `python/` folder. Update the `.env` file with your Azure and PostgreSQL credentials.
- Create a Python virtual environment:
  ```bash
  python -m venv venv
  ```
- Activate the virtual environment:
  ```
  source venv/bin/activate   # macOS/Linux
  venv\Scripts\activate      # Windows
  ```
- Install dependencies:
  ```
  pip install -r requirements.txt
  ```
- Run the Streamlit application:
  ```
  streamlit run app.py
  ```
---

## ✅ **Key Features**
- **Secure AI on Private Data** – No raw data leaves your database.
- **Natural Language Queries** – Interact with data like you would with a human.
- **Privacy Guaranteed** – Built-in PII detection and redaction.
- **Scalable & Cost-Efficient** – Azure handles AI workloads without breaking the bank.
