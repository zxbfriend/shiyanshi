-- M06 增量设计；MySQL 8.0.16+；DDL隐式提交；报错停止，不使用force或自动重跑。
-- 同连接显式设置 @m06_close_maintenance_confirmed=1, @m06_close_baseline_verified=1, @m06_close_backup_ref=已完成恢复验证的备份记录ID。
DELIMITER $$
CREATE PROCEDURE m06_close_install_20260911()
BEGIN
 IF DATABASE() IS NULL OR COALESCE(@m06_close_maintenance_confirmed,0)<>1 OR COALESCE(@m06_close_baseline_verified,0)<>1 OR CHAR_LENGTH(TRIM(COALESCE(@m06_close_backup_ref,'')))=0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Maintenance, exact baseline and recoverable backup required';
 END IF;
 IF VERSION() NOT REGEXP '^8[.]' OR (SUBSTRING_INDEX(VERSION(),'.',2)='8.0' AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(VERSION(),'.',3),'.',-1) AS UNSIGNED)<16) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='MySQL 8.0.16+ with enforced CHECK required';
 END IF;
 IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('apr_scene','apr_lab_policy','apr_policy_revision','apr_request','apr_action','apr_delivery'))<>95 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Baseline column count mismatch; inspect exact schema';
 END IF;
 IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='apr_reconciliation') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Target table exists; inspect partial install'; END IF;
 IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='apr_lab_policy' AND column_name='activation_state') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Target column exists; inspect partial install'; END IF;
 IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='apr_lab_policy' AND column_name='activation_evidence') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Target column exists; inspect partial install'; END IF;
 IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='apr_policy_revision' AND column_name='request_key') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Target column exists; inspect partial install'; END IF;
 IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='apr_policy_revision' AND column_name='request_hash') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Target column exists; inspect partial install'; END IF;
 IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='apr_delivery' AND column_name='query_attempts') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Target column exists; inspect partial install'; END IF;
 IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='apr_delivery' AND column_name='unknown_since') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Target column exists; inspect partial install'; END IF;
 IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='apr_delivery' AND column_name='escalation_level') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Target column exists; inspect partial install'; END IF;
 IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='apr_delivery' AND column_name='retry_policy_snapshot') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Target column exists; inspect partial install'; END IF;
 IF EXISTS(SELECT 1 FROM `apr_delivery` WHERE (state<>'ACKNOWLEDGED' OR (owner_receipt IS NOT NULL AND COALESCE(JSON_UNQUOTE(JSON_EXTRACT(owner_receipt,'$.status')),'')=CASE WHEN decision_kind='APPLY' THEN 'APPLIED' ELSE 'DISCARDED' END)) IS FALSE) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='ck_apr_close_ack_kind: existing data violates target'; END IF;
