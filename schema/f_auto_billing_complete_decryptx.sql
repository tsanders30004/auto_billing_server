Procedure	sql_mode	Create Procedure	character_set_client	collation_connection	Database Collation
f_auto_billing_complete_decryptx	STRICT_TRANS_TABLES	CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `f_auto_billing_complete_decryptx`()\nBEGIN\n  \n    DECLARE last_of_last_month DATE;\n  \n    SELECT 'Executing Stored Procedure' AS operation, 'f_auto_billing_complete_decryptx' AS stored_procedure, CURRENT_TIMESTAMP;\n    \n    SET last_of_last_month = CONVERT(DATE_FORMAT(CURRENT_DATE, '%Y%m01'), DATE) - INTERVAL 1 DAY;\n      \n    SET @stage = 0;\n  \n    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP; \n    \n    UPDATE auto_billing_dw.f_auto_billing_complete_2      abc \n      JOIN (\n          SELECT\n              COALESCE(ddcm.cardconex_acct_id, dcm.cardconex_acct_id)         AS account_id\n             ,SUM(ddd.decryptions_mtd)                                        AS decryptions_mtd\n            FROM auto_billing_staging.decryptx_device_day                     ddd \n            LEFT JOIN auto_billing_staging.stg_decryptx_device_cardconex_map  ddcm ON ddd.poi_device_id = ddcm.decryptx_device_id \n            LEFT JOIN auto_billing_staging.stg_decryptx_cardconex_map         dcm  ON ddd.custodian_id  = dcm.decryptx_acct_id\n           WHERE ddd.report_date = last_of_last_month\n           GROUP BY 1\n      ) ddd\n        ON abc.account_id = ddd.account_id\n       SET abc.decryption_count = COALESCE(ddd.decryptions_mtd, 0)\n     WHERE TRUE \n    ;\n    \n    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;\n    \n    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc \n      JOIN (\n          SELECT     \n               dca.account_id \n              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_activated_count\n            FROM auto_billing_staging.decryptx_device_day             ddd\n            JOIN auto_billing_staging.tmp_device_account_id   dca \n              ON ddd.poi_device_id = dca.poi_device_id\n           WHERE ddd.report_date =  last_of_last_month\n             AND ddd.state = 'Activated'\n           GROUP BY 1\n      ) t1 \n        ON tdc.account_id = t1.account_id \n       SET tdc.device_activated_count = t1.device_activated_count\n      WHERE TRUE \n    ; \n    \n    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;\n    \n    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc \n      JOIN (\n          SELECT     \n               dca.account_id \n              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_activating_activated_count\n            FROM auto_billing_staging.decryptx_device_day             ddd\n            JOIN auto_billing_staging.tmp_device_account_id   dca \n              ON ddd.poi_device_id = dca.poi_device_id\n           WHERE ddd.report_date =  last_of_last_month\n             AND ddd.state = 'Activating'\n             AND ddd.decryptions_mtd > 0\n           GROUP BY 1\n      ) t1 \n        ON tdc.account_id = t1.account_id \n       SET tdc.device_activating_activated_count = t1.device_activating_activated_count\n      WHERE TRUE \n    ; \n    \n    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;\n    \n    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc \n      JOIN (\n          SELECT     \n               dca.account_id \n              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_activating_count\n            FROM auto_billing_staging.decryptx_device_day             ddd\n            JOIN auto_billing_staging.tmp_device_account_id   dca \n              ON ddd.poi_device_id = dca.poi_device_id\n           WHERE ddd.report_date =  last_of_last_month\n             AND ddd.state = 'Activating'\n           GROUP BY 1\n      ) t1 \n        ON tdc.account_id = t1.account_id \n       SET tdc.device_activating_count = t1.device_activating_count\n      WHERE TRUE \n    ; \n    \n    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;\n    \n    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc \n      JOIN (\n          SELECT     \n               dca.account_id \n              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_other_activated_count\n            FROM auto_billing_staging.decryptx_device_day             ddd\n            JOIN auto_billing_staging.tmp_device_account_id   dca \n              ON ddd.poi_device_id = dca.poi_device_id\n           WHERE ddd.report_date =  last_of_last_month\n             AND ddd.state NOT IN ('Activated', 'Activating', 'Stored')\n             AND ddd.decryptions_mtd > 0\n           GROUP BY 1\n      ) t1 \n        ON tdc.account_id = t1.account_id \n       SET tdc.device_other_activated_count = t1.device_other_activated_count\n      WHERE TRUE \n    ; \n    \n    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;\n    \n    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc \n      JOIN (\n          SELECT     \n               dca.account_id \n              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_other_count\n            FROM auto_billing_staging.decryptx_device_day             ddd\n            JOIN auto_billing_staging.tmp_device_account_id   dca \n              ON ddd.poi_device_id = dca.poi_device_id\n           WHERE ddd.report_date =  last_of_last_month\n             AND ddd.state NOT IN ('Activated', 'Activating', 'Stored')\n           GROUP BY 1\n      ) t1 \n        ON tdc.account_id = t1.account_id \n       SET tdc.device_other_count = t1.device_other_count\n      WHERE TRUE \n    ; \n    \n    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;\n    \n    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc \n      JOIN (\n          SELECT     \n               dca.account_id \n              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_stored_activated_count\n            FROM auto_billing_staging.decryptx_device_day             ddd\n            JOIN auto_billing_staging.tmp_device_account_id   dca \n              ON ddd.poi_device_id = dca.poi_device_id\n           WHERE ddd.report_date =  last_of_last_month\n             AND ddd.state = 'Stored'\n             AND ddd.decryptions_mtd > 0\n           GROUP BY 1\n      ) t1 \n        ON tdc.account_id = t1.account_id \n       SET tdc.device_stored_activated_count = t1.device_stored_activated_count\n      WHERE TRUE \n    ;\n    \n    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;\n    \n    UPDATE auto_billing_dw.f_auto_billing_complete_2     tdc \n      JOIN (\n          SELECT     \n               dca.account_id \n              ,COUNT(DISTINCT ddd.poi_device_id)                      AS device_stored_count\n            FROM auto_billing_staging.decryptx_device_day             ddd\n            JOIN auto_billing_staging.tmp_device_account_id   dca \n              ON ddd.poi_device_id = dca.poi_device_id\n           WHERE ddd.report_date =  last_of_last_month\n             AND ddd.state = 'Stored'\n           GROUP BY 1\n      ) t1 \n        ON tdc.account_id = t1.account_id \n       SET tdc.device_stored_count = t1.device_stored_count\n      WHERE TRUE \n    ;\n    \n    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;\n    \n    UPDATE auto_billing_dw.f_auto_billing_complete_2\n       SET device_activated_count               = COALESCE(device_activated_count           , 0.0000) \n          ,device_activating_activated_count    = COALESCE(device_activating_activated_count, 0.0000) \n          ,device_activating_count              = COALESCE(device_activating_count          , 0.0000) \n          ,device_other_activated_count         = COALESCE(device_other_activated_count     , 0.0000) \n          ,device_other_count                   = COALESCE(device_other_count               , 0.0000) \n          ,device_stored_activated_count        = COALESCE(device_stored_activated_count    , 0.0000) \n          ,device_stored_count                  = COALESCE(device_stored_count, 0.0000) \n     WHERE decryptx = 1\n    ;\n    \n    SELECT 'updating' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;\n        \n    UPDATE auto_billing_dw.f_auto_billing_complete_2    abc \n      JOIN auto_billing_staging.stg_asset               asst \n        ON abc.account_id = asst.account_id\n       SET abc.p2pe_device_activated_charge  = asst.p2pe_device_activated      * (abc.device_activated_count + abc.device_activating_activated_count + abc.device_stored_activated_count + abc.device_other_activated_count)\n          ,abc.p2pe_device_activating_charge = asst.p2pe_device_activating_fee * (abc.device_activating_count - abc.device_activating_activated_count)\n          ,abc.p2pe_device_stored_charge     = asst.p2pe_device_stored_fee     * (abc.device_stored_count - abc.device_stored_activated_count)\n     WHERE TRUE \n    ;\n    \nEND	utf8	utf8_general_ci	latin1_swedish_ci
