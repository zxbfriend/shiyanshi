-- M02 设计稿，2026-09-09；未在数据库执行。MySQL 8语法。
-- 先读数据库增量设计.md；逐阶段执行并检查结果，不能整包盲跑或失败重跑。
SET NAMES utf8mb4;

-- 预检中的重复及引用检查必须重新执行；结果由实施者判定，SELECT本身不会中止后续SQL。
SELECT 'bottle_config' AS table_name,(SELECT COUNT(*) FROM `bottle_config`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_bottle_config`) AS backup_count;
SELECT b.`bottle_id` AS missing_original_key FROM `bak_m02_20260909_bottle_config` b LEFT JOIN `bottle_config` a ON a.`bottle_id`=b.`bottle_id` WHERE a.`bottle_id` IS NULL;
SELECT 'calibration_object' AS table_name,(SELECT COUNT(*) FROM `calibration_object`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_calibration_object`) AS backup_count;
SELECT b.`object_id` AS missing_original_key FROM `bak_m02_20260909_calibration_object` b LEFT JOIN `calibration_object` a ON a.`object_id`=b.`object_id` WHERE a.`object_id` IS NULL;
SELECT 'consumable_master' AS table_name,(SELECT COUNT(*) FROM `consumable_master`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_consumable_master`) AS backup_count;
SELECT b.`consumable_id` AS missing_original_key FROM `bak_m02_20260909_consumable_master` b LEFT JOIN `consumable_master` a ON a.`consumable_id`=b.`consumable_id` WHERE a.`consumable_id` IS NULL;
SELECT 'consumption_rule' AS table_name,(SELECT COUNT(*) FROM `consumption_rule`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_consumption_rule`) AS backup_count;
SELECT b.`rule_id` AS missing_original_key FROM `bak_m02_20260909_consumption_rule` b LEFT JOIN `consumption_rule` a ON a.`rule_id`=b.`rule_id` WHERE a.`rule_id` IS NULL;
SELECT 'dev_air_pump_model' AS table_name,(SELECT COUNT(*) FROM `dev_air_pump_model`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_dev_air_pump_model`) AS backup_count;
SELECT b.`model_id` AS missing_original_key FROM `bak_m02_20260909_dev_air_pump_model` b LEFT JOIN `dev_air_pump_model` a ON a.`model_id`=b.`model_id` WHERE a.`model_id` IS NULL;
SELECT 'dev_analyzer_model' AS table_name,(SELECT COUNT(*) FROM `dev_analyzer_model`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_dev_analyzer_model`) AS backup_count;
SELECT b.`analyzer_id` AS missing_original_key FROM `bak_m02_20260909_dev_analyzer_model` b LEFT JOIN `dev_analyzer_model` a ON a.`analyzer_id`=b.`analyzer_id` WHERE a.`analyzer_id` IS NULL;
SELECT 'dev_bench_reactor' AS table_name,(SELECT COUNT(*) FROM `dev_bench_reactor`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_dev_bench_reactor`) AS backup_count;
SELECT b.`model_id` AS missing_original_key FROM `bak_m02_20260909_dev_bench_reactor` b LEFT JOIN `dev_bench_reactor` a ON a.`model_id`=b.`model_id` WHERE a.`model_id` IS NULL;
SELECT 'dev_culture_container_spec' AS table_name,(SELECT COUNT(*) FROM `dev_culture_container_spec`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_dev_culture_container_spec`) AS backup_count;
SELECT b.`spec_id` AS missing_original_key FROM `bak_m02_20260909_dev_culture_container_spec` b LEFT JOIN `dev_culture_container_spec` a ON a.`spec_id`=b.`spec_id` WHERE a.`spec_id` IS NULL;
SELECT 'dev_detector_item' AS table_name,(SELECT COUNT(*) FROM `dev_detector_item`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_dev_detector_item`) AS backup_count;
SELECT b.`item_id` AS missing_original_key FROM `bak_m02_20260909_dev_detector_item` b LEFT JOIN `dev_detector_item` a ON a.`item_id`=b.`item_id` WHERE a.`item_id` IS NULL;
SELECT 'dev_detector_model' AS table_name,(SELECT COUNT(*) FROM `dev_detector_model`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_dev_detector_model`) AS backup_count;
SELECT b.`model_id` AS missing_original_key FROM `bak_m02_20260909_dev_detector_model` b LEFT JOIN `dev_detector_model` a ON a.`model_id`=b.`model_id` WHERE a.`model_id` IS NULL;
SELECT 'dev_floor_scale_model' AS table_name,(SELECT COUNT(*) FROM `dev_floor_scale_model`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_dev_floor_scale_model`) AS backup_count;
SELECT b.`model_id` AS missing_original_key FROM `bak_m02_20260909_dev_floor_scale_model` b LEFT JOIN `dev_floor_scale_model` a ON a.`model_id`=b.`model_id` WHERE a.`model_id` IS NULL;
SELECT 'dev_integrated_reactor' AS table_name,(SELECT COUNT(*) FROM `dev_integrated_reactor`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_dev_integrated_reactor`) AS backup_count;
SELECT b.`model_id` AS missing_original_key FROM `bak_m02_20260909_dev_integrated_reactor` b LEFT JOIN `dev_integrated_reactor` a ON a.`model_id`=b.`model_id` WHERE a.`model_id` IS NULL;
SELECT 'dev_peristaltic_pump_model' AS table_name,(SELECT COUNT(*) FROM `dev_peristaltic_pump_model`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_dev_peristaltic_pump_model`) AS backup_count;
SELECT b.`model_id` AS missing_original_key FROM `bak_m02_20260909_dev_peristaltic_pump_model` b LEFT JOIN `dev_peristaltic_pump_model` a ON a.`model_id`=b.`model_id` WHERE a.`model_id` IS NULL;
SELECT 'feed_medium' AS table_name,(SELECT COUNT(*) FROM `feed_medium`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_feed_medium`) AS backup_count;
SELECT b.`medium_id` AS missing_original_key FROM `bak_m02_20260909_feed_medium` b LEFT JOIN `feed_medium` a ON a.`medium_id`=b.`medium_id` WHERE a.`medium_id` IS NULL;
SELECT 'lab_air_pump' AS table_name,(SELECT COUNT(*) FROM `lab_air_pump`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_air_pump`) AS backup_count;
SELECT b.`air_pump_id` AS missing_original_key FROM `bak_m02_20260909_lab_air_pump` b LEFT JOIN `lab_air_pump` a ON a.`air_pump_id`=b.`air_pump_id` WHERE a.`air_pump_id` IS NULL;
SELECT 'lab_balance' AS table_name,(SELECT COUNT(*) FROM `lab_balance`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_balance`) AS backup_count;
SELECT b.`balance_id` AS missing_original_key FROM `bak_m02_20260909_lab_balance` b LEFT JOIN `lab_balance` a ON a.`balance_id`=b.`balance_id` WHERE a.`balance_id` IS NULL;
SELECT 'lab_bench_reactor' AS table_name,(SELECT COUNT(*) FROM `lab_bench_reactor`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_bench_reactor`) AS backup_count;
SELECT b.`reactor_id` AS missing_original_key FROM `bak_m02_20260909_lab_bench_reactor` b LEFT JOIN `lab_bench_reactor` a ON a.`reactor_id`=b.`reactor_id` WHERE a.`reactor_id` IS NULL;
SELECT 'lab_bench_reactor_controller' AS table_name,(SELECT COUNT(*) FROM `lab_bench_reactor_controller`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_bench_reactor_controller`) AS backup_count;
SELECT b.`connection_id` AS missing_original_key FROM `bak_m02_20260909_lab_bench_reactor_controller` b LEFT JOIN `lab_bench_reactor_controller` a ON a.`connection_id`=b.`connection_id` WHERE a.`connection_id` IS NULL;
SELECT 'lab_bench_reactor_controller_channel' AS table_name,(SELECT COUNT(*) FROM `lab_bench_reactor_controller_channel`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_bench_reactor_controller_channel`) AS backup_count;
SELECT b.`channel_id` AS missing_original_key FROM `bak_m02_20260909_lab_bench_reactor_controller_channel` b LEFT JOIN `lab_bench_reactor_controller_channel` a ON a.`channel_id`=b.`channel_id` WHERE a.`channel_id` IS NULL;
SELECT 'lab_communication' AS table_name,(SELECT COUNT(*) FROM `lab_communication`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_communication`) AS backup_count;
SELECT b.`comm_id` AS missing_original_key FROM `bak_m02_20260909_lab_communication` b LEFT JOIN `lab_communication` a ON a.`comm_id`=b.`comm_id` WHERE a.`comm_id` IS NULL;
SELECT 'lab_culture_container' AS table_name,(SELECT COUNT(*) FROM `lab_culture_container`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_culture_container`) AS backup_count;
SELECT b.`container_id` AS missing_original_key FROM `bak_m02_20260909_lab_culture_container` b LEFT JOIN `lab_culture_container` a ON a.`container_id`=b.`container_id` WHERE a.`container_id` IS NULL;
SELECT 'lab_detection_rule' AS table_name,(SELECT COUNT(*) FROM `lab_detection_rule`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_detection_rule`) AS backup_count;
SELECT b.`rule_id` AS missing_original_key FROM `bak_m02_20260909_lab_detection_rule` b LEFT JOIN `lab_detection_rule` a ON a.`rule_id`=b.`rule_id` WHERE a.`rule_id` IS NULL;
SELECT 'lab_detector' AS table_name,(SELECT COUNT(*) FROM `lab_detector`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_detector`) AS backup_count;
SELECT b.`detector_id` AS missing_original_key FROM `bak_m02_20260909_lab_detector` b LEFT JOIN `lab_detector` a ON a.`detector_id`=b.`detector_id` WHERE a.`detector_id` IS NULL;
SELECT 'lab_detector_item_config' AS table_name,(SELECT COUNT(*) FROM `lab_detector_item_config`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_detector_item_config`) AS backup_count;
SELECT b.`detector_id` AS missing_original_key FROM `bak_m02_20260909_lab_detector_item_config` b LEFT JOIN `lab_detector_item_config` a ON a.`detector_id`=b.`detector_id` AND a.`item_id`=b.`item_id` WHERE a.`detector_id` IS NULL;
SELECT 'lab_downstream_device' AS table_name,(SELECT COUNT(*) FROM `lab_downstream_device`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_downstream_device`) AS backup_count;
SELECT b.`device_id` AS missing_original_key FROM `bak_m02_20260909_lab_downstream_device` b LEFT JOIN `lab_downstream_device` a ON a.`device_id`=b.`device_id` WHERE a.`device_id` IS NULL;
SELECT 'lab_floor_scale' AS table_name,(SELECT COUNT(*) FROM `lab_floor_scale`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_floor_scale`) AS backup_count;
SELECT b.`scale_id` AS missing_original_key FROM `bak_m02_20260909_lab_floor_scale` b LEFT JOIN `lab_floor_scale` a ON a.`scale_id`=b.`scale_id` WHERE a.`scale_id` IS NULL;
SELECT 'lab_integrated_reactor' AS table_name,(SELECT COUNT(*) FROM `lab_integrated_reactor`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_integrated_reactor`) AS backup_count;
SELECT b.`integrated_id` AS missing_original_key FROM `bak_m02_20260909_lab_integrated_reactor` b LEFT JOIN `lab_integrated_reactor` a ON a.`integrated_id`=b.`integrated_id` WHERE a.`integrated_id` IS NULL;
SELECT 'lab_integrated_reactor_pump' AS table_name,(SELECT COUNT(*) FROM `lab_integrated_reactor_pump`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_integrated_reactor_pump`) AS backup_count;
SELECT b.`integrated_id` AS missing_original_key FROM `bak_m02_20260909_lab_integrated_reactor_pump` b LEFT JOIN `lab_integrated_reactor_pump` a ON a.`integrated_id`=b.`integrated_id` AND a.`pump_id`=b.`pump_id` WHERE a.`integrated_id` IS NULL;
SELECT 'lab_integrated_reactor_pump_config' AS table_name,(SELECT COUNT(*) FROM `lab_integrated_reactor_pump_config`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_integrated_reactor_pump_config`) AS backup_count;
SELECT b.`integrated_id` AS missing_original_key FROM `bak_m02_20260909_lab_integrated_reactor_pump_config` b LEFT JOIN `lab_integrated_reactor_pump_config` a ON a.`integrated_id`=b.`integrated_id` AND a.`pump_no`=b.`pump_no` WHERE a.`integrated_id` IS NULL;
SELECT 'lab_lab' AS table_name,(SELECT COUNT(*) FROM `lab_lab`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_lab`) AS backup_count;
SELECT b.`lab_id` AS missing_original_key FROM `bak_m02_20260909_lab_lab` b LEFT JOIN `lab_lab` a ON a.`lab_id`=b.`lab_id` WHERE a.`lab_id` IS NULL;
SELECT 'lab_lab_leader' AS table_name,(SELECT COUNT(*) FROM `lab_lab_leader`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_lab_leader`) AS backup_count;
SELECT b.`lab_id` AS missing_original_key FROM `bak_m02_20260909_lab_lab_leader` b LEFT JOIN `lab_lab_leader` a ON a.`lab_id`=b.`lab_id` AND a.`user_id`=b.`user_id` WHERE a.`lab_id` IS NULL;
SELECT 'lab_peristaltic_pump' AS table_name,(SELECT COUNT(*) FROM `lab_peristaltic_pump`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_peristaltic_pump`) AS backup_count;
SELECT b.`pump_id` AS missing_original_key FROM `bak_m02_20260909_lab_peristaltic_pump` b LEFT JOIN `lab_peristaltic_pump` a ON a.`pump_id`=b.`pump_id` WHERE a.`pump_id` IS NULL;
SELECT 'lab_printer' AS table_name,(SELECT COUNT(*) FROM `lab_printer`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_printer`) AS backup_count;
SELECT b.`printer_id` AS missing_original_key FROM `bak_m02_20260909_lab_printer` b LEFT JOIN `lab_printer` a ON a.`printer_id`=b.`printer_id` WHERE a.`printer_id` IS NULL;
SELECT 'lab_printer_layout_setting' AS table_name,(SELECT COUNT(*) FROM `lab_printer_layout_setting`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_printer_layout_setting`) AS backup_count;
SELECT b.`layout_id` AS missing_original_key FROM `bak_m02_20260909_lab_printer_layout_setting` b LEFT JOIN `lab_printer_layout_setting` a ON a.`layout_id`=b.`layout_id` WHERE a.`layout_id` IS NULL;
SELECT 'lab_relay' AS table_name,(SELECT COUNT(*) FROM `lab_relay`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_relay`) AS backup_count;
SELECT b.`relay_id` AS missing_original_key FROM `bak_m02_20260909_lab_relay` b LEFT JOIN `lab_relay` a ON a.`relay_id`=b.`relay_id` WHERE a.`relay_id` IS NULL;
SELECT 'lab_sound_alarm' AS table_name,(SELECT COUNT(*) FROM `lab_sound_alarm`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_lab_sound_alarm`) AS backup_count;
SELECT b.`alarm_id` AS missing_original_key FROM `bak_m02_20260909_lab_sound_alarm` b LEFT JOIN `lab_sound_alarm` a ON a.`alarm_id`=b.`alarm_id` WHERE a.`alarm_id` IS NULL;
SELECT 'liquid_bag' AS table_name,(SELECT COUNT(*) FROM `liquid_bag`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_liquid_bag`) AS backup_count;
SELECT b.`bag_id` AS missing_original_key FROM `bak_m02_20260909_liquid_bag` b LEFT JOIN `liquid_bag` a ON a.`bag_id`=b.`bag_id` WHERE a.`bag_id` IS NULL;
SELECT 'sys_user_lab' AS table_name,(SELECT COUNT(*) FROM `sys_user_lab`) AS current_count,(SELECT COUNT(*) FROM `bak_m02_20260909_sys_user_lab`) AS backup_count;
SELECT b.`user_id` AS missing_original_key FROM `bak_m02_20260909_sys_user_lab` b LEFT JOIN `sys_user_lab` a ON a.`user_id`=b.`user_id` AND a.`lab_id`=b.`lab_id` WHERE a.`user_id` IS NULL;

SELECT comm_id FROM lab_communication WHERE applied_revision>desired_revision OR (apply_state='APPLIED' AND (applied_revision IS NULL OR applied_revision<>desired_revision));
SELECT bottle_id FROM bottle_config WHERE reading_quality='GOOD' AND (observed_at IS NULL OR observed_revision IS NULL OR observed_revision<>configuration_revision);
SELECT model_id FROM dev_detector_model WHERE single_send_limit IS NOT NULL AND single_send_limit NOT BETWEEN 1 AND 99;
SELECT connection_id FROM lab_bench_reactor_controller WHERE balance_kind IS NOT NULL AND balance_kind NOT IN ('BALANCE','FLOOR_SCALE');
SELECT user_id,lab_id,auth_type FROM sys_user_lab WHERE auth_type NOT IN ('0','1','2');
SELECT table_name,index_name,non_unique,seq_in_index,column_name FROM information_schema.statistics WHERE table_schema=DATABASE() AND index_name LIKE 'uk_m02_%' ORDER BY table_name,index_name,seq_in_index;

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

-- 动态规则六列：结构差异查询必须为空；旧数据NULL正常但不代表ready。
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
SELECT model_id FROM dev_detector_model WHERE rule_revision>0 AND rule_profile IS NULL;
SELECT detector_id FROM lab_detector WHERE (applied_rule_revision IS NULL)<>(applied_rule_snapshot IS NULL);
