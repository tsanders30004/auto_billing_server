#!/bin/sh

# you need to direct the of this file to ~/logs/run_auth_billing.txt

echo Bluefin Payment Systems / Auto Billing II 
echo
echo PURPOSE:  Populate auto_billing_dw.f_auto_billing_complete_2
echo 

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

echo Confirm that CURRENT VERSIONS of the following files are present:
echo -----------------------------------------------------------------
ls -lt $DCM_FILENAME
ls -lt $DDCM_FILENAME
ls -lt $PCM_FILENAME
ls -lt $TRUSTWAVE_FILENAME
ls -lt $SHIELDCONEX_FILENAME

echo
echo Stop here if any of files are missing or out-of-date, or if more than one of each file type is present
echo
# read -p "press ENTER to continue..."

echo Make sure the tables below have been updated
echo WARNING:  check_prerequisites has been DISABLED.  Need to RE-ENABLE.
# mysql -e"CALL check_prerequisites()" auto_billing_staging

echo 

read -p "press ENTER to continue..."

# ########## Import Map Files #########################################################################################
# Import the following files into the table indicated:
# File Name                                  Table Name
# ------------------------------------------------------------------------------------------------- 
# decryptx_cardconex_map_YYYYMM.csv                            auto_billing_staging.stg_decryptx__cardconex_map
# decryptx_device_cardconex_map_YYYYMM.csv                     auto_billing_staging.stg_decryptx_device_cardconex_map
# payconex_cardconex_map_YYYYMM.csv                            auto_billing_staging.stg_payconex_device_cardconex_map
# Merchant_Detail_Report-YYYY-MM-DD-{H|HH}-{M|MM}-{S|SS}.csv   auto_billing_staging.stg_trustwave
# clientTransactionSummaryReport_YYYYMMDDHHMMSS.csv            auto_billing_staging.stg_shieldconex

# YYYYMM and YYYY-MM represent the year and month of the previous month, relative to the current date.
# Only YYYY-MM is important in the Trustwave and ShieldConex files; values for DD, HH, MM, SS are ignored.
# This script will import only the files which correspond to the previous month, even if older files are present.

echo Importing $DCM_FILENAME

mysql -e"
  TRUNCATE auto_billing_staging.stg_decryptx_cardconex_map;
  SET @n = 0;
  SET @source_file = REPLACE(REPLACE('$DCM_FILENAME', '$DIR_SOURCE_DEFAULT', ''), '/', '');

  LOAD DATA LOCAL INFILE '$DCM_FILENAME'
  INTO TABLE auto_billing_staging.stg_decryptx_cardconex_map
  FIELDS TERMINATED BY ','
  OPTIONALLY ENCLOSED BY '\"'
  LINES TERMINATED BY '\r\n'
  IGNORE 1 LINES
  (@col01 
  ,@col02 
  ,@col03
  ,@col04
  ,@col05)
  SET 
    decryptx_acct_id = @col01 
   ,decryptx_acct_name = @col02 
   ,decryptx_partner_id = @col03 
   ,decryptx_partner_name = @col04 
   ,cardconex_acct_id = @col05 
   ,source_file = @source_file
   ,source_row = @n := @n + 1"

echo 
echo Importing $DDCM_FILENAME

mysql -e"
    TRUNCATE auto_billing_staging.stg_decryptx_device_cardconex_map;
    SET @n = 0;
    SET @source_file = REPLACE(REPLACE('$DDCM_FILENAME', '$DIR_SOURCE_DEFAULT', ''), '/', '');

    LOAD DATA LOCAL INFILE '$DDCM_FILENAME'
    INTO TABLE auto_billing_staging.stg_decryptx_device_cardconex_map
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '\"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES(
     @col01
    ,@col02
    ,@col03)
    SET 
     decryptx_device_id = @col01
    ,decryptx_location_id = @col02
    ,cardconex_acct_id = @col03
    ,source_file = @source_file
    ,source_row = @n := @n + 1"

echo
echo Importing $PCM_FILENAME

mysql -e"
    TRUNCATE auto_billing_staging.stg_payconex_cardconex_map;
    SET @n = 0;
    SET @source_file = REPLACE(REPLACE('$PCM_FILENAME', '$DIR_SOURCE_DEFAULT', ''), '/', '');
    
    LOAD DATA LOCAL INFILE '$PCM_FILENAME'
    INTO TABLE auto_billing_staging.stg_payconex_cardconex_map
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '\"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES(
     @col01
    ,@col02)
    SET 
     payconex_acct_id = @col01
    ,cardconex_acct_id = @col02
    ,source_file = @source_file
    ,source_row = @n := @n + 1"

echo
echo Importing $TRUSTWAVE_FILENAME

