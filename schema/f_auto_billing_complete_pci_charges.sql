Procedure	sql_mode	Create Procedure	character_set_client	collation_connection	Database Collation
f_auto_billing_complete_pci_charges	STRICT_TRANS_TABLES	CREATE DEFINER=`data_warehouse`@`172.16.63.%` PROCEDURE `f_auto_billing_complete_pci_charges`()\nBEGIN\n  \n      SELECT 'Executing Stored Procedure' AS operation, 'f_auto_billing_complete_pci_charges' AS stored_procedure, CURRENT_TIMESTAMP;\n\n      SET @first_of_last_month     = CONVERT(DATE_FORMAT(CURRENT_DATE - INTERVAL 1 MONTH, '%Y%m01'), DATE);\n      SET @fifteeth_of_last_month  = @first_of_last_month + INTERVAL 14 DAY;\n      SET @sixteenth_of_last_month = @first_of_last_month + INTERVAL 15 DAY;\n    \n      SELECT @first_of_last_month, @fifteeth_of_last_month, @sixteenth_of_last_month;\n    \n      SELECT 'determining if there are mids in trustwave that roll up to multiple account_id\\'s' AS operation;\n\n      SELECT \n           tw.mid                                               AS mid_from_tw\n          ,GROUP_CONCAT(cmm.cardconex_acct_id SEPARATOR ' | ')  AS account_ids_from_cmm \n          ,COUNT(*) \n        FROM auto_billing_staging.stg_trustwave     tw \n        JOIN sales_force.cardconex_mid_map          cmm \n          ON tw.mid = cmm.mid\n       GROUP BY 1\n      HAVING COUNT(*) >= 2\n       ORDER BY 3 DESC \n      ;\n      \n      SELECT 'determining if there are multiple mids that roll up the same account_id' AS operation;\n      \n      SELECT\n           cmm.cardconex_acct_id                                                        AS account_id_from_cmm\n          ,LEFT(acct.name, 30)                                                                    AS account_name\n          ,GROUP_CONCAT(RPAD(tw.mid, 10, ' ')        ORDER BY tw.mid SEPARATOR ' | ')   AS mids_from_trustave\n          ,GROUP_CONCAT(RPAD(tw.mid_status, 7, ' ')  ORDER BY tw.mid SEPARATOR ' | ')   AS mid_statuses\n          ,GROUP_CONCAT(RPAD(tw.pci_status, 10, ' ') ORDER BY tw.mid SEPARATOR ' | ')   AS pci_statuses\n          ,COUNT(*)\n        FROM auto_billing_staging.stg_trustwave     tw \n        JOIN sales_force.cardconex_mid_map          cmm \n          ON tw.mid = cmm.mid\n        JOIN sales_force.account                    acct \n          ON cmm.cardconex_acct_id = acct.id\n       GROUP BY 1\n      HAVING COUNT(*) >= 2\n       ORDER BY 2\n      ;\n      \n      SELECT 'determining if there are mids in the trustwave file that are not in Sales Force' AS operation;\n    \n      SELECT   \n           tw.mid \n          ,tw.mid_status \n          ,tw.pci_status \n          ,tw.date_added \n          ,cmm.cardconex_acct_id \n        FROM auto_billing_staging.stg_trustwave tw \n        LEFT JOIN sales_force.cardconex_mid_map cmm \n          ON tw.mid = cmm.mid \n       WHERE tw.mid REGEXP '^80[0-9]{8}$' \n         AND cmm.cardconex_acct_id IS NULL \n      ;\n\n      DROP TABLE IF EXISTS auto_billing_dw.tmp_pci_compliance_charges;\n       \n      CREATE TEMPORARY TABLE auto_billing_dw.tmp_pci_compliance_charges (\n         mid                        VARCHAR(32)   NOT NULL\n        ,account_id                 VARCHAR(32)   NOT NULL\n        ,org_pci                    BOOLEAN\n        ,mid_pci                    BOOLEAN\n        ,org_name                   VARCHAR(128)\n        ,mid_status                 VARCHAR(64) \n        ,close_date                 DATE \n        ,pci_status                 VARCHAR(64) \n        ,date_added                 DATE \n        ,pci_compliance_fee         DECIMAL(12, 2) \n        ,pci_non_compliance_fee     DECIMAL(12, 2) \n        ,pci_compliance_charge      DECIMAL(12, 2)\n        ,pci_non_compliance_charge  DECIMAL(12, 2)\n        ,create_timestamp           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP\n        ,PRIMARY KEY(mid)\n      -- ,UNIQUE (account_id)\n      );\n      \n      INSERT INTO auto_billing_dw.tmp_pci_compliance_charges(\n           mid                      \n          ,account_id               \n          ,org_pci \n          ,mid_pci                  \n          ,org_name\n          ,mid_status               \n          ,close_date               \n          ,pci_status               \n          ,date_added               \n          ,pci_compliance_fee       \n          ,pci_non_compliance_fee)\n      SELECT \n           tw.mid                                                                 AS mid\n          ,cmm.cardconex_acct_id                                                  AS account_id\n          ,CASE\n               WHEN org.name LIKE '%mindbody%' THEN 0\n               ELSE 1\n           END                                                                    AS org_pci    -- returns 1 for all orgs except those for which org name LIKE '%mindbody%'\n          ,tw.mid REGEXP '^80[0-9]{8}$'                                           AS mid_pci    -- do pci fees apply to this mid?  yes if mid starts with 80 and has exactly ten chars; no otherwise\n          ,COALESCE(org.name, '')                                                 AS org_name\n          ,tw.mid_status                                                          AS mid_status\n          ,COALESCE(CONVERT(idn.close_date__c, DATE), CONVERT(99991231, DATE))    AS close_date\n          ,tw.pci_status                                                          AS pci_status\n          ,tw.date_added                                                          AS date_added\n          ,asst.pci_compliance_fee                                                AS pci_compliance_fee\n          ,asst.pci_non_compliance_fee                                            AS pci_non_compliance_fee      \n        FROM auto_billing_staging.stg_trustwave             tw\n        JOIN sales_force.cardconex_mid_map                  cmm \n          ON tw.mid = cmm.mid \n        JOIN sales_force.account                            acct  \n          ON cmm.cardconex_acct_id = acct.id \n        LEFT JOIN sales_force.organization__c               org \n          ON acct.organizationid__c = org.id \n        LEFT JOIN sales_force.identification_number__c      idn\n          ON acct.id = idn.accountid__c \n         AND tw.mid = idn.name\n        LEFT JOIN auto_billing_staging.stg_asset            asst \n          ON cmm.cardconex_acct_id = asst.account_id  \n       ORDER BY mid\n      ;\n      \n      DROP TABLE IF EXISTS auto_billing_dw.tmp_pci_compliance_charge;\n      \n      -- what should the primary key be?\n      CREATE TEMPORARY TABLE auto_billing_dw.tmp_pci_compliance_charge (\n           mid                        VARCHAR(32) \n          ,account_id                 VARCHAR(32) \n          ,org_name                   VARCHAR(16)\n          ,first_of_last_month        DATE\n          ,sixteenth_of_last_month    DATE\n          ,pci_compliance_fee         DECIMAL(12,2)\n          ,org_pci                    BOOLEAN\n          ,mid_pci                    BOOLEAN\n          ,mid_status                 VARCHAR(64)\n          ,close_date                 DATE\n          ,pci_status                 VARCHAR(64)\n          ,date_added                 DATE\n          ,pci_compliance_charge      DECIMAL(12,2)\n          ,pci_non_compliance_charge  DECIMAL(12,2)\n          ,PRIMARY KEY(mid)           -- not sure this is applicable\n      )\n      ;\n      \n      INSERT INTO auto_billing_dw.tmp_pci_compliance_charge(\n           mid                      \n          ,account_id               \n          ,org_name                 \n          ,first_of_last_month      \n          ,sixteenth_of_last_month  \n          ,pci_compliance_fee       \n          ,org_pci                  \n          ,mid_pci                  \n          ,mid_status               \n          ,close_date               \n          ,pci_status               \n          ,date_added               \n          ,pci_compliance_charge    \n          ,pci_non_compliance_charge\n      )\n      SELECT\n           mid \n          ,account_id \n          ,LEFT(org_name, 16) AS org_name\n          ,@first_of_last_month \n          ,@sixteenth_of_last_month\n          ,pci_compliance_fee\n          ,org_pci\n          ,mid_pci \n          ,mid_status \n          ,close_date\n          ,pci_status\n          ,date_added\n          ,CASE \n              WHEN org_pci = 0                                                          THEN 0   -- mindbody\n              WHEN mid_pci = 0                                                          THEN 0   -- mid starts with 80 and has ten chars\n              WHEN mid_status = 'CLOSED'                                                THEN 0 \n              WHEN close_date < @first_of_last_month                                    THEN 0   -- what if NULL?\n              WHEN pci_status = 'PASS'                                                  THEN 0\n              WHEN date_added >= @sixteenth_of_last_month                               THEN 0\n              ELSE                                                                           pci_compliance_fee\n           END                                                                          AS pci_compliance_charge \n          ,CASE \n              WHEN org_pci = 0                                                          THEN 0   -- mindbody\n              WHEN mid_pci = 0                                                          THEN 0   -- mid starts with 80 and has ten chars\n              WHEN mid_status = 'CLOSED'                                                THEN 0 \n              WHEN close_date < @first_of_last_month                                    THEN 0   -- what if NULL?\n              WHEN pci_status = 'PASS'                                                  THEN 0\n              WHEN date_added >= @sixteenth_of_last_month                               THEN 0\n              WHEN date_added <  @first_of_last_month                                   THEN pci_non_compliance_fee \n              WHEN date_added BETWEEN @first_of_last_month AND @fifteeth_of_last_month  THEN 0   \n              ELSE                                                                      NULL   -- this condition should not happen\n           END                                                                          AS pci_non_compliance_charge  \n        FROM auto_billing_dw.tmp_pci_compliance_charges\n      ;\n      \n--       UPDATE auto_billing_dw.f_auto_billing_complete_2      abc\n--         JOIN auto_billing_dw.tmp_pci_compliance_charge      t1 \n--           ON abc.account_id = t1.account_id \n--          SET abc.pci_compliance_charge = t1.pci_compliance_charge\n--             ,abc.pci_non_compliance_charge = t1.pci_non_compliance_charge \n--        WHERE TRUE \n--       ;\n  \n      -- it is possible that multiple mids from the trustwave file roll up to the same account_id.\n      -- fees are cumulative in this case; therefore update processor_static to use the sum of the fees.\n    \n      UPDATE auto_billing_dw.f_auto_billing_complete_2      abc\n        JOIN (\n            SELECT \n                 account_id \n                ,SUM(pci_compliance_charge)         AS pci_compliance_charge\n                ,SUM(pci_non_compliance_charge)     AS pci_non_compliance_charge\n                ,COUNT(*)\n              FROM auto_billing_dw.tmp_pci_compliance_charge\n             GROUP BY 1\n        )  t1 \n          ON abc.account_id = t1.account_id \n         SET abc.pci_compliance_charge = t1.pci_compliance_charge\n            ,abc.pci_non_compliance_charge = t1.pci_non_compliance_charge \n       WHERE TRUE \n      ;\n    \n    \nEND	utf8	utf8_general_ci	latin1_swedish_ci
