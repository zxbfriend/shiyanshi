-- 2026-09-10 设计稿，未连接或执行数据库；MySQL 8.0.16+。
-- 维护窗口先停管理写入、派发及回调，原生一致性备份完成后逐阶段审阅；禁止--force忽略错误。
-- DDL隐式提交，不能依靠一个事务回滚整个脚本；所有关联为逻辑关联，不新增外键。
SET NAMES utf8mb4;
-- 先完成M02本版02/03或旧库07补丁；此处仅新增M05十四列。
-- 操作者确认后另行SET @m05_rules_maintenance_confirmed=1；SQL不能证明外部写入已停止。
DELIMITER $$
CREATE PROCEDURE m05_rules_preflight_20260910()
BEGIN
  IF DATABASE() IS NULL OR COALESCE(@m05_rules_maintenance_confirmed,0)<>1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rules: confirm maintenance window and explicit database';
  END IF;
  IF VERSION() NOT REGEXP '^8[.]' OR (SUBSTRING_INDEX(VERSION(),'.',2)='8.0' AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(VERSION(),'.',3),'.',-1) AS UNSIGNED)<16) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rules: reviewed target requires MySQL 8.0.16 or newer 8.x';
  END IF;
  IF (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_type='BASE TABLE' AND engine='InnoDB' AND table_name IN ('dev_detector_model','lab_detector','det_sample','det_sample_item','det_dispatch_log'))<>5 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rules: missing table, wrong type or non-InnoDB';
  END IF;
  IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND ((table_name='det_sample' AND column_name IN ('object_version','created_user_id','sent_user_id','occupancy_generation','occupancy_state','draft_source','current_dispatch_id','send_requested_at')) OR (table_name='det_sample_item' AND column_name IN ('dilution_numerator','dilution_denominator')) OR (table_name='det_dispatch_log' AND column_name IN ('dispatch_lifecycle','item_bindings','rule_snapshot','client_request_id')))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rules: target columns already present or partial migration; stop and reconcile';
  END IF;
  IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name IN ('bak_m05_rules_20260910_det_sample','bak_m05_rules_20260910_det_sample_item','bak_m05_rules_20260910_det_dispatch_log')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rules: backup already exists; do not overwrite';
  END IF;
  IF EXISTS(SELECT 1 FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND constraint_name IN ('ck_m05_sample_version','ck_m05_occupancy_generation','ck_m05_occupancy_state','ck_m05_draft_source','ck_m05_item_dilution','ck_m05_dispatch_lifecycle','ck_m05_bindings_array','ck_m05_dispatch_rule_object')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rules: target constraint name already exists';
  END IF;
  IF EXISTS(SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE() AND index_name IN ('idx_m05_occupancy','idx_m05_dispatch','idx_m05_draft_owner','idx_m05_client_request','idx_m05_dispatch_recovery')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rules: target index name already exists';
  END IF;
  IF EXISTS(SELECT e.table_name,e.column_name,e.expected_type,e.expected_nullable,e.expected_default,
       c.column_type,c.is_nullable,c.column_default,c.extra
FROM (SELECT 'dev_detector_model' AS table_name,'rule_profile' AS column_name,'json' AS expected_type,'YES' AS expected_nullable,NULL AS expected_default
UNION ALL
SELECT 'dev_detector_model' AS table_name,'rule_revision' AS column_name,'bigint unsigned' AS expected_type,'NO' AS expected_nullable,'0' AS expected_default
UNION ALL
SELECT 'lab_detector' AS table_name,'queue_revision' AS column_name,'bigint unsigned' AS expected_type,'NO' AS expected_nullable,'0' AS expected_default
UNION ALL
SELECT 'lab_detector' AS table_name,'applied_rule_revision' AS column_name,'bigint unsigned' AS expected_type,'YES' AS expected_nullable,NULL AS expected_default
UNION ALL
SELECT 'lab_detector' AS table_name,'applied_rule_snapshot' AS column_name,'json' AS expected_type,'YES' AS expected_nullable,NULL AS expected_default
UNION ALL
SELECT 'lab_detector' AS table_name,'position_evidence' AS column_name,'json' AS expected_type,'YES' AS expected_nullable,NULL AS expected_default) e
LEFT JOIN information_schema.columns c ON c.table_schema=DATABASE() AND c.table_name=e.table_name AND c.column_name=e.column_name
WHERE c.column_name IS NULL OR LOWER(c.column_type)<>e.expected_type OR c.is_nullable<>e.expected_nullable
   OR NOT(c.column_default <=> e.expected_default) OR COALESCE(c.extra,'')<>'') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 rules: M02 six-column prerequisite differs; reconcile first';
  END IF;
  IF (SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND enforced='YES' AND constraint_name IN ('ck_m02_rule_object','ck_m02_rule_published','ck_m02_rule_applied_pair','ck_m02_rule_applied_object','ck_m02_position_object'))<>5 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 rules: M02 five enforced CHECK constraints required';
  END IF;
  SET @m05_rules_db=DATABASE();
  SET @m05_rules_patch_started=1;
END$$
DELIMITER ;
CALL m05_rules_preflight_20260910();
DROP PROCEDURE m05_rules_preflight_20260910;
CREATE TABLE `bak_m05_rules_20260910_det_sample` LIKE `det_sample`;
INSERT INTO `bak_m05_rules_20260910_det_sample` SELECT * FROM `det_sample`;
CREATE TABLE `bak_m05_rules_20260910_det_sample_item` LIKE `det_sample_item`;
INSERT INTO `bak_m05_rules_20260910_det_sample_item` SELECT * FROM `det_sample_item`;
CREATE TABLE `bak_m05_rules_20260910_det_dispatch_log` LIKE `det_dispatch_log`;
INSERT INTO `bak_m05_rules_20260910_det_dispatch_log` SELECT * FROM `det_dispatch_log`;
ALTER TABLE `det_sample`
  ADD COLUMN `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '样品修改、关联、状态、占位、清空/删除共同版本',
  ADD COLUMN `created_user_id` BIGINT NULL COMMENT '稳定暂存/创建用户身份；create_by继续用于原审计显示',
  ADD COLUMN `sent_user_id` BIGINT NULL COMMENT '本次真实送检操作者，确定派发时固定；不由回调登录人代填',
  ADD COLUMN `occupancy_generation` BIGINT UNSIGNED NULL COMMENT '新装入时以设备新queue_revision分配；同位置新样品必须新代次',
  ADD COLUMN `occupancy_state` VARCHAR(16) NULL COMMENT 'DRAFT/RESERVED/RUNNING/UNKNOWN/COMPLETED/RELEASED；与业务queue_status独立',
  ADD COLUMN `draft_source` VARCHAR(24) NULL COMMENT 'MANUAL/OFFLINE_UNSENT/CAPACITY_UNSENT，非未发送草稿可为NULL；不含已接受/未知请求',
  ADD COLUMN `current_dispatch_id` BIGINT NULL COMMENT '逻辑关联det_dispatch_log.log_id，最近相关调用；历史映射仍保存于每次调用',
  ADD COLUMN `send_requested_at` DATETIME(3) NULL COMMENT '发起发送动作时间，不能替代设备上样testing_start_time',
  ADD CONSTRAINT `ck_m05_sample_version` CHECK (object_version>=1),
  ADD CONSTRAINT `ck_m05_occupancy_generation` CHECK (occupancy_generation IS NULL OR occupancy_generation>0),
  ADD CONSTRAINT `ck_m05_occupancy_state` CHECK (occupancy_state IS NULL OR BINARY occupancy_state IN ('DRAFT','RESERVED','RUNNING','UNKNOWN','COMPLETED','RELEASED')),
  ADD CONSTRAINT `ck_m05_draft_source` CHECK (draft_source IS NULL OR BINARY draft_source IN ('MANUAL','OFFLINE_UNSENT','CAPACITY_UNSENT')),
  ADD INDEX `idx_m05_occupancy` (`detector_id`,`occupancy_state`,`column_no`,`channel_no`),
  ADD INDEX `idx_m05_dispatch` (`current_dispatch_id`),
  ADD INDEX `idx_m05_draft_owner` (`created_user_id`,`queue_status`,`create_time`);
ALTER TABLE `det_sample_item`
  ADD COLUMN `dilution_numerator` SMALLINT UNSIGNED NULL COMMENT '项目稀释左值，新请求固定1；旧NULL不擅自当1',
  ADD COLUMN `dilution_denominator` SMALLINT UNSIGNED NULL COMMENT '项目稀释右值，新请求1—100整数，不能复用样品dilution_factor',
  ADD CONSTRAINT `ck_m05_item_dilution` CHECK ((dilution_numerator IS NULL AND dilution_denominator IS NULL) OR (dilution_numerator IS NOT NULL AND dilution_denominator IS NOT NULL AND dilution_numerator=1 AND dilution_denominator BETWEEN 1 AND 100));
ALTER TABLE `det_dispatch_log`
  ADD COLUMN `dispatch_lifecycle` VARCHAR(16) NULL COMMENT 'PREPARED/INVOKING/RESOLVED/UNKNOWN，描述调用过程而非样品检测状态',
  ADD COLUMN `item_bindings` JSON NULL COMMENT '调用所含sampleId/resultId/列/位置/代次/期望指标及每项接受事实',
  ADD COLUMN `rule_snapshot` JSON NULL COMMENT '本次调用固定的完整规则及适配契约版本，不引用可变最新配置',
  ADD COLUMN `client_request_id` VARCHAR(64) NULL COMMENT '关联M01 HTTP幂等请求；现request_id仍为真实设备调用ID',
  ADD CONSTRAINT `ck_m05_dispatch_lifecycle` CHECK (dispatch_lifecycle IS NULL OR BINARY dispatch_lifecycle IN ('PREPARED','INVOKING','RESOLVED','UNKNOWN')),
  ADD CONSTRAINT `ck_m05_bindings_array` CHECK (item_bindings IS NULL OR JSON_TYPE(item_bindings)='ARRAY'),
  ADD CONSTRAINT `ck_m05_dispatch_rule_object` CHECK (rule_snapshot IS NULL OR JSON_TYPE(rule_snapshot)='OBJECT'),
  ADD INDEX `idx_m05_client_request` (`client_request_id`),
  ADD INDEX `idx_m05_dispatch_recovery` (`detector_id`,`dispatch_lifecycle`,`create_time`);
