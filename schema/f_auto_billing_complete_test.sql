SELECT abc1.cardconex_acct_id, abc1.achworks_credit_charge, abc2.achworks_credit_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.achworks_credit_charge, 0.0000) != COALESCE(abc2.achworks_credit_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.achworks_monthly_charge, abc2.achworks_monthly_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.achworks_monthly_charge, 0.0000) != COALESCE(abc2.achworks_monthly_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.achworks_per_trans_charge, abc2.achworks_per_trans_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.achworks_per_trans_charge, 0.0000) != COALESCE(abc2.achworks_per_trans_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.ach_batches, abc2.ach_batches 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.ach_batches, 0.0000) != COALESCE(abc2.ach_batches, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.ach_credit_trans, abc2.ach_credit_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.ach_credit_trans, 0.0000) != COALESCE(abc2.ach_credit_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.ach_credit_vol, abc2.ach_credit_vol 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.ach_credit_vol, 0.0000) != COALESCE(abc2.ach_credit_vol, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.ach_errors, abc2.ach_errors 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.ach_errors, 0.0000) != COALESCE(abc2.ach_errors, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.ach_noc_messages, abc2.ach_noc_messages 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.ach_noc_messages, 0.0000) != COALESCE(abc2.ach_noc_messages, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.ach_noc_message_charge, abc2.ach_noc_message_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.ach_noc_message_charge, 0.0000) != COALESCE(abc2.ach_noc_message_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.ach_returnerror_charge, abc2.ach_returnerror_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.ach_returnerror_charge, 0.0000) != COALESCE(abc2.ach_returnerror_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.ach_returns, abc2.ach_returns 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.ach_returns, 0.0000) != COALESCE(abc2.ach_returns, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.ach_sale_trans, abc2.ach_sale_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.ach_sale_trans, 0.0000) != COALESCE(abc2.ach_sale_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.ach_sale_vol, abc2.ach_sale_vol 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.ach_sale_vol, 0.0000) != COALESCE(abc2.ach_sale_vol, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.ach_sale_volume_charge, abc2.ach_sale_volume_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.ach_sale_volume_charge, 0.0000) != COALESCE(abc2.ach_sale_volume_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.apriva_monthly_charge, abc2.apriva_monthly_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.apriva_monthly_charge, 0.0000) != COALESCE(abc2.apriva_monthly_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.batch_files_processed, abc2.batch_files_processed 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.batch_files_processed, 0.0000) != COALESCE(abc2.batch_files_processed, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.card_convenience_charge, abc2.card_convenience_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.card_convenience_charge, 0.0000) != COALESCE(abc2.card_convenience_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.cc_auth_decline_trans, abc2.cc_auth_decline_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.cc_auth_decline_trans, 0.0000) != COALESCE(abc2.cc_auth_decline_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.cc_auth_trans, abc2.cc_auth_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.cc_auth_trans, 0.0000) != COALESCE(abc2.cc_auth_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.cc_auth_vol, abc2.cc_auth_vol 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.cc_auth_vol, 0.0000) != COALESCE(abc2.cc_auth_vol, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.cc_batches, abc2.cc_batches 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.cc_batches, 0.0000) != COALESCE(abc2.cc_batches, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.cc_capture_trans, abc2.cc_capture_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.cc_capture_trans, 0.0000) != COALESCE(abc2.cc_capture_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.cc_capture_vol, abc2.cc_capture_vol 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.cc_capture_vol, 0.0000) != COALESCE(abc2.cc_capture_vol, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.cc_credit_trans, abc2.cc_credit_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.cc_credit_trans, 0.0000) != COALESCE(abc2.cc_credit_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.cc_credit_vol, abc2.cc_credit_vol 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.cc_credit_vol, 0.0000) != COALESCE(abc2.cc_credit_vol, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.cc_keyed_trans, abc2.cc_keyed_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.cc_keyed_trans, 0.0000) != COALESCE(abc2.cc_keyed_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.cc_keyed_vol, abc2.cc_keyed_vol 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.cc_keyed_vol, 0.0000) != COALESCE(abc2.cc_keyed_vol, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.cc_ref_trans, abc2.cc_ref_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.cc_ref_trans, 0.0000) != COALESCE(abc2.cc_ref_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.cc_ref_vol, abc2.cc_ref_vol 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.cc_ref_vol, 0.0000) != COALESCE(abc2.cc_ref_vol, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.cc_sale_charge, abc2.cc_sale_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.cc_sale_charge, 0.0000) != COALESCE(abc2.cc_sale_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.cc_sale_decline_trans, abc2.cc_sale_decline_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.cc_sale_decline_trans, 0.0000) != COALESCE(abc2.cc_sale_decline_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.cc_sale_trans, abc2.cc_sale_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.cc_sale_trans, 0.0000) != COALESCE(abc2.cc_sale_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.cc_sale_vol, abc2.cc_sale_vol 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.cc_sale_vol, 0.0000) != COALESCE(abc2.cc_sale_vol, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.cc_swiped_trans, abc2.cc_swiped_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.cc_swiped_trans, 0.0000) != COALESCE(abc2.cc_swiped_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.cc_swiped_vol, abc2.cc_swiped_vol 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.cc_swiped_vol, 0.0000) != COALESCE(abc2.cc_swiped_vol, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.combined_decline_trans, abc2.combined_decline_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.combined_decline_trans, 0.0000) != COALESCE(abc2.combined_decline_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.decryption_count, abc2.decryption_count 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.decryption_count, 0.0000) != COALESCE(abc2.decryption_count, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.device_activated_count, abc2.device_activated_count 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.device_activated_count, 0.0000) != COALESCE(abc2.device_activated_count, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.device_activating_activated_count, abc2.device_activating_activated_count 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.device_activating_activated_count, 0.0000) != COALESCE(abc2.device_activating_activated_count, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.device_activating_count, abc2.device_activating_count 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.device_activating_count, 0.0000) != COALESCE(abc2.device_activating_count, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.device_other_activated_count, abc2.device_other_activated_count 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.device_other_activated_count, 0.0000) != COALESCE(abc2.device_other_activated_count, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.device_other_count, abc2.device_other_count 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.device_other_count, 0.0000) != COALESCE(abc2.device_other_count, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.device_stored_activated_count, abc2.device_stored_activated_count 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.device_stored_activated_count, 0.0000) != COALESCE(abc2.device_stored_activated_count, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.device_stored_count, abc2.device_stored_count 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.device_stored_count, 0.0000) != COALESCE(abc2.device_stored_count, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.file_transfer_monthly_charge, abc2.file_transfer_monthly_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.file_transfer_monthly_charge, 0.0000) != COALESCE(abc2.file_transfer_monthly_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.group_charge, abc2.group_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.group_charge, 0.0000) != COALESCE(abc2.group_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.group_count, abc2.group_count 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.group_count, 0.0000) != COALESCE(abc2.group_count, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.gw_monthly_charge, abc2.gw_monthly_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.gw_monthly_charge, 0.0000) != COALESCE(abc2.gw_monthly_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.gw_per_auth_charge, abc2.gw_per_auth_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.gw_per_auth_charge, 0.0000) != COALESCE(abc2.gw_per_auth_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.gw_per_auth_decline_charge, abc2.gw_per_auth_decline_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.gw_per_auth_decline_charge, 0.0000) != COALESCE(abc2.gw_per_auth_decline_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.gw_per_credit_charge, abc2.gw_per_credit_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.gw_per_credit_charge, 0.0000) != COALESCE(abc2.gw_per_credit_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.gw_per_refund_charge, abc2.gw_per_refund_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.gw_per_refund_charge, 0.0000) != COALESCE(abc2.gw_per_refund_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.gw_per_token_charge, abc2.gw_per_token_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.gw_per_token_charge, 0.0000) != COALESCE(abc2.gw_per_token_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.gw_reissued_ach_trans_charge, abc2.gw_reissued_ach_trans_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.gw_reissued_ach_trans_charge, 0.0000) != COALESCE(abc2.gw_reissued_ach_trans_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.gw_reissued_charge, abc2.gw_reissued_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.gw_reissued_charge, 0.0000) != COALESCE(abc2.gw_reissued_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.misc_monthly_charge, abc2.misc_monthly_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.misc_monthly_charge, 0.0000) != COALESCE(abc2.misc_monthly_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_active_device_trans, abc2.p2pe_active_device_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_active_device_trans, 0.0000) != COALESCE(abc2.p2pe_active_device_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_auth_decline_trans, abc2.p2pe_auth_decline_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_auth_decline_trans, 0.0000) != COALESCE(abc2.p2pe_auth_decline_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_auth_trans, abc2.p2pe_auth_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_auth_trans, 0.0000) != COALESCE(abc2.p2pe_auth_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_auth_vol, abc2.p2pe_auth_vol 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_auth_vol, 0.0000) != COALESCE(abc2.p2pe_auth_vol, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_capture_trans, abc2.p2pe_capture_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_capture_trans, 0.0000) != COALESCE(abc2.p2pe_capture_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_capture_vol, abc2.p2pe_capture_vol 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_capture_vol, 0.0000) != COALESCE(abc2.p2pe_capture_vol, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_credit_trans, abc2.p2pe_credit_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_credit_trans, 0.0000) != COALESCE(abc2.p2pe_credit_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_credit_vol, abc2.p2pe_credit_vol 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_credit_vol, 0.0000) != COALESCE(abc2.p2pe_credit_vol, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_declined_trans, abc2.p2pe_declined_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_declined_trans, 0.0000) != COALESCE(abc2.p2pe_declined_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_device_activated_charge, abc2.p2pe_device_activated_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_device_activated_charge, 0.0000) != COALESCE(abc2.p2pe_device_activated_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_device_activating_charge, abc2.p2pe_device_activating_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_device_activating_charge, 0.0000) != COALESCE(abc2.p2pe_device_activating_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_device_stored_charge, abc2.p2pe_device_stored_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_device_stored_charge, 0.0000) != COALESCE(abc2.p2pe_device_stored_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_encryption_charge, abc2.p2pe_encryption_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_encryption_charge, 0.0000) != COALESCE(abc2.p2pe_encryption_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_inactive_device_trans, abc2.p2pe_inactive_device_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_inactive_device_trans, 0.0000) != COALESCE(abc2.p2pe_inactive_device_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_refund_trans, abc2.p2pe_refund_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_refund_trans, 0.0000) != COALESCE(abc2.p2pe_refund_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_refund_vol, abc2.p2pe_refund_vol 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_refund_vol, 0.0000) != COALESCE(abc2.p2pe_refund_vol, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_sale_decline_trans, abc2.p2pe_sale_decline_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_sale_decline_trans, 0.0000) != COALESCE(abc2.p2pe_sale_decline_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_sale_trans, abc2.p2pe_sale_trans 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_sale_trans, 0.0000) != COALESCE(abc2.p2pe_sale_trans, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_sale_vol, abc2.p2pe_sale_vol 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_sale_vol, 0.0000) != COALESCE(abc2.p2pe_sale_vol, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_tokens_stored, abc2.p2pe_tokens_stored 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_tokens_stored, 0.0000) != COALESCE(abc2.p2pe_tokens_stored, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_token_charge, abc2.p2pe_token_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_token_charge, 0.0000) != COALESCE(abc2.p2pe_token_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_token_flat_charge, abc2.p2pe_token_flat_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_token_flat_charge, 0.0000) != COALESCE(abc2.p2pe_token_flat_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.p2pe_token_flat_monthly_charge, abc2.p2pe_token_flat_monthly_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.p2pe_token_flat_monthly_charge, 0.0000) != COALESCE(abc2.p2pe_token_flat_monthly_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pci_compliance_fee, abc2.pci_compliance_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pci_compliance_fee, 0.0000) != COALESCE(abc2.pci_compliance_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pci_monthly_charge, abc2.pci_monthly_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pci_monthly_charge, 0.0000) != COALESCE(abc2.pci_monthly_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pci_non_compliance_charge, abc2.pci_non_compliance_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pci_non_compliance_charge, 0.0000) != COALESCE(abc2.pci_non_compliance_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pci_non_compliance_fee, abc2.pci_non_compliance_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pci_non_compliance_fee, 0.0000) != COALESCE(abc2.pci_non_compliance_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pci_scans_monthly_charge, abc2.pci_scans_monthly_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pci_scans_monthly_charge, 0.0000) != COALESCE(abc2.pci_scans_monthly_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pc_account_updater_monthly_charge, abc2.pc_account_updater_monthly_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pc_account_updater_monthly_charge, 0.0000) != COALESCE(abc2.pc_account_updater_monthly_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_ach_credit_fee, abc2.pricing_ach_credit_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_ach_credit_fee, 0.0000) != COALESCE(abc2.pricing_ach_credit_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_ach_discount_rate, abc2.pricing_ach_discount_rate 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_ach_discount_rate, 0.0000) != COALESCE(abc2.pricing_ach_discount_rate, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_ach_monthly_fee, abc2.pricing_ach_monthly_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_ach_monthly_fee, 0.0000) != COALESCE(abc2.pricing_ach_monthly_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_ach_noc_fee, abc2.pricing_ach_noc_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_ach_noc_fee, 0.0000) != COALESCE(abc2.pricing_ach_noc_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_ach_per_gw_trans_fee, abc2.pricing_ach_per_gw_trans_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_ach_per_gw_trans_fee, 0.0000) != COALESCE(abc2.pricing_ach_per_gw_trans_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_ach_return_error_fee, abc2.pricing_ach_return_error_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_ach_return_error_fee, 0.0000) != COALESCE(abc2.pricing_ach_return_error_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_ach_transaction_fee, abc2.pricing_ach_transaction_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_ach_transaction_fee, 0.0000) != COALESCE(abc2.pricing_ach_transaction_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_bluefin_gateway_discount_rate, abc2.pricing_bluefin_gateway_discount_rate 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_bluefin_gateway_discount_rate, 0.0000) != COALESCE(abc2.pricing_bluefin_gateway_discount_rate, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_file_transfer_monthly_fee, abc2.pricing_file_transfer_monthly_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_file_transfer_monthly_fee, 0.0000) != COALESCE(abc2.pricing_file_transfer_monthly_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_gateway_monthly_fee, abc2.pricing_gateway_monthly_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_gateway_monthly_fee, 0.0000) != COALESCE(abc2.pricing_gateway_monthly_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_group_tag_fee, abc2.pricing_group_tag_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_group_tag_fee, 0.0000) != COALESCE(abc2.pricing_group_tag_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_gw_per_auth_decline_fee, abc2.pricing_gw_per_auth_decline_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_gw_per_auth_decline_fee, 0.0000) != COALESCE(abc2.pricing_gw_per_auth_decline_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_gw_per_credit_fee, abc2.pricing_gw_per_credit_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_gw_per_credit_fee, 0.0000) != COALESCE(abc2.pricing_gw_per_credit_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_gw_per_refund_fee, abc2.pricing_gw_per_refund_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_gw_per_refund_fee, 0.0000) != COALESCE(abc2.pricing_gw_per_refund_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_gw_per_sale_fee, abc2.pricing_gw_per_sale_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_gw_per_sale_fee, 0.0000) != COALESCE(abc2.pricing_gw_per_sale_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_gw_per_token_fee, abc2.pricing_gw_per_token_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_gw_per_token_fee, 0.0000) != COALESCE(abc2.pricing_gw_per_token_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_gw_reissued_fee, abc2.pricing_gw_reissued_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_gw_reissued_fee, 0.0000) != COALESCE(abc2.pricing_gw_reissued_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_misc_monthly_fee, abc2.pricing_misc_monthly_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_misc_monthly_fee, 0.0000) != COALESCE(abc2.pricing_misc_monthly_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_one_time_key_injection_fee, abc2.pricing_one_time_key_injection_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_one_time_key_injection_fee, 0.0000) != COALESCE(abc2.pricing_one_time_key_injection_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_p2pe_device_activated_fee, abc2.pricing_p2pe_device_activated_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_p2pe_device_activated_fee, 0.0000) != COALESCE(abc2.pricing_p2pe_device_activated_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_p2pe_device_activating_fee, abc2.pricing_p2pe_device_activating_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_p2pe_device_activating_fee, 0.0000) != COALESCE(abc2.pricing_p2pe_device_activating_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_p2pe_device_stored_fee, abc2.pricing_p2pe_device_stored_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_p2pe_device_stored_fee, 0.0000) != COALESCE(abc2.pricing_p2pe_device_stored_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_p2pe_encryption_fee, abc2.pricing_p2pe_encryption_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_p2pe_encryption_fee, 0.0000) != COALESCE(abc2.pricing_p2pe_encryption_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_p2pe_monthly_flat_fee, abc2.pricing_p2pe_monthly_flat_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_p2pe_monthly_flat_fee, 0.0000) != COALESCE(abc2.pricing_p2pe_monthly_flat_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_p2pe_tokenization_fee, abc2.pricing_p2pe_tokenization_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_p2pe_tokenization_fee, 0.0000) != COALESCE(abc2.pricing_p2pe_tokenization_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_pci_scans_monthly_fee, abc2.pricing_pci_scans_monthly_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_pci_scans_monthly_fee, 0.0000) != COALESCE(abc2.pricing_pci_scans_monthly_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_pc_acct_updater_fee, abc2.pricing_pc_acct_updater_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_pc_acct_updater_fee, 0.0000) != COALESCE(abc2.pricing_pc_acct_updater_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_per_transaction_fee, abc2.pricing_per_transaction_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_per_transaction_fee, 0.0000) != COALESCE(abc2.pricing_per_transaction_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_shieldconex_fields_fee, abc2.pricing_shieldconex_fields_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_shieldconex_fields_fee, 0.0000) != COALESCE(abc2.pricing_shieldconex_fields_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_shieldconex_monthly_fee, abc2.pricing_shieldconex_monthly_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_shieldconex_monthly_fee, 0.0000) != COALESCE(abc2.pricing_shieldconex_monthly_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_shieldconex_monthly_minimum_fee, abc2.pricing_shieldconex_monthly_minimum_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_shieldconex_monthly_minimum_fee, 0.0000) != COALESCE(abc2.pricing_shieldconex_monthly_minimum_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.pricing_shieldconex_transaction_fee, abc2.pricing_shieldconex_transaction_fee 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.pricing_shieldconex_transaction_fee, 0.0000) != COALESCE(abc2.pricing_shieldconex_transaction_fee, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.reissued_ach_transactions, abc2.reissued_ach_transactions 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.reissued_ach_transactions, 0.0000) != COALESCE(abc2.reissued_ach_transactions, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.reissued_cc_transactions, abc2.reissued_cc_transactions 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.reissued_cc_transactions, 0.0000) != COALESCE(abc2.reissued_cc_transactions, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.shieldconex_fields_charge, abc2.shieldconex_fields_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.shieldconex_fields_charge, 0.0000) != COALESCE(abc2.shieldconex_fields_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.shieldconex_monthly_charge, abc2.shieldconex_monthly_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.shieldconex_monthly_charge, 0.0000) != COALESCE(abc2.shieldconex_monthly_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.shieldconex_monthly_minimum_charge, abc2.shieldconex_monthly_minimum_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.shieldconex_monthly_minimum_charge, 0.0000) != COALESCE(abc2.shieldconex_monthly_minimum_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.shieldconex_transaction_charge, abc2.shieldconex_transaction_charge 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.shieldconex_transaction_charge, 0.0000) != COALESCE(abc2.shieldconex_transaction_charge, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.tokens_stored, abc2.tokens_stored 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.tokens_stored, 0.0000) != COALESCE(abc2.tokens_stored, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);

SELECT abc1.cardconex_acct_id, abc1.user_count, abc2.user_count 
  FROM auto_billing_dw.f_auto_billing_complete_shieldconex abc1   JOIN auto_billing_dw.f_auto_billing_complete_2 abc2 ON abc1.cardconex_acct_id = abc2.account_id  
 WHERE COALESCE(abc1.user_count, 0.0000) != COALESCE(abc2.user_count, 0.0000)
   AND abc1.cardconex_acct_id NOT IN (SELECT cardconex_acct_id FROM temp.dupe_fees);