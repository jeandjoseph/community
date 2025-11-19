import os
import csv
import pyodbc
from dotenv import load_dotenv

class ExternalTools:
    """
    A utility class for handling SQL prompt files and related operations.
    """

    @staticmethod
    def read_sql_prompt(file_path: str) -> str:
        if os.path.exists(file_path):
            with open(file_path, "r", encoding="utf-8") as f:
                return f.read()
        return f"❌ File not found: {file_path}"

    @staticmethod
    def save_sql_script(file_path: str, content: str) -> str:
        try:
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(content)
            return f"✅ Saved successfully: {file_path}"
        except Exception as e:
            return f"❌ Failed to save {file_path}: {e}"

    @staticmethod
    def list_sql_scripts(folder_path: str) -> list:
        if os.path.exists(folder_path):
            return [f for f in os.listdir(folder_path) if f.endswith(".sql")]
        return []

    @staticmethod
    def load_csv_to_sql_db(file_path: str, table_name: str) -> str:
        """
        Load a CSV file into an existing Azure SQL Database table.
        """
        load_dotenv()
        connection_string = os.getenv("AZURE_SQL_CONNECTION_STRING")
        if not connection_string:
            return "❌ No AZURE_SQL_CONNECTION_STRING found in environment variables."

        if not os.path.exists(file_path):
            return f"❌ File not found: {file_path}"

        try:
            with open(file_path, "r", encoding="utf-8-sig") as f:
                reader = csv.reader(f)
                headers = next(reader)
                rows = [row for row in reader]

            if not rows:
                return "❌ CSV file is empty."

            conn = pyodbc.connect(connection_string)
            cursor = conn.cursor()

            # ✅ Build INSERT statement
            columns = ", ".join([f"[{col.strip()}]" for col in headers])
            placeholders = ", ".join(["?"] * len(headers))
            insert_sql = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})"

            # ✅ Batch insert for performance
            cursor.fast_executemany = True
            cursor.executemany(insert_sql, rows)

            conn.commit()
            cursor.close()
            conn.close()

            return f"✅ Successfully loaded {len(rows)} rows into {table_name}"

        except Exception as e:
            return f"❌ Error loading CSV into Azure SQL: {e}"


    @staticmethod
    def execute_stored_procedure(sql_query: str) -> str:
        """
        Executes a stored procedure in Azure SQL Database.

        Args:
            proc_name (str): Fully qualified stored procedure name (e.g., etl_process.usp_load_bicycle_staging_data).

        Returns:
            str: Status message.
        """
        try:
            load_dotenv()
            connection_string = os.getenv("AZURE_SQL_CONNECTION_STRING")
            if not connection_string:
                return "❌ Missing AZURE_SQL_CONNECTION_STRING in environment variables."
            if not sql_query:
                return "❌ Stored procedure name cannot be empty."

            conn = pyodbc.connect(connection_string)
            cursor = conn.cursor()

            cursor.execute(f"EXEC {sql_query}")
            conn.commit()

            cursor.close()
            conn.close()

            return f"✅ Successfully executed stored procedure: {sql_query}"

        except Exception as e:
            return f"❌ Error executing stored procedure: {e}"
