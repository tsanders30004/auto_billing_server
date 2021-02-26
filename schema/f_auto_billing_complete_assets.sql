Procedure	sql_mode	Create Procedure	character_set_client	collation_connection	Database Collation
f_auto_billing_complete_assets	STRICT_TRANS_TABLES	CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `f_auto_billing_complete_assets`()\n    COMMENT 'USAGE:  f_auto_billing_complete_assets /* update asset columns in f_auto_billing_complete_2 */'\nBEGIN\n   \n    SELECT 'Executing Stored Procedure' AS operation, 'f_auto_billing_complete_assets' AS stored_procedure, CURRENT_TIMESTAMP;\n  \n     UPDATE auto_billing_dw.f_auto_billing_complete_2      abc \n      JOIN auto_billing_staging.stg_asset                  asst \n        ON abc.account_id = asst.account_id \n       SET abc.pricing_ach_credit_fee                 = asst.ach_credit_fee\n          ,abc.pricing_ach_monthly_fee                = asst.ach_monthly_fee\n          ,abc.pricing_ach_noc_fee                    = asst.ach_noc_fee\n          ,abc.pricing_ach_per_gw_trans_fee           = asst.ach_per_gw_trans_fee\n          ,abc.pricing_ach_return_error_fee           = asst.ach_return_error_fee\n          ,abc.pricing_ach_transaction_fee            = asst.ach_transaction_fee\n          ,abc.pricing_bluefin_gateway_discount_rate  = asst.bluefin_gateway_discount_rate\n          ,abc.pricing_file_transfer_monthly_fee      = asst.file_transfer_monthly_fee\n          ,abc.pricing_gateway_monthly_fee            = asst.gateway_monthly_fee\n          ,abc.pricing_group_tag_fee                  = asst.group_tag_fee\n          ,abc.pricing_gw_per_auth_decline_fee        = asst.gw_per_auth_decline_fee\n          ,abc.pricing_gw_per_credit_fee              = asst.gw_per_credit_fee\n          ,abc.pricing_gw_per_refund_fee              = asst.gw_per_refund_fee\n          ,abc.pricing_gw_per_sale_fee                = asst.gw_per_sale_fee\n          ,abc.pricing_gw_per_token_fee               = asst.gw_per_token_fee\n          ,abc.pricing_gw_reissued_fee                = asst.gw_reissued_fee\n          ,abc.pricing_misc_monthly_fee               = asst.misc_monthly_fees\n      --  ,abc.pricing_one_time_key_injection_fee     = asst.one_time_key_injection_fees  \n          ,abc.pricing_one_time_key_injection_fee     = asst.payconex_app_exchange_fee  -- 13 jan 2013\n          ,abc.pricing_p2pe_device_activated_fee      = asst.p2pe_device_activated\n          ,abc.pricing_p2pe_device_activating_fee     = asst.p2pe_device_activating_fee\n          ,abc.pricing_p2pe_device_stored_fee         = asst.p2pe_device_stored_fee\n          ,abc.pricing_p2pe_encryption_fee            = asst.p2pe_encryption_fee\n          ,abc.pricing_p2pe_monthly_flat_fee          = asst.p2pe_monthly_flat_fee\n      --  ,abc.pricing_p2pe_tokenization_fee          = asst.p2pe_tokenization_fee  \n          ,abc.pricing_p2pe_tokenization_fee          = asst.one_time_key_injection_fees  -- 13 jan 2021\n          ,abc.pricing_pc_acct_updater_fee            = 0      -- confirm this is zero.\n          ,abc.pricing_pci_compliance_fee             = asst.pci_compliance_fee \n          ,abc.pricing_pci_non_compliance_fee         = asst.pci_non_compliance_fee \n          ,abc.pricing_pci_scans_monthly_fee          = asst.pci_scans_monthly_fee\n          ,abc.pricing_per_transaction_fee            = asst.per_transaction_fee\n          ,pricing_shieldconex_fields_fee             = asst.shieldconex_fields_fee \n          ,pricing_shieldconex_monthly_fee            = asst.shieldconex_monthly_fee \n          ,pricing_shieldconex_monthly_minimum_fee    = asst.shieldconex_monthly_minimum \n          ,pricing_shieldconex_transaction_fee        = asst.shieldconex_transaction_fee \n          ,pricing_tokenization_fee                   = asst.tokenization_fee \n     WHERE TRUE \n    ;\n    \n    UPDATE auto_billing_dw.f_auto_billing_complete_2      abc \n      JOIN auto_billing_staging.stg_asset                 asst \n        ON abc.account_id = asst.account_id\n       SET abc.pricing_ach_discount_rate = asst.bfach_discount_rate / 100.0\n     WHERE TRUE \n    ; \n  \n \n\nEND	utf8	utf8_general_ci	latin1_swedish_ci
