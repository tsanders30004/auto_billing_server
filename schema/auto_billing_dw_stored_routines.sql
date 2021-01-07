-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: suw-srvr-14.capitalpayments.local    Database: auto_billing_dw
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
-- Dumping events for database 'auto_billing_dw'
--

--
-- Dumping routines for database 'auto_billing_dw'
--
/*!50003 DROP FUNCTION IF EXISTS `calc_payment_due_date` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` FUNCTION `calc_payment_due_date`(start_date DATE, terms VARCHAR(16)) RETURNS date
    COMMENT 'USAGE:  calc_payment_due_date(start_date, payment_terms) /* Calculate payment due date based on a starting date and the payment terms. */'
BEGIN
 
    -- Objective:  Calculate payment_due_date = LAST OF LAST MONTH + f(payment_terms); see below.
    -- Note that `... + INTERVAL x DAYS` only works for CONSTANT values of x; it does not work for calculated values of x.
    
    /*
        SELECT DISTINCT account_payment_terms__c FROM sales_force.account ORDER BY 1;
        +--------------------------+
        | account_payment_terms__c |
        +--------------------------+
        | NULL                     |
        | Due upon receipt         |
        | Net 10                   |
        | Net 15                   |
        | Net 20                   |
        | Net 30                   |
        | Net 40                   |
        | Net 45                   |
        | Net 60                   |
        | Net 75                   |
        | Net 90                   |
        +--------------------------+
    */

    DECLARE lolm        DATE;
    DECLARE tmp_return  DATE;

    SET lolm = CONVERT(1.0 * DATE_FORMAT(start_date, '%Y%m01'), DATE) - INTERVAL 1 DAY;
    
    IF     terms IS NULL                THEN SET tmp_return = lolm;
    ELSEIF terms = 'Due upon receipt'   THEN SET tmp_return = lolm;
    ELSEIF terms = 'Net 10'             THEN SET tmp_return = lolm + INTERVAL 10 DAY;
    ELSEIF terms = 'Net 15'             THEN SET tmp_return = lolm + INTERVAL 15 DAY;
    ELSEIF terms = 'Net 20'             THEN SET tmp_return = lolm + INTERVAL 20 DAY;
    ELSEIF terms = 'Net 30'             THEN SET tmp_return = lolm + INTERVAL 30 DAY;
    ELSEIF terms = 'Net 40'             THEN SET tmp_return = lolm + INTERVAL 40 DAY;
    ELSEIF terms = 'Net 45'             THEN SET tmp_return = lolm + INTERVAL 45 DAY;
    ELSEIF terms = 'Net 60'             THEN SET tmp_return = lolm + INTERVAL 60 DAY;
    ELSEIF terms = 'Net 75'             THEN SET tmp_return = lolm + INTERVAL 75 DAY;
    ELSEIF terms = 'Net 90'             THEN SET tmp_return = lolm + INTERVAL 90 DAY;
    ELSE                                     SET tmp_return = lolm;
    END IF;
  
    RETURN tmp_return;
  
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `calc_shieldconex_fields_charge` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` FUNCTION `calc_shieldconex_fields_charge`(
     f_good_tokenized_fields        INT UNSIGNED
    ,f_bad_tokenized_fields         INT UNSIGNED
    ,f_good_detokenized_fields      INT UNSIGNED
    ,f_bad_detokenized_fields       INT UNSIGNED
    ,f_shieldconex_monthly_minimum  INT UNSIGNED
    ,f_shieldconex_fields_fee       DECIMAL(20, 5)   
) RETURNS decimal(20,5)
    COMMENT 'USAGE: calc_shieldconex_fields_charge(good_tokenized_fields, bad_tokenized_fields, ood_detokenized_fields, bad_detokenized_fields, shieldconex_monthly_minimum, shieldconex_fields_fee) /* calculates calc_shieldconex_field_charge */'
BEGIN

  SET @tmp_var = (
        f_good_tokenized_fields
      + f_bad_tokenized_fields
      + f_good_detokenized_fields
      + f_bad_detokenized_fields
      ) * f_shieldconex_fields_fee
  ;

  RETURN TRUNCATE(IF(@tmp_var < f_shieldconex_monthly_minimum, 0, @tmp_var), 5);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `calc_shieldconex_monthly_charge` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` FUNCTION `calc_shieldconex_monthly_charge`(f_shieldconex_monthly_fee DECIMAL(12, 5)) RETURNS decimal(12,5)
    COMMENT 'USAGE: calc_shieldconex_monthly_charge(shieldconex_monthly_fee) /* calculates calc_shieldconex_monthly_charge */'
BEGIN
  
  -- this funciton is trivial; it is being added so that if the defintion changes later, it will only be necessary for change the function;
  -- i.e., to faciliate maintenance.
  
  RETURN f_shieldconex_monthly_fee;
  
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `calc_shieldconex_monthly_minimum_charge` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` FUNCTION `calc_shieldconex_monthly_minimum_charge`(
     f_shieldconex_transaction_charge DECIMAL(16, 4)
    ,f_shieldconex_monthly_minimum    DECIMAL(16, 4)
) RETURNS decimal(20,5)
    COMMENT 'USAGE: calc_shieldconex_monthly_minimum_charge(shieldconex_transaction_charge, shieldconex_monthly_minumum) /* calulates shieldconex_monthly_minimum_charge */'
BEGIN

    DECLARE x DECIMAL(16, 4);
  
    IF f_shieldconex_transaction_charge <= f_shieldconex_monthly_minimum THEN 
       SET x = f_shieldconex_monthly_minimum;
    ELSE 
       SET x = 0;
    END IF; 
  
    RETURN x;
  
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `calc_shieldconex_transaction_charge` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` FUNCTION `calc_shieldconex_transaction_charge`(
     f_total_good_tokenized        INT UNSIGNED
    ,f_total_bad_tokenized         INT UNSIGNED
    ,f_total_good_detokenized      INT UNSIGNED
    ,f_total_bad_detokenized       INT UNSIGNED
    ,f_shieldconex_monthly_minimum INT UNSIGNED
    ,f_shieldconex_transaction_fee DECIMAL(20, 5)   
) RETURNS decimal(20,5)
    COMMENT 'USAGE: calc_shieldconex_transaction_charge(total_good_tokenized, total_bad_tokenized, total_good_detokenized, total_bad_detokenized, shieldconex_monthly_minimum, shieldconex_transaction_fee) /* calculates calc_shieldconex_transaction_charge */'
BEGIN

  SET @tmp_var = (
        f_total_good_tokenized
      + f_total_bad_tokenized
      + f_total_good_detokenized
      + f_total_bad_detokenized
      ) * f_shieldconex_transaction_fee
  ;

  RETURN TRUNCATE(IF(@tmp_var < f_shieldconex_monthly_minimum, 0, @tmp_var), 5);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `null_number_to_empty_string` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` FUNCTION `null_number_to_empty_string`(n DECIMAL(16, 4)) RETURNS varchar(64) CHARSET latin1
BEGIN
  
  RETURN COALESCE(CONVERT(n USING latin1), '');

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `f_auto_billing_complete_assets` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `f_auto_billing_complete_assets`()
    COMMENT 'USAGE:  f_auto_billing_complete_assets /* update asset columns in f_auto_billing_complete_2 */'
BEGIN
   
    SELECT 'Executing Stored Procedure' AS operation, 'f_auto_billing_complete_assets' AS stored_procedure, CURRENT_TIMESTAMP;
  
     UPDATE auto_billing_dw.f_auto_billing_complete_2      abc 
      JOIN auto_billing_staging.stg_asset                 asst 
        ON abc.account_id = asst.account_id 
       SET abc.pricing_ach_credit_fee                 = asst.ach_credit_fee
          ,abc.pricing_ach_monthly_fee                = asst.ach_monthly_fee
          ,abc.pricing_ach_noc_fee                    = asst.ach_noc_fee
          ,abc.pricing_ach_per_gw_trans_fee           = asst.ach_per_gw_trans_fee
          ,abc.pricing_ach_return_error_fee           = asst.ach_return_error_fee
          ,abc.pricing_ach_transaction_fee            = asst.ach_transaction_fee
          ,abc.pricing_bluefin_gateway_discount_rate  = asst.bluefin_gateway_discount_rate
          ,abc.pricing_file_transfer_monthly_fee      = asst.file_transfer_monthly_fee
          ,abc.pricing_gateway_monthly_fee            = asst.gateway_monthly_fee
          ,abc.pricing_group_tag_fee                  = asst.group_tag_fee
          ,abc.pricing_gw_per_auth_decline_fee        = asst.gw_per_auth_decline_fee
          ,abc.pricing_gw_per_credit_fee              = asst.gw_per_credit_fee
          ,abc.pricing_gw_per_refund_fee              = asst.gw_per_refund_fee
          ,abc.pricing_gw_per_sale_fee                = asst.gw_per_sale_fee
          ,abc.pricing_gw_per_token_fee               = asst.gw_per_token_fee
          ,abc.pricing_gw_reissued_fee                = asst.gw_reissued_fee
          ,abc.pricing_misc_monthly_fee               = asst.misc_monthly_fees
          ,abc.pricing_one_time_key_injection_fee     = asst.one_time_key_injection_fees
          ,abc.pricing_p2pe_device_activated_fee      = asst.p2pe_device_activated
          ,abc.pricing_p2pe_device_activating_fee     = asst.p2pe_device_activating_fee
          ,abc.pricing_p2pe_device_stored_fee         = asst.p2pe_device_stored_fee
          ,abc.pricing_p2pe_encryption_fee            = asst.p2pe_encryption_fee
          ,abc.pricing_p2pe_monthly_flat_fee          = asst.p2pe_monthly_flat_fee
          ,abc.pricing_p2pe_tokenization_fee          = asst.p2pe_tokenization_fee
          ,abc.pricing_pc_acct_updater_fee            = 0      -- confirm this is zero.
          ,abc.pci_compliance_fee                     = asst.pci_compliance_fee 
          ,abc.pci_non_compliance_fee                 = asst.pci_non_compliance_fee 
          ,abc.pricing_pci_scans_monthly_fee          = asst.pci_scans_monthly_fee
          ,abc.pricing_per_transaction_fee            = asst.per_transaction_fee
     WHERE TRUE 
    ;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2      abc 
      JOIN auto_billing_staging.stg_asset                 asst 
        ON abc.account_id = asst.account_id
       SET abc.pricing_ach_discount_rate = asst.bfach_discount_rate / 100.0
     WHERE TRUE 
    ;
  
 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `f_auto_billing_complete_bill_to_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `f_auto_billing_complete_bill_to_id`()
    COMMENT 'USAGE:  f_auto_billing_complete_bill_to_id */ Calculates and populates bill_to_id. */'
BEGIN

    /*
    
        Purpose:  Calculate the bill_to_id.
        
        Note the following:
    
        MariaDB [sales_force]> SELECT billing_preference__c, COUNT(*) FROM sales_force.account GROUP BY 1;
        +-----------------------+----------+
        | billing_preference__c | COUNT(*) |
        +-----------------------+----------+
        | NULL                  |    21702 |
        | Aggregated Billing    |     4235 |
        | Client Level Only     |       42 |
        | Direct Billing        |     9687 |
        | Processor Only        |    30928 |
        +-----------------------+----------+
        5 rows in set (3.38 sec)
    
        Rows in sales_force.account for which billing_preference__c != 'Aggregated' are billed directly.
        
        Rows in sales_force.account for which billing_preference__c = 'Aggregated' are billed to a parent account, based on the value of account.parentid.
        It may be be necessary to traverse multiple 'levels' to find the parent.
        
        See the simulated data below; the calculated value of bill_to_id is shown.
        
        cardconex_acct_id|parent_id|billing_preference|bill_to_id|
        -----------------|---------|------------------|----------|
        a                |*        |Client Level Only |a         |   -- case 1
        
        b                |c        |Aggregated Billing|c         |   -- case 2
        c                |*        |Direct Billing    |c         |
        
        e                |f        |Aggregated Billing|g         |   -- case 3
        f                |g        |Aggregated Billing|g         |
        g                |*        |Processor Only    |g         |
        
        i                |j        |Aggregated Billing|l         |   -- case 4
        j                |k        |Aggregated Billing|l         |
        k                |l        |Aggregated Billing|l         |
        l                |*        |Processor Only    |l         |
        
        n                |o        |Aggregated Billing|r         |   -- case 5
        o                |p        |Aggregated Billing|r         |
        p                |q        |Aggregated Billing|r         |
        q                |r        |Aggregated Billing|r         |
        r                |*        |Processor Only    |r         |
        
        t                |u        |Aggregated Billing|y         |   -- case 6
        u                |v        |Aggregated Billing|y         |
        v                |w        |Aggregated Billing|y         |
        w                |x        |Aggregated Billing|y         |
        x                |y        |Aggregated Billing|y         |
        y                |*        |Processor Only    |y         |
        
        Case 1 (One Level)
        ------------------
        Since billing_preference != 'Aggregated Billing, the account is billed directly; i.e, bill_to_id = cardconex_acct_id
        
        Case 2 (Two Levels)
        -------------------
        billing_preference = 'Aggregated Billing', so this account is not billed directly.
     
        Consider the following:
        
        cardconex_acct_id|parent_id|billing_preference|
        -----------------|---------|------------------|
        b                |c        |Aggregated Billing|
        c                |*        |Direct Billing    |
        
        We need to calculate the bill_to_id for cardconex_acct_id = 'b'.
        billing_preference = 'Aggregated Billing', so we have the find the parent.
        
        In this case, the parent_id = 'c'.  The value of billing_preference for cardconex_acct_id = 'c' = 'Direct Billing', so 'c' is the parent.
        Therefore, the bill_to_id for cardconex_acct_id IN ('b', 'c') = 'Direct Billing.
        
        Cases 3, 4, 5, ... (Three Or More Levels)
        -----------------------------------------
        These are variations for Case 2, with an increasing number of levels.
        See the desired output in the table above for each of these cases.   
    
    */
    
    DECLARE i           TINYINT UNSIGNED;
    DECLARE num_levels  TINYINT UNSIGNED DEFAULT 4;   -- number of times to repeat the loop for cases 3-6

    SELECT 'Executing Stored Procedure' AS operation, 'update_bill_to_id' AS stored_procedure, CURRENT_TIMESTAMP;
    
    -- Case 1
    
    SET @ab = 'Aggregated Billing';
    
    DROP TABLE IF EXISTS tmp_01;
    
    CREATE TEMPORARY TABLE tmp_01(
        cardconex_acct_id     VARCHAR(32)
       ,parent_id             VARCHAR(32)
       ,billing_preference    VARCHAR(32)
       ,bill_to_id            VARCHAR(32)
       ,PRIMARY KEY(cardconex_acct_id)
       ,KEY idx_parent_id(parent_id)
    );
    

    -- NULL values of billing_preference__c should be interpreted as 'Direct Billing'.  
    -- This is not currently configured in the database or in the warehouse, so it is being done here.
    
    SELECT 'NULL values of sales_force.account.billing_preference__c will be interpreted as \'Direct Billing\'' AS message;
  
    INSERT INTO tmp_01 
    SELECT 
         id                       AS cardconex_acct_id 
        ,parentid                 AS parent_id 
        ,'Direct Billing'         AS billing_preference
        ,NULL                     AS bill_to_id
      FROM sales_force.account 
     WHERE billing_preference__c IS NULL
    ;
  
    INSERT INTO tmp_01 
    SELECT 
         id                       AS cardconex_acct_id 
        ,parentid                 AS parent_id 
        ,billing_preference__c    AS billing_preference
        ,NULL                     AS bill_to_id
      FROM sales_force.account 
     WHERE billing_preference__c != @ab
    ;
    
    UPDATE tmp_01
       SET bill_to_id = cardconex_acct_id
     WHERE TRUE 
    ;  
    
    -- SELECT * FROM tmp_01;
    -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|
    -- --|-----------------|---------|------------------|----------|
    --  1|a                |*        |B                 |a         |
    --  3|c                |*        |C                 |c         |
    --  6|g                |*        |D                 |g         |
    -- 10|l                |*        |E                 |l         |
    -- 15|r                |*        |F                 |r         |
    -- 21|y                |*        |G                 |y         |
    
    -- Case 2
    
    DROP TABLE IF EXISTS tmp_02;
    
    CREATE TEMPORARY TABLE tmp_02 LIKE tmp_01;
    
    INSERT INTO tmp_02
    SELECT 
         id                       AS cardconex_acct_id 
        ,parentid                 AS parent_id 
        ,billing_preference__c    AS billing_preference
        ,NULL                     AS bill_to_id
      FROM sales_force.account 
     WHERE billing_preference__c = @ab
    ;
    
    UPDATE tmp_02     t2 
      JOIN tmp_01     t1 
        ON t2.parent_id = t1.cardconex_acct_id 
       SET t2.bill_to_id = t1.bill_to_id
     WHERE TRUE 
    ;
    
    -- SELECT * FROM tmp_02;
    
    -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|
    -- --|-----------------|---------|------------------|----------|
    --  2|b                |c        |A                 |c         |
    --  4|e                |f        |A                 |          |
    --  5|f                |g        |A                 |g         |
    --  7|i                |j        |A                 |          |
    --  8|j                |k        |A                 |          |
    --  9|k                |l        |A                 |l         |
    -- 11|n                |o        |A                 |          |
    -- 12|o                |p        |A                 |          |
    -- 13|p                |q        |A                 |          |
    -- 14|q                |r        |A                 |r         |
    -- 16|t                |u        |A                 |          |
    -- 17|u                |v        |A                 |          |
    -- 18|v                |w        |A                 |          |
    -- 19|w                |x        |A                 |          |
    -- 20|x                |y        |A                 |y         |
    
    -- SELECT * FROM (
    --          SELECT * FROM tmp_01
    --    UNION SELECT * FROM tmp_02
    --   ) t3
    --  ORDER BY 1
    -- ;
    
    -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|
    -- --|-----------------|---------|------------------|----------|
    --  1|a                |*        |B                 |a         |
    --  2|b                |c        |A                 |c         |
    --  3|c                |*        |C                 |c         |
    --  4|e                |f        |A                 |          |
    --  5|f                |g        |A                 |g         |
    --  6|g                |*        |D                 |g         |
    --  7|i                |j        |A                 |          |
    --  8|j                |k        |A                 |          |
    --  9|k                |l        |A                 |l         |
    -- 10|l                |*        |E                 |l         |
    -- 11|n                |o        |A                 |          |
    -- 12|o                |p        |A                 |          |
    -- 13|p                |q        |A                 |          |
    -- 14|q                |r        |A                 |r         |
    -- 15|r                |*        |F                 |r         |
    -- 16|t                |u        |A                 |          |
    -- 17|u                |v        |A                 |          |
    -- 18|v                |w        |A                 |          |
    -- 19|w                |x        |A                 |          |
    -- 20|x                |y        |A                 |y         |
    -- 21|y                |*        |G                 |y         |
    
    
    
    -- Case 3
    
    /*  
    
        I need to join a self join on tmp_02 to proceed.  
        But MariaDB apparently does not support that; see the following:
        
        SELECT a.*, b.*
          FROM tmp_02   a 
          JOIN tmp_02   b 
            ON a.cardconex_acct_id = b.cardconex_acct_id;
        SQL Error [1137] [HY000]: Can't reopen table: 'a'
        
        I will therefore have to create two copies of the same table and join those instead.
        
        It so happens that the code for Case 3 also workds for Case 4, 5, 6, ...
        
        So we can put that code in a loop.
        
        Finance has advised that four loops is enough.
    
    */
    
    SET i = 0;
    
    REPEAT
        DROP TABLE IF EXISTS tmp_03;
        DROP TABLE IF EXISTS tmp_04;
        CREATE TEMPORARY TABLE tmp_03 SELECT * FROM tmp_02;
        CREATE TEMPORARY TABLE tmp_04 SELECT * FROM tmp_02;
        
        -- SELECT 
        --      t3.cardconex_acct_id AS t3_cardconex_acct_id 
        --     ,t3.parent_id         AS t3_parent_id 
        --     ,t4.cardconex_acct_id AS t3_cardconex_acct_id 
        --     ,t4.parent_id         AS t4_parent_id
        --     ,t4.bill_to_id
        --   FROM tmp_03   t3
        --   JOIN tmp_04   t4 
        --     ON t3.parent_id = t4.cardconex_acct_id
        --  WHERE t4.bill_to_id IS NOT NULL;
         
        -- t3_cardconex_acct_id|t3_parent_id|t3_cardconex_acct_id|t4_parent_id|bill_to_id|
        -- --------------------|------------|--------------------|------------|----------|
        -- e                   |f           |f                   |g           |g         |
        -- j                   |k           |k                   |l           |l         |
        -- p                   |q           |q                   |r           |r         |
        -- w                   |x           |x                   |y           |y         |
        
        -- SELECT * FROM tmp_02 WHERE bill_to_id IS NULL;
        
        -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|
        -- --|-----------------|---------|------------------|----------|
        --  4|e                |f        |A                 |          |
        --  7|i                |j        |A                 |          |
        --  8|j                |k        |A                 |          |
        -- 11|n                |o        |A                 |          |
        -- 12|o                |p        |A                 |          |
        -- 13|p                |q        |A                 |          |
        -- 16|t                |u        |A                 |          |
        -- 17|u                |v        |A                 |          |
        -- 18|v                |w        |A                 |          |
        -- 19|w                |x        |A                 |          |
        
        UPDATE tmp_02    t2 
          JOIN (
            SELECT 
                 t3.cardconex_acct_id AS t3_cardconex_acct_id 
                ,t3.parent_id         AS t3_parent_id 
                ,t4.cardconex_acct_id AS t4_cardconex_acct_id 
                ,t4.parent_id         AS t4_parent_id
                ,t4.bill_to_id
              FROM tmp_03   t3
              JOIN tmp_04   t4 
                ON t3.parent_id = t4.cardconex_acct_id
             WHERE t4.bill_to_id IS NOT NULL   
          ) t3 
            ON t2.cardconex_acct_id = t3.t3_cardconex_acct_id 
           SET t2.bill_to_id = t3.bill_to_id 
         WHERE TRUE 
        ;
      
        SET i = i + 1;
        
        -- SELECT * FROM (
        --          SELECT * FROM tmp_01
        --    UNION SELECT * FROM tmp_02
        --   ) t3
        --  ORDER BY 1
        -- ;
        
        -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|
        -- --|-----------------|---------|------------------|----------|
        --  1|a                |*        |B                 |a         |
        --  2|b                |c        |A                 |c         |
        --  3|c                |*        |C                 |c         |
        --  4|e                |f        |A                 |g         |
        --  5|f                |g        |A                 |g         |
        --  6|g                |*        |D                 |g         |
        --  7|i                |j        |A                 |          |
        --  8|j                |k        |A                 |l         |
        --  9|k                |l        |A                 |l         |
        -- 10|l                |*        |E                 |l         |
        -- 11|n                |o        |A                 |          |
        -- 12|o                |p        |A                 |          |
        -- 13|p                |q        |A                 |r         |
        -- 14|q                |r        |A                 |r         |
        -- 15|r                |*        |F                 |r         |
        -- 16|t                |u        |A                 |          |
        -- 17|u                |v        |A                 |          |
        -- 18|v                |w        |A                 |          |
        -- 19|w                |x        |A                 |y         |
        -- 20|x                |y        |A                 |y         |
        -- 21|y                |*        |G                 |y         |
        
     UNTIL i = num_levels
       END REPEAT
    ;
  
  INSERT INTO tmp_01 SELECT * FROM tmp_02;   -- combine case 1 and cases 2-6
     
