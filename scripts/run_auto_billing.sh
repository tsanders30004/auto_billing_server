#!/bin/sh

echo
echo B\ L U E F I N\ \ \ P A Y M E N T\ \ \ S Y S T E M S\ \ \ /\ \ \ A U T O\ \ \ B I L L I N G
echo ===========================================================================
echo
echo PURPOSE:  Import auto billing data and create auto_billing_complete output file.
echo 
echo Usage Notes
echo -----------
echo The script must be executed while logged in as the svc-dbwh user.
echo The script assumes you are creating the output for the previous month.  It will not work for other reporting periods.
echo You should monitor the contents of the ~/dir_errors_default and ~/logs directory.
echo 

# Shell Variables

AUTO_BILLING_REPO=/home/tsanders/repositories/auto_billing
DIR_OUTPUT_DEFAULT=/home/tsanders/dir_output_default
DIR_SOURCE_DEFAULT=/home/tsanders/dir_source_default
FILE_RECIPIENT_EMAIL_ADDRESS=tsanders@bluefin.com
LOG_DIR=/home/tsanders/logs
PENTAHO_DIR=/home/tsanders/data-integration-7
TEMP_DIR=/home/tsanders/temp

hostname 

echo 
echo Auto Billing Repository:\ \ \ $AUTO_BILLING_REPO
echo Input File Directory: \ \ \ \ \ $DIR_SOURCE_DEFAULT
echo Output File Directory:\ \ \ \ \ $DIR_OUTPUT_DEFAULT
echo Log File Directory:\ \ \ \ \ \ \ \ $LOG_DIR
echo Pentaho Directory:\ \ \ \ \ \ \ \ \ $PENTAHO_DIR
echo Temporary Directory:\ \ \ \ \ \ \ $TEMP_DIR
echo 

rm -f $LOG_DIR/run_auto_billing.txt 

