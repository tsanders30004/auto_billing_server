CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `auto_billing_dw`.`update_billing_demographics`()
    COMMENT 'USAGE:  update_billing_demographics */ Updates several demographic columns. */'
BEGIN
  
    UPDATE auto_billing_dw.f_auto_billing_complete_shieldconex    abc
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
      
END
