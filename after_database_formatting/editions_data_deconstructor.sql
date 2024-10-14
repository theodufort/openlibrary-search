--Remove unecessary data
DO $$
DECLARE
    batch_size INTEGER := 100000;  -- Number of rows per batch; adjust based on your system's capacity
    total_rows BIGINT;
    updated_rows BIGINT;
    batch_counter INTEGER := 0;
    start_time TIMESTAMP := clock_timestamp();
BEGIN
    -- Step 1: Count total rows that need to be updated
    SELECT COUNT(*) INTO total_rows FROM editions
    WHERE data ? 'key' OR data ? 'type' OR data ? 'created' OR data ? 'revision'
       OR data ? 'publishers' OR data ? 'last_modified' OR data ? 'source_records'
       OR data ? 'latest_revision';
    
    RAISE NOTICE 'Total rows to update: %', total_rows;
    
    -- Step 2: Loop through batches
    LOOP
        -- Step 2a: Select a batch of keys to update
        WITH cte AS (
            SELECT key
            FROM editions
            WHERE data ? 'key' OR data ? 'type' OR data ? 'created' OR data ? 'revision'
               OR data ? 'publishers' OR data ? 'last_modified' OR data ? 'source_records'
               OR data ? 'latest_revision'
            ORDER BY key
            LIMIT batch_size
        )
        -- Step 2b: Update the selected batch
        UPDATE editions e
        SET data = e.data 
                   - 'key' 
                   - 'type' 
                   - 'created' 
                   - 'revision' 
                   - 'publishers' 
                   - 'last_modified' 
                   - 'source_records' 
                   - 'latest_revision'
        FROM cte
        WHERE e.key = cte.key;
        
        -- Step 2c: Get number of rows updated in this batch
        GET DIAGNOSTICS updated_rows = ROW_COUNT;
        
        -- Step 2d: Exit loop if no more rows to update
        EXIT WHEN updated_rows = 0;
        
        -- Step 2e: Increment batch counter
        batch_counter := batch_counter + 1;
        
        -- Step 2f: Log progress
        RAISE NOTICE 'Completed batch % of % (%.2f%%)', 
                     batch_counter, 
                     CEIL(total_rows::numeric / batch_size), 
                     (batch_counter * batch_size) / total_rows * 100;
    END LOOP;
    
    RAISE NOTICE 'Update completed. Total time elapsed: %', clock_timestamp() - start_time;
END $$;
