-- M09 SQL设计稿，2026-09-10。未在MySQL执行。仅核准维护窗口手动使用；不含业务回填或真实通知。
-- MySQL >= 8.0.16，固定USE目标库须由执行人显式完成；禁止在未知库/生产业务活动中直接运行。
-- 只限02完整完成但V2从未启用，新增表全空且旧表新增列全NULL。已投递/启用必须停服务前滚修复或整库受控恢复，不得删除审计证据。
DELIMITER $$
CREATE PROCEDURE m09_check_unused()
BEGIN
IF EXISTS(SELECT 1 FROM `alarm_online_config` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 already used: alarm_online_config'; END IF;
IF EXISTS(SELECT 1 FROM `alarm_monitor_policy` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 already used: alarm_monitor_policy'; END IF;
IF EXISTS(SELECT 1 FROM `alarm_config_revision` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 already used: alarm_config_revision'; END IF;
IF EXISTS(SELECT 1 FROM `alarm_event` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 already used: alarm_event'; END IF;
IF EXISTS(SELECT 1 FROM `alarm_recipient` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 already used: alarm_recipient'; END IF;
IF EXISTS(SELECT 1 FROM `alarm_delivery` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 already used: alarm_delivery'; END IF;
IF EXISTS(SELECT 1 FROM `alarm_delivery_attempt` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 already used: alarm_delivery_attempt'; END IF;
IF EXISTS(SELECT 1 FROM `alarm_runtime` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 already used: alarm_runtime'; END IF;
IF EXISTS(SELECT 1 FROM `alarm_mail_config` WHERE `secret_key_version` IS NOT NULL OR `active_revision_id` IS NOT NULL LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 extensions used: alarm_mail_config'; END IF;
IF EXISTS(SELECT 1 FROM `alarm_notify_receiver` WHERE `stable_source_key` IS NOT NULL LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 extensions used: alarm_notify_receiver'; END IF;
IF EXISTS(SELECT 1 FROM `alarm_notify_rule` WHERE `active_revision_id` IS NOT NULL OR `rule_key` IS NOT NULL OR `window_policy` IS NOT NULL LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 extensions used: alarm_notify_rule'; END IF;
IF EXISTS(SELECT 1 FROM `alarm_record` WHERE `event_id` IS NOT NULL OR `condition_key` IS NOT NULL OR `episode_no` IS NOT NULL OR `condition_state` IS NOT NULL OR `resolved_at` IS NOT NULL OR `rule_revision_id` IS NOT NULL OR `recipient_state` IS NOT NULL OR `handled_user_id` IS NOT NULL OR `row_version` IS NOT NULL OR `handle_request_id` IS NOT NULL OR `handle_request_hash` IS NOT NULL OR `fact_snapshot` IS NOT NULL LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 extensions used: alarm_record'; END IF;
IF EXISTS(SELECT 1 FROM `lab_offline_alarm_config` WHERE `culture_id` IS NOT NULL OR `active_key` IS NOT NULL OR `revision_id` IS NOT NULL OR `row_version` IS NOT NULL LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 extensions used: lab_offline_alarm_config'; END IF;
IF EXISTS(SELECT 1 FROM `lab_status_alarm_config` WHERE `revision_id` IS NOT NULL OR `row_version` IS NOT NULL OR `quantity_source_ref` IS NOT NULL OR `quantity_observed_at` IS NOT NULL LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 extensions used: lab_status_alarm_config'; END IF;
IF EXISTS(SELECT 1 FROM `sys_notification` WHERE `delivery_id` IS NOT NULL OR `event_id` IS NOT NULL OR `alarm_id` IS NOT NULL OR `read_actor_id` IS NOT NULL OR `row_version` IS NOT NULL LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 extensions used: sys_notification'; END IF;
END$$
DELIMITER ;
CALL m09_check_unused();
DROP PROCEDURE m09_check_unused;
DROP TABLE `alarm_runtime`;
DROP TABLE `alarm_delivery_attempt`;
DROP TABLE `alarm_delivery`;
DROP TABLE `alarm_recipient`;
DROP TABLE `alarm_event`;
DROP TABLE `alarm_config_revision`;
DROP TABLE `alarm_monitor_policy`;
DROP TABLE `alarm_online_config`;
ALTER TABLE `alarm_mail_config` DROP COLUMN `secret_key_version`, DROP COLUMN `active_revision_id`;
ALTER TABLE `alarm_notify_receiver` DROP COLUMN `stable_source_key`;
ALTER TABLE `alarm_notify_rule` DROP INDEX `uk_m09_rule_key`, DROP COLUMN `active_revision_id`, DROP COLUMN `rule_key`, DROP COLUMN `window_policy`;
ALTER TABLE `alarm_record` DROP INDEX `uk_m09_alarm_episode`, DROP INDEX `ix_m09_alarm_scope_time`, DROP COLUMN `event_id`, DROP COLUMN `condition_key`, DROP COLUMN `episode_no`, DROP COLUMN `condition_state`, DROP COLUMN `resolved_at`, DROP COLUMN `rule_revision_id`, DROP COLUMN `recipient_state`, DROP COLUMN `handled_user_id`, DROP COLUMN `row_version`, DROP COLUMN `handle_request_id`, DROP COLUMN `handle_request_hash`, DROP COLUMN `fact_snapshot`;
ALTER TABLE `lab_offline_alarm_config` DROP INDEX `uk_m09_offline_scope`, DROP COLUMN `culture_id`, DROP COLUMN `active_key`, DROP COLUMN `revision_id`, DROP COLUMN `row_version`;
ALTER TABLE `lab_status_alarm_config` DROP COLUMN `revision_id`, DROP COLUMN `row_version`, DROP COLUMN `quantity_source_ref`, DROP COLUMN `quantity_observed_at`;
ALTER TABLE `sys_notification` DROP INDEX `uk_m09_notification_delivery`, DROP COLUMN `delivery_id`, DROP COLUMN `event_id`, DROP COLUMN `alarm_id`, DROP COLUMN `read_actor_id`, DROP COLUMN `row_version`;
