-- M09 SQL设计稿，2026-09-10。未在MySQL执行。仅核准维护窗口手动使用；不含业务回填或真实通知。
-- MySQL >= 8.0.16，固定USE目标库须由执行人显式完成；禁止在未知库/生产业务活动中直接运行。
-- 只读输出，不输出配置秘密或通知内容。执行人须把结果同源DDL逐列比对并签署；任一差异阻断02。
SELECT DATABASE() AS target_database, VERSION() AS mysql_version;
SELECT table_name,column_name,ordinal_position,column_type,is_nullable,column_default,extra,collation_name
FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('alarm_mail_config','alarm_notify_receiver','alarm_notify_rule','alarm_record','lab_offline_alarm_config','lab_status_alarm_config','sys_notification','alarm_online_config','alarm_monitor_policy','alarm_config_revision','alarm_event','alarm_recipient','alarm_delivery','alarm_delivery_attempt','alarm_runtime') ORDER BY table_name,ordinal_position;
SELECT table_name,index_name,seq_in_index,column_name,non_unique FROM information_schema.statistics
WHERE table_schema=DATABASE() AND table_name IN ('alarm_mail_config','alarm_notify_receiver','alarm_notify_rule','alarm_record','lab_offline_alarm_config','lab_status_alarm_config','sys_notification','alarm_online_config','alarm_monitor_policy','alarm_config_revision','alarm_event','alarm_recipient','alarm_delivery','alarm_delivery_attempt','alarm_runtime') ORDER BY table_name,index_name,seq_in_index;
SELECT 'alarm_mail_config' AS table_name,COUNT(*) AS baseline_rows FROM `alarm_mail_config`;
SELECT 'alarm_notify_receiver' AS table_name,COUNT(*) AS baseline_rows FROM `alarm_notify_receiver`;
SELECT 'alarm_notify_rule' AS table_name,COUNT(*) AS baseline_rows FROM `alarm_notify_rule`;
SELECT 'alarm_record' AS table_name,COUNT(*) AS baseline_rows FROM `alarm_record`;
SELECT 'lab_offline_alarm_config' AS table_name,COUNT(*) AS baseline_rows FROM `lab_offline_alarm_config`;
SELECT 'lab_status_alarm_config' AS table_name,COUNT(*) AS baseline_rows FROM `lab_status_alarm_config`;
SELECT 'sys_notification' AS table_name,COUNT(*) AS baseline_rows FROM `sys_notification`;
SELECT 'historical_notify_users_invalid' AS check_name,COUNT(*) AS problem_rows FROM alarm_record WHERE notify_users IS NOT NULL AND notify_users <> '' AND JSON_VALID(notify_users)=0;
SELECT 'historical_offline_bounds_invalid' AS check_name,COUNT(*) AS problem_rows FROM lab_offline_alarm_config WHERE lower_limit IS NOT NULL AND upper_limit IS NOT NULL AND lower_limit >= upper_limit;
