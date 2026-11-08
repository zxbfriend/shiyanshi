-- SQL设计稿，未执行；MySQL 8.0且CHECK须ENFORCED。DDL隐式提交，不声称整包事务回滚。
-- 执行前21核验并维护停写，同连接设置三个确认变量；报错立即停止，禁止客户端force继续。
DELIMITER $$
CREATE PROCEDURE m05_corr_install_20260911()
BEGIN
 IF DATABASE() IS NULL OR COALESCE(@m05_corr_maintenance_confirmed,0)<>1 OR COALESCE(@m05_corr_baseline_verified,0)<>1 OR CHAR_LENGTH(TRIM(COALESCE(@m05_corr_backup_ref,'')))=0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 correction requires maintenance, baseline and recoverable backup';
 END IF;
 IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('det_approval_assignee','det_ccpd_upload_log','det_dispatch_log','det_exception_note','det_print_export_log','det_result','det_result_item','det_result_sign_record','det_review_audit_log','det_sample','det_sample_id_history','det_sample_item','det_device_event','det_result_revision'))<>267 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 expected 14-table 267-column baseline';
 END IF;
 IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='det_result_correction') OR EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result' AND column_name='current_correction_id') THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 target exists or prior DDL partial; inspect before retry';
 END IF;
 CREATE TABLE `det_result_correction` (
  `correction_id` BIGINT NOT NULL COMMENT '更正申请主键',
  `result_id` BIGINT NOT NULL COMMENT '原结果稳定主键',
  `base_object_version` BIGINT UNSIGNED NOT NULL COMMENT '提交时结果基线',
  `base_correction_id` BIGINT NULL COMMENT '前一已生效更正',
  `base_content_hash` CHAR(64) NOT NULL COMMENT '完整原版摘要',
  `candidate_snapshot` JSON NOT NULL COMMENT '冻结完整候选',
  `candidate_hash` CHAR(64) NOT NULL COMMENT '候选规范摘要',
  `changed_paths` JSON NOT NULL COMMENT '稳定指标字段差异',
  `evidence_refs` JSON NOT NULL COMMENT '不可变证据及身份依据',
  `reason` VARCHAR(500) NOT NULL COMMENT '更正理由',
  `state` VARCHAR(16) NOT NULL DEFAULT 'SUBMITTED' COMMENT '申请状态',
  `submitted_by` BIGINT NOT NULL COMMENT '新版本签名人稳定ID',
  `submitted_at` DATETIME(3) NOT NULL COMMENT '当前签名时刻UTC',
  `submission_signature` JSON NOT NULL COMMENT '签名声明及摘要与当时身份',
  `submit_request_id` CHAR(36) NOT NULL COMMENT '提交持久幂等键',
  `submit_payload_hash` CHAR(64) NOT NULL COMMENT '规范请求摘要',
  `terminal_actor_id` BIGINT NULL COMMENT '决定或撤回操作者',
  `terminal_at` DATETIME(3) NULL COMMENT '终结时刻UTC',
  `terminal_request_id` CHAR(36) NULL COMMENT '终结持久幂等键',
  `terminal_payload_hash` CHAR(64) NULL COMMENT '终结规范请求摘要',
  `terminal_reason` VARCHAR(500) NULL COMMENT '审核撤回或过期原因',
  `review_signature` JSON NULL COMMENT '批准的新审核签名及候选摘要',
  `result_revision_id` BIGINT NULL COMMENT '批准生成不可变版本',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '申请乐观版本',
  `pending_result_id` BIGINT GENERATED ALWAYS AS (CASE WHEN state='SUBMITTED' THEN result_id ELSE NULL END) STORED COMMENT '每结果至多一个未决申请',
  PRIMARY KEY (`correction_id`),
  UNIQUE INDEX `uk_m05_corr_pending` (`pending_result_id`),
  UNIQUE INDEX `uk_m05_corr_submit` (`submitted_by`,`submit_request_id`),
  UNIQUE INDEX `uk_m05_corr_terminal` (`terminal_actor_id`,`terminal_request_id`),
  INDEX `idx_m05_corr_result` (`result_id`,`correction_id`),
  CONSTRAINT `ck_m05_corr_ids` CHECK (correction_id>0 AND result_id>0 AND submitted_by>0 AND object_version>=1 AND (base_correction_id IS NULL OR base_correction_id>0)),
  CONSTRAINT `ck_m05_corr_json` CHECK (JSON_TYPE(candidate_snapshot)='OBJECT' AND JSON_TYPE(changed_paths)='ARRAY' AND JSON_TYPE(evidence_refs)='ARRAY' AND JSON_LENGTH(evidence_refs) BETWEEN 1 AND 20 AND JSON_TYPE(submission_signature)='OBJECT'),
  CONSTRAINT `ck_m05_corr_reason` CHECK (CHAR_LENGTH(TRIM(reason)) BETWEEN 1 AND 500),
  CONSTRAINT `ck_m05_corr_state` CHECK (state IN ('SUBMITTED','APPROVED','REJECTED','WITHDRAWN','STALE')),
  CONSTRAINT `ck_m05_corr_terminal` CHECK ((state='SUBMITTED' AND terminal_actor_id IS NULL AND terminal_at IS NULL AND terminal_request_id IS NULL AND terminal_payload_hash IS NULL AND terminal_reason IS NULL AND review_signature IS NULL AND result_revision_id IS NULL) OR (state<>'SUBMITTED' AND terminal_actor_id IS NOT NULL AND terminal_actor_id>0 AND terminal_at IS NOT NULL AND terminal_request_id IS NOT NULL AND terminal_payload_hash IS NOT NULL AND terminal_reason IS NOT NULL AND CHAR_LENGTH(TRIM(terminal_reason)) BETWEEN 1 AND 500)),
  CONSTRAINT `ck_m05_corr_approval` CHECK ((state='APPROVED' AND terminal_actor_id<>submitted_by AND result_revision_id IS NOT NULL AND result_revision_id>0 AND review_signature IS NOT NULL AND JSON_TYPE(review_signature)='OBJECT') OR (state<>'APPROVED' AND result_revision_id IS NULL AND review_signature IS NULL)),
  CONSTRAINT `ck_m05_corr_actor` CHECK ((state='WITHDRAWN' AND terminal_actor_id=submitted_by) OR state<>'WITHDRAWN')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='受控更正申请与不可变候选证据';

 ALTER TABLE det_result ADD COLUMN current_correction_id BIGINT NULL COMMENT '当前批准更正；NULL沿原投影';
 ALTER TABLE det_result_revision DROP CHECK ck_m05_revision_source, ADD CONSTRAINT ck_m05_revision_source CHECK (source_kind IN ('RESULT','ACTION','RECEIVE','CORRECTION') AND source_id IS NOT NULL AND source_id>0);
 ALTER TABLE det_result_revision MODIFY COLUMN source_kind VARCHAR(16) NOT NULL COMMENT 'RESULT/ACTION/RECEIVE/CORRECTION';
END$$
DELIMITER ;
CALL m05_corr_install_20260911();
DROP PROCEDURE m05_corr_install_20260911;
-- 只有全部成功再执行23；若中途失败保留现场，按备份与已执行DDL逐条恢复，不重跑或自动清理。
