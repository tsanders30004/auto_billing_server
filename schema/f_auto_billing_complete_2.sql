SELECT 
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
    ,COALESCE(CONVERT(user_count                              USING latin1), '') AS user_count                             
    ,COALESCE(CONVERT(group_count                             USING latin1), '') AS group_count                            
    ,COALESCE(CONVERT(cc_auth_trans                           USING latin1), '') AS cc_auth_trans                          
    ,COALESCE(CONVERT(cc_auth_vol                             USING latin1), '') AS cc_auth_vol                            
    ,COALESCE(CONVERT(cc_sale_trans                           USING latin1), '') AS cc_sale_trans                          
    ,COALESCE(CONVERT(cc_sale_vol                             USING latin1), '') AS cc_sale_vol                            
    ,COALESCE(CONVERT(cc_ref_trans                            USING latin1), '') AS cc_ref_trans                           
    ,COALESCE(CONVERT(cc_ref_vol                              USING latin1), '') AS cc_ref_vol                             
    ,COALESCE(CONVERT(cc_credit_trans                         USING latin1), '') AS cc_credit_trans                        
    ,COALESCE(CONVERT(cc_credit_vol                           USING latin1), '') AS cc_credit_vol                          
    ,COALESCE(CONVERT(cc_sale_decline_trans                   USING latin1), '') AS cc_sale_decline_trans                  
    ,COALESCE(CONVERT(cc_auth_decline_trans                   USING latin1), '') AS cc_auth_decline_trans                  
    ,COALESCE(CONVERT(cc_batches                              USING latin1), '') AS cc_batches                             
    ,COALESCE(CONVERT(cc_keyed_trans                          USING latin1), '') AS cc_keyed_trans                         
    ,COALESCE(CONVERT(cc_keyed_vol                            USING latin1), '') AS cc_keyed_vol                           
    ,COALESCE(CONVERT(cc_swiped_trans                         USING latin1), '') AS cc_swiped_trans                        
    ,COALESCE(CONVERT(cc_swiped_vol                           USING latin1), '') AS cc_swiped_vol                          
    ,COALESCE(CONVERT(ach_sale_trans                          USING latin1), '') AS ach_sale_trans                         
    ,COALESCE(CONVERT(ach_sale_vol                            USING latin1), '') AS ach_sale_vol                           
    ,COALESCE(CONVERT(ach_credit_trans                        USING latin1), '') AS ach_credit_trans                       
    ,COALESCE(CONVERT(ach_credit_vol                          USING latin1), '') AS ach_credit_vol                         
    ,COALESCE(CONVERT(ach_batches                             USING latin1), '') AS ach_batches                            
    ,COALESCE(CONVERT(ach_returns                             USING latin1), '') AS ach_returns                            
    ,COALESCE(CONVERT(ach_errors                              USING latin1), '') AS ach_errors                             
    ,COALESCE(CONVERT(ach_noc_messages                        USING latin1), '') AS ach_noc_messages                       
    ,COALESCE(CONVERT(p2pe_auth_trans                         USING latin1), '') AS p2pe_auth_trans                        
    ,COALESCE(CONVERT(p2pe_auth_vol                           USING latin1), '') AS p2pe_auth_vol                          
    ,COALESCE(CONVERT(p2pe_sale_trans                         USING latin1), '') AS p2pe_sale_trans                        
    ,COALESCE(CONVERT(p2pe_sale_vol                           USING latin1), '') AS p2pe_sale_vol                          
    ,COALESCE(CONVERT(p2pe_refund_trans                       USING latin1), '') AS p2pe_refund_trans                      
    ,COALESCE(CONVERT(p2pe_refund_vol                         USING latin1), '') AS p2pe_refund_vol                        
    ,COALESCE(CONVERT(p2pe_credit_trans                       USING latin1), '') AS p2pe_credit_trans                      
    ,COALESCE(CONVERT(p2pe_credit_vol                         USING latin1), '') AS p2pe_credit_vol                        
    ,COALESCE(CONVERT(p2pe_sale_decline_trans                 USING latin1), '') AS p2pe_sale_decline_trans                
    ,COALESCE(CONVERT(p2pe_auth_decline_trans                 USING latin1), '') AS p2pe_auth_decline_trans                
    ,COALESCE(CONVERT(p2pe_active_device_trans                USING latin1), '') AS p2pe_active_device_trans               
    ,COALESCE(CONVERT(p2pe_inactive_device_trans              USING latin1), '') AS p2pe_inactive_device_trans             
    ,COALESCE(CONVERT(tokens_stored                           USING latin1), '') AS tokens_stored                          
    ,COALESCE(CONVERT(batch_files_processed                   USING latin1), '') AS batch_files_processed                  
    ,COALESCE(CONVERT(cc_capture_trans                        USING latin1), '') AS cc_capture_trans                       
    ,COALESCE(CONVERT(cc_capture_vol                          USING latin1), '') AS cc_capture_vol                         
    ,COALESCE(CONVERT(p2pe_capture_trans                      USING latin1), '') AS p2pe_capture_trans                     
    ,COALESCE(CONVERT(p2pe_capture_vol                        USING latin1), '') AS p2pe_capture_vol                       
    ,COALESCE(CONVERT(combined_decline_trans                  USING latin1), '') AS combined_decline_trans                 
    ,COALESCE(CONVERT(p2pe_declined_trans                     USING latin1), '') AS p2pe_declined_trans                    
    ,COALESCE(CONVERT(p2pe_tokens_stored                      USING latin1), '') AS p2pe_tokens_stored                     
    ,COALESCE(CONVERT(reissued_cc_transactions                USING latin1), '') AS reissued_cc_transactions               
    ,COALESCE(CONVERT(reissued_ach_transactions               USING latin1), '') AS reissued_ach_transactions              
    ,date_updated                                                                                                     
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex 
;

