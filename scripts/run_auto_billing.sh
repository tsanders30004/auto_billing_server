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
ls -lt ~/dir_source_default/*map_??????.txt

echo
echo Stop here if any of the map files are missing or out-of-date.
echo
read -p "press enter to continue..."

echo Confirm that the CURRENT VERSION of the ShieldConex file is present:
echo --------------------------------------------------------------------
ls -lt ~/dir_source_default/clientTransactionSummaryReport_2020??????????.csv

echo
echo Stop here if the ShieldConex file is  missing or out-of-date, or if more than one file is present.
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
mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_staging.stg_decryptx_cardconex_map; set foreign_key_checks=1;"

/usr/local/install/data-integration/pan.sh -file /home/svc-dbwh/repositories/auto_billing/pentaho/trans/src_decryptx_cardconex_map.ktr
read -p "press enter to run src_decryptx_device_cardconex_map.ktr..."

########## Decryptx Device Cardconex Map ##############################################################################
# Input File:    decryptx_device_cardconex_map.YYYYMMDD.xlsx
# Output Table:  auto_billing_staging.stg_decryptx_device_cardconex_map
mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_staging.stg_decryptx_device_cardconex_map; set foreign_key_checks=1;"

/usr/local/install/data-integration/pan.sh -file /home/svc-dbwh/repositories/auto_billing/pentaho/trans/src_decryptx_device_cardconex_map.ktr
read -p "press enter to run src_payconex_cardconex_map.ktr..."

########## Payconex Cardconex Map #####################################################################################
# Input File:    payconex_cardconex_map.YYYYMMDD.xlsx
# Output Table:  auto_billing_staging.stg_payconex_cardconex_map
mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_staging.stg_payconex_cardconex_map; set foreign_key_checks=1;"

/usr/local/install/data-integration/pan.sh -file /home/svc-dbwh/repositories/auto_billing/pentaho/trans/src_payconex_cardconex_map.ktr
read -p "press enter to run src_shieldconex.ktr..."

########## ShieldConex ################################################################################################
# Input File:    clientTransactionSummaryReport_YYYYMMDDHHMMSS.csv
# Output Table:  auto_billing_staging.stg_shieldconex

/usr/local/install/data-integration/pan.sh -file /home/svc-dbwh/repositories/auto_billing/pentaho/trans/src_shieldconex.ktr 

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


# ############################## Calculate ShieldConex Charges and Fees ###############################################
mysql -e"CALL update_shieldconex_fees_and_charges" auto_billing_dw

# ############################## Calculate bill_to_id #################################################################
mysql -e"CALL update_bill_to_id()" auto_billing_dw

# ############################## Add Demographics Coumns ##############################################################
mysql -e"CALL update_billing_demographics" auto_billing_dw

# define output filename
current_timestamp=$( date +"%Y%m%d_%H%M%S" )
output_file="auto_billing_complete_$current_timestamp.txt"

echo The line below shows the table used to create the output file.
cat /home/svc-dbwh/repositories/auto_billing/schema/f_auto_billing_complete.sql | grep FROM

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
