-- Test SQL script to demonstrate calling Azure OpenAI embeddings endpoint 
-- using sp_invoke_external_rest_endpoint in SQL Server 2025
USE TestDB;
GO
--Azure OpenAI Deployment Model Name: text-embedding-3-small
--Azure OpenAI Deployment Model api-version: 2024-10-21'

DECLARE @url nvarchar(4000) =
  N'https://<your azure openai name>.openai.azure.com/openai/deployments/<your deployment name>/embeddings?api-version=<your api version>';

DECLARE @payload nvarchar(max) =
  N'{"input":"hello from SQL Server 2025 running in Docker"}';

DECLARE @headers nvarchar(4000) =
  N'{"Content-Type":"application/json"}';

DECLARE @ret int;
DECLARE @resp nvarchar(max);

EXEC @ret = sys.sp_invoke_external_rest_endpoint
  @url = @url,
  @method = 'POST',
  @payload = @payload,
  @headers = @headers,
  @timeout = 60,
  @credential = [https://<your azure openai name>.openai.azure.com/],
  @response = @resp OUTPUT,
  @retry_count = 1;

SELECT
  @ret AS sp_return_code,
  JSON_VALUE(@resp, '$.response.status.http.code') AS http_status_code,
  JSON_VALUE(@resp, '$.response.status.http.description') AS http_status_description,
  LEFT(@resp, 2000) AS response_preview;
GO



-- The following code demonstrates how to extract the embedding vector 
-- from the response and insert it into a table.
DECLARE @url nvarchar(4000) =
  N'https://<your azure openai name>.openai.azure.com/openai/deployments/<your deployment name>/embeddings?api-version=<your api version>';

DECLARE @payload nvarchar(max) =
  N'{"input":"hello from SQL Server 2025 running in Docker"}';

DECLARE @headers nvarchar(4000) =
  N'{"Content-Type":"application/json"}';

DECLARE @ret int;
DECLARE @resp nvarchar(max);

EXEC @ret = sys.sp_invoke_external_rest_endpoint
  @url = @url,
  @method = 'POST',
  @payload = @payload,
  @headers = @headers,
  @timeout = 60,
  @credential = [https://<your azure openai name>.openai.azure.com/],
  @response = @resp OUTPUT,
  @retry_count = 1;

-- Extract the embedding as JSON array
SELECT
  @ret AS sp_return_code,
  JSON_VALUE(@resp, '$.response.status.http.code') AS http_status_code,
  JSON_QUERY(@resp, '$.result.data[0].embedding')  AS embedding_json;
GO


/* Only on Azure SQL Mi for now.
--https://learn.microsoft.com/en-us/sql/t-sql/functions/ai-generate-embeddings-transact-sql?view=sql-server-ver17&tabs=request-headers
SELECT id,
       AI_GENERATE_EMBEDDINGS(large_text USE MODEL MyAzureOpenAIModel) AS embeddings
FROM (VALUES (1, 'text data that benefits from vector representation.')) AS T(id, large_text);
*/