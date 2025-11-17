-- First: you need to have the azure_ai, pg_vector extension installed and configured before running this script
   -- make sure azure_ai, pg_vector extension is installed and configured on azure postgresql flexible server.
-- Second: you need to have an Azure OpenAI service and Azure AI Services (Language & Translator Service) created in your Azure subscription
-- Third: you need to replace the placeholder values below with your actual endpoint URLs and subscription keys
-- Finally: run this script to set up the configuration for Azure OpenAI and Azure Cognitive Services
-- Note: keep your subscription keys secure and do not expose them in public repositories or shared environments

/* Set Azure OpenAI configuration settings 
    --- Replace {endpoint} with your actual Azure OpenAI endpoint URL
    SELECT azure_ai.set_setting('azure_openai.endpoint', '{endpoint}');
    --- Replace {api-key} with your actual Azure OpenAI subscription key
    SELECT azure_ai.set_setting('azure_openai.subscription_key', '{api-key}');
*/


-- configure Azure OpenAI settings
DO $$
DECLARE
    endpoint TEXT := 'https://{your-azure-openai-svc}.openai.azure.com/';
    api_key TEXT := '{your-azure-openai-svc-subscription-key}';
BEGIN
    PERFORM  azure_ai.set_setting('azure_openai.endpoint', endpoint);
    PERFORM  azure_ai.set_setting('azure_openai.subscription_key', api_key);
END $$;


-- Verify the settings
SELECT azure_ai.get_setting('azure_openai.endpoint');

-- test Azure OpenAI Chat Completion
SELECT azure_openai.create_embeddings('text-embedding-ada-002','I love this demo') AS embeddings;





-- configure Azure Cognitive Services settings
DO $$
DECLARE
    endpoint TEXT := 'https://{your-azure-language-svc}.cognitiveservices.azure.com/';
    api_key TEXT := '{your-azure-language-svc-subscription-key}';
BEGIN
    PERFORM  azure_ai.set_setting('azure_cognitive.endpoint', endpoint);
    PERFORM  azure_ai.set_setting('azure_cognitive.subscription_key', api_key);
END $$;




-- Verify the settings
SELECT azure_ai.get_setting('azure_cognitive.endpoint');

SELECT azure_ai.get_setting('azure_cognitive.subscription_key');


-- Test Azure Cognitive Services Sentiment Analysis
SELECT  azure_cognitive.analyze_sentiment('i LOVE THIS DEMO', 'en') AS sentiment






-- we will not cover azure AI translation service here, but you can set it up similarly
--- Alternative way to set Azure Cognitive Services settings for language translation
-- for language translation, you need to set the region as well
DO $$
DECLARE
    endpoint TEXT := 'https://{your-azure-translator-svc}.cognitiveservices.azure.com/';
    api_key TEXT := '{your-azure-stranslator-svc-subscription-key}';
    regoin TEXT := '{your-azure-translator-svc-region}';
BEGIN
    PERFORM  azure_ai.set_setting('azure_cognitive.endpoint', endpoint);
    PERFORM  azure_ai.set_setting('azure_cognitive.subscription_key', api_key);
    PERFORM  azure_ai.set_setting('azure_cognitive.region', regoin);
END $$;



-- Verify the settings
SELECT azure_ai.get_setting('azure_cognitive.endpoint');    
SELECT azure_ai.get_setting('azure_cognitive.region');


-- Test Azure Cognitive Services Language Translation
SELECT azure_cognitive.translate('I love this demo', 'fr') AS translated_text;