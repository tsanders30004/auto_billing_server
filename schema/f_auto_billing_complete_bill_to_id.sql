Procedure	sql_mode	Create Procedure	character_set_client	collation_connection	Database Collation
f_auto_billing_complete_bill_to_id	STRICT_TRANS_TABLES	CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `f_auto_billing_complete_bill_to_id`()\n    COMMENT 'USAGE:  f_auto_billing_complete_bill_to_id */ Calculates and populates bill_to_id. */'\nBEGIN\n\n    /*\n    \n        Purpose:  Calculate the bill_to_id.\n        \n        Note the following:\n    \n        MariaDB [sales_force]> SELECT billing_preference__c, COUNT(*) FROM sales_force.account GROUP BY 1;\n        +-----------------------+----------+\n        | billing_preference__c | COUNT(*) |\n        +-----------------------+----------+\n        | NULL                  |    21702 |\n        | Aggregated Billing    |     4235 |\n        | Client Level Only     |       42 |\n        | Direct Billing        |     9687 |\n        | Processor Only        |    30928 |\n        +-----------------------+----------+\n        5 rows in set (3.38 sec)\n    \n        Rows in sales_force.account for which billing_preference__c != 'Aggregated' are billed directly.\n        \n        Rows in sales_force.account for which billing_preference__c = 'Aggregated' are billed to a parent account, based on the value of account.parentid.\n        It may be be necessary to traverse multiple 'levels' to find the parent.\n        \n        See the simulated data below; the calculated value of bill_to_id is shown.\n        \n        cardconex_acct_id|parent_id|billing_preference|bill_to_id|\n        -----------------|---------|------------------|----------|\n        a                |*        |Client Level Only |a         |   -- case 1\n        \n        b                |c        |Aggregated Billing|c         |   -- case 2\n        c                |*        |Direct Billing    |c         |\n        \n        e                |f        |Aggregated Billing|g         |   -- case 3\n        f                |g        |Aggregated Billing|g         |\n        g                |*        |Processor Only    |g         |\n        \n        i                |j        |Aggregated Billing|l         |   -- case 4\n        j                |k        |Aggregated Billing|l         |\n        k                |l        |Aggregated Billing|l         |\n        l                |*        |Processor Only    |l         |\n        \n        n                |o        |Aggregated Billing|r         |   -- case 5\n        o                |p        |Aggregated Billing|r         |\n        p                |q        |Aggregated Billing|r         |\n        q                |r        |Aggregated Billing|r         |\n        r                |*        |Processor Only    |r         |\n        \n        t                |u        |Aggregated Billing|y         |   -- case 6\n        u                |v        |Aggregated Billing|y         |\n        v                |w        |Aggregated Billing|y         |\n        w                |x        |Aggregated Billing|y         |\n        x                |y        |Aggregated Billing|y         |\n        y                |*        |Processor Only    |y         |\n        \n        Case 1 (One Level)\n        ------------------\n        Since billing_preference != 'Aggregated Billing, the account is billed directly; i.e, bill_to_id = cardconex_acct_id\n        \n        Case 2 (Two Levels)\n        -------------------\n        billing_preference = 'Aggregated Billing', so this account is not billed directly.\n     \n        Consider the following:\n        \n        cardconex_acct_id|parent_id|billing_preference|\n        -----------------|---------|------------------|\n        b                |c        |Aggregated Billing|\n        c                |*        |Direct Billing    |\n        \n        We need to calculate the bill_to_id for cardconex_acct_id = 'b'.\n        billing_preference = 'Aggregated Billing', so we have the find the parent.\n        \n        In this case, the parent_id = 'c'.  The value of billing_preference for cardconex_acct_id = 'c' = 'Direct Billing', so 'c' is the parent.\n        Therefore, the bill_to_id for cardconex_acct_id IN ('b', 'c') = 'Direct Billing.\n        \n        Cases 3, 4, 5, ... (Three Or More Levels)\n        -----------------------------------------\n        These are variations for Case 2, with an increasing number of levels.\n        See the desired output in the table above for each of these cases.   \n    \n    */\n    \n    DECLARE i           TINYINT UNSIGNED;\n    DECLARE num_levels  TINYINT UNSIGNED DEFAULT 4;   -- number of times to repeat the loop for cases 3-6\n\n    SELECT 'Executing Stored Procedure' AS operation, 'update_bill_to_id' AS stored_procedure, CURRENT_TIMESTAMP;\n    \n    -- Case 1\n    \n    SET @ab = 'Aggregated Billing';\n    \n    DROP TABLE IF EXISTS tmp_01;\n    \n    CREATE TEMPORARY TABLE tmp_01(\n        cardconex_acct_id     VARCHAR(32)\n       ,parent_id             VARCHAR(32)\n       ,billing_preference    VARCHAR(32)\n       ,bill_to_id            VARCHAR(32)\n       ,PRIMARY KEY(cardconex_acct_id)\n       ,KEY idx_parent_id(parent_id)\n    );\n    \n\n    -- NULL values of billing_preference__c should be interpreted as 'Direct Billing'.  \n    -- This is not currently configured in the database or in the warehouse, so it is being done here.\n    \n    SELECT 'NULL values of sales_force.account.billing_preference__c will be interpreted as \\'Direct Billing\\'' AS message;\n  \n    INSERT INTO tmp_01 \n    SELECT \n         id                       AS cardconex_acct_id \n        ,parentid                 AS parent_id \n        ,'Direct Billing'         AS billing_preference\n        ,NULL                     AS bill_to_id\n      FROM sales_force.account \n     WHERE billing_preference__c IS NULL\n    ;\n  \n    INSERT INTO tmp_01 \n    SELECT \n         id                       AS cardconex_acct_id \n        ,parentid                 AS parent_id \n        ,billing_preference__c    AS billing_preference\n        ,NULL                     AS bill_to_id\n      FROM sales_force.account \n     WHERE billing_preference__c != @ab\n    ;\n    \n    UPDATE tmp_01\n       SET bill_to_id = cardconex_acct_id\n     WHERE TRUE \n    ;  \n    \n    -- SELECT * FROM tmp_01;\n    -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|\n    -- --|-----------------|---------|------------------|----------|\n    --  1|a                |*        |B                 |a         |\n    --  3|c                |*        |C                 |c         |\n    --  6|g                |*        |D                 |g         |\n    -- 10|l                |*        |E                 |l         |\n    -- 15|r                |*        |F                 |r         |\n    -- 21|y                |*        |G                 |y         |\n    \n    -- Case 2\n    \n    DROP TABLE IF EXISTS tmp_02;\n    \n    CREATE TEMPORARY TABLE tmp_02 LIKE tmp_01;\n    \n    INSERT INTO tmp_02\n    SELECT \n         id                       AS cardconex_acct_id \n        ,parentid                 AS parent_id \n        ,billing_preference__c    AS billing_preference\n        ,NULL                     AS bill_to_id\n      FROM sales_force.account \n     WHERE billing_preference__c = @ab\n    ;\n    \n    UPDATE tmp_02     t2 \n      JOIN tmp_01     t1 \n        ON t2.parent_id = t1.cardconex_acct_id \n       SET t2.bill_to_id = t1.bill_to_id\n     WHERE TRUE \n    ;\n    \n    -- SELECT * FROM tmp_02;\n    \n    -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|\n    -- --|-----------------|---------|------------------|----------|\n    --  2|b                |c        |A                 |c         |\n    --  4|e                |f        |A                 |          |\n    --  5|f                |g        |A                 |g         |\n    --  7|i                |j        |A                 |          |\n    --  8|j                |k        |A                 |          |\n    --  9|k                |l        |A                 |l         |\n    -- 11|n                |o        |A                 |          |\n    -- 12|o                |p        |A                 |          |\n    -- 13|p                |q        |A                 |          |\n    -- 14|q                |r        |A                 |r         |\n    -- 16|t                |u        |A                 |          |\n    -- 17|u                |v        |A                 |          |\n    -- 18|v                |w        |A                 |          |\n    -- 19|w                |x        |A                 |          |\n    -- 20|x                |y        |A                 |y         |\n    \n    -- SELECT * FROM (\n    --          SELECT * FROM tmp_01\n    --    UNION SELECT * FROM tmp_02\n    --   ) t3\n    --  ORDER BY 1\n    -- ;\n    \n    -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|\n    -- --|-----------------|---------|------------------|----------|\n    --  1|a                |*        |B                 |a         |\n    --  2|b                |c        |A                 |c         |\n    --  3|c                |*        |C                 |c         |\n    --  4|e                |f        |A                 |          |\n    --  5|f                |g        |A                 |g         |\n    --  6|g                |*        |D                 |g         |\n    --  7|i                |j        |A                 |          |\n    --  8|j                |k        |A                 |          |\n    --  9|k                |l        |A                 |l         |\n    -- 10|l                |*        |E                 |l         |\n    -- 11|n                |o        |A                 |          |\n    -- 12|o                |p        |A                 |          |\n    -- 13|p                |q        |A                 |          |\n    -- 14|q                |r        |A                 |r         |\n    -- 15|r                |*        |F                 |r         |\n    -- 16|t                |u        |A                 |          |\n    -- 17|u                |v        |A                 |          |\n    -- 18|v                |w        |A                 |          |\n    -- 19|w                |x        |A                 |          |\n    -- 20|x                |y        |A                 |y         |\n    -- 21|y                |*        |G                 |y         |\n    \n    \n    \n    -- Case 3\n    \n    /*  \n    \n        I need to join a self join on tmp_02 to proceed.  \n        But MariaDB apparently does not support that; see the following:\n        \n        SELECT a.*, b.*\n          FROM tmp_02   a \n          JOIN tmp_02   b \n            ON a.cardconex_acct_id = b.cardconex_acct_id;\n        SQL Error [1137] [HY000]: Can't reopen table: 'a'\n        \n        I will therefore have to create two copies of the same table and join those instead.\n        \n        It so happens that the code for Case 3 also workds for Case 4, 5, 6, ...\n        \n        So we can put that code in a loop.\n        \n        Finance has advised that four loops is enough.\n    \n    */\n    \n    SET i = 0;\n    \n    REPEAT\n        DROP TABLE IF EXISTS tmp_03;\n        DROP TABLE IF EXISTS tmp_04;\n        CREATE TEMPORARY TABLE tmp_03 SELECT * FROM tmp_02;\n        CREATE TEMPORARY TABLE tmp_04 SELECT * FROM tmp_02;\n        \n        -- SELECT \n        --      t3.cardconex_acct_id AS t3_cardconex_acct_id \n        --     ,t3.parent_id         AS t3_parent_id \n        --     ,t4.cardconex_acct_id AS t3_cardconex_acct_id \n        --     ,t4.parent_id         AS t4_parent_id\n        --     ,t4.bill_to_id\n        --   FROM tmp_03   t3\n        --   JOIN tmp_04   t4 \n        --     ON t3.parent_id = t4.cardconex_acct_id\n        --  WHERE t4.bill_to_id IS NOT NULL;\n         \n        -- t3_cardconex_acct_id|t3_parent_id|t3_cardconex_acct_id|t4_parent_id|bill_to_id|\n        -- --------------------|------------|--------------------|------------|----------|\n        -- e                   |f           |f                   |g           |g         |\n        -- j                   |k           |k                   |l           |l         |\n        -- p                   |q           |q                   |r           |r         |\n        -- w                   |x           |x                   |y           |y         |\n        \n        -- SELECT * FROM tmp_02 WHERE bill_to_id IS NULL;\n        \n        -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|\n        -- --|-----------------|---------|------------------|----------|\n        --  4|e                |f        |A                 |          |\n        --  7|i                |j        |A                 |          |\n        --  8|j                |k        |A                 |          |\n        -- 11|n                |o        |A                 |          |\n        -- 12|o                |p        |A                 |          |\n        -- 13|p                |q        |A                 |          |\n        -- 16|t                |u        |A                 |          |\n        -- 17|u                |v        |A                 |          |\n        -- 18|v                |w        |A                 |          |\n        -- 19|w                |x        |A                 |          |\n        \n        UPDATE tmp_02    t2 \n          JOIN (\n            SELECT \n                 t3.cardconex_acct_id AS t3_cardconex_acct_id \n                ,t3.parent_id         AS t3_parent_id \n                ,t4.cardconex_acct_id AS t4_cardconex_acct_id \n                ,t4.parent_id         AS t4_parent_id\n                ,t4.bill_to_id\n              FROM tmp_03   t3\n              JOIN tmp_04   t4 \n                ON t3.parent_id = t4.cardconex_acct_id\n             WHERE t4.bill_to_id IS NOT NULL   \n          ) t3 \n            ON t2.cardconex_acct_id = t3.t3_cardconex_acct_id \n           SET t2.bill_to_id = t3.bill_to_id \n         WHERE TRUE \n        ;\n      \n        SET i = i + 1;\n        \n        -- SELECT * FROM (\n        --          SELECT * FROM tmp_01\n        --    UNION SELECT * FROM tmp_02\n        --   ) t3\n        --  ORDER BY 1\n        -- ;\n        \n        -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|\n        -- --|-----------------|---------|------------------|----------|\n        --  1|a                |*        |B                 |a         |\n        --  2|b                |c        |A                 |c         |\n        --  3|c                |*        |C                 |c         |\n        --  4|e                |f        |A                 |g         |\n        --  5|f                |g        |A                 |g         |\n        --  6|g                |*        |D                 |g         |\n        --  7|i                |j        |A                 |          |\n        --  8|j                |k        |A                 |l         |\n        --  9|k                |l        |A                 |l         |\n        -- 10|l                |*        |E                 |l         |\n        -- 11|n                |o        |A                 |          |\n        -- 12|o                |p        |A                 |          |\n        -- 13|p                |q        |A                 |r         |\n        -- 14|q                |r        |A                 |r         |\n        -- 15|r                |*        |F                 |r         |\n        -- 16|t                |u        |A                 |          |\n        -- 17|u                |v        |A                 |          |\n        -- 18|v                |w        |A                 |          |\n        -- 19|w                |x        |A                 |y         |\n        -- 20|x                |y        |A                 |y         |\n        -- 21|y                |*        |G                 |y         |\n        \n     UNTIL i = num_levels\n       END REPEAT\n    ;\n  \n  INSERT INTO tmp_01 SELECT * FROM tmp_02;   -- combine case 1 and cases 2-6\n     \n--   SELECT \n--       t1.bill_to_id \n--      ,sc.cardconex_acct_id \n--      ,sc.dba_name \n--     FROM auto_billing_dw.f_auto_billing_complete_2 sc \n--     JOIN tmp_01                                         t1 \n--       ON sc.cardconex_acct_id = t1.cardconex_acct_id \n--   ;\n\n\n  SELECT 'Updating f_auto_billing_complete_2...' AS message;\n\n  UPDATE auto_billing_dw.f_auto_billing_complete_2\n     SET bill_to_id = NULL\n   WHERE TRUE \n  ;\n\n  UPDATE auto_billing_dw.f_auto_billing_complete_2  ab\n    JOIN tmp_01                                               t1 \n      ON ab.account_id = t1.cardconex_acct_id  \n     SET ab.bill_to_id = t1.bill_to_id \n   WHERE TRUE \n  ;\n\n\n  SELECT 'Updating f_auto_billing_complete_2...' AS message;\n\n  UPDATE auto_billing_dw.f_auto_billing_complete_2\n     SET bill_to_id = NULL\n   WHERE TRUE \n  ;\n   \n  UPDATE auto_billing_dw.f_auto_billing_complete_2            ab\n    JOIN tmp_01                                               t1 \n      ON ab.account_id = t1.cardconex_acct_id  \n     SET ab.bill_to_id = t1.bill_to_id \n   WHERE TRUE \n  ;\n\n\nEND	utf8	utf8_general_ci	latin1_swedish_ci