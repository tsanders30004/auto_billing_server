CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `auto_billing_dw`.`update_bill_to_id`()
    COMMENT 'USAGE:  update_bill_to_id */ Calculates and populates bill_to_id. */'
BEGIN

    /*
    
        Purpose:  Calculate the bill_to_id.
        
        Note the following:
    
        MariaDB [sales_force]> SELECT billing_preference__c, COUNT(*) FROM sales_force.account GROUP BY 1;
        +-----------------------+----------+
        | billing_preference__c | COUNT(*) |
        +-----------------------+----------+
        | NULL                  |    21702 |
        | Aggregated Billing    |     4235 |
        | Client Level Only     |       42 |
        | Direct Billing        |     9687 |
        | Processor Only        |    30928 |
        +-----------------------+----------+
        5 rows in set (3.38 sec)
    
        Rows in sales_force.account for which billing_preference__c != 'Aggregated' are billed directly.
        
        Rows in sales_force.account for which billing_preference__c = 'Aggregated' are billed to a parent account, based on the value of account.parentid.
        It may be be necessary to traverse multiple 'levels' to find the parent.
        
        See the simulated data below; the calculated value of bill_to_id is shown.
        
        cardconex_acct_id|parent_id|billing_preference|bill_to_id|
        -----------------|---------|------------------|----------|
        a                |*        |Client Level Only |a         |   -- case 1
        
        b                |c        |Aggregated Billing|c         |   -- case 2
        c                |*        |Direct Billing    |c         |
        
        e                |f        |Aggregated Billing|g         |   -- case 3
        f                |g        |Aggregated Billing|g         |
        g                |*        |Processor Only    |g         |
        
        i                |j        |Aggregated Billing|l         |   -- case 4
        j                |k        |Aggregated Billing|l         |
        k                |l        |Aggregated Billing|l         |
        l                |*        |Processor Only    |l         |
        
        n                |o        |Aggregated Billing|r         |   -- case 5
        o                |p        |Aggregated Billing|r         |
        p                |q        |Aggregated Billing|r         |
        q                |r        |Aggregated Billing|r         |
        r                |*        |Processor Only    |r         |
        
        t                |u        |Aggregated Billing|y         |   -- case 6
        u                |v        |Aggregated Billing|y         |
        v                |w        |Aggregated Billing|y         |
        w                |x        |Aggregated Billing|y         |
        x                |y        |Aggregated Billing|y         |
        y                |*        |Processor Only    |y         |
        
        Case 1 (One Level)
        ------------------
        Since billing_preference != 'Aggregated Billing, the account is billed directly; i.e, bill_to_id = cardconex_acct_id
        
        Case 2 (Two Levels)
        -------------------
        billing_preference = 'Aggregated Billing', so this account is not billed directly.
     
        Consider the following:
        
        cardconex_acct_id|parent_id|billing_preference|
        -----------------|---------|------------------|
        b                |c        |Aggregated Billing|
        c                |*        |Direct Billing    |
        
        We need to calculate the bill_to_id for cardconex_acct_id = 'b'.
        billing_preference = 'Aggregated Billing', so we have the find the parent.
        
        In this case, the parent_id = 'c'.  The value of billing_preference for cardconex_acct_id = 'c' = 'Direct Billing', so 'c' is the parent.
        Therefore, the bill_to_id for cardconex_acct_id IN ('b', 'c') = 'Direct Billing.
        
        Cases 3, 4, 5, ... (Three Or More Levels)
        -----------------------------------------
        These are variations for Case 2, with an increasing number of levels.
        See the desired output in the table above for each of these cases.   
    
    */
    
    DECLARE i           TINYINT UNSIGNED;
    DECLARE num_levels  TINYINT UNSIGNED DEFAULT 4;   -- number of times to repeat the loop for cases 3-6

    SELECT 'Executing Stored Procedure' AS operation, 'update_bill_to_id' AS stored_procedure, CURRENT_TIMESTAMP;
    
    -- Case 1
    
    SET @ab = 'Aggregated Billing';
    
    DROP TABLE IF EXISTS tmp_01;
    
    CREATE TEMPORARY TABLE tmp_01(
        cardconex_acct_id     VARCHAR(32)
       ,parent_id             VARCHAR(32)
       ,billing_preference    VARCHAR(32)
       ,bill_to_id            VARCHAR(32)
       ,PRIMARY KEY(cardconex_acct_id)
       ,KEY idx_parent_id(parent_id)
    );
    

    -- NULL values of billing_preference__c should be interpreted as 'Direct Billing'.  
    -- This is not currently configured in the database or in the warehouse, so it is being done here.
    
    SELECT 'NULL values of sales_force.account.billing_preference__c will be interpreted as \'Direct Billing\'' AS message;
  
    INSERT INTO tmp_01 
    SELECT 
         id                       AS cardconex_acct_id 
        ,parentid                 AS parent_id 
        ,'Direct Billing'         AS billing_preference
        ,NULL                     AS bill_to_id
      FROM sales_force.account 
     WHERE billing_preference__c IS NULL
    ;
  
    INSERT INTO tmp_01 
    SELECT 
         id                       AS cardconex_acct_id 
        ,parentid                 AS parent_id 
        ,billing_preference__c    AS billing_preference
        ,NULL                     AS bill_to_id
      FROM sales_force.account 
     WHERE billing_preference__c != @ab
    ;
    
    UPDATE tmp_01
       SET bill_to_id = cardconex_acct_id
     WHERE TRUE 
    ;  
    
    -- SELECT * FROM tmp_01;
    -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|
    -- --|-----------------|---------|------------------|----------|
    --  1|a                |*        |B                 |a         |
    --  3|c                |*        |C                 |c         |
    --  6|g                |*        |D                 |g         |
    -- 10|l                |*        |E                 |l         |
    -- 15|r                |*        |F                 |r         |
    -- 21|y                |*        |G                 |y         |
    
    -- Case 2
    
    DROP TABLE IF EXISTS tmp_02;
    
    CREATE TEMPORARY TABLE tmp_02 LIKE tmp_01;
    
    INSERT INTO tmp_02
    SELECT 
         id                       AS cardconex_acct_id 
        ,parentid                 AS parent_id 
        ,billing_preference__c    AS billing_preference
        ,NULL                     AS bill_to_id
      FROM sales_force.account 
     WHERE billing_preference__c = @ab
    ;
    
    UPDATE tmp_02     t2 
      JOIN tmp_01     t1 
        ON t2.parent_id = t1.cardconex_acct_id 
       SET t2.bill_to_id = t1.bill_to_id
     WHERE TRUE 
    ;
    
    -- SELECT * FROM tmp_02;
    
    -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|
    -- --|-----------------|---------|------------------|----------|
    --  2|b                |c        |A                 |c         |
    --  4|e                |f        |A                 |          |
    --  5|f                |g        |A                 |g         |
    --  7|i                |j        |A                 |          |
    --  8|j                |k        |A                 |          |
    --  9|k                |l        |A                 |l         |
    -- 11|n                |o        |A                 |          |
    -- 12|o                |p        |A                 |          |
    -- 13|p                |q        |A                 |          |
    -- 14|q                |r        |A                 |r         |
    -- 16|t                |u        |A                 |          |
    -- 17|u                |v        |A                 |          |
    -- 18|v                |w        |A                 |          |
    -- 19|w                |x        |A                 |          |
    -- 20|x                |y        |A                 |y         |
    
    -- SELECT * FROM (
    --          SELECT * FROM tmp_01
    --    UNION SELECT * FROM tmp_02
    --   ) t3
    --  ORDER BY 1
    -- ;
    
    -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|
    -- --|-----------------|---------|------------------|----------|
    --  1|a                |*        |B                 |a         |
    --  2|b                |c        |A                 |c         |
    --  3|c                |*        |C                 |c         |
    --  4|e                |f        |A                 |          |
    --  5|f                |g        |A                 |g         |
    --  6|g                |*        |D                 |g         |
    --  7|i                |j        |A                 |          |
    --  8|j                |k        |A                 |          |
    --  9|k                |l        |A                 |l         |
    -- 10|l                |*        |E                 |l         |
    -- 11|n                |o        |A                 |          |
    -- 12|o                |p        |A                 |          |
    -- 13|p                |q        |A                 |          |
    -- 14|q                |r        |A                 |r         |
    -- 15|r                |*        |F                 |r         |
    -- 16|t                |u        |A                 |          |
    -- 17|u                |v        |A                 |          |
    -- 18|v                |w        |A                 |          |
    -- 19|w                |x        |A                 |          |
    -- 20|x                |y        |A                 |y         |
    -- 21|y                |*        |G                 |y         |
    
    
    
    -- Case 3
    
    /*  
    
        I need to join a self join on tmp_02 to proceed.  
        But MariaDB apparently does not support that; see the following:
        
        SELECT a.*, b.*
          FROM tmp_02   a 
          JOIN tmp_02   b 
            ON a.cardconex_acct_id = b.cardconex_acct_id;
        SQL Error [1137] [HY000]: Can't reopen table: 'a'
        
        I will therefore have to create two copies of the same table and join those instead.
        
        It so happens that the code for Case 3 also workds for Case 4, 5, 6, ...
        
        So we can put that code in a loop.
        
        Finance has advised that four loops is enough.
    
    */
    
    SET i = 0;
    
    REPEAT
        DROP TABLE IF EXISTS tmp_03;
        DROP TABLE IF EXISTS tmp_04;
        CREATE TEMPORARY TABLE tmp_03 SELECT * FROM tmp_02;
        CREATE TEMPORARY TABLE tmp_04 SELECT * FROM tmp_02;
        
        -- SELECT 
        --      t3.cardconex_acct_id AS t3_cardconex_acct_id 
        --     ,t3.parent_id         AS t3_parent_id 
        --     ,t4.cardconex_acct_id AS t3_cardconex_acct_id 
        --     ,t4.parent_id         AS t4_parent_id
        --     ,t4.bill_to_id
        --   FROM tmp_03   t3
        --   JOIN tmp_04   t4 
        --     ON t3.parent_id = t4.cardconex_acct_id
        --  WHERE t4.bill_to_id IS NOT NULL;
         
        -- t3_cardconex_acct_id|t3_parent_id|t3_cardconex_acct_id|t4_parent_id|bill_to_id|
        -- --------------------|------------|--------------------|------------|----------|
        -- e                   |f           |f                   |g           |g         |
        -- j                   |k           |k                   |l           |l         |
        -- p                   |q           |q                   |r           |r         |
        -- w                   |x           |x                   |y           |y         |
        
        -- SELECT * FROM tmp_02 WHERE bill_to_id IS NULL;
        
        -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|
        -- --|-----------------|---------|------------------|----------|
        --  4|e                |f        |A                 |          |
        --  7|i                |j        |A                 |          |
        --  8|j                |k        |A                 |          |
        -- 11|n                |o        |A                 |          |
        -- 12|o                |p        |A                 |          |
        -- 13|p                |q        |A                 |          |
        -- 16|t                |u        |A                 |          |
        -- 17|u                |v        |A                 |          |
        -- 18|v                |w        |A                 |          |
        -- 19|w                |x        |A                 |          |
        
        UPDATE tmp_02    t2 
          JOIN (
            SELECT 
                 t3.cardconex_acct_id AS t3_cardconex_acct_id 
                ,t3.parent_id         AS t3_parent_id 
                ,t4.cardconex_acct_id AS t4_cardconex_acct_id 
                ,t4.parent_id         AS t4_parent_id
                ,t4.bill_to_id
              FROM tmp_03   t3
              JOIN tmp_04   t4 
                ON t3.parent_id = t4.cardconex_acct_id
             WHERE t4.bill_to_id IS NOT NULL   
          ) t3 
            ON t2.cardconex_acct_id = t3.t3_cardconex_acct_id 
           SET t2.bill_to_id = t3.bill_to_id 
         WHERE TRUE 
        ;
      
        SET i = i + 1;
        
        -- SELECT * FROM (
        --          SELECT * FROM tmp_01
        --    UNION SELECT * FROM tmp_02
        --   ) t3
        --  ORDER BY 1
        -- ;
        
        -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|
        -- --|-----------------|---------|------------------|----------|
        --  1|a                |*        |B                 |a         |
        --  2|b                |c        |A                 |c         |
        --  3|c                |*        |C                 |c         |
        --  4|e                |f        |A                 |g         |
        --  5|f                |g        |A                 |g         |
        --  6|g                |*        |D                 |g         |
        --  7|i                |j        |A                 |          |
        --  8|j                |k        |A                 |l         |
        --  9|k                |l        |A                 |l         |
        -- 10|l                |*        |E                 |l         |
        -- 11|n                |o        |A                 |          |
        -- 12|o                |p        |A                 |          |
        -- 13|p                |q        |A                 |r         |
        -- 14|q                |r        |A                 |r         |
        -- 15|r                |*        |F                 |r         |
        -- 16|t                |u        |A                 |          |
        -- 17|u                |v        |A                 |          |
        -- 18|v                |w        |A                 |          |
        -- 19|w                |x        |A                 |y         |
        -- 20|x                |y        |A                 |y         |
        -- 21|y                |*        |G                 |y         |
        
     UNTIL i = num_levels
       END REPEAT
    ;
  
  INSERT INTO tmp_01 SELECT * FROM tmp_02;   -- combine case 1 and cases 2-6
     
