CREATE DEFINER=`data_warehouse`@`172.16.63.%` FUNCTION `auto_billing_dw`.`calc_shieldconex_transaction_charge`(
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

END
