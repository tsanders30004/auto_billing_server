CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `auto_billing_dw`.`update_shieldconex_fees_and_charges`()
    COMMENT 'USAGE: update_shieldconex_fees_and_charges */ Calculates and updates ShieldConex charges and fees. */'
BEGIN

    -- ShieldConex
    
    -- objective:  calculation shieldconex fees
    
    SELECT 'Executing Stored Procedure' AS operation, 'update_shieldconex_fees_and_charges' AS stored_procedure, CURRENT_TIMESTAMP;
    
    DROP TABLE IF EXISTS auto_billing_staging.tmp_asset;
    
    CREATE TEMPORARY TABLE auto_billing_staging.tmp_asset(
         client_id                      VARCHAR(32) NOT NULL 
        ,cardconex_acct_id              VARCHAR(18) NOT NULL 
        ,shieldconex_monthly_fee        DECIMAL(12, 5) NOT NULL
        ,shieldconex_monthly_minimum    DECIMAL(12, 5) NOT NULL
        ,shieldconex_transaction_fee    DECIMAL(12, 5) NOT NULL
        ,shieldconex_fields_fee         DECIMAL(12, 5) NOT NULL
        ,PRIMARY KEY(client_id)
    );
    
    SELECT 'de-normalizing ShieldConex fees' AS message;
  
    -- Populate the table
    INSERT INTO auto_billing_staging.tmp_asset
    SELECT 
         client_id
        ,cardconex_acct_id
        ,SUM(shieldconex_monthly_fee)         AS shieldconex_monthly_fee
        ,SUM(shieldconex_monthly_minimum)     AS shieldconex_monthly_minimum
        ,SUM(shieldconex_transaction_fee)     AS shieldconex_transaction_fee
        ,SUM(shieldconex_fields_charge)       AS shieldconex_fields_charge
      FROM (
          SELECT 
             cardconex_acct_id 
            ,client_id 
            ,(fee_name = 'shieldconex_monthly_fee'    ) * fee_amount AS shieldconex_monthly_fee
            ,(fee_name = 'shieldconex_monthly_minimum') * fee_amount AS shieldconex_monthly_minimum
            ,(fee_name = 'shieldconex_transaction_fee') * fee_amount AS shieldconex_transaction_fee
            ,(fee_name = 'shieldconex_fields_fee'  )    * fee_amount AS shieldconex_fields_charge
          FROM (
                SELECT 
                    asst.accountid                        AS cardconex_acct_id
                   ,COALESCE(idn.name, 'undefined')       AS client_id
                   ,fm.fee                                AS fee_name
                   ,COALESCE(asst.fee_amount__c, 0.00000) AS fee_amount
                  FROM sales_force.asset                  asst 
                  JOIN sales_force.fee_map                fm 
                    ON asst.fee_name__c = fm.fee_name
                  JOIN sales_force.identification_number__c   idn 
                    ON asst.accountid = idn.accountid__c 
                 WHERE fm.fee IN (
                        'shieldconex_monthly_fee'   
                       ,'shieldconex_monthly_minimum'
                       ,'shieldconex_transaction_fee'
                       ,'shieldconex_fields_fee')
          ) t1 
      ) t2 
     GROUP BY 1, 2
     ORDER BY 1, 2
    ; 
    
    SELECT * FROM auto_billing_staging.tmp_asset;
    
    -- Sample Output
    -- client_id|cardconex_acct_id |shieldconex_monthly_fee|shieldconex_monthly_minimum|shieldconex_transaction_fee|shieldconex_fields_charge|
    -- ---------|------------------|-----------------------|---------------------------|---------------------------|-------------------------|
    -- 20       |0013i00000IsUq7AAF|                0.00000|                  250.00000|                    0.02100|                  0.00000|
    -- 33       |0013i00000QqgelAAB|                0.00000|                 5000.00000|                    0.00175|                  0.00000|
    
    
    -- SELECT
    --      acct.name
    --     ,asst.*
    --   FROM auto_billing_staging.tmp_asset   asst
    --   JOIN sales_force.account              acct
    --     ON asst.cardconex_acct_id = acct.id
    --  ORDER BY 1 * client_id
    -- ;
    
    -- name                         |client_id|cardconex_acct_id |shieldconex_monthly_fee|shieldconex_monthly_minimum|shieldconex_transaction_fee|shieldconex_fields_fee|
    -- -----------------------------|---------|------------------|-----------------------|---------------------------|---------------------------|----------------------|
    -- Alaska Airlines - ShieldConex|20       |0013i00000IsUq7AAF|                0.00000|                  250.00000|                    0.02100|               0.00000|
    -- PAAY LLC                     |33       |0013i00000QqgelAAB|                0.00000|                 5000.00000|                    0.00175|               0.00000|
    
    
    -- All numeric columns:  INT UNSIGNED NOT NULL DEFAULT 0; no need for COALESCE function this time.
    
    SELECT 'populating temporary table 1' AS message;
  
    DROP TABLE IF EXISTS auto_billing_staging.tmp_shieldconex;
    
    CREATE TEMPORARY TABLE auto_billing_staging.tmp_shieldconex(
         client_id               VARCHAR(16) NOT NULL
        ,client_name             VARCHAR(64)
        ,partner_name            VARCHAR(64)
        ,total_bad_tokenized     INT UNSIGNED NOT NULL
        ,total_good_detokenized  INT UNSIGNED NOT NULL
        ,total_good_tokenized    INT UNSIGNED NOT NULL
        ,total_bad_detokenized   INT UNSIGNED NOT NULL 
        ,good_tokenized_fields   INT UNSIGNED NOT NULL
        ,bad_tokenized_fields    INT UNSIGNED NOT NULL
        ,good_detokenized_fields INT UNSIGNED NOT NULL
        ,bad_detokenized_fields  INT UNSIGNED NOT NULL
        ,PRIMARY KEY(client_id)
    );
    
    INSERT INTO auto_billing_staging.tmp_shieldconex
    SELECT 
        client_id 
       ,client_name 
       ,partner_name
       ,total_bad_tokenized 
       ,total_good_detokenized 
       ,total_good_tokenized     
       ,total_bad_detokenized
       ,good_tokenized_fields 
       ,bad_tokenized_fields 
       ,good_detokenized_fields 
       ,bad_detokenized_fields 
      FROM auto_billing_staging.stg_shieldconex
     WHERE complete_date = DATE_FORMAT(CURRENT_DATE - INTERVAL 1 MONTH, '%Y%m01')
       AND client_name NOT LIKE 'client_name%'
    ;
    
    -- SELECT * FROM auto_billing_staging.tmp_shieldconex;
    
    -- client_id|client_name    |partner_name   |total_bad_tokenized|total_good_detokenized|total_good_tokenized|total_bad_detokenized|good_tokenized_fields|bad_tokenized_fields|good_detokenized_fields|bad_detokenized_fields|
    -- ---------|---------------|---------------|-------------------|----------------------|--------------------|---------------------|---------------------|--------------------|-----------------------|----------------------|
    -- 20       |Contact Centers|Alaska Airlines|                 61|                   132|                 132|                    0|                  528|                 244|                    528|                     0|
    -- 33       |Paay           |Paay LLC       |                 18|                413372|              860487|                    7|               860487|                  18|                 413372|                     7|
    
    
    -- identify client_id's which exist in sales_force.asset or auto_billing_staging.stg_shieldconex BUT NOT BOTH.
    -- get a 'master list' of client_id's to start.
    
  
    DROP TABLE IF EXISTS auto_billing_staging.tmp_client_id;
    
    CREATE TEMPORARY TABLE auto_billing_staging.tmp_client_id SELECT client_id FROM auto_billing_staging.tmp_asset UNION SELECT client_id FROM auto_billing_staging.tmp_shieldconex;
    
    -- SELECT * FROM auto_billing_staging.tmp_client_id;
    
    -- show a list of client_id's are missing data in one or more tables
    SELECT 
         COALESCE(acct.name, 'NULL')                    AS account_name
        ,sc.partner_name
        ,t1.client_id                                   AS client_id
        ,IF(sc.client_id IS NULL, 'missing', 'ok')      AS stg_shieldconex
        ,IF(asst.client_id IS NULL, 'missing', 'ok')    AS asset 
        ,IF(idn.name IS NOT NULL, 'ok', 'missing')      AS identification_number__c
        ,idn.type__c                                    AS identification_number_type__c
      FROM auto_billing_staging.tmp_client_id           t1 
      LEFT JOIN auto_billing_staging.tmp_asset          asst
        ON t1.client_id = asst.client_id
      LEFT JOIN sales_force.identification_number__c    idn 
        ON t1.client_id = idn.name
      LEFT JOIN sales_force.account                     acct 
        ON idn.accountid__c = acct.id
      LEFT JOIN auto_billing_staging.tmp_shieldconex    sc 
        ON t1.client_id = sc.client_id
     WHERE idn.type__c = 'ShieldConex'
        OR idn.type__c IS NULL
     ORDER BY acct.name IS NULL, acct.name, 1 * t1.client_id
    ;
    
    SELECT 'populating temporary table 2' AS message;
  
    DROP TABLE IF EXISTS auto_billing_staging.tmp_calc_shieldconex_charges;
    
    CREATE TABLE auto_billing_staging.tmp_calc_shieldconex_charges(
       client_id                           VARCHAR(32)   NOT NULL,
       cardconex_acct_id                   VARCHAR(18)   NOT NULL,
       client_name                         VARCHAR(64)   DEFAULT NULL,
       shieldconex_monthly_fee             DECIMAL(10,5) NOT NULL,
       shieldconex_monthly_minimum         DECIMAL(10,5) NOT NULL,
       shieldconex_transaction_fee         DECIMAL(10,5) NOT NULL,
       shieldconex_fields_fee              DECIMAL(10,5) NOT NULL,
       total_bad_tokenized                 INT UNSIGNED  NOT NULL,
       total_good_detokenized              INT UNSIGNED  NOT NULL,
       total_good_tokenized                INT UNSIGNED  NOT NULL,
       total_bad_detokenized               INT UNSIGNED  NOT NULL,
       good_tokenized_fields               INT UNSIGNED  NOT NULL,
       bad_tokenized_fields                INT UNSIGNED  NOT NULL,
       good_detokenized_fields             INT UNSIGNED  NOT NULL,
       bad_detokenized_fields              INT UNSIGNED  NOT NULL,
       shieldconex_monthly_charge          DECIMAL(10,5) NOT NULL DEFAULT 0.00000,
       shieldconex_transaction_charge      DECIMAL(10,5) NOT NULL DEFAULT 0.00000,
       shieldconex_monthly_minimum_charge  DECIMAL(10,5) NOT NULL DEFAULT 0.00000,
       shieldconex_fields_charge           DECIMAL(10,5) NOT NULL DEFAULT 0.00000,
       PRIMARY KEY(client_id),
       UNIQUE(cardconex_acct_id)
    )
    ;
    
    -- DESC auto_billing_staging.tmp_calc_shieldconex_charges;
    
    INSERT INTO auto_billing_staging.tmp_calc_shieldconex_charges
    SELECT 
         asst.client_id 
        ,asst.cardconex_acct_id 
        ,sc.client_name
        ,asst.shieldconex_monthly_fee
        ,asst.shieldconex_monthly_minimum
        ,asst.shieldconex_transaction_fee
        ,asst.shieldconex_fields_fee
        ,sc.total_bad_tokenized    
        ,sc.total_good_detokenized 
        ,sc.total_good_tokenized   
        ,sc.total_bad_detokenized  
        ,sc.good_tokenized_fields  
        ,sc.bad_tokenized_fields   
        ,sc.good_detokenized_fields
        ,sc.bad_detokenized_fields 
        ,0.00000 AS shieldconex_monthly_charge
        ,0.00000 AS shieldconex_transaction_charge
        ,0.00000 AS shieldconex_monthly_minimum_charge
        ,0.00000 AS shieldconex_fields_charge
      FROM auto_billing_staging.tmp_asset                asst 
      LEFT JOIN auto_billing_staging.tmp_shieldconex     sc
        ON asst.client_id = sc.client_id 
    ;
    
    SELECT 'calculating stage 1' AS message;
  
    UPDATE auto_billing_staging.tmp_calc_shieldconex_charges
       SET shieldconex_monthly_charge = auto_billing_dw.calc_shieldconex_monthly_charge(shieldconex_monthly_fee) 
     WHERE TRUE
    ;
    
    SELECT 'calculating stage 2' AS message;
    
    UPDATE auto_billing_staging.tmp_calc_shieldconex_charges
       SET shieldconex_transaction_charge     = auto_billing_dw.calc_shieldconex_transaction_charge(
              total_good_tokenized 
             ,total_bad_tokenized 
             ,total_good_detokenized
             ,total_bad_detokenized 
             ,shieldconex_monthly_minimum
             ,shieldconex_transaction_fee)    
     WHERE TRUE
    ;

    SELECT 'calculating stage 3' AS message;
  
    UPDATE auto_billing_staging.tmp_calc_shieldconex_charges
       SET shieldconex_monthly_minimum_charge = auto_billing_dw.calc_shieldconex_monthly_minimum_charge(
              shieldconex_transaction_charge
             ,shieldconex_monthly_minimum)
     WHERE TRUE 
    ;

    SELECT 'calculating stage 4' AS message;
    
    UPDATE auto_billing_staging.tmp_calc_shieldconex_charges
       SET shieldconex_fields_charge = auto_billing_dw.calc_shieldconex_fields_charge(
            good_tokenized_fields 
           ,bad_tokenized_fields 
           ,good_detokenized_fields 
           ,bad_detokenized_fields 
           ,shieldconex_monthly_minimum 
           ,shieldconex_fields_fee)
     WHERE TRUE 
    ;
    
    