--   SELECT 
--       t1.bill_to_id 
--      ,sc.cardconex_acct_id 
--      ,sc.dba_name 
--     FROM auto_billing_dw.f_auto_billing_complete_2 sc 
--     JOIN tmp_01                                         t1 
--       ON sc.cardconex_acct_id = t1.cardconex_acct_id 
--   ;


  SELECT 'Updating f_auto_billing_complete_2...' AS message;

  UPDATE auto_billing_dw.f_auto_billing_complete_2
     SET bill_to_id = NULL
   WHERE TRUE 
  ;

  UPDATE auto_billing_dw.f_auto_billing_complete_2  ab
    JOIN tmp_01                                               t1 
      ON ab.account_id = t1.cardconex_acct_id  
     SET ab.bill_to_id = t1.bill_to_id 
   WHERE TRUE 
  ;


  SELECT 'Updating f_auto_billing_complete_2...' AS message;

  UPDATE auto_billing_dw.f_auto_billing_complete_2
     SET bill_to_id = NULL
   WHERE TRUE 
  ;
   
  UPDATE auto_billing_dw.f_auto_billing_complete_2            ab
    JOIN tmp_01                                               t1 
      ON ab.account_id = t1.cardconex_acct_id  
     SET ab.bill_to_id = t1.bill_to_id 
   WHERE TRUE 
  ;


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `f_auto_billing_complete_decryptx` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `f_auto_billing_complete_decryptx`()
BEGIN
  
    DECLARE last_of_last_month DATE;
  
    SELECT 'Executing Stored Procedure' AS operation, 'f_auto_billing_complete_decryptx' AS stored_procedure, CURRENT_TIMESTAMP;
    
    SET last_of_last_month = CONVERT(DATE_FORMAT(CURRENT_DATE, '%Y%m01'), DATE) - INTERVAL 1 DAY;
      
    SET @stage = 0;
  
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP; 
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2      abc 
      JOIN (
          SELECT
              COALESCE(ddcm.cardconex_acct_id, dcm.cardconex_acct_id)         AS account_id
             ,SUM(ddd.decryptions_mtd)                                        AS decryptions_mtd
            FROM auto_billing_staging.decryptx_device_day                     ddd 
            LEFT JOIN auto_billing_staging.stg_decryptx_device_cardconex_map  ddcm ON ddd.poi_device_id = ddcm.decryptx_device_id 
            LEFT JOIN auto_billing_staging.stg_decryptx_cardconex_map         dcm  ON ddd.custodian_id  = dcm.decryptx_acct_id
           WHERE ddd.report_date = last_of_last_month
           GROUP BY 1
      ) ddd
        ON abc.account_id = ddd.account_id
       SET abc.decryption_count = COALESCE(ddd.decryptions_mtd, 0)
     WHERE TRUE 
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc 
      JOIN (
          SELECT     
               dca.account_id 
              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_activated_count
            FROM auto_billing_staging.decryptx_device_day             ddd
            JOIN auto_billing_staging.tmp_device_account_id   dca 
              ON ddd.poi_device_id = dca.poi_device_id
           WHERE ddd.report_date =  last_of_last_month
             AND ddd.state = 'Activated'
           GROUP BY 1
      ) t1 
        ON tdc.account_id = t1.account_id 
       SET tdc.device_activated_count = t1.device_activated_count
      WHERE TRUE 
    ; 
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc 
      JOIN (
          SELECT     
               dca.account_id 
              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_activating_activated_count
            FROM auto_billing_staging.decryptx_device_day             ddd
            JOIN auto_billing_staging.tmp_device_account_id   dca 
              ON ddd.poi_device_id = dca.poi_device_id
           WHERE ddd.report_date =  last_of_last_month
             AND ddd.state = 'Activating'
             AND ddd.decryptions_mtd > 0
           GROUP BY 1
      ) t1 
        ON tdc.account_id = t1.account_id 
       SET tdc.device_activating_activated_count = t1.device_activating_activated_count
      WHERE TRUE 
    ; 
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc 
      JOIN (
          SELECT     
               dca.account_id 
              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_activating_count
            FROM auto_billing_staging.decryptx_device_day             ddd
            JOIN auto_billing_staging.tmp_device_account_id   dca 
              ON ddd.poi_device_id = dca.poi_device_id
           WHERE ddd.report_date =  last_of_last_month
             AND ddd.state = 'Activating'
           GROUP BY 1
      ) t1 
        ON tdc.account_id = t1.account_id 
       SET tdc.device_activating_count = t1.device_activating_count
      WHERE TRUE 
    ; 
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc 
      JOIN (
          SELECT     
               dca.account_id 
              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_other_activated_count
            FROM auto_billing_staging.decryptx_device_day             ddd
            JOIN auto_billing_staging.tmp_device_account_id   dca 
              ON ddd.poi_device_id = dca.poi_device_id
           WHERE ddd.report_date =  last_of_last_month
             AND ddd.state NOT IN ('Activated', 'Activating', 'Stored')
             AND ddd.decryptions_mtd > 0
           GROUP BY 1
      ) t1 
        ON tdc.account_id = t1.account_id 
       SET tdc.device_other_activated_count = t1.device_other_activated_count
      WHERE TRUE 
    ; 
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc 
      JOIN (
          SELECT     
               dca.account_id 
              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_other_count
            FROM auto_billing_staging.decryptx_device_day             ddd
            JOIN auto_billing_staging.tmp_device_account_id   dca 
              ON ddd.poi_device_id = dca.poi_device_id
           WHERE ddd.report_date =  last_of_last_month
             AND ddd.state NOT IN ('Activated', 'Activating', 'Stored')
           GROUP BY 1
      ) t1 
        ON tdc.account_id = t1.account_id 
       SET tdc.device_other_count = t1.device_other_count
      WHERE TRUE 
    ; 
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc 
      JOIN (
          SELECT     
               dca.account_id 
              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_stored_activated_count
            FROM auto_billing_staging.decryptx_device_day             ddd
            JOIN auto_billing_staging.tmp_device_account_id   dca 
              ON ddd.poi_device_id = dca.poi_device_id
           WHERE ddd.report_date =  last_of_last_month
             AND ddd.state = 'Stored'
             AND ddd.decryptions_mtd > 0
           GROUP BY 1
      ) t1 
        ON tdc.account_id = t1.account_id 
       SET tdc.device_stored_activated_count = t1.device_stored_activated_count
      WHERE TRUE 
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc 
      JOIN (
          SELECT     
               dca.account_id 
              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_stored_count
            FROM auto_billing_staging.decryptx_device_day             ddd
            JOIN auto_billing_staging.tmp_device_account_id   dca 
              ON ddd.poi_device_id = dca.poi_device_id
           WHERE ddd.report_date =  last_of_last_month
             AND ddd.state = 'Stored'
           GROUP BY 1
      ) t1 
        ON tdc.account_id = t1.account_id 
       SET tdc.device_stored_count = t1.device_stored_count
      WHERE TRUE 
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2
       SET device_activated_count               = COALESCE(device_activated_count           , 0.0000) 
          ,device_activating_activated_count    = COALESCE(device_activating_activated_count, 0.0000) 
          ,device_activating_count              = COALESCE(device_activating_count          , 0.0000) 
          ,device_other_activated_count         = COALESCE(device_other_activated_count     , 0.0000) 
          ,device_other_count                   = COALESCE(device_other_count               , 0.0000) 
          ,device_stored_activated_count        = COALESCE(device_stored_activated_count    , 0.0000) 
          ,device_stored_count                  = COALESCE(device_stored_count, 0.0000) 
     WHERE decryptx = 1
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
        
    UPDATE auto_billing_dw.f_auto_billing_complete_2    abc 
      JOIN auto_billing_staging.stg_asset               asst 
        ON abc.account_id = asst.account_id
       SET abc.p2pe_device_activated_charge  = asst.p2pe_device_activated      * (abc.device_activated_count + abc.device_activating_activated_count + abc.device_stored_activated_count + abc.device_other_activated_count)
          ,abc.p2pe_device_activating_charge = asst.p2pe_device_activating_fee * (abc.device_activating_count - abc.device_activating_activated_count)
          ,abc.p2pe_device_stored_charge     = asst.p2pe_device_stored_fee     * (abc.device_stored_count - abc.device_stored_activated_count)
     WHERE TRUE 
    ;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `f_auto_billing_complete_demographics` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `f_auto_billing_complete_demographics`()
BEGIN
  
    -- bill_to_name 
    
    SELECT 'Executing Stored Procedure' AS operation, 'f_auto_billing_complete_demographics' AS stored_procedure, CURRENT_TIMESTAMP;
    
    SELECT 'updating bill_to_%' AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2    abc 
      JOIN sales_force.account                          acct
        ON abc.bill_to_id   = acct.id 
       SET abc.bill_to_name = acct.name 
     WHERE TRUE 
    ;
        
    -- columns originating in sales_force.account
    SELECT 'updating columns = f(sales_force.account)' AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2    abc 
      JOIN sales_force.account                          acct
        ON abc.account_id        = acct.id 
       SET abc.account_name      = acct.name
          ,abc.dba_name          = acct.dba_name__c
          ,abc.collection_method = acct.collection_method__c 
          ,abc.hold_bill         = acct.hold_billing__c
          ,abc.industry_now      = acct.industry
          ,abc.segment_now       = acct.revenue_segment__c 
          ,abc.start_date        = 19700101                     -- needs to be changed to acct.bluefin_contract_start_date when that column has been added to acct
     WHERE TRUE 
    ;
    
    
    -- org_now
    SELECT 'updating org_now' AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2        abc 
      JOIN sales_force.account                              acct 
        ON abc.account_id = acct.id 
      JOIN sales_force.organization__c                      org 
        ON acct.organizationid__c = org.id 
       SET abc.org_now = org.name 
    WHERE TRUE 
    ;
    
    -- payconex 
    
    DROP TABLE IF EXISTS auto_billing_dw.tmp_payconex_01;
    
    SELECT 'creating temporary table tmp_payconex_01' AS stage, CURRENT_TIMESTAMP;
    
    CREATE TEMPORARY TABLE auto_billing_dw.tmp_payconex_01(
         payconex_acct_id       VARCHAR(20)
        ,payconex_acct_name     VARCHAR(255)  
        ,account_id             VARCHAR(18)    
        ,max_cc_sale_vol        DECIMAL(15, 4) 
        ,PRIMARY KEY(payconex_acct_id)
    );
        
    SELECT 'populating tmp_payconex_01' AS stage, CURRENT_TIMESTAMP;
    
    INSERT INTO auto_billing_dw.tmp_payconex_01(payconex_acct_id, max_cc_sale_vol)
    SELECT
         pcm.payconex_acct_id 
        ,MAX(abc.cc_sale_vol) AS max_cc_sale_vol
      FROM auto_billing_dw.f_auto_billing_complete_2          abc 
      JOIN auto_billing_staging.stg_payconex_cardconex_map    pcm
        ON abc.account_id = pcm.cardconex_acct_id 
      JOIN auto_billing_staging.stg_payconex_volume           pv 
        ON pcm.payconex_acct_id = pv.acct_id 
     GROUP BY 1
    ;
    
    SELECT 'updating account_id' AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.tmp_payconex_01                      t01 
      JOIN auto_billing_staging.stg_payconex_cardconex_map      pcm 
        ON t01.payconex_acct_id = pcm.payconex_acct_id 
       SET t01.account_id = pcm.cardconex_acct_id 
     WHERE TRUE 
    ;
      
    SELECT 'updating account_name' AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.tmp_payconex_01                  t01
      JOIN auto_billing_staging.stg_payconex_volume         pv 
        ON t01.payconex_acct_id = pv.acct_id 
       SET t01.payconex_acct_name = pv.acct_name
     WHERE TRUE 
    ;
    
    SELECT 'updating payconex_acct_id, payconex_acct_name' AS stage, CURRENT_TIMESTAMP;
      
    UPDATE auto_billing_dw.f_auto_billing_complete_2      abc 
      JOIN auto_billing_dw.tmp_payconex_01                t01 
        ON abc.account_id = t01.account_id 
       AND t01.max_cc_sale_vol = abc.cc_sale_vol
       SET abc.payconex_acct_id = t01.payconex_acct_id 
          ,abc.payconex_acct_name = t01.payconex_acct_name  
     WHERE TRUE 
    ;
    
    SET SESSION group_concat_max_len = 102400;
  
    SELECT 'updating payconex_acct_ids' AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2      abc 
      JOIN (
            SELECT 
                 pcm.cardconex_acct_id                                                  AS account_id
                ,LEFT(GROUP_CONCAT(pv.acct_id ORDER BY pv.cc_sale_vol DESC SEPARATOR ' | '), 74) AS payconex_acct_ids
                ,COUNT(*)
              FROM auto_billing_staging.stg_payconex_volume           pv 
              JOIN auto_billing_staging.stg_payconex_cardconex_map    pcm
                ON pv.acct_id = pcm.payconex_acct_id 
             GROUP BY 1  
      ) t0 
        ON abc.account_id = t0.account_id 
       SET abc.payconex_acct_ids = t0.payconex_acct_ids
     WHERE TRUE 
    ;
  
    SELECT 'updating year_mon' AS stage, CURRENT_TIMESTAMP;
    UPDATE auto_billing_dw.f_auto_billing_complete_2 
       SET year_mon = DATE_FORMAT(CURRENT_DATE, '%Y%m')
     WHERE TRUE
    ;
  
  
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `f_auto_billing_complete_initialize` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `f_auto_billing_complete_initialize`()
    COMMENT 'USAGE:  f_auto_billing_complete_initialize /* initialize f_auto_billing_complete_2 with account_ids */'
