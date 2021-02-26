#!/bin/sh

# you need to direct the of this file to ~/logs/run_auth_billing.txt

echo Bluefin Payment Systems / Auto Billing II 
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

# Define the billing period; i.e., YYYYMM for the previous month.
BILLING_PERIOD=$( date -d "$(date +%Y-%m-01) -1 day" +%Y%m )
TRUSTWAVE_PERIOD=$( date -d "$(date +%Y-%m-01) -1 day" +%Y-%m )

# Define directory names.
DIR_SOURCE_DEFAULT="/home/tsanders/dir_source_default"
DIR_REPO="/home/tsanders/repositories/csv_to_mysql"
DIR_SCHEMA="/home/tsanders/repositories/auto_billing/schema"

# Derive the filenames.
DCM_FILENAME="$DIR_SOURCE_DEFAULT/decryptx_cardconex_map_$BILLING_PERIOD.csv"
DDCM_FILENAME="$DIR_SOURCE_DEFAULT/decryptx_device_cardconex_map_$BILLING_PERIOD.csv"
PCM_FILENAME="$DIR_SOURCE_DEFAULT/payconex_cardconex_map_$BILLING_PERIOD.csv"
SHIELDCONEX_FILENAME=$DIR_SOURCE_DEFAULT/clientTransactionSummaryReport_$( date -d "$(date +%Y-%m-01) " +%Y%m%d000000 ).csv
TRUSTWAVE_FILENAME=($(ls /home/tsanders/dir_source_default/Merchant_Detail_Report-$TRUSTWAVE_PERIOD*.csv))

echo Confirm that CURRENT VERSIONS of the three map files are present:
echo -----------------------------------------------------------------
ls -lt $DCM_FILENAME
ls -lt $DDCM_FILENAME
ls -lt $PCM_FILENAME
echo
echo Stop here if any of the map files are missing or out-of-date.
echo
read -p "press enter to continue..."

echo Confirm that the CURRENT VERSION of the ShieldConex file is present:
echo --------------------------------------------------------------------
ls -lt $SHIELDCONEX_FILENAME

echo
echo Stop here if the ShieldConex file is  missing or out-of-date, or if more than one file is present.
echo
read -p "press enter to continue..."

echo Confirm that the CURRENT VERSION of the Trustwave file is present:
echo ------------------------------------------------------------------
ls -lt $TRUSTWAVE_FILENAME

echo
echo Stop here if the Trustwave file is  missing or out-of-date, or if more than one file is present.
echo
read -p "press enter to continue..."

echo Make sure the tables below have been updated:
echo IMPORTANT:  check_prerequisites has been DISABLED.  Need to RE-ENABLE.
# mysql -e"CALL check_prerequisites()" auto_billing_staging
echo 

read -p "press enter to continue..."

# ########## Import Map Files #########################################################################################
# Import the following files into the table indicated:
# File Name                                  Table Name
# ------------------------------------------------------------------------------------------------- 
# decryptx_cardconex_map_YYYYMM.csv          auto_billing_staging.stg_decryptx__cardconex_map
# decryptx_device_cardconex_map_YYYYMM.csv   auto_billing_staging.stg_decryptx_device_cardconex_map
# payconex_cardconex_map.csv                 auto_billing_staging.stg_payconex_device_cardconex_map

# where YYYYMM represents the year and month of the previous month, relative to the current date.
# Example:  If today = 2021-01-04, then YYYYMM = 202012.
# This script will import only the files which correspond to the previous month, even if older files are present.

# Import the files.
# mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_staging.stg_decryptx_cardconex_map; set foreign_key_checks=1;"
# node $DIR_REPO/mysql_import.js auto_billing_staging $DCM_FILENAME

mysql < $DIR_SCHEMA/src_decryptx_cardconex_map.sql
mysql -e"SELECT source_file, COUNT(*), MIN(import_timestamp), MAX(import_timestamp) FROM auto_billing_staging.stg_decryptx_cardconex_map GROUP BY 1"
read -p "press enter to continue..."

# mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_staging.stg_decryptx_device_cardconex_map; set foreign_key_checks=1;"
# node $DIR_REPO/mysql_import.js auto_billing_staging $DDCM_FILENAME
mysql < $DIR_SCHEMA/src_decryptx_device_cardconex_map.sql
mysql -e"SELECT source_file, COUNT(*), MIN(import_timestamp), MAX(import_timestamp) FROM auto_billing_staging.stg_decryptx_device_cardconex_map GROUP BY 1"
read -p "press enter to continue..."

# mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_staging.stg_payconex_cardconex_map; set foreign_key_checks=1;"
# node $DIR_REPO/mysql_import.js auto_billing_staging $PCM_FILENAME 
mysql < $DIR_SCHEMA/src_payconex_cardconex_map.sql
mysql -e"SELECT source_file, COUNT(*), MIN(import_timestamp), MAX(import_timestamp) FROM auto_billing_staging.stg_payconex_cardconex_map GROUP BY 1"
read -p "press enter to continue..."

########## ShieldConex ################################################################################################
# Input File:    clientTransactionSummaryReport_YYYYMMDDHHMMSS.csv
# Output Table:  auto_billing_staging.stg_shieldconex

echo ShieldConex
node $DIR_REPO/mysql_import.js auto_billing_staging $SHIELDCONEX_FILENAME
# mysql -e"SELECT source_file, COUNT(*), MIN(import_timestamp), MAX(import_timestamp) FROM stg_shieldconex GROUP BY 1" auto_billing_staging
read -p "press enter to continue..."

########## Trustwave # ################################################################################################
# Input File:    Merchant_Detail_Report-YYYY-MM-DD-{H|HH}-{M|MM}-{S|SS}.csv
# Output Table:  auto_billing_staging.stg_trustwave

mysql < $DIR_SCHEMA/src_trustwave.sql
# mysql -e"SELECT source_file, MAX(import_timestamp), COUNT(*) FROM auto_billing_staging.stg_trustwave" auto_billing_staging
read -p "press enter continue..."

########## Check cardconex_acct_id Lengths in Map Files ###############################################################
mysql -v -v -e "call auto_billing_staging.check_cc_acct_len"
read -p "press enter to show staging summary..."

# ############################## Show Summary #########################################################################
echo IMPORTANT:   auto_billing_staging.show_input_file_summary has been DISABLED.  Need to RE-ENABLE
# mysql -v -v -e"call auto_billing_staging.show_input_file_summary;"
read -p "press enter to populate auto_billing_dw.f_auto_billing_complete_2..."

# update auto_billing_dw.f_auto_billing_complete_2

mysql -e"CALL auto_billing_dw.f_auto_billing_complete_initialize()"
read -p "press enter to continue..."

mysql -e"CALL auto_billing_staging.populate_stg_asset()"
read -p "press enter to continue..."

mysql -e"CALL auto_billing_dw.f_auto_billing_complete_assets()"
read -p "press enter to continue..."

mysql -e"CALL auto_billing_dw.f_auto_billing_complete_decryptx()"
read -p "press enter to continue..."

mysql -e"CALL auto_billing_dw.f_auto_billing_complete_payconex()"
read -p "press enter to continue..."

mysql -e"CALL auto_billing_dw.f_auto_billing_complete_payconex_acct_id"
read -p "press enter to continue..."

mysql -e"CALL auto_billing_dw.f_auto_billing_complete_shieldconex"
read -p "XXXXX press enter to continue..."

mysql -e"CALL auto_billing_dw.f_auto_billing_complete_pci_charges"
read -p "press enter to continue..."

mysql -e"CALL auto_billing_dw.update_bill_to_id_2()"
read -p "press enter to continue..."

mysql -e"CALL auto_billing_dw.f_auto_billing_complete_demographics"
read -p "press enter to continue..."

mysql -e"CALL auto_billing_history.update_history"
read -p "press enter to continue..."

# define output filename
current_timestamp=$( date +"%Y%m%d_%H%M%S" )
output_file="auto_billing_complete_$current_timestamp.txt"

echo The line below shows the table used to create the output file.
cat /home/tsanders/repositories/auto_billing/schema/f_auto_billing_complete_2.sql | grep FROM

mysql auto_billing_dw < /home/tsanders/repositories/auto_billing/schema/f_auto_billing_complete_2.sql > /home/tsanders/dir_output_default/$output_file
ls -lt  /home/tsanders/dir_output_default/$output_file

# prepare to email the output file.

# create the email body.
cd ~/dir_output_default

fn1=$(ls -t | head -n1)

rm -f ~/temp/msg.txt

echo 'Auto Billing File attached.'                    > ~/temp/msg.txt
ls -lt ~/dir_output_default/$fn1                     >> ~/temp/msg.txt
wc -l ~/dir_output_default/$fn1                      >> ~/temp/msg.txt 

# compress the output file
zip $fn1.zip $fn1

fn2=$(ls -t | head -n1)

# email the file
mailx -a $fn2 -s "Auto Billing File" tsanders@bluefin.com < ~/temp/msg.txt
