-- M09 SQL设计稿，2026-09-10。未在MySQL执行。仅核准维护窗口手动使用；不含业务回填或真实通知。
-- MySQL >= 8.0.16，固定USE目标库须由执行人显式完成；禁止在未知库/生产业务活动中直接运行。
-- 只读；预期15张表及字段数与字典一致，关联异常为0；历史V1记录不伪造V2版本。
SELECT table_name,COUNT(*) AS column_count FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('alarm_mail_config','alarm_notify_receiver','alarm_notify_rule','alarm_record','lab_offline_alarm_config','lab_status_alarm_config','sys_notification','alarm_online_config','alarm_monitor_policy','alarm_config_revision','alarm_event','alarm_recipient','alarm_delivery','alarm_delivery_attempt','alarm_runtime') GROUP BY table_name ORDER BY table_name;
SELECT COUNT(*) AS invalid_v2_alarm FROM alarm_record WHERE row_version IS NOT NULL AND (event_id IS NULL OR condition_key IS NULL OR episode_no IS NULL OR condition_state NOT IN ('ACTIVE','RESOLVED') OR recipient_state NOT IN ('RESOLVED','KNOWN_EMPTY','UNKNOWN'));
SELECT 'alarm_recipient.alarm_id' AS relation_name,COUNT(*) AS invalid_rows FROM `alarm_recipient` a LEFT JOIN `alarm_record` b ON a.`alarm_id`=b.`alarm_id` WHERE a.`alarm_id` IS NOT NULL AND b.`alarm_id` IS NULL;
SELECT 'alarm_delivery.event_id' AS relation_name,COUNT(*) AS invalid_rows FROM `alarm_delivery` a LEFT JOIN `alarm_event` b ON a.`event_id`=b.`event_id` WHERE a.`event_id` IS NOT NULL AND b.`event_id` IS NULL;
SELECT 'alarm_delivery_attempt.delivery_id' AS relation_name,COUNT(*) AS invalid_rows FROM `alarm_delivery_attempt` a LEFT JOIN `alarm_delivery` b ON a.`delivery_id`=b.`delivery_id` WHERE a.`delivery_id` IS NOT NULL AND b.`delivery_id` IS NULL;
SELECT 'sys_notification.delivery_id' AS relation_name,COUNT(*) AS invalid_rows FROM `sys_notification` a LEFT JOIN `alarm_delivery` b ON a.`delivery_id`=b.`delivery_id` WHERE a.`delivery_id` IS NOT NULL AND b.`delivery_id` IS NULL;
SELECT COUNT(*) AS duplicate_site_delivery FROM (SELECT delivery_id FROM sys_notification WHERE delivery_id IS NOT NULL GROUP BY delivery_id HAVING COUNT(*)>1) x;