BEGIN
  
    DECLARE last_of_last_month  DATE;
  
    SET last_of_last_month = CONVERT(DATE_FORMAT(CURRENT_DATE, '%Y%m01'), DATE) - INTERVAL 1 DAY;
  
    SELECT 'Executing Stored Procedure' AS operation, 'f_auto_billing_complete_initialize' AS stored_procedure, CURRENT_TIMESTAMP;
   
    -- get list of cardconex_acct_id's originating from decryptx
    
    SELECT 'retrieving decryptx account_id\'s' AS stage, CURRENT_TIMESTAMP;
    
    DROP TABLE IF EXISTS auto_billing_staging.tmp_device_account_id;
    
    CREATE TABLE auto_billing_staging.tmp_device_account_id (
         poi_device_id VARCHAR(16)
        ,account_id VARCHAR(18) 
        ,PRIMARY KEY(poi_device_id)
    );
    
    INSERT INTO auto_billing_staging.tmp_device_account_id
    SELECT
        ddd.poi_device_id                                               AS poi_device_id                                    
       ,COALESCE(ddcm.cardconex_acct_id, dcm.cardconex_acct_id)         AS account_id
      FROM auto_billing_staging.decryptx_device_day                     ddd 
      LEFT JOIN auto_billing_staging.stg_decryptx_device_cardconex_map  ddcm ON ddd.poi_device_id = ddcm.decryptx_device_id 
      LEFT JOIN auto_billing_staging.stg_decryptx_cardconex_map         dcm  ON ddd.custodian_id  = dcm.decryptx_acct_id
     WHERE ddd.report_date = last_of_last_month
    ;
    
    -- get list of cardconex_acct_id's originating from payconex
    SELECT 'retrieving payconex account_id\'s' AS stage, CURRENT_TIMESTAMP;
      
    DROP TABLE IF EXISTS auto_billing_staging.tmp_payconex_account_id;
    
    CREATE  TABLE auto_billing_staging.tmp_payconex_account_id(
         account_id VARCHAR(18) PRIMARY KEY
    );
    
    INSERT IGNORE INTO auto_billing_staging.tmp_payconex_account_id
    SELECT pcm.cardconex_acct_id
      FROM auto_billing_staging.stg_payconex_volume                 pvd 
      LEFT JOIN auto_billing_staging.stg_payconex_cardconex_map     pcm 
        ON pvd.acct_id = pcm.payconex_acct_id 
    ;
    
    -- populate f_auto_billing_complete_2
    
    TRUNCATE auto_billing_dw.f_auto_billing_complete_2;
    
    SELECT 'inserting account_id\'s' AS stage, CURRENT_TIMESTAMP;
  
    INSERT IGNORE INTO auto_billing_dw.f_auto_billing_complete_2(account_id)
    SELECT account_id
      FROM auto_billing_staging.tmp_device_account_id
    ;
    
    INSERT IGNORE INTO auto_billing_dw.f_auto_billing_complete_2(account_id)
    SELECT account_id
      FROM auto_billing_staging.tmp_payconex_account_id
    ;
      
    DELETE FROM auto_billing_dw.f_auto_billing_complete_2 WHERE account_id IS NULL OR LENGTH(account_id) = 0;
   
    UPDATE auto_billing_dw.f_auto_billing_complete_2      t1
      JOIN auto_billing_staging.tmp_device_account_id     t2 
        ON t1.account_id = t2.account_id 
       SET t1.decryptx = 1
     WHERE TRUE
    ;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2      t1
      JOIN auto_billing_staging.tmp_payconex_account_id   t2 
        ON t1.account_id = t2.account_id 
       SET t1.payconex = 1
     WHERE TRUE
    ;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2
       SET decryptx    = COALESCE(decryptx, 0)
          ,payconex    = COALESCE(payconex, 0)
          ,shieldconex = 0
     WHERE TRUE 
    ;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `f_auto_billing_complete_payconex` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `f_auto_billing_complete_payconex`()
