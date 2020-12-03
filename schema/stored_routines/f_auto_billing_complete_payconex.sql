CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `auto_billing_dw`.`f_auto_billing_complete_payconex`()
BEGIN
  
    SET @stage = 0; 
    
    SELECT 'Executing Stored Procedure' AS operation, 'f_auto_billing_complete_payconex' AS stored_procedure, CURRENT_TIMESTAMP;

    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2      abc 
      JOIN (
          SELECT
               pcm.cardconex_acct_id 
              ,SUM(group_count) AS group_count
            FROM auto_billing_staging.stg_payconex_volume       pv 
            JOIN auto_billing_staging.stg_payconex_cardconex_map  pcm 
              ON pv.acct_id = pcm.payconex_acct_id 
           GROUP BY 1
      ) t1 
        ON abc.account_id = t1.cardconex_acct_id 
       SET abc.group_count = t1.group_count 
     WHERE TRUE
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2    abc
      JOIN auto_billing_staging.stg_asset               asst
        ON abc.account_id = asst.account_id
       SET abc.group_charge = abc.group_count * asst.group_tag_fee 
     WHERE TRUE 
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2 abc 
      JOIN (
          SELECT 
               pcm.cardconex_acct_id  AS account_id 
              ,SUM(pv.user_count)     AS user_count
            FROM auto_billing_staging.stg_payconex_volume           pv
            JOIN auto_billing_staging.stg_payconex_cardconex_map    pcm
              ON pv.acct_id = pcm.payconex_acct_id 
           GROUP BY 1  
      ) t1 
        ON abc.account_id = t1.account_id
       SET abc.user_count = t1.user_count 
     WHERE TRUE 
    ;
    
    DROP TABLE IF EXISTS auto_billing_dw.tmp_vol_charges;
    
    CREATE TABLE auto_billing_dw.tmp_vol_charges(
       payconex_acct_id                      VARCHAR(12)
      ,account_id                            VARCHAR(18) 
      ,ach_noc_message_charge                DECIMAL(12, 5) NOT NULL DEFAULT 0.00000
      ,ach_returnerror_charge                DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 
      ,ach_sale_volume_charge                DECIMAL(12, 5) NOT NULL DEFAULT 0.00000
      ,achworks_credit_charge                DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 
      ,achworks_monthly_charge               DECIMAL(12, 5) NOT NULL DEFAULT 0.00000
      ,achworks_per_trans_charge             DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 
      ,apriva_monthly_charge                 DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 
      ,card_convenience_charge               DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 
      ,cc_sale_charge                        DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 
      ,file_transfer_monthly_charge          DECIMAL(12, 5) NOT NULL DEFAULT 0.00000
      ,gw_monthly_charge                     DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 
      ,gw_per_auth_charge                    DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,gw_per_auth_decline_charge            DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,gw_per_credit_charge                  DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,gw_per_refund_charge                  DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,gw_per_token_charge                   DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,gw_reissued_ach_trans_charge          DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,gw_reissued_charge                    DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,misc_monthly_charge                   DECIMAL(12, 5) NOT NULL DEFAULT 0.00000   
      ,p2pe_encryption_charge                DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,p2pe_token_charge                     DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,p2pe_token_flat_charge                DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 
      ,p2pe_token_flat_monthly_charge        DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 
      ,pc_account_updater_monthly_charge     DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,pci_scans_monthly_charge              DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,PRIMARY KEY(payconex_acct_id)         -- i think, but am not sure, that this is valid
    ) ENGINE=InnoDB DEFAULT CHARSET=latin1
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    INSERT INTO auto_billing_dw.tmp_vol_charges
    SELECT 
         pvd.acct_id AS payconex_acct_id
        ,pcm.cardconex_acct_id 
        ,COALESCE(asst.ach_noc_fee,                 0.0) *  COALESCE(pvd.ach_noc_messages,          0.0)                                                 AS ach_noc_message_charge
        ,COALESCE(asst.ach_return_error_fee,        0.0) * (COALESCE(pvd.ach_returns,               0.0) + COALESCE(pvd.ach_errors, 0.0))                AS ach_returnerror_charge
        ,COALESCE(asst.bfach_discount_rate / 100.0, 0.0) *  COALESCE(pvd.ach_sale_vol ,             0.0)                                                 AS ach_sale_volume_charge               
        ,COALESCE(asst.ach_credit_fee,              0.0) * (COALESCE(pvd.ach_sale_trans,            0.0) + COALESCE(pvd.ach_credit_trans, 0.0))          AS achworks_credit_charge
        ,COALESCE(asst.ach_monthly_fee,             0.0)                                                                                                 AS achworks_monthly_charge
        ,COALESCE(asst.ach_per_gw_trans_fee,        0.0) * (COALESCE(pvd.ach_sale_trans,            0.0) + COALESCE(pvd.ach_credit_trans, 0.0))          AS achworks_per_trans_charge
        ,0.0                                                                                                                                             AS apriva_monthly_charge                -- placeholder
        ,0.0                                                                                                                                             AS card_convenience_charge              -- placeholder
        ,COALESCE(asst.gw_per_sale_fee,             0.0) *  COALESCE(pvd.cc_sale_trans,             0.0)                                                 AS cc_sale_charge
        ,COALESCE(asst.file_transfer_monthly_fee,   0.0)                                                                                                 AS file_transfer_monthly_charge
        ,0.0                                                                                                                                             AS gw_monthly_charge                    -- placeholder
        ,COALESCE(asst.per_transaction_fee,         0.0) * (COALESCE(pvd.cc_auth_trans,             0.0) + COALESCE(pvd.tokens_stored, 0.0))             AS gw_per_auth_charge
        ,COALESCE(asst.gw_per_auth_decline_fee,     0.0) *  COALESCE(pvd.cc_auth_decline_trans,     0.0)                                                 AS gw_per_auth_decline_charge
        ,COALESCE(asst.gw_per_credit_fee,           0.0) *  COALESCE(pvd.cc_credit_trans,           0.0)                                                 AS gw_per_credit_charge
        ,COALESCE(asst.gw_per_refund_fee,           0.0) *  COALESCE(pvd.cc_ref_trans,              0.0)                                                 AS gw_per_refund_charge
        ,COALESCE(asst.gw_per_token_fee,            0.0) *  COALESCE(pvd.tokens_stored,             0.0)                                                 AS gw_per_token_charge
        ,COALESCE(asst.gw_reissued_fee,             0.0) *  COALESCE(pvd.reissued_ach_transactions, 0.0)                                                 AS gw_reissued_ach_trans_charge
        ,COALESCE(asst.gw_reissued_fee,             0.0) *  COALESCE(pvd.reissued_cc_transactions,  0.0)                                                 AS gw_reissued_charge
        ,0.0                                                                                                                                             AS misc_monthly_charge                  -- placeholder 
        ,0.0                                                                                                                                             AS p2pe_encryption_charge               -- placeholder
        ,COALESCE(asst.p2pe_tokenization_fee,       0.0) *  COALESCE(pvd.p2pe_tokens_stored,        0.0)                                                 AS p2pe_token_charge
        ,COALESCE(asst.p2pe_monthly_flat_fee,       0.0)                                                                                                 AS p2pe_token_flat_charge
        ,COALESCE(asst.one_time_key_injection_fees, 0.0)                                                                                                 AS p2pe_token_flat_monthly_charge
        ,0.0                                                                                                                                             AS pc_account_updater_monthly_charge    -- placeholder
        ,COALESCE(asst.pci_scans_monthly_fee,       0.0) * (COALESCE(pvd.reissued_cc_transactions,  0.0) + COALESCE(pvd.reissued_ach_transactions, 0.0)) AS pci_scans_monthly_charge
      FROM auto_billing_staging.stg_payconex_volume           pvd    
      JOIN auto_billing_staging.stg_payconex_cardconex_map    pcm    
        ON pvd.acct_id = pcm.payconex_acct_id 
      LEFT JOIN auto_billing_staging.stg_asset                asst 
        ON pcm.cardconex_acct_id = asst.account_id
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.tmp_vol_charges
       SET card_convenience_charge           = 0.0
          ,pc_account_updater_monthly_charge = 0.0
     WHERE TRUE 
    ;
    
    DROP TABLE IF EXISTS auto_billing_dw.tmp_mid_count;
    
    CREATE  TABLE auto_billing_dw.tmp_mid_count(
         account_id   VARCHAR(18)
        ,mid_count    SMALLINT UNSIGNED
        ,PRIMARY KEY(account_id)
    );
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    INSERT INTO auto_billing_dw.tmp_mid_count
    SELECT 
         pcm.cardconex_acct_id 
        ,COUNT(DISTINCT pvd.acct_id   ) AS mid_count 
      FROM auto_billing_staging.stg_payconex_volume           pvd
      JOIN auto_billing_staging.stg_payconex_cardconex_map    pcm
        ON pvd.acct_id = pcm.payconex_acct_id 
     GROUP BY 1
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.tmp_vol_charges                pv 
      LEFT JOIN auto_billing_staging.stg_asset            asst 
        ON pv.account_id = asst.account_id
      LEFT JOIN auto_billing_dw.tmp_mid_count             mc 
        ON pv.account_id = mc.account_id 
       SET pv.apriva_monthly_charge = COALESCE(asst.bluefin_gateway_discount_rate, 0.0) * COALESCE(mc.mid_count, 0)
          ,pv.gw_monthly_charge     = COALESCE(asst.gateway_monthly_fee,           0.0) * COALESCE(mc.mid_count, 0)
          ,pv.misc_monthly_charge   = COALESCE(asst.misc_monthly_fees,             0.0) * COALESCE(mc.mid_count, 0)
     WHERE TRUE 
    ;
     
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2 abc
      JOIN (
          SELECT
               account_id 
              ,SUM(ach_noc_message_charge           ) AS ach_noc_message_charge           
              ,SUM(ach_returnerror_charge           ) AS ach_returnerror_charge           
              ,SUM(ach_sale_volume_charge           ) AS ach_sale_volume_charge           
              ,SUM(achworks_credit_charge           ) AS achworks_credit_charge           
              ,MAX(achworks_monthly_charge          ) AS achworks_monthly_charge            -- changed SUM to MAX
              ,SUM(achworks_per_trans_charge        ) AS achworks_per_trans_charge        
              ,SUM(apriva_monthly_charge            ) AS apriva_monthly_charge            
              ,SUM(card_convenience_charge          ) AS card_convenience_charge          
              ,SUM(cc_sale_charge                   ) AS cc_sale_charge                   
              ,SUM(file_transfer_monthly_charge     ) AS file_transfer_monthly_charge             
              ,MAX(gw_monthly_charge                ) AS gw_monthly_charge                
              ,SUM(gw_per_auth_charge               ) AS gw_per_auth_charge               
              ,SUM(gw_per_auth_decline_charge       ) AS gw_per_auth_decline_charge       
              ,SUM(gw_per_credit_charge             ) AS gw_per_credit_charge             
              ,SUM(gw_per_refund_charge             ) AS gw_per_refund_charge             
              ,SUM(gw_per_token_charge              ) AS gw_per_token_charge              
              ,SUM(gw_reissued_ach_trans_charge     ) AS gw_reissued_ach_trans_charge     
              ,SUM(gw_reissued_charge               ) AS gw_reissued_charge               
              ,MAX(misc_monthly_charge              ) AS misc_monthly_charge                -- changed SUM to MAX                    
              ,SUM(p2pe_token_charge                ) AS p2pe_token_charge                
              ,MAX(p2pe_token_flat_charge           ) AS p2pe_token_flat_charge           
              ,MAX(p2pe_token_flat_monthly_charge   ) AS p2pe_token_flat_monthly_charge   
              ,SUM(pc_account_updater_monthly_charge) AS pc_account_updater_monthly_charge
              ,SUM(pci_scans_monthly_charge         ) AS pci_scans_monthly_charge                
            FROM auto_billing_dw.tmp_vol_charges
           GROUP BY 1  
      ) t1 
        ON abc.account_id = t1.account_id 
      SET  abc.ach_noc_message_charge            = t1.ach_noc_message_charge           
          ,abc.ach_returnerror_charge            = t1.ach_returnerror_charge           
          ,abc.ach_sale_volume_charge            = t1.ach_sale_volume_charge           
          ,abc.achworks_credit_charge            = t1.achworks_credit_charge           
          ,abc.achworks_monthly_charge           = t1.achworks_monthly_charge          
          ,abc.achworks_per_trans_charge         = t1.achworks_per_trans_charge        
          ,abc.apriva_monthly_charge             = t1.apriva_monthly_charge            
          ,abc.card_convenience_charge           = t1.card_convenience_charge          
          ,abc.cc_sale_charge                    = t1.cc_sale_charge                   
          ,abc.file_transfer_monthly_charge      = t1.file_transfer_monthly_charge                        
          ,abc.gw_monthly_charge                 = t1.gw_monthly_charge                
          ,abc.gw_per_auth_charge                = t1.gw_per_auth_charge               
          ,abc.gw_per_auth_decline_charge        = t1.gw_per_auth_decline_charge       
          ,abc.gw_per_credit_charge              = t1.gw_per_credit_charge             
          ,abc.gw_per_refund_charge              = t1.gw_per_refund_charge             
          ,abc.gw_per_token_charge               = t1.gw_per_token_charge              
          ,abc.gw_reissued_ach_trans_charge      = t1.gw_reissued_ach_trans_charge     
          ,abc.gw_reissued_charge                = t1.gw_reissued_charge               
          ,abc.misc_monthly_charge               = t1.misc_monthly_charge                       
          ,abc.p2pe_token_charge                 = t1.p2pe_token_charge                
          ,abc.p2pe_token_flat_charge            = t1.p2pe_token_flat_charge           
          ,abc.p2pe_token_flat_monthly_charge    = t1.p2pe_token_flat_monthly_charge   
          ,abc.pc_account_updater_monthly_charge = t1.pc_account_updater_monthly_charge
          ,abc.pci_scans_monthly_charge          = t1.pci_scans_monthly_charge    
     WHERE TRUE 
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2      abc 
      JOIN auto_billing_staging.stg_asset                 asst 
        ON abc.account_id = asst.account_id 
       SET abc.p2pe_encryption_charge = COALESCE(abc.decryption_count, 0) * COALESCE(asst.p2pe_encryption_fee, 0.0000)
     WHERE TRUE 
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2      abc 
      JOIN (
          SELECT 
               pcm.cardconex_acct_id            AS account_id
              ,SUM(ach_batches)                 AS ach_batches
              ,SUM(ach_credit_trans)            AS ach_credit_trans
              ,SUM(ach_credit_vol)              AS ach_credit_vol
              ,SUM(ach_errors)                  AS ach_errors
              ,SUM(ach_noc_messages)            AS ach_noc_messages
              ,SUM(ach_returns)                 AS ach_returns
              ,SUM(ach_sale_trans)              AS ach_sale_trans
              ,SUM(ach_sale_vol)                AS ach_sale_vol
              ,SUM(batch_files_processed)       AS batch_files_processed
              ,SUM(cc_auth_decline_trans)       AS cc_auth_decline_trans
              ,SUM(cc_auth_trans)               AS cc_auth_trans
              ,SUM(cc_auth_vol)                 AS cc_auth_vol
              ,SUM(cc_batches)                  AS cc_batches
              ,SUM(cc_capture_trans)            AS cc_capture_trans
              ,SUM(cc_capture_vol)              AS cc_capture_vol
              ,SUM(cc_credit_trans)             AS cc_credit_trans
              ,SUM(cc_credit_vol)               AS cc_credit_vol
              ,SUM(cc_keyed_trans)              AS cc_keyed_trans
              ,SUM(cc_keyed_vol)                AS cc_keyed_vol
              ,SUM(cc_ref_trans)                AS cc_ref_trans
              ,SUM(cc_ref_vol)                  AS cc_ref_vol
              ,SUM(cc_sale_decline_trans)       AS cc_sale_decline_trans
              ,SUM(cc_sale_trans)               AS cc_sale_trans
              ,SUM(cc_sale_vol)                 AS cc_sale_vol
              ,SUM(cc_swiped_trans)             AS cc_swiped_trans
              ,SUM(cc_swiped_vol)               AS cc_swiped_vol
              ,SUM(combined_decline_trans)      AS combined_decline_trans
              ,SUM(p2pe_active_device_trans)    AS p2pe_active_device_trans
              ,SUM(p2pe_auth_decline_trans)     AS p2pe_auth_decline_trans
              ,SUM(p2pe_auth_trans)             AS p2pe_auth_trans
              ,SUM(p2pe_auth_vol)               AS p2pe_auth_vol
              ,SUM(p2pe_capture_trans)          AS p2pe_capture_trans
              ,SUM(p2pe_capture_vol)            AS p2pe_capture_vol
              ,SUM(p2pe_credit_trans)           AS p2pe_credit_trans
              ,SUM(p2pe_credit_vol)             AS p2pe_credit_vol
              ,SUM(p2pe_declined_trans)         AS p2pe_declined_trans
              ,SUM(p2pe_inactive_device_trans)  AS p2pe_inactive_device_trans
              ,SUM(p2pe_refund_trans)           AS p2pe_refund_trans
              ,SUM(p2pe_refund_vol)             AS p2pe_refund_vol
              ,SUM(p2pe_sale_decline_trans)     AS p2pe_sale_decline_trans
              ,SUM(p2pe_sale_trans)             AS p2pe_sale_trans
              ,SUM(p2pe_sale_vol)               AS p2pe_sale_vol
              ,SUM(p2pe_tokens_stored)          AS p2pe_tokens_stored
              ,SUM(reissued_ach_transactions)   AS reissued_ach_transactions
              ,SUM(reissued_cc_transactions)    AS reissued_cc_transactions
              ,SUM(tokens_stored)               AS tokens_stored
            FROM auto_billing_staging.stg_payconex_volume         pvd 
            JOIN auto_billing_staging.stg_payconex_cardconex_map    pcm
              ON pvd.acct_id = pcm.payconex_acct_id 
           GROUP BY 1
      ) t1 ON abc.account_id              = t1.account_id
       SET abc.ach_batches                = t1.ach_batches
          ,abc.ach_credit_trans           = t1.ach_credit_trans
          ,abc.ach_credit_vol             = t1.ach_credit_vol
          ,abc.ach_errors                 = t1.ach_errors
          ,abc.ach_noc_messages           = t1.ach_noc_messages
          ,abc.ach_returns                = t1.ach_returns
          ,abc.ach_sale_trans             = t1.ach_sale_trans
          ,abc.ach_sale_vol               = t1.ach_sale_vol
          ,abc.batch_files_processed      = t1.batch_files_processed
          ,abc.cc_auth_decline_trans      = t1.cc_auth_decline_trans
          ,abc.cc_auth_trans              = t1.cc_auth_trans
          ,abc.cc_auth_vol                = t1.cc_auth_vol
          ,abc.cc_batches                 = t1.cc_batches
          ,abc.cc_capture_trans           = t1.cc_capture_trans
          ,abc.cc_capture_vol             = t1.cc_capture_vol
          ,abc.cc_credit_trans            = t1.cc_credit_trans
          ,abc.cc_credit_vol              = t1.cc_credit_vol
          ,abc.cc_keyed_trans             = t1.cc_keyed_trans
          ,abc.cc_keyed_vol               = t1.cc_keyed_vol
          ,abc.cc_ref_trans               = t1.cc_ref_trans
          ,abc.cc_ref_vol                 = t1.cc_ref_vol
          ,abc.cc_sale_decline_trans      = t1.cc_sale_decline_trans
          ,abc.cc_sale_trans              = t1.cc_sale_trans
          ,abc.cc_sale_vol                = t1.cc_sale_vol
          ,abc.cc_swiped_trans            = t1.cc_swiped_trans
          ,abc.cc_swiped_vol              = t1.cc_swiped_vol
          ,abc.combined_decline_trans     = t1.combined_decline_trans
          ,abc.p2pe_active_device_trans   = t1.p2pe_active_device_trans
          ,abc.p2pe_auth_decline_trans    = t1.p2pe_auth_decline_trans
          ,abc.p2pe_auth_trans            = t1.p2pe_auth_trans
          ,abc.p2pe_auth_vol              = t1.p2pe_auth_vol
          ,abc.p2pe_capture_trans         = t1.p2pe_capture_trans
          ,abc.p2pe_capture_vol           = t1.p2pe_capture_vol
          ,abc.p2pe_credit_trans          = t1.p2pe_credit_trans
          ,abc.p2pe_credit_vol            = t1.p2pe_credit_vol
          ,abc.p2pe_declined_trans        = t1.p2pe_declined_trans
          ,abc.p2pe_inactive_device_trans = t1.p2pe_inactive_device_trans
          ,abc.p2pe_refund_trans          = t1.p2pe_refund_trans
          ,abc.p2pe_refund_vol            = t1.p2pe_refund_vol
          ,abc.p2pe_sale_decline_trans    = t1.p2pe_sale_decline_trans
          ,abc.p2pe_sale_trans            = t1.p2pe_sale_trans
          ,abc.p2pe_sale_vol              = t1.p2pe_sale_vol
          ,abc.p2pe_tokens_stored         = t1.p2pe_tokens_stored
          ,abc.reissued_ach_transactions  = t1.reissued_ach_transactions
          ,abc.reissued_cc_transactions   = t1.reissued_cc_transactions
          ,abc.tokens_stored              = t1.tokens_stored
      WHERE TRUE
    ;



END
