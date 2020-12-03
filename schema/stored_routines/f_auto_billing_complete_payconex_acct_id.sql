CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `auto_billing_dw`.`f_auto_billing_complete_payconex_acct_id`()
BEGIN
  
    /*
        
        Finance wants the auto_billing_complete table to include the payconex_acct_id and the payconex_acct_name that corresponds to it.
        But there can exists > 1 payconex_acct_id for the same account_id.  We will therefore have to define which payconex_acct_id to use 
        if there is more than one.
        
        Example
        -------
        
        account_id        |payconex_acct_id|payconex_acct_name                                          |cc_sale_vol|
        ------------------|----------------|------------------------------------------------------------|-----------|
        0013i00000FhCBCAA3|120615298861    |UCIMC Gavin Herbert Eye Institute GHEI LASIK Refractive Surg|     0.0000|
        0013i00000FhCBCAA3|120615298881    |UCIMC Gavin Herbert Eye Institute GHEI Opthalmology         | 92873.3300|
        0013i00000FhCBCAA3|120615298901    |UCIMC Gavin Herbert Eye Institute GHEI OR                   |129985.0700|
    
        Finance has advised that payconex_acct_id to use is the one that corresponds to the highest value of cc_sale_vol;
        i.e., the one in the third row above.
      
    */
    
    SELECT 'Executing Stored Procedure' AS operation, 'f_auto_billing_complete_payconex_acct_id' AS stored_procedure, CURRENT_TIMESTAMP;
    
    SELECT 'creating temporary table auto_billing_dw.tmp_pc_01' AS message;
  
    DROP TABLE IF EXISTS auto_billing_dw.tmp_pc_01;
    
    CREATE TEMPORARY TABLE auto_billing_dw.tmp_pc_01 (
         account_id           VARCHAR(255) 
        ,payconex_acct_id     VARCHAR(20)  
        ,payconex_acct_name   VARCHAR(255)  
        ,cc_sale_vol          DECIMAL(16,4)) 
    ;
    
    INSERT INTO auto_billing_dw.tmp_pc_01
    SELECT 
         pcm.cardconex_acct_id  AS account_id
        ,pv.acct_id             AS payconex_acct_id 
        ,pv.acct_name           AS payconex_acct_name
        ,pv.cc_sale_vol 
      FROM auto_billing_staging.stg_payconex_volume             pv 
      JOIN   auto_billing_staging.stg_payconex_cardconex_map    pcm 
        ON pv.acct_id = pcm.payconex_acct_id 
    --  WHERE pv.acct_id IN ('120615298861', '120615298881', '120615298901')
    ;
    
--     SELECT * FROM auto_billing_dw.tmp_pc_01;
    
    -- account_id        |payconex_acct_id|payconex_acct_name                                          |cc_sale_vol|
    -- ------------------|----------------|------------------------------------------------------------|-----------|
    -- 0013i00000FhCBCAA3|120615298861    |UCIMC Gavin Herbert Eye Institute GHEI LASIK Refractive Surg|     0.0000|
    -- 0013i00000FhCBCAA3|120615298881    |UCIMC Gavin Herbert Eye Institute GHEI Opthalmology         | 92873.3300|
    -- 0013i00000FhCBCAA3|120615298901    |UCIMC Gavin Herbert Eye Institute GHEI OR                   |129985.0700|
    
    SELECT 'creating temporary table auto_billing_dw.tmp_pc_02' AS message;

    DROP TABLE IF EXISTS auto_billing_dw.tmp_pc_02;
    
    CREATE TEMPORARY TABLE auto_billing_dw.tmp_pc_02(
         account_id               VARCHAR(18)
        ,payconex_acct_id         VARCHAR(20)
        ,payconex_acct_name       VARCHAR(255)
        ,cc_sale_vol              DECIMAL(15, 4)
        ,UNIQUE(account_id)
    )
    ;
    
    INSERT INTO auto_billing_dw.tmp_pc_02(account_id, cc_sale_vol)
    SELECT account_id, MAX(cc_sale_vol) AS max_cc_sale_vol 
      FROM auto_billing_dw.tmp_pc_01
     GROUP BY 1
    ;
    