BEGIN
  
    SET @stage = 0; 
    
    SELECT 'Executing Stored Procedure' AS operation, 'f_auto_billing_complete_payconex' AS stored_procedure, CURRENT_TIMESTAMP;

    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2      abc 
      JOIN (
          SELECT
               pcm.cardconex_acct_id 
              ,SUM(group_count) AS group_count
            FROM auto_billing_staging.stg_payconex_volume       pv 
            JOIN auto_billing_staging.stg_payconex_cardconex_map  pcm 
              ON pv.acct_id = pcm.payconex_acct_id 
           GROUP BY 1
      ) t1 
        ON abc.account_id = t1.cardconex_acct_id 
       SET abc.group_count = t1.group_count 
     WHERE TRUE
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2    abc
      JOIN auto_billing_staging.stg_asset               asst
        ON abc.account_id = asst.account_id
       SET abc.group_charge = abc.group_count * asst.group_tag_fee 
     WHERE TRUE 
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2 abc 
      JOIN (
          SELECT 
               pcm.cardconex_acct_id  AS account_id 
              ,SUM(pv.user_count)     AS user_count
            FROM auto_billing_staging.stg_payconex_volume           pv
            JOIN auto_billing_staging.stg_payconex_cardconex_map    pcm
              ON pv.acct_id = pcm.payconex_acct_id 
           GROUP BY 1  
      ) t1 
        ON abc.account_id = t1.account_id
       SET abc.user_count = t1.user_count 
     WHERE TRUE 
    ;
    
    DROP TABLE IF EXISTS auto_billing_dw.tmp_vol_charges;
    
    CREATE TABLE auto_billing_dw.tmp_vol_charges(
       payconex_acct_id                      VARCHAR(12)
      ,account_id                            VARCHAR(18) 
      ,ach_noc_message_charge                DECIMAL(12, 5) NOT NULL DEFAULT 0.00000
      ,ach_returnerror_charge                DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 
      ,ach_sale_volume_charge                DECIMAL(12, 5) NOT NULL DEFAULT 0.00000
      ,achworks_credit_charge                DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 
      ,achworks_monthly_charge               DECIMAL(12, 5) NOT NULL DEFAULT 0.00000
      ,achworks_per_trans_charge             DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 
      ,apriva_monthly_charge                 DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 
      ,card_convenience_charge               DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 
      ,cc_sale_charge                        DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 
      ,file_transfer_monthly_charge          DECIMAL(12, 5) NOT NULL DEFAULT 0.00000
      ,gw_monthly_charge                     DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 
      ,gw_per_auth_charge                    DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,gw_per_auth_decline_charge            DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,gw_per_credit_charge                  DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,gw_per_refund_charge                  DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,gw_per_token_charge                   DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,gw_reissued_ach_trans_charge          DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,gw_reissued_charge                    DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,misc_monthly_charge                   DECIMAL(12, 5) NOT NULL DEFAULT 0.00000   
      ,p2pe_encryption_charge                DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,p2pe_token_charge                     DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,p2pe_token_flat_charge                DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 
      ,p2pe_token_flat_monthly_charge        DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 
      ,pc_account_updater_monthly_charge     DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,pci_scans_monthly_charge              DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  
      ,UNIQUE(payconex_acct_id)         -- i think, but am not sure, that this is valid
    ) ENGINE=InnoDB DEFAULT CHARSET=latin1
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    INSERT INTO auto_billing_dw.tmp_vol_charges
    SELECT 
         pvd.acct_id AS payconex_acct_id
        ,pcm.cardconex_acct_id 
        ,COALESCE(asst.ach_noc_fee,                 0.0) *  COALESCE(pvd.ach_noc_messages,          0.0)                                                 AS ach_noc_message_charge
        ,COALESCE(asst.ach_return_error_fee,        0.0) * (COALESCE(pvd.ach_returns,               0.0) + COALESCE(pvd.ach_errors, 0.0))                AS ach_returnerror_charge
        ,COALESCE(asst.bfach_discount_rate / 100.0, 0.0) *  COALESCE(pvd.ach_sale_vol ,             0.0)                                                 AS ach_sale_volume_charge               
        ,COALESCE(asst.ach_credit_fee,              0.0) * (COALESCE(pvd.ach_sale_trans,            0.0) + COALESCE(pvd.ach_credit_trans, 0.0))          AS achworks_credit_charge
        ,COALESCE(asst.ach_monthly_fee,             0.0)                                                                                                 AS achworks_monthly_charge
        ,COALESCE(asst.ach_per_gw_trans_fee,        0.0) * (COALESCE(pvd.ach_sale_trans,            0.0) + COALESCE(pvd.ach_credit_trans, 0.0))          AS achworks_per_trans_charge
        ,0.0                                                                                                                                             AS apriva_monthly_charge                -- placeholder
        ,0.0                                                                                                                                             AS card_convenience_charge              -- placeholder
        ,COALESCE(asst.gw_per_sale_fee,             0.0) *  COALESCE(pvd.cc_sale_trans,             0.0)                                                 AS cc_sale_charge
        ,COALESCE(asst.file_transfer_monthly_fee,   0.0)                                                                                                 AS file_transfer_monthly_charge
        ,0.0                                                                                                                                             AS gw_monthly_charge                    -- placeholder
        ,COALESCE(asst.per_transaction_fee,         0.0) * (COALESCE(pvd.cc_auth_trans,             0.0) + COALESCE(pvd.tokens_stored, 0.0))             AS gw_per_auth_charge
        ,COALESCE(asst.gw_per_auth_decline_fee,     0.0) *  COALESCE(pvd.cc_auth_decline_trans,     0.0)                                                 AS gw_per_auth_decline_charge
        ,COALESCE(asst.gw_per_credit_fee,           0.0) *  COALESCE(pvd.cc_credit_trans,           0.0)                                                 AS gw_per_credit_charge
        ,COALESCE(asst.gw_per_refund_fee,           0.0) *  COALESCE(pvd.cc_ref_trans,              0.0)                                                 AS gw_per_refund_charge
        ,COALESCE(asst.gw_per_token_fee,            0.0) *  COALESCE(pvd.tokens_stored,             0.0)                                                 AS gw_per_token_charge
        ,COALESCE(asst.gw_reissued_fee,             0.0) *  COALESCE(pvd.reissued_ach_transactions, 0.0)                                                 AS gw_reissued_ach_trans_charge
        ,COALESCE(asst.gw_reissued_fee,             0.0) *  COALESCE(pvd.reissued_cc_transactions,  0.0)                                                 AS gw_reissued_charge
        ,0.0                                                                                                                                             AS misc_monthly_charge                  -- placeholder 
        ,0.0                                                                                                                                             AS p2pe_encryption_charge               -- placeholder
        ,COALESCE(asst.p2pe_tokenization_fee,       0.0) *  COALESCE(pvd.p2pe_tokens_stored,        0.0)                                                 AS p2pe_token_charge
        ,COALESCE(asst.p2pe_monthly_flat_fee,       0.0)                                                                                                 AS p2pe_token_flat_charge
        ,COALESCE(asst.one_time_key_injection_fees, 0.0)                                                                                                 AS p2pe_token_flat_monthly_charge
        ,0.0                                                                                                                                             AS pc_account_updater_monthly_charge    -- placeholder
        ,COALESCE(asst.pci_scans_monthly_fee,       0.0) * (COALESCE(pvd.reissued_cc_transactions,  0.0) + COALESCE(pvd.reissued_ach_transactions, 0.0)) AS pci_scans_monthly_charge
      FROM auto_billing_staging.stg_payconex_volume           pvd    
      JOIN auto_billing_staging.stg_payconex_cardconex_map    pcm    
        ON pvd.acct_id = pcm.payconex_acct_id 
      LEFT JOIN auto_billing_staging.stg_asset                asst 
        ON pcm.cardconex_acct_id = asst.account_id
    ;
  
    -- 7 jan 2021
    -- need to add rows for decryptx-only; i.e., no row in stg_payconex_cardconex_map
    INSERT INTO auto_billing_dw.tmp_vol_charges
    SELECT 
       NULL                                      AS payconex_acct_id
      ,asst.account_id                           AS account_id
      ,0                                         AS ach_noc_message_charge
      ,0                                         AS ach_returnerror_charge
      ,0                                         AS ach_sale_volume_charge               
      ,0                                         AS achworks_credit_charge
      ,0                                         AS achworks_monthly_charge
      ,0                                         AS achworks_per_trans_charge
      ,0                                         AS apriva_monthly_charge                
      ,0                                         AS card_convenience_charge              
      ,0                                         AS cc_sale_charge
      ,0                                         AS file_transfer_monthly_charge
      ,0                                         AS gw_monthly_charge                    
      ,0                                         AS gw_per_auth_charge
      ,0                                         AS gw_per_auth_decline_charge
      ,0                                         AS gw_per_credit_charge
      ,0                                         AS gw_per_refund_charge
      ,0                                         AS gw_per_token_charge
      ,0                                         AS gw_reissued_ach_trans_charge
      ,0                                         AS gw_reissued_charge
      ,0                                         AS misc_monthly_charge                   
      ,0                                         AS p2pe_encryption_charge               -- placeholder (yes) 
      ,0                                         AS p2pe_token_charge
      ,asst.p2pe_monthly_flat_fee                AS p2pe_token_flat_charge  -- yes
      ,asst.one_time_key_injection_fees          AS p2pe_token_flat_monthly_charge       -- yes
      ,0 AS pc_account_updater_monthly_charge    -- yes -- placeholder
      ,0 AS pci_scans_monthly_charge
   FROM auto_billing_staging.stg_asset     asst
   LEFT JOIN auto_billing_staging.stg_payconex_cardconex_map   pcm
     ON asst.account_id = pcm.cardconex_acct_id
   LEFT JOIN sales_force.account acct 
     ON asst.account_id = acct.id
  WHERE pcm.payconex_acct_id IS NULL
  ;
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.tmp_vol_charges
       SET card_convenience_charge           = 0.0
          ,pc_account_updater_monthly_charge = 0.0
     WHERE TRUE 
    ;
    
    DROP TABLE IF EXISTS auto_billing_dw.tmp_mid_count;
    
    CREATE  TABLE auto_billing_dw.tmp_mid_count(
         account_id   VARCHAR(18)
        ,mid_count    SMALLINT UNSIGNED
        ,PRIMARY KEY(account_id)
    );
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    INSERT INTO auto_billing_dw.tmp_mid_count
    SELECT 
         pcm.cardconex_acct_id 
        ,COUNT(DISTINCT pvd.acct_id   ) AS mid_count 
      FROM auto_billing_staging.stg_payconex_volume           pvd
      JOIN auto_billing_staging.stg_payconex_cardconex_map    pcm
        ON pvd.acct_id = pcm.payconex_acct_id 
     GROUP BY 1
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.tmp_vol_charges                pv 
      LEFT JOIN auto_billing_staging.stg_asset            asst 
        ON pv.account_id = asst.account_id
      LEFT JOIN auto_billing_dw.tmp_mid_count             mc 
        ON pv.account_id = mc.account_id 
       SET pv.apriva_monthly_charge = COALESCE(asst.bluefin_gateway_discount_rate, 0.0) * COALESCE(mc.mid_count, 0)
          ,pv.gw_monthly_charge     = COALESCE(asst.gateway_monthly_fee,           0.0) * COALESCE(mc.mid_count, 0)
          ,pv.misc_monthly_charge   = COALESCE(asst.misc_monthly_fees,             0.0) * COALESCE(mc.mid_count, 0)
     WHERE TRUE 
    ;
     
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2 abc
      JOIN (
          SELECT
               account_id 
              ,SUM(ach_noc_message_charge           ) AS ach_noc_message_charge           
              ,SUM(ach_returnerror_charge           ) AS ach_returnerror_charge           
              ,SUM(ach_sale_volume_charge           ) AS ach_sale_volume_charge           
              ,SUM(achworks_credit_charge           ) AS achworks_credit_charge           
              ,MAX(achworks_monthly_charge          ) AS achworks_monthly_charge            -- changed SUM to MAX
              ,SUM(achworks_per_trans_charge        ) AS achworks_per_trans_charge        
              ,SUM(apriva_monthly_charge            ) AS apriva_monthly_charge            
              ,SUM(card_convenience_charge          ) AS card_convenience_charge          
              ,SUM(cc_sale_charge                   ) AS cc_sale_charge                   
              ,SUM(file_transfer_monthly_charge     ) AS file_transfer_monthly_charge             
              ,MAX(gw_monthly_charge                ) AS gw_monthly_charge                
              ,SUM(gw_per_auth_charge               ) AS gw_per_auth_charge               
              ,SUM(gw_per_auth_decline_charge       ) AS gw_per_auth_decline_charge       
              ,SUM(gw_per_credit_charge             ) AS gw_per_credit_charge             
              ,SUM(gw_per_refund_charge             ) AS gw_per_refund_charge             
              ,SUM(gw_per_token_charge              ) AS gw_per_token_charge              
              ,SUM(gw_reissued_ach_trans_charge     ) AS gw_reissued_ach_trans_charge     
              ,SUM(gw_reissued_charge               ) AS gw_reissued_charge               
              ,MAX(misc_monthly_charge              ) AS misc_monthly_charge                -- changed SUM to MAX                    
              ,SUM(p2pe_token_charge                ) AS p2pe_token_charge                
              ,MAX(p2pe_token_flat_charge           ) AS p2pe_token_flat_charge           
              ,MAX(p2pe_token_flat_monthly_charge   ) AS p2pe_token_flat_monthly_charge   
              ,SUM(pc_account_updater_monthly_charge) AS pc_account_updater_monthly_charge
              ,SUM(pci_scans_monthly_charge         ) AS pci_scans_monthly_charge                
            FROM auto_billing_dw.tmp_vol_charges
           GROUP BY 1  
      ) t1 
        ON abc.account_id = t1.account_id 
      SET  abc.ach_noc_message_charge            = t1.ach_noc_message_charge           
          ,abc.ach_returnerror_charge            = t1.ach_returnerror_charge           
          ,abc.ach_sale_volume_charge            = t1.ach_sale_volume_charge           
          ,abc.achworks_credit_charge            = t1.achworks_credit_charge           
          ,abc.achworks_monthly_charge           = t1.achworks_monthly_charge          
          ,abc.achworks_per_trans_charge         = t1.achworks_per_trans_charge        
          ,abc.apriva_monthly_charge             = t1.apriva_monthly_charge            
          ,abc.card_convenience_charge           = t1.card_convenience_charge          
          ,abc.cc_sale_charge                    = t1.cc_sale_charge                   
          ,abc.file_transfer_monthly_charge      = t1.file_transfer_monthly_charge                        
          ,abc.gw_monthly_charge                 = t1.gw_monthly_charge                
          ,abc.gw_per_auth_charge                = t1.gw_per_auth_charge               
          ,abc.gw_per_auth_decline_charge        = t1.gw_per_auth_decline_charge       
          ,abc.gw_per_credit_charge              = t1.gw_per_credit_charge             
          ,abc.gw_per_refund_charge              = t1.gw_per_refund_charge             
          ,abc.gw_per_token_charge               = t1.gw_per_token_charge              
          ,abc.gw_reissued_ach_trans_charge      = t1.gw_reissued_ach_trans_charge     
          ,abc.gw_reissued_charge                = t1.gw_reissued_charge               
          ,abc.misc_monthly_charge               = t1.misc_monthly_charge                       
          ,abc.p2pe_token_charge                 = t1.p2pe_token_charge                
          ,abc.p2pe_token_flat_charge            = t1.p2pe_token_flat_charge           
          ,abc.p2pe_token_flat_monthly_charge    = t1.p2pe_token_flat_monthly_charge   
          ,abc.pc_account_updater_monthly_charge = t1.pc_account_updater_monthly_charge
          ,abc.pci_scans_monthly_charge          = t1.pci_scans_monthly_charge    
     WHERE TRUE 
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2      abc 
      JOIN auto_billing_staging.stg_asset                 asst 
        ON abc.account_id = asst.account_id 
       SET abc.p2pe_encryption_charge = COALESCE(abc.decryption_count, 0) * COALESCE(asst.p2pe_encryption_fee, 0.0000)
     WHERE TRUE 
    ;
    
    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2      abc 
      JOIN (
          SELECT 
               pcm.cardconex_acct_id            AS account_id
              ,SUM(ach_batches)                 AS ach_batches
              ,SUM(ach_credit_trans)            AS ach_credit_trans
              ,SUM(ach_credit_vol)              AS ach_credit_vol
              ,SUM(ach_errors)                  AS ach_errors
              ,SUM(ach_noc_messages)            AS ach_noc_messages
              ,SUM(ach_returns)                 AS ach_returns
              ,SUM(ach_sale_trans)              AS ach_sale_trans
              ,SUM(ach_sale_vol)                AS ach_sale_vol
              ,SUM(batch_files_processed)       AS batch_files_processed
              ,SUM(cc_auth_decline_trans)       AS cc_auth_decline_trans
              ,SUM(cc_auth_trans)               AS cc_auth_trans
              ,SUM(cc_auth_vol)                 AS cc_auth_vol
              ,SUM(cc_batches)                  AS cc_batches
              ,SUM(cc_capture_trans)            AS cc_capture_trans
              ,SUM(cc_capture_vol)              AS cc_capture_vol
              ,SUM(cc_credit_trans)             AS cc_credit_trans
              ,SUM(cc_credit_vol)               AS cc_credit_vol
              ,SUM(cc_keyed_trans)              AS cc_keyed_trans
              ,SUM(cc_keyed_vol)                AS cc_keyed_vol
              ,SUM(cc_ref_trans)                AS cc_ref_trans
              ,SUM(cc_ref_vol)                  AS cc_ref_vol
              ,SUM(cc_sale_decline_trans)       AS cc_sale_decline_trans
              ,SUM(cc_sale_trans)               AS cc_sale_trans
              ,SUM(cc_sale_vol)                 AS cc_sale_vol
              ,SUM(cc_swiped_trans)             AS cc_swiped_trans
              ,SUM(cc_swiped_vol)               AS cc_swiped_vol
              ,SUM(combined_decline_trans)      AS combined_decline_trans
              ,SUM(p2pe_active_device_trans)    AS p2pe_active_device_trans
              ,SUM(p2pe_auth_decline_trans)     AS p2pe_auth_decline_trans
              ,SUM(p2pe_auth_trans)             AS p2pe_auth_trans
              ,SUM(p2pe_auth_vol)               AS p2pe_auth_vol
              ,SUM(p2pe_capture_trans)          AS p2pe_capture_trans
              ,SUM(p2pe_capture_vol)            AS p2pe_capture_vol
              ,SUM(p2pe_credit_trans)           AS p2pe_credit_trans
              ,SUM(p2pe_credit_vol)             AS p2pe_credit_vol
              ,SUM(p2pe_declined_trans)         AS p2pe_declined_trans
              ,SUM(p2pe_inactive_device_trans)  AS p2pe_inactive_device_trans
              ,SUM(p2pe_refund_trans)           AS p2pe_refund_trans
              ,SUM(p2pe_refund_vol)             AS p2pe_refund_vol
              ,SUM(p2pe_sale_decline_trans)     AS p2pe_sale_decline_trans
              ,SUM(p2pe_sale_trans)             AS p2pe_sale_trans
              ,SUM(p2pe_sale_vol)               AS p2pe_sale_vol
              ,SUM(p2pe_tokens_stored)          AS p2pe_tokens_stored
              ,SUM(reissued_ach_transactions)   AS reissued_ach_transactions
              ,SUM(reissued_cc_transactions)    AS reissued_cc_transactions
              ,SUM(tokens_stored)               AS tokens_stored
            FROM auto_billing_staging.stg_payconex_volume         pvd 
            JOIN auto_billing_staging.stg_payconex_cardconex_map    pcm
              ON pvd.acct_id = pcm.payconex_acct_id 
           GROUP BY 1
      ) t1 ON abc.account_id              = t1.account_id
       SET abc.ach_batches                = t1.ach_batches
          ,abc.ach_credit_trans           = t1.ach_credit_trans
          ,abc.ach_credit_vol             = t1.ach_credit_vol
          ,abc.ach_errors                 = t1.ach_errors
          ,abc.ach_noc_messages           = t1.ach_noc_messages
          ,abc.ach_returns                = t1.ach_returns
          ,abc.ach_sale_trans             = t1.ach_sale_trans
          ,abc.ach_sale_vol               = t1.ach_sale_vol
          ,abc.batch_files_processed      = t1.batch_files_processed
          ,abc.cc_auth_decline_trans      = t1.cc_auth_decline_trans
          ,abc.cc_auth_trans              = t1.cc_auth_trans
          ,abc.cc_auth_vol                = t1.cc_auth_vol
          ,abc.cc_batches                 = t1.cc_batches
          ,abc.cc_capture_trans           = t1.cc_capture_trans
          ,abc.cc_capture_vol             = t1.cc_capture_vol
          ,abc.cc_credit_trans            = t1.cc_credit_trans
          ,abc.cc_credit_vol              = t1.cc_credit_vol
          ,abc.cc_keyed_trans             = t1.cc_keyed_trans
          ,abc.cc_keyed_vol               = t1.cc_keyed_vol
          ,abc.cc_ref_trans               = t1.cc_ref_trans
          ,abc.cc_ref_vol                 = t1.cc_ref_vol
          ,abc.cc_sale_decline_trans      = t1.cc_sale_decline_trans
          ,abc.cc_sale_trans              = t1.cc_sale_trans
          ,abc.cc_sale_vol                = t1.cc_sale_vol
          ,abc.cc_swiped_trans            = t1.cc_swiped_trans
          ,abc.cc_swiped_vol              = t1.cc_swiped_vol
          ,abc.combined_decline_trans     = t1.combined_decline_trans
          ,abc.p2pe_active_device_trans   = t1.p2pe_active_device_trans
          ,abc.p2pe_auth_decline_trans    = t1.p2pe_auth_decline_trans
          ,abc.p2pe_auth_trans            = t1.p2pe_auth_trans
          ,abc.p2pe_auth_vol              = t1.p2pe_auth_vol
          ,abc.p2pe_capture_trans         = t1.p2pe_capture_trans
          ,abc.p2pe_capture_vol           = t1.p2pe_capture_vol
          ,abc.p2pe_credit_trans          = t1.p2pe_credit_trans
          ,abc.p2pe_credit_vol            = t1.p2pe_credit_vol
          ,abc.p2pe_declined_trans        = t1.p2pe_declined_trans
          ,abc.p2pe_inactive_device_trans = t1.p2pe_inactive_device_trans
          ,abc.p2pe_refund_trans          = t1.p2pe_refund_trans
          ,abc.p2pe_refund_vol            = t1.p2pe_refund_vol
          ,abc.p2pe_sale_decline_trans    = t1.p2pe_sale_decline_trans
          ,abc.p2pe_sale_trans            = t1.p2pe_sale_trans
          ,abc.p2pe_sale_vol              = t1.p2pe_sale_vol
          ,abc.p2pe_tokens_stored         = t1.p2pe_tokens_stored
          ,abc.reissued_ach_transactions  = t1.reissued_ach_transactions
          ,abc.reissued_cc_transactions   = t1.reissued_cc_transactions
          ,abc.tokens_stored              = t1.tokens_stored
      WHERE TRUE
    ;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `f_auto_billing_complete_payconex_acct_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `f_auto_billing_complete_payconex_acct_id`()
BEGIN
  
    /*
        
        Finance wants the auto_billing_complete table to include the payconex_acct_id and the payconex_acct_name that corresponds to it.
        But there can exists > 1 payconex_acct_id for the same account_id.  We will therefore have to define which payconex_acct_id to use 
        if there is more than one.
        
        Example
        -------
        
        account_id        |payconex_acct_id|payconex_acct_name                                          |cc_sale_vol|
        ------------------|----------------|------------------------------------------------------------|-----------|
        0013i00000FhCBCAA3|120615298861    |UCIMC Gavin Herbert Eye Institute GHEI LASIK Refractive Surg|     0.0000|
        0013i00000FhCBCAA3|120615298881    |UCIMC Gavin Herbert Eye Institute GHEI Opthalmology         | 92873.3300|
        0013i00000FhCBCAA3|120615298901    |UCIMC Gavin Herbert Eye Institute GHEI OR                   |129985.0700|
    
        Finance has advised that payconex_acct_id to use is the one that corresponds to the highest value of cc_sale_vol;
        i.e., the one in the third row above.
      
    */
    
    SELECT 'Executing Stored Procedure' AS operation, 'f_auto_billing_complete_payconex_acct_id' AS stored_procedure, CURRENT_TIMESTAMP;
    
    SELECT 'creating temporary table auto_billing_dw.tmp_pc_01' AS message;
  
    DROP TABLE IF EXISTS auto_billing_dw.tmp_pc_01;
    
    CREATE TEMPORARY TABLE auto_billing_dw.tmp_pc_01 (
         account_id           VARCHAR(255) 
        ,payconex_acct_id     VARCHAR(20)  
        ,payconex_acct_name   VARCHAR(255)  
        ,cc_sale_vol          DECIMAL(16,4)) 
    ;
    
    INSERT INTO auto_billing_dw.tmp_pc_01
    SELECT 
         pcm.cardconex_acct_id  AS account_id
        ,pv.acct_id             AS payconex_acct_id 
        ,pv.acct_name           AS payconex_acct_name
        ,pv.cc_sale_vol 
      FROM auto_billing_staging.stg_payconex_volume             pv 
      JOIN   auto_billing_staging.stg_payconex_cardconex_map    pcm 
        ON pv.acct_id = pcm.payconex_acct_id 
    --  WHERE pv.acct_id IN ('120615298861', '120615298881', '120615298901')
    ;
    
--     SELECT * FROM auto_billing_dw.tmp_pc_01;
    
    -- account_id        |payconex_acct_id|payconex_acct_name                                          |cc_sale_vol|
    -- ------------------|----------------|------------------------------------------------------------|-----------|
    -- 0013i00000FhCBCAA3|120615298861    |UCIMC Gavin Herbert Eye Institute GHEI LASIK Refractive Surg|     0.0000|
    -- 0013i00000FhCBCAA3|120615298881    |UCIMC Gavin Herbert Eye Institute GHEI Opthalmology         | 92873.3300|
    -- 0013i00000FhCBCAA3|120615298901    |UCIMC Gavin Herbert Eye Institute GHEI OR                   |129985.0700|
    
    SELECT 'creating temporary table auto_billing_dw.tmp_pc_02' AS message;

    DROP TABLE IF EXISTS auto_billing_dw.tmp_pc_02;
    
    CREATE TEMPORARY TABLE auto_billing_dw.tmp_pc_02(
         account_id               VARCHAR(18)
        ,payconex_acct_id         VARCHAR(20)
        ,payconex_acct_name       VARCHAR(255)
        ,cc_sale_vol              DECIMAL(15, 4)
        ,UNIQUE(account_id)
    )
    ;
    
    INSERT INTO auto_billing_dw.tmp_pc_02(account_id, cc_sale_vol)
    SELECT account_id, MAX(cc_sale_vol) AS max_cc_sale_vol 
      FROM auto_billing_dw.tmp_pc_01
     GROUP BY 1
    ;
    
--     SELECT * FROM auto_billing_dw.tmp_pc_02;
    
    -- account_id        |payconex_acct_id|payconex_acct_name|cc_sale_vol|
    -- ------------------|----------------|------------------|-----------|
    -- 0013i00000FhCBCAA3|                |                  |129985.0700|
       
    UPDATE auto_billing_dw.tmp_pc_02    t2 
      JOIN auto_billing_dw.tmp_pc_01    t1 
        ON t2.account_id = t1.account_id 
       AND t2.cc_sale_vol = t1.cc_sale_vol 
       SET t2.payconex_acct_id = t1.payconex_acct_id 
          ,t2.payconex_acct_name = t1.payconex_acct_name
     WHERE TRUE 
    ;
    
    -- SELECT * FROM auto_billing_dw.tmp_pc_02;
    
    -- account_id        |payconex_acct_id|payconex_acct_name                       |cc_sale_vol|
    -- ------------------|----------------|-----------------------------------------|-----------|
    -- 0013i00000FhCBCAA3|120615298901    |UCIMC Gavin Herbert Eye Institute GHEI OR|129985.0700|
    
    UPDATE auto_billing_dw.tmp_pc_01   t1 
      JOIN auto_billing_dw.tmp_pc_02   t2 
        ON t1.account_id = t2.account_id 
       SET t1.payconex_acct_id = t2.payconex_acct_id 
          ,t1.payconex_acct_name = t2.payconex_acct_name 
     WHERE TRUE 
    ;
    
    -- SELECT * FROM auto_billing_dw.tmp_pc_01;
    
    -- account_id        |payconex_acct_id|payconex_acct_name                       |cc_sale_vol|
    -- ------------------|----------------|-----------------------------------------|-----------|
    -- 0013i00000FhCBCAA3|120615298901    |UCIMC Gavin Herbert Eye Institute GHEI OR|     0.0000|
    -- 0013i00000FhCBCAA3|120615298901    |UCIMC Gavin Herbert Eye Institute GHEI OR| 92873.3300|
    -- 0013i00000FhCBCAA3|120615298901    |UCIMC Gavin Herbert Eye Institute GHEI OR|129985.0700|
    
    UPDATE auto_billing_dw.f_auto_billing_complete_2    abc
      JOIN auto_billing_dw.tmp_pc_01                    t01 
        ON abc.account_id = t01.account_id 
       SET abc.payconex_acct_id = t01.payconex_acct_id 
          ,abc.payconex_acct_name = t01.payconex_acct_name
     WHERE TRUE 
    ;
    
    -- SELECT account_id, payconex, payconex_acct_id , payconex_acct_ids , payconex_acct_name FROM auto_billing_dw.f_auto_billing_complete_2 WHERE account_id = '0013i00000FhCBCAA3';
    
    SET SESSION group_concat_max_len = 102400;  -- this is needed in order to prevent a 'MySQL error code 1260 (ER_CUT_VALUE_GROUP_CONCAT): Row %u was cut by GROUP_CONCAT()' error.
    SHOW VARIABLES LIKE 'group_concat_max_len';

    SELECT 'updating auto_billing_dw.f_auto_billing_complete_2' AS message;
    
--     UPDATE auto_billing_dw.f_auto_billing_complete_2      abc 
--       JOIN (
--             SELECT 
--                  account_id             
--                 ,LEFT(GROUP_CONCAT(DISTINCT payconex_acct_id ORDER BY cc_sale_vol DESC SEPARATOR ' | '), 72) AS payconex_acct_ids
--               FROM auto_billing_dw.tmp_pc_01
--              GROUP BY 1  
--              ORDER BY LENGTH(GROUP_CONCAT(payconex_acct_id ORDER BY cc_sale_vol DESC SEPARATOR ' | ')) DESC 
--       ) t1 
--         ON abc.account_id = t1.account_id
--        SET abc.payconex_acct_ids = t1.payconex_acct_ids
--      WHERE TRUE 
--     ;
    
    -- SELECT 
    --      account_id 
    --     ,GROUP_CONCAT(payconex_acct_id ORDER BY cc_sale_vol DESC SEPARATOR ' | ')
    --   FROM auto_billing_dw.tmp_pc_01
    --  GROUP BY 1
    -- ;
    
    -- SELECT * FROM auto_billing_staging.stg_payconex_volume WHERE acct_id = '120615298901';
    

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `f_auto_billing_complete_shieldconex` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `f_auto_billing_complete_shieldconex`()
    COMMENT 'USAGE: f_auto_billing_complete_shieldconex */ Calculates and updates ShieldConex charges and fees. */'
BEGIN

    -- ShieldConex
    
    -- objective:  calculation shieldconex fees
    
    SELECT 'Executing Stored Procedure' AS operation, 'f_auto_billing_complete_shieldconex' AS stored_procedure, CURRENT_TIMESTAMP;
    
    DROP TABLE IF EXISTS auto_billing_staging.tmp_asset;
    
    CREATE TEMPORARY TABLE auto_billing_staging.tmp_asset(
         client_id                      VARCHAR(32) NOT NULL 
        ,cardconex_acct_id              VARCHAR(18) NOT NULL 
        ,shieldconex_monthly_fee        DECIMAL(12, 5) NOT NULL
        ,shieldconex_monthly_minimum    DECIMAL(12, 5) NOT NULL
        ,shieldconex_transaction_fee    DECIMAL(12, 5) NOT NULL
        ,shieldconex_fields_fee         DECIMAL(12, 5) NOT NULL
        ,PRIMARY KEY(client_id)
    );
    
    SELECT 'de-normalizing ShieldConex fees' AS message;
  
    -- Populate the table
    INSERT INTO auto_billing_staging.tmp_asset
    SELECT 
         client_id
        ,cardconex_acct_id
        ,SUM(shieldconex_monthly_fee)         AS shieldconex_monthly_fee
        ,SUM(shieldconex_monthly_minimum)     AS shieldconex_monthly_minimum
        ,SUM(shieldconex_transaction_fee)     AS shieldconex_transaction_fee
        ,SUM(shieldconex_fields_charge)       AS shieldconex_fields_charge
      FROM (
          SELECT 
             cardconex_acct_id 
            ,client_id 
            ,(fee_name = 'shieldconex_monthly_fee'    ) * fee_amount AS shieldconex_monthly_fee
            ,(fee_name = 'shieldconex_monthly_minimum') * fee_amount AS shieldconex_monthly_minimum
            ,(fee_name = 'shieldconex_transaction_fee') * fee_amount AS shieldconex_transaction_fee
            ,(fee_name = 'shieldconex_fields_fee'  )    * fee_amount AS shieldconex_fields_charge
          FROM (
                SELECT 
                    asst.accountid                        AS cardconex_acct_id
                   ,COALESCE(idn.name, 'undefined')       AS client_id
                   ,fm.fee                                AS fee_name
                   ,COALESCE(asst.fee_amount__c, 0.00000) AS fee_amount
                  FROM sales_force.asset                  asst 
                  JOIN sales_force.fee_map                fm 
                    ON asst.fee_name__c = fm.fee_name
                  JOIN sales_force.identification_number__c   idn 
                    ON asst.accountid = idn.accountid__c 
                 WHERE fm.fee IN (
                        'shieldconex_monthly_fee'   
                       ,'shieldconex_monthly_minimum'
                       ,'shieldconex_transaction_fee'
                       ,'shieldconex_fields_fee')
          ) t1 
      ) t2 
     GROUP BY 1, 2
     ORDER BY 1, 2
    ; 
    
    SELECT * FROM auto_billing_staging.tmp_asset;
    
    -- Sample Output
    -- client_id|cardconex_acct_id |shieldconex_monthly_fee|shieldconex_monthly_minimum|shieldconex_transaction_fee|shieldconex_fields_charge|
    -- ---------|------------------|-----------------------|---------------------------|---------------------------|-------------------------|
    -- 20       |0013i00000IsUq7AAF|                0.00000|                  250.00000|                    0.02100|                  0.00000|
    -- 33       |0013i00000QqgelAAB|                0.00000|                 5000.00000|                    0.00175|                  0.00000|
    
    
    -- SELECT
    --      acct.name
    --     ,asst.*
    --   FROM auto_billing_staging.tmp_asset   asst
    --   JOIN sales_force.account              acct
    --     ON asst.cardconex_acct_id = acct.id
    --  ORDER BY 1 * client_id
    -- ;
    
    -- name                         |client_id|cardconex_acct_id |shieldconex_monthly_fee|shieldconex_monthly_minimum|shieldconex_transaction_fee|shieldconex_fields_fee|
    -- -----------------------------|---------|------------------|-----------------------|---------------------------|---------------------------|----------------------|
    -- Alaska Airlines - ShieldConex|20       |0013i00000IsUq7AAF|                0.00000|                  250.00000|                    0.02100|               0.00000|
    -- PAAY LLC                     |33       |0013i00000QqgelAAB|                0.00000|                 5000.00000|                    0.00175|               0.00000|
    
    
    -- All numeric columns:  INT UNSIGNED NOT NULL DEFAULT 0; no need for COALESCE function this time.
    
    SELECT 'populating temporary table 1' AS message;
  
    DROP TABLE IF EXISTS auto_billing_staging.tmp_shieldconex;
    
    CREATE TEMPORARY TABLE auto_billing_staging.tmp_shieldconex(
         client_id               VARCHAR(16) NOT NULL
        ,client_name             VARCHAR(64)
        ,partner_name            VARCHAR(64)
        ,total_bad_tokenized     INT UNSIGNED NOT NULL
        ,total_good_detokenized  INT UNSIGNED NOT NULL
        ,total_good_tokenized    INT UNSIGNED NOT NULL
        ,total_bad_detokenized   INT UNSIGNED NOT NULL 
        ,good_tokenized_fields   INT UNSIGNED NOT NULL
        ,bad_tokenized_fields    INT UNSIGNED NOT NULL
        ,good_detokenized_fields INT UNSIGNED NOT NULL
        ,bad_detokenized_fields  INT UNSIGNED NOT NULL
        ,PRIMARY KEY(client_id)
    );
    
    INSERT INTO auto_billing_staging.tmp_shieldconex
    SELECT 
        client_id 
       ,client_name 
       ,partner_name
       ,total_bad_tokenized 
       ,total_good_detokenized 
       ,total_good_tokenized     
       ,total_bad_detokenized
       ,good_tokenized_fields 
       ,bad_tokenized_fields 
       ,good_detokenized_fields 
       ,bad_detokenized_fields 
      FROM auto_billing_staging.stg_shieldconex
     WHERE complete_date = DATE_FORMAT(CURRENT_DATE - INTERVAL 1 MONTH, '%Y%m01')
       AND client_name NOT LIKE 'client_name%'
    ;
    
    -- SELECT * FROM auto_billing_staging.tmp_shieldconex;
    
    -- client_id|client_name    |partner_name   |total_bad_tokenized|total_good_detokenized|total_good_tokenized|total_bad_detokenized|good_tokenized_fields|bad_tokenized_fields|good_detokenized_fields|bad_detokenized_fields|
    -- ---------|---------------|---------------|-------------------|----------------------|--------------------|---------------------|---------------------|--------------------|-----------------------|----------------------|
    -- 20       |Contact Centers|Alaska Airlines|                 61|                   132|                 132|                    0|                  528|                 244|                    528|                     0|
    -- 33       |Paay           |Paay LLC       |                 18|                413372|              860487|                    7|               860487|                  18|                 413372|                     7|
    
    
    -- identify client_id's which exist in sales_force.asset or auto_billing_staging.stg_shieldconex BUT NOT BOTH.
    -- get a 'master list' of client_id's to start.
    
  
    DROP TABLE IF EXISTS auto_billing_staging.tmp_client_id;
    
    CREATE TEMPORARY TABLE auto_billing_staging.tmp_client_id SELECT client_id FROM auto_billing_staging.tmp_asset UNION SELECT client_id FROM auto_billing_staging.tmp_shieldconex;
    
    -- SELECT * FROM auto_billing_staging.tmp_client_id;
    
    -- show a list of client_id's are missing data in one or more tables
    SELECT 
         COALESCE(acct.name, 'NULL')                    AS account_name
        ,sc.partner_name
        ,t1.client_id                                   AS client_id
        ,IF(sc.client_id IS NULL, 'missing', 'ok')      AS stg_shieldconex
        ,IF(asst.client_id IS NULL, 'missing', 'ok')    AS asset 
        ,IF(idn.name IS NOT NULL, 'ok', 'missing')      AS identification_number__c
        ,idn.type__c                                    AS identification_number_type__c
      FROM auto_billing_staging.tmp_client_id           t1 
      LEFT JOIN auto_billing_staging.tmp_asset          asst
        ON t1.client_id = asst.client_id
      LEFT JOIN sales_force.identification_number__c    idn 
        ON t1.client_id = idn.name
      LEFT JOIN sales_force.account                     acct 
        ON idn.accountid__c = acct.id
      LEFT JOIN auto_billing_staging.tmp_shieldconex    sc 
        ON t1.client_id = sc.client_id
     WHERE idn.type__c = 'ShieldConex'
        OR idn.type__c IS NULL
     ORDER BY acct.name IS NULL, acct.name, 1 * t1.client_id
    ;
    
    SELECT 'populating temporary table 2' AS message;
  
    DROP TABLE IF EXISTS auto_billing_staging.tmp_calc_shieldconex_charges;
    
    CREATE TABLE auto_billing_staging.tmp_calc_shieldconex_charges(
       client_id                           VARCHAR(32)   NOT NULL,
       cardconex_acct_id                   VARCHAR(18)   NOT NULL,
       client_name                         VARCHAR(64)   DEFAULT NULL,
       shieldconex_monthly_fee             DECIMAL(10,5) NOT NULL,
       shieldconex_monthly_minimum         DECIMAL(10,5) NOT NULL,
       shieldconex_transaction_fee         DECIMAL(10,5) NOT NULL,
       shieldconex_fields_fee              DECIMAL(10,5) NOT NULL,
       total_bad_tokenized                 INT UNSIGNED  NOT NULL,
       total_good_detokenized              INT UNSIGNED  NOT NULL,
       total_good_tokenized                INT UNSIGNED  NOT NULL,
       total_bad_detokenized               INT UNSIGNED  NOT NULL,
       good_tokenized_fields               INT UNSIGNED  NOT NULL,
       bad_tokenized_fields                INT UNSIGNED  NOT NULL,
       good_detokenized_fields             INT UNSIGNED  NOT NULL,
       bad_detokenized_fields              INT UNSIGNED  NOT NULL,
       shieldconex_monthly_charge          DECIMAL(10,5) NOT NULL DEFAULT 0.00000,
       shieldconex_transaction_charge      DECIMAL(10,5) NOT NULL DEFAULT 0.00000,
       shieldconex_monthly_minimum_charge  DECIMAL(10,5) NOT NULL DEFAULT 0.00000,
       shieldconex_fields_charge           DECIMAL(10,5) NOT NULL DEFAULT 0.00000,
       PRIMARY KEY(client_id),
       UNIQUE(cardconex_acct_id)
    )
    ;
    
    -- DESC auto_billing_staging.tmp_calc_shieldconex_charges;
    
    INSERT INTO auto_billing_staging.tmp_calc_shieldconex_charges
    SELECT 
         asst.client_id 
        ,asst.cardconex_acct_id 
        ,sc.client_name
        ,asst.shieldconex_monthly_fee
        ,asst.shieldconex_monthly_minimum
        ,asst.shieldconex_transaction_fee
        ,asst.shieldconex_fields_fee
        ,sc.total_bad_tokenized    
        ,sc.total_good_detokenized 
        ,sc.total_good_tokenized   
        ,sc.total_bad_detokenized  
        ,sc.good_tokenized_fields  
        ,sc.bad_tokenized_fields   
        ,sc.good_detokenized_fields
        ,sc.bad_detokenized_fields 
        ,0.00000 AS shieldconex_monthly_charge
        ,0.00000 AS shieldconex_transaction_charge
        ,0.00000 AS shieldconex_monthly_minimum_charge
        ,0.00000 AS shieldconex_fields_charge
      FROM auto_billing_staging.tmp_asset                asst 
      LEFT JOIN auto_billing_staging.tmp_shieldconex     sc
        ON asst.client_id = sc.client_id 
    ;
    
    SELECT 'calculating stage 1' AS message;
  
    UPDATE auto_billing_staging.tmp_calc_shieldconex_charges
       SET shieldconex_monthly_charge = auto_billing_dw.calc_shieldconex_monthly_charge(shieldconex_monthly_fee) 
     WHERE TRUE
    ;
    
    SELECT 'calculating stage 2' AS message;
    
    UPDATE auto_billing_staging.tmp_calc_shieldconex_charges
       SET shieldconex_transaction_charge     = auto_billing_dw.calc_shieldconex_transaction_charge(
              total_good_tokenized 
             ,total_bad_tokenized 
             ,total_good_detokenized
             ,total_bad_detokenized 
             ,shieldconex_monthly_minimum
             ,shieldconex_transaction_fee)    
     WHERE TRUE
    ;

    SELECT 'calculating stage 3' AS message;
  
    UPDATE auto_billing_staging.tmp_calc_shieldconex_charges
       SET shieldconex_monthly_minimum_charge = auto_billing_dw.calc_shieldconex_monthly_minimum_charge(
              shieldconex_transaction_charge
             ,shieldconex_monthly_minimum)
     WHERE TRUE 
    ;

    SELECT 'calculating stage 4' AS message;
    
    UPDATE auto_billing_staging.tmp_calc_shieldconex_charges
       SET shieldconex_fields_charge = auto_billing_dw.calc_shieldconex_fields_charge(
            good_tokenized_fields 
           ,bad_tokenized_fields 
           ,good_detokenized_fields 
           ,bad_detokenized_fields 
           ,shieldconex_monthly_minimum 
           ,shieldconex_fields_fee)
     WHERE TRUE 
    ;
    
    
--     SELECT * FROM auto_billing_staging.tmp_calc_shieldconex_charges;
    -- client_id|cardconex_acct_id |client_name    |shieldconex_monthly_fee|shieldconex_monthly_minimum|shieldconex_transaction_fee|shieldconex_fields_fee|total_bad_tokenized|total_good_detokenized|total_good_tokenized|total_bad_detokenized|good_tokenized_fields|bad_tokenized_fields|good_detokenized_fields|bad_detokenized_fields|shieldconex_monthly_charge|shieldconex_transaction_charge|shieldconex_monthly_minimum_charge|shieldconex_fields_charge|
    -- ---------|------------------|---------------|-----------------------|---------------------------|---------------------------|----------------------|-------------------|----------------------|--------------------|---------------------|---------------------|--------------------|-----------------------|----------------------|--------------------------|------------------------------|----------------------------------|-------------------------|
    -- 20       |0013i00000IsUq7AAF|Contact Centers|                0.00000|                  250.00000|                    0.02100|               0.00000|                 61|                   132|                 132|                    0|                  528|                 244|                    528|                     0|                   0.00000|                       0.00000|                         250.00000|                  0.00000|
    -- 33       |0013i00000QqgelAAB|Paay           |                0.00000|                 5000.00000|                    0.00175|               0.00000|                 18|                413372|              860487|                    7|               860487|                  18|                 413372|                     7|                   0.00000|                       0.00000|                        5000.00000|                  0.00000|
    
    SELECT 'updating auto_billing_dw.f_auto_billing_complete_2' AS message; 
      
    INSERT INTO auto_billing_dw.f_auto_billing_complete_2 (
         decryptx 
        ,payconex 
        ,shieldconex
        ,bill_to_id
        ,bill_to_name
        ,collection_method
        ,start_date
        ,vintage_v2
        ,hold_bill
        ,segment_intacct
--         ,id
        ,segment_now
        ,org_now
        ,chain_now
        ,industry_now
        ,dba_name
        ,year_mon
        ,account_id
        ,account_name
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
        ,user_count
        ,group_count
        ,cc_auth_trans
        ,cc_auth_vol
        ,cc_sale_trans
        ,cc_sale_vol
        ,cc_ref_trans
        ,cc_ref_vol
        ,cc_credit_trans
        ,cc_credit_vol
        ,cc_sale_decline_trans
        ,cc_auth_decline_trans
        ,cc_batches
        ,cc_keyed_trans
        ,cc_keyed_vol
        ,cc_swiped_trans
        ,cc_swiped_vol
        ,ach_sale_trans
        ,ach_sale_vol
        ,ach_credit_trans
        ,ach_credit_vol
        ,ach_batches
        ,ach_returns
        ,ach_errors
        ,ach_noc_messages
        ,p2pe_auth_trans
        ,p2pe_auth_vol
        ,p2pe_sale_trans
        ,p2pe_sale_vol
        ,p2pe_refund_trans
        ,p2pe_refund_vol
        ,p2pe_credit_trans
        ,p2pe_credit_vol
        ,p2pe_sale_decline_trans
        ,p2pe_auth_decline_trans
        ,p2pe_active_device_trans
        ,p2pe_inactive_device_trans
        ,tokens_stored
        ,batch_files_processed
        ,cc_capture_trans
        ,cc_capture_vol 
        ,p2pe_capture_trans
        ,p2pe_capture_vol
        ,combined_decline_trans
        ,p2pe_declined_trans
        ,p2pe_tokens_stored
        ,reissued_cc_transactions
        ,reissued_ach_transactions
    ) 
    SELECT 
         0
        ,0
        ,1
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
--         ,NULL  -- id
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,DATE_FORMAT(CURRENT_DATE, '%Y%m')
        ,cardconex_acct_id
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,0
        ,0
        ,shieldconex_monthly_charge
        ,shieldconex_transaction_charge
        ,shieldconex_monthly_minimum_charge
        ,shieldconex_fields_charge
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,shieldconex_monthly_fee
        ,shieldconex_transaction_fee
        ,shieldconex_fields_fee
        ,shieldconex_monthly_minimum
        ,total_good_tokenized
        ,total_bad_tokenized
        ,total_good_detokenized
        ,total_bad_detokenized
        ,good_tokenized_fields
        ,bad_tokenized_fields
        ,good_detokenized_fields
        ,bad_detokenized_fields
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
    FROM auto_billing_staging.tmp_calc_shieldconex_charges
    ;
  
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `show_row_counts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `show_row_counts`()
BEGIN
  
