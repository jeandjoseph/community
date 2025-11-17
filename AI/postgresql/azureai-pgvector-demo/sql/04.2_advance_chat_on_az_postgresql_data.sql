


--✅ 1. Group by Nearest Neighbor Similarity
--Find products similar to each other by comparing embeddings:
-- duplicate pairs are displayed
SELECT p1.name AS product, p2.name AS similar_product,
       1 - (pv1.embedding <=> pv2.embedding) AS similarity
FROM products_vector pv1
JOIN products_vector pv2 ON pv1.productid <> pv2.productid
JOIN products p1 ON pv1.productid = p1.productid
JOIN products p2 ON pv2.productid = p2.productid
WHERE p1.category = p2.category  -- optional: same category
  --AND p1.category = 'Audio' 
 -- AND p2.category = 'Audio'    -- optional: filter by category
ORDER BY similarity DESC
LIMIT 10;


-- 2. Group by Nearest Neighbor Similarity and **avoid duplicate pairs**
SELECT
    p1.name AS product, 
    p2.name AS similar_product, 
    1 - (pv1.embedding <=> pv2.embedding) AS similarity
FROM products_vector pv1
JOIN products_vector pv2 ON pv1.productid <> pv2.productid
JOIN products p1 ON pv1.productid = p1.productid
JOIN products p2 ON pv2.productid = p2.productid
WHERE p1.category = p2.category
  AND p1.productid < p2.productid  -- ✅ ensures only one direction
ORDER BY similarity DESC, product
LIMIT 10;


-- 3. Aggregate Similar Products by Category
-- List similar product pairs within each category:
SELECT
    p1.category AS category,
    STRING_AGG(
        p1.name || ' ↔ ' || p2.name || ' (' || ROUND((1 - (pv1.embedding <=> pv2.embedding))::numeric, 3)::text || ')',
        ', '
    ) AS similar_pairs
FROM products_vector pv1
JOIN products_vector pv2 ON pv1.productid <> pv2.productid
JOIN products p1 ON pv1.productid = p1.productid
JOIN products p2 ON pv2.productid = p2.productid
WHERE p1.category = p2.category
  AND p1.productid < p2.productid
GROUP BY p1.category
ORDER BY p1.category;



-- json format
-- Group Products by Category Similarity
-- Aggregate products within each category based on their similarity to the category centroid:
WITH category_centroids AS (
    SELECT p.category, AVG(pv.embedding) AS centroid
    FROM products p
    JOIN products_vector pv ON p.productid = pv.productid
    GROUP BY p.category
)
SELECT cc.category,
       ARRAY_AGG(p.name ORDER BY (1 - (pv.embedding <=> cc.centroid)) DESC) AS related_products
FROM products p
JOIN products_vector pv ON p.productid = pv.productid
JOIN category_centroids cc ON p.category = cc.category
GROUP BY cc.category
ORDER BY cc.category;





-- take advantage of indexing for performance
-- drop existing index if any
DROP INDEX products_embedding_ivfflat_idx
EXPLAIN ANALIZE;
-- generate query plan to analyze performance
EXPLAIN
WITH cross_category_similarity AS (
    SELECT p1.category AS base_category,
           p2.category AS dependent_category,
           AVG(1 - (pv1.embedding <=> pv2.embedding)) AS avg_similarity
    FROM products_vector pv1
    JOIN products_vector pv2 ON pv1.productid <> pv2.productid
    JOIN products p1 ON pv1.productid = p1.productid
    JOIN products p2 ON pv2.productid = p2.productid
    WHERE p1.category <> p2.category
    GROUP BY p1.category, p2.category
)
SELECT base_category, dependent_category, avg_similarity
FROM cross_category_similarity
ORDER BY avg_similarity DESC
LIMIT 10;


---CREATE INDEX FOR IMPROVED PERFORMANCE
/*
HNSW (Hierarchical Navigable Small World):
    What: Graph-based index for approximate nearest neighbor search.
    When to use: Best for high recall and fast queries on large datasets. Great for semantic search with embeddings.

IVFFlat (Inverted File with Flat quantization):
    What: Clusters vectors into lists and searches only relevant clusters.
    When to use: Best for large-scale datasets where you need speed over exact accuracy. Works well with pgvector for similarity search.     
*/

/***************EXAMPLE: HNSW index type****************
 Explanation:
  USING hnsw → specifies HNSW index type.
  vector_cosine_ops → uses cosine similarity for embeddings.
  m → number of connections per node (controls memory and speed).
  ef_construction → size of dynamic candidate list during index build (higher = better accuracy, slower build).
*/
CREATE INDEX products_embedding_hnsw_idx
ON products_vector USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);


/***************EXAMPLE: ivfflat index type****************
✅ Explanation:
  Index type: ivfflat → Inverted File Flat index for approximate nearest neighbor search.
    ivfflat: Index type for approximate nearest neighbor search.
    vector_cosine_ops: Operator class for cosine distance (<=>).
    lists = 100: Controls the number of clusters (higher = more accurate but slower build).
*/
CREATE INDEX products_embedding_ivfflat_idx
ON products_vector USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);




-- Analyze the products_vector table to update statistics
ANALYZE products_vector;



-- generate query plan to analyze performance
EXPLAIN
WITH cross_category_similarity AS (
    SELECT p1.category AS base_category,
           p2.category AS dependent_category,
           AVG(1 - (pv1.embedding <=> pv2.embedding)) AS avg_similarity
    FROM products_vector pv1
    JOIN products_vector pv2 ON pv1.productid <> pv2.productid
    JOIN products p1 ON pv1.productid = p1.productid
    JOIN products p2 ON pv2.productid = p2.productid
    WHERE p1.category <> p2.category
    GROUP BY p1.category, p2.category
)
SELECT base_category, dependent_category, avg_similarity
FROM cross_category_similarity
ORDER BY avg_similarity DESC
LIMIT 10;



-- Tune Query Accuracy vs Speed
/*
Tip:
    probes = 1 → fastest, less accurate
    probes = lists → most accurate, slower

✅ Performance Tips

Use IVFFLAT index for large datasets (thousands+ embeddings).
  - Adjust lists and probes:
    - lists = 100–1000 for balance.
    - probes = 10–50 for accuracy.
  - Run ANALYZE products_vector; after creating the index.    
*/


-- Set probes for better accuracy
SET ivfflat.probes = 10;  -- default is 1, increase for better accuracy

