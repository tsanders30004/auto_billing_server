#!/bin/sh

# you need to direct the of this file to ~/logs/run_auth_billing.txt

echo Bluefin Payment Systems / Auto Billing 
echo
echo PURPOSE:  Import auto billing data and create auto_billing_complete output file.
echo 
echo Usage Notes
echo -----------
echo The script must be executed while logged in as the svc-dbwh user.
echo The script assumes you are creating the output for the previous month.  It will not work for other reporting periods.
echo You should monitor the contents of the ~/dir_errors_default and ~/logs directory.
echo 

rm -f ~/logs/run_auto_billing.txt 

echo Confirm that CURRENT VERSIONS of the three map files are present:
echo -----------------------------------------------------------------
ls -lt ~/dir_source_default/*map*

echo
echo Stop here if any of the map files are missing or out-of-date.
echo
read -p "press enter to continue..."

echo Make sure the tables below have been updated:
mysql -e"CALL check_prerequisites()" auto_billing_staging
echo 

read -p "press enter to run src_cardconex_account.ktr..."

# ########## Account ##################################################################################################
# 1 Jun 2020:  Clean up the comments where next month.
# Output Table:  auto_billing_staging.stg_cardconex_account

cd /home/svc-dbwh/repositories/sales_force/pentaho/trans/
/usr/local/install/data-integration/pan.sh -file /home/svc-dbwh/repositories/auto_billing/pentaho/trans/src_cardconex_account_2.ktr

mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_staging.stg_cardconex_account; set foreign_key_checks=1;"
mysql -v -v -e"INSERT INTO auto_billing_staging.stg_cardconex_account SELECT * FROM sales_force.test_cardconex_account"

read -p "press enter to run src_decryptx_cardconex_map.ktr..."

# ########## Decryptx Cardconex Map ###################################################################################
# Input File:    decryptx_cardconex_map.YYYYMMDD.xlsx
# Output Table:  auto_billing_staging.stg_decryptx_cardconex_map
# mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_staging.stg_decryptx_cardconex_map; set foreign_key_checks=1;"

# /usr/local/install/data-integration/pan.sh -file /home/svc-dbwh/repositories/auto_billing/pentaho/trans/src_decryptx_cardconex_map.ktr
read -p "press enter to run src_decryptx_device_cardconex_map.ktr..."

########## Decryptx Device Cardconex Map ##############################################################################
# Input File:    decryptx_device_cardconex_map.YYYYMMDD.xlsx
# Output Table:  auto_billing_staging.stg_decryptx_device_cardconex_map
# mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_staging.stg_decryptx_device_cardconex_map; set foreign_key_checks=1;"

# /usr/local/install/data-integration/pan.sh -file /home/svc-dbwh/repositories/auto_billing/pentaho/trans/src_decryptx_device_cardconex_map.ktr
read -p "press enter to run src_payconex_cardconex_map.ktr..."

########## Payconex Cardconex Map #####################################################################################
# Input File:    payconex_cardconex_map.YYYYMMDD.xlsx
# Output Table:  auto_billing_staging.stg_payconex_cardconex_map
# mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_staging.stg_payconex_cardconex_map; set foreign_key_checks=1;"

# /usr/local/install/data-integration/pan.sh -file /home/svc-dbwh/repositories/auto_billing/pentaho/trans/src_payconex_cardconex_map.ktr
read -p "press enter to verify length of cardconex_acct_id's..."

########## Check cardconex_acct_id Lengths in Map Files ###############################################################
mysql -v -v -e "call auto_billing_staging.check_cc_acct_len"
read -p "press enter to show staging summary..."

# ############################## Show Summary #########################################################################
mysql -v -v -e"call auto_billing_staging.show_input_file_summary;"
read -p "press enter to run dw_d_pricing.ktr..."

########## Pricing ####################################################################################################
# Output Table:  auto_billing_dw.d_pricing
mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_dw.d_pricing; set foreign_key_checks=1;"
/usr/local/install/data-integration/pan.sh -file /home/svc-dbwh/repositories/auto_billing/pentaho/trans/dw_d_pricing.ktr
read -p "press enter to run dw_d_merchant.ktr..."

########## Merchant ###################################################################################################
# Output Table:  auto_billing_dw.d_merchant
# Note:  Verify that we can always call auto_billing_dw.update_billing_frequency()

mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_dw.d_merchant; set foreign_key_checks=1;"
/usr/local/install/data-integration/pan.sh -file /home/svc-dbwh/repositories/auto_billing/pentaho/trans/dw_d_merchant.ktr
mysql -v -v -e"call auto_billing_dw.update_billing_frequency()"
read -p "press enter to run dw_f_decryptx_day.ktr..."

# ############################## f_decryptx_day #######################################################################
# Output Tables:  auto_billing_dw.f_decryptx_day_alt and auto_billing_dw.f_decryptx_day
#                 auto_billing_dw_d_device

mysql -v -e "set foreign_key_checks=0; truncate auto_billing_dw.f_decryptx_day_alt; truncate auto_billing_dw.f_decryptx_day; set foreign_key_checks=1;"
/usr/local/install/data-integration/pan.sh -file /home/svc-dbwh/repositories/auto_billing/pentaho/trans/dw_f_decryptx_day.ktr
read -p "press enter to run dw_d_processor.ktr..."

# ############################## d_processor ##########################################################################
# Output Table:  auto_billing_dw.d_processor (not truncated)

/usr/local/install/data-integration/pan.sh -file /home/svc-dbwh/repositories/auto_billing/pentaho/trans/dw_d_processor.ktr
read -p "press enter to dw_f_payconex_day.ktr..."

# ############################## f_payconex_day #######################################################################
# Output Table:  auto_billing_dw.f_payconex_day_alt and auto_billing_dw.f_payconex_day
mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_dw.f_payconex_day_alt; truncate auto_billing_dw.f_payconex_day; set foreign_key_checks=1;"

/usr/local/install/data-integration/pan.sh -file /home/svc-dbwh/repositories/auto_billing/pentaho/trans/dw_f_payconex_day.ktr
read -p "press enter to run dw_f_billing_month.ktr..."

# ############################## f_billing_month ######################################################################
# Output Table:  auto_billing_dw.f_billing_month_alt and auto_billing_dw.f_billing_month

mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_dw.f_billing_month_alt; truncate auto_billing_dw.f_billing_month; set foreign_key_checks=1;"
/usr/local/install/data-integration/pan.sh -file /home/svc-dbwh/repositories/auto_billing/pentaho/trans/dw_f_billing_month.ktr
read -p "press enter to run rpt_billing.ktr..."

# ############################## Auto Billing Complete ################################################################
# Output Table:  auto_billing_dw.f_auto_billing_complete (truncated)
# Output File:   /home/svc-dbwh/dir_output_default/auto_billing_complete_YYYYMMDD:HHMMSS.txt

/usr/local/install/data-integration/pan.sh -file /home/svc-dbwh/repositories/auto_billing/pentaho/trans/rpt_billing.ktr

# ############################## Update auto_billing_dw.f_auto_billing_dw.payconex_acct_id ############################
mysql auto_billing_dw < /home/svc-dbwh/repositories/auto_billing/schema/update_payconex_acct_id.sql

# define output filename
current_timestamp=$( date +"%Y%m%d_%H%M%S" )
output_file="auto_billing_complete_$current_timestamp.txt"
mysql auto_billing_dw < /home/svc-dbwh/repositories/auto_billing/schema/f_auto_billing_complete.sql > /home/svc-dbwh/dir_output_default/$output_file
ls -lt  /home/svc-dbwh/dir_output_default/$output_file

# prepare to email the output file.

# create the email body.
cd ~/dir_output_default

fn1=$(ls -t | head -n1)

rm -f ~/temp/msg.txt

echo 'Auto Billing File attached.'                    > ~/temp/msg.txt
ls -lt ~/dir_output_default/$fn1                     >> ~/temp/msg.txt
wc -l ~/dir_output_default/$fn1                      >> ~/temp/msg.txt 

cat ~/logs/run_auto_billing.txt                      >> ~/temp/msg.txt

# compress the output file
zip $fn1.zip $fn1

fn2=$(ls -t | head -n1)

# email the file
mailx -a $fn2 -s "Auto Billing File" tsanders@bluefin.com < ~/temp/msg.txt

read -p "press enter display sum of each column..."

# show sum of each column
mysql -v -v -e"SELECT 
  sum(p2pe_encryption_charge) AS p2pe_encryption_charge,
  sum(p2pe_token_flat_monthly_charge) AS p2pe_token_flat_monthly_charge,
  sum(p2pe_token_flat_charge) AS p2pe_token_flat_charge,
  sum(achworks_credit_charge) AS achworks_credit_charge,
  sum(achworks_per_trans_charge) AS achworks_per_trans_charge,
  sum(ach_returnerror_charge) AS ach_returnerror_charge,
  sum(ach_noc_message_charge) AS ach_noc_message_charge,
  sum(achworks_monthly_charge) AS achworks_monthly_charge,
  sum(ach_sale_volume_charge) AS ach_sale_volume_charge,
  sum(cc_sale_charge) AS cc_sale_charge,
  sum(group_charge) AS group_charge,
  sum(gw_reissued_charge) AS gw_reissued_charge,
  sum(gw_reissued_ach_trans_charge) AS gw_reissued_ach_trans_charge,
  sum(p2pe_token_charge) AS p2pe_token_charge,
  sum(apriva_monthly_charge) AS apriva_monthly_charge,
  sum(file_transfer_monthly_charge) AS file_transfer_monthly_charge,
  sum(misc_monthly_charge) AS misc_monthly_charge,
  sum(pc_account_updater_monthly_charge) AS pc_account_updater_monthly_charge,
  sum(pci_scans_monthly_charge) AS pci_scans_monthly_charge,
  sum(card_convenience_charge) AS card_convenience_charge,
  sum(gw_monthly_charge) AS gw_monthly_charge,
  sum(gw_per_auth_charge) AS gw_per_auth_charge,
  sum(gw_per_auth_decline_charge) AS gw_per_auth_decline_charge,
  sum(gw_per_refund_charge) AS gw_per_refund_charge,
  sum(gw_per_credit_charge) AS gw_per_credit_charge,
  sum(gw_per_token_charge) AS gw_per_token_charge,
  sum(p2pe_device_activated_charge) AS p2pe_device_activated_charge,
  sum(p2pe_device_activating_charge) AS p2pe_device_activating_charge,
  sum(p2pe_device_stored_charge) AS p2pe_device_stored_charge,
  sum(pricing_ach_credit_fee) AS pricing_ach_credit_fee,
  sum(pricing_ach_discount_rate) AS pricing_ach_discount_rate,
  sum(pricing_ach_monthly_fee) AS pricing_ach_monthly_fee,
  sum(pricing_ach_noc_fee) AS pricing_ach_noc_fee,
  sum(pricing_ach_per_gw_trans_fee) AS pricing_ach_per_gw_trans_fee,
  sum(pricing_ach_return_error_fee) AS pricing_ach_return_error_fee,
  sum(pricing_ach_transaction_fee) AS pricing_ach_transaction_fee,
  sum(pricing_bluefin_gateway_discount_rate) AS pricing_bluefin_gateway_discount_rate,
  sum(pricing_file_transfer_monthly_fee) AS pricing_file_transfer_monthly_fee,
  sum(pricing_gateway_monthly_fee) AS pricing_gateway_monthly_fee,
  sum(pricing_group_tag_fee) AS pricing_group_tag_fee,
  sum(pricing_gw_per_auth_decline_fee) AS pricing_gw_per_auth_decline_fee,
  sum(pricing_per_transaction_fee) AS pricing_per_transaction_fee,
  sum(pricing_gw_per_credit_fee) AS pricing_gw_per_credit_fee,
  sum(pricing_gw_per_refund_fee) AS pricing_gw_per_refund_fee,
  sum(pricing_gw_per_sale_fee) AS pricing_gw_per_sale_fee,
  sum(pricing_gw_per_token_fee) AS pricing_gw_per_token_fee,
  sum(pricing_gw_reissued_fee) AS pricing_gw_reissued_fee,
  sum(pricing_misc_monthly_fee) AS pricing_misc_monthly_fee,
  sum(pricing_p2pe_device_activated_fee) AS pricing_p2pe_device_activated_fee,
  sum(pricing_p2pe_device_activating_fee) AS pricing_p2pe_device_activating_fee,
  sum(pricing_p2pe_device_stored_fee) AS pricing_p2pe_device_stored_fee,
  sum(pricing_p2pe_encryption_fee) AS pricing_p2pe_encryption_fee,
  sum(pricing_p2pe_monthly_flat_fee) AS pricing_p2pe_monthly_flat_fee,
  sum(pricing_one_time_key_injection_fee) AS pricing_one_time_key_injection_fee,
  sum(pricing_p2pe_tokenization_fee) AS pricing_p2pe_tokenization_fee,
  sum(pricing_pci_scans_monthly_fee) AS pricing_pci_scans_monthly_fee,
  sum(pricing_pc_acct_updater_fee) AS pricing_pc_acct_updater_fee,
  sum(decryption_count) AS decryption_count,
  sum(device_activated_count) AS device_activated_count,
  sum(device_activating_count) AS device_activating_count,
  sum(device_stored_count) AS device_stored_count,
  sum(device_other_count) AS device_other_count,
  sum(device_activating_activated_count) AS device_activating_activated_count,
  sum(device_stored_activated_count) AS device_stored_activated_count,
  sum(device_other_activated_count) AS device_other_activated_count,
  sum(user_count) AS user_count,
  sum(group_count) AS group_count,
  sum(cc_auth_trans) AS cc_auth_trans,
  sum(cc_auth_vol) AS cc_auth_vol,
  sum(cc_sale_trans) AS cc_sale_trans,
  sum(cc_sale_vol) AS cc_sale_vol,
  sum(cc_ref_trans) AS cc_ref_trans,
  sum(cc_ref_vol) AS cc_ref_vol,
  sum(cc_credit_trans) AS cc_credit_trans,
  sum(cc_credit_vol) AS cc_credit_vol,
  sum(cc_sale_decline_trans) AS cc_sale_decline_trans,
  sum(cc_auth_decline_trans) AS cc_auth_decline_trans,
  sum(cc_batches) AS cc_batches,
  sum(cc_keyed_trans) AS cc_keyed_trans,
  sum(cc_keyed_vol) AS cc_keyed_vol,
  sum(cc_swiped_trans) AS cc_swiped_trans,
  sum(cc_swiped_vol) AS cc_swiped_vol,
  sum(ach_sale_trans) AS ach_sale_trans,
  sum(ach_sale_vol) AS ach_sale_vol,
  sum(ach_credit_trans) AS ach_credit_trans,
  sum(ach_credit_vol) AS ach_credit_vol,
  sum(ach_batches) AS ach_batches,
  sum(ach_returns) AS ach_returns,
  sum(ach_errors) AS ach_errors,
  sum(ach_noc_messages) AS ach_noc_messages,
  sum(p2pe_auth_trans) AS p2pe_auth_trans,
  sum(p2pe_auth_vol) AS p2pe_auth_vol,
  sum(p2pe_sale_trans) AS p2pe_sale_trans,
  sum(p2pe_sale_vol) AS p2pe_sale_vol,
  sum(p2pe_refund_trans) AS p2pe_refund_trans,
  sum(p2pe_refund_vol) AS p2pe_refund_vol,
  sum(p2pe_credit_trans) AS p2pe_credit_trans,
  sum(p2pe_credit_vol) AS p2pe_credit_vol,
  sum(p2pe_sale_decline_trans) AS p2pe_sale_decline_trans,
  sum(p2pe_auth_decline_trans) AS p2pe_auth_decline_trans,
  sum(p2pe_active_device_trans) AS p2pe_active_device_trans,
  sum(p2pe_inactive_device_trans) AS p2pe_inactive_device_trans,
  sum(tokens_stored) AS tokens_stored,
  sum(batch_files_processed) AS batch_files_processed,
  sum(cc_capture_trans) AS cc_capture_trans,
  sum(cc_capture_vol) AS cc_capture_vol,
  sum(p2pe_capture_trans) AS p2pe_capture_trans,
  sum(p2pe_capture_vol) AS p2pe_capture_vol,
  sum(combined_decline_trans) AS combined_decline_trans,
  sum(p2pe_declined_trans) AS p2pe_declined_trans,
  sum(p2pe_tokens_stored) AS p2pe_tokens_stored,
  sum(reissued_cc_transactions) AS reissued_cc_transactions,
  sum(reissued_ach_transactions) AS reissued_ach_transactions
FROM auto_billing_dw.f_auto_billing_complete\G" auto_billing_dw

read -p "press enter to continue..."

echo Remember to update the history tables via update_history.ktr.

