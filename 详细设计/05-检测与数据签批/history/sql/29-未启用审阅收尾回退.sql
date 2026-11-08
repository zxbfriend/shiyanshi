-- M05 仅完整安装且从未启用可回退；本包之后的包必须先回退。已产生任何新证据禁止回退。
-- 同连接设置 @m05_close_maintenance_confirmed=1, @m05_close_never_enabled_confirmed=1, @m05_close_backup_ref=真实备份记录。
DELIMITER $$
CREATE PROCEDURE m05_close_unused_rollback_20260911()
BEGIN
 IF DATABASE() IS NULL OR COALESCE(@m05_close_maintenance_confirmed,0)<>1 OR COALESCE(@m05_close_never_enabled_confirmed,0)<>1 OR CHAR_LENGTH(TRIM(COALESCE(@m05_close_backup_ref,'')))=0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unused rollback confirmations required'; END IF;
 IF EXISTS(SELECT 1 FROM `det_sample` WHERE `current_result_id` IS NOT NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New column used: rollback forbidden'; END IF;
ALTER TABLE `det_sample` DROP CHECK `ck_m05_close_current_result`;
ALTER TABLE `det_result_revision` MODIFY COLUMN `source_id` BIGINT NULL COMMENT '对应结果或动作或接收事件主键';
ALTER TABLE `det_sample` DROP COLUMN `current_result_id`;

END$$
DELIMITER ;
CALL m05_close_unused_rollback_20260911();
DROP PROCEDURE m05_close_unused_rollback_20260911;
