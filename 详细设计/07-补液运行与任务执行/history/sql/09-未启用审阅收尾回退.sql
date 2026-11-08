-- M07 仅完整安装且从未启用可回退；本包之后的包必须先回退。已产生任何新证据禁止回退。
-- 同连接设置 @m07_close_maintenance_confirmed=1, @m07_close_never_enabled_confirmed=1, @m07_close_backup_ref=真实备份记录。
DELIMITER $$
CREATE PROCEDURE m07_close_unused_rollback_20260911()
BEGIN
 IF DATABASE() IS NULL OR COALESCE(@m07_close_maintenance_confirmed,0)<>1 OR COALESCE(@m07_close_never_enabled_confirmed,0)<>1 OR CHAR_LENGTH(TRIM(COALESCE(@m07_close_backup_ref,'')))=0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unused rollback confirmations required'; END IF;
 IF EXISTS(SELECT 1 FROM `run_executor_assignment`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New evidence exists: rollback forbidden'; END IF;
 IF EXISTS(SELECT 1 FROM information_schema.key_column_usage WHERE referenced_table_schema=DATABASE() AND referenced_table_name='run_executor_assignment') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='External FK reference: rollback forbidden'; END IF;
 IF EXISTS(SELECT 1 FROM `run_legacy_handover`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New evidence exists: rollback forbidden'; END IF;
 IF EXISTS(SELECT 1 FROM information_schema.key_column_usage WHERE referenced_table_schema=DATABASE() AND referenced_table_name='run_legacy_handover') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='External FK reference: rollback forbidden'; END IF;
 IF EXISTS(SELECT 1 FROM `run_culture_runtime` WHERE `handover_id` IS NOT NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New column used: rollback forbidden'; END IF;
ALTER TABLE `run_culture_runtime` DROP COLUMN `handover_id`;
DROP TABLE `run_legacy_handover`;
DROP TABLE `run_executor_assignment`;
END$$
DELIMITER ;
CALL m07_close_unused_rollback_20260911();
DROP PROCEDURE m07_close_unused_rollback_20260911;
