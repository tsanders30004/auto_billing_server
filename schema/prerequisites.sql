SELECT
     table_name 
    ,source_file
    ,num_rows
    ,min_date_updated 
    ,max_date_updated
    ,CASE CAST(REPLACE(LEFT(RIGHT(source_file, 21), 10), '-', '') AS DATE) >= DATE_FORMAT(DATE_FORMAT(CURRENT_DATE, '%Y%m01') - INTERVAL 1 DAY, '%Y-%m-%d')
        WHEN 1 THEN 'PASS'
        ELSE        'FAIL' END AS status
  FROM (
      SELECT 
          'auto_billing_staging.stg_device_detail' AS table_name
          ,source_file
          ,count(*) AS num_rows
          ,min(date_updated) AS min_date_updated 
          ,max(date_updated) AS max_date_updated
          -- ,concat('The date in source_file should be >= ', DATE_FORMAT(current_date, '%Y%m01') - INTERVAL 1 DAY, '.') AS message
          -- ,concat('device_detail.',  DATE_FORMAT(current_date, '%Y%m01') - INTERVAL 1 DAY, '
        FROM stg_device_detail
       GROUP BY 1, 2
       ORDER BY 1, 2
  ) t1
\G
 
CALL check_payconex_volume_day_files();

SELECT 
     table_name 
    ,source_file
    ,num_rows
    ,min_date_updated
    ,max_date_updated
    ,CASE DATE_FORMAT(CURRENT_DATE, '%Y%m01') - INTERVAL 1 DAY =  CAST(REPLACE(LEFT(RIGHT(source_file, 18), 10), '-', '') AS DATE)
        WHEN 1 THEN 'PASS'
        ELSE        'FAIL'
     END AS status
  FROM (
     SELECT 
        'auto_billing_staging.stg_payconex_volume' AS table_name
        ,source_file
        ,count(*) AS num_rows
        ,min(date_updated) AS min_date_updated 
        ,max(date_updated) AS max_date_updated
        -- ,concat('The date is source_file should be ', DATE_FORMAT(CURRENT_DATE, '%Y%m01') - INTERVAL 1 DAY, '.') AS message
      FROM stg_payconex_volume
     GROUP BY 1, 2
     ORDER BY 1, 2
  ) t1 
\G
 
SELECT 
    'auto_billing_staging.decryptx_device_day' AS table_name
    ,source_file
    ,count(*) AS num_rows
    ,min(date_updated) AS min_date_updated 
    ,max(date_updated) AS max_date_updated
  FROM decryptx_device_day
 WHERE report_date >= DATE_FORMAT(CURRENT_DATE, '%Y%m01') - INTERVAL 1 MONTH
 GROUP BY 1, 2
 ORDER BY 1, 2
\G

