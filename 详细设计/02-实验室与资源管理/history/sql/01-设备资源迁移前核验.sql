-- M02 设计稿，2026-09-09；未在数据库执行。MySQL 8语法。
-- 先读数据库增量设计.md；逐阶段执行并检查结果，不能整包盲跑或失败重跑。
SET NAMES utf8mb4;

-- 确认目标实例、数据库和SQL模式；必须与评审基线对比。
SELECT DATABASE(), VERSION(), @@sql_mode;
SELECT table_name,column_name,column_type,is_nullable,column_default FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('bottle_config','calibration_object','consumable_master','consumption_rule','dev_air_pump_model','dev_analyzer_model','dev_bench_reactor','dev_culture_container_spec','dev_detector_item','dev_detector_model','dev_floor_scale_model','dev_integrated_reactor','dev_peristaltic_pump_model','feed_medium','lab_air_pump','lab_balance','lab_bench_reactor','lab_bench_reactor_controller','lab_bench_reactor_controller_channel','lab_communication','lab_culture_container','lab_detection_rule','lab_detector','lab_detector_item_config','lab_downstream_device','lab_floor_scale','lab_integrated_reactor','lab_integrated_reactor_pump','lab_integrated_reactor_pump_config','lab_lab','lab_lab_leader','lab_peristaltic_pump','lab_printer','lab_printer_layout_setting','lab_relay','lab_sound_alarm','liquid_bag','sys_user_lab') ORDER BY table_name,ordinal_position;

-- dev_bench_reactor.uk_m02_business：以下结果须逐条处理，不自动删重。
SELECT `brand`,`category`,COUNT(*) AS duplicate_count FROM `dev_bench_reactor` WHERE del_flag='0' GROUP BY `brand`,`category` HAVING COUNT(*)>1;

-- dev_integrated_reactor.uk_m02_business：以下结果须逐条处理，不自动删重。
SELECT `model_name`,COUNT(*) AS duplicate_count FROM `dev_integrated_reactor` WHERE del_flag='0' GROUP BY `model_name` HAVING COUNT(*)>1;

-- dev_culture_container_spec.uk_m02_business：以下结果须逐条处理，不自动删重。
SELECT `container_type`,`spec`,COUNT(*) AS duplicate_count FROM `dev_culture_container_spec` WHERE del_flag='0' GROUP BY `container_type`,`spec` HAVING COUNT(*)>1;

-- dev_floor_scale_model.uk_m02_business：以下结果须逐条处理，不自动删重。
SELECT `brand`,`model_name`,COUNT(*) AS duplicate_count FROM `dev_floor_scale_model` WHERE del_flag='0' GROUP BY `brand`,`model_name` HAVING COUNT(*)>1;

-- dev_detector_item.uk_m02_business：以下结果须逐条处理，不自动删重。
SELECT `detect_class`,`item_code`,COUNT(*) AS duplicate_count FROM `dev_detector_item` WHERE del_flag='0' GROUP BY `detect_class`,`item_code` HAVING COUNT(*)>1;

-- dev_peristaltic_pump_model.uk_m02_business：以下结果须逐条处理，不自动删重。
SELECT `brand`,`model_name`,COUNT(*) AS duplicate_count FROM `dev_peristaltic_pump_model` WHERE del_flag='0' GROUP BY `brand`,`model_name` HAVING COUNT(*)>1;

-- dev_air_pump_model.uk_m02_business：以下结果须逐条处理，不自动删重。
SELECT `brand`,`model_name`,COUNT(*) AS duplicate_count FROM `dev_air_pump_model` WHERE del_flag='0' GROUP BY `brand`,`model_name` HAVING COUNT(*)>1;

-- dev_analyzer_model.uk_m02_business：以下结果须逐条处理，不自动删重。
SELECT `brand`,`model_name`,COUNT(*) AS duplicate_count FROM `dev_analyzer_model` WHERE del_flag='0' GROUP BY `brand`,`model_name` HAVING COUNT(*)>1;

