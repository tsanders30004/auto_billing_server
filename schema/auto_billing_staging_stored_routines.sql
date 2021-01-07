-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: suw-srvr-14.capitalpayments.local    Database: auto_billing_staging
-- ------------------------------------------------------
-- Server version	5.5.68-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping events for database 'auto_billing_staging'
--

--
-- Dumping routines for database 'auto_billing_staging'
--
/*!50003 DROP PROCEDURE IF EXISTS `check_cc_acct_len` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`tsanders`@`172.16.4.%` PROCEDURE `check_cc_acct_len`()
BEGIN
    SELECT 'cardconex_acct_id must have 18 characters for every row in the map files.' AS message 
  UNION SELECT 'you will need to manually correct the input files if this requirement is not satisfied.'
  UNION SELECT 'checking to see if this condition has been satisfied...';
  
  SELECT * FROM (
      SELECT 'stg_decryptx_cardconex_map' AS table_name, LENGTH(cardconex_acct_id) AS cardconex_acct_id_length, COUNT(*) AS num_rows, IF(LENGTH(cardconex_acct_id) = 18, 'Pass', 'Fail') AS status
      FROM stg_decryptx_cardconex_map
      GROUP BY 1, 2, 4
      UNION SELECT 'stg_decryptx_device_cardconex_map' AS table_name, LENGTH(cardconex_acct_id), COUNT(*), IF(LENGTH(cardconex_acct_id) = 18, 'Pass', 'Fail')
      FROM stg_decryptx_device_cardconex_map
      GROUP BY 1, 2, 4
      UNION SELECT 'stg_payconex_cardconex_map' AS table_name, LENGTH(cardconex_acct_id), COUNT(*), IF(LENGTH(cardconex_acct_id) = 18, 'Pass', 'Fail')
      FROM stg_payconex_cardconex_map
      GROUP BY 1, 2, 4
  )t1 
  ORDER BY 1, 4;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `check_payconex_volume_day_files` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`tsanders`@`172.16.4.%` PROCEDURE `check_payconex_volume_day_files`()
BEGIN
  -- this procedure will determine whether or not the auto_billing_staging.payconex_volume_day table
  -- has data for every day of the previous month - relative to the current date.
  
  DECLARE file_prefix   char(14);
  DECLARE file_suffix   char(4);

  DECLARE start_date    date;
  DECLARE end_date      date;

  DECLARE start_source_file varchar(32);
  DECLARE end_source_file   varchar(32);

  DECLARE num_days_in_last_month TINYINT UNSIGNED;
  DECLARE num_files_imported     TINYINT UNSIGNED;

  SELECT 'auto_billing_staging.payconex_volume_day must have one input file for every day of the previous month.' AS notes
  UNION SELECT 'checking to see if this requirement has been satisfied for last month...';

  SET file_prefix = 'volume_report_';
  SET file_suffix = '.tsv';
 
  SET start_date = date_format(current_date, '%Y-%m-01') - INTERVAL 1 MONTH;   -- this is the first day of the previous month
  SET end_date   = start_date + INTERVAL 1 MONTH - INTERVAL 1 DAY;             -- this is the last  day of the previous month
  
  SET start_source_file = concat(file_prefix, start_date, file_suffix);        -- this is the filename that should correspond to the first day of the previous month
  SET end_source_file =   concat(file_prefix, end_date,   file_suffix);        -- this is the filename that should correspond to the last  day of the previous month
  
  -- the number of files that should have been imported will be equal to the number of days in the previous month.

  -- this is the number of days in the previous month
  SET num_days_in_last_month = datediff(end_date, start_date) + 1;

  -- create a table of imported files
  DROP TABLE IF EXISTS tmp_sp_files; 
  CREATE TEMPORARY TABLE tmp_sp_files 
  SELECT 
     source_file
    ,date_format(REPLACE(LEFT(RIGHT(source_file, 14), 10), '-', ''), '%Y%m%d') AS file_date
    ,count(*) AS num_rows
    ,min(date_updated) AS earliest_update
    ,max(date_updated) AS last_update
  FROM auto_billing_staging.payconex_volume_day
 WHERE source_file BETWEEN start_source_file AND end_source_file 
 GROUP BY 1, 2;

  -- this is the number of files imported in the previous month
  SELECT count(*) FROM (
    SELECT * FROM tmp_sp_files
  ) t1 INTO num_files_imported;

  IF num_days_in_last_month = num_files_imported THEN 
     SELECT 'PASS:  number of input files for auto_billing_staging.payconex_volume_day is correct.' AS status_message;
  ELSE 
     SELECT 'FAIL:  number of input files for auto_billing_staging.payconex_volume_day is incorrect.  There should be one file for every day of the previous month.  One or more files is missing.' AS status_message;
  END IF;

  SELECT * FROM tmp_sp_files;

  SELECT sum(num_rows) AS num_records FROM tmp_sp_files;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `check_prerequisites` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `check_prerequisites`()
BEGIN
  
    SET @fotm = DATE_FORMAT(CURRENT_DATE, '%Y-%m-01');  -- first of this MONTH
    SET @folm = @fotm - INTERVAL 1 MONTH;
    SET @lolm = @fotm - INTERVAL 1 DAY;                -- last of last MONTH
    
    DROP TABLE IF EXISTS tmp_01;
    CREATE TEMPORARY TABLE tmp_01(table_name VARCHAR(32), notes VARCHAR(64));
    INSERT INTO tmp_01 VALUES
     ('stg_device_detail',   concat('min_source_file >= device_detail.', @lolm, '_??????.csv'))
    ,('payconex_volume_day', 'one file for every day of previous month')
    ,('stg_payconex_volume', 'one file for last  day of previous month')
    ,('decryptx_device_day', 'one file for every day of previous month')
    -- ,('stg_shieldconex',     'one file for last month')
    ;
    
    SELECT 'checking prerequisites...' AS message;
    
    DROP TABLE IF EXISTS tmp_02;
  
    CREATE TEMPORARY TABLE tmp_02 
    SELECT 
        'stg_device_detail' AS table_name
        ,source_file
        ,count(*) AS num_rows
        ,min(date_updated) AS min_date_updated 
        ,max(date_updated) AS max_date_updated
      FROM stg_device_detail
     GROUP BY 1, 2
     UNION 
    SELECT 
        'payconex_volume_day' AS table_name
        ,source_file
        ,count(*) AS num_rows
        ,min(date_updated) AS min_date_updated 
        ,max(date_updated) AS max_date_updated
      FROM payconex_volume_day
     WHERE report_date >= @folm
     GROUP BY 1, 2
     UNION 
    SELECT 
        'stg_payconex_volume' AS table_name
        ,source_file
        ,count(*) AS num_rows
        ,min(date_updated) AS min_date_updated 
        ,max(date_updated) AS max_date_updated
      FROM stg_payconex_volume
     GROUP BY 1, 2
     UNION 
    SELECT 
        'decryptx_device_day' AS table_name
        ,source_file
        ,count(*) AS num_rows
        ,min(date_updated) AS min_date_updated 
        ,max(date_updated) AS max_date_updated
      FROM decryptx_device_day
     WHERE report_date >= @folm
     GROUP BY 1, 2
     UNION     
    SELECT 
        'stg_shieldconex' AS table_name
        ,file_name AS source_file
        ,count(*) AS num_rows
        ,min(import_timestamp) AS min_date_updated 
        ,max(import_timestamp) AS max_date_updated
      FROM auto_billing_staging.stg_shieldconex 
     GROUP BY 1, 2
    ;
    
    SELECT
         t1.table_name
        ,min(t2.source_file)               AS min_source_file
        ,max(t2.source_file)               AS max_source_file
        ,min(t2.min_date_updated)          AS min_date_updated
        ,max(t2.max_date_updated)          AS max_date_updated
        ,count(*)                          AS num_files
        ,t1.notes
      FROM tmp_01       t1 
      LEFT JOIN tmp_02  t2
        ON t1.table_name = t2.table_name
     GROUP BY 1 
     ORDER BY 5, 1
    ;
  
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `check_stg_payconex_volume_files` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`tsanders`@`172.16.4.%` PROCEDURE `check_stg_payconex_volume_files`()
BEGIN
  
  -- this procedure will determine whether or not the auto_billing_staging.stg_payconex_volume table
  -- only has data for the last day of the previous month - relative to the current date.
  
  DECLARE file_prefix          char(14);
  DECLARE file_suffix          char(8);
  DECLARE start_date           date;
  DECLARE end_date             date;
  DECLARE end_source_file      varchar(32);

  DECLARE num_files_imported   int UNSIGNED;
  DECLARE imported_filename    varchar(32);

  DECLARE msg                  varchar(256);
  DECLARE db_name              varchar(128);

  SELECT 'auto_billing_staging.stg_payconex_volume must have only one input file' AS notes 
  UNION SELECT 'and it must correspond to the file for the last day of the previous month.'
  UNION SELECT 'checking to see if this requirement has been satisfied...';

  SET file_prefix        = 'volume_report_';
  SET file_suffix        = '_mtd.tsv';
  SET start_date         = date_format(current_date, '%Y-%m-01') - INTERVAL 1 MONTH;   -- this is the first day of the previous month
  SET end_date           = start_date + INTERVAL 1 MONTH - INTERVAL 1 DAY;             -- this is the last day of the previous month
  SET end_source_file    =   concat(file_prefix, end_date, file_suffix);               -- this is the filename that should correspond to the last  day of the previous month
  SET num_files_imported = 0;
  SET msg                = '';
  SET db_name            = 'auto_billing_staging.stg_payconex_volume';

  -- create a table of imported files
  DROP TABLE IF EXISTS tmp_sp_files; 
  CREATE TEMPORARY TABLE tmp_sp_files 
    SELECT
       db_name AS table_name
      ,source_file
      ,date_format(REPLACE(substring(source_file, 15, 10), '-', ''), '%Y%m%d') AS file_date
      ,count(*) AS num_rows
      ,min(date_updated) AS earliest_update
      ,max(date_updated) AS last_update
    FROM auto_billing_staging.stg_payconex_volume
   GROUP BY 1, 2;

  SELECT count(*) FROM tmp_sp_files INTO num_files_imported;

  IF num_files_imported = 0 THEN 
     SET msg = concat('FAIL:  0 files were imported into ', db_name, '.');
  ELSEIF num_files_imported >= 2 THEN 
     SET msg = concat('FAIL:  > 1 file was imported into ', db_name, '.');
     SELECT * FROM tmp_sp_files;
  ELSE 
     SELECT source_file FROM tmp_sp_files INTO imported_filename;
     IF imported_filename != end_source_file THEN 
          SET msg = concat('FAIL:  filename that was imported into ', db_name, ' did not correspond to the last day of the previous month.');
          SELECT * FROM tmp_sp_files;
     ELSE 
          SET msg = 'PASS:  file was imported successfully.';
          SELECT * FROM tmp_sp_files;
     END IF;
  END IF;

  SELECT msg AS message;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populate_stg_asset` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `populate_stg_asset`()
    COMMENT 'USAGE: populate_stg_asset() /* Populates auto_billing_staging.stg_asset - a de-normalized version of sales_force.asset. */'
