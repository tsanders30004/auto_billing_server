CREATE DEFINER=`tsanders`@`172.16.63.%` PROCEDURE `auto_billing_dw`.`update_billing_frequency`()
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

END