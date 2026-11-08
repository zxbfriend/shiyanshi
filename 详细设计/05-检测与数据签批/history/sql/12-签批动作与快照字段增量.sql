-- 2026-09-10 M05签批数据库设计稿；仅静态设计，未执行。MySQL 8.0.16+（8.x）。
-- 前置发送20列包及接收17列/事件表包。停全部写入口并完成原生一致性备份。
-- DDL隐式提交，禁止--force；部分失败保留现场，不能自动重跑。
SET NAMES utf8mb4;
-- 操作者审阅后独立SET @m05_sign_maintenance_confirmed=1和@m05_sign_baseline_verified=1。
DELIMITER $$
CREATE PROCEDURE m05_sign_migrate_20260910()
BEGIN
  IF DATABASE() IS NULL OR COALESCE(@m05_sign_maintenance_confirmed,0)<>1 OR COALESCE(@m05_sign_baseline_verified,0)<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='SIGN: explicit database, stopped writers and baseline review required'; END IF;
  IF VERSION() NOT REGEXP '^8[.]' OR (SUBSTRING_INDEX(VERSION(),'.',2)='8.0' AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(VERSION(),'.',3),'.',-1) AS UNSIGNED)<16) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='SIGN: requires reviewed MySQL 8.0.16+ in 8.x'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_type='BASE TABLE' AND engine='InnoDB' AND table_name IN ('det_result','det_result_sign_record','det_device_event'))<>3 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='SIGN: required InnoDB tables missing'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result')<>34 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='SIGN: unexpected baseline columns'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result_sign_record')<>18 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='SIGN: unexpected baseline columns'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result' AND column_name IN ('object_version','collection_basis','source_progress','result_completeness'))<>4 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='SIGN: reception fields absent'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result' AND column_name IN ('active_sign_id','active_review_id','active_void_id','sign_chain_state')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='SIGN: target fields already exist; inspect partial migration'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result_sign_record' AND column_name IN ('action_contract_version','operation_code','result_version_before','result_version_after','content_snapshot','content_hash','request_id','related_action_id')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='SIGN: target fields already exist; inspect partial migration'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name IN ('bak_m05_sign_20260910_det_result','bak_m05_sign_20260910_det_result_sign_record')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='SIGN: backup exists; never overwrite'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND constraint_name IN ('ck_m05_sign_chain','ck_m05_sign_ptr_positive','ck_m05_sign_ptr_state','ck_m05_sign_contract','ck_m05_sign_new_required','ck_m05_sign_snapshot','ck_m05_sign_relation','ck_m05_sign_reason','ck_m05_sign_transition')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='SIGN: check name exists'; END IF;
