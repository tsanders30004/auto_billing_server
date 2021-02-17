CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `auto_billing_staging`.`populate_stg_asset`()
    COMMENT 'USAGE: populate_stg_asset() /* Populates auto_billing_staging.stg_asset - a de-normalized version of sales_force.asset. */'
BEGIN
  
    /* 
        purpose:  create a de-normalized version for sales_force.asset which can be used to facilitate auto_billing.
        the table will include the account_id, currency_code, date, exchange rate, and a separate column for each fee_name__c present in sales_force.asset.
        
        sample row (some fees omitted for brevity):
        
        data_warehouse@localhost [auto_billing_staging] select * from stg_asset LIMIT 1\G
        *************************** 1. row ***************************
                           account_id: 0013i00000Cg8RaAAJ
                    currency_iso_code: EUR
                            rate_date: 2020-12-01
                        exchange_rate: 1.22637300
                       ach_credit_fee: 1.00000
                  bfach_discount_rate: 3.00000
                                   ...
              shieldconex_monthly_fee: 63.00000
          shieldconex_monthly_minimum: 65.00000
          shieldconex_transaction_fee: 67.00000
                         date_updated: 2021-01-11 16:49:33               
        
        
          this procedure will have to be updated when new fees are added to sales_force.asset.

          the exchange rate will change every month.  
          because auto_billing is generally run on the first business day of the month, the exchange month that is applicable will be the one for the previous month, relative to the current date.
          for that reason, it is required that the auto_billing_staging.exchange_rate table contains a row for every currency in sales_force.asset for the previous month; 
    
          sample rows from auto_billing_staging.exchange_rate:
          
          +-------------------+------------+---------------+---------------------+
          | currency_iso_code | rate_date  | exchange_rate | date_processed      |
          +-------------------+------------+---------------+---------------------+
          | CAD               | 2020-12-01 |    0.78474300 | 2021-01-11 13:50:21 |
          | EUR               | 2020-12-01 |    1.22637300 | 2021-01-11 13:54:09 |
          +-------------------+------------+---------------+---------------------+
 
     */
  
    SELECT 'Executing Stored Procedure' AS operation, 'auto_billing_staging.populate_stg_asset' AS stored_procedure, CURRENT_TIMESTAMP;
  
    SELECT 'there should be an exchange rate defined for every currency present in the sales_force.asset table.' AS message UNION SELECT 'NULL values for exchange rate / rate_date indicate that an exchange rate is missing in auto_billing_staging.exchange_rate. ';
  
    SELECT
       asst.currency_iso_code 
      ,er.exchange_rate 
      ,er.rate_date
      ,COUNT(*) AS num_rows
      FROM sales_force.asset      asst 
      LEFT JOIN auto_billing_staging.v_exchange_rates_last_month    er 
        ON asst.currency_iso_code = er.currency_iso_code 
     GROUP BY 1, 2, 3
    ;
  
  SELECT 0;

  SELECT 'every row in sales_force.asset for a given account_id should have the same currency code.' AS message UNION SELECT 'if the number of rows in the table below is non-zero, then the account_id\'s shown have more than one currency.';

  SELECT * 
    FROM (
        SELECT 
             accountid 
            ,COUNT(DISTINCT currency_iso_code) AS currency_codes
          FROM sales_force.asset 
         GROUP BY 1) t1 
   WHERE currency_codes >= 2
  ;
  
    SELECT 'The following fees are duplicated in sales_force.asset and will causing billing errors unless the duplicates are deleted.' AS message;
      
    SELECT * FROM sales_force.v_dupe_fees;
    
    SELECT 1;
      
  
    TRUNCATE auto_billing_staging.stg_asset;
  
    INSERT INTO auto_billing_staging.stg_asset(
       account_id    
      ,currency_iso_code 
      ,rate_date 
      ,exchange_rate 
      ,ach_credit_fee               
      ,bfach_discount_rate          
      ,ach_per_gw_trans_fee         
      ,ach_monthly_fee              
      ,ach_noc_fee                  
      ,ach_return_error_fee         
      ,ach_transaction_fee          
      ,bluefin_gateway_discount_rate
      ,file_transfer_monthly_fee    
      ,group_tag_fee                
      ,gw_per_auth_decline_fee      
      ,per_transaction_fee          
      ,gw_per_credit_fee            
      ,gateway_monthly_fee          
      ,gw_per_refund_fee            
      ,gw_reissued_fee              
      ,gw_per_token_fee             
      ,gw_per_sale_fee              
      ,misc_monthly_fees            
      ,p2pe_device_activated        
      ,p2pe_device_activating_fee   
      ,p2pe_device_stored_fee       
      ,p2pe_encryption_fee          
      ,p2pe_monthly_flat_fee        
      ,p2pe_tokenization_fee        
      ,one_time_key_injection_fees  
      ,payconex_app_exchange_fee    
      ,pci_compliance_fee           
      ,pci_non_compliance_fee       
      ,pci_scans_monthly_fee        
      ,shieldconex_fields_fee       
      ,shieldconex_monthly_fee      
      ,shieldconex_monthly_minimum  
      ,shieldconex_transaction_fee  
      ,tokenization_fee 
      ,date_updated                 )
    SELECT 
         account_id 
        ,currency_iso_code 
        ,rate_date
        ,exchange_rate
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
        ,SUM(tokenization_fee)              AS tokenization_fee
        ,MAX(date_updated)                  AS date_updated
      FROM (
          SELECT
               accountid                                                                                    AS account_id
              ,currency_iso_code                                                                                         AS currency_iso_code
              ,NULL                                                                                         AS rate_date 
              ,NULL                                                                                         AS exchange_rate
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
              ,(COALESCE(fee_name__c, '') = 'Tokenization Fee')             * COALESCE(fee_amount__c, 0.00) AS tokenization_fee
              ,CURRENT_TIMESTAMP                                                                            AS date_updated
            FROM sales_force.asset 
      ) t1 
     GROUP BY 1, 2, 3, 4
    ;
    
    -- we need a 'table' that has all of the rows in auto_billing_staging.exchange_rate 
    -- for which rate_date is between the first of the previous month to the last of the previous month 
    -- relative to the current date.
    -- a view has been created for this purpose.
    -- see sample query and data below:
    
    SELECT 2;
  
    SELECT * FROM auto_billing_staging.v_exchange_rates_last_month;
  
    --     rate_date |currency_iso_code|exchange_rate|
    --     ----------|-----------------|-------------|
    --     2020-12-01|CAD              |   0.78474300|
    --     2020-12-01|EUR              |   1.22637300|
    --     2020-12-01|USD              |   1.00000000|
    --     this query was exceuted on 2021-01-20; so the rate_date that time would have been 2020-12-01
      
    SELECT 3; 
  
    UPDATE auto_billing_staging.stg_asset                           asst
      LEFT JOIN auto_billing_staging.v_exchange_rates_last_month    er
        ON asst.currency_iso_code = er.currency_iso_code 
       SET asst.currency_iso_code = er.currency_iso_code
          ,asst.rate_date         = er.rate_date
          ,asst.exchange_rate     = er.exchange_rate
     WHERE TRUE 
    ;
    
END 