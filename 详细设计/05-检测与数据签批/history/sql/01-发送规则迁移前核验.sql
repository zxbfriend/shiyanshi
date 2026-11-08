-- 2026-09-10 设计稿，未连接或执行数据库；MySQL 8.0.16+。
-- 维护窗口先停管理写入、派发及回调，原生一致性备份完成后逐阶段审阅；禁止--force忽略错误。
-- DDL隐式提交，不能依靠一个事务回滚整个脚本；所有关联为逻辑关联，不新增外键。
SET NAMES utf8mb4;
SELECT DATABASE(),VERSION(),@@sql_mode;
-- 五表目标字段盘点，NULL/缺失必须按部署路径核对，不自动回填。
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
SELECT detector_id,column_no,channel_no,COUNT(*) AS visible_count FROM det_sample WHERE del_flag='0' AND clear_flag='0' GROUP BY detector_id,column_no,channel_no HAVING COUNT(*)>1;
SELECT sample_id,detector_id,queue_status FROM det_sample WHERE queue_status IN ('pending','testing','timeout','exception') AND del_flag='0';
SELECT log_id,request_id,device_status,local_status FROM det_dispatch_log WHERE device_status='unknown' OR local_status='unknown';
-- 以下仅盘点，不按create_by同名直接回填稳定身份。
SELECT create_by,COUNT(*) AS sample_count FROM det_sample GROUP BY create_by;