echo Confirm that CURRENT VERSIONS of the three map files are present:
echo -----------------------------------------------------------------
ls -lt $DIR_SOURCE_DEFAULT/*map_??????.txt

echo
echo Stop here if any of the map files are missing or out-of-date.
echo
read -p "press enter to continue..."

echo Make sure the tables below have been updated:
mysql -e"CALL check_prerequisites()" auto_billing_staging
echo 

read -p "press enter to run src_cardconex_account.ktr..."

# ########## Account ##################################################################################################
# Output Table:  auto_billing_staging.stg_cardconex_account

$PENTAHO_DIR/pan.sh -file $AUTO_BILLING_REPO/pentaho/trans/src_cardconex_account_2.ktr

mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_staging.stg_cardconex_account; set foreign_key_checks=1;"
mysql -v -v -e"INSERT INTO auto_billing_staging.stg_cardconex_account SELECT * FROM sales_force.test_cardconex_account"

read -p "press enter to run src_decryptx_cardconex_map.ktr..."

# ########## Decryptx Cardconex Map ###################################################################################
# Input File:    decryptx_cardconex_map.YYYYMMDD.xlsx
# Output Table:  auto_billing_staging.stg_decryptx_cardconex_map
mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_staging.stg_decryptx_cardconex_map; set foreign_key_checks=1;"

$PENTAHO_DIR/pan.sh -file $AUTO_BILLING_REPO/pentaho/trans/src_decryptx_cardconex_map.ktr
read -p "press enter to run src_decryptx_device_cardconex_map.ktr..."

########## Decryptx Device Cardconex Map ##############################################################################
# Input File:    decryptx_device_cardconex_map.YYYYMMDD.xlsx
# Output Table:  auto_billing_staging.stg_decryptx_device_cardconex_map
mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_staging.stg_decryptx_device_cardconex_map; set foreign_key_checks=1;"

$PENTAHO_DIR/pan.sh -file $AUTO_BILLING_REPO/pentaho/trans/src_decryptx_device_cardconex_map.ktr
read -p "press enter to run src_payconex_cardconex_map.ktr..."

########## Payconex Cardconex Map #####################################################################################
# Input File:    payconex_cardconex_map.YYYYMMDD.xlsx
# Output Table:  auto_billing_staging.stg_payconex_cardconex_map
mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_staging.stg_payconex_cardconex_map; set foreign_key_checks=1;"

$PENTAHO_DIR/pan.sh -file $AUTO_BILLING_REPO/pentaho/trans/src_payconex_cardconex_map.ktr

read -p "press enter to run src_shieldconex.ktr..."

########## ShieldConex ################################################################################################
# Input File:    clientTransactionSummaryReport_YYYYMMDDHHMMSS.csv
# Output Table:  auto_billing_staging.stg_shieldconex

/home/tsanders/data-integration-7/pan.sh -file /home/tsanders/repositories/auto_billing/pentaho/trans/src_shieldconex.ktr 

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
$PENTAHO_DIR/pan.sh -file $AUTO_BILLING_REPO/pentaho/trans/dw_d_pricing.ktr
read -p "press enter to run dw_d_merchant.ktr..."

########## Merchant ###################################################################################################
# Output Table:  auto_billing_dw.d_merchant
# Note:  Verify that we can always call auto_billing_dw.update_billing_frequency()

mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_dw.d_merchant; set foreign_key_checks=1;"
$PENTAHO_DIR/pan.sh -file $AUTO_BILLING_REPO/pentaho/trans/dw_d_merchant.ktr
mysql -v -v -e"call auto_billing_dw.update_billing_frequency()"
read -p "press enter to run dw_f_decryptx_day.ktr..."

# ############################## f_decryptx_day #######################################################################
# Output Tables:  auto_billing_dw.f_decryptx_day_alt and auto_billing_dw.f_decryptx_day
#                 auto_billing_dw_d_device

mysql -v -e "set foreign_key_checks=0; truncate auto_billing_dw.f_decryptx_day_alt; truncate auto_billing_dw.f_decryptx_day; set foreign_key_checks=1;"
$PENTAHO_DIR/pan.sh -file $AUTO_BILLING_REPO/pentaho/trans/dw_f_decryptx_day.ktr
read -p "press enter to run dw_d_processor.ktr..."

# ############################## d_processor ##########################################################################
# Output Table:  auto_billing_dw.d_processor (not truncated)

$PENTAHO_DIR/pan.sh -file $AUTO_BILLING_REPO/pentaho/trans/dw_d_processor.ktr
read -p "press enter to dw_f_payconex_day.ktr..."

# ############################## f_payconex_day #######################################################################
# Output Table:  auto_billing_dw.f_payconex_day_alt and auto_billing_dw.f_payconex_day
mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_dw.f_payconex_day_alt; truncate auto_billing_dw.f_payconex_day; set foreign_key_checks=1;"

$PENTAHO_DIR/pan.sh -file $AUTO_BILLING_REPO/pentaho/trans/dw_f_payconex_day.ktr
read -p "press enter to run dw_f_billing_month.ktr..."

# ############################## f_billing_month ######################################################################
# Output Table:  auto_billing_dw.f_billing_month_alt and auto_billing_dw.f_billing_month

mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_dw.f_billing_month_alt; truncate auto_billing_dw.f_billing_month; set foreign_key_checks=1;"
$PENTAHO_DIR/pan.sh -file $AUTO_BILLING_REPO/pentaho/trans/dw_f_billing_month.ktr
read -p "press enter to run rpt_billing.ktr..."

# ############################## Auto Billing Complete ################################################################
# Output Table:  auto_billing_dw.f_auto_billing_complete (truncated)
# Output File:   /home/svc-dbwh/dir_output_default/auto_billing_complete_YYYYMMDD:HHMMSS.txt

$PENTAHO_DIR/pan.sh -file $AUTO_BILLING_REPO/pentaho/trans/rpt_billing.ktr

# ############################## Update auto_billing_dw.f_auto_billing_dw.payconex_acct_id ############################
mysql auto_billing_dw < $AUTO_BILLING_REPO/schema/update_payconex_acct_id.sql

# ############################## Calculate ShieldConex Charges and Fees ###############################################
mysql -e"CALL update_shieldconex_fees_and_charges" auto_billing_dw

# ############################## Calculate bill_to_id #################################################################
mysql -e"CALL update_bill_to_id()" auto_billing_dw

# ############################## Add Demographics Coumns ##############################################################
mysql -e"CALL update_billing_demographics" auto_billing_dw


CURRENT_TIMESTAMP=$( date +"%Y%m%d_%H%M%S" )
OUTPUT_FILE=$DIR_OUTPUT_DEFAULT"/auto_billing_complete_$CURRENT_TIMESTAMP.txt"

# ############################## Create the Output File ###############################################################
mysql auto_billing_dw < $AUTO_BILLING_REPO/schema/f_auto_billing_complete_shieldconex.sql > $OUTPUT_FILE 
# assume the output file is the most recently-created file in $DIR_OUTPUT_DEFAULT
fn1=$(ls -t $DIR_OUTPUT_DEFAULT | head -n1)

# ############################## E-Mail the File ######################################################################
rm -f $TEMP_DIR/auto_billing_email_body.txt

echo 'Auto Billing Complete File attached.'  > $TEMP_DIR/auto_billing_email_body.txt
date                                         >> $TEMP_DIR/auto_billing_email_body.txt
ls -lt $DIR_OUTPUT_DEFAULT/$fn1              >> $TEMP_DIR/auto_billing_email_body.txt
wc -l  $DIR_OUTPUT_DEFAULT/$fn1              >> $TEMP_DIR/auto_billing_email_body.txt 

# compress the output file
cd $DIR_OUTPUT_DEFAULT
zip $fn1.zip $fn1

# assume the compressed file is the most recently created file in $DIR_OUTPUT_DEFAULT
fn2=$(ls -t $DIR_OUTPUT_DEFAULT | head -n1)

# email the file
mailx -a $fn2 -s "Auto Billing Complete File" $FILE_RECIPIENT_EMAIL_ADDRESS < $TEMP_DIR/auto_billing_email_body.txt


