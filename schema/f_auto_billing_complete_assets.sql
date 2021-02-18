CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `auto_billing_dw`.`f_auto_billing_complete_assets`()
    COMMENT 'USAGE:  f_auto_billing_complete_assets /* update asset columns in f_auto_billing_complete_2 */'
BEGIN
   
    SELECT 'Executing Stored Procedure' AS operation, 'f_auto_billing_complete_assets' AS stored_procedure, CURRENT_TIMESTAMP;
  
     UPDATE auto_billing_dw.f_auto_billing_complete_2      abc 
      JOIN auto_billing_staging.stg_asset                  asst 
        ON abc.account_id = asst.account_id 
       SET abc.pricing_ach_credit_fee                 = asst.ach_credit_fee
          ,abc.pricing_ach_monthly_fee                = asst.ach_monthly_fee
          ,abc.pricing_ach_noc_fee                    = asst.ach_noc_fee
          ,abc.pricing_ach_per_gw_trans_fee           = asst.ach_per_gw_trans_fee
          ,abc.pricing_ach_return_error_fee           = asst.ach_return_error_fee
          ,abc.pricing_ach_transaction_fee            = asst.ach_transaction_fee
          ,abc.pricing_bluefin_gateway_discount_rate  = asst.bluefin_gateway_discount_rate
          ,abc.pricing_file_transfer_monthly_fee      = asst.file_transfer_monthly_fee
          ,abc.pricing_gateway_monthly_fee            = asst.gateway_monthly_fee
          ,abc.pricing_group_tag_fee                  = asst.group_tag_fee
          ,abc.pricing_gw_per_auth_decline_fee        = asst.gw_per_auth_decline_fee
          ,abc.pricing_gw_per_credit_fee              = asst.gw_per_credit_fee
          ,abc.pricing_gw_per_refund_fee              = asst.gw_per_refund_fee
          ,abc.pricing_gw_per_sale_fee                = asst.gw_per_sale_fee
          ,abc.pricing_gw_per_token_fee               = asst.gw_per_token_fee
          ,abc.pricing_gw_reissued_fee                = asst.gw_reissued_fee
          ,abc.pricing_misc_monthly_fee               = asst.misc_monthly_fees
      --  ,abc.pricing_one_time_key_injection_fee     = asst.one_time_key_injection_fees  
          ,abc.pricing_one_time_key_injection_fee     = asst.payconex_app_exchange_fee  -- 13 jan 2013
          ,abc.pricing_p2pe_device_activated_fee      = asst.p2pe_device_activated
          ,abc.pricing_p2pe_device_activating_fee     = asst.p2pe_device_activating_fee
          ,abc.pricing_p2pe_device_stored_fee         = asst.p2pe_device_stored_fee
          ,abc.pricing_p2pe_encryption_fee            = asst.p2pe_encryption_fee
          ,abc.pricing_p2pe_monthly_flat_fee          = asst.p2pe_monthly_flat_fee
      --  ,abc.pricing_p2pe_tokenization_fee          = asst.p2pe_tokenization_fee  
          ,abc.pricing_p2pe_tokenization_fee          = asst.one_time_key_injection_fees  -- 13 jan 2021
          ,abc.pricing_pc_acct_updater_fee            = 0      -- confirm this is zero.
          ,abc.pci_compliance_fee                     = asst.pci_compliance_fee 
          ,abc.pci_non_compliance_fee                 = asst.pci_non_compliance_fee 
          ,abc.pricing_pci_scans_monthly_fee          = asst.pci_scans_monthly_fee
          ,abc.pricing_per_transaction_fee            = asst.per_transaction_fee
          ,pricing_shieldconex_fields_fee             = asst.shieldconex_fields_fee 
          ,pricing_shieldconex_monthly_fee            = asst.shieldconex_monthly_fee 
          ,pricing_shieldconex_monthly_minimum_fee    = asst.shieldconex_monthly_minimum 
          ,pricing_shieldconex_transaction_fee        = asst.shieldconex_transaction_fee 
          ,pricing_tokenization_fee                   = asst.tokenization_fee 
     WHERE TRUE 
    ;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2      abc 
      JOIN auto_billing_staging.stg_asset                 asst 
        ON abc.account_id = asst.account_id
       SET abc.pricing_ach_discount_rate = asst.bfach_discount_rate / 100.0
     WHERE TRUE 
    ; 
  
 

END