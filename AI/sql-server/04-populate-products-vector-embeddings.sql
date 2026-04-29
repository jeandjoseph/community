USE [TestDB];
GO

/* Instance prerequisite for outbound REST calls */
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
EXEC sp_configure 'external rest endpoint enabled', 1;
RECONFIGURE WITH OVERRIDE;
GO

/* Settings */
DECLARE @BatchSize  int = 25;
DECLARE @MaxBatches int = 100;

DECLARE @EndpointBaseUrl nvarchar(4000) = N'https://az-openai-live-demo-01.openai.azure.com/';
DECLARE @DeploymentName  nvarchar(200)  = N'text-embedding-3-small';
DECLARE @ApiVersion      nvarchar(50)   = N'2024-10-21';

DECLARE @Url nvarchar(4000) =
    @EndpointBaseUrl + N'openai/deployments/' + @DeploymentName + N'/embeddings?api-version=' + @ApiVersion;

DECLARE @Headers nvarchar(4000) = N'{"Content-Type":"application/json"}';

DECLARE @BatchNumber int = 0;

WHILE @BatchNumber < @MaxBatches
BEGIN
    SET @BatchNumber += 1;

    IF OBJECT_ID('tempdb..#batch') IS NOT NULL DROP TABLE #batch;

    /* Pull next batch of products that do not yet have embeddings */
    SELECT TOP (@BatchSize)
           p.productid,
           CAST(p.name AS nvarchar(max)) AS name
    INTO #batch
    FROM dbo.products AS p
    WHERE p.name IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM dbo.products_vector AS pv WHERE pv.productid = p.productid)
    ORDER BY p.productid;

    DECLARE @BatchRowCount int;
    SELECT @BatchRowCount = COUNT(*) FROM #batch;

    IF @BatchRowCount = 0
    BEGIN
        PRINT 'No more rows to embed. Done.';
        BREAK;
    END

    /* Build input JSON array safely: ["name1","name2",...] */
    DECLARE @InputArray nvarchar(max);

    SELECT @InputArray =
        N'[' + STRING_AGG(QUOTENAME(b.name, '"'), N',') WITHIN GROUP (ORDER BY b.productid) + N']'
    FROM #batch AS b;

    DECLARE @Payload nvarchar(max) =
        N'{"input":' + @InputArray + N'}';

    /* Call embeddings endpoint once for the batch */
    DECLARE @ret int;
    DECLARE @resp nvarchar(max);

    EXEC @ret = sys.sp_invoke_external_rest_endpoint
        @url         = @Url,
        @method      = 'POST',
        @payload     = @Payload,
        @headers     = @Headers,
        @timeout     = 120,
        @credential  = [https://az-openai-live-demo-01.openai.azure.com/],
        @response    = @resp OUTPUT,
        @retry_count = 1;
    /* sp_invoke_external_rest_endpoint supports these parameters and response output. [1](https://bing.com/search?q=SQL+Server+PREVIEW_FEATURES+DMV) */

    /* Validate HTTP status */
    DECLARE @HttpCode int = TRY_CONVERT(int, JSON_VALUE(@resp, '$.response.status.http.code'));

    IF @HttpCode IS NULL OR @HttpCode <> 200
    BEGIN
        SELECT
            @BatchNumber AS batch_number,
            @BatchRowCount AS rows_in_batch,
            @ret AS sp_return_code,
            @HttpCode AS http_status_code,
            LEFT(@resp, 4000) AS response_preview;
        THROW 50001, 'Embeddings batch call failed. See response_preview for details.', 1;
    END

    /* Map response embeddings back to products by index */
    ;WITH Embeddings AS
    (
        SELECT
            CAST(j.[key] AS int) AS input_index,
            JSON_QUERY(j.[value], '$.embedding') AS embedding_json
        FROM OPENJSON(@resp, '$.result.data') AS j
    ),
    BatchOrdered AS
    (
        SELECT
            b.productid,
            ROW_NUMBER() OVER (ORDER BY b.productid) - 1 AS input_index
        FROM #batch AS b
    )
    MERGE dbo.products_vector AS tgt
    USING
    (
        SELECT
            bo.productid,
            e.embedding_json
        FROM BatchOrdered AS bo
        INNER JOIN Embeddings AS e
            ON e.input_index = bo.input_index
    ) AS src
    ON tgt.productid = src.productid
    WHEN MATCHED THEN
        UPDATE SET tgt.embedding_json = src.embedding_json
    WHEN NOT MATCHED THEN
        INSERT (productid, embedding_json)
        VALUES (src.productid, src.embedding_json);

    /* IMPORTANT FIX: do not use subquery inside CONCAT/PRINT */
    PRINT CONCAT('Batch ', @BatchNumber, ' processed. Rows: ', @BatchRowCount);
END
GO

--TRUNCATE TABLE dbo.products_vector; -- use with caution, this will delete all existing embeddings

SELECT top(5) * FROM dbo.products_vector;

SELECT TOP(5)P.name, P.category, P.description, PV.embedding_json
FROM products AS P 
JOIN products_vector AS PV
ON P.productid = PV.productid;