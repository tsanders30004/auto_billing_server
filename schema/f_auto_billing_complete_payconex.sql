Procedure	sql_mode	Create Procedure	character_set_client	collation_connection	Database Collation
f_auto_billing_complete_payconex	STRICT_TRANS_TABLES	CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `f_auto_billing_complete_payconex`()\nBEGIN\n  \n    SET @stage = 0; \n    \n    SELECT 'Executing Stored Procedure' AS operation, 'f_auto_billing_complete_payconex' AS stored_procedure, CURRENT_TIMESTAMP;\n\n    SELECT 'calculating group_count' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;\n    \n    UPDATE auto_billing_dw.f_auto_billing_complete_2      abc \n      JOIN (\n          SELECT\n               pcm.cardconex_acct_id \n              ,SUM(group_count) AS group_count\n            FROM auto_billing_staging.stg_payconex_volume       pv \n            JOIN auto_billing_staging.stg_payconex_cardconex_map  pcm \n              ON pv.acct_id = pcm.payconex_acct_id \n           GROUP BY 1\n      ) t1 \n        ON abc.account_id = t1.cardconex_acct_id \n       SET abc.group_count = t1.group_count \n     WHERE TRUE\n    ;\n    \n    SELECT 'calculating group_charge' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;\n    \n    UPDATE auto_billing_dw.f_auto_billing_complete_2    abc\n      JOIN auto_billing_staging.stg_asset               asst\n        ON abc.account_id = asst.account_id\n    -- SET abc.group_charge = abc.group_count * asst.group_tag_fee \n       SET abc.group_charge = IF (group_count = 0, 0, group_count - 1) * asst.group_tag_fee    -- 13 jan 2021\n     WHERE TRUE \n    ;\n    \n    SELECT 'calculating user_count' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;\n    \n    UPDATE auto_billing_dw.f_auto_billing_complete_2 abc \n      JOIN (\n          SELECT \n               pcm.cardconex_acct_id  AS account_id \n              ,SUM(pv.user_count)     AS user_count\n            FROM auto_billing_staging.stg_payconex_volume           pv\n            JOIN auto_billing_staging.stg_payconex_cardconex_map    pcm\n              ON pv.acct_id = pcm.payconex_acct_id \n           GROUP BY 1  \n      ) t1 \n        ON abc.account_id = t1.account_id\n       SET abc.user_count = t1.user_count \n     WHERE TRUE \n    ;\n    \n    DROP TABLE IF EXISTS auto_billing_dw.tmp_vol_charges;\n    \n    CREATE TABLE auto_billing_dw.tmp_vol_charges(\n       payconex_acct_id                      VARCHAR(12)\n      ,account_id                            VARCHAR(18) \n      ,ach_noc_message_charge                DECIMAL(12, 5) NOT NULL DEFAULT 0.00000\n      ,ach_returnerror_charge                DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 \n      ,ach_sale_volume_charge                DECIMAL(12, 5) NOT NULL DEFAULT 0.00000\n      ,achworks_credit_charge                DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 \n      ,achworks_monthly_charge               DECIMAL(12, 5) NOT NULL DEFAULT 0.00000\n      ,achworks_per_trans_charge             DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 \n      ,apriva_monthly_charge                 DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 \n      ,card_convenience_charge               DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 \n      ,cc_sale_charge                        DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 \n      ,file_transfer_monthly_charge          DECIMAL(12, 5) NOT NULL DEFAULT 0.00000\n      ,gw_monthly_charge                     DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 \n      ,gw_per_auth_charge                    DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  \n      ,gw_per_auth_decline_charge            DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  \n      ,gw_per_credit_charge                  DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  \n      ,gw_per_refund_charge                  DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  \n      ,gw_per_token_charge                   DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  \n      ,gw_reissued_ach_trans_charge          DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  \n      ,gw_reissued_charge                    DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  \n      ,misc_monthly_charge                   DECIMAL(12, 5) NOT NULL DEFAULT 0.00000   \n      ,p2pe_encryption_charge                DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  \n      ,p2pe_token_charge                     DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  \n      ,p2pe_token_flat_charge                DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 \n      ,p2pe_token_flat_monthly_charge        DECIMAL(12, 5) NOT NULL DEFAULT 0.00000 \n      ,pc_account_updater_monthly_charge     DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  \n      ,pci_scans_monthly_charge              DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  \n      ,tokenization_charge                   DECIMAL(12, 5) NOT NULL DEFAULT 0.00000  \n      ,UNIQUE(payconex_acct_id)         -- i think, but am not sure, that this is valid\n    ) ENGINE=InnoDB DEFAULT CHARSET=latin1\n    ;\n      \n    SELECT 'calculating *_charge' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;\n    \n    INSERT INTO auto_billing_dw.tmp_vol_charges(\n       payconex_acct_id                 \n      ,account_id                       \n      ,ach_noc_message_charge           \n      ,ach_returnerror_charge           \n      ,ach_sale_volume_charge           \n      ,achworks_credit_charge           \n      ,achworks_monthly_charge          \n      ,achworks_per_trans_charge        \n      ,apriva_monthly_charge            \n      ,card_convenience_charge          \n      ,cc_sale_charge                   \n      ,file_transfer_monthly_charge     \n      ,gw_monthly_charge                \n      ,gw_per_auth_charge               \n      ,gw_per_auth_decline_charge       \n      ,gw_per_credit_charge             \n      ,gw_per_refund_charge             \n      ,gw_per_token_charge              \n      ,gw_reissued_ach_trans_charge     \n      ,gw_reissued_charge               \n      ,misc_monthly_charge              \n      ,p2pe_encryption_charge           \n      ,p2pe_token_charge                \n      ,p2pe_token_flat_charge           \n      ,p2pe_token_flat_monthly_charge   \n      ,pc_account_updater_monthly_charge\n      ,pci_scans_monthly_charge         \n      ,tokenization_charge                  \n    )\n    SELECT \n         pvd.acct_id AS payconex_acct_id\n        ,pcm.cardconex_acct_id \n        ,COALESCE(asst.ach_noc_fee,                 0.0) *  COALESCE(pvd.ach_noc_messages,          0.0)                                                 AS ach_noc_message_charge\n        ,COALESCE(asst.ach_return_error_fee,        0.0) * (COALESCE(pvd.ach_returns,               0.0) + COALESCE(pvd.ach_errors, 0.0))                AS ach_returnerror_charge\n        ,COALESCE(asst.bfach_discount_rate / 100.0, 0.0) *  COALESCE(pvd.ach_sale_vol ,             0.0)                                                 AS ach_sale_volume_charge               \n        ,COALESCE(asst.ach_credit_fee,              0.0) * (COALESCE(pvd.ach_sale_trans,            0.0) + COALESCE(pvd.ach_credit_trans, 0.0))          AS achworks_credit_charge\n        ,COALESCE(asst.ach_monthly_fee,             0.0)                                                                                                 AS achworks_monthly_charge\n        ,COALESCE(asst.ach_per_gw_trans_fee,        0.0) * (COALESCE(pvd.ach_sale_trans,            0.0) + COALESCE(pvd.ach_credit_trans, 0.0))          AS achworks_per_trans_charge\n        ,0.0                                                                                                                                             AS apriva_monthly_charge                -- placeholder\n        ,0.0                                                                                                                                             AS card_convenience_charge              -- placeholder\n        ,COALESCE(asst.gw_per_sale_fee,             0.0) *  COALESCE(pvd.cc_sale_trans,             0.0)                                                 AS cc_sale_charge\n        ,COALESCE(asst.file_transfer_monthly_fee,   0.0)                                                                                                 AS file_transfer_monthly_charge\n        ,0.0                                                                                                                                             AS gw_monthly_charge                    -- placeholder\n        ,COALESCE(asst.per_transaction_fee,         0.0) * (COALESCE(pvd.cc_auth_trans,             0.0) + COALESCE(pvd.tokens_stored, 0.0))             AS gw_per_auth_charge\n        ,COALESCE(asst.gw_per_auth_decline_fee,     0.0) *  COALESCE(pvd.cc_auth_decline_trans,     0.0)                                                 AS gw_per_auth_decline_charge\n        ,COALESCE(asst.gw_per_credit_fee,           0.0) *  COALESCE(pvd.cc_credit_trans,           0.0)                                                 AS gw_per_credit_charge\n        ,COALESCE(asst.gw_per_refund_fee,           0.0) *  COALESCE(pvd.cc_ref_trans,              0.0)                                                 AS gw_per_refund_charge\n        ,COALESCE(asst.gw_per_token_fee,            0.0) *  COALESCE(pvd.tokens_stored,             0.0)                                                 AS gw_per_token_charge\n        ,COALESCE(asst.gw_reissued_fee,             0.0) *  COALESCE(pvd.reissued_ach_transactions, 0.0)                                                 AS gw_reissued_ach_trans_charge\n        ,COALESCE(asst.gw_reissued_fee,             0.0) *  COALESCE(pvd.reissued_cc_transactions,  0.0)                                                 AS gw_reissued_charge\n        ,0.0                                                                                                                                             AS misc_monthly_charge                  -- placeholder \n        ,0.0                                                                                                                                             AS p2pe_encryption_charge               -- placeholder\n        ,COALESCE(asst.p2pe_tokenization_fee,       0.0) *  COALESCE(pvd.p2pe_tokens_stored,        0.0)                                                 AS p2pe_token_charge\n        ,COALESCE(asst.p2pe_monthly_flat_fee,       0.0)                                                                                                 AS p2pe_token_flat_charge\n        ,COALESCE(asst.one_time_key_injection_fees, 0.0)                                                                                                 AS p2pe_token_flat_monthly_charge\n        ,0.0                                                                                                                                             AS pc_account_updater_monthly_charge    -- placeholder\n        ,COALESCE(asst.pci_scans_monthly_fee,       0.0) * (COALESCE(pvd.reissued_cc_transactions,  0.0) + COALESCE(pvd.reissued_ach_transactions, 0.0)) AS pci_scans_monthly_charge\n        ,COALESCE(asst.tokenization_fee,            0.0) * (COALESCE(pvd.cc_auth_trans,             0.0)\n                                                           +COALESCE(pvd.tokens_stored,             0.0)\n                                                           +COALESCE(pvd.cc_auth_decline_trans,     0.0)\n                                                           +COALESCE(pvd.cc_credit_trans,           0.0)\n                                                           +COALESCE(pvd.cc_ref_trans,              0.0))                                                AS tokenization_charge \n      FROM auto_billing_staging.stg_payconex_volume           pvd    \n      JOIN auto_billing_staging.stg_payconex_cardconex_map    pcm    \n        ON pvd.acct_id = pcm.payconex_acct_id \n      LEFT JOIN auto_billing_staging.stg_asset                asst \n        ON pcm.cardconex_acct_id = asst.account_id\n    ;\n\n    -- 7 jan 2021\n    -- need to add rows for decryptx-only; i.e., no row in stg_payconex_cardconex_map\n    INSERT INTO auto_billing_dw.tmp_vol_charges(\n       payconex_acct_id                 \n      ,account_id                       \n      ,ach_noc_message_charge           \n      ,ach_returnerror_charge           \n      ,ach_sale_volume_charge           \n      ,achworks_credit_charge           \n      ,achworks_monthly_charge          \n      ,achworks_per_trans_charge        \n      ,apriva_monthly_charge            \n      ,card_convenience_charge          \n      ,cc_sale_charge                   \n      ,file_transfer_monthly_charge     \n      ,gw_monthly_charge                \n      ,gw_per_auth_charge               \n      ,gw_per_auth_decline_charge       \n      ,gw_per_credit_charge             \n      ,gw_per_refund_charge             \n      ,gw_per_token_charge              \n      ,gw_reissued_ach_trans_charge     \n      ,gw_reissued_charge               \n      ,misc_monthly_charge              \n      ,p2pe_encryption_charge           \n      ,p2pe_token_charge                \n      ,p2pe_token_flat_charge           \n      ,p2pe_token_flat_monthly_charge   \n      ,pc_account_updater_monthly_charge\n      ,pci_scans_monthly_charge         \n      ,tokenization_charge\n    )\n    SELECT \n       NULL                                      AS payconex_acct_id\n      ,asst.account_id                           AS account_id\n      ,0                                         AS ach_noc_message_charge\n      ,0                                         AS ach_returnerror_charge\n      ,0                                         AS ach_sale_volume_charge               \n      ,0                                         AS achworks_credit_charge\n      ,0                                         AS achworks_monthly_charge\n      ,0                                         AS achworks_per_trans_charge\n      ,0                                         AS apriva_monthly_charge                \n      ,0                                         AS card_convenience_charge              \n      ,0                                         AS cc_sale_charge\n      ,0                                         AS file_transfer_monthly_charge\n      ,0                                         AS gw_monthly_charge                    \n      ,0                                         AS gw_per_auth_charge\n      ,0                                         AS gw_per_auth_decline_charge\n      ,0                                         AS gw_per_credit_charge\n      ,0                                         AS gw_per_refund_charge\n      ,0                                         AS gw_per_token_charge\n      ,0                                         AS gw_reissued_ach_trans_charge\n      ,0                                         AS gw_reissued_charge\n      ,0                                         AS misc_monthly_charge                   \n      ,0                                         AS p2pe_encryption_charge               -- placeholder (yes) \n      ,0                                         AS p2pe_token_charge\n      ,asst.p2pe_monthly_flat_fee                AS p2pe_token_flat_charge  -- yes\n      ,asst.one_time_key_injection_fees          AS p2pe_token_flat_monthly_charge       -- yes\n      ,0                                         AS pc_account_updater_monthly_charge    -- yes -- placeholder\n      ,0                                         AS pci_scans_monthly_charge     \n      ,0                                         AS tokenization_charge                  -- 17 feb 2021: does not apply.\n   FROM auto_billing_staging.stg_asset     asst\n   LEFT JOIN auto_billing_staging.stg_payconex_cardconex_map   pcm\n     ON asst.account_id = pcm.cardconex_acct_id\n   LEFT JOIN sales_force.account acct \n     ON asst.account_id = acct.id\n  WHERE pcm.payconex_acct_id IS NULL\n  ;\n    SELECT 'calculating card_convenience_charge and pc_account_updater_monthly_charge' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;\n    \n    UPDATE auto_billing_dw.tmp_vol_charges\n       SET card_convenience_charge           = 0.0\n          ,pc_account_updater_monthly_charge = 0.0\n     WHERE TRUE \n    ;\n    \n    DROP TABLE IF EXISTS auto_billing_dw.tmp_mid_count;\n    \n    CREATE TABLE auto_billing_dw.tmp_mid_count(\n         account_id   VARCHAR(18)\n        ,mid_count    SMALLINT UNSIGNED\n        ,update_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP\n        ,PRIMARY KEY(account_id)\n    );\n    \n    SELECT 'calculating nmid_count' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;\n    \n    INSERT INTO auto_billing_dw.tmp_mid_count(account_id, mid_count)\n    SELECT \n         pcm.cardconex_acct_id \n        ,COUNT(DISTINCT pvd.acct_id   ) AS mid_count \n      FROM auto_billing_staging.stg_payconex_volume           pvd\n      JOIN auto_billing_staging.stg_payconex_cardconex_map    pcm\n        ON pvd.acct_id = pcm.payconex_acct_id \n     GROUP BY 1\n    ;\n    \n    SELECT 'calculating apriva_monthly_charge, gw_monthly_charge, and misc_monthly_charge' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;\n    \n    UPDATE auto_billing_dw.tmp_vol_charges                pv \n      LEFT JOIN auto_billing_staging.stg_asset            asst \n        ON pv.account_id = asst.account_id\n      LEFT JOIN auto_billing_dw.tmp_mid_count             mc \n        ON pv.account_id = mc.account_id \n       SET pv.apriva_monthly_charge = COALESCE(asst.bluefin_gateway_discount_rate, 0.0) * COALESCE(mc.mid_count, 0)\n          ,pv.gw_monthly_charge     = COALESCE(asst.gateway_monthly_fee,           0.0) * COALESCE(mc.mid_count, 0)\n          ,pv.misc_monthly_charge   = COALESCE(asst.misc_monthly_fees,             0.0) * COALESCE(mc.mid_count, 0)\n     WHERE TRUE \n    ;\n     \n    SELECT 'updating auto_billing_dw.f_auto_billing_complete_2 (1 of 3)' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;\n    \n    UPDATE auto_billing_dw.f_auto_billing_complete_2 abc\n      JOIN (\n          SELECT\n               account_id \n              ,SUM(ach_noc_message_charge           ) AS ach_noc_message_charge           \n              ,SUM(ach_returnerror_charge           ) AS ach_returnerror_charge           \n              ,SUM(ach_sale_volume_charge           ) AS ach_sale_volume_charge           \n              ,SUM(achworks_credit_charge           ) AS achworks_credit_charge           \n              ,MAX(achworks_monthly_charge          ) AS achworks_monthly_charge            -- changed SUM to MAX\n              ,SUM(achworks_per_trans_charge        ) AS achworks_per_trans_charge        \n              ,SUM(apriva_monthly_charge            ) AS apriva_monthly_charge            \n              ,SUM(card_convenience_charge          ) AS card_convenience_charge          \n              ,SUM(cc_sale_charge                   ) AS cc_sale_charge                   \n              ,SUM(file_transfer_monthly_charge     ) AS file_transfer_monthly_charge             \n              ,MAX(gw_monthly_charge                ) AS gw_monthly_charge                \n              ,SUM(gw_per_auth_charge               ) AS gw_per_auth_charge               \n              ,SUM(gw_per_auth_decline_charge       ) AS gw_per_auth_decline_charge       \n              ,SUM(gw_per_credit_charge             ) AS gw_per_credit_charge             \n              ,SUM(gw_per_refund_charge             ) AS gw_per_refund_charge             \n              ,SUM(gw_per_token_charge              ) AS gw_per_token_charge              \n              ,SUM(gw_reissued_ach_trans_charge     ) AS gw_reissued_ach_trans_charge     \n              ,SUM(gw_reissued_charge               ) AS gw_reissued_charge               \n              ,MAX(misc_monthly_charge              ) AS misc_monthly_charge                -- changed SUM to MAX                    \n              ,SUM(p2pe_token_charge                ) AS p2pe_token_charge                \n              ,MAX(p2pe_token_flat_charge           ) AS p2pe_token_flat_charge           \n              ,MAX(p2pe_token_flat_monthly_charge   ) AS p2pe_token_flat_monthly_charge   \n              ,SUM(pc_account_updater_monthly_charge) AS pc_account_updater_monthly_charge\n              ,SUM(pci_scans_monthly_charge         ) AS pci_scans_monthly_charge  \n              ,SUM(tokenization_charge              ) AS tokenization_charge \n            FROM auto_billing_dw.tmp_vol_charges\n           GROUP BY 1  \n      ) t1 \n        ON abc.account_id = t1.account_id \n      SET  abc.ach_noc_message_charge            = t1.ach_noc_message_charge           \n          ,abc.ach_returnerror_charge            = t1.ach_returnerror_charge           \n          ,abc.ach_sale_volume_charge            = t1.ach_sale_volume_charge           \n          ,abc.achworks_credit_charge            = t1.achworks_credit_charge           \n          ,abc.achworks_monthly_charge           = t1.achworks_monthly_charge          \n          ,abc.achworks_per_trans_charge         = t1.achworks_per_trans_charge        \n          ,abc.apriva_monthly_charge             = t1.apriva_monthly_charge            \n          ,abc.card_convenience_charge           = t1.card_convenience_charge          \n          ,abc.cc_sale_charge                    = t1.cc_sale_charge                   \n          ,abc.file_transfer_monthly_charge      = t1.file_transfer_monthly_charge                        \n          ,abc.gw_monthly_charge                 = t1.gw_monthly_charge                \n          ,abc.gw_per_auth_charge                = t1.gw_per_auth_charge               \n          ,abc.gw_per_auth_decline_charge        = t1.gw_per_auth_decline_charge       \n          ,abc.gw_per_credit_charge              = t1.gw_per_credit_charge             \n          ,abc.gw_per_refund_charge              = t1.gw_per_refund_charge             \n          ,abc.gw_per_token_charge               = t1.gw_per_token_charge              \n          ,abc.gw_reissued_ach_trans_charge      = t1.gw_reissued_ach_trans_charge     \n          ,abc.gw_reissued_charge                = t1.gw_reissued_charge               \n          ,abc.misc_monthly_charge               = t1.misc_monthly_charge                       \n          ,abc.p2pe_token_charge                 = t1.p2pe_token_charge                \n          ,abc.p2pe_token_flat_charge            = t1.p2pe_token_flat_charge           \n          ,abc.p2pe_token_flat_monthly_charge    = t1.p2pe_token_flat_monthly_charge   \n          ,abc.pc_account_updater_monthly_charge = t1.pc_account_updater_monthly_charge\n          ,abc.pci_scans_monthly_charge          = t1.pci_scans_monthly_charge  \n          ,abc.tokenization_charge               = t1.tokenization_charge\n     WHERE TRUE \n    ;\n    \n    SELECT 'updating auto_billing_dw.f_auto_billing_complete_2 (2 of 3)' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;\n    \n    UPDATE auto_billing_dw.f_auto_billing_complete_2      abc \n      JOIN auto_billing_staging.stg_asset                 asst \n        ON abc.account_id = asst.account_id \n       SET abc.p2pe_encryption_charge = auto_billing_dw.calc_p2pe_encryption_charge(\n           p2pe_auth_trans         \n          ,p2pe_refund_trans       \n          ,p2pe_credit_trans       \n          ,p2pe_auth_decline_trans \n          ,p2pe_encryption_fee     \n          ,decryption_count)\n     WHERE TRUE \n    ;\n    \n    SELECT 'updating auto_billing_dw.f_auto_billing_complete_2 (3 of 3)' AS operation, @stage := @stage + 1 AS stage, CURRENT_TIMESTAMP;\n    \n    UPDATE auto_billing_dw.f_auto_billing_complete_2      abc \n      JOIN (\n          SELECT \n               pcm.cardconex_acct_id            AS account_id\n              ,SUM(ach_batches)                 AS ach_batches\n              ,SUM(ach_credit_trans)            AS ach_credit_trans\n              ,SUM(ach_credit_vol)              AS ach_credit_vol\n              ,SUM(ach_errors)                  AS ach_errors\n              ,SUM(ach_noc_messages)            AS ach_noc_messages\n              ,SUM(ach_returns)                 AS ach_returns\n              ,SUM(ach_sale_trans)              AS ach_sale_trans\n              ,SUM(ach_sale_vol)                AS ach_sale_vol\n              ,SUM(batch_files_processed)       AS batch_files_processed\n              ,SUM(cc_auth_decline_trans)       AS cc_auth_decline_trans\n              ,SUM(cc_auth_trans)               AS cc_auth_trans\n              ,SUM(cc_auth_vol)                 AS cc_auth_vol\n              ,SUM(cc_batches)                  AS cc_batches\n              ,SUM(cc_capture_trans)            AS cc_capture_trans\n              ,SUM(cc_capture_vol)              AS cc_capture_vol\n              ,SUM(cc_credit_trans)             AS cc_credit_trans\n              ,SUM(cc_credit_vol)               AS cc_credit_vol\n              ,SUM(cc_keyed_trans)              AS cc_keyed_trans\n              ,SUM(cc_keyed_vol)                AS cc_keyed_vol\n              ,SUM(cc_ref_trans)                AS cc_ref_trans\n              ,SUM(cc_ref_vol)                  AS cc_ref_vol\n              ,SUM(cc_sale_decline_trans)       AS cc_sale_decline_trans\n              ,SUM(cc_sale_trans)               AS cc_sale_trans\n              ,SUM(cc_sale_vol)                 AS cc_sale_vol\n              ,SUM(cc_swiped_trans)             AS cc_swiped_trans\n              ,SUM(cc_swiped_vol)               AS cc_swiped_vol\n              ,SUM(combined_decline_trans)      AS combined_decline_trans\n              ,SUM(p2pe_active_device_trans)    AS p2pe_active_device_trans\n              ,SUM(p2pe_auth_decline_trans)     AS p2pe_auth_decline_trans\n              ,SUM(p2pe_auth_trans)             AS p2pe_auth_trans\n              ,SUM(p2pe_auth_vol)               AS p2pe_auth_vol\n              ,SUM(p2pe_capture_trans)          AS p2pe_capture_trans\n              ,SUM(p2pe_capture_vol)            AS p2pe_capture_vol\n              ,SUM(p2pe_credit_trans)           AS p2pe_credit_trans\n              ,SUM(p2pe_credit_vol)             AS p2pe_credit_vol\n              ,SUM(p2pe_declined_trans)         AS p2pe_declined_trans\n              ,SUM(p2pe_inactive_device_trans)  AS p2pe_inactive_device_trans\n              ,SUM(p2pe_refund_trans)           AS p2pe_refund_trans\n              ,SUM(p2pe_refund_vol)             AS p2pe_refund_vol\n              ,SUM(p2pe_sale_decline_trans)     AS p2pe_sale_decline_trans\n              ,SUM(p2pe_sale_trans)             AS p2pe_sale_trans\n              ,SUM(p2pe_sale_vol)               AS p2pe_sale_vol\n              ,SUM(p2pe_tokens_stored)          AS p2pe_tokens_stored\n              ,SUM(reissued_ach_transactions)   AS reissued_ach_transactions\n              ,SUM(reissued_cc_transactions)    AS reissued_cc_transactions\n              ,SUM(tokens_stored)               AS tokens_stored\n            FROM auto_billing_staging.stg_payconex_volume         pvd \n            JOIN auto_billing_staging.stg_payconex_cardconex_map    pcm\n              ON pvd.acct_id = pcm.payconex_acct_id \n           GROUP BY 1\n      ) t1 ON abc.account_id              = t1.account_id\n       SET abc.ach_batches                = t1.ach_batches\n          ,abc.ach_credit_trans           = t1.ach_credit_trans\n          ,abc.ach_credit_vol             = t1.ach_credit_vol\n          ,abc.ach_errors                 = t1.ach_errors\n          ,abc.ach_noc_messages           = t1.ach_noc_messages\n          ,abc.ach_returns                = t1.ach_returns\n          ,abc.ach_sale_trans             = t1.ach_sale_trans\n          ,abc.ach_sale_vol               = t1.ach_sale_vol\n          ,abc.batch_files_processed      = t1.batch_files_processed\n          ,abc.cc_auth_decline_trans      = t1.cc_auth_decline_trans\n          ,abc.cc_auth_trans              = t1.cc_auth_trans\n          ,abc.cc_auth_vol                = t1.cc_auth_vol\n          ,abc.cc_batches                 = t1.cc_batches\n          ,abc.cc_capture_trans           = t1.cc_capture_trans\n          ,abc.cc_capture_vol             = t1.cc_capture_vol\n          ,abc.cc_credit_trans            = t1.cc_credit_trans\n          ,abc.cc_credit_vol              = t1.cc_credit_vol\n          ,abc.cc_keyed_trans             = t1.cc_keyed_trans\n          ,abc.cc_keyed_vol               = t1.cc_keyed_vol\n          ,abc.cc_ref_trans               = t1.cc_ref_trans\n          ,abc.cc_ref_vol                 = t1.cc_ref_vol\n          ,abc.cc_sale_decline_trans      = t1.cc_sale_decline_trans\n          ,abc.cc_sale_trans              = t1.cc_sale_trans\n          ,abc.cc_sale_vol                = t1.cc_sale_vol\n          ,abc.cc_swiped_trans            = t1.cc_swiped_trans\n          ,abc.cc_swiped_vol              = t1.cc_swiped_vol\n          ,abc.combined_decline_trans     = t1.combined_decline_trans\n          ,abc.p2pe_active_device_trans   = t1.p2pe_active_device_trans\n          ,abc.p2pe_auth_decline_trans    = t1.p2pe_auth_decline_trans\n          ,abc.p2pe_auth_trans            = t1.p2pe_auth_trans\n          ,abc.p2pe_auth_vol              = t1.p2pe_auth_vol\n          ,abc.p2pe_capture_trans         = t1.p2pe_capture_trans\n          ,abc.p2pe_capture_vol           = t1.p2pe_capture_vol\n          ,abc.p2pe_credit_trans          = t1.p2pe_credit_trans\n          ,abc.p2pe_credit_vol            = t1.p2pe_credit_vol\n          ,abc.p2pe_declined_trans        = t1.p2pe_declined_trans\n          ,abc.p2pe_inactive_device_trans = t1.p2pe_inactive_device_trans\n          ,abc.p2pe_refund_trans          = t1.p2pe_refund_trans\n          ,abc.p2pe_refund_vol            = t1.p2pe_refund_vol\n          ,abc.p2pe_sale_decline_trans    = t1.p2pe_sale_decline_trans\n          ,abc.p2pe_sale_trans            = t1.p2pe_sale_trans\n          ,abc.p2pe_sale_vol              = t1.p2pe_sale_vol\n          ,abc.p2pe_tokens_stored         = t1.p2pe_tokens_stored\n          ,abc.reissued_ach_transactions  = t1.reissued_ach_transactions\n          ,abc.reissued_cc_transactions   = t1.reissued_cc_transactions\n          ,abc.tokens_stored              = t1.tokens_stored\n      WHERE TRUE\n    ;\n\n\n\nEND	utf8	utf8_general_ci	latin1_swedish_ci
