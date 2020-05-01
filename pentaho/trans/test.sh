########## Merchant ###################################################################################################
# Output Table:  auto_billing_dw.d_merchant
# Note:  Verify that we can always call auto_billing_dw.update_billing_frequency()
#cd /home/svc-dbwh/repositories/auto_billing/pentaho/trans/
#mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_dw.d_merchant; set foreign_key_checks=1;"
#/usr/local/install/data-integration/pan.sh -file dw_d_merchant.ktr
# mysql -v -v -e"call auto_billing_dw.update_billing_frequency()"
# read -p "press enter to run dw_f_decryptx_day.ktr..."

# ############################## f_decryptx_day #######################################################################
# Output Tables:  auto_billing_dw.f_decryptx_day_alt and auto_billing_dw.f_decryptx_day
#                 auto_billing_dw_d_device
# cd /home/svc-dbwh/repositories/auto_billing/pentaho/trans/
#mysql -v -e "set foreign_key_checks=0; truncate auto_billing_dw.f_decryptx_day_alt; truncate auto_billing_dw.f_decryptx_day; set foreign_key_checks=1;"
#/usr/local/install/data-integration/pan.sh -file dw_f_decryptx_day.ktr

# ############################## f_processor  #########################################################################
# cd /home/svc-dbwh/repositories/auto_billing/pentaho/trans/
#/usr/local/install/data-integration/pan.sh -file dw_d_processor.ktr
# read -p "press enter to dw_f_payconex_day.ktr..."

# ############################## f_payconex_day #######################################################################
# Output Table:  auto_billing_dw.f_payconex_day_alt and auto_billing_dw.f_payconex_day
#mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_dw.f_payconex_day_alt; truncate auto_billing_dw.f_payconex_day; set foreign_key_checks=1;"
#cd /home/svc-dbwh/repositories/auto_billing/pentaho/trans/
#/usr/local/install/data-integration/pan.sh -file dw_f_payconex_day.ktr
#read -p "press enter to run dw_f_billing_month.ktr..."

# ############################## f_billing_month ######################################################################
# Output Table:  auto_billing_dw.f_billing_month_alt and auto_billing_dw.f_billing_month
#cd /home/svc-dbwh/repositories/auto_billing/pentaho/trans/
#mysql -v -v -e "set foreign_key_checks=0; truncate auto_billing_dw.f_billing_month_alt; truncate auto_billing_dw.f_billing_month; set foreign_key_checks=1;"
#/usr/local/install/data-integration/pan.sh -file dw_f_billing_month.ktr
#read -p "press enter to run rpt_billing.ktr..."

# ############################## Auto Billing Complete ################################################################
# Output Table:  auto_billing_dw.f_auto_billing_complete (currently not truncated but may need to be later)
# Output File:   /home/svc-dbwh/dir_output_default/auto_billing_complete_YYYYMMDD:HHMMSS.txt
#cd /home/svc-dbwh/repositories/auto_billing/pentaho/trans/
/usr/local/install/data-integration/pan.sh -file rpt_billing.ktr
# define output filename
current_timestamp=$( date +"%Y%m%d_%H%M%S" )
output_file="auto_billing_complete_$current_timestamp.txt"
mysql auto_billing_dw < /home/svc-dbwh/repositories/auto_billing/schema/f_auto_billing_complete.sql > /home/svc-dbwh/dir_output_default/$output_file
ls -lt  /home/svc-dbwh/dir_output_default/$output_file | head -2



