-- M06 仅完整安装且从未启用可回退；本包之后的包必须先回退。已产生任何新证据禁止回退。
-- 同连接设置 @m06_close_maintenance_confirmed=1, @m06_close_never_enabled_confirmed=1, @m06_close_backup_ref=真实备份记录。
DELIMITER $$
CREATE PROCEDURE m06_close_unused_rollback_20260911()
BEGIN
 IF DATABASE() IS NULL OR COALESCE(@m06_close_maintenance_confirmed,0)<>1 OR COALESCE(@m06_close_never_enabled_confirmed,0)<>1 OR CHAR_LENGTH(TRIM(COALESCE(@m06_close_backup_ref,'')))=0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unused rollback confirmations required'; END IF;
 IF EXISTS(SELECT 1 FROM `apr_reconciliation`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New evidence exists: rollback forbidden'; END IF;
 IF EXISTS(SELECT 1 FROM information_schema.key_column_usage WHERE referenced_table_schema=DATABASE() AND referenced_table_name='apr_reconciliation') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='External FK reference: rollback forbidden'; END IF;
 IF EXISTS(SELECT 1 FROM `apr_lab_policy` WHERE `activation_state` <>'DISABLED') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New column used: rollback forbidden'; END IF;
 IF EXISTS(SELECT 1 FROM `apr_lab_policy` WHERE `activation_evidence` IS NOT NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New column used: rollback forbidden'; END IF;
 IF EXISTS(SELECT 1 FROM `apr_policy_revision` WHERE `request_key` IS NOT NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New column used: rollback forbidden'; END IF;
 IF EXISTS(SELECT 1 FROM `apr_policy_revision` WHERE `request_hash` IS NOT NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New column used: rollback forbidden'; END IF;
 IF EXISTS(SELECT 1 FROM `apr_delivery` WHERE `query_attempts` <>0) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New column used: rollback forbidden'; END IF;
 IF EXISTS(SELECT 1 FROM `apr_delivery` WHERE `unknown_since` IS NOT NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New column used: rollback forbidden'; END IF;
 IF EXISTS(SELECT 1 FROM `apr_delivery` WHERE `escalation_level` <>0) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New column used: rollback forbidden'; END IF;
 IF EXISTS(SELECT 1 FROM `apr_delivery` WHERE `retry_policy_snapshot` IS NOT NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New column used: rollback forbidden'; END IF;
ALTER TABLE `apr_delivery` DROP CHECK `ck_apr_close_ack_kind`;
ALTER TABLE `apr_delivery` DROP COLUMN `retry_policy_snapshot`;
ALTER TABLE `apr_delivery` DROP COLUMN `escalation_level`;
ALTER TABLE `apr_delivery` DROP COLUMN `unknown_since`;
ALTER TABLE `apr_delivery` DROP COLUMN `query_attempts`;
ALTER TABLE `apr_policy_revision` DROP INDEX `uk_apr_close_policy_request`;
ALTER TABLE `apr_policy_revision` DROP COLUMN `request_hash`;
ALTER TABLE `apr_policy_revision` DROP COLUMN `request_key`;
ALTER TABLE `apr_lab_policy` DROP CHECK `ck_apr_close_activation`;
ALTER TABLE `apr_lab_policy` DROP COLUMN `activation_evidence`;
ALTER TABLE `apr_lab_policy` DROP COLUMN `activation_state`;
DROP TABLE `apr_reconciliation`;
END$$
DELIMITER ;
CALL m06_close_unused_rollback_20260911();
DROP PROCEDURE m06_close_unused_rollback_20260911;
