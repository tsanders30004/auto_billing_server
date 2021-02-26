TRUNCATE auto_billing_staging.stg_trustwave;
SET @n = 0;

LOAD DATA LOCAL INFILE '~/dir_source_default/Merchant_Detail_Report-2021-01-20_3_34_24_AM.csv'
INTO TABLE auto_billing_staging.stg_trustwave
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES(
 @col01
,@col02
,@col03
,@col04
,@col05
,@col06
,@col07
,@col08
,@col09
,@col10
,@col11
,@col12
,@col13
,@col14
,@col15
,@col16
,@col17
,@col18
,@col19
,@col20
,@col21
,@col22
,@col23
,@col24
,@col25
,@col26
,@col27
,@col28
,@col29
,@col30
,@col31
,@col32
,@col33
,@col34
,@col35
,@col36
,@col37
,@col38
,@col39
,@col40
,@col41
,@col42
,@col43
,@col44
,@col45
,@col46
,@col47
,@col48
,@col49
,@col50
,@col51
,@col52
,@col53
,@col54
,@col55
,@col56
,@col57
,@col58
,@col59
,@col60
,@col61
,@col62
,@col63
,@col64
,@col65
,@col66
,@col67
,@col68
,@col69
,@col70)
SET 
 customer_id                    = @col01
,company_name                   = @col02
,mid                            = @col03
,primary_mid                    = @col04
,merchant_type                  = @col05
,compliance_program             = @col06
,date_added                     = dba.text_to_date(@col07)                          -- convert 'YYYY-MM-DD' (VARCHAR 10) to DATE
,date_registered                = dba.text_to_date(@col08)
,registration_code              = @col09
,initial_certification_deadline = dba.text_to_date(@col10)
,pci_status                     = @col11
,pci_expiry                     = dba.text_to_date(@col12)
,first_certification_date       = dba.text_to_date(@col13)
,scan_status                    = @col14
,most_recent_scan_date          = dba.text_to_date(@col15)
,scan_expiry                    = dba.text_to_date(@col16)
,scan_location_count            = IF(LENGTH(@col17) = 0, NULL, scan_location_count) -- convert empty string to INT
,saq_status                     = @col18
,saq_type                       = @col19
,saq_version                    = @col20
,saq_document_type              = @col21
,most_recent_saq_date           = dba.text_to_date(@col22)
,saq_expiry                     = dba.text_to_date(@col23)
,pa_dss_status                  = @col24
,pci_milestone_1                = @col25
,pci_milestone_2                = @col26
,pci_milestone_3                = @col27
,pci_milestone_4                = @col28
,pci_milestone_5                = @col29
,pci_milestone_6                = @col30
,ec_psp_status                  = @col31
,sp_status                      = @col32
,expected_compliance_program    = @col33
,mid_status                     = @col34
,pre_registration_link          = @col35
,chain_id                       = @col36
,sponsor_name                   = @col37
,relationship_type              = @col38
,assessor                       = @col39
,service_providers              = @col40
,primary_user_first_name        = @col41
,primary_user_last_name         = @col42
,primary_user_email             = @col43
,primary_user_phone             = @col44
,primary_user_username          = @col45
,primary_user_language          = @col46
,pci_level                      = @col47
,country                        = @col48
,state_province                 = @col49
,close_date                     = dba.text_to_date(@col50)
,last_login_date                = dba.text_to_date(@col51)
,industry                       = @col52
,mcc                            = IF(LENGTH(@col53) = 0, NULL, mcc)
,pre_registration_email         = @col54
,pre_registration_phone         = @col55
,in_play_date                   = @col56
,marketing_call_campaign        = @col57
,marketing_email_campaign       = @col58
,marketing_direct_campaign      = @col59
,offering_type_override         = @col60
,offering_expiry                = dba.text_to_date(@col61)
,external_mid                   = @col62
,last_four_of_mid               = @col63
,breach_coverage_option         = @col64
,integrator_reseller_name       = @col65
,qir_status                     = @col66
,program_date_added             = @col67
,last_offering_change_date      = @col68
,last_scan_attestation_date     = dba.text_to_date(@col69)
,scan_attestation_expiry_date   = dba.text_to_date(@col70)
,source_file                    = 'Merchant_Detail_Report-2021-01-20_3_34_24_AM.csv'
,source_row                     = @n := @n + 1
;
