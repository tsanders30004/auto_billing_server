TRUNCATE auto_billing_staging.stg_payconex_cardconex_map;
SET @n = 0;

LOAD DATA LOCAL INFILE '~/dir_source_default/payconex_cardconex_map_202101.csv'
INTO TABLE auto_billing_staging.stg_payconex_cardconex_map
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@col01
,@col02)
SET 
 payconex_acct_id = @col01
,cardconex_acct_id = @col02
,source_file = 'payconex_cardconex_map_202101.csv'
,source_row = @n := @n + 1
;


