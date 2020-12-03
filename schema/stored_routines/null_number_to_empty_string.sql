CREATE DEFINER=`data_warehouse`@`172.16.63.%` FUNCTION `auto_billing_dw`.`null_number_to_empty_string`(n DECIMAL(16, 4)) RETURNS varchar(64) CHARSET latin1
BEGIN
  
  RETURN COALESCE(CONVERT(n USING latin1), '');

END