CREATE TABLE `apr_reconciliation` (
  `reconciliation_id` BIGINT NOT NULL COMMENT '对账申请',
  `delivery_id` BIGINT NOT NULL COMMENT '固定原交付',
  `approval_id` BIGINT NOT NULL COMMENT '固定审批',
  `decision_version` BIGINT UNSIGNED NOT NULL,
  `candidate_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '原候选',
  `resolution` VARCHAR(24) NOT NULL COMMENT 'VERIFY_APPLIED/SEAL_NOT_APPLIED',
  `base_delivery_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'CAS版本',
  `evidence_json` JSON NOT NULL COMMENT '原始证据引用及拥有方核对结果',
  `evidence_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '签审绑定摘要',
  `reason` VARCHAR(500) NOT NULL,
  `submitted_by` BIGINT NOT NULL COMMENT '提交者稳定ID',
  `submitted_at` DATETIME(3) NOT NULL COMMENT '提交时刻；UTC',
  `submit_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '用户及请求持久键',
  `submit_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '提交正文',
  `reviewed_by` BIGINT NULL COMMENT '复核者稳定ID',
  `reviewed_at` DATETIME(3) NULL COMMENT '复核时刻；UTC',
  `review_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '复核请求持久键',
  `review_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '复核正文',
  `state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'SUBMITTED' COMMENT 'SUBMITTED/REJECTED/WITHDRAWN/RESOLVING/RESOLVED/STALE',
  `owner_receipt` JSON NULL COMMENT '最终拥有模块证明',
  `review_evidence` JSON NULL COMMENT '复核身份和原因',
  `resolved_at` DATETIME(3) NULL COMMENT '闭合时刻；UTC',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'CAS版本',
  `active_delivery_id` BIGINT GENERATED ALWAYS AS (CASE WHEN state IN ('SUBMITTED','RESOLVING') THEN delivery_id ELSE NULL END) STORED,
  PRIMARY KEY (`reconciliation_id`),
  UNIQUE KEY `uk_apr_rec_active` (`active_delivery_id`),
  UNIQUE KEY `uk_apr_rec_submit` (`submit_key`),
  UNIQUE KEY `uk_apr_rec_review` (`review_key`),
  KEY `ix_apr_rec_delivery` (`delivery_id`,`reconciliation_id`),
  CONSTRAINT `ck_apr_rec_state` CHECK (state IN ('SUBMITTED','REJECTED','WITHDRAWN','RESOLVING','RESOLVED','STALE')),
  CONSTRAINT `ck_apr_rec_resolution` CHECK (resolution IN ('VERIFY_APPLIED','SEAL_NOT_APPLIED')),
  CONSTRAINT `ck_apr_rec_actor` CHECK (submitted_by>0 AND (reviewed_by IS NULL OR (reviewed_by>0 AND reviewed_by<>submitted_by))),
  CONSTRAINT `ck_apr_rec_ready` CHECK (state NOT IN ('RESOLVING','RESOLVED') OR (reviewed_by IS NOT NULL AND reviewed_at IS NOT NULL AND review_evidence IS NOT NULL)),
  CONSTRAINT `ck_apr_rec_closed` CHECK (state<>'RESOLVED' OR (owner_receipt IS NOT NULL AND resolved_at IS NOT NULL)),
  CONSTRAINT `ck_apr_rec_json` CHECK (JSON_TYPE(evidence_json)='OBJECT' AND CHAR_LENGTH(TRIM(reason)) BETWEEN 1 AND 500 AND object_version>0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='apr_reconciliation 当前设计目标';

ALTER TABLE `apr_lab_policy` ADD COLUMN `activation_state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'DISABLED' COMMENT 'DISABLED/ENABLED/PAUSED；旧政策不自动启用';
ALTER TABLE `apr_lab_policy` ADD COLUMN `activation_evidence` JSON NULL COMMENT '分批启用或暂停的操作者、批次、核准及原因；完整历史见policy_revision';
ALTER TABLE `apr_lab_policy` ADD CONSTRAINT `ck_apr_close_activation` CHECK (activation_state IN ('DISABLED','ENABLED','PAUSED') AND (activation_state<>'ENABLED' OR (readiness='READY' AND current_revision_id IS NOT NULL AND activation_evidence IS NOT NULL)));
ALTER TABLE `apr_policy_revision` ADD COLUMN `request_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '真实操作人及UUID持久幂等；历史NULL';
ALTER TABLE `apr_policy_revision` ADD COLUMN `request_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '配置或启停规范请求摘要';
ALTER TABLE `apr_policy_revision` ADD UNIQUE KEY `uk_apr_close_policy_request` (`request_key`);
ALTER TABLE `apr_delivery` ADD COLUMN `query_attempts` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '只读对账查询次数';
ALTER TABLE `apr_delivery` ADD COLUMN `unknown_since` DATETIME(3) NULL COMMENT '首次未知时刻；重试不重置';
ALTER TABLE `apr_delivery` ADD COLUMN `escalation_level` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '0正常1关注2人工3长期未决';
ALTER TABLE `apr_delivery` ADD COLUMN `retry_policy_snapshot` JSON NULL COMMENT '首次交付固定退避与预算；旧NULL须受控初始化';
ALTER TABLE `apr_delivery` ADD CONSTRAINT `ck_apr_close_ack_kind` CHECK (state<>'ACKNOWLEDGED' OR (owner_receipt IS NOT NULL AND COALESCE(JSON_UNQUOTE(JSON_EXTRACT(owner_receipt,'$.status')),'')=CASE WHEN decision_kind='APPLY' THEN 'APPLIED' ELSE 'DISCARDED' END));
END$$
DELIMITER ;
CALL m06_close_install_20260911();
DROP PROCEDURE m06_close_install_20260911;