SELECT 'calculating row counts...' AS message;
DROP TABLE IF EXISTS tmp_01;

CREATE TEMPORARY TABLE tmp_01
        SELECT 'auto_billing_dw' AS db, 'd_merchant' AS table_name
  UNION SELECT 'auto_billing_dw' AS db, 'd_pricing' AS table_name
  UNION SELECT 'auto_billing_dw' AS db, 'd_processor' AS table_name
  UNION SELECT 'auto_billing_staging' AS db, 'decryptx_device_day' AS table_name
  UNION SELECT 'auto_billing_dw' AS db, 'f_auto_billing_complete' AS table_name
  UNION SELECT 'auto_billing_dw' AS db, 'f_billing_month' AS table_name
  UNION SELECT 'auto_billing_dw' AS db, 'f_decryptx_day' AS table_name
  UNION SELECT 'auto_billing_dw' AS db, 'f_payconex_day' AS table_name
  UNION SELECT 'auto_billing_staging' AS db, 'payconex_volume_day' AS table_name
  UNION SELECT 'auto_billing_staging' AS db, 'stg_cardconex_account' AS table_name
  UNION SELECT 'auto_billing_staging' AS db, 'stg_decryptx_cardconex_map' AS table_name
  UNION SELECT 'auto_billing_staging' AS db, 'stg_decryptx_device_cardconex_map' AS table_name
  UNION SELECT 'auto_billing_staging' AS db, 'stg_device_detail' AS table_name
  UNION SELECT 'auto_billing_staging' AS db, 'stg_payconex_cardconex_map' AS table_name
  UNION SELECT 'auto_billing_staging' AS db, 'stg_payconex_volume' AS table_name
;

DROP TABLE IF EXISTS tmp_02;

CREATE TEMPORARY TABLE tmp_02 
        SELECT 'auto_billing_dw' AS db, 'd_merchant' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_dw.d_merchant GROUP BY 1, 2
  UNION SELECT 'auto_billing_dw' AS db, 'd_pricing' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_dw.d_pricing GROUP BY 1, 2
  UNION SELECT 'auto_billing_dw' AS db, 'd_processor' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_dw.d_processor GROUP BY 1, 2
  UNION SELECT 'auto_billing_staging' AS db, 'decryptx_device_day' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_staging.decryptx_device_day GROUP BY 1, 2
  UNION SELECT 'auto_billing_dw' AS db, 'f_auto_billing_complete' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_dw.f_auto_billing_complete GROUP BY 1, 2
  UNION SELECT 'auto_billing_dw' AS db, 'f_billing_month' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_dw.f_billing_month GROUP BY 1, 2
  UNION SELECT 'auto_billing_dw' AS db, 'f_decryptx_day' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_dw.f_decryptx_day GROUP BY 1, 2
  UNION SELECT 'auto_billing_dw' AS db, 'f_payconex_day' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_dw.f_payconex_day GROUP BY 1, 2
  UNION SELECT 'auto_billing_staging' AS db, 'payconex_volume_day' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_staging.payconex_volume_day GROUP BY 1, 2
  UNION SELECT 'auto_billing_staging' AS db, 'stg_cardconex_account' AS table_name, min(import_timestamp) AS min_date_updated, max(import_timestamp) AS max_date_updated, count(*) AS num_rows FROM auto_billing_staging.stg_cardconex_account GROUP BY 1, 2
  UNION SELECT 'auto_billing_staging' AS db, 'stg_decryptx_cardconex_map' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_staging.stg_decryptx_cardconex_map GROUP BY 1, 2
  UNION SELECT 'auto_billing_staging' AS db, 'stg_decryptx_device_cardconex_map' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_staging.stg_decryptx_device_cardconex_map GROUP BY 1, 2
  UNION SELECT 'auto_billing_staging' AS db, 'stg_device_detail' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_staging.stg_device_detail GROUP BY 1, 2
  UNION SELECT 'auto_billing_staging' AS db, 'stg_payconex_cardconex_map' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_staging.stg_payconex_cardconex_map GROUP BY 1, 2
  UNION SELECT 'auto_billing_staging' AS db, 'stg_payconex_volume' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_staging.stg_payconex_volume GROUP BY 1, 2
    ;