--     SELECT * FROM auto_billing_dw.tmp_pc_02;
    
    -- account_id        |payconex_acct_id|payconex_acct_name|cc_sale_vol|
    -- ------------------|----------------|------------------|-----------|
    -- 0013i00000FhCBCAA3|                |                  |129985.0700|
       
    UPDATE auto_billing_dw.tmp_pc_02    t2 
      JOIN auto_billing_dw.tmp_pc_01    t1 
        ON t2.account_id = t1.account_id 
       AND t2.cc_sale_vol = t1.cc_sale_vol 
       SET t2.payconex_acct_id = t1.payconex_acct_id 
          ,t2.payconex_acct_name = t1.payconex_acct_name
     WHERE TRUE 
    ;
    
    -- SELECT * FROM auto_billing_dw.tmp_pc_02;
    
    -- account_id        |payconex_acct_id|payconex_acct_name                       |cc_sale_vol|
    -- ------------------|----------------|-----------------------------------------|-----------|
    -- 0013i00000FhCBCAA3|120615298901    |UCIMC Gavin Herbert Eye Institute GHEI OR|129985.0700|
    
    UPDATE auto_billing_dw.tmp_pc_01   t1 
      JOIN auto_billing_dw.tmp_pc_02   t2 
        ON t1.account_id = t2.account_id 
       SET t1.payconex_acct_id = t2.payconex_acct_id 
          ,t1.payconex_acct_name = t2.payconex_acct_name 
     WHERE TRUE 
    ;
    
    -- SELECT * FROM auto_billing_dw.tmp_pc_01;
    
    -- account_id        |payconex_acct_id|payconex_acct_name                       |cc_sale_vol|
    -- ------------------|----------------|-----------------------------------------|-----------|
    -- 0013i00000FhCBCAA3|120615298901    |UCIMC Gavin Herbert Eye Institute GHEI OR|     0.0000|
    -- 0013i00000FhCBCAA3|120615298901    |UCIMC Gavin Herbert Eye Institute GHEI OR| 92873.3300|
    -- 0013i00000FhCBCAA3|120615298901    |UCIMC Gavin Herbert Eye Institute GHEI OR|129985.0700|
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2    abc
      JOIN auto_billing_dw.tmp_pc_01                    t01 
        ON abc.account_id = t01.account_id 
       SET abc.payconex_acct_id = t01.payconex_acct_id 
          ,abc.payconex_acct_name = t01.payconex_acct_name
     WHERE TRUE 
    ;
    
    -- SELECT account_id, payconex, payconex_acct_id , payconex_acct_ids , payconex_acct_name FROM auto_billing_dw.f_auto_billing_complete_2 WHERE account_id = '0013i00000FhCBCAA3';
    
    SET SESSION group_concat_max_len = 102400;  -- this is needed in order to prevent a 'MySQL error code 1260 (ER_CUT_VALUE_GROUP_CONCAT): Row %u was cut by GROUP_CONCAT()' error.
    SHOW VARIABLES LIKE 'group_concat_max_len';

    SELECT 'updating auto_billing_dw.f_auto_billing_complete_2' AS message;
    
--     UPDATE auto_billing_dw.f_auto_billing_complete_2      abc 
--       JOIN (
--             SELECT 
--                  account_id             
--                 ,LEFT(GROUP_CONCAT(DISTINCT payconex_acct_id ORDER BY cc_sale_vol DESC SEPARATOR ' | '), 72) AS payconex_acct_ids
--               FROM auto_billing_dw.tmp_pc_01
--              GROUP BY 1  
--              ORDER BY LENGTH(GROUP_CONCAT(payconex_acct_id ORDER BY cc_sale_vol DESC SEPARATOR ' | ')) DESC 
--       ) t1 
--         ON abc.account_id = t1.account_id
--        SET abc.payconex_acct_ids = t1.payconex_acct_ids
--      WHERE TRUE 
--     ;
    
    -- SELECT 
    --      account_id 
    --     ,GROUP_CONCAT(payconex_acct_id ORDER BY cc_sale_vol DESC SEPARATOR ' | ')
    --   FROM auto_billing_dw.tmp_pc_01
    --  GROUP BY 1
    -- ;
    
    -- SELECT * FROM auto_billing_staging.stg_payconex_volume WHERE acct_id = '120615298901';
    

END
