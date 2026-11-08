-- M07 增量设计；MySQL 8.0.16+；DDL隐式提交；报错停止，不使用force或自动重跑。
-- 同连接显式设置 @m07_close_maintenance_confirmed=1, @m07_close_baseline_verified=1, @m07_close_backup_ref=已完成恢复验证的备份记录ID。
DELIMITER $$
CREATE PROCEDURE m07_close_install_20260911()
BEGIN
 IF DATABASE() IS NULL OR COALESCE(@m07_close_maintenance_confirmed,0)<>1 OR COALESCE(@m07_close_baseline_verified,0)<>1 OR CHAR_LENGTH(TRIM(COALESCE(@m07_close_backup_ref,'')))=0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Maintenance, exact baseline and recoverable backup required';
 END IF;
 IF VERSION() NOT REGEXP '^8[.]' OR (SUBSTRING_INDEX(VERSION(),'.',2)='8.0' AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(VERSION(),'.',3),'.',-1) AS UNSIGNED)<16) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='MySQL 8.0.16+ with enforced CHECK required';
 END IF;
 IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('run_culture_runtime','run_workflow_instance','run_workflow_step','run_material_session','run_manual_result','run_confirmation','run_calculation','run_task','run_task_candidate','run_generation','run_execution','run_execution_segment','run_command','run_resource_guard','run_execution_sample','run_exception_handling','run_ledger','run_event'))<>314 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Baseline column count mismatch; inspect exact schema';
 END IF;
 IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='run_executor_assignment') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Target table exists; inspect partial install'; END IF;
 IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='run_legacy_handover') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Target table exists; inspect partial install'; END IF;
 IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='run_culture_runtime' AND column_name='handover_id') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Target column exists; inspect partial install'; END IF;
CREATE TABLE `run_executor_assignment` (
  `resource_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `lab_id` BIGINT NOT NULL COMMENT '所属实验室',
  `executor_id` VARCHAR(128) NOT NULL,
  `assignment_epoch` BIGINT UNSIGNED NOT NULL,
  `state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'DISABLED' COMMENT 'DISABLED/ENABLED/ISOLATED/TRANSFERRING',
  `control_proof` JSON NOT NULL COMMENT '控制入口限制及网关核准证据',
  `transfer_evidence` JSON NULL COMMENT '旧执行器隔离、未决命令及接管核对',
  `updated_by` BIGINT NOT NULL COMMENT '真实维护人',
  `updated_at` DATETIME(3) NOT NULL COMMENT '变更时刻；UTC',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'CAS版本',
  PRIMARY KEY (`resource_key`),
  CONSTRAINT `ck_m07_assign_state` CHECK (state IN ('DISABLED','ENABLED','ISOLATED','TRANSFERRING')),
  CONSTRAINT `ck_m07_assign_epoch` CHECK (assignment_epoch>0 AND object_version>0 AND JSON_TYPE(control_proof)='OBJECT')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='run_executor_assignment 当前设计目标';

CREATE TABLE `run_legacy_handover` (
  `handover_id` BIGINT NOT NULL COMMENT '交接申请',
  `culture_id` BIGINT NOT NULL COMMENT '核准培养',
  `lab_id` BIGINT NOT NULL COMMENT '实验室',
  `source_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '旧系统与培养及截止点唯一键',
  `cutover_at` DATETIME(3) NOT NULL COMMENT '交接截止；UTC',
  `mapping_snapshot` JSON NOT NULL COMMENT '旧BatchID实际含义及新身份映射',
  `baseline_snapshot` JSON NOT NULL COMMENT '净量累计量物料余额及源水位',
  `baseline_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '冻结基线',
  `evidence_json` JSON NOT NULL COMMENT '现场观测与数据凭据',
  `state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'SUBMITTED' COMMENT 'SUBMITTED/APPROVED/REJECTED/STALE',
  `submitted_by` BIGINT NOT NULL COMMENT '提交复核人',
  `submitted_at` DATETIME(3) NOT NULL COMMENT '提交；UTC',
  `reviewed_by` BIGINT NULL COMMENT '第二复核人',
  `reviewed_at` DATETIME(3) NULL COMMENT '批准；UTC',
  `request_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '申请幂等',
  `review_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '决定幂等',
  `application_receipt` JSON NULL COMMENT '一次安装基线回执',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'CAS版本',
  `pending_culture_id` BIGINT GENERATED ALWAYS AS (CASE WHEN state='SUBMITTED' THEN culture_id ELSE NULL END) STORED,
  PRIMARY KEY (`handover_id`),
  UNIQUE KEY `uk_m07_handover_source` (`source_key`),
  UNIQUE KEY `uk_m07_handover_pending` (`pending_culture_id`),
  UNIQUE KEY `uk_m07_handover_request` (`request_key`),
  UNIQUE KEY `uk_m07_handover_review` (`review_key`),
  CONSTRAINT `ck_m07_handover_actor` CHECK (reviewed_by IS NULL OR reviewed_by<>submitted_by),
  CONSTRAINT `ck_m07_handover_state` CHECK (state IN ('SUBMITTED','APPROVED','REJECTED','STALE')),
  CONSTRAINT `ck_m07_handover_ready` CHECK (state<>'APPROVED' OR (reviewed_by IS NOT NULL AND reviewed_at IS NOT NULL AND application_receipt IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='run_legacy_handover 当前设计目标';

ALTER TABLE `run_culture_runtime` ADD COLUMN `handover_id` BIGINT NULL COMMENT '一次核准接续基线；NULL沿原初始量';
END$$
DELIMITER ;
CALL m07_close_install_20260911();
DROP PROCEDURE m07_close_install_20260911;
