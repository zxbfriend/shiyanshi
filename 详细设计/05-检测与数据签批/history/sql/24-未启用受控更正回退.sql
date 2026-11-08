-- 仅从未启用、申请表全空、指针/更正事件均空的维护窗口可回退。备份永久保留。
-- 显式设置 @m05_corr_never_enabled_confirmed=1 与维护确认。部分安装不使用此脚本；先人工恢复完整结构。
DELIMITER $$
CREATE PROCEDURE m05_corr_unused_rollback_20260911()
BEGIN
 IF COALESCE(@m05_corr_maintenance_confirmed,0)<>1 OR COALESCE(@m05_corr_never_enabled_confirmed,0)<>1 OR CHAR_LENGTH(TRIM(COALESCE(@m05_corr_backup_ref,'')))=0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 unused rollback confirmations required';
 END IF;
 IF EXISTS(SELECT 1 FROM det_result_correction) OR EXISTS(SELECT 1 FROM det_result WHERE current_correction_id IS NOT NULL) OR EXISTS(SELECT 1 FROM det_result_revision WHERE source_kind='CORRECTION' OR event_kind='CORRECTION_APPLIED') THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 correction has evidence; rollback forbidden';
 END IF;
 IF EXISTS(SELECT 1 FROM information_schema.key_column_usage WHERE referenced_table_schema=DATABASE() AND referenced_table_name='det_result_correction') THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 external FK reference prevents rollback';
 END IF;
 ALTER TABLE det_result_revision DROP CHECK ck_m05_revision_source, ADD CONSTRAINT ck_m05_revision_source CHECK (source_kind IN ('RESULT','ACTION','RECEIVE') AND source_id IS NOT NULL AND source_id>0);
 ALTER TABLE det_result_revision MODIFY COLUMN source_kind VARCHAR(16) NOT NULL COMMENT 'RESULT/ACTION/RECEIVE';
 ALTER TABLE det_result DROP COLUMN current_correction_id;
 DROP TABLE det_result_correction;
END$$
DELIMITER ;
CALL m05_corr_unused_rollback_20260911();
DROP PROCEDURE m05_corr_unused_rollback_20260911;
-- 成功后才可进入原19→14→09→04；任何申请即便被拒绝/撤回也算已启用，不准删证据回退。
