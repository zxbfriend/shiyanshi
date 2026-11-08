-- 2026-09-10 M05签批数据库设计稿；仅静态设计，未执行。MySQL 8.0.16+（8.x）。
-- 前置发送20列包及接收17列/事件表包。停全部写入口并完成原生一致性备份。
-- DDL隐式提交，禁止--force；部分失败保留现场，不能自动重跑。
SET NAMES utf8mb4;
-- 仅完整迁移后从未启用；使用过不能清空证据以通过守卫。不删除备份、不回灌原列、不回退接收包。
DELIMITER $$
CREATE PROCEDURE m05_sign_rollback_20260910()
BEGIN
  IF DATABASE() IS NULL OR COALESCE(@m05_sign_maintenance_confirmed,0)<>1 OR COALESCE(@m05_sign_never_enabled_confirmed,0)<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='SIGN rollback: stop writers and prove never enabled'; END IF;
  IF EXISTS(SELECT 1 FROM `det_result` WHERE NOT (`active_sign_id` <=> NULL) OR NOT (`active_review_id` <=> NULL) OR NOT (`active_void_id` <=> NULL) OR NOT (`sign_chain_state` <=> 'UNVERIFIED')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='SIGN rollback: signed facts or chain used; preserve evidence'; END IF;
  IF EXISTS(SELECT 1 FROM `det_result_sign_record` WHERE NOT (`action_contract_version` <=> NULL) OR NOT (`operation_code` <=> NULL) OR NOT (`result_version_before` <=> NULL) OR NOT (`result_version_after` <=> NULL) OR NOT (`content_snapshot` <=> NULL) OR NOT (`content_hash` <=> NULL) OR NOT (`request_id` <=> NULL) OR NOT (`related_action_id` <=> NULL)) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='SIGN rollback: signed facts or chain used; preserve evidence'; END IF;
ALTER TABLE `det_result`
  DROP CHECK `ck_m05_sign_chain`,
  DROP CHECK `ck_m05_sign_ptr_positive`,
  DROP CHECK `ck_m05_sign_ptr_state`,
  DROP INDEX `idx_m05_active_sign`,
  DROP INDEX `idx_m05_active_review`,
  DROP INDEX `idx_m05_active_void`,
  DROP COLUMN `active_sign_id`,
  DROP COLUMN `active_review_id`,
  DROP COLUMN `active_void_id`,
  DROP COLUMN `sign_chain_state`;
ALTER TABLE `det_result_sign_record`
  DROP CHECK `ck_m05_sign_contract`,
  DROP CHECK `ck_m05_sign_new_required`,
  DROP CHECK `ck_m05_sign_snapshot`,
  DROP CHECK `ck_m05_sign_relation`,
  DROP CHECK `ck_m05_sign_reason`,
  DROP CHECK `ck_m05_sign_transition`,
  DROP INDEX `idx_m05_sign_related`,
  DROP INDEX `uk_m05_sign_request_result`,
  DROP COLUMN `action_contract_version`,
  DROP COLUMN `operation_code`,
  DROP COLUMN `result_version_before`,
  DROP COLUMN `result_version_after`,
  DROP COLUMN `content_snapshot`,
  DROP COLUMN `content_hash`,
  DROP COLUMN `request_id`,
  DROP COLUMN `related_action_id`;
END$$
DELIMITER ;
CALL m05_sign_rollback_20260910();
DROP PROCEDURE m05_sign_rollback_20260910;
