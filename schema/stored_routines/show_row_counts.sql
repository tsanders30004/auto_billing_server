CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `auto_billing_dw`.`show_row_counts`()
BEGIN
  
SELECT 'calculating row counts...' AS message;
DROP TABLE IF EXISTS tmp_01;

CREATE TEMPORARY TABLE tmp_01
        SELECT 'auto_billing_dw' AS db, 'd_merchant' AS table_name
  UNION SELECT 'auto_billing_dw' AS db, 'd_pricing' AS table_name
  UNION SELECT 'auto_billing_dw' AS db, 'd_processor' AS table_name
  UNION SELECT 'auto_billing_staging' AS db, 'decryptx_device_day' AS table_name
  UNION SELECT 'auto_billing_dw' AS db, 'f_auto_billing_complete' AS table_name
  UNION SELECT 'auto_billing_dw' AS db, 'f_billing_month' AS table_name
  UNION SELECT 'auto_billing_dw' AS db, 'f_decryptx_day' AS table_name
  UNION SELECT 'auto_billing_dw' AS db, 'f_payconex_day' AS table_name
  UNION SELECT 'auto_billing_staging' AS db, 'payconex_volume_day' AS table_name
  UNION SELECT 'auto_billing_staging' AS db, 'stg_cardconex_account' AS table_name
  UNION SELECT 'auto_billing_staging' AS db, 'stg_decryptx_cardconex_map' AS table_name
  UNION SELECT 'auto_billing_staging' AS db, 'stg_decryptx_device_cardconex_map' AS table_name
  UNION SELECT 'auto_billing_staging' AS db, 'stg_device_detail' AS table_name
  UNION SELECT 'auto_billing_staging' AS db, 'stg_payconex_cardconex_map' AS table_name
  UNION SELECT 'auto_billing_staging' AS db, 'stg_payconex_volume' AS table_name
;

DROP TABLE IF EXISTS tmp_02;

CREATE TEMPORARY TABLE tmp_02 
        SELECT 'auto_billing_dw' AS db, 'd_merchant' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_dw.d_merchant GROUP BY 1, 2
  UNION SELECT 'auto_billing_dw' AS db, 'd_pricing' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_dw.d_pricing GROUP BY 1, 2
  UNION SELECT 'auto_billing_dw' AS db, 'd_processor' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_dw.d_processor GROUP BY 1, 2
  UNION SELECT 'auto_billing_staging' AS db, 'decryptx_device_day' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_staging.decryptx_device_day GROUP BY 1, 2
  UNION SELECT 'auto_billing_dw' AS db, 'f_auto_billing_complete' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_dw.f_auto_billing_complete GROUP BY 1, 2
  UNION SELECT 'auto_billing_dw' AS db, 'f_billing_month' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_dw.f_billing_month GROUP BY 1, 2
  UNION SELECT 'auto_billing_dw' AS db, 'f_decryptx_day' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_dw.f_decryptx_day GROUP BY 1, 2
  UNION SELECT 'auto_billing_dw' AS db, 'f_payconex_day' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_dw.f_payconex_day GROUP BY 1, 2
  UNION SELECT 'auto_billing_staging' AS db, 'payconex_volume_day' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_staging.payconex_volume_day GROUP BY 1, 2
  UNION SELECT 'auto_billing_staging' AS db, 'stg_cardconex_account' AS table_name, min(import_timestamp) AS min_date_updated, max(import_timestamp) AS max_date_updated, count(*) AS num_rows FROM auto_billing_staging.stg_cardconex_account GROUP BY 1, 2
  UNION SELECT 'auto_billing_staging' AS db, 'stg_decryptx_cardconex_map' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_staging.stg_decryptx_cardconex_map GROUP BY 1, 2
  UNION SELECT 'auto_billing_staging' AS db, 'stg_decryptx_device_cardconex_map' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_staging.stg_decryptx_device_cardconex_map GROUP BY 1, 2
  UNION SELECT 'auto_billing_staging' AS db, 'stg_device_detail' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_staging.stg_device_detail GROUP BY 1, 2
  UNION SELECT 'auto_billing_staging' AS db, 'stg_payconex_cardconex_map' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_staging.stg_payconex_cardconex_map GROUP BY 1, 2
  UNION SELECT 'auto_billing_staging' AS db, 'stg_payconex_volume' AS table_name, min(date_updated) AS min_date_updated, max(date_updated) AS max_date_updated, count(*) AS num_rows FROM auto_billing_staging.stg_payconex_volume GROUP BY 1, 2
    ;

DROP TABLE IF EXISTS tmp_03_row_counts;

CREATE TEMPORARY TABLE tmp_03_row_counts
SELECT 
     tmp_01.db
    ,tmp_01.table_name
    ,tmp_02.min_date_updated 
    ,tmp_02.max_date_updated
    ,dba.eng(tmp_02.num_rows) AS approx_no_rows
  FROM tmp_01
  LEFT JOIN tmp_02 
    ON tmp_01.db = tmp_02.db 
   AND tmp_01.table_name = tmp_02.table_name
 ORDER BY 4, 1, 2
;

ALTER TABLE tmp_03_row_counts ADD COLUMN notes VARCHAR (32);

UPDATE tmp_03_row_counts SET notes = 'recent updated not required' WHERE table_name = 'd_processor';
UPDATE tmp_03_row_counts SET notes = 'recent update required' WHERE table_name != 'd_processor';

SELECT * FROM tmp_03_row_counts ORDER BY 4, 1, 2 DESC, 2;

DROP TABLE IF EXISTS tmp_01;
DROP TABLE IF EXISTS tmp_02;

SELECT 'query auto_billing_dw.tmp_03_row_counts for more information' AS message;

END
