-- 2026-09-10 M05最终补齐包；MySQL 8.0.16+（8.x），仅设计未执行。
-- 先完成发送02、接收07、签批12及其核验；禁止--force。DDL隐式提交，失败停止逐对象核对。
SET NAMES utf8mb4;
-- 仅完整迁移且本补齐功能从未启用可回退。先本19，再签批14、接收09、发送04；不得按旧脚本逆序遗漏新数据。
DELIMITER $$
CREATE PROCEDURE m05_final_rollback_guard_20260910()
BEGIN
  IF DATABASE() IS NULL OR COALESCE(@m05_final_never_enabled_confirmed,0)<>1 OR COALESCE(@m05_final_maintenance_confirmed,0)<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 1: stop and reconcile'; END IF;
  IF (SELECT COUNT(*) FROM det_result_revision)<>0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 2: stop and reconcile'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result')<>39 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 3: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM `det_result` WHERE `active_upload_id` IS NOT NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 4: stop and reconcile'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result_item')<>21 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 5: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM `det_result_item` WHERE `active_void_action_id` IS NOT NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 6: stop and reconcile'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result_sign_record')<>27 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 7: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM `det_result_sign_record` WHERE `target_result_item_id` IS NOT NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 8: stop and reconcile'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_print_export_log')<>22 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 9: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM `det_print_export_log` WHERE `job_root_id` IS NOT NULL OR `actor_user_id` IS NOT NULL OR `request_id` IS NOT NULL OR `request_payload_hash` IS NOT NULL OR `job_state` IS NOT NULL OR `job_version` IS NOT NULL OR `content_manifest` IS NOT NULL OR `file_sha256` IS NOT NULL OR `template_profile` IS NOT NULL OR `template_hash` IS NOT NULL OR `selection_snapshot` IS NOT NULL OR `job_evidence` IS NOT NULL OR `state_updated_at` IS NOT NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 10: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM det_result_sign_record WHERE action_contract_version=2) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 final guard 11: stop and reconcile'; END IF;
END$$
DELIMITER ;
CALL m05_final_rollback_guard_20260910();
DROP PROCEDURE m05_final_rollback_guard_20260910;
ALTER TABLE `det_print_export_log`
  DROP INDEX `idx_m05_report_jobs`,
  DROP INDEX `idx_m05_report_root`,
  DROP INDEX `uk_m05_report_request_result`,
  DROP CHECK `ck_m05_report_ready`,
  DROP CHECK `ck_m05_report_json`,
  DROP CHECK `ck_m05_report_root`,
  DROP CHECK `ck_m05_report_identity`,
  DROP CHECK `ck_m05_report_state`,
  DROP COLUMN `job_root_id`,
  DROP COLUMN `actor_user_id`,
  DROP COLUMN `request_id`,
  DROP COLUMN `request_payload_hash`,
  DROP COLUMN `job_state`,
  DROP COLUMN `job_version`,
  DROP COLUMN `content_manifest`,
  DROP COLUMN `file_sha256`,
  DROP COLUMN `template_profile`,
  DROP COLUMN `template_hash`,
  DROP COLUMN `selection_snapshot`,
  DROP COLUMN `job_evidence`,
  DROP COLUMN `state_updated_at`;
ALTER TABLE `det_result_sign_record`
  DROP CHECK `ck_m05_sign_transition`,
  ADD CONSTRAINT `ck_m05_sign_transition` CHECK (action_contract_version IS NULL OR (operation_code='SIGN' AND before_status='uploaded' AND after_status='signed') OR (operation_code='REVIEW' AND before_status='signed' AND after_status='reviewed') OR (operation_code='REVOKE_SIGN' AND before_status='signed' AND after_status='uploaded') OR (operation_code='REVOKE_REVIEW' AND before_status='reviewed' AND after_status='signed') OR (operation_code='VOID' AND before_status IN ('tested','uploaded') AND after_status='voided') OR (operation_code='RESTORE_VOID' AND before_status='voided' AND after_status IN ('tested','uploaded'))),
  DROP CHECK `ck_m05_sign_reason`,
  ADD CONSTRAINT `ck_m05_sign_reason` CHECK (action_contract_version IS NULL OR operation_code IN ('SIGN','REVIEW') OR (action_reason IS NOT NULL AND CHAR_LENGTH(TRIM(action_reason)) BETWEEN 1 AND 500)),
  DROP CHECK `ck_m05_sign_relation`,
  ADD CONSTRAINT `ck_m05_sign_relation` CHECK (action_contract_version IS NULL OR ((operation_code IN ('SIGN','VOID') AND related_action_id IS NULL) OR (operation_code IN ('REVIEW','REVOKE_SIGN','REVOKE_REVIEW','RESTORE_VOID') AND related_action_id IS NOT NULL AND related_action_id>0))),
  DROP CHECK `ck_m05_sign_new_required`,
  ADD CONSTRAINT `ck_m05_sign_new_required` CHECK (action_contract_version IS NULL OR (operation_code IS NOT NULL AND operation_code IN ('SIGN','REVIEW','REVOKE_SIGN','REVOKE_REVIEW','VOID','RESTORE_VOID') AND result_id IS NOT NULL AND signer_user_id IS NOT NULL AND signer_user_id>0 AND action_result IS NOT NULL AND action_result='1' AND before_status IS NOT NULL AND after_status IS NOT NULL AND create_time IS NOT NULL AND result_version_before IS NOT NULL AND result_version_before>=1 AND result_version_after IS NOT NULL AND result_version_after=result_version_before+1 AND content_snapshot IS NOT NULL AND content_hash IS NOT NULL AND request_id IS NOT NULL AND CHAR_LENGTH(request_id)=36)),
  DROP CHECK `ck_m05_sign_contract`,
  ADD CONSTRAINT `ck_m05_sign_contract` CHECK (action_contract_version IS NULL OR action_contract_version=1),
  DROP INDEX `idx_m05_action_item`,
  DROP CHECK `ck_m05_action_v2_transition`,
  DROP CHECK `ck_m05_action_v2_reason`,
  DROP CHECK `ck_m05_action_v2_relation`,
  DROP CHECK `ck_m05_action_v2_target`,
  DROP CHECK `ck_m05_action_v2_required`,
  DROP COLUMN `target_result_item_id`;
ALTER TABLE `det_result_item`
  DROP INDEX `idx_m05_item_void_action`,
  DROP CHECK `ck_m05_item_void_ptr`,
  DROP COLUMN `active_void_action_id`;
ALTER TABLE `det_result`
  DROP INDEX `idx_m05_active_upload`,
  DROP CHECK `ck_m05_upload_ptr`,
  DROP COLUMN `active_upload_id`;
DROP TABLE `det_result_revision`;
-- 不删除备份，不覆盖原业务数据；已启用只能另行核准恢复方案。
