UPDATE auto_billing_dw.f_auto_billing_complete  t1 
  JOIN sales_force.account                      acct 
    ON t1.cardconex_acct_id = acct.id 
  JOIN sales_force.identification_number__c     idn
    ON acct.id = idn.accountid__c 
   SET payconex_acct_id = idn.name
 WHERE idn.type__c = 'PayConex'
   AND idn.name REGEXP '^[0-9]*$'
;
