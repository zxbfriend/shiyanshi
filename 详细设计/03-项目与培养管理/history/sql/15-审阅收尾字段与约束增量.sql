-- M03 增量设计；MySQL 8.0.16+；DDL隐式提交；报错停止，不使用force或自动重跑。
-- 同连接显式设置 @m03_close_maintenance_confirmed=1, @m03_close_baseline_verified=1, @m03_close_backup_ref=已完成恢复验证的备份记录ID。
DELIMITER $$
CREATE PROCEDURE m03_close_install_20260911()
BEGIN
 IF DATABASE() IS NULL OR COALESCE(@m03_close_maintenance_confirmed,0)<>1 OR COALESCE(@m03_close_baseline_verified,0)<>1 OR CHAR_LENGTH(TRIM(COALESCE(@m03_close_backup_ref,'')))=0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Maintenance, exact baseline and recoverable backup required';
 END IF;
 IF VERSION() NOT REGEXP '^8[.]' OR (SUBSTRING_INDEX(VERSION(),'.',2)='8.0' AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(VERSION(),'.',3),'.',-1) AS UNSIGNED)<16) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='MySQL 8.0.16+ with enforced CHECK required';
 END IF;
 IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('res_project','res_project_leader','res_project_lab','res_project_tag','res_project_member','res_batch','res_batch_leader','res_batch_member','res_culture','res_culture_leader','res_culture_member','res_culture_occupancy','res_culture_notice_outbox','res_culture_parameter_application','res_culture_parameter_snapshot','res_culture_parameter_state','res_culture_workflow_reference','res_culture_runtime_event'))<>254 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Baseline column count mismatch; inspect exact schema';
 END IF;
 IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='res_culture_change_candidate') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Target table exists; inspect partial install'; END IF;
CREATE TABLE `res_culture_change_candidate` (
  `candidate_id` BIGINT NOT NULL COMMENT '培养基础变更候选',
  `culture_id` BIGINT NOT NULL COMMENT '培养',
  `scene_code` VARCHAR(32) NOT NULL,
  `change_key` VARCHAR(160) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `expected_target_version` BIGINT UNSIGNED NOT NULL,
  `before_snapshot` JSON NOT NULL COMMENT '固定原身份日期模式及设备版本',
  `after_snapshot` JSON NOT NULL COMMENT '受控基础字段候选',
  `candidate_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '候选摘要',
  `state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'PREPARED' COMMENT 'PREPARED/PENDING/APPLIED/DISCARDED/CONFLICT/UNKNOWN',
  `approval_id` BIGINT NULL COMMENT 'M06审批；DIRECT空',
  `policy_evidence` JSON NOT NULL COMMENT '固定政策与免审批依据',
  `reason` VARCHAR(500) NULL,
  `source_request_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '用户及原UUID',
  `source_request_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '请求内容',
  `decision_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '固定最终决定键',
  `decision_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '决定正文',
  `application_receipt` JSON NULL COMMENT '持久生效或封禁回执',
  `created_by` BIGINT NOT NULL COMMENT '原申请人',
  `created_at` DATETIME(3) NOT NULL COMMENT '候选提交；UTC',
  `applied_at` DATETIME(3) NULL COMMENT '实际应用；UTC',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'CAS版本',
  `active_culture_id` BIGINT GENERATED ALWAYS AS (CASE WHEN state IN ('PREPARED','PENDING','UNKNOWN') THEN culture_id ELSE NULL END) STORED,
  PRIMARY KEY (`candidate_id`),
  UNIQUE KEY `uk_m03_close_active_change` (`active_culture_id`),
  UNIQUE KEY `uk_m03_close_source` (`source_request_key`),
  UNIQUE KEY `uk_m03_close_decision` (`decision_key`),
  UNIQUE KEY `uk_m03_close_approval` (`approval_id`),
  CONSTRAINT `ck_m03_close_change_state` CHECK (state IN ('PREPARED','PENDING','APPLIED','DISCARDED','CONFLICT','UNKNOWN')),
  CONSTRAINT `ck_m03_close_change_scene` CHECK (scene_code IN ('M06_SC027','M06_SC028','M06_SC029','M03_DEVICE_CHANGE')),
  CONSTRAINT `ck_m03_close_change_json` CHECK (JSON_TYPE(before_snapshot)='OBJECT' AND JSON_TYPE(after_snapshot)='OBJECT' AND JSON_TYPE(policy_evidence)='OBJECT'),
  CONSTRAINT `ck_m03_close_change_applied` CHECK (state<>'APPLIED' OR (application_receipt IS NOT NULL AND applied_at IS NOT NULL AND decision_key IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='res_culture_change_candidate 当前设计目标';


END$$
DELIMITER ;
CALL m03_close_install_20260911();
DROP PROCEDURE m03_close_install_20260911;