DROP TABLE IF EXISTS tmp_03_row_counts;

CREATE TEMPORARY TABLE tmp_03_row_counts
SELECT 
     tmp_01.db
    ,tmp_01.table_name
    ,tmp_02.min_date_updated 
    ,tmp_02.max_date_updated
    ,dba.eng(tmp_02.num_rows) AS approx_no_rows
  FROM tmp_01
  LEFT JOIN tmp_02 
    ON tmp_01.db = tmp_02.db 
   AND tmp_01.table_name = tmp_02.table_name
 ORDER BY 4, 1, 2
;

ALTER TABLE tmp_03_row_counts ADD COLUMN notes VARCHAR (32);

UPDATE tmp_03_row_counts SET notes = 'recent updated not required' WHERE table_name = 'd_processor';
UPDATE tmp_03_row_counts SET notes = 'recent update required' WHERE table_name != 'd_processor';

SELECT * FROM tmp_03_row_counts ORDER BY 4, 1, 2 DESC, 2;

DROP TABLE IF EXISTS tmp_01;
DROP TABLE IF EXISTS tmp_02;

SELECT 'query auto_billing_dw.tmp_03_row_counts for more information' AS message;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_billing_demographics` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `update_billing_demographics`()
    COMMENT 'USAGE:  update_billing_demographics */ Updates several demographic columns. */'
BEGIN
  
    SELECT 'auto_billing_dw.update_billing_demographics() is updating f_auto_billing_complete_shieldconex and f_auto_billing_complete_2' AS message;
  
    UPDATE auto_billing_dw.f_auto_billing_complete_shieldconex    abc
      JOIN sales_force.account                                    acct 
        ON abc.bill_to_id = acct.id 
       SET abc.bill_to_name = acct.name
     WHERE TRUE 
    ;
  
    UPDATE auto_billing_dw.f_auto_billing_complete_2              abc
      JOIN sales_force.account                                    acct 
        ON abc.bill_to_id = acct.id 
       SET abc.bill_to_name = acct.name
     WHERE TRUE 
    ;
  
    -- add some demographic information; these are the new columns Jonathan requested that we not added initially.
    
    UPDATE auto_billing_dw.f_auto_billing_complete_shieldconex    abc
      JOIN sales_force.account                            acct 
        ON abc.cardconex_acct_id = acct.id
       SET abc.collection_method = acct.collection_method__c 
          ,abc.start_date = 19700101    -- sales_force.bluefin_contract_start date; this column is not in the warehouse.
          ,abc.vintage_v2 = 'need column definition'
          ,abc.hold_bill  = acct.hold_billing__c
          ,abc.segment_intacct = 'need column definition' 
     WHERE TRUE 
    ;  
      
    UPDATE auto_billing_dw.f_auto_billing_complete_2      abc
      JOIN sales_force.account                            acct 
        ON abc.account_id = acct.id
       SET abc.collection_method = acct.collection_method__c 
          ,abc.start_date = 19700101    -- sales_force.bluefin_contract_start date; this column is not in the warehouse.
          ,abc.vintage_v2 = 'need column definition'
          ,abc.hold_bill  = acct.hold_billing__c
          ,abc.segment_intacct = 'need column definition' 
     WHERE TRUE 
    ;  
  
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_billing_frequency` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`tsanders`@`172.16.63.%` PROCEDURE `update_billing_frequency`()
BEGIN

  DECLARE n_annually  int UNSIGNED DEFAULT 0;
  DECLARE n_monthly   int UNSIGNED DEFAULT 0;
  DECLARE n_unknown   int UNSIGNED DEFAULT 0;
  DECLARE n_other     int UNSIGNED DEFAULT 0;

  DROP TABLE IF EXISTS tmp_billing_frequency;

  CREATE TEMPORARY TABLE tmp_billing_frequency 
  SELECT `x`.`table_name` AS `table_name`, SUM((IF((`x`.`billing_frequency` = 'Monthly'), 1, 0) * `x`.`num_records`)) AS `num_monthly`, SUM((IF((`x`.`billing_frequency` = 'Annually'), 1, 0) * `x`.`num_records`)) AS `num_annually`, SUM((IF((`x`.`billing_frequency` = 'Unknown'), 1, 0) * `x`.`num_records`)) AS `num_unknown`, SUM((IF(isnull(`x`.`billing_frequency`), 1, 0) * `x`.`num_records`)) AS `num_other`
  FROM (SELECT 'd_merchant' AS `table_name`, IF((LENGTH(`auto_billing_dw`.`d_merchant`.`billing_frequency`) = 0), NULL, `auto_billing_dw`.`d_merchant`.`billing_frequency`) AS `billing_frequency`, COUNT(0) AS `num_records`
  FROM `auto_billing_dw`.`d_merchant`
  GROUP BY 'd_merchant', IF((LENGTH(`auto_billing_dw`.`d_merchant`.`billing_frequency`) = 0), NULL, `auto_billing_dw`.`d_merchant`.`billing_frequency`)
  UNION SELECT 'stg_cardconex_account' AS `table_name`, `auto_billing_staging`.`stg_cardconex_account`.`billing_frequency` AS `stg_billing_frequency`, COUNT(0) AS `COUNT(*)`
  FROM `auto_billing_staging`.`stg_cardconex_account`
  GROUP BY `auto_billing_staging`.`stg_cardconex_account`.`billing_frequency`) `x`
  GROUP BY `x`.`table_name`;

  SELECT 'most rows should appear in the num_monthly column...' AS message;

  SELECT * FROM tmp_billing_frequency;

  SELECT num_monthly  FROM tmp_billing_frequency WHERE table_name = 'd_merchant' INTO n_monthly;
  SELECT num_annually FROM tmp_billing_frequency WHERE table_name = 'd_merchant' INTO n_annually; 
  SELECT num_unknown  FROM tmp_billing_frequency WHERE table_name = 'd_merchant' INTO n_unknown;
  SELECT num_other    FROM tmp_billing_frequency WHERE table_name = 'd_merchant' INTO n_other;

  -- SELECT n_monthly, n_annually, n_unknown, n_other, n_annually < n_monthly + n_unknown + n_other AS message;
  
  IF n_monthly < n_annually + n_unknown + n_other THEN 
     SELECT 'update needed...' AS message;
   
     SELECT 'updating billing frequency...' AS message;
    
     UPDATE auto_billing_dw.d_merchant m
     JOIN auto_billing_staging.stg_cardconex_account ca
     ON m.cardconex_acct_id = ca.acct_id
     SET m.billing_frequency = ca.billing_frequency;
   
     SELECT 'after update...' AS message;
   
     SELECT `x`.`table_name` AS `table_name`, SUM((IF((`x`.`billing_frequency` = 'Monthly'), 1, 0) * `x`.`num_records`)) AS `num_monthly`, SUM((IF((`x`.`billing_frequency` = 'Annually'), 1, 0) * `x`.`num_records`)) AS `num_annually`, SUM((IF((`x`.`billing_frequency` = 'Unknown'), 1, 0) * `x`.`num_records`)) AS `num_unknown`, SUM((IF(isnull(`x`.`billing_frequency`), 1, 0) * `x`.`num_records`)) AS `num_other`
     FROM (SELECT 'd_merchant' AS `table_name`, IF((LENGTH(`auto_billing_dw`.`d_merchant`.`billing_frequency`) = 0), NULL, `auto_billing_dw`.`d_merchant`.`billing_frequency`) AS `billing_frequency`, COUNT(0) AS `num_records`
     FROM `auto_billing_dw`.`d_merchant`
     GROUP BY 'd_merchant', IF((LENGTH(`auto_billing_dw`.`d_merchant`.`billing_frequency`) = 0), NULL, `auto_billing_dw`.`d_merchant`.`billing_frequency`)
     UNION SELECT 'stg_cardconex_account' AS `table_name`, `auto_billing_staging`.`stg_cardconex_account`.`billing_frequency` AS `stg_billing_frequency`, COUNT(0) AS `COUNT(*)`
     FROM `auto_billing_staging`.`stg_cardconex_account`
     GROUP BY `auto_billing_staging`.`stg_cardconex_account`.`billing_frequency`) `x`
     GROUP BY `x`.`table_name`;

  ELSE 
     SELECT 'no update required' AS message;
  END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_bill_to_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `update_bill_to_id`()
    COMMENT 'USAGE:  update_bill_to_id */ Calculates and populates bill_to_id. */'
BEGIN

    /*
    
        Purpose:  Calculate the bill_to_id.
        
        Note the following:
    
        MariaDB [sales_force]> SELECT billing_preference__c, COUNT(*) FROM sales_force.account GROUP BY 1;
        +-----------------------+----------+
        | billing_preference__c | COUNT(*) |
        +-----------------------+----------+
        | NULL                  |    21702 |
        | Aggregated Billing    |     4235 |
        | Client Level Only     |       42 |
        | Direct Billing        |     9687 |
        | Processor Only        |    30928 |
        +-----------------------+----------+
        5 rows in set (3.38 sec)
    
        Rows in sales_force.account for which billing_preference__c != 'Aggregated' are billed directly.
        
        Rows in sales_force.account for which billing_preference__c = 'Aggregated' are billed to a parent account, based on the value of account.parentid.
        It may be be necessary to traverse multiple 'levels' to find the parent.
        
        See the simulated data below; the calculated value of bill_to_id is shown.
        
        cardconex_acct_id|parent_id|billing_preference|bill_to_id|
        -----------------|---------|------------------|----------|
        a                |*        |Client Level Only |a         |   -- case 1
        
        b                |c        |Aggregated Billing|c         |   -- case 2
        c                |*        |Direct Billing    |c         |
        
        e                |f        |Aggregated Billing|g         |   -- case 3
        f                |g        |Aggregated Billing|g         |
        g                |*        |Processor Only    |g         |
        
        i                |j        |Aggregated Billing|l         |   -- case 4
        j                |k        |Aggregated Billing|l         |
        k                |l        |Aggregated Billing|l         |
        l                |*        |Processor Only    |l         |
        
        n                |o        |Aggregated Billing|r         |   -- case 5
        o                |p        |Aggregated Billing|r         |
        p                |q        |Aggregated Billing|r         |
        q                |r        |Aggregated Billing|r         |
        r                |*        |Processor Only    |r         |
        
        t                |u        |Aggregated Billing|y         |   -- case 6
        u                |v        |Aggregated Billing|y         |
        v                |w        |Aggregated Billing|y         |
        w                |x        |Aggregated Billing|y         |
        x                |y        |Aggregated Billing|y         |
        y                |*        |Processor Only    |y         |
        
        Case 1 (One Level)
        ------------------
        Since billing_preference != 'Aggregated Billing, the account is billed directly; i.e, bill_to_id = cardconex_acct_id
        
        Case 2 (Two Levels)
        -------------------
        billing_preference = 'Aggregated Billing', so this account is not billed directly.
     
        Consider the following:
        
        cardconex_acct_id|parent_id|billing_preference|
        -----------------|---------|------------------|
        b                |c        |Aggregated Billing|
        c                |*        |Direct Billing    |
        
        We need to calculate the bill_to_id for cardconex_acct_id = 'b'.
        billing_preference = 'Aggregated Billing', so we have the find the parent.
        
        In this case, the parent_id = 'c'.  The value of billing_preference for cardconex_acct_id = 'c' = 'Direct Billing', so 'c' is the parent.
        Therefore, the bill_to_id for cardconex_acct_id IN ('b', 'c') = 'Direct Billing.
        
        Cases 3, 4, 5, ... (Three Or More Levels)
        -----------------------------------------
        These are variations for Case 2, with an increasing number of levels.
        See the desired output in the table above for each of these cases.   
    
    */
    
    DECLARE i           TINYINT UNSIGNED;
    DECLARE num_levels  TINYINT UNSIGNED DEFAULT 4;   -- number of times to repeat the loop for cases 3-6

    SELECT 'Executing Stored Procedure' AS operation, 'update_bill_to_id' AS stored_procedure, CURRENT_TIMESTAMP;
    
    -- Case 1
    
    SET @ab = 'Aggregated Billing';
    
    DROP TABLE IF EXISTS tmp_01;
    
    CREATE TEMPORARY TABLE tmp_01(
        cardconex_acct_id     VARCHAR(32)
       ,parent_id             VARCHAR(32)
       ,billing_preference    VARCHAR(32)
       ,bill_to_id            VARCHAR(32)
       ,PRIMARY KEY(cardconex_acct_id)
       ,KEY idx_parent_id(parent_id)
    );
    

    -- NULL values of billing_preference__c should be interpreted as 'Direct Billing'.  
    -- This is not currently configured in the database or in the warehouse, so it is being done here.
    
    SELECT 'NULL values of sales_force.account.billing_preference__c will be interpreted as \'Direct Billing\'' AS message;
  
    INSERT INTO tmp_01 
    SELECT 
         id                       AS cardconex_acct_id 
        ,parentid                 AS parent_id 
        ,'Direct Billing'         AS billing_preference
        ,NULL                     AS bill_to_id
      FROM sales_force.account 
     WHERE billing_preference__c IS NULL
    ;
  
    INSERT INTO tmp_01 
    SELECT 
         id                       AS cardconex_acct_id 
        ,parentid                 AS parent_id 
        ,billing_preference__c    AS billing_preference
        ,NULL                     AS bill_to_id
      FROM sales_force.account 
     WHERE billing_preference__c != @ab
    ;
    
    UPDATE tmp_01
       SET bill_to_id = cardconex_acct_id
     WHERE TRUE 
    ;  
    
    -- SELECT * FROM tmp_01;
    -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|
    -- --|-----------------|---------|------------------|----------|
    --  1|a                |*        |B                 |a         |
    --  3|c                |*        |C                 |c         |
    --  6|g                |*        |D                 |g         |
    -- 10|l                |*        |E                 |l         |
    -- 15|r                |*        |F                 |r         |
    -- 21|y                |*        |G                 |y         |
    
    -- Case 2
    
    DROP TABLE IF EXISTS tmp_02;
    
    CREATE TEMPORARY TABLE tmp_02 LIKE tmp_01;
    
    INSERT INTO tmp_02
    SELECT 
         id                       AS cardconex_acct_id 
        ,parentid                 AS parent_id 
        ,billing_preference__c    AS billing_preference
        ,NULL                     AS bill_to_id
      FROM sales_force.account 
     WHERE billing_preference__c = @ab
    ;
    
    UPDATE tmp_02     t2 
      JOIN tmp_01     t1 
        ON t2.parent_id = t1.cardconex_acct_id 
       SET t2.bill_to_id = t1.bill_to_id
     WHERE TRUE 
    ;
    
    -- SELECT * FROM tmp_02;
    
    -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|
    -- --|-----------------|---------|------------------|----------|
    --  2|b                |c        |A                 |c         |
    --  4|e                |f        |A                 |          |
    --  5|f                |g        |A                 |g         |
    --  7|i                |j        |A                 |          |
    --  8|j                |k        |A                 |          |
    --  9|k                |l        |A                 |l         |
    -- 11|n                |o        |A                 |          |
    -- 12|o                |p        |A                 |          |
    -- 13|p                |q        |A                 |          |
    -- 14|q                |r        |A                 |r         |
    -- 16|t                |u        |A                 |          |
    -- 17|u                |v        |A                 |          |
    -- 18|v                |w        |A                 |          |
    -- 19|w                |x        |A                 |          |
    -- 20|x                |y        |A                 |y         |
    
    -- SELECT * FROM (
    --          SELECT * FROM tmp_01
    --    UNION SELECT * FROM tmp_02
    --   ) t3
    --  ORDER BY 1
    -- ;
    
    -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|
    -- --|-----------------|---------|------------------|----------|
    --  1|a                |*        |B                 |a         |
    --  2|b                |c        |A                 |c         |
    --  3|c                |*        |C                 |c         |
    --  4|e                |f        |A                 |          |
    --  5|f                |g        |A                 |g         |
    --  6|g                |*        |D                 |g         |
    --  7|i                |j        |A                 |          |
    --  8|j                |k        |A                 |          |
    --  9|k                |l        |A                 |l         |
    -- 10|l                |*        |E                 |l         |
    -- 11|n                |o        |A                 |          |
    -- 12|o                |p        |A                 |          |
    -- 13|p                |q        |A                 |          |
    -- 14|q                |r        |A                 |r         |
    -- 15|r                |*        |F                 |r         |
    -- 16|t                |u        |A                 |          |
    -- 17|u                |v        |A                 |          |
    -- 18|v                |w        |A                 |          |
    -- 19|w                |x        |A                 |          |
    -- 20|x                |y        |A                 |y         |
    -- 21|y                |*        |G                 |y         |
    
    
    
    -- Case 3
    
    /*  
    
        I need to join a self join on tmp_02 to proceed.  
        But MariaDB apparently does not support that; see the following:
        
        SELECT a.*, b.*
          FROM tmp_02   a 
          JOIN tmp_02   b 
            ON a.cardconex_acct_id = b.cardconex_acct_id;
        SQL Error [1137] [HY000]: Can't reopen table: 'a'
        
        I will therefore have to create two copies of the same table and join those instead.
        
        It so happens that the code for Case 3 also workds for Case 4, 5, 6, ...
        
        So we can put that code in a loop.
        
        Finance has advised that four loops is enough.
    
    */
    
    SET i = 0;
    
    REPEAT
        DROP TABLE IF EXISTS tmp_03;
        DROP TABLE IF EXISTS tmp_04;
        CREATE TEMPORARY TABLE tmp_03 SELECT * FROM tmp_02;
        CREATE TEMPORARY TABLE tmp_04 SELECT * FROM tmp_02;
        
        -- SELECT 
        --      t3.cardconex_acct_id AS t3_cardconex_acct_id 
        --     ,t3.parent_id         AS t3_parent_id 
        --     ,t4.cardconex_acct_id AS t3_cardconex_acct_id 
        --     ,t4.parent_id         AS t4_parent_id
        --     ,t4.bill_to_id
        --   FROM tmp_03   t3
        --   JOIN tmp_04   t4 
        --     ON t3.parent_id = t4.cardconex_acct_id
        --  WHERE t4.bill_to_id IS NOT NULL;
         
        -- t3_cardconex_acct_id|t3_parent_id|t3_cardconex_acct_id|t4_parent_id|bill_to_id|
        -- --------------------|------------|--------------------|------------|----------|
        -- e                   |f           |f                   |g           |g         |
        -- j                   |k           |k                   |l           |l         |
        -- p                   |q           |q                   |r           |r         |
        -- w                   |x           |x                   |y           |y         |
        
        -- SELECT * FROM tmp_02 WHERE bill_to_id IS NULL;
        
        -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|
        -- --|-----------------|---------|------------------|----------|
        --  4|e                |f        |A                 |          |
        --  7|i                |j        |A                 |          |
        --  8|j                |k        |A                 |          |
        -- 11|n                |o        |A                 |          |
        -- 12|o                |p        |A                 |          |
        -- 13|p                |q        |A                 |          |
        -- 16|t                |u        |A                 |          |
        -- 17|u                |v        |A                 |          |
        -- 18|v                |w        |A                 |          |
        -- 19|w                |x        |A                 |          |
        
        UPDATE tmp_02    t2 
          JOIN (
            SELECT 
                 t3.cardconex_acct_id AS t3_cardconex_acct_id 
                ,t3.parent_id         AS t3_parent_id 
                ,t4.cardconex_acct_id AS t4_cardconex_acct_id 
                ,t4.parent_id         AS t4_parent_id
                ,t4.bill_to_id
              FROM tmp_03   t3
              JOIN tmp_04   t4 
                ON t3.parent_id = t4.cardconex_acct_id
             WHERE t4.bill_to_id IS NOT NULL   
          ) t3 
            ON t2.cardconex_acct_id = t3.t3_cardconex_acct_id 
           SET t2.bill_to_id = t3.bill_to_id 
         WHERE TRUE 
        ;
      
        SET i = i + 1;
        
        -- SELECT * FROM (
        --          SELECT * FROM tmp_01
        --    UNION SELECT * FROM tmp_02
        --   ) t3
        --  ORDER BY 1
        -- ;
        
        -- id|cardconex_acct_id|parent_id|billing_preference|bill_to_id|
        -- --|-----------------|---------|------------------|----------|
        --  1|a                |*        |B                 |a         |
        --  2|b                |c        |A                 |c         |
        --  3|c                |*        |C                 |c         |
        --  4|e                |f        |A                 |g         |
        --  5|f                |g        |A                 |g         |
        --  6|g                |*        |D                 |g         |
        --  7|i                |j        |A                 |          |
        --  8|j                |k        |A                 |l         |
        --  9|k                |l        |A                 |l         |
        -- 10|l                |*        |E                 |l         |
        -- 11|n                |o        |A                 |          |
        -- 12|o                |p        |A                 |          |
        -- 13|p                |q        |A                 |r         |
        -- 14|q                |r        |A                 |r         |
        -- 15|r                |*        |F                 |r         |
        -- 16|t                |u        |A                 |          |
        -- 17|u                |v        |A                 |          |
        -- 18|v                |w        |A                 |          |
        -- 19|w                |x        |A                 |y         |
        -- 20|x                |y        |A                 |y         |
        -- 21|y                |*        |G                 |y         |
        
     UNTIL i = num_levels
       END REPEAT
    ;
  
  INSERT INTO tmp_01 SELECT * FROM tmp_02;   -- combine case 1 and cases 2-6
     
