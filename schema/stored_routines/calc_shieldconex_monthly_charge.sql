CREATE DEFINER=`data_warehouse`@`172.16.63.%` FUNCTION `auto_billing_dw`.`calc_shieldconex_monthly_charge`(f_shieldconex_monthly_fee DECIMAL(12, 5)) RETURNS decimal(12,5)
    COMMENT 'USAGE: calc_shieldconex_monthly_charge(shieldconex_monthly_fee) /* calculates calc_shieldconex_monthly_charge */'
BEGIN
  
  -- this funciton is trivial; it is being added so that if the defintion changes later, it will only be necessary for change the function;
  -- i.e., to faciliate maintenance.
  
  RETURN f_shieldconex_monthly_fee;
  
END
