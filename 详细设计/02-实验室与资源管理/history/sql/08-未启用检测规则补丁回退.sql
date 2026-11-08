-- 2026-09-10 设计稿，未连接或执行数据库；MySQL 8.0.16+。
-- 维护窗口先停管理写入、派发及回调，原生一致性备份完成后逐阶段审阅；禁止--force忽略错误。
-- DDL隐式提交，不能依靠一个事务回滚整个脚本；所有关联为逻辑关联，不新增外键。
SET NAMES utf8mb4;
-- 只回退六个尚未使用的检测规则字段，不回退其他M02改造；另行确认@m02_rules_unused_rollback_confirmed=1。
-- 确认备份和应用停写；M05扩展先安全回退。任何已发布规则或队列事实均阻断。
DELIMITER $$
CREATE PROCEDURE m02_rules_rollback_unused_20260910()
BEGIN
  IF DATABASE() IS NULL OR COALESCE(@m02_rules_unused_rollback_confirmed,0)<>1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rules: confirm maintenance window and explicit database';
  END IF;
  IF VERSION() NOT REGEXP '^8[.]' OR (SUBSTRING_INDEX(VERSION(),'.',2)='8.0' AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(VERSION(),'.',3),'.',-1) AS UNSIGNED)<16) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rules: reviewed target requires MySQL 8.0.16 or newer 8.x';
  END IF;
  IF (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_type='BASE TABLE' AND engine='InnoDB' AND table_name IN ('dev_detector_model','lab_detector'))<>2 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rules: missing table, wrong type or non-InnoDB';
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
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M02 rollback: six-column shape differs';
  END IF;
  IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND ((table_name='det_sample' AND column_name IN ('object_version','created_user_id','sent_user_id','occupancy_generation','occupancy_state','draft_source','current_dispatch_id','send_requested_at')) OR (table_name='det_sample_item' AND column_name IN ('dilution_numerator','dilution_denominator')) OR (table_name='det_dispatch_log' AND column_name IN ('dispatch_lifecycle','item_bindings','rule_snapshot','client_request_id')))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M02 rollback: remove unused M05 extension first';
  END IF;
  IF EXISTS(SELECT 1 FROM `dev_detector_model` WHERE `rule_profile` IS NOT NULL OR `rule_revision`<>0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M02 rollback: rule or queue facts exist; do not drop';
  END IF;
  IF EXISTS(SELECT 1 FROM `lab_detector` WHERE `queue_revision`<>0 OR `applied_rule_revision` IS NOT NULL OR `applied_rule_snapshot` IS NOT NULL OR `position_evidence` IS NOT NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M02 rollback: rule or queue facts exist; do not drop';
  END IF;
  IF EXISTS(SELECT 1 FROM information_schema.key_column_usage WHERE referenced_table_schema=DATABASE() AND referenced_table_name IN ('dev_detector_model','lab_detector') AND referenced_column_name IN ('rule_profile','rule_revision','queue_revision','applied_rule_revision','applied_rule_snapshot','position_evidence')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M02 rollback: foreign reference to new rule fields';
  END IF;
  ALTER TABLE `lab_detector` DROP CHECK `ck_m02_position_object`, DROP CHECK `ck_m02_rule_applied_object`, DROP CHECK `ck_m02_rule_applied_pair`, DROP COLUMN `position_evidence`, DROP COLUMN `applied_rule_snapshot`, DROP COLUMN `applied_rule_revision`, DROP COLUMN `queue_revision`;
  ALTER TABLE `dev_detector_model` DROP CHECK `ck_m02_rule_published`, DROP CHECK `ck_m02_rule_object`, DROP COLUMN `rule_revision`, DROP COLUMN `rule_profile`;
END$$
DELIMITER ;
CALL m02_rules_rollback_unused_20260910();
DROP PROCEDURE m02_rules_rollback_unused_20260910;
