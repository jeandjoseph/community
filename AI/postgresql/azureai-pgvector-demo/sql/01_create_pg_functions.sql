
-- Function to get product review summary by product name
CREATE OR REPLACE FUNCTION get_product_review_summary(p_name TEXT)
RETURNS TABLE (
    product_name TEXT,
    product_summary_feedback TEXT,
    sentiment_label TEXT,
    positive_score DOUBLE PRECISION,
    neutral_score DOUBLE PRECISION,
    negative_score DOUBLE PRECISION
)
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.name,
        (azure_cognitive.recognize_pii_entities(r.abstractive_summary,'en-US')).redacted_text AS product_summary_feedback,
        r.sentiment_label,
        r.positive_score,
        r.neutral_score,
        r.negative_score
    FROM products AS p
    INNER JOIN product_review_summary AS r ON p.productid = r.productid
    WHERE p.name = p_name;
END;
$$ LANGUAGE plpgsql;


-- Example call to the function
-- should be empty for now but will be populated after after configuring azure openai and AI Language services.
SELECT * FROM get_product_review_summary('EchoBuds Pro');




-- create a function to perform similarity search
-- can only be executed after configuring azure openai and AI Language services.
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


-- Example call to the similarity search function
-- Should be empty for now but will be populated after after configuring azure openai and AI Language services.
SELECT * FROM find_similar_products('wireless headphones with noise cancellation');