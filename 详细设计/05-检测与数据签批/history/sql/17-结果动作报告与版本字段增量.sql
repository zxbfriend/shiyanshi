-- 2026-09-10 M05最终补齐包；MySQL 8.0.16+（8.x），仅设计未执行。
-- 先完成发送02、接收07、签批12及其核验；禁止--force。DDL隐式提交，失败停止逐对象核对。
SET NAMES utf8mb4;
-- 人工核验后单独设置两个会话开关为1；脚本不能证明外部写入停止或原生备份有效。
DELIMITER $$
CREATE PROCEDURE m05_final_preflight_20260910()
BEGIN
  IF DATABASE() IS NULL OR COALESCE(@m05_final_maintenance_confirmed,0)<>1 OR COALESCE(@m05_final_baseline_verified,0)<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 1: stop and reconcile'; END IF;
  IF VERSION() NOT REGEXP '^8[.]' OR (SUBSTRING_INDEX(VERSION(),'.',2)='8.0' AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(VERSION(),'.',3),'.',-1) AS UNSIGNED)<16) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 2: stop and reconcile'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='det_result' AND table_type='BASE TABLE' AND engine='InnoDB')<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 3: stop and reconcile'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result')<>38 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 4: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result' AND column_name IN ('active_upload_id')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 5: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='bak_m05_final_20260910_det_result') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 6: stop and reconcile'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='det_result_item' AND table_type='BASE TABLE' AND engine='InnoDB')<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 7: stop and reconcile'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result_item')<>20 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 8: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result_item' AND column_name IN ('active_void_action_id')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 9: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='bak_m05_final_20260910_det_result_item') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 10: stop and reconcile'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='det_result_sign_record' AND table_type='BASE TABLE' AND engine='InnoDB')<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 11: stop and reconcile'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result_sign_record')<>26 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 12: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result_sign_record' AND column_name IN ('target_result_item_id')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 13: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='bak_m05_final_20260910_det_result_sign_record') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 14: stop and reconcile'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='det_print_export_log' AND table_type='BASE TABLE' AND engine='InnoDB')<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 15: stop and reconcile'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_print_export_log')<>9 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 16: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_print_export_log' AND column_name IN ('job_root_id','actor_user_id','request_id','request_payload_hash','job_state','job_version','content_manifest','file_sha256','template_profile','template_hash','selection_snapshot','job_evidence','state_updated_at')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 17: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='bak_m05_final_20260910_det_print_export_log') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 18: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='det_result_revision') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 19: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND constraint_name IN ('ck_m05_upload_ptr','ck_m05_item_void_ptr','ck_m05_action_v2_required','ck_m05_action_v2_target','ck_m05_action_v2_relation','ck_m05_action_v2_reason','ck_m05_action_v2_transition','ck_m05_report_state','ck_m05_report_identity','ck_m05_report_root','ck_m05_report_json','ck_m05_report_ready','ck_m05_revision_version','ck_m05_revision_snapshot','ck_m05_revision_source','ck_m05_revision_publish')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 20: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='det_result' AND index_name IN ('idx_m05_active_upload')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 21: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='det_result_item' AND index_name IN ('idx_m05_item_void_action')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 22: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='det_result_sign_record' AND index_name IN ('idx_m05_action_item')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 23: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='det_print_export_log' AND index_name IN ('uk_m05_report_request_result','idx_m05_report_root','idx_m05_report_jobs')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 24: stop and reconcile'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='det_result_sign_record' AND enforced='YES' AND constraint_name IN ('ck_m05_sign_contract','ck_m05_sign_new_required','ck_m05_sign_snapshot','ck_m05_sign_relation','ck_m05_sign_reason','ck_m05_sign_transition'))<>6 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 25: stop and reconcile'; END IF;