-- calibration_object.uk_m02_business：以下结果须逐条处理，不自动删重。
SELECT `weight_name`,COUNT(*) AS duplicate_count FROM `calibration_object` WHERE del_flag='0' GROUP BY `weight_name` HAVING COUNT(*)>1;

-- feed_medium.uk_m02_business：以下结果须逐条处理，不自动删重。
SELECT `medium_name`,COUNT(*) AS duplicate_count FROM `feed_medium` WHERE del_flag='0' GROUP BY `medium_name` HAVING COUNT(*)>1;

-- consumable_master.uk_m02_business：以下结果须逐条处理，不自动删重。
SELECT `item_code`,COUNT(*) AS duplicate_count FROM `consumable_master` WHERE del_flag='0' GROUP BY `item_code` HAVING COUNT(*)>1;

-- liquid_bag.uk_m02_business：以下结果须逐条处理，不自动删重。
SELECT `description`,COUNT(*) AS duplicate_count FROM `liquid_bag` WHERE del_flag='0' GROUP BY `description` HAVING COUNT(*)>1;

-- lab_lab.uk_m02_business：以下结果须逐条处理，不自动删重。
SELECT `lab_name`,COUNT(*) AS duplicate_count FROM `lab_lab` WHERE del_flag='0' GROUP BY `lab_name` HAVING COUNT(*)>1;

-- lab_lab.uk_m02_code：以下结果须逐条处理，不自动删重。
SELECT `lab_code`,COUNT(*) AS duplicate_count FROM `lab_lab` WHERE del_flag='0' GROUP BY `lab_code` HAVING COUNT(*)>1;

-- lab_lab.uk_m02_asset：以下结果须逐条处理，不自动删重。
SELECT NULLIF(LOWER(TRIM(`lab_code`)), '') COLLATE utf8mb4_bin,COUNT(*) AS duplicate_count FROM `lab_lab` WHERE del_flag='0' GROUP BY NULLIF(LOWER(TRIM(`lab_code`)), '') COLLATE utf8mb4_bin HAVING COUNT(*)>1;

-- lab_detection_rule.uk_m02_business：以下结果须逐条处理，不自动删重。
SELECT `lab_id`,COUNT(*) AS duplicate_count FROM `lab_detection_rule` WHERE del_flag='0' GROUP BY `lab_id` HAVING COUNT(*)>1;

-- lab_bench_reactor_controller.uk_m02_business：以下结果须逐条处理，不自动删重。
SELECT `reactor_id`,COUNT(*) AS duplicate_count FROM `lab_bench_reactor_controller` WHERE del_flag='0' GROUP BY `reactor_id` HAVING COUNT(*)>1;

-- lab_bench_reactor_controller.uk_m02_controller：以下结果须逐条处理，不自动删重。
SELECT `lab_id`,`controller_no`,COUNT(*) AS duplicate_count FROM `lab_bench_reactor_controller` WHERE del_flag='0' GROUP BY `lab_id`,`controller_no` HAVING COUNT(*)>1;

-- lab_air_pump.uk_m02_device：以下结果须逐条处理，不自动删重。
SELECT `lab_id`,`device_no`,COUNT(*) AS duplicate_count FROM `lab_air_pump` WHERE del_flag='0' GROUP BY `lab_id`,`device_no` HAVING COUNT(*)>1;

-- lab_air_pump.uk_m02_asset：以下结果须逐条处理，不自动删重。
SELECT NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin,COUNT(*) AS duplicate_count FROM `lab_air_pump` WHERE del_flag='0' GROUP BY NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin HAVING COUNT(*)>1;

-- lab_balance.uk_m02_device：以下结果须逐条处理，不自动删重。
SELECT `lab_id`,`device_no`,COUNT(*) AS duplicate_count FROM `lab_balance` WHERE del_flag='0' GROUP BY `lab_id`,`device_no` HAVING COUNT(*)>1;

-- lab_balance.uk_m02_asset：以下结果须逐条处理，不自动删重。
SELECT NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin,COUNT(*) AS duplicate_count FROM `lab_balance` WHERE del_flag='0' GROUP BY NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin HAVING COUNT(*)>1;

