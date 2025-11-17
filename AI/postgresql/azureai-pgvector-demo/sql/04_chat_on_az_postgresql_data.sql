
-- Semantic product search using natural language input.
-- perform similarity search
/*
Show me products that offer premium sound quality.
Can you find wireless earbuds with noise cancellation?
I’m looking for a lightweight laptop with long battery life.
Show me options for a fitness smartwatch with heart rate monitor.
Find a smart home device with voice control.
Do you have recommendations for smart home automation?
Show me a portable sound system for travel.
*/

WITH query_embedding AS (
    SELECT azure_openai.create_embeddings('text-embedding-ada-002', 'I’m looking for a lightweight laptop with long battery life.')::vector AS embedding
)
SELECT P.name, P.category, P.description,
       ROUND((1 - (PV.embedding <=> query_embedding.embedding))::numeric, 4) AS similarity
FROM products AS P
JOIN products_vector AS PV ON P.productid = PV.productid
JOIN query_embedding ON TRUE
ORDER BY PV.embedding <=> query_embedding.embedding
LIMIT 10;


-- we have created this function already but you are welcome to recreate it here
-- turn the above into a reusable function
-- create a function to perform similarity search
-- this function takes a search text as input and returns the top 5 similar products
CREATE OR REPLACE FUNCTION find_similar_products(search_text TEXT DEFAULT 'premium sound quality')
RETURNS TABLE (
    product_name TEXT,
    category TEXT,
    description TEXT,
    similarity DOUBLE PRECISION
) AS $$
DECLARE
    query_embedding VECTOR := (
        SELECT azure_openai.create_embeddings('text-embedding-ada-002', search_text)
    );
BEGIN
    RETURN QUERY
    SELECT P.name, P.category, P.description,
           1 - (PV.embedding <=> query_embedding) AS similarity
    FROM products AS P
    JOIN products_vector AS PV ON P.productid = PV.productid
    --WHERE P.category = 'Audio'
    ORDER BY similarity DESC
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;



-- Custom search text
/*
Show me products that offer premium sound quality.
Find wireless earbuds with noise cancellation.
I’m looking for a lightweight laptop with long battery life.
Show me a fitness smartwatch with heart rate monitor.
Find a smart home device with voice control.
Show me options for smart home automation.
Do you have a gaming controller with haptics?
Show me a portable sound system for travel.
Find an eco-friendly home appliance.
*/
SELECT * FROM find_similar_products('Find wireless earbuds with noise cancellation.');




--- Check function execution statistics
-- track function usage
-- enable track_functions from azure parameters by setting track_functions = 'pl';
SELECT * FROM pg_stat_user_functions WHERE funcname = 'find_similar_products';
