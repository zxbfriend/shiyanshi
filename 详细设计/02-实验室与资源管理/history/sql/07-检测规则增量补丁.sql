-- 2026-09-10 设计稿，未连接或执行数据库；MySQL 8.0.16+。
-- 维护窗口先停管理写入、派发及回调，原生一致性备份完成后逐阶段审阅；禁止--force忽略错误。
-- DDL隐式提交，不能依靠一个事务回滚整个脚本；所有关联为逻辑关联，不新增外键。
SET NAMES utf8mb4;
-- 仅旧版M02已部署库；首次部署新02/03已含六列，不再执行本文件。
-- 操作者确认后另行SET @m02_rules_maintenance_confirmed=1；本稿不自动确认。
DELIMITER $$
CREATE PROCEDURE m02_rules_preflight_20260910()
BEGIN
  IF DATABASE() IS NULL OR COALESCE(@m02_rules_maintenance_confirmed,0)<>1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rules: confirm maintenance window and explicit database';
  END IF;
  IF VERSION() NOT REGEXP '^8[.]' OR (SUBSTRING_INDEX(VERSION(),'.',2)='8.0' AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(VERSION(),'.',3),'.',-1) AS UNSIGNED)<16) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rules: reviewed target requires MySQL 8.0.16 or newer 8.x';
  END IF;
  IF (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_type='BASE TABLE' AND engine='InnoDB' AND table_name IN ('dev_detector_model','lab_detector'))<>2 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rules: missing table, wrong type or non-InnoDB';
  END IF;
  IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND ((table_name='dev_detector_model' AND column_name IN ('rule_profile','rule_revision')) OR (table_name='lab_detector' AND column_name IN ('queue_revision','applied_rule_revision','applied_rule_snapshot','position_evidence')))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rules: target columns already present or partial migration; stop and reconcile';
  END IF;
  IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name IN ('bak_m02_rules_20260910_dev_detector_model','bak_m02_rules_20260910_lab_detector')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rules: backup already exists; do not overwrite';
  END IF;
  IF EXISTS(SELECT 1 FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND constraint_name IN ('ck_m02_rule_object','ck_m02_rule_published','ck_m02_rule_applied_pair','ck_m02_rule_applied_object','ck_m02_position_object')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rules: target constraint name already exists';
  END IF;
  IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND ((table_name='dev_detector_model' AND column_name='model_name') OR (table_name='dev_detector_model' AND column_name='single_send_limit') OR (table_name='dev_detector_model' AND column_name='support_dilution') OR (table_name='lab_detector' AND column_name='m02_active')))<>4 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M02 rules: prior M02 target columns not installed';
  END IF;
  SET @m02_rules_db=DATABASE();
  SET @m02_rules_patch_started=1;
END$$
DELIMITER ;
CALL m02_rules_preflight_20260910();
DROP PROCEDURE m02_rules_preflight_20260910;
CREATE TABLE `bak_m02_rules_20260910_dev_detector_model` LIKE `dev_detector_model`;
INSERT INTO `bak_m02_rules_20260910_dev_detector_model` SELECT * FROM `dev_detector_model`;
CREATE TABLE `bak_m02_rules_20260910_lab_detector` LIKE `lab_detector`;
INSERT INTO `bak_m02_rules_20260910_lab_detector` SELECT * FROM `lab_detector`;
ALTER TABLE `dev_detector_model`
  ADD COLUMN `rule_profile` JSON NULL COMMENT '扩展规则schemaVersion、layout补充、scheduling、workCapacity.unit、protection、occlusion、inputProfile；不重复旧标量',
  ADD COLUMN `rule_revision` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '0未核准；发布成功递增，模型当前配置版本',
  ADD CONSTRAINT `ck_m02_rule_object` CHECK (rule_profile IS NULL OR JSON_TYPE(rule_profile)='OBJECT'),
  ADD CONSTRAINT `ck_m02_rule_published` CHECK (rule_revision=0 OR rule_profile IS NOT NULL);
ALTER TABLE `lab_detector`
  ADD COLUMN `queue_revision` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '设备队列/位置事实版本，改变可操作性时同事务递增',
  ADD COLUMN `applied_rule_revision` BIGINT UNSIGNED NULL COMMENT '当前实例实际接入运行的型号规则修订；与所属model_id组成身份',
  ADD COLUMN `applied_rule_snapshot` JSON NULL COMMENT '已核准且已接入的完整规则快照，包含modelId/修订及旧标量固定值',
  ADD COLUMN `position_evidence` JSON NULL COMMENT '初始/当前位置证据、采集时间、事件身份与源；NULL不是初始态',
  ADD CONSTRAINT `ck_m02_rule_applied_pair` CHECK ((applied_rule_revision IS NULL AND applied_rule_snapshot IS NULL) OR (applied_rule_revision IS NOT NULL AND applied_rule_revision>0 AND applied_rule_snapshot IS NOT NULL)),
  ADD CONSTRAINT `ck_m02_rule_applied_object` CHECK (applied_rule_snapshot IS NULL OR JSON_TYPE(applied_rule_snapshot)='OBJECT'),
  ADD CONSTRAINT `ck_m02_position_object` CHECK (position_evidence IS NULL OR JSON_TYPE(position_evidence)='OBJECT');
SELECT e.table_name,e.column_name,e.expected_type,e.expected_nullable,e.expected_default,
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
   OR NOT(c.column_default <=> e.expected_default) OR COALESCE(c.extra,'')<>'';
-- 必须存在且ENFORCED=YES；check_clause逐项与目标DDL核对，计数不能代替语义核对。
SELECT tc.table_name,tc.constraint_name,tc.enforced,cc.check_clause
FROM information_schema.table_constraints tc JOIN information_schema.check_constraints cc
 ON cc.constraint_schema=tc.constraint_schema AND cc.constraint_name=tc.constraint_name
WHERE tc.constraint_schema=DATABASE() AND tc.constraint_name IN ('ck_m02_rule_object','ck_m02_rule_published','ck_m02_rule_applied_pair','ck_m02_rule_applied_object','ck_m02_position_object') ORDER BY tc.table_name,tc.constraint_name;