mysql -e"
    TRUNCATE auto_billing_staging.stg_trustwave;
    SET @n = 0;
    SET @source_file = REPLACE(REPLACE('$TRUSTWAVE_FILENAME', '$DIR_SOURCE_DEFAULT', ''), '/', '');

    LOAD DATA LOCAL INFILE '$TRUSTWAVE_FILENAME'
    INTO TABLE auto_billing_staging.stg_trustwave
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES(
         @col01
        ,@col02
        ,@col03
        ,@col04
        ,@col05
        ,@col06
        ,@col07
        ,@col08
        ,@col09
        ,@col10
        ,@col11
        ,@col12
        ,@col13
        ,@col14
        ,@col15
        ,@col16
        ,@col17
        ,@col18
        ,@col19
        ,@col20
        ,@col21
        ,@col22
        ,@col23
        ,@col24
        ,@col25
        ,@col26
        ,@col27
        ,@col28
        ,@col29
        ,@col30
        ,@col31
        ,@col32
        ,@col33
        ,@col34
        ,@col35
        ,@col36
        ,@col37
        ,@col38
        ,@col39
        ,@col40
        ,@col41
        ,@col42
        ,@col43
        ,@col44
        ,@col45
        ,@col46
        ,@col47
        ,@col48
        ,@col49
        ,@col50
        ,@col51
        ,@col52
        ,@col53
        ,@col54
        ,@col55
        ,@col56
        ,@col57
        ,@col58
        ,@col59
        ,@col60
        ,@col61
        ,@col62
        ,@col63
        ,@col64
        ,@col65
        ,@col66
        ,@col67
        ,@col68
        ,@col69
        ,@col70)
    SET 
         customer_id                    = @col01
        ,company_name                   = @col02
        ,mid                            = @col03
        ,primary_mid                    = @col04
        ,merchant_type                  = @col05
        ,compliance_program             = @col06
        ,date_added                     = dba.text_to_date(@col07)                          -- convert 'YYYY-MM-DD' (VARCHAR 10) to DATE
        ,date_registered                = dba.text_to_date(@col08)
        ,registration_code              = @col09
        ,initial_certification_deadline = dba.text_to_date(@col10)
        ,pci_status                     = @col11
        ,pci_expiry                     = dba.text_to_date(@col12)
        ,first_certification_date       = dba.text_to_date(@col13)
        ,scan_status                    = @col14
        ,most_recent_scan_date          = dba.text_to_date(@col15)
        ,scan_expiry                    = dba.text_to_date(@col16)
        ,scan_location_count            = IF(LENGTH(@col17) = 0, NULL, scan_location_count) -- convert empty string to INT
        ,saq_status                     = @col18
        ,saq_type                       = @col19
        ,saq_version                    = @col20
        ,saq_document_type              = @col21
        ,most_recent_saq_date           = dba.text_to_date(@col22)
        ,saq_expiry                     = dba.text_to_date(@col23)
        ,pa_dss_status                  = @col24
        ,pci_milestone_1                = @col25
        ,pci_milestone_2                = @col26
        ,pci_milestone_3                = @col27
        ,pci_milestone_4                = @col28
        ,pci_milestone_5                = @col29
        ,pci_milestone_6                = @col30
        ,ec_psp_status                  = @col31
        ,sp_status                      = @col32
        ,expected_compliance_program    = @col33
        ,mid_status                     = @col34
        ,pre_registration_link          = @col35
        ,chain_id                       = @col36
        ,sponsor_name                   = @col37
        ,relationship_type              = @col38
        ,assessor                       = @col39
        ,service_providers              = @col40
        ,primary_user_first_name        = @col41
        ,primary_user_last_name         = @col42
        ,primary_user_email             = @col43
        ,primary_user_phone             = @col44
        ,primary_user_username          = @col45
        ,primary_user_language          = @col46
        ,pci_level                      = @col47
        ,country                        = @col48
        ,state_province                 = @col49
        ,close_date                     = dba.text_to_date(@col50)
        ,last_login_date                = dba.text_to_date(@col51)
        ,industry                       = @col52
        ,mcc                            = IF(LENGTH(@col53) = 0, NULL, mcc)
        ,pre_registration_email         = @col54
        ,pre_registration_phone         = @col55
        ,in_play_date                   = @col56
        ,marketing_call_campaign        = @col57
        ,marketing_email_campaign       = @col58
        ,marketing_direct_campaign      = @col59
        ,offering_type_override         = @col60
        ,offering_expiry                = dba.text_to_date(@col61)
        ,external_mid                   = @col62
        ,last_four_of_mid               = @col63
        ,breach_coverage_option         = @col64
        ,integrator_reseller_name       = @col65
        ,qir_status                     = @col66
        ,program_date_added             = @col67
        ,last_offering_change_date      = @col68
        ,last_scan_attestation_date     = dba.text_to_date(@col69)
        ,scan_attestation_expiry_date   = dba.text_to_date(@col70)
        ,source_file                    = @source_file
        ,source_row                     = @n := @n + 1"   

echo
echo Importing $SHIELDCONEX_FILENAME