CREATE TABLE `bak_m05_sign_20260910_det_result` LIKE `det_result`;
INSERT INTO `bak_m05_sign_20260910_det_result` SELECT * FROM `det_result`;
  IF (SELECT COUNT(*) FROM `bak_m05_sign_20260910_det_result`)<>(SELECT COUNT(*) FROM `det_result`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='SIGN: backup count mismatch'; END IF;
CREATE TABLE `bak_m05_sign_20260910_det_result_sign_record` LIKE `det_result_sign_record`;
INSERT INTO `bak_m05_sign_20260910_det_result_sign_record` SELECT * FROM `det_result_sign_record`;
  IF (SELECT COUNT(*) FROM `bak_m05_sign_20260910_det_result_sign_record`)<>(SELECT COUNT(*) FROM `det_result_sign_record`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='SIGN: backup count mismatch'; END IF;
ALTER TABLE `det_result`
  ADD COLUMN `active_sign_id` BIGINT NULL COMMENT '当前有效SIGN动作主键；不从最新记录推算',
  ADD COLUMN `active_review_id` BIGINT NULL COMMENT '当前有效REVIEW动作主键；关联有效签名',
  ADD COLUMN `active_void_id` BIGINT NULL COMMENT '当前有效整结果VOID动作主键；精确恢复原状态',
  ADD COLUMN `sign_chain_state` VARCHAR(16) NOT NULL DEFAULT 'UNVERIFIED' COMMENT 'VERIFIED/UNVERIFIED/CONFLICT；历史默认未核验',
  ADD CONSTRAINT `ck_m05_sign_chain` CHECK (sign_chain_state IN ('VERIFIED','UNVERIFIED','CONFLICT')),
  ADD CONSTRAINT `ck_m05_sign_ptr_positive` CHECK ((active_sign_id IS NULL OR active_sign_id>0) AND (active_review_id IS NULL OR active_review_id>0) AND (active_void_id IS NULL OR active_void_id>0)),
  ADD CONSTRAINT `ck_m05_sign_ptr_state` CHECK ((sign_chain_state<>'VERIFIED' AND active_sign_id IS NULL AND active_review_id IS NULL AND active_void_id IS NULL) OR (sign_chain_state='VERIFIED' AND ((result_status='signed' AND active_sign_id IS NOT NULL AND active_review_id IS NULL AND active_void_id IS NULL) OR (result_status='reviewed' AND active_sign_id IS NOT NULL AND active_review_id IS NOT NULL AND active_void_id IS NULL) OR (result_status='voided' AND active_sign_id IS NULL AND active_review_id IS NULL AND active_void_id IS NOT NULL) OR (result_status NOT IN ('signed','reviewed','voided') AND active_sign_id IS NULL AND active_review_id IS NULL AND active_void_id IS NULL)))),
  ADD INDEX `idx_m05_active_sign` (active_sign_id),
  ADD INDEX `idx_m05_active_review` (active_review_id),
  ADD INDEX `idx_m05_active_void` (active_void_id);
ALTER TABLE `det_result_sign_record`
  ADD COLUMN `action_contract_version` SMALLINT UNSIGNED NULL COMMENT '本批成功动作固定1；旧记录NULL不伪造升级',
  ADD COLUMN `operation_code` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'SIGN/REVIEW/REVOKE_SIGN/REVOKE_REVIEW/VOID/RESTORE_VOID；精确新契约类型',
  ADD COLUMN `result_version_before` BIGINT UNSIGNED NULL COMMENT '操作锁定的结果版本',
  ADD COLUMN `result_version_after` BIGINT UNSIGNED NULL COMMENT '成功后结果版本，等于before加1',
  ADD COLUMN `content_snapshot` JSON NULL COMMENT '不可变对象：schema/content/actor/authorization/action；完整明细与来源依据',
  ADD COLUMN `content_hash` BINARY(32) NULL COMMENT '规范化snapshot.content的SHA256；非电子证书签名',
  ADD COLUMN `request_id` VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '同操作者M01请求UUID；领域证据不随HTTP回执过期删除',
  ADD COLUMN `related_action_id` BIGINT NULL COMMENT 'REVIEW指向被审核SIGN；撤销/恢复指向原动作',
  ADD CONSTRAINT `ck_m05_sign_contract` CHECK (action_contract_version IS NULL OR action_contract_version=1),
  ADD CONSTRAINT `ck_m05_sign_new_required` CHECK (action_contract_version IS NULL OR (operation_code IS NOT NULL AND operation_code IN ('SIGN','REVIEW','REVOKE_SIGN','REVOKE_REVIEW','VOID','RESTORE_VOID') AND result_id IS NOT NULL AND signer_user_id IS NOT NULL AND signer_user_id>0 AND action_result IS NOT NULL AND action_result='1' AND before_status IS NOT NULL AND after_status IS NOT NULL AND create_time IS NOT NULL AND result_version_before IS NOT NULL AND result_version_before>=1 AND result_version_after IS NOT NULL AND result_version_after=result_version_before+1 AND content_snapshot IS NOT NULL AND content_hash IS NOT NULL AND request_id IS NOT NULL AND CHAR_LENGTH(request_id)=36)),
  ADD CONSTRAINT `ck_m05_sign_snapshot` CHECK (content_snapshot IS NULL OR JSON_TYPE(content_snapshot)='OBJECT'),
  ADD CONSTRAINT `ck_m05_sign_relation` CHECK (action_contract_version IS NULL OR ((operation_code IN ('SIGN','VOID') AND related_action_id IS NULL) OR (operation_code IN ('REVIEW','REVOKE_SIGN','REVOKE_REVIEW','RESTORE_VOID') AND related_action_id IS NOT NULL AND related_action_id>0))),
  ADD CONSTRAINT `ck_m05_sign_reason` CHECK (action_contract_version IS NULL OR operation_code IN ('SIGN','REVIEW') OR (action_reason IS NOT NULL AND CHAR_LENGTH(TRIM(action_reason)) BETWEEN 1 AND 500)),
  ADD CONSTRAINT `ck_m05_sign_transition` CHECK (action_contract_version IS NULL OR (operation_code='SIGN' AND before_status='uploaded' AND after_status='signed') OR (operation_code='REVIEW' AND before_status='signed' AND after_status='reviewed') OR (operation_code='REVOKE_SIGN' AND before_status='signed' AND after_status='uploaded') OR (operation_code='REVOKE_REVIEW' AND before_status='reviewed' AND after_status='signed') OR (operation_code='VOID' AND before_status IN ('tested','uploaded') AND after_status='voided') OR (operation_code='RESTORE_VOID' AND before_status='voided' AND after_status IN ('tested','uploaded'))),
  ADD INDEX `idx_m05_sign_related` (related_action_id),
  ADD UNIQUE INDEX `uk_m05_sign_request_result` (signer_user_id,request_id,result_id);
END$$
DELIMITER ;
CALL m05_sign_migrate_20260910();
DROP PROCEDURE m05_sign_migrate_20260910;
