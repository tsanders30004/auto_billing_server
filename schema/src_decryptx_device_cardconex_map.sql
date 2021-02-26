TRUNCATE auto_billing_staging.stg_decryptx_device_cardconex_map;
SET @n = 0;

LOAD DATA LOCAL INFILE '~/dir_source_default/decryptx_device_cardconex_map_202101.csv'
INTO TABLE auto_billing_staging.stg_decryptx_device_cardconex_map
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@col01
,@col02
,@col03)
SET 
 decryptx_device_id = @col01
,decryptx_location_id = @col02
,cardconex_acct_id = @col03
,source_file = 'decryptx_device_cardconex_map_202101.csv'
,source_row = @n := @n + 1
;


