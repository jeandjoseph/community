import psycopg2
import os
from dotenv import load_dotenv

class PostgresClient:
    def __init__(self, env_var: str = "POSTGRES_CONNECT_STRING"):
        """Initialize Postgres client with connection string from environment."""
        load_dotenv()
        self.connect_string = os.getenv(env_var)
        if not self.connect_string:
            raise ValueError(f"Environment variable '{env_var}' not found or empty.")

    def run_query(self, pg_query: str, params: tuple = None) -> list:
        """Execute a SQL query and return all rows with column names."""
        try:
            with psycopg2.connect(self.connect_string) as conn:
                with conn.cursor() as cursor:
                    cursor.execute(pg_query, params)
                    rows = cursor.fetchall()
                    col_names = [desc[0] for desc in cursor.description]  # Get real column names
                    return {"columns": col_names, "rows": rows}
        except Exception as e:
            print(f"Error executing query: {e}")
            return {"columns": [], "rows": []}  


    def call_function(self, function_name: str, input_text: str) -> dict:
        """
        Call a PostgreSQL function dynamically based on function name.

        Args:
            function_name (str): Friendly name mapped to actual PostgreSQL function.
            input_text (str): Parameter passed to the function.

        Returns:
            list: Query result as a list of tuples.
        """        
        function_map = {
            "Looking for similar items? Just ask!": "find_similar_products",
            "Find a specific product overview": "get_product_review_summary"
        }
        pg_function = function_map.get(function_name)
        if not pg_function:
            raise ValueError(f"Unknown function name: {function_name}")

        pg_query = f"SELECT * FROM {pg_function}(%s);"
        return self.run_query(pg_query, (input_text,))
