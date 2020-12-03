CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `auto_billing_dw`.`f_auto_billing_complete_demographics`()
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
  
  
END