BEGIN
     
    SELECT 'Executing Stored Procedure' AS operation, 'auto_billing_staging.populate_stg_asset' AS stored_procedure, CURRENT_TIMESTAMP;
  
    DROP TABLE IF EXISTS auto_billing_staging.tmp_dupe_fees;

    CREATE TEMPORARY TABLE auto_billing_staging.tmp_dupe_fees
    SELECT 
         acct.id 
        ,acct.name 
        ,asst.fee_name__c 
        ,MIN(fee_amount__c)               AS min_fee_amount
        ,MAX(fee_amount__c)               AS max_fee_amount
        ,COUNT(DISTINCT fee_amount__c)    AS num_distinct_fees
        ,COUNT(*)                         AS num_duplicates
      FROM sales_force.account      acct 
      JOIN sales_force.asset        asst
        ON acct.id = asst.accountid 
     WHERE asst.fee_name__c IS NOT NULL
     GROUP BY 1, 2, 3
    HAVING COUNT(*) >= 2
     ORDER BY 2
    ;
    
    SELECT 'The following fees are duplicated in sales_force.asset and will causing billing errors unless the duplicates are deleted.' AS message;
      
    SELECT * FROM auto_billing_staging.tmp_dupe_fees;
    
    SELECT 
         fee_name__c
        ,COUNT(*) AS num_rows
      FROM auto_billing_staging.tmp_dupe_fees
     GROUP BY 1
     ORDER BY 1
    ;    
     
    TRUNCATE auto_billing_staging.stg_asset;
    
    INSERT INTO auto_billing_staging.stg_asset
    SELECT 
         account_id 
        ,SUM(ach_credit_fee)                AS ach_credit_fee
        ,SUM(bfach_discount_rate)           AS bfach_discount_rate
        ,SUM(ach_per_gw_trans_fee)          AS ach_per_gw_trans_fee
        ,SUM(ach_monthly_fee)               AS ach_monthly_fee
        ,SUM(ach_noc_fee)                   AS ach_noc_fee
        ,SUM(ach_return_error_fee)          AS ach_return_error_fee
        ,SUM(ach_transaction_fee)           AS ach_transaction_fee
        ,SUM(bluefin_gateway_discount_rate) AS bluefin_gateway_discount_rate
        ,SUM(file_transfer_monthly_fee)     AS file_transfer_monthly_fee
        ,SUM(group_tag_fee)                 AS group_tag_fee
        ,SUM(gw_per_auth_decline_fee)       AS gw_per_auth_decline_fee
        ,SUM(per_transaction_fee)           AS per_transaction_fee
        ,SUM(gw_per_credit_fee)             AS gw_per_credit_fee
        ,SUM(gateway_monthly_fee)           AS gateway_monthly_fee
        ,SUM(gw_per_refund_fee)             AS gw_per_refund_fee
        ,SUM(gw_reissued_fee)               AS gw_reissued_fee
        ,SUM(gw_per_token_fee)              AS gw_per_token_fee
        ,SUM(gw_per_sale_fee)               AS gw_per_sale_fee
        ,SUM(misc_monthly_fees)             AS misc_monthly_fees
        ,SUM(p2pe_device_activated)         AS p2pe_device_activated
        ,SUM(p2pe_device_activating_fee)    AS p2pe_device_activating_fee
        ,SUM(p2pe_device_stored_fee)        AS p2pe_device_stored_fee
        ,SUM(p2pe_encryption_fee)           AS p2pe_encryption_fee
        ,SUM(p2pe_monthly_flat_fee)         AS p2pe_monthly_flat_fee
        ,SUM(p2pe_tokenization_fee)         AS p2pe_tokenization_fee
        ,SUM(one_time_key_injection_fees)   AS one_time_key_injection_fees
        ,SUM(payconex_app_exchange_fee)     AS payconex_app_exchange_fee
        ,SUM(pci_compliance_fee)            AS pci_compliance_fee
        ,SUM(pci_non_compliance_fee)        AS pci_non_compliance_fee
        ,SUM(pci_scans_monthly_fee)         AS pci_scans_monthly_fee
        ,SUM(shieldconex_fields_fee)        AS shieldconex_fields_fee
        ,SUM(shieldconex_monthly_fee)       AS shieldconex_monthly_fee
        ,SUM(shieldconex_monthly_minimum)   AS shieldconex_monthly_minimum
        ,SUM(shieldconex_transaction_fee)   AS shieldconex_transaction_fee
        ,MAX(date_updated)                  AS date_updated
      FROM (
          SELECT
                accountid                                                                                   AS account_id
              ,(COALESCE(fee_name__c, '') = 'ACH Credit Fee')               * COALESCE(fee_amount__c, 0.00) AS ach_credit_fee
              ,(COALESCE(fee_name__c, '') = 'ACH Discount Rate')            * COALESCE(fee_amount__c, 0.00) AS bfach_discount_rate
              ,(COALESCE(fee_name__c, '') = 'ACH GW Trans Fee')             * COALESCE(fee_amount__c, 0.00) AS ach_per_gw_trans_fee
              ,(COALESCE(fee_name__c, '') = 'ACH Monthly Fee')              * COALESCE(fee_amount__c, 0.00) AS ach_monthly_fee
              ,(COALESCE(fee_name__c, '') = 'ACH NOC Fee')                  * COALESCE(fee_amount__c, 0.00) AS ach_noc_fee
              ,(COALESCE(fee_name__c, '') = 'ACH Return/Error Fee')         * COALESCE(fee_amount__c, 0.00) AS ach_return_error_fee
              ,(COALESCE(fee_name__c, '') = 'ACH Transaction Fee')          * COALESCE(fee_amount__c, 0.00) AS ach_transaction_fee
              ,(COALESCE(fee_name__c, '') = 'Apriva Monthly Fee')           * COALESCE(fee_amount__c, 0.00) AS bluefin_gateway_discount_rate
              ,(COALESCE(fee_name__c, '') = 'File Transfer Monthly Fee')    * COALESCE(fee_amount__c, 0.00) AS file_transfer_monthly_fee
              ,(COALESCE(fee_name__c, '') = 'Group/Tag Fee')                * COALESCE(fee_amount__c, 0.00) AS group_tag_fee
              ,(COALESCE(fee_name__c, '') = 'GW Auth Decline Fee')          * COALESCE(fee_amount__c, 0.00) AS gw_per_auth_decline_fee
              ,(COALESCE(fee_name__c, '') = 'GW Auth Fee')                  * COALESCE(fee_amount__c, 0.00) AS per_transaction_fee
              ,(COALESCE(fee_name__c, '') = 'GW Credit Fee')                * COALESCE(fee_amount__c, 0.00) AS gw_per_credit_fee
              ,(COALESCE(fee_name__c, '') = 'GW Monthly Fee')               * COALESCE(fee_amount__c, 0.00) AS gateway_monthly_fee
              ,(COALESCE(fee_name__c, '') = 'GW Refund Fee')                * COALESCE(fee_amount__c, 0.00) AS gw_per_refund_fee
              ,(COALESCE(fee_name__c, '') = 'GW Reissued Fee')              * COALESCE(fee_amount__c, 0.00) AS gw_reissued_fee
              ,(COALESCE(fee_name__c, '') = 'GW Token Fee')                 * COALESCE(fee_amount__c, 0.00) AS gw_per_token_fee
              ,(COALESCE(fee_name__c, '') = 'GW Tran Fee')                  * COALESCE(fee_amount__c, 0.00) AS gw_per_sale_fee
              ,(COALESCE(fee_name__c, '') = 'Misc Monthly Fee(s)')          * COALESCE(fee_amount__c, 0.00) AS misc_monthly_fees
              ,(COALESCE(fee_name__c, '') = 'P2PE Device Activated Fee')    * COALESCE(fee_amount__c, 0.00) AS p2pe_device_activated
              ,(COALESCE(fee_name__c, '') = 'P2PE Device Activating Fee')   * COALESCE(fee_amount__c, 0.00) AS p2pe_device_activating_fee
              ,(COALESCE(fee_name__c, '') = 'P2PE Device Stored Fee')       * COALESCE(fee_amount__c, 0.00) AS p2pe_device_stored_fee
              ,(COALESCE(fee_name__c, '') = 'P2PE Encryption Fee')          * COALESCE(fee_amount__c, 0.00) AS p2pe_encryption_fee
              ,(COALESCE(fee_name__c, '') = 'P2PE Monthly Flat Fee')        * COALESCE(fee_amount__c, 0.00) AS p2pe_monthly_flat_fee
              ,(COALESCE(fee_name__c, '') = 'P2PE Token Fee')               * COALESCE(fee_amount__c, 0.00) AS p2pe_tokenization_fee
              ,(COALESCE(fee_name__c, '') = 'P2PE Token Flat Monthly Fee')  * COALESCE(fee_amount__c, 0.00) AS one_time_key_injection_fees
              ,(COALESCE(fee_name__c, '') = 'PayConex AppExchange Fee')     * COALESCE(fee_amount__c, 0.00) AS payconex_app_exchange_fee
              ,(COALESCE(fee_name__c, '') = 'PCI Management Fee')           * COALESCE(fee_amount__c, 0.00) AS pci_compliance_fee
              ,(COALESCE(fee_name__c, '') = 'PCI Non-Compliance Fee')       * COALESCE(fee_amount__c, 0.00) AS pci_non_compliance_fee
              ,(COALESCE(fee_name__c, '') = 'PCI Transaction Fee')          * COALESCE(fee_amount__c, 0.00) AS pci_scans_monthly_fee
              ,(COALESCE(fee_name__c, '') = 'ShieldConex Fields Fee')       * COALESCE(fee_amount__c, 0.00) AS shieldconex_fields_fee
              ,(COALESCE(fee_name__c, '') = 'ShieldConex Monthly Fee')      * COALESCE(fee_amount__c, 0.00) AS shieldconex_monthly_fee
              ,(COALESCE(fee_name__c, '') = 'ShieldConex Monthly Minimum')  * COALESCE(fee_amount__c, 0.00) AS shieldconex_monthly_minimum
              ,(COALESCE(fee_name__c, '') = 'ShieldConex Transaction Fee')  * COALESCE(fee_amount__c, 0.00) AS shieldconex_transaction_fee
              ,CURRENT_TIMESTAMP                                                                            AS date_updated
            FROM sales_force.asset 
      ) t1 
     GROUP BY 1
    ;
    

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `show_input_file_summary` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`tsanders`@`172.16.4.%` PROCEDURE `show_input_file_summary`()
BEGIN

  SELECT 'calculating input file summary...' AS message;

  DROP TABLE IF EXISTS tmp_sp_tables;
  
  CREATE TEMPORARY TABLE tmp_sp_tables SELECT 'stg_cardconex_account' AS table_name
  UNION SELECT 'stg_cardconex_service'
  UNION SELECT 'site'
  UNION SELECT 'stg_device_detail'
  UNION SELECT 'payconex_volume_day'
  UNION SELECT 'stg_payconex_volume'
  UNION SELECT 'decryptx_device_day'
  UNION SELECT 'stg_decryptx_cardconex_map'
  UNION SELECT 'stg_decryptx_device_cardconex_map'
  UNION SELECT 'stg_payconex_cardconex_map' ;
  
  DROP TABLE IF EXISTS tmp_sp_input_files;
  
  CREATE TEMPORARY TABLE tmp_sp_input_files AS SELECT t1.table_name, t2.source_file, t2.notes, t2.num_records, t2.min_date_updated, t2.max_date_updated
  FROM (SELECT 'stg_cardconex_account' AS table_name
  UNION SELECT 'stg_cardconex_service'
  UNION SELECT 'site'
  UNION SELECT 'stg_device_detail'
  UNION SELECT 'payconex_volume_day'
  UNION SELECT 'stg_payconex_volume'
  UNION SELECT 'decryptx_device_day'
  UNION SELECT 'stg_decryptx_cardconex_map'
  UNION SELECT 'stg_decryptx_device_cardconex_map'
  UNION SELECT 'stg_payconex_cardconex_map' ) t1
  LEFT JOIN ( SELECT 'stg_cardconex_account' AS table_name, NULL AS source_file, NULL AS notes, COUNT(*) AS num_records, MIN(date_updated) AS min_date_updated, MAX(date_updated) AS max_date_updated
  FROM auto_billing_staging.stg_cardconex_account
  GROUP BY 1, 2, 3
  UNION SELECT 'stg_cardconex_service' AS table_name, source_file, NULL AS notes, COUNT(*) AS num_records, MIN(date_updated) AS min_date_updated, MAX(date_updated) AS max_date_updated
  FROM auto_billing_staging.stg_cardconex_service
  GROUP BY 1, 2, 3
  UNION SELECT 'stg_device_detail' AS table_name, source_file, NULL AS notes, COUNT(*) AS num_records, MIN(date_updated) AS min_date_updated, MAX(date_updated) AS max_date_updated
  FROM auto_billing_staging.stg_device_detail
  GROUP BY 1, 2, 3
  UNION SELECT 'payconex_volume_day' AS table_name, source_file, '1 file/day for prev month' AS notes, COUNT(*) AS num_records, MIN(date_updated) AS min_date_updated, MAX(date_updated) AS max_date_updated
  FROM auto_billing_staging.payconex_volume_day
  WHERE report_date BETWEEN DATE_FORMAT(CURRENT_DATE, '%Y%m01') - INTERVAL 1 MONTH AND DATE_FORMAT(CURRENT_DATE, '%Y%m01') - INTERVAL 1 DAY
  GROUP BY 1, 2, 3
  UNION SELECT 'stg_payconex_volume' AS table_name, source_file, '1 file for last day prev month' AS notes, COUNT(*) AS num_records, MIN(date_updated) AS min_date_updated, MAX(date_updated) AS max_date_updated
  FROM auto_billing_staging.stg_payconex_volume
  GROUP BY 1, 2, 3
  UNION SELECT 'decryptx_device_day' AS table_name, source_file, '1 file/day for prev month' AS notes, COUNT(*) AS num_records, MIN(date_updated) AS min_date_updated, MAX(date_updated) AS max_date_updated
  FROM auto_billing_staging.decryptx_device_day
  WHERE report_date BETWEEN DATE_FORMAT(CURRENT_DATE, '%Y%m01') - INTERVAL 1 MONTH AND DATE_FORMAT(CURRENT_DATE, '%Y%m01') - INTERVAL 1 DAY
  GROUP BY 1, 2, 3
  UNION SELECT 'stg_decryptx_cardconex_map' AS table_name, source_file, 'len(cc_acct_id) = 1 for all rows' AS notes, COUNT(*) AS num_records, MIN(date_updated) AS min_date_updated, MAX(date_updated) AS max_date_updated
  FROM auto_billing_staging.stg_decryptx_cardconex_map
  GROUP BY 1, 2, 3
  UNION SELECT 'stg_decryptx_device_cardconex_map' AS table_name, source_file, 'len(cc_acct_id) = 1 for all rows' AS notes, COUNT(*) AS num_records, MIN(date_updated) AS min_date_updated, MAX(date_updated) AS max_date_updated
  FROM auto_billing_staging.stg_decryptx_device_cardconex_map
  GROUP BY 1, 2, 3
  UNION SELECT 'stg_payconex_cardconex_map' AS table_name, source_file, 'len(cc_acct_id) = 1 for all rows' AS notes, COUNT(*) AS num_records, MIN(date_updated) AS min_date_updated, MAX(date_updated) AS max_date_updated
  FROM auto_billing_staging.stg_payconex_cardconex_map
  GROUP BY 1, 2, 3 ) t2 ON
  t1.table_name = t2.table_name
  ORDER BY t1.table_name LIKE '%map%', 1, 2 ;
  
  SELECT t1.table_name, t2.source_file, notes, num_records, min_date_updated, max_date_updated
  FROM tmp_sp_tables t1
  LEFT JOIN tmp_sp_input_files t2 ON
  t1.table_name = t2.table_name
  ORDER BY 1, 2 ;  
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_alpha_cc_acct_id_to_beta_cc_acct_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `update_alpha_cc_acct_id_to_beta_cc_acct_id`()
BEGIN

    SELECT 'updating alpha cardconex_acct_ids to beta cardconex_acct_ids...' AS status;
    
    SELECT 'updating auto_billing_staging.stg_cardconex_service...' AS status;
    UPDATE auto_billing_staging.stg_cardconex_service s 
      JOIN sales_force.account                        a  
        ON s.accountid = a.legacy_id__c 
       SET s.accountid = a.id 
    ;  
    SELECT row_count();
  
    SELECT 'updating auto_billing_staging.stg_decryptx_cardconex_map...' AS status;
    UPDATE auto_billing_staging.stg_decryptx_cardconex_map AS dcm 
      JOIN sales_force.account                             AS a  
        ON dcm.cardconex_acct_id = a.legacy_id__c 
       SET dcm.cardconex_acct_id  = a.id
    ;
    SELECT row_count();
    
    SELECT 'updating auto_billing_staging.stg_decryptx_device_cardconex_map' AS status;
    UPDATE auto_billing_staging.stg_decryptx_device_cardconex_map AS ddcm 
      JOIN sales_force.account                                    AS a  
        ON ddcm.cardconex_acct_id = a.legacy_id__c
       SET ddcm.cardconex_acct_id  = a.id
    ;
    SELECT row_count();
    
    SELECT 'updating auto_billing_staging.stg_payconex_cardconex_map' AS status;
    UPDATE auto_billing_staging.stg_payconex_cardconex_map AS pcm
      JOIN sales_force.account                             AS a  
        ON pcm.cardconex_acct_id = a.legacy_id__c 
       SET pcm.cardconex_acct_id  = a.id
    ;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_decryptx_device_day_eom` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `update_decryptx_device_day_eom`()
    COMMENT 'USAGE:  update_decryptx_device_day_eom() /* Update auto_billing_staging.decryptx_device_day_eom */'
BEGIN
  
    /*
         Issue
         -----
         Finance wants to query auto_billing.decryptx_device_day in Tableau.
         
         The following pseudo-code defines they Finance wants:
         
         SELECT * 
           FROM auto_billing_decryptx_device_day 
          WHERE report_date = last day of the month for previous months 
             OR report_date = MAX(report_date) for current month
            
         auto_billing_staging.decryptx_device_day is a very large table and the query to isolate the rows they want is very slow.
         They run this query frequently; therefore, there is a high load on the database whenever they need to access that table.
         
         To fix this, a separate table will be maintained for their use instead which will include only the rows they want.
         
         It will need to be updated daily.
         
    */
    
    
    SET @cutoff_date = CURRENT_DATE - INTERVAL 45 DAY;
    
    SET @yesterday   = CURRENT_DATE - INTERVAL  1 DAY;
    
    -- delete rows WHERE report_date >= last day of last month 
    DELETE FROM decryptx_device_day_eom WHERE report_date >= @cutoff_date; 
    
    -- insert rows WHERE report_date = last day or last month or most recent date in this month.
    INSERT INTO decryptx_device_day_eom 
    SELECT dcx.*
      FROM decryptx_device_day      dcx
      JOIN auto_billing_dw.d_day  
        ON dcx.report_date = d_day.day_key
      WHERE (dcx.report_date >= CURRENT_DATE - INTERVAL 45 DAY AND d_day.end_of_month = dcx.report_date)
         OR  report_date = @yesterday
    ;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-01-07 14:28:37