--   SELECT 
--       t1.bill_to_id 
--      ,sc.cardconex_acct_id 
--      ,sc.dba_name 
--     FROM auto_billing_dw.f_auto_billing_complete_shieldconex sc 
--     JOIN tmp_01                                         t1 
--       ON sc.cardconex_acct_id = t1.cardconex_acct_id 
--   ;



  SELECT 'Updating f_auto_billing_complete_shieldconex...' AS message;

  UPDATE auto_billing_dw.f_auto_billing_complete_shieldconex
     SET bill_to_id = NULL
   WHERE TRUE 
  ;

  UPDATE auto_billing_dw.f_auto_billing_complete_shieldconex  ab
    JOIN tmp_01                                               t1 
      ON ab.cardconex_acct_id = t1.cardconex_acct_id  
     SET ab.bill_to_id = t1.bill_to_id 
   WHERE TRUE 
  ;

  

  SELECT 'Updating f_auto_billing_complete_2...' AS message;

  UPDATE auto_billing_dw.f_auto_billing_complete_2
     SET bill_to_id = NULL
   WHERE TRUE 
  ;
   
  UPDATE auto_billing_dw.f_auto_billing_complete_2            ab
    JOIN tmp_01                                               t1 
      ON ab.account_id = t1.cardconex_acct_id  
     SET ab.bill_to_id = t1.bill_to_id 
   WHERE TRUE 
  ;


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_bill_to_id_2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `update_bill_to_id_2`()
    COMMENT 'USAGE:  update_bill_to_id */ Calculates and populates bill_to_id. */'
BEGIN

    /*
    
        Purpose:  Calculate the bill_to_id.
        
        Note the following:
    
        MariaDB [sales_force]> SELECT billing_preference__c, COUNT(*) FROM sales_force.account GROUP BY 1;
        +-----------------------+----------+
        | billing_preference__c | COUNT(*) |
        +-----------------------+----------+
        | NULL                  |    21702 |
        | Aggregated Billing    |     4235 |
        | Client Level Only     |       42 |
        | Direct Billing        |     9687 |
        | Processor Only        |    30928 |
        +-----------------------+----------+
        5 rows in set (3.38 sec)
    
        Rows in sales_force.account for which billing_preference__c != 'Aggregated' are billed directly.
        
        Rows in sales_force.account for which billing_preference__c = 'Aggregated' are billed to a parent account, based on the value of account.parentid.
        It may be be necessary to traverse multiple 'levels' to find the parent.
        
        See the simulated data below; the calculated value of bill_to_id is shown.
        
        account_id       |parent_id|billing_preference|bill_to_id|
        -----------------|---------|------------------|----------|
        a                |*        |Client Level Only |a         |   -- case 1
        
        b                |c        |Aggregated Billing|c         |   -- case 2
        c                |*        |Direct Billing    |c         |
        
        e                |f        |Aggregated Billing|g         |   -- case 3
        f                |g        |Aggregated Billing|g         |
        g                |*        |Processor Only    |g         |
        
        i                |j        |Aggregated Billing|l         |   -- case 4
        j                |k        |Aggregated Billing|l         |
        k                |l        |Aggregated Billing|l         |
        l                |*        |Processor Only    |l         |
        
        n                |o        |Aggregated Billing|r         |   -- case 5
        o                |p        |Aggregated Billing|r         |
        p                |q        |Aggregated Billing|r         |
        q                |r        |Aggregated Billing|r         |
        r                |*        |Processor Only    |r         |
        
        t                |u        |Aggregated Billing|y         |   -- case 6
        u                |v        |Aggregated Billing|y         |
        v                |w        |Aggregated Billing|y         |
        w                |x        |Aggregated Billing|y         |
        x                |y        |Aggregated Billing|y         |
        y                |*        |Processor Only    |y         |
        
        Case 1 (One Level)
        ------------------
        Since billing_preference != 'Aggregated Billing, the account is billed directly; i.e, bill_to_id = account_id
        
        Case 2 (Two Levels)
        -------------------
        billing_preference = 'Aggregated Billing', so this account is not billed directly.
     
        Consider the following:
        
        account_id|parent_id|billing_preference|
        -----------------|---------|------------------|
        b                |c        |Aggregated Billing|
        c                |*        |Direct Billing    |
        
        We need to calculate the bill_to_id for account_id = 'b'.
        billing_preference = 'Aggregated Billing', so we have the find the parent.
        
        In this case, the parent_id = 'c'.  The value of billing_preference for account_id = 'c' = 'Direct Billing', so 'c' is the parent.
        Therefore, the bill_to_id for account_id IN ('b', 'c') = 'Direct Billing.
        
        Cases 3, 4, 5, ... (Three Or More Levels)
        -----------------------------------------
        These are variations for Case 2, with an increasing number of levels.
        See the desired output in the table above for each of these cases.   
    
    */
    
    DECLARE i           TINYINT UNSIGNED;
    DECLARE num_levels  TINYINT UNSIGNED DEFAULT 4;   -- number of times to repeat the loop for cases 3-6

    SELECT 'Executing Stored Procedure' AS operation, 'update_bill_to_id' AS stored_procedure, CURRENT_TIMESTAMP;
  
          SELECT 'This procedure updates both auto_billing_dw.f_auto_billing_complete_2 and auto_billing_dw.f_auto_billing_complete_shieldconex.' AS message
    UNION SELECT 'Updates to auto_billing_dw.f_auto_billing_complete_shieldconex can be dropped once that table is dropped.';
  
  -- Case 1
    
    SET @ab = 'Aggregated Billing';
    
    TRUNCATE auto_billing_staging.stg_bill_to_id;
    
    -- NULL values of billing_preference__c should be interpreted as 'Direct Billing'.  
    -- This is not currently configured in the database or in the warehouse, so it is being done here.
    
    SELECT 'NULL values of sales_force.account.billing_preference__c will be interpreted as \'Direct Billing\'' AS message;
  
    INSERT INTO auto_billing_staging.stg_bill_to_id 
    SELECT 
         id                       AS account_id 
        ,parentid                 AS parent_id 
        ,'Direct Billing'         AS billing_preference
        ,NULL                     AS bill_to_id
        ,NULL                     AS date_updated
      FROM sales_force.account 
     WHERE billing_preference__c IS NULL
    ;
  
    INSERT INTO auto_billing_staging.stg_bill_to_id 
    SELECT 
         id                       AS account_id 
        ,parentid                 AS parent_id 
        ,billing_preference__c    AS billing_preference
        ,NULL                     AS bill_to_id
        ,NULL                     AS date_updated
      FROM sales_force.account 
     WHERE billing_preference__c != @ab
    ;
    
    UPDATE auto_billing_staging.stg_bill_to_id
       SET bill_to_id = account_id
     WHERE TRUE 
    ;  
    
    -- SELECT * FROM auto_billing_staging.stg_bill_to_id;
    -- id|account_id|parent_id|billing_preference|bill_to_id|
    -- --|-----------------|---------|------------------|----------|
    --  1|a                |*        |B                 |a         |
    --  3|c                |*        |C                 |c         |
    --  6|g                |*        |D                 |g         |
    -- 10|l                |*        |E                 |l         |
    -- 15|r                |*        |F                 |r         |
    -- 21|y                |*        |G                 |y         |
    
    -- Case 2
    
    DROP TABLE IF EXISTS tmp_bill_to_id_02;
    
    CREATE TEMPORARY TABLE tmp_bill_to_id_02 LIKE auto_billing_staging.stg_bill_to_id;
    
    INSERT INTO tmp_bill_to_id_02
    SELECT 
         id                       AS account_id 
        ,parentid                 AS parent_id 
        ,billing_preference__c    AS billing_preference
        ,NULL                     AS bill_to_id
        ,NULL                     AS date_updated
      FROM sales_force.account 
     WHERE billing_preference__c = @ab
    ;
    
    UPDATE tmp_bill_to_id_02     t2 
      JOIN auto_billing_staging.stg_bill_to_id     t1 
        ON t2.parent_id = t1.account_id 
       SET t2.bill_to_id = t1.bill_to_id
     WHERE TRUE 
    ;
    
    -- SELECT * FROM tmp_bill_to_id_02;
    
    -- id|account_id|parent_id|billing_preference|bill_to_id|
    -- --|-----------------|---------|------------------|----------|
    --  2|b                |c        |A                 |c         |
    --  4|e                |f        |A                 |          |
    --  5|f                |g        |A                 |g         |
    --  7|i                |j        |A                 |          |
    --  8|j                |k        |A                 |          |
    --  9|k                |l        |A                 |l         |
    -- 11|n                |o        |A                 |          |
    -- 12|o                |p        |A                 |          |
    -- 13|p                |q        |A                 |          |
    -- 14|q                |r        |A                 |r         |
    -- 16|t                |u        |A                 |          |
    -- 17|u                |v        |A                 |          |
    -- 18|v                |w        |A                 |          |
    -- 19|w                |x        |A                 |          |
    -- 20|x                |y        |A                 |y         |
    
    -- SELECT * FROM (
    --          SELECT * FROM auto_billing_staging.stg_bill_to_id
    --    UNION SELECT * FROM tmp_bill_to_id_02
    --   ) t3
    --  ORDER BY 1
    -- ;
    
    -- id|account_id|parent_id|billing_preference|bill_to_id|
    -- --|-----------------|---------|------------------|----------|
    --  1|a                |*        |B                 |a         |
    --  2|b                |c        |A                 |c         |
    --  3|c                |*        |C                 |c         |
    --  4|e                |f        |A                 |          |
    --  5|f                |g        |A                 |g         |
    --  6|g                |*        |D                 |g         |
    --  7|i                |j        |A                 |          |
    --  8|j                |k        |A                 |          |
    --  9|k                |l        |A                 |l         |
    -- 10|l                |*        |E                 |l         |
    -- 11|n                |o        |A                 |          |
    -- 12|o                |p        |A                 |          |
    -- 13|p                |q        |A                 |          |
    -- 14|q                |r        |A                 |r         |
    -- 15|r                |*        |F                 |r         |
    -- 16|t                |u        |A                 |          |
    -- 17|u                |v        |A                 |          |
    -- 18|v                |w        |A                 |          |
    -- 19|w                |x        |A                 |          |
    -- 20|x                |y        |A                 |y         |
    -- 21|y                |*        |G                 |y         |
    
    
    
    -- Case 3
    
    /*  
    
        I need to join a self join on tmp_bill_to_id_02 to proceed.  
        But MariaDB apparently does not support that; see the following:
        
        SELECT a.*, b.*
          FROM tmp_bill_to_id_02   a 
          JOIN tmp_bill_to_id_02   b 
            ON a.account_id = b.account_id;
        SQL Error [1137] [HY000]: Can't reopen table: 'a'
        
        I will therefore have to create two copies of the same table and join those instead.
        
        It so happens that the code for Case 3 also workds for Case 4, 5, 6, ...
        
        So we can put that code in a loop.
        
        Finance has advised that four loops is enough.
    
    */
    
    SET i = 0;
    
    REPEAT
        DROP TABLE IF EXISTS tmp_bill_to_id_03;
        DROP TABLE IF EXISTS tmp_bill_to_id_04;
        CREATE TEMPORARY TABLE tmp_bill_to_id_03 SELECT * FROM tmp_bill_to_id_02;
        CREATE TEMPORARY TABLE tmp_bill_to_id_04 SELECT * FROM tmp_bill_to_id_02;
        
        -- SELECT 
        --      t3.account_id AS t3_account_id 
        --     ,t3.parent_id         AS t3_parent_id 
        --     ,t4.account_id AS t3_account_id 
        --     ,t4.parent_id         AS t4_parent_id
        --     ,t4.bill_to_id
        --   FROM tmp_bill_to_id_03   t3
        --   JOIN tmp_bill_to_id_04   t4 
        --     ON t3.parent_id = t4.account_id
        --  WHERE t4.bill_to_id IS NOT NULL;
         
        -- t3_account_id|t3_parent_id|t3_account_id|t4_parent_id|bill_to_id|
        -- --------------------|------------|--------------------|------------|----------|
        -- e                   |f           |f                   |g           |g         |
        -- j                   |k           |k                   |l           |l         |
        -- p                   |q           |q                   |r           |r         |
        -- w                   |x           |x                   |y           |y         |
        
        -- SELECT * FROM tmp_bill_to_id_02 WHERE bill_to_id IS NULL;
        
        -- id|account_id|parent_id|billing_preference|bill_to_id|
        -- --|-----------------|---------|------------------|----------|
        --  4|e                |f        |A                 |          |
        --  7|i                |j        |A                 |          |
        --  8|j                |k        |A                 |          |
        -- 11|n                |o        |A                 |          |
        -- 12|o                |p        |A                 |          |
        -- 13|p                |q        |A                 |          |
        -- 16|t                |u        |A                 |          |
        -- 17|u                |v        |A                 |          |
        -- 18|v                |w        |A                 |          |
        -- 19|w                |x        |A                 |          |
        
        UPDATE tmp_bill_to_id_02    t2 
          JOIN (
            SELECT 
                 t3.account_id AS t3_account_id 
                ,t3.parent_id         AS t3_parent_id 
                ,t4.account_id AS t4_account_id 
                ,t4.parent_id         AS t4_parent_id
                ,t4.bill_to_id
              FROM tmp_bill_to_id_03   t3
              JOIN tmp_bill_to_id_04   t4 
                ON t3.parent_id = t4.account_id
             WHERE t4.bill_to_id IS NOT NULL   
          ) t3 
            ON t2.account_id = t3.t3_account_id 
           SET t2.bill_to_id = t3.bill_to_id 
         WHERE TRUE 
        ;
      
        SET i = i + 1;
        
        -- SELECT * FROM (
        --          SELECT * FROM auto_billing_staging.stg_bill_to_id
        --    UNION SELECT * FROM tmp_bill_to_id_02
        --   ) t3
        --  ORDER BY 1
        -- ;
        
        -- id|account_id|parent_id|billing_preference|bill_to_id|
        -- --|-----------------|---------|------------------|----------|
        --  1|a                |*        |B                 |a         |
        --  2|b                |c        |A                 |c         |
        --  3|c                |*        |C                 |c         |
        --  4|e                |f        |A                 |g         |
        --  5|f                |g        |A                 |g         |
        --  6|g                |*        |D                 |g         |
        --  7|i                |j        |A                 |          |
        --  8|j                |k        |A                 |l         |
        --  9|k                |l        |A                 |l         |
        -- 10|l                |*        |E                 |l         |
        -- 11|n                |o        |A                 |          |
        -- 12|o                |p        |A                 |          |
        -- 13|p                |q        |A                 |r         |
        -- 14|q                |r        |A                 |r         |
        -- 15|r                |*        |F                 |r         |
        -- 16|t                |u        |A                 |          |
        -- 17|u                |v        |A                 |          |
        -- 18|v                |w        |A                 |          |
        -- 19|w                |x        |A                 |y         |
        -- 20|x                |y        |A                 |y         |
        -- 21|y                |*        |G                 |y         |
        
     UNTIL i = num_levels
       END REPEAT
    ;
  
  INSERT INTO auto_billing_staging.stg_bill_to_id SELECT * FROM tmp_bill_to_id_02;   -- combine case 1 and cases 2-6
     
