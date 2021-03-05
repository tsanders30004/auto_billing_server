TRUNCATE auto_billing_staging.stg_decryptx_cardconex_map;
SET @n = 0;

LOAD DATA LOCAL INFILE '~/dir_source_default/decryptx_cardconex_map_202101.csv'
INTO TABLE auto_billing_staging.stg_decryptx_cardconex_map
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@col01
,@col02
,@col03
,@col04
,@col05
,@col06
)
SET 
 decryptx_acct_id = @col01
,decryptx_acct_name = @col02
,decryptx_partner_id = @col03
,decryptx_partner_name = @col04
,cardconex_acct_id = @col05
,source_file = 'decryptx_cardconex_map_202101.csv'
,source_row = @n := @n + 1
;