--   SELECT 
--       t1.bill_to_id 
--      ,sc.cardconex_acct_id 
--      ,sc.dba_name 
--     FROM auto_billing_dw.f_auto_billing_complete_shieldconex sc 
--     JOIN tmp_01                                         t1 
--       ON sc.cardconex_acct_id = t1.cardconex_acct_id 
--   ;


  SELECT 'Updating f_auto_billing_complete_shieldconex...' AS message;

  UPDATE auto_billing_dw.f_auto_billing_complete_shieldconex
     SET bill_to_id = NULL
   WHERE TRUE 
  ;

  UPDATE auto_billing_dw.f_auto_billing_complete_shieldconex  ab
    JOIN tmp_01                                               t1 
      ON ab.cardconex_acct_id = t1.cardconex_acct_id  
     SET ab.bill_to_id = t1.bill_to_id 
   WHERE TRUE 
  ;


  SELECT 'Updating f_auto_billing_complete_2...' AS message;

  UPDATE auto_billing_dw.f_auto_billing_complete_2
     SET bill_to_id = NULL
   WHERE TRUE 
  ;
   
  UPDATE auto_billing_dw.f_auto_billing_complete_2            ab
    JOIN tmp_01                                               t1 
      ON ab.account_id = t1.cardconex_acct_id  
     SET ab.bill_to_id = t1.bill_to_id 
   WHERE TRUE 
  ;


END
