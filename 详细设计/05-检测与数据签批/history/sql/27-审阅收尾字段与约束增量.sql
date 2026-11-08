-- M05 增量设计；MySQL 8.0.16+；DDL隐式提交；报错停止，不使用force或自动重跑。
-- 同连接显式设置 @m05_close_maintenance_confirmed=1, @m05_close_baseline_verified=1, @m05_close_backup_ref=已完成恢复验证的备份记录ID。
DELIMITER $$
CREATE PROCEDURE m05_close_install_20260911()
BEGIN
 IF DATABASE() IS NULL OR COALESCE(@m05_close_maintenance_confirmed,0)<>1 OR COALESCE(@m05_close_baseline_verified,0)<>1 OR CHAR_LENGTH(TRIM(COALESCE(@m05_close_backup_ref,'')))=0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Maintenance, exact baseline and recoverable backup required';
 END IF;
 IF VERSION() NOT REGEXP '^8[.]' OR (SUBSTRING_INDEX(VERSION(),'.',2)='8.0' AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(VERSION(),'.',3),'.',-1) AS UNSIGNED)<16) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='MySQL 8.0.16+ with enforced CHECK required';
 END IF;
 IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('det_approval_assignee','det_ccpd_upload_log','det_dispatch_log','det_exception_note','det_print_export_log','det_result','det_result_item','det_result_sign_record','det_review_audit_log','det_sample','det_sample_id_history','det_sample_item','det_device_event','det_result_revision','det_result_correction'))<>293 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Baseline column count mismatch; inspect exact schema';
 END IF;
 IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_sample' AND column_name='current_result_id') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Target column exists; inspect partial install'; END IF;
 IF EXISTS(SELECT 1 FROM `det_result_revision` WHERE `source_id` IS NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='nonnull_source_id: existing data violates target'; END IF;

ALTER TABLE `det_sample` ADD COLUMN `current_result_id` BIGINT NULL COMMENT '核准当前运行主结果；多结果歧义保留NULL';
ALTER TABLE `det_result_revision` MODIFY COLUMN `source_id` BIGINT NOT NULL COMMENT '对应结果或动作或接收事件或更正申请主键';
ALTER TABLE `det_sample` ADD CONSTRAINT `ck_m05_close_current_result` CHECK (current_result_id IS NULL OR current_result_id>0);
END$$
DELIMITER ;
CALL m05_close_install_20260911();
DROP PROCEDURE m05_close_install_20260911;