-- lab_bench_reactor.uk_m02_device：以下结果须逐条处理，不自动删重。
SELECT `lab_id`,`device_no`,COUNT(*) AS duplicate_count FROM `lab_bench_reactor` WHERE del_flag='0' GROUP BY `lab_id`,`device_no` HAVING COUNT(*)>1;

-- lab_bench_reactor.uk_m02_vessel_no：以下结果须逐条处理，不自动删重。
SELECT `lab_id`,`vessel_no`,COUNT(*) AS duplicate_count FROM `lab_bench_reactor` WHERE del_flag='0' GROUP BY `lab_id`,`vessel_no` HAVING COUNT(*)>1;

-- lab_bench_reactor.uk_m02_controller_no：以下结果须逐条处理，不自动删重。
SELECT `lab_id`,`controller_no`,COUNT(*) AS duplicate_count FROM `lab_bench_reactor` WHERE del_flag='0' GROUP BY `lab_id`,`controller_no` HAVING COUNT(*)>1;

-- lab_bench_reactor.uk_m02_asset：以下结果须逐条处理，不自动删重。
SELECT NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin,COUNT(*) AS duplicate_count FROM `lab_bench_reactor` WHERE del_flag='0' GROUP BY NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin HAVING COUNT(*)>1;

-- lab_detector.uk_m02_device：以下结果须逐条处理，不自动删重。
SELECT `device_no`,COUNT(*) AS duplicate_count FROM `lab_detector` WHERE del_flag='0' GROUP BY `device_no` HAVING COUNT(*)>1;

-- lab_detector.uk_m02_asset：以下结果须逐条处理，不自动删重。
SELECT NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin,COUNT(*) AS duplicate_count FROM `lab_detector` WHERE del_flag='0' GROUP BY NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin HAVING COUNT(*)>1;

-- lab_downstream_device.uk_m02_device：以下结果须逐条处理，不自动删重。
SELECT `lab_id`,`device_no`,COUNT(*) AS duplicate_count FROM `lab_downstream_device` WHERE del_flag='0' GROUP BY `lab_id`,`device_no` HAVING COUNT(*)>1;

-- lab_downstream_device.uk_m02_asset：以下结果须逐条处理，不自动删重。
SELECT NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin,COUNT(*) AS duplicate_count FROM `lab_downstream_device` WHERE del_flag='0' GROUP BY NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin HAVING COUNT(*)>1;

-- lab_floor_scale.uk_m02_device：以下结果须逐条处理，不自动删重。
SELECT `lab_id`,`device_no`,COUNT(*) AS duplicate_count FROM `lab_floor_scale` WHERE del_flag='0' GROUP BY `lab_id`,`device_no` HAVING COUNT(*)>1;

-- lab_floor_scale.uk_m02_asset：以下结果须逐条处理，不自动删重。
SELECT NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin,COUNT(*) AS duplicate_count FROM `lab_floor_scale` WHERE del_flag='0' GROUP BY NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin HAVING COUNT(*)>1;

-- lab_peristaltic_pump.uk_m02_device：以下结果须逐条处理，不自动删重。
SELECT `lab_id`,`device_no`,COUNT(*) AS duplicate_count FROM `lab_peristaltic_pump` WHERE del_flag='0' GROUP BY `lab_id`,`device_no` HAVING COUNT(*)>1;

-- lab_peristaltic_pump.uk_m02_asset：以下结果须逐条处理，不自动删重。
SELECT NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin,COUNT(*) AS duplicate_count FROM `lab_peristaltic_pump` WHERE del_flag='0' GROUP BY NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin HAVING COUNT(*)>1;

-- lab_printer.uk_m02_device：以下结果须逐条处理，不自动删重。
SELECT `lab_id`,`device_no`,COUNT(*) AS duplicate_count FROM `lab_printer` WHERE del_flag='0' GROUP BY `lab_id`,`device_no` HAVING COUNT(*)>1;