mysql -e"
    TRUNCATE auto_billing_staging.stg_shieldconex;
    SET @n = 0;
    SET @source_file = REPLACE(REPLACE('$SHIELDCONEX_FILENAME', '$DIR_SOURCE_DEFAULT', ''), '/', '');
    
    LOAD DATA LOCAL INFILE '$SHIELDCONEX_FILENAME'
    INTO TABLE auto_billing_staging.stg_shieldconex
    FIELDS TERMINATED BY '\t'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES(
       @col01
      ,@col02
      ,@col03
      ,@col04
      ,@col05
      ,@col06
      ,@col07
      ,@col08
      ,@col09
      ,@col10
      ,@col11
      ,@col12
      ,@col13
      ,@col14
      ,@col15
      ,@col16
      ,@col17
      ,@col18)
    SET 
       partner_id              = @col01
      ,partner_name            = @col02
      ,direct_partner_id       = @col03
      ,direct_partner_name     = @col04
      ,partner_path            = @col05
      ,direct_partner_path     = @col06
      ,client_id               = @col07
      ,client_name             = @col08
      ,total_template_validate = @col09
      ,total_good_tokenized    = @col10
      ,total_bad_tokenized     = @col11
      ,total_good_detokenized  = @col12
      ,total_bad_detokenized   = @col13
      ,good_tokenized_fields   = @col14
      ,bad_tokenized_fields    = @col15
      ,good_detokenized_fields = @col16
      ,bad_detokenized_fields  = @col17
      ,complete_date           = @col18
      ,source_file             = @source_file
      ,source_row              = @n := @n + 1
"

echo 
mysql -e"
SELECT 
     t1.table_name 
    ,t2.source_file 
    ,t2.num_rows
    ,t2.min_import_timestamp
    ,t2.max_import_timestamp
  FROM (
            SELECT 'stg_decryptx_cardconex_map'             AS  table_name 
      UNION SELECT 'stg_decryptx_device_cardconex_map'
      UNION SELECT 'stg_payconex_cardconex_map' 
      UNION SELECT 'stg_trustwave'
      UNION SELECT 'stg_shieldconex'  
  ) t1 
  LEFT JOIN (
            SELECT 'stg_decryptx_cardconex_map'        AS table_name, source_file, COUNT(*) AS num_rows, MIN(import_timestamp) AS min_import_timestamp, MAX(import_timestamp) AS max_import_timestamp FROM auto_billing_staging.stg_decryptx_cardconex_map 
      UNION SELECT 'stg_decryptx_device_cardconex_map' AS table_name, source_file, COUNT(*),             MIN(import_timestamp),                         MAX(import_timestamp)                         FROM auto_billing_staging.stg_decryptx_device_cardconex_map   
      UNION SELECT 'stg_payconex_cardconex_map'        AS table_name, source_file, COUNT(*),             MIN(import_timestamp),                         MAX(import_timestamp)                         FROM auto_billing_staging.stg_payconex_cardconex_map                             
      UNION SELECT 'stg_trustwave'                     AS table_name, source_file, COUNT(*),             MIN(import_timestamp),                         MAX(import_timestamp)                         FROM auto_billing_staging.stg_trustwave                             
      UNION SELECT 'stg_shieldconex'                   AS table_name, source_file, COUNT(*),             MIN(import_timestamp),                         MAX(import_timestamp)                         FROM auto_billing_staging.stg_shieldconex                             
  ) t2 
    ON t1.table_name = t2.table_name
 ORDER BY t1.table_name
"

echo 
echo COMMENT:  Number of rows imported may be one less than the number of rows in file.
echo 
wc -l $DCM_FILENAME 
wc -l $DDCM_FILENAME
wc -l $PCM_FILENAME
wc -l $SHIELDCONEX_FILENAME
wc -l $TRUSTWAVE_FILENAME

echo

read -p "press ENTER to continue"

########## Check cardconex_acct_id Lengths in Map Files ###############################################################
mysql -v -v -e "call auto_billing_staging.check_cc_acct_len"
read -p "press ENTER to continue"

# update auto_billing_dw.f_auto_billing_complete_2

mysql -e"CALL auto_billing_dw.f_auto_billing_complete_initialize()"
read -p "press ENTER to continue..."

mysql -e"CALL auto_billing_staging.populate_stg_asset()"
read -p "press ENTER to continue..."

mysql -e"CALL auto_billing_dw.f_auto_billing_complete_assets()"
read -p "press ENTER to continue..."

mysql -e"CALL auto_billing_dw.f_auto_billing_complete_decryptx()"
read -p "press ENTER to continue..."

mysql -e"CALL auto_billing_dw.f_auto_billing_complete_payconex()"
read -p "press ENTER to continue..."

mysql -e"CALL auto_billing_dw.f_auto_billing_complete_payconex_acct_id"
read -p "press ENTER to continue..."

mysql -e"CALL auto_billing_dw.f_auto_billing_complete_shieldconex"
read -p "press ENTER to continue..."

mysql -e"CALL auto_billing_dw.f_auto_billing_complete_pci_charges"
read -p "press ENTER to continue..."

mysql -e"CALL auto_billing_dw.update_bill_to_id_2()"
read -p "press ENTER to continue..."

mysql -e"CALL auto_billing_dw.f_auto_billing_complete_demographics"
read -p "press ENTER to continue..."

mysql -e"CALL auto_billing_history.update_history"
read -p "press ENTER to continue..."

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