--   SELECT 
--       t1.bill_to_id 
--      ,sc.account_id 
--      ,sc.dba_name 
--     FROM auto_billing_dw.f_auto_billing_complete_2 sc 
--     JOIN auto_billing_staging.stg_bill_to_id                                         t1 
--       ON sc.account_id = t1.account_id 
--   ;


  /* 
  SELECT 'Updating f_auto_billing_complete_shieldconex...' AS message;

  UPDATE auto_billing_dw.f_auto_billing_complete_shieldconex
     SET bill_to_id = NULL
   WHERE TRUE 
  ;

  UPDATE auto_billing_dw.f_auto_billing_complete_shieldconex  ab
    JOIN auto_billing_staging.stg_bill_to_id                  t1 
      ON ab.cardconex_acct_id = t1.account_id  
     SET ab.bill_to_id = t1.bill_to_id 
   WHERE TRUE 
  ;
  */

  SELECT 'Updating f_auto_billing_complete_2...' AS message;

  UPDATE auto_billing_dw.f_auto_billing_complete_2
     SET bill_to_id = NULL
   WHERE TRUE 
  ;
   
  UPDATE auto_billing_dw.f_auto_billing_complete_2            ab
    JOIN auto_billing_staging.stg_bill_to_id                  t1
      ON ab.account_id = t1.account_id  
     SET ab.bill_to_id = t1.bill_to_id 
   WHERE TRUE 
  ;
  
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_shieldconex_fees_and_charges` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `update_shieldconex_fees_and_charges`()
    COMMENT 'USAGE: update_shieldconex_fees_and_charges */ Calculates and updates ShieldConex charges and fees. */'
BEGIN

    -- ShieldConex
    
    -- objective:  calculation shieldconex fees
    
    SELECT 'Executing Stored Procedure' AS operation, 'update_shieldconex_fees_and_charges' AS stored_procedure, CURRENT_TIMESTAMP;
    
    DROP TABLE IF EXISTS auto_billing_staging.tmp_asset;
    
    CREATE TEMPORARY TABLE auto_billing_staging.tmp_asset(
         client_id                      VARCHAR(32) NOT NULL 
        ,cardconex_acct_id              VARCHAR(18) NOT NULL 
        ,shieldconex_monthly_fee        DECIMAL(12, 5) NOT NULL
        ,shieldconex_monthly_minimum    DECIMAL(12, 5) NOT NULL
        ,shieldconex_transaction_fee    DECIMAL(12, 5) NOT NULL
        ,shieldconex_fields_fee         DECIMAL(12, 5) NOT NULL
        ,PRIMARY KEY(client_id)
    );
    
    SELECT 'de-normalizing ShieldConex fees' AS message;
  
    -- Populate the table
    INSERT INTO auto_billing_staging.tmp_asset
    SELECT 
         client_id
        ,cardconex_acct_id
        ,SUM(shieldconex_monthly_fee)         AS shieldconex_monthly_fee
        ,SUM(shieldconex_monthly_minimum)     AS shieldconex_monthly_minimum
        ,SUM(shieldconex_transaction_fee)     AS shieldconex_transaction_fee
        ,SUM(shieldconex_fields_charge)       AS shieldconex_fields_charge
      FROM (
          SELECT 
             cardconex_acct_id 
            ,client_id 
            ,(fee_name = 'shieldconex_monthly_fee'    ) * fee_amount AS shieldconex_monthly_fee
            ,(fee_name = 'shieldconex_monthly_minimum') * fee_amount AS shieldconex_monthly_minimum
            ,(fee_name = 'shieldconex_transaction_fee') * fee_amount AS shieldconex_transaction_fee
            ,(fee_name = 'shieldconex_fields_fee'  )    * fee_amount AS shieldconex_fields_charge
          FROM (
                SELECT 
                    asst.accountid                        AS cardconex_acct_id
                   ,COALESCE(idn.name, 'undefined')       AS client_id
                   ,fm.fee                                AS fee_name
                   ,COALESCE(asst.fee_amount__c, 0.00000) AS fee_amount
                  FROM sales_force.asset                  asst 
                  JOIN sales_force.fee_map                fm 
                    ON asst.fee_name__c = fm.fee_name
                  JOIN sales_force.identification_number__c   idn 
                    ON asst.accountid = idn.accountid__c 
                 WHERE fm.fee IN (
                        'shieldconex_monthly_fee'   
                       ,'shieldconex_monthly_minimum'
                       ,'shieldconex_transaction_fee'
                       ,'shieldconex_fields_fee')
          ) t1 
      ) t2 
     GROUP BY 1, 2
     ORDER BY 1, 2
    ; 
    
    SELECT * FROM auto_billing_staging.tmp_asset;
    
    -- Sample Output
    -- client_id|cardconex_acct_id |shieldconex_monthly_fee|shieldconex_monthly_minimum|shieldconex_transaction_fee|shieldconex_fields_charge|
    -- ---------|------------------|-----------------------|---------------------------|---------------------------|-------------------------|
    -- 20       |0013i00000IsUq7AAF|                0.00000|                  250.00000|                    0.02100|                  0.00000|
    -- 33       |0013i00000QqgelAAB|                0.00000|                 5000.00000|                    0.00175|                  0.00000|
    
    
    -- SELECT
    --      acct.name
    --     ,asst.*
    --   FROM auto_billing_staging.tmp_asset   asst
    --   JOIN sales_force.account              acct
    --     ON asst.cardconex_acct_id = acct.id
    --  ORDER BY 1 * client_id
    -- ;
    
    -- name                         |client_id|cardconex_acct_id |shieldconex_monthly_fee|shieldconex_monthly_minimum|shieldconex_transaction_fee|shieldconex_fields_fee|
    -- -----------------------------|---------|------------------|-----------------------|---------------------------|---------------------------|----------------------|
    -- Alaska Airlines - ShieldConex|20       |0013i00000IsUq7AAF|                0.00000|                  250.00000|                    0.02100|               0.00000|
    -- PAAY LLC                     |33       |0013i00000QqgelAAB|                0.00000|                 5000.00000|                    0.00175|               0.00000|
    
    
    -- All numeric columns:  INT UNSIGNED NOT NULL DEFAULT 0; no need for COALESCE function this time.
    
    SELECT 'populating temporary table 1' AS message;
  
    DROP TABLE IF EXISTS auto_billing_staging.tmp_shieldconex;
    
    CREATE TEMPORARY TABLE auto_billing_staging.tmp_shieldconex(
         client_id               VARCHAR(16) NOT NULL
        ,client_name             VARCHAR(64)
        ,partner_name            VARCHAR(64)
        ,total_bad_tokenized     INT UNSIGNED NOT NULL
        ,total_good_detokenized  INT UNSIGNED NOT NULL
        ,total_good_tokenized    INT UNSIGNED NOT NULL
        ,total_bad_detokenized   INT UNSIGNED NOT NULL 
        ,good_tokenized_fields   INT UNSIGNED NOT NULL
        ,bad_tokenized_fields    INT UNSIGNED NOT NULL
        ,good_detokenized_fields INT UNSIGNED NOT NULL
        ,bad_detokenized_fields  INT UNSIGNED NOT NULL
        ,PRIMARY KEY(client_id)
    );
    
    INSERT INTO auto_billing_staging.tmp_shieldconex
    SELECT 
        client_id 
       ,client_name 
       ,partner_name
       ,total_bad_tokenized 
       ,total_good_detokenized 
       ,total_good_tokenized     
       ,total_bad_detokenized
       ,good_tokenized_fields 
       ,bad_tokenized_fields 
       ,good_detokenized_fields 
       ,bad_detokenized_fields 
      FROM auto_billing_staging.stg_shieldconex
     WHERE complete_date = DATE_FORMAT(CURRENT_DATE - INTERVAL 1 MONTH, '%Y%m01')
       AND client_name NOT LIKE 'client_name%'
    ;
    
    -- SELECT * FROM auto_billing_staging.tmp_shieldconex;
    
    -- client_id|client_name    |partner_name   |total_bad_tokenized|total_good_detokenized|total_good_tokenized|total_bad_detokenized|good_tokenized_fields|bad_tokenized_fields|good_detokenized_fields|bad_detokenized_fields|
    -- ---------|---------------|---------------|-------------------|----------------------|--------------------|---------------------|---------------------|--------------------|-----------------------|----------------------|
    -- 20       |Contact Centers|Alaska Airlines|                 61|                   132|                 132|                    0|                  528|                 244|                    528|                     0|
    -- 33       |Paay           |Paay LLC       |                 18|                413372|              860487|                    7|               860487|                  18|                 413372|                     7|
    
    
    -- identify client_id's which exist in sales_force.asset or auto_billing_staging.stg_shieldconex BUT NOT BOTH.
    -- get a 'master list' of client_id's to start.
    
  
    DROP TABLE IF EXISTS auto_billing_staging.tmp_client_id;
    
    CREATE TEMPORARY TABLE auto_billing_staging.tmp_client_id SELECT client_id FROM auto_billing_staging.tmp_asset UNION SELECT client_id FROM auto_billing_staging.tmp_shieldconex;
    
    -- SELECT * FROM auto_billing_staging.tmp_client_id;
    
    -- show a list of client_id's are missing data in one or more tables
    SELECT 
         COALESCE(acct.name, 'NULL')                    AS account_name
        ,sc.partner_name
        ,t1.client_id                                   AS client_id
        ,IF(sc.client_id IS NULL, 'missing', 'ok')      AS stg_shieldconex
        ,IF(asst.client_id IS NULL, 'missing', 'ok')    AS asset 
        ,IF(idn.name IS NOT NULL, 'ok', 'missing')      AS identification_number__c
        ,idn.type__c                                    AS identification_number_type__c
      FROM auto_billing_staging.tmp_client_id           t1 
      LEFT JOIN auto_billing_staging.tmp_asset          asst
        ON t1.client_id = asst.client_id
      LEFT JOIN sales_force.identification_number__c    idn 
        ON t1.client_id = idn.name
      LEFT JOIN sales_force.account                     acct 
        ON idn.accountid__c = acct.id
      LEFT JOIN auto_billing_staging.tmp_shieldconex    sc 
        ON t1.client_id = sc.client_id
     WHERE idn.type__c = 'ShieldConex'
        OR idn.type__c IS NULL
     ORDER BY acct.name IS NULL, acct.name, 1 * t1.client_id
    ;
    
    SELECT 'populating temporary table 2' AS message;
  
    DROP TABLE IF EXISTS auto_billing_staging.tmp_calc_shieldconex_charges;
    
    CREATE TABLE auto_billing_staging.tmp_calc_shieldconex_charges(
       client_id                           VARCHAR(32)   NOT NULL,
       cardconex_acct_id                   VARCHAR(18)   NOT NULL,
       client_name                         VARCHAR(64)   DEFAULT NULL,
       shieldconex_monthly_fee             DECIMAL(10,5) NOT NULL,
       shieldconex_monthly_minimum         DECIMAL(10,5) NOT NULL,
       shieldconex_transaction_fee         DECIMAL(10,5) NOT NULL,
       shieldconex_fields_fee              DECIMAL(10,5) NOT NULL,
       total_bad_tokenized                 INT UNSIGNED  NOT NULL,
       total_good_detokenized              INT UNSIGNED  NOT NULL,
       total_good_tokenized                INT UNSIGNED  NOT NULL,
       total_bad_detokenized               INT UNSIGNED  NOT NULL,
       good_tokenized_fields               INT UNSIGNED  NOT NULL,
       bad_tokenized_fields                INT UNSIGNED  NOT NULL,
       good_detokenized_fields             INT UNSIGNED  NOT NULL,
       bad_detokenized_fields              INT UNSIGNED  NOT NULL,
       shieldconex_monthly_charge          DECIMAL(10,5) NOT NULL DEFAULT 0.00000,
       shieldconex_transaction_charge      DECIMAL(10,5) NOT NULL DEFAULT 0.00000,
       shieldconex_monthly_minimum_charge  DECIMAL(10,5) NOT NULL DEFAULT 0.00000,
       shieldconex_fields_charge           DECIMAL(10,5) NOT NULL DEFAULT 0.00000,
       PRIMARY KEY(client_id),
       UNIQUE(cardconex_acct_id)
    )
    ;
    
    -- DESC auto_billing_staging.tmp_calc_shieldconex_charges;
    
    INSERT INTO auto_billing_staging.tmp_calc_shieldconex_charges
    SELECT 
         asst.client_id 
        ,asst.cardconex_acct_id 
        ,sc.client_name
        ,asst.shieldconex_monthly_fee
        ,asst.shieldconex_monthly_minimum
        ,asst.shieldconex_transaction_fee
        ,asst.shieldconex_fields_fee
        ,sc.total_bad_tokenized    
        ,sc.total_good_detokenized 
        ,sc.total_good_tokenized   
        ,sc.total_bad_detokenized  
        ,sc.good_tokenized_fields  
        ,sc.bad_tokenized_fields   
        ,sc.good_detokenized_fields
        ,sc.bad_detokenized_fields 
        ,0.00000 AS shieldconex_monthly_charge
        ,0.00000 AS shieldconex_transaction_charge
        ,0.00000 AS shieldconex_monthly_minimum_charge
        ,0.00000 AS shieldconex_fields_charge
      FROM auto_billing_staging.tmp_asset                asst 
      LEFT JOIN auto_billing_staging.tmp_shieldconex     sc
        ON asst.client_id = sc.client_id 
    ;
    
    SELECT 'calculating stage 1' AS message;
  
    UPDATE auto_billing_staging.tmp_calc_shieldconex_charges
       SET shieldconex_monthly_charge = auto_billing_dw.calc_shieldconex_monthly_charge(shieldconex_monthly_fee) 
     WHERE TRUE
    ;
    
    SELECT 'calculating stage 2' AS message;
    
    UPDATE auto_billing_staging.tmp_calc_shieldconex_charges
       SET shieldconex_transaction_charge     = auto_billing_dw.calc_shieldconex_transaction_charge(
              total_good_tokenized 
             ,total_bad_tokenized 
             ,total_good_detokenized
             ,total_bad_detokenized 
             ,shieldconex_monthly_minimum
             ,shieldconex_transaction_fee)    
     WHERE TRUE
    ;

    SELECT 'calculating stage 3' AS message;
  
    UPDATE auto_billing_staging.tmp_calc_shieldconex_charges
       SET shieldconex_monthly_minimum_charge = auto_billing_dw.calc_shieldconex_monthly_minimum_charge(
              shieldconex_transaction_charge
             ,shieldconex_monthly_minimum)
     WHERE TRUE 
    ;

    SELECT 'calculating stage 4' AS message;
    
    UPDATE auto_billing_staging.tmp_calc_shieldconex_charges
       SET shieldconex_fields_charge = auto_billing_dw.calc_shieldconex_fields_charge(
            good_tokenized_fields 
           ,bad_tokenized_fields 
           ,good_detokenized_fields 
           ,bad_detokenized_fields 
           ,shieldconex_monthly_minimum 
           ,shieldconex_fields_fee)
     WHERE TRUE 
    ;
    
    
--     SELECT * FROM auto_billing_staging.tmp_calc_shieldconex_charges;
    -- client_id|cardconex_acct_id |client_name    |shieldconex_monthly_fee|shieldconex_monthly_minimum|shieldconex_transaction_fee|shieldconex_fields_fee|total_bad_tokenized|total_good_detokenized|total_good_tokenized|total_bad_detokenized|good_tokenized_fields|bad_tokenized_fields|good_detokenized_fields|bad_detokenized_fields|shieldconex_monthly_charge|shieldconex_transaction_charge|shieldconex_monthly_minimum_charge|shieldconex_fields_charge|
    -- ---------|------------------|---------------|-----------------------|---------------------------|---------------------------|----------------------|-------------------|----------------------|--------------------|---------------------|---------------------|--------------------|-----------------------|----------------------|--------------------------|------------------------------|----------------------------------|-------------------------|
    -- 20       |0013i00000IsUq7AAF|Contact Centers|                0.00000|                  250.00000|                    0.02100|               0.00000|                 61|                   132|                 132|                    0|                  528|                 244|                    528|                     0|                   0.00000|                       0.00000|                         250.00000|                  0.00000|
    -- 33       |0013i00000QqgelAAB|Paay           |                0.00000|                 5000.00000|                    0.00175|               0.00000|                 18|                413372|              860487|                    7|               860487|                  18|                 413372|                     7|                   0.00000|                       0.00000|                        5000.00000|                  0.00000|
    
    SELECT 'updating auto_billing_dw.f_auto_billing_complete_shieldconex' AS message; 
      
    INSERT INTO auto_billing_dw.f_auto_billing_complete_shieldconex (
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
        ,user_count
        ,group_count
        ,cc_auth_trans
        ,cc_auth_vol
        ,cc_sale_trans
        ,cc_sale_vol
        ,cc_ref_trans
        ,cc_ref_vol
        ,cc_credit_trans
        ,cc_credit_vol
        ,cc_sale_decline_trans
        ,cc_auth_decline_trans
        ,cc_batches
        ,cc_keyed_trans
        ,cc_keyed_vol
        ,cc_swiped_trans
        ,cc_swiped_vol
        ,ach_sale_trans
        ,ach_sale_vol
        ,ach_credit_trans
        ,ach_credit_vol
        ,ach_batches
        ,ach_returns
        ,ach_errors
        ,ach_noc_messages
        ,p2pe_auth_trans
        ,p2pe_auth_vol
        ,p2pe_sale_trans
        ,p2pe_sale_vol
        ,p2pe_refund_trans
        ,p2pe_refund_vol
        ,p2pe_credit_trans
        ,p2pe_credit_vol
        ,p2pe_sale_decline_trans
        ,p2pe_auth_decline_trans
        ,p2pe_active_device_trans
        ,p2pe_inactive_device_trans
        ,tokens_stored
        ,batch_files_processed
        ,cc_capture_trans
        ,cc_capture_vol
        ,p2pe_capture_trans
        ,p2pe_capture_vol
        ,combined_decline_trans
        ,p2pe_declined_trans
        ,p2pe_tokens_stored
        ,reissued_cc_transactions
        ,reissued_ach_transactions
    ) 
    SELECT 
         NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,DATE_FORMAT(CURRENT_DATE, '%Y%m')
        ,cardconex_acct_id
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,0
        ,0
        ,shieldconex_monthly_charge
        ,shieldconex_transaction_charge
        ,shieldconex_monthly_minimum_charge
        ,shieldconex_fields_charge
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,shieldconex_monthly_fee
        ,shieldconex_transaction_fee
        ,shieldconex_fields_fee
        ,shieldconex_monthly_minimum
        ,total_good_tokenized
        ,total_bad_tokenized
        ,total_good_detokenized
        ,total_bad_detokenized
        ,good_tokenized_fields
        ,bad_tokenized_fields
        ,good_detokenized_fields
        ,bad_detokenized_fields
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
    FROM auto_billing_staging.tmp_calc_shieldconex_charges
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

-- Dump completed on 2021-01-07 14:28:00
