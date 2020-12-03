CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `auto_billing_dw`.`f_auto_billing_complete_decryptx`()
BEGIN
  
    DECLARE last_of_last_month DATE;
  
    SELECT 'Executing Stored Procedure' AS operation, 'f_auto_billing_complete_decryptx' AS stored_procedure, CURRENT_TIMESTAMP;
    
    SET last_of_last_month = CONVERT(DATE_FORMAT(CURRENT_DATE, '%Y%m01'), DATE) - INTERVAL 1 DAY;
      
    SET @stage = 0;
  
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP; 
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2      abc 
      JOIN (
          SELECT
              COALESCE(ddcm.cardconex_acct_id, dcm.cardconex_acct_id)         AS account_id
             ,SUM(ddd.decryptions_mtd)                                        AS decryptions_mtd
            FROM auto_billing_staging.decryptx_device_day                     ddd 
            LEFT JOIN auto_billing_staging.stg_decryptx_device_cardconex_map  ddcm ON ddd.poi_device_id = ddcm.decryptx_device_id 
            LEFT JOIN auto_billing_staging.stg_decryptx_cardconex_map         dcm  ON ddd.custodian_id  = dcm.decryptx_acct_id
           WHERE ddd.report_date = last_of_last_month
           GROUP BY 1
      ) ddd
        ON abc.account_id = ddd.account_id
       SET abc.decryption_count = COALESCE(ddd.decryptions_mtd, 0)
     WHERE TRUE 
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc 
      JOIN (
          SELECT     
               dca.account_id 
              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_activated_count
            FROM auto_billing_staging.decryptx_device_day             ddd
            JOIN auto_billing_staging.tmp_device_account_id   dca 
              ON ddd.poi_device_id = dca.poi_device_id
           WHERE ddd.report_date =  last_of_last_month
             AND ddd.state = 'Activated'
           GROUP BY 1
      ) t1 
        ON tdc.account_id = t1.account_id 
       SET tdc.device_activated_count = t1.device_activated_count
      WHERE TRUE 
    ; 
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc 
      JOIN (
          SELECT     
               dca.account_id 
              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_activating_activated_count
            FROM auto_billing_staging.decryptx_device_day             ddd
            JOIN auto_billing_staging.tmp_device_account_id   dca 
              ON ddd.poi_device_id = dca.poi_device_id
           WHERE ddd.report_date =  last_of_last_month
             AND ddd.state = 'Activating'
             AND ddd.decryptions_mtd > 0
           GROUP BY 1
      ) t1 
        ON tdc.account_id = t1.account_id 
       SET tdc.device_activating_activated_count = t1.device_activating_activated_count
      WHERE TRUE 
    ; 
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc 
      JOIN (
          SELECT     
               dca.account_id 
              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_activating_count
            FROM auto_billing_staging.decryptx_device_day             ddd
            JOIN auto_billing_staging.tmp_device_account_id   dca 
              ON ddd.poi_device_id = dca.poi_device_id
           WHERE ddd.report_date =  last_of_last_month
             AND ddd.state = 'Activating'
           GROUP BY 1
      ) t1 
        ON tdc.account_id = t1.account_id 
       SET tdc.device_activating_count = t1.device_activating_count
      WHERE TRUE 
    ; 
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc 
      JOIN (
          SELECT     
               dca.account_id 
              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_other_activated_count
            FROM auto_billing_staging.decryptx_device_day             ddd
            JOIN auto_billing_staging.tmp_device_account_id   dca 
              ON ddd.poi_device_id = dca.poi_device_id
           WHERE ddd.report_date =  last_of_last_month
             AND ddd.state NOT IN ('Activated', 'Activating', 'Stored')
             AND ddd.decryptions_mtd > 0
           GROUP BY 1
      ) t1 
        ON tdc.account_id = t1.account_id 
       SET tdc.device_other_activated_count = t1.device_other_activated_count
      WHERE TRUE 
    ; 
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc 
      JOIN (
          SELECT     
               dca.account_id 
              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_other_count
            FROM auto_billing_staging.decryptx_device_day             ddd
            JOIN auto_billing_staging.tmp_device_account_id   dca 
              ON ddd.poi_device_id = dca.poi_device_id
           WHERE ddd.report_date =  last_of_last_month
             AND ddd.state NOT IN ('Activated', 'Activating', 'Stored')
           GROUP BY 1
      ) t1 
        ON tdc.account_id = t1.account_id 
       SET tdc.device_other_count = t1.device_other_count
      WHERE TRUE 
    ; 
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc 
      JOIN (
          SELECT     
               dca.account_id 
              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_stored_activated_count
            FROM auto_billing_staging.decryptx_device_day             ddd
            JOIN auto_billing_staging.tmp_device_account_id   dca 
              ON ddd.poi_device_id = dca.poi_device_id
           WHERE ddd.report_date =  last_of_last_month
             AND ddd.state = 'Stored'
             AND ddd.decryptions_mtd > 0
           GROUP BY 1
      ) t1 
        ON tdc.account_id = t1.account_id 
       SET tdc.device_stored_activated_count = t1.device_stored_activated_count
      WHERE TRUE 
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc 
      JOIN (
          SELECT     
               dca.account_id 
              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_stored_count
            FROM auto_billing_staging.decryptx_device_day             ddd
            JOIN auto_billing_staging.tmp_device_account_id   dca 
              ON ddd.poi_device_id = dca.poi_device_id
           WHERE ddd.report_date =  last_of_last_month
             AND ddd.state = 'Stored'
           GROUP BY 1
      ) t1 
        ON tdc.account_id = t1.account_id 
       SET tdc.device_stored_count = t1.device_stored_count
      WHERE TRUE 
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2
       SET device_activated_count               = COALESCE(device_activated_count           , 0.0000) 
          ,device_activating_activated_count    = COALESCE(device_activating_activated_count, 0.0000) 
          ,device_activating_count              = COALESCE(device_activating_count          , 0.0000) 
          ,device_other_activated_count         = COALESCE(device_other_activated_count     , 0.0000) 
          ,device_other_count                   = COALESCE(device_other_count               , 0.0000) 
          ,device_stored_activated_count        = COALESCE(device_stored_activated_count    , 0.0000) 
          ,device_stored_count                  = COALESCE(device_stored_count, 0.0000) 
     WHERE decryptx = 1
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
        
    UPDATE auto_billing_dw.f_auto_billing_complete_2    abc 
      JOIN auto_billing_staging.stg_asset               asst 
        ON abc.account_id = asst.account_id
       SET abc.p2pe_device_activated_charge  = asst.p2pe_device_activated      * (abc.device_activated_count + abc.device_activating_activated_count + abc.device_stored_activated_count + abc.device_other_activated_count)
          ,abc.p2pe_device_activating_charge = asst.p2pe_device_activating_fee * (abc.device_activating_count - abc.device_activating_activated_count)
          ,abc.p2pe_device_stored_charge     = asst.p2pe_device_stored_fee     * (abc.device_stored_count - abc.device_stored_activated_count)
     WHERE TRUE 
    ;
    
END
