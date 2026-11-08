-- M03 仅完整安装且从未启用可回退；本包之后的包必须先回退。已产生任何新证据禁止回退。
-- 同连接设置 @m03_close_maintenance_confirmed=1, @m03_close_never_enabled_confirmed=1, @m03_close_backup_ref=真实备份记录。
DELIMITER $$
CREATE PROCEDURE m03_close_unused_rollback_20260911()
BEGIN
 IF DATABASE() IS NULL OR COALESCE(@m03_close_maintenance_confirmed,0)<>1 OR COALESCE(@m03_close_never_enabled_confirmed,0)<>1 OR CHAR_LENGTH(TRIM(COALESCE(@m03_close_backup_ref,'')))=0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unused rollback confirmations required'; END IF;
 IF EXISTS(SELECT 1 FROM `res_culture_change_candidate`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New evidence exists: rollback forbidden'; END IF;
 IF EXISTS(SELECT 1 FROM information_schema.key_column_usage WHERE referenced_table_schema=DATABASE() AND referenced_table_name='res_culture_change_candidate') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='External FK reference: rollback forbidden'; END IF;

DROP TABLE `res_culture_change_candidate`;
END$$
DELIMITER ;
CALL m03_close_unused_rollback_20260911();
DROP PROCEDURE m03_close_unused_rollback_20260911;
