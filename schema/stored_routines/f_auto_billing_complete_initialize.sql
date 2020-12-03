CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `auto_billing_dw`.`f_auto_billing_complete_initialize`()
    COMMENT 'USAGE:  f_auto_billing_complete_initialize /* initialize f_auto_billing_complete_2 with account_ids */'
BEGIN
  
    DECLARE last_of_last_month  DATE;
  
    SET last_of_last_month = CONVERT(DATE_FORMAT(CURRENT_DATE, '%Y%m01'), DATE) - INTERVAL 1 DAY;
  
    SELECT 'Executing Stored Procedure' AS operation, 'f_auto_billing_complete_initialize' AS stored_procedure, CURRENT_TIMESTAMP;
   
    -- get list of cardconex_acct_id's originating from decryptx
    
    SELECT 'retrieving decryptx account_id\'s' AS stage, CURRENT_TIMESTAMP;
    
    DROP TABLE IF EXISTS auto_billing_staging.tmp_device_account_id;
    
    CREATE TABLE auto_billing_staging.tmp_device_account_id (
         poi_device_id VARCHAR(16)
        ,account_id VARCHAR(18) 
        ,PRIMARY KEY(poi_device_id)
    );
    
    INSERT INTO auto_billing_staging.tmp_device_account_id
    SELECT
        ddd.poi_device_id                                               AS poi_device_id                                    
       ,COALESCE(ddcm.cardconex_acct_id, dcm.cardconex_acct_id)         AS account_id
      FROM auto_billing_staging.decryptx_device_day                     ddd 
      LEFT JOIN auto_billing_staging.stg_decryptx_device_cardconex_map  ddcm ON ddd.poi_device_id = ddcm.decryptx_device_id 
      LEFT JOIN auto_billing_staging.stg_decryptx_cardconex_map         dcm  ON ddd.custodian_id  = dcm.decryptx_acct_id
     WHERE ddd.report_date = last_of_last_month
    ;
    
    -- get list of cardconex_acct_id's originating from payconex
    SELECT 'retrieving payconex account_id\'s' AS stage, CURRENT_TIMESTAMP;
      
    DROP TABLE IF EXISTS auto_billing_staging.tmp_payconex_account_id;
    
    CREATE  TABLE auto_billing_staging.tmp_payconex_account_id(
         account_id VARCHAR(18) PRIMARY KEY
    );
    
    INSERT IGNORE INTO auto_billing_staging.tmp_payconex_account_id
    SELECT pcm.cardconex_acct_id
      FROM auto_billing_staging.stg_payconex_volume                 pvd 
      LEFT JOIN auto_billing_staging.stg_payconex_cardconex_map     pcm 
        ON pvd.acct_id = pcm.payconex_acct_id 
    ;
    
    -- populate f_auto_billing_complete_2
    
    TRUNCATE auto_billing_dw.f_auto_billing_complete_2;
    
    SELECT 'inserting account_id\'s' AS stage, CURRENT_TIMESTAMP;
  
    INSERT IGNORE INTO auto_billing_dw.f_auto_billing_complete_2(account_id)
    SELECT account_id
      FROM auto_billing_staging.tmp_device_account_id
    ;
    
    INSERT IGNORE INTO auto_billing_dw.f_auto_billing_complete_2(account_id)
    SELECT account_id
      FROM auto_billing_staging.tmp_payconex_account_id
    ;
      
    DELETE FROM auto_billing_dw.f_auto_billing_complete_2 WHERE account_id IS NULL OR LENGTH(account_id) = 0;
   
    UPDATE auto_billing_dw.f_auto_billing_complete_2      t1
      JOIN auto_billing_staging.tmp_device_account_id     t2 
        ON t1.account_id = t2.account_id 
       SET t1.decryptx = 1
     WHERE TRUE
    ;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2      t1
      JOIN auto_billing_staging.tmp_payconex_account_id   t2 
        ON t1.account_id = t2.account_id 
       SET t1.payconex = 1
     WHERE TRUE
    ;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2
       SET decryptx    = COALESCE(decryptx, 0)
          ,payconex    = COALESCE(payconex, 0)
          ,shieldconex = 0
     WHERE TRUE 
    ;
    
END
