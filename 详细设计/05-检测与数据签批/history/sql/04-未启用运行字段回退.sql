-- 2026-09-10 设计稿，未连接或执行数据库；MySQL 8.0.16+。
-- 维护窗口先停管理写入、派发及回调，原生一致性备份完成后逐阶段审阅；禁止--force忽略错误。
-- DDL隐式提交，不能依靠一个事务回滚整个脚本；所有关联为逻辑关联，不新增外键。
SET NAMES utf8mb4;
-- 仅同连接刚扩展、未开放业务且所有新增事实未使用；另行确认@m05_rules_never_enabled_confirmed=1。
-- 已使用后仅保留新列只读恢复；不删除业务表或备份。每个ALTER仍可能独立提交，中断需核对实际位置。
DELIMITER $$
CREATE PROCEDURE m05_rules_rollback_unused_20260910()
BEGIN
  IF DATABASE() IS NULL OR COALESCE(@m05_rules_maintenance_confirmed,0)<>1 OR COALESCE(@m05_rules_never_enabled_confirmed,0)<>1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rules: confirm maintenance window and explicit database';
  END IF;
  IF VERSION() NOT REGEXP '^8[.]' OR (SUBSTRING_INDEX(VERSION(),'.',2)='8.0' AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(VERSION(),'.',3),'.',-1) AS UNSIGNED)<16) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rules: reviewed target requires MySQL 8.0.16 or newer 8.x';
  END IF;
  IF (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_type='BASE TABLE' AND engine='InnoDB' AND table_name IN ('det_sample','det_sample_item','det_dispatch_log'))<>3 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rules: missing table, wrong type or non-InnoDB';
  END IF;
  IF COALESCE(@m05_rules_patch_started,0)<>1 OR @m05_rules_db IS NULL OR @m05_rules_db<>DATABASE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 rollback: require same-session fresh extension context';
  END IF;
  IF EXISTS(SELECT e.table_name,e.column_name,e.expected_type,e.expected_nullable,e.expected_default,
       c.column_type,c.is_nullable,c.column_default,c.extra
FROM (SELECT 'det_sample' AS table_name,'object_version' AS column_name,'bigint unsigned' AS expected_type,'NO' AS expected_nullable,'1' AS expected_default
UNION ALL
SELECT 'det_sample' AS table_name,'created_user_id' AS column_name,'bigint' AS expected_type,'YES' AS expected_nullable,NULL AS expected_default
UNION ALL
SELECT 'det_sample' AS table_name,'sent_user_id' AS column_name,'bigint' AS expected_type,'YES' AS expected_nullable,NULL AS expected_default
UNION ALL
SELECT 'det_sample' AS table_name,'occupancy_generation' AS column_name,'bigint unsigned' AS expected_type,'YES' AS expected_nullable,NULL AS expected_default
UNION ALL
SELECT 'det_sample' AS table_name,'occupancy_state' AS column_name,'varchar(16)' AS expected_type,'YES' AS expected_nullable,NULL AS expected_default
UNION ALL
SELECT 'det_sample' AS table_name,'draft_source' AS column_name,'varchar(24)' AS expected_type,'YES' AS expected_nullable,NULL AS expected_default
UNION ALL
SELECT 'det_sample' AS table_name,'current_dispatch_id' AS column_name,'bigint' AS expected_type,'YES' AS expected_nullable,NULL AS expected_default
UNION ALL
SELECT 'det_sample' AS table_name,'send_requested_at' AS column_name,'datetime(3)' AS expected_type,'YES' AS expected_nullable,NULL AS expected_default
UNION ALL
SELECT 'det_sample_item' AS table_name,'dilution_numerator' AS column_name,'smallint unsigned' AS expected_type,'YES' AS expected_nullable,NULL AS expected_default
UNION ALL
SELECT 'det_sample_item' AS table_name,'dilution_denominator' AS column_name,'smallint unsigned' AS expected_type,'YES' AS expected_nullable,NULL AS expected_default
UNION ALL
SELECT 'det_dispatch_log' AS table_name,'dispatch_lifecycle' AS column_name,'varchar(16)' AS expected_type,'YES' AS expected_nullable,NULL AS expected_default
UNION ALL
SELECT 'det_dispatch_log' AS table_name,'item_bindings' AS column_name,'json' AS expected_type,'YES' AS expected_nullable,NULL AS expected_default
UNION ALL
SELECT 'det_dispatch_log' AS table_name,'rule_snapshot' AS column_name,'json' AS expected_type,'YES' AS expected_nullable,NULL AS expected_default
UNION ALL
SELECT 'det_dispatch_log' AS table_name,'client_request_id' AS column_name,'varchar(64)' AS expected_type,'YES' AS expected_nullable,NULL AS expected_default) e
LEFT JOIN information_schema.columns c ON c.table_schema=DATABASE() AND c.table_name=e.table_name AND c.column_name=e.column_name
WHERE c.column_name IS NULL OR LOWER(c.column_type)<>e.expected_type OR c.is_nullable<>e.expected_nullable
   OR NOT(c.column_default <=> e.expected_default) OR COALESCE(c.extra,'')<>'') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 rollback: extension shape missing or differs';
  END IF;
  IF (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name IN ('bak_m05_rules_20260910_det_sample','bak_m05_rules_20260910_det_sample_item','bak_m05_rules_20260910_det_dispatch_log'))<>3 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 rollback: all three reviewed backups required';
  END IF;
  IF EXISTS(SELECT 1 FROM `det_sample` WHERE `object_version`<>1 OR `created_user_id` IS NOT NULL OR `sent_user_id` IS NOT NULL OR `occupancy_generation` IS NOT NULL OR `occupancy_state` IS NOT NULL OR `draft_source` IS NOT NULL OR `current_dispatch_id` IS NOT NULL OR `send_requested_at` IS NOT NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 rollback: new runtime data exists; preserve it';
  END IF;
  IF (SELECT COUNT(*) FROM `det_sample`)<>(SELECT COUNT(*) FROM `bak_m05_rules_20260910_det_sample`) OR EXISTS(SELECT 1 FROM `bak_m05_rules_20260910_det_sample` b LEFT JOIN `det_sample` a ON a.`sample_id`=b.`sample_id` WHERE a.`sample_id` IS NULL OR NOT((a.`sample_id` <=> b.`sample_id`) AND (a.`sample_no` <=> b.`sample_no`) AND (a.`second_id` <=> b.`second_id`) AND (a.`project_id` <=> b.`project_id`) AND (a.`batch_id` <=> b.`batch_id`) AND (a.`culture_id` <=> b.`culture_id`) AND (a.`lab_id` <=> b.`lab_id`) AND (a.`detector_id` <=> b.`detector_id`) AND (a.`detect_class` <=> b.`detect_class`) AND (a.`detect_type` <=> b.`detect_type`) AND (a.`detect_mode` <=> b.`detect_mode`) AND (a.`queue_status` <=> b.`queue_status`) AND (a.`send_batch_no` <=> b.`send_batch_no`) AND (a.`column_no` <=> b.`column_no`) AND (a.`channel_no` <=> b.`channel_no`) AND (a.`sample_position` <=> b.`sample_position`) AND (a.`day_number` <=> b.`day_number`) AND (a.`detect_count` <=> b.`detect_count`) AND (a.`temperature` <=> b.`temperature`) AND (a.`cell_type` <=> b.`cell_type`) AND (a.`dilution_factor` <=> b.`dilution_factor`) AND (a.`testing_start_time` <=> b.`testing_start_time`) AND (a.`testing_end_time` <=> b.`testing_end_time`) AND (a.`del_flag` <=> b.`del_flag`) AND (a.`clear_flag` <=> b.`clear_flag`) AND (a.`create_by` <=> b.`create_by`) AND (a.`create_time` <=> b.`create_time`) AND (a.`update_by` <=> b.`update_by`) AND (a.`update_time` <=> b.`update_time`) AND (a.`remark` <=> b.`remark`))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 rollback: original data changed in det_sample';
  END IF;
  IF EXISTS(SELECT 1 FROM `det_sample_item` WHERE `dilution_numerator` IS NOT NULL OR `dilution_denominator` IS NOT NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 rollback: new runtime data exists; preserve it';
  END IF;
  IF (SELECT COUNT(*) FROM `det_sample_item`)<>(SELECT COUNT(*) FROM `bak_m05_rules_20260910_det_sample_item`) OR EXISTS(SELECT 1 FROM `bak_m05_rules_20260910_det_sample_item` b LEFT JOIN `det_sample_item` a ON a.`sample_id`=b.`sample_id` AND a.`item_id`=b.`item_id` WHERE a.`sample_id` IS NULL OR NOT((a.`sample_id` <=> b.`sample_id`) AND (a.`item_id` <=> b.`item_id`) AND (a.`item_code` <=> b.`item_code`) AND (a.`item_cn_name` <=> b.`item_cn_name`) AND (a.`item_en_name` <=> b.`item_en_name`) AND (a.`del_flag` <=> b.`del_flag`))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 rollback: original data changed in det_sample_item';
  END IF;
  IF EXISTS(SELECT 1 FROM `det_dispatch_log` WHERE `dispatch_lifecycle` IS NOT NULL OR `item_bindings` IS NOT NULL OR `rule_snapshot` IS NOT NULL OR `client_request_id` IS NOT NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 rollback: new runtime data exists; preserve it';
  END IF;
  IF (SELECT COUNT(*) FROM `det_dispatch_log`)<>(SELECT COUNT(*) FROM `bak_m05_rules_20260910_det_dispatch_log`) OR EXISTS(SELECT 1 FROM `bak_m05_rules_20260910_det_dispatch_log` b LEFT JOIN `det_dispatch_log` a ON a.`log_id`=b.`log_id` WHERE a.`log_id` IS NULL OR NOT((a.`log_id` <=> b.`log_id`) AND (a.`request_id` <=> b.`request_id`) AND (a.`send_batch_no` <=> b.`send_batch_no`) AND (a.`detector_id` <=> b.`detector_id`) AND (a.`detect_class` <=> b.`detect_class`) AND (a.`detect_type` <=> b.`detect_type`) AND (a.`communication_type` <=> b.`communication_type`) AND (a.`invocation_mode` <=> b.`invocation_mode`) AND (a.`sample_nos` <=> b.`sample_nos`) AND (a.`device_status` <=> b.`device_status`) AND (a.`local_status` <=> b.`local_status`) AND (a.`request_summary` <=> b.`request_summary`) AND (a.`response_summary` <=> b.`response_summary`) AND (a.`error_message` <=> b.`error_message`) AND (a.`start_time` <=> b.`start_time`) AND (a.`end_time` <=> b.`end_time`) AND (a.`create_time` <=> b.`create_time`))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 rollback: original data changed in det_dispatch_log';
  END IF;
  IF EXISTS(SELECT 1 FROM information_schema.key_column_usage WHERE referenced_table_schema=DATABASE() AND referenced_table_name IN ('det_sample','det_sample_item','det_dispatch_log') AND referenced_column_name IN ('object_version','created_user_id','sent_user_id','occupancy_generation','occupancy_state','draft_source','current_dispatch_id','send_requested_at','dilution_numerator','dilution_denominator','dispatch_lifecycle','item_bindings','rule_snapshot','client_request_id')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M05 rollback: new foreign references require review';
  END IF;
  ALTER TABLE `det_dispatch_log` DROP CHECK `ck_m05_dispatch_rule_object`, DROP CHECK `ck_m05_bindings_array`, DROP CHECK `ck_m05_dispatch_lifecycle`, DROP INDEX `idx_m05_dispatch_recovery`, DROP INDEX `idx_m05_client_request`, DROP COLUMN `client_request_id`, DROP COLUMN `rule_snapshot`, DROP COLUMN `item_bindings`, DROP COLUMN `dispatch_lifecycle`;
  ALTER TABLE `det_sample_item` DROP CHECK `ck_m05_item_dilution`, DROP COLUMN `dilution_denominator`, DROP COLUMN `dilution_numerator`;
  ALTER TABLE `det_sample` DROP CHECK `ck_m05_draft_source`, DROP CHECK `ck_m05_occupancy_state`, DROP CHECK `ck_m05_occupancy_generation`, DROP CHECK `ck_m05_sample_version`, DROP INDEX `idx_m05_draft_owner`, DROP INDEX `idx_m05_dispatch`, DROP INDEX `idx_m05_occupancy`, DROP COLUMN `send_requested_at`, DROP COLUMN `current_dispatch_id`, DROP COLUMN `draft_source`, DROP COLUMN `occupancy_state`, DROP COLUMN `occupancy_generation`, DROP COLUMN `sent_user_id`, DROP COLUMN `created_user_id`, DROP COLUMN `object_version`;
  SET @m05_rules_patch_started=0;
END$$
DELIMITER ;
CALL m05_rules_rollback_unused_20260910();
DROP PROCEDURE m05_rules_rollback_unused_20260910;
