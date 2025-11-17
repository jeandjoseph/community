
-- products_vector is empty and we are going to populate the vector embeddings for product names
SELECT * from products_vector LIMIT 5;


-- populate products_vector table with embeddings
-- for product names using Azure OpenAI 'text-embedding-ada-002' model
-- assumes products table already exists and is populated

-- Takes all product names from products, creates vector embeddings using Azure OpenAI, 
-- and saves them in products_vector for semantic search.
-- TOOK Total execution time: 00:00:28.271 TO INSERT 46 RECORDS
INSERT INTO products_vector (productid, embedding)
SELECT
    P.productid,
    azure_openai.create_embeddings('text-embedding-ada-002', P.name) AS embedding
FROM products AS P;



-- verify data in products_vector table
SELECT * from products_vector LIMIT 5;
SELECT * from products LIMIT 5;


-- join products with products_vector to see embeddings alongside product details
SELECT P.name, P.category, P.description, PV.embedding
FROM products AS P 
JOIN products_vector AS PV
ON P.productid = PV.productid
LIMIT 5;



-- populate product_review_summary table
-- Summarize and analyze all existing product reviews once using Azure Language, then store the results for future use.
    -- If it’s a one-time operation: 
-- TOOK Total execution time: 00:04:51.043 TO INSERT 46 RECORDS

WITH review_data AS (
    SELECT
        p.productid,
        STRING_AGG(r.review_text, ' ') AS combined_reviews
    FROM products AS p
    INNER JOIN product_reviews AS r ON p.productid = r.productid
    --WHERE p.name = 'EchoBuds Pro'
    GROUP BY p.productid
),
summary_data AS (
    SELECT
        r.productid,
        array_to_string(
            azure_cognitive.summarize_abstractive(
                r.combined_reviews,
                'en',
                throw_on_error => false,
                sentence_count => 2
            ),
            ' '
        ) AS abstractive_summary,
        azure_cognitive.analyze_sentiment(r.combined_reviews, 'en') AS sentiment
    FROM review_data AS r
)
INSERT INTO product_review_summary (
    productid,
    abstractive_summary,
    sentiment_label,
    positive_score,
    neutral_score,
    negative_score
)
SELECT
    productid,
    abstractive_summary,
    (sentiment).sentiment AS sentiment,
    (sentiment).positive_score AS positive_score,
    (sentiment).neutral_score AS neutral_score,
    (sentiment).negative_score AS negative_score
FROM summary_data;


-- verify data insertion
SELECT * FROM product_review_summary;