-- lab_printer.uk_m02_asset：以下结果须逐条处理，不自动删重。
SELECT NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin,COUNT(*) AS duplicate_count FROM `lab_printer` WHERE del_flag='0' GROUP BY NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin HAVING COUNT(*)>1;

-- lab_relay.uk_m02_device：以下结果须逐条处理，不自动删重。
SELECT `lab_id`,`device_no`,COUNT(*) AS duplicate_count FROM `lab_relay` WHERE del_flag='0' GROUP BY `lab_id`,`device_no` HAVING COUNT(*)>1;

-- lab_relay.uk_m02_asset：以下结果须逐条处理，不自动删重。
SELECT NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin,COUNT(*) AS duplicate_count FROM `lab_relay` WHERE del_flag='0' GROUP BY NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin HAVING COUNT(*)>1;

-- lab_sound_alarm.uk_m02_device：以下结果须逐条处理，不自动删重。
SELECT `lab_id`,`device_no`,COUNT(*) AS duplicate_count FROM `lab_sound_alarm` WHERE del_flag='0' GROUP BY `lab_id`,`device_no` HAVING COUNT(*)>1;

-- lab_sound_alarm.uk_m02_asset：以下结果须逐条处理，不自动删重。
SELECT NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin,COUNT(*) AS duplicate_count FROM `lab_sound_alarm` WHERE del_flag='0' GROUP BY NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin HAVING COUNT(*)>1;

-- lab_culture_container.uk_m02_container：以下结果须逐条处理，不自动删重。
SELECT `lab_id`,`container_no`,COUNT(*) AS duplicate_count FROM `lab_culture_container` WHERE del_flag='0' GROUP BY `lab_id`,`container_no` HAVING COUNT(*)>1;

-- lab_culture_container.uk_m02_name：以下结果须逐条处理，不自动删重。
SELECT `lab_id`,`container_name`,COUNT(*) AS duplicate_count FROM `lab_culture_container` WHERE del_flag='0' GROUP BY `lab_id`,`container_name` HAVING COUNT(*)>1;

-- lab_culture_container.uk_m02_asset：以下结果须逐条处理，不自动删重。
SELECT NULLIF(LOWER(TRIM(`container_no`)), '') COLLATE utf8mb4_bin,COUNT(*) AS duplicate_count FROM `lab_culture_container` WHERE del_flag='0' GROUP BY NULLIF(LOWER(TRIM(`container_no`)), '') COLLATE utf8mb4_bin HAVING COUNT(*)>1;

-- lab_integrated_reactor.uk_m02_asset：以下结果须逐条处理，不自动删重。
SELECT NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin,COUNT(*) AS duplicate_count FROM `lab_integrated_reactor` WHERE del_flag='0' GROUP BY NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin HAVING COUNT(*)>1;

