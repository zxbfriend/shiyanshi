-- 2026-09-10 设计稿，未连接或执行数据库；MySQL 8.0.16+。
-- 维护窗口先停管理写入、派发及回调，原生一致性备份完成后逐阶段审阅；禁止--force忽略错误。
-- DDL隐式提交，不能依靠一个事务回滚整个脚本；所有关联为逻辑关联，不新增外键。
SET NAMES utf8mb4;
-- 仅在02全部执行成功后运行；三张辅助备份不得被覆盖。
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
SELECT 'lab_detector' AS table_name,'position_evidence' AS column_name,'json' AS expected_type,'YES' AS expected_nullable,NULL AS expected_default
UNION ALL
SELECT 'det_sample' AS table_name,'object_version' AS column_name,'bigint unsigned' AS expected_type,'NO' AS expected_nullable,'1' AS expected_default
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
   OR NOT(c.column_default <=> e.expected_default) OR COALESCE(c.extra,'')<>'';
-- 必须存在且ENFORCED=YES；check_clause逐项与目标DDL核对，计数不能代替语义核对。
SELECT tc.table_name,tc.constraint_name,tc.enforced,cc.check_clause
FROM information_schema.table_constraints tc JOIN information_schema.check_constraints cc
 ON cc.constraint_schema=tc.constraint_schema AND cc.constraint_name=tc.constraint_name