END$$
DELIMITER ;
CALL m05_final_preflight_20260910();
DROP PROCEDURE m05_final_preflight_20260910;
CREATE TABLE `bak_m05_final_20260910_det_result` LIKE `det_result`;
INSERT INTO `bak_m05_final_20260910_det_result` SELECT * FROM `det_result`;
CREATE TABLE `bak_m05_final_20260910_det_result_item` LIKE `det_result_item`;
INSERT INTO `bak_m05_final_20260910_det_result_item` SELECT * FROM `det_result_item`;
CREATE TABLE `bak_m05_final_20260910_det_result_sign_record` LIKE `det_result_sign_record`;
INSERT INTO `bak_m05_final_20260910_det_result_sign_record` SELECT * FROM `det_result_sign_record`;
CREATE TABLE `bak_m05_final_20260910_det_print_export_log` LIKE `det_print_export_log`;
INSERT INTO `bak_m05_final_20260910_det_print_export_log` SELECT * FROM `det_print_export_log`;
DELIMITER $$
CREATE PROCEDURE m05_final_backup_check_20260910()
BEGIN
  IF (SELECT COUNT(*) FROM `det_result`)<>(SELECT COUNT(*) FROM `bak_m05_final_20260910_det_result`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 1: stop and reconcile'; END IF;
  IF (SELECT COUNT(*) FROM `det_result_item`)<>(SELECT COUNT(*) FROM `bak_m05_final_20260910_det_result_item`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 2: stop and reconcile'; END IF;
  IF (SELECT COUNT(*) FROM `det_result_sign_record`)<>(SELECT COUNT(*) FROM `bak_m05_final_20260910_det_result_sign_record`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 3: stop and reconcile'; END IF;
  IF (SELECT COUNT(*) FROM `det_print_export_log`)<>(SELECT COUNT(*) FROM `bak_m05_final_20260910_det_print_export_log`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 4: stop and reconcile'; END IF;
END$$
DELIMITER ;
CALL m05_final_backup_check_20260910();
DROP PROCEDURE m05_final_backup_check_20260910;
ALTER TABLE `det_result`
  ADD COLUMN `active_upload_id` BIGINT NULL COMMENT '当前有效人工或系统上传动作；历史NULL不推断',
  ADD CONSTRAINT `ck_m05_upload_ptr` CHECK (active_upload_id IS NULL OR active_upload_id>0),
  ADD INDEX `idx_m05_active_upload` (active_upload_id);
ALTER TABLE `det_result_item`
  ADD COLUMN `active_void_action_id` BIGINT NULL COMMENT '当前有效单项作废动作；不是整结果作废',
  ADD CONSTRAINT `ck_m05_item_void_ptr` CHECK (active_void_action_id IS NULL OR (active_void_action_id>0 AND is_voided IS NOT NULL AND is_voided='1')),
  ADD INDEX `idx_m05_item_void_action` (active_void_action_id);
ALTER TABLE `det_result_sign_record`
  DROP CHECK `ck_m05_sign_contract`,
  ADD CONSTRAINT `ck_m05_sign_contract` CHECK (action_contract_version IS NULL OR action_contract_version IN (1,2)),
  DROP CHECK `ck_m05_sign_new_required`,
  ADD CONSTRAINT `ck_m05_sign_new_required` CHECK (action_contract_version=2 OR action_contract_version IS NULL OR (operation_code IS NOT NULL AND operation_code IN ('SIGN','REVIEW','REVOKE_SIGN','REVOKE_REVIEW','VOID','RESTORE_VOID') AND result_id IS NOT NULL AND signer_user_id IS NOT NULL AND signer_user_id>0 AND action_result IS NOT NULL AND action_result='1' AND before_status IS NOT NULL AND after_status IS NOT NULL AND create_time IS NOT NULL AND result_version_before IS NOT NULL AND result_version_before>=1 AND result_version_after IS NOT NULL AND result_version_after=result_version_before+1 AND content_snapshot IS NOT NULL AND content_hash IS NOT NULL AND request_id IS NOT NULL AND CHAR_LENGTH(request_id)=36)),
  DROP CHECK `ck_m05_sign_relation`,
  ADD CONSTRAINT `ck_m05_sign_relation` CHECK (action_contract_version=2 OR action_contract_version IS NULL OR ((operation_code IN ('SIGN','VOID') AND related_action_id IS NULL) OR (operation_code IN ('REVIEW','REVOKE_SIGN','REVOKE_REVIEW','RESTORE_VOID') AND related_action_id IS NOT NULL AND related_action_id>0))),
  DROP CHECK `ck_m05_sign_reason`,
  ADD CONSTRAINT `ck_m05_sign_reason` CHECK (action_contract_version=2 OR action_contract_version IS NULL OR operation_code IN ('SIGN','REVIEW') OR (action_reason IS NOT NULL AND CHAR_LENGTH(TRIM(action_reason)) BETWEEN 1 AND 500)),
  DROP CHECK `ck_m05_sign_transition`,
  ADD CONSTRAINT `ck_m05_sign_transition` CHECK (action_contract_version=2 OR action_contract_version IS NULL OR (operation_code='SIGN' AND before_status='uploaded' AND after_status='signed') OR (operation_code='REVIEW' AND before_status='signed' AND after_status='reviewed') OR (operation_code='REVOKE_SIGN' AND before_status='signed' AND after_status='uploaded') OR (operation_code='REVOKE_REVIEW' AND before_status='reviewed' AND after_status='signed') OR (operation_code='VOID' AND before_status IN ('tested','uploaded') AND after_status='voided') OR (operation_code='RESTORE_VOID' AND before_status='voided' AND after_status IN ('tested','uploaded'))),
  ADD COLUMN `target_result_item_id` BIGINT NULL COMMENT 'v2单项动作目标；其他动作NULL',
  ADD CONSTRAINT `ck_m05_action_v2_required` CHECK (action_contract_version IS NULL OR action_contract_version<>2 OR (operation_code IS NOT NULL AND operation_code IN ('UPLOAD','AUTO_UPLOAD','REVOKE_UPLOAD','RENAME_SAMPLE','MARK_EXCEPTION','DELETE_RESULT','VOID_ITEM','RESTORE_ITEM') AND result_id IS NOT NULL AND action_result IS NOT NULL AND action_result='1' AND before_status IS NOT NULL AND after_status IS NOT NULL AND create_time IS NOT NULL AND result_version_before IS NOT NULL AND result_version_before>=1 AND result_version_after IS NOT NULL AND result_version_after=result_version_before+1 AND content_snapshot IS NOT NULL AND content_hash IS NOT NULL AND request_id IS NOT NULL AND CHAR_LENGTH(request_id)=36 AND ((operation_code='AUTO_UPLOAD' AND signer_user_id IS NULL) OR (operation_code<>'AUTO_UPLOAD' AND signer_user_id IS NOT NULL AND signer_user_id>0)))),
  ADD CONSTRAINT `ck_m05_action_v2_target` CHECK (action_contract_version IS NULL OR action_contract_version<>2 OR ((operation_code IN ('VOID_ITEM','RESTORE_ITEM') AND target_result_item_id IS NOT NULL AND target_result_item_id>0) OR (operation_code NOT IN ('VOID_ITEM','RESTORE_ITEM') AND target_result_item_id IS NULL))),
  ADD CONSTRAINT `ck_m05_action_v2_relation` CHECK (action_contract_version IS NULL OR action_contract_version<>2 OR ((operation_code IN ('REVOKE_UPLOAD','RESTORE_ITEM') AND related_action_id IS NOT NULL AND related_action_id>0) OR (operation_code NOT IN ('REVOKE_UPLOAD','RESTORE_ITEM') AND related_action_id IS NULL))),
  ADD CONSTRAINT `ck_m05_action_v2_reason` CHECK (action_contract_version IS NULL OR action_contract_version<>2 OR operation_code IN ('UPLOAD','AUTO_UPLOAD','DELETE_RESULT') OR (action_reason IS NOT NULL AND CHAR_LENGTH(TRIM(action_reason)) BETWEEN 1 AND 500)),
  ADD CONSTRAINT `ck_m05_action_v2_transition` CHECK (action_contract_version IS NULL OR action_contract_version<>2 OR (operation_code IN ('UPLOAD','AUTO_UPLOAD') AND before_status='tested' AND after_status='uploaded') OR (operation_code='REVOKE_UPLOAD' AND before_status='uploaded' AND after_status='tested') OR (operation_code IN ('RENAME_SAMPLE','VOID_ITEM','RESTORE_ITEM') AND before_status IN ('tested','uploaded') AND after_status=before_status) OR (operation_code='MARK_EXCEPTION' AND before_status IN ('pending','testing') AND after_status='exception') OR (operation_code='DELETE_RESULT' AND before_status IN ('pending','testing') AND after_status=before_status)),
  ADD INDEX `idx_m05_action_item` (target_result_item_id,sign_id);
ALTER TABLE `det_print_export_log`
  ADD COLUMN `job_root_id` BIGINT NULL COMMENT '每冻结结果一行；root指向自身log_id，子行指向root',
  ADD COLUMN `actor_user_id` BIGINT NULL COMMENT '稳定操作用户；历史NULL',
  ADD COLUMN `request_id` VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'M01请求UUID；与用户及结果组合去重',
  ADD COLUMN `request_payload_hash` BINARY(32) NULL COMMENT 'root规范化请求摘要',
  ADD COLUMN `job_state` VARCHAR(16) NULL COMMENT 'root PREPARING/RENDERING/READY/SUBMITTED/UNKNOWN/FAILED',
  ADD COLUMN `job_version` BIGINT UNSIGNED NULL COMMENT 'root乐观版本，从1递增；子行NULL',
  ADD COLUMN `content_manifest` JSON NULL COMMENT 'root不可变完整结果版本和动作集合及模板映射快照',
  ADD COLUMN `file_sha256` BINARY(32) NULL COMMENT 'root服务端生成文件摘要',
  ADD COLUMN `template_profile` VARCHAR(32) NULL COMMENT 'root核准模板配置及版本键',
  ADD COLUMN `template_hash` BINARY(32) NULL COMMENT 'root原模板SHA256',
  ADD COLUMN `selection_snapshot` JSON NULL COMMENT 'root不可变选中与扩展范围及用途',
  ADD COLUMN `job_evidence` JSON NULL COMMENT 'root租约token及生成打印尝试证据；允许追加',
  ADD COLUMN `state_updated_at` DATETIME(3) NULL COMMENT 'root最近状态变更时间',
  ADD CONSTRAINT `ck_m05_report_state` CHECK (job_state IS NULL OR job_state IN ('PREPARING','RENDERING','READY','SUBMITTED','UNKNOWN','FAILED')),
  ADD CONSTRAINT `ck_m05_report_identity` CHECK (job_root_id IS NULL OR (job_root_id>0 AND actor_user_id IS NOT NULL AND actor_user_id>0 AND request_id IS NOT NULL AND CHAR_LENGTH(request_id)=36)),
  ADD CONSTRAINT `ck_m05_report_root` CHECK (job_root_id IS NULL OR (job_root_id<>log_id AND job_state IS NULL AND job_version IS NULL AND content_manifest IS NULL) OR (job_root_id=log_id AND job_state IS NOT NULL AND job_version IS NOT NULL AND job_version>=1 AND request_payload_hash IS NOT NULL AND content_manifest IS NOT NULL AND template_profile IS NOT NULL AND template_hash IS NOT NULL AND selection_snapshot IS NOT NULL AND state_updated_at IS NOT NULL)),
  ADD CONSTRAINT `ck_m05_report_json` CHECK ((content_manifest IS NULL OR JSON_TYPE(content_manifest)='OBJECT') AND (selection_snapshot IS NULL OR JSON_TYPE(selection_snapshot)='OBJECT') AND (job_evidence IS NULL OR JSON_TYPE(job_evidence)='OBJECT')),
  ADD CONSTRAINT `ck_m05_report_ready` CHECK (job_state IS NULL OR job_state NOT IN ('READY','SUBMITTED','UNKNOWN') OR (file_sha256 IS NOT NULL AND file_path IS NOT NULL AND CHAR_LENGTH(TRIM(file_path))>0)),
  ADD UNIQUE INDEX `uk_m05_report_request_result` (actor_user_id,request_id,result_id),
  ADD INDEX `idx_m05_report_root` (job_root_id,log_id),
  ADD INDEX `idx_m05_report_jobs` (job_state,state_updated_at,log_id);
CREATE TABLE `det_result_revision` (
  `revision_id` BIGINT NOT NULL COMMENT '不可变版本兼发件箱事件主键',
  `result_id` BIGINT NOT NULL COMMENT '结果主键；逻辑关联',
  `object_version` BIGINT UNSIGNED NOT NULL COMMENT '精确结果版本',
  `event_kind` VARCHAR(32) NOT NULL COMMENT 'INITIAL/BASELINE/RECEIVE或精确领域动作',
  `source_kind` VARCHAR(16) NOT NULL COMMENT 'RESULT/ACTION/RECEIVE',
  `source_id` BIGINT NULL COMMENT '对应结果或动作或接收事件主键',
  `actor_user_id` BIGINT NULL COMMENT '用户主体；系统事件NULL',
  `content_snapshot` JSON NOT NULL COMMENT '完整ResultSnapshot，内容不可变',
  `created_at` DATETIME(3) NOT NULL COMMENT '版本提交前服务器时刻',
  `publish_state` VARCHAR(16) NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING/RETRY/PUBLISHED',
  `publish_attempts` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '尝试次数，不等同下游消费次数',
  `next_publish_at` DATETIME(3) NULL COMMENT '退避重试时刻',
  `last_error` VARCHAR(1000) NULL COMMENT '无凭据的投递错误摘要',
  `published_at` DATETIME(3) NULL COMMENT '消息系统确认交接时刻',
  PRIMARY KEY (`revision_id`),
  UNIQUE INDEX `uk_m05_revision_result_version` (result_id,object_version),
  INDEX `idx_m05_revision_publish` (publish_state,next_publish_at,revision_id),
  CONSTRAINT `ck_m05_revision_version` CHECK (result_id>0 AND object_version>=1),
  CONSTRAINT `ck_m05_revision_snapshot` CHECK (JSON_TYPE(content_snapshot)='OBJECT'),
  CONSTRAINT `ck_m05_revision_source` CHECK (source_kind IN ('RESULT','ACTION','RECEIVE') AND source_id IS NOT NULL AND source_id>0),
  CONSTRAINT `ck_m05_revision_publish` CHECK ((publish_state IN ('PENDING','RETRY') AND published_at IS NULL) OR (publish_state='PUBLISHED' AND published_at IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='检测结果不可变版本与事务发件箱';