-- 跨表资产空间（含实验室编码）；不得输出负责人或凭据。
SELECT asset_key,COUNT(*) AS duplicate_count FROM (
SELECT 'lab_air_pump' AS source_table, CAST(`air_pump_id` AS CHAR) AS source_id, NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin AS asset_key FROM `lab_air_pump` WHERE del_flag='0'
UNION ALL
SELECT 'lab_balance' AS source_table, CAST(`balance_id` AS CHAR) AS source_id, NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin AS asset_key FROM `lab_balance` WHERE del_flag='0'
UNION ALL
SELECT 'lab_bench_reactor' AS source_table, CAST(`reactor_id` AS CHAR) AS source_id, NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin AS asset_key FROM `lab_bench_reactor` WHERE del_flag='0'
UNION ALL
SELECT 'lab_detector' AS source_table, CAST(`detector_id` AS CHAR) AS source_id, NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin AS asset_key FROM `lab_detector` WHERE del_flag='0'
UNION ALL
SELECT 'lab_downstream_device' AS source_table, CAST(`device_id` AS CHAR) AS source_id, NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin AS asset_key FROM `lab_downstream_device` WHERE del_flag='0'
UNION ALL
SELECT 'lab_floor_scale' AS source_table, CAST(`scale_id` AS CHAR) AS source_id, NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin AS asset_key FROM `lab_floor_scale` WHERE del_flag='0'
UNION ALL
SELECT 'lab_integrated_reactor' AS source_table, CAST(`integrated_id` AS CHAR) AS source_id, NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin AS asset_key FROM `lab_integrated_reactor` WHERE del_flag='0'
UNION ALL
SELECT 'lab_lab' AS source_table, CAST(`lab_id` AS CHAR) AS source_id, NULLIF(LOWER(TRIM(`lab_code`)), '') COLLATE utf8mb4_bin AS asset_key FROM `lab_lab` WHERE del_flag='0'
UNION ALL
SELECT 'lab_peristaltic_pump' AS source_table, CAST(`pump_id` AS CHAR) AS source_id, NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin AS asset_key FROM `lab_peristaltic_pump` WHERE del_flag='0'
UNION ALL
SELECT 'lab_printer' AS source_table, CAST(`printer_id` AS CHAR) AS source_id, NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin AS asset_key FROM `lab_printer` WHERE del_flag='0'
UNION ALL
SELECT 'lab_relay' AS source_table, CAST(`relay_id` AS CHAR) AS source_id, NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin AS asset_key FROM `lab_relay` WHERE del_flag='0'
UNION ALL
SELECT 'lab_sound_alarm' AS source_table, CAST(`alarm_id` AS CHAR) AS source_id, NULLIF(LOWER(TRIM(`asset_no`)), '') COLLATE utf8mb4_bin AS asset_key FROM `lab_sound_alarm` WHERE del_flag='0'
UNION ALL
SELECT 'lab_culture_container' AS source_table, CAST(`container_id` AS CHAR) AS source_id, NULLIF(LOWER(TRIM(`container_no`)), '') COLLATE utf8mb4_bin AS asset_key FROM `lab_culture_container` WHERE del_flag='0'
) a WHERE asset_key IS NOT NULL GROUP BY asset_key HAVING COUNT(*)>1;

SELECT connection_id,reactor_id,balance_id FROM lab_bench_reactor_controller WHERE del_flag='0';
SELECT comm_id,route,device_id,communication_type FROM lab_communication WHERE del_flag='0';
SELECT model_id,detect_class,detect_type FROM dev_detector_model WHERE del_flag='0';
-- 仅列身份与必要判定字段，不SELECT通讯密码。

-- 评审补充：以下人数是核验汇总，非零及合法双来源不视为迁移异常。
-- 不按账号status过滤；按(lab_id,user_id)并集去重，不用有效用户JOIN吞掉残留关系。
SELECT lab_id, COUNT(*) AS authorized_user_count FROM (
 SELECT lab_id,user_id FROM sys_user_lab
 UNION
 SELECT lab_id,user_id FROM lab_lab_leader
) current_relations GROUP BY lab_id ORDER BY lab_id;

-- 以下孤儿/删除对象残留须人工核验，不自动删除，不输出姓名或凭据。
SELECT r.source_kind,r.lab_id,r.user_id,
 CASE WHEN u.user_id IS NULL THEN 'USER_MISSING' WHEN u.del_flag<>'0' THEN 'USER_DELETED' ELSE NULL END AS user_issue,
 CASE WHEN l.lab_id IS NULL THEN 'LAB_MISSING' WHEN l.del_flag<>'0' THEN 'LAB_DELETED' ELSE NULL END AS lab_issue
FROM (
 SELECT 'DIRECT' AS source_kind,lab_id,user_id FROM sys_user_lab
 UNION ALL
 SELECT 'LAB_LEADER' AS source_kind,lab_id,user_id FROM lab_lab_leader
) r
LEFT JOIN sys_user u ON u.user_id=r.user_id
LEFT JOIN lab_lab l ON l.lab_id=r.lab_id
WHERE u.user_id IS NULL OR u.del_flag<>'0' OR l.lab_id IS NULL OR l.del_flag<>'0';

-- 2026-09-10动态规则六列盘点：已存在时核对版本，不能重跑首次部署02。
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