WHERE tc.constraint_schema=DATABASE() AND tc.constraint_name IN ('ck_m02_rule_object','ck_m02_rule_published','ck_m02_rule_applied_pair','ck_m02_rule_applied_object','ck_m02_position_object','ck_m05_sample_version','ck_m05_occupancy_generation','ck_m05_occupancy_state','ck_m05_draft_source','ck_m05_item_dilution','ck_m05_dispatch_lifecycle','ck_m05_bindings_array','ck_m05_dispatch_rule_object') ORDER BY tc.table_name,tc.constraint_name;
SELECT table_name,index_name,non_unique,seq_in_index,column_name FROM information_schema.statistics WHERE table_schema=DATABASE() AND index_name IN ('idx_m05_occupancy','idx_m05_dispatch','idx_m05_draft_owner','idx_m05_client_request','idx_m05_dispatch_recovery') ORDER BY table_name,index_name,seq_in_index;
SELECT 'det_sample' AS table_name,(SELECT COUNT(*) FROM `det_sample`) AS current_count,(SELECT COUNT(*) FROM `bak_m05_rules_20260910_det_sample`) AS backup_count;
SELECT b.`sample_id` AS changed_original_key FROM `bak_m05_rules_20260910_det_sample` b LEFT JOIN `det_sample` a ON a.`sample_id`=b.`sample_id` WHERE a.`sample_id` IS NULL OR NOT((a.`sample_id` <=> b.`sample_id`) AND (a.`sample_no` <=> b.`sample_no`) AND (a.`second_id` <=> b.`second_id`) AND (a.`project_id` <=> b.`project_id`) AND (a.`batch_id` <=> b.`batch_id`) AND (a.`culture_id` <=> b.`culture_id`) AND (a.`lab_id` <=> b.`lab_id`) AND (a.`detector_id` <=> b.`detector_id`) AND (a.`detect_class` <=> b.`detect_class`) AND (a.`detect_type` <=> b.`detect_type`) AND (a.`detect_mode` <=> b.`detect_mode`) AND (a.`queue_status` <=> b.`queue_status`) AND (a.`send_batch_no` <=> b.`send_batch_no`) AND (a.`column_no` <=> b.`column_no`) AND (a.`channel_no` <=> b.`channel_no`) AND (a.`sample_position` <=> b.`sample_position`) AND (a.`day_number` <=> b.`day_number`) AND (a.`detect_count` <=> b.`detect_count`) AND (a.`temperature` <=> b.`temperature`) AND (a.`cell_type` <=> b.`cell_type`) AND (a.`dilution_factor` <=> b.`dilution_factor`) AND (a.`testing_start_time` <=> b.`testing_start_time`) AND (a.`testing_end_time` <=> b.`testing_end_time`) AND (a.`del_flag` <=> b.`del_flag`) AND (a.`clear_flag` <=> b.`clear_flag`) AND (a.`create_by` <=> b.`create_by`) AND (a.`create_time` <=> b.`create_time`) AND (a.`update_by` <=> b.`update_by`) AND (a.`update_time` <=> b.`update_time`) AND (a.`remark` <=> b.`remark`));
SELECT 'det_sample_item' AS table_name,(SELECT COUNT(*) FROM `det_sample_item`) AS current_count,(SELECT COUNT(*) FROM `bak_m05_rules_20260910_det_sample_item`) AS backup_count;
SELECT b.`sample_id` AS changed_original_key FROM `bak_m05_rules_20260910_det_sample_item` b LEFT JOIN `det_sample_item` a ON a.`sample_id`=b.`sample_id` AND a.`item_id`=b.`item_id` WHERE a.`sample_id` IS NULL OR NOT((a.`sample_id` <=> b.`sample_id`) AND (a.`item_id` <=> b.`item_id`) AND (a.`item_code` <=> b.`item_code`) AND (a.`item_cn_name` <=> b.`item_cn_name`) AND (a.`item_en_name` <=> b.`item_en_name`) AND (a.`del_flag` <=> b.`del_flag`));
SELECT 'det_dispatch_log' AS table_name,(SELECT COUNT(*) FROM `det_dispatch_log`) AS current_count,(SELECT COUNT(*) FROM `bak_m05_rules_20260910_det_dispatch_log`) AS backup_count;
SELECT b.`log_id` AS changed_original_key FROM `bak_m05_rules_20260910_det_dispatch_log` b LEFT JOIN `det_dispatch_log` a ON a.`log_id`=b.`log_id` WHERE a.`log_id` IS NULL OR NOT((a.`log_id` <=> b.`log_id`) AND (a.`request_id` <=> b.`request_id`) AND (a.`send_batch_no` <=> b.`send_batch_no`) AND (a.`detector_id` <=> b.`detector_id`) AND (a.`detect_class` <=> b.`detect_class`) AND (a.`detect_type` <=> b.`detect_type`) AND (a.`communication_type` <=> b.`communication_type`) AND (a.`invocation_mode` <=> b.`invocation_mode`) AND (a.`sample_nos` <=> b.`sample_nos`) AND (a.`device_status` <=> b.`device_status`) AND (a.`local_status` <=> b.`local_status`) AND (a.`request_summary` <=> b.`request_summary`) AND (a.`response_summary` <=> b.`response_summary`) AND (a.`error_message` <=> b.`error_message`) AND (a.`start_time` <=> b.`start_time`) AND (a.`end_time` <=> b.`end_time`) AND (a.`create_time` <=> b.`create_time`));
-- 运行就绪盘点：以下未知记录允许结构迁移完成，但该设备不能自动ready。
SELECT sample_id,detector_id,queue_status,occupancy_state,current_dispatch_id FROM det_sample
 WHERE del_flag='0' AND (occupancy_state IS NULL OR (queue_status IN ('pending','testing') AND (current_dispatch_id IS NULL OR occupancy_generation IS NULL)));
SELECT detector_id,column_no,channel_no,COUNT(*) AS active_occupancies FROM det_sample
 WHERE occupancy_state IN ('DRAFT','RESERVED','RUNNING','UNKNOWN','COMPLETED')
 GROUP BY detector_id,column_no,channel_no HAVING COUNT(*)>1;
SELECT s.sample_id,s.current_dispatch_id FROM det_sample s LEFT JOIN det_dispatch_log l ON l.log_id=s.current_dispatch_id
 WHERE s.current_dispatch_id IS NOT NULL AND (l.log_id IS NULL OR l.detector_id<>s.detector_id);
SELECT sample_id FROM det_sample WHERE occupancy_state IN ('RESERVED','RUNNING','UNKNOWN') AND clear_flag='1';
SELECT log_id FROM det_dispatch_log WHERE dispatch_lifecycle IS NOT NULL AND (item_bindings IS NULL OR rule_snapshot IS NULL OR client_request_id IS NULL);
SELECT sample_id,item_id FROM det_sample_item WHERE (dilution_numerator IS NULL)<>(dilution_denominator IS NULL);
-- 身份映射、JSON内部sampleId/代次/期望指标一致性还需应用核验；这些SQL不是完整设备验收。
