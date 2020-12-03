CREATE DEFINER=`data_warehouse`@`172.16.63.%` FUNCTION `auto_billing_dw`.`calc_shieldconex_monthly_minimum_charge`(
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
  
END