--     SELECT * FROM auto_billing_staging.tmp_calc_shieldconex_charges;
    -- client_id|cardconex_acct_id |client_name    |shieldconex_monthly_fee|shieldconex_monthly_minimum|shieldconex_transaction_fee|shieldconex_fields_fee|total_bad_tokenized|total_good_detokenized|total_good_tokenized|total_bad_detokenized|good_tokenized_fields|bad_tokenized_fields|good_detokenized_fields|bad_detokenized_fields|shieldconex_monthly_charge|shieldconex_transaction_charge|shieldconex_monthly_minimum_charge|shieldconex_fields_charge|
    -- ---------|------------------|---------------|-----------------------|---------------------------|---------------------------|----------------------|-------------------|----------------------|--------------------|---------------------|---------------------|--------------------|-----------------------|----------------------|--------------------------|------------------------------|----------------------------------|-------------------------|
    -- 20       |0013i00000IsUq7AAF|Contact Centers|                0.00000|                  250.00000|                    0.02100|               0.00000|                 61|                   132|                 132|                    0|                  528|                 244|                    528|                     0|                   0.00000|                       0.00000|                         250.00000|                  0.00000|
    -- 33       |0013i00000QqgelAAB|Paay           |                0.00000|                 5000.00000|                    0.00175|               0.00000|                 18|                413372|              860487|                    7|               860487|                  18|                 413372|                     7|                   0.00000|                       0.00000|                        5000.00000|                  0.00000|
    
    SELECT 'updating auto_billing_dw.f_auto_billing_complete_shieldconex' AS message; 
      
    INSERT INTO auto_billing_dw.f_auto_billing_complete_shieldconex (
         bill_to_id
        ,bill_to_name
        ,collection_method
        ,start_date
        ,vintage_v2
        ,hold_bill
        ,segment_intacct
        ,id
        ,segment_now
        ,org_now
        ,chain_now
        ,industry_now
        ,dba_name
        ,year_mon
        ,cardconex_acct_id
        ,cardconex_acct_name
        ,payconex_acct_id
        ,payconex_acct_name
        ,payconex_acct_ids
        ,pci_monthly_charge
        ,pci_non_compliance_charge
        ,shieldconex_monthly_charge
        ,shieldconex_transaction_charge
        ,shieldconex_monthly_minimum_charge
        ,shieldconex_fields_charge
        ,p2pe_encryption_charge
        ,p2pe_token_flat_monthly_charge
        ,p2pe_token_flat_charge
        ,achworks_credit_charge
        ,achworks_per_trans_charge
        ,ach_returnerror_charge
        ,ach_noc_message_charge
        ,achworks_monthly_charge
        ,ach_sale_volume_charge
        ,cc_sale_charge
        ,group_charge
        ,gw_reissued_charge
        ,gw_reissued_ach_trans_charge
        ,p2pe_token_charge
        ,apriva_monthly_charge
        ,file_transfer_monthly_charge
        ,misc_monthly_charge
        ,pc_account_updater_monthly_charge
        ,pci_scans_monthly_charge
        ,card_convenience_charge
        ,gw_monthly_charge
        ,gw_per_auth_charge
        ,gw_per_auth_decline_charge
        ,gw_per_refund_charge
        ,gw_per_credit_charge
        ,gw_per_token_charge
        ,p2pe_device_activated_charge
        ,p2pe_device_activating_charge
        ,p2pe_device_stored_charge
        ,pricing_ach_credit_fee
        ,pricing_ach_discount_rate
        ,pricing_ach_monthly_fee
        ,pricing_ach_noc_fee
        ,pricing_ach_per_gw_trans_fee
        ,pricing_ach_return_error_fee
        ,pricing_ach_transaction_fee
        ,pricing_bluefin_gateway_discount_rate
        ,pricing_file_transfer_monthly_fee
        ,pricing_gateway_monthly_fee
        ,pricing_group_tag_fee
        ,pricing_gw_per_auth_decline_fee
        ,pricing_per_transaction_fee
        ,pricing_gw_per_credit_fee
        ,pricing_gw_per_refund_fee
        ,pricing_gw_per_sale_fee
        ,pricing_gw_per_token_fee
        ,pricing_gw_reissued_fee
        ,pricing_misc_monthly_fee
        ,pricing_p2pe_device_activated_fee
        ,pricing_p2pe_device_activating_fee
        ,pricing_p2pe_device_stored_fee
        ,pricing_p2pe_encryption_fee
        ,pricing_p2pe_monthly_flat_fee
        ,pricing_one_time_key_injection_fee
        ,pricing_p2pe_tokenization_fee
        ,pricing_pci_scans_monthly_fee
        ,pricing_pc_acct_updater_fee
        ,pci_compliance_fee
        ,pci_non_compliance_fee
        ,pricing_shieldconex_monthly_fee
        ,pricing_shieldconex_transaction_fee
        ,pricing_shieldconex_fields_fee
        ,pricing_shieldconex_monthly_minimum_fee
        ,total_good_tokenized
        ,total_bad_tokenized
        ,total_good_detokenized
        ,total_bad_detokenized
        ,total_good_tokenized_fields
        ,total_bad_tokenized_fields
        ,total_good_detokenized_fields
        ,total_bad_detokenized_fields
        ,decryption_count
        ,device_activated_count
        ,device_activating_count
        ,device_stored_count
        ,device_other_count
        ,device_activating_activated_count
        ,device_stored_activated_count
        ,device_other_activated_count
        ,user_count
        ,group_count
        ,cc_auth_trans
        ,cc_auth_vol
        ,cc_sale_trans
        ,cc_sale_vol
        ,cc_ref_trans
        ,cc_ref_vol
        ,cc_credit_trans
        ,cc_credit_vol
        ,cc_sale_decline_trans
        ,cc_auth_decline_trans
        ,cc_batches
        ,cc_keyed_trans
        ,cc_keyed_vol
        ,cc_swiped_trans
        ,cc_swiped_vol
        ,ach_sale_trans
        ,ach_sale_vol
        ,ach_credit_trans
        ,ach_credit_vol
        ,ach_batches
        ,ach_returns
        ,ach_errors
        ,ach_noc_messages
        ,p2pe_auth_trans
        ,p2pe_auth_vol
        ,p2pe_sale_trans
        ,p2pe_sale_vol
        ,p2pe_refund_trans
        ,p2pe_refund_vol
        ,p2pe_credit_trans
        ,p2pe_credit_vol
        ,p2pe_sale_decline_trans
        ,p2pe_auth_decline_trans
        ,p2pe_active_device_trans
        ,p2pe_inactive_device_trans
        ,tokens_stored
        ,batch_files_processed
        ,cc_capture_trans
        ,cc_capture_vol
        ,p2pe_capture_trans
        ,p2pe_capture_vol
        ,combined_decline_trans
        ,p2pe_declined_trans
        ,p2pe_tokens_stored
        ,reissued_cc_transactions
        ,reissued_ach_transactions
    ) 
    SELECT 
         NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,DATE_FORMAT(CURRENT_DATE, '%Y%m')
        ,cardconex_acct_id
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,0
        ,0
        ,shieldconex_monthly_charge
        ,shieldconex_transaction_charge
        ,shieldconex_monthly_minimum_charge
        ,shieldconex_fields_charge
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,shieldconex_monthly_fee
        ,shieldconex_transaction_fee
        ,shieldconex_fields_fee
        ,shieldconex_monthly_minimum
        ,total_good_tokenized
        ,total_bad_tokenized
        ,total_good_detokenized
        ,total_bad_detokenized
        ,good_tokenized_fields
        ,bad_tokenized_fields
        ,good_detokenized_fields
        ,bad_detokenized_fields
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
    FROM auto_billing_staging.tmp_calc_shieldconex_charges
    ;
  
END