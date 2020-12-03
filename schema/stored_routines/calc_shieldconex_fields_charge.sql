CREATE DEFINER=`data_warehouse`@`172.16.63.%` FUNCTION `auto_billing_dw`.`calc_shieldconex_fields_charge`(
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

END
