# OBJECTIVE
# Import the following files into the table indicated

# File Name                                  Table Name
# ------------------------------------------------------------------------------------------------- 
# decryptx_cardconex_map_YYYYMM.csv          auto_billing_staging.stg_decryptx__cardconex_map
# decryptx_device_cardconex_map_YYYYMM.csv   auto_billing_staging.stg_decryptx_device_cardconex_map
# payconex_cardconex_map.csv                 auto_billing_staging.stg_payconex_device_cardconex_map

# where YYYYMM represents the year and month of the previous month, relative to the current date.
# Example:  If today = 20200104, then YYYYMM = 202012.

# This script will import only the files which correspond to the previous month, even if older files are present.

# Define the billing period; i.e., YYYYMM for the previous month.
BILLING_PERIOD=$( date -d "$(date +%Y-%m-01) -1 day" +%Y%m )

DIR_SOURCE_DEFAULT="/home/tsanders/dir_source_default"
DIR_REPO="/home/tsanders/repositories/csv_to_mysql"

# Calculate the filenames.
DCM_FILENAME="/home/tsanders/dir_source_default/decryptx_cardconex_map_$BILLING_PERIOD.csv"
DDCM_FILENAME="$DIR_SOURCE_DEFAULT/decryptx_device_cardconex_map_$BILLING_PERIOD.csv"
PCM_FILENAME="$DIR_SOURCE_DEFAULT/payconex_cardconex_map_$BILLING_PERIOD.csv"

# Import the files.
# Note that there are two command-line arguments:
# (i)   The first is the database you are importing into.
# (ii)  The second is the filename.

node $DIR_REPO/mysql_import.js auto_billing_staging $DCM_FILENAME
echo 

node $DIR_REPO/mysql_import.js auto_billing_staging $DDCM_FILENAME
echo 

node $DIR_REPO/mysql_import.js auto_billing_staging $PCM_FILENAME
echo 
