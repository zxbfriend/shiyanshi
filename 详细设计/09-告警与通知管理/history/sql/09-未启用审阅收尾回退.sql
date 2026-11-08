-- M09 仅完整安装且从未启用可回退；本包之后的包必须先回退。已产生任何新证据禁止回退。
-- 同连接设置 @m09_close_maintenance_confirmed=1, @m09_close_never_enabled_confirmed=1, @m09_close_backup_ref=真实备份记录。
DELIMITER $$
CREATE PROCEDURE m09_close_unused_rollback_20260911()
BEGIN
 IF DATABASE() IS NULL OR COALESCE(@m09_close_maintenance_confirmed,0)<>1 OR COALESCE(@m09_close_never_enabled_confirmed,0)<>1 OR CHAR_LENGTH(TRIM(COALESCE(@m09_close_backup_ref,'')))=0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unused rollback confirmations required'; END IF;
 IF EXISTS(SELECT 1 FROM `alarm_config_revision` WHERE `decision_snapshot` IS NOT NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New column used: rollback forbidden'; END IF;
 IF EXISTS(SELECT 1 FROM `alarm_config_revision` WHERE `application_receipt` IS NOT NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New column used: rollback forbidden'; END IF;
ALTER TABLE `sys_notification` DROP CHECK `ck_m09_close_notification_ready`;
ALTER TABLE `sys_notification` DROP CHECK `ck_m09_close_notification_read`;
ALTER TABLE `lab_status_alarm_config` DROP CHECK `ck_m09_close_status_ready`;
ALTER TABLE `lab_offline_alarm_config` DROP CHECK `ck_m09_close_offline_ready`;
ALTER TABLE `sys_notification` DROP CHECK `ck_m09_close_ver_sys_notification`;
ALTER TABLE `lab_status_alarm_config` DROP CHECK `ck_m09_close_ver_lab_status_alarm_config`;
ALTER TABLE `lab_offline_alarm_config` DROP CHECK `ck_m09_close_ver_lab_offline_alarm_config`;
ALTER TABLE `alarm_online_config` DROP CHECK `ck_m09_close_ver_online_config`;
ALTER TABLE `alarm_monitor_policy` DROP CHECK `ck_m09_close_ver_monitor_policy`;
ALTER TABLE `alarm_event` DROP CHECK `ck_m09_close_ver_event`;
ALTER TABLE `alarm_online_config` DROP CHECK `ck_m09_close_online_time`;
ALTER TABLE `alarm_online_config` DROP CHECK `ck_m09_close_online_mode`;
ALTER TABLE `alarm_online_config` DROP CHECK `ck_m09_close_online_limits`;
ALTER TABLE `alarm_online_config` DROP CHECK `ck_m09_close_online_scope`;
ALTER TABLE `alarm_recipient` DROP CHECK `ck_m09_close_recipient`;
ALTER TABLE `alarm_config_revision` DROP CHECK `ck_m09_close_revision`;
ALTER TABLE `alarm_monitor_policy` DROP CHECK `ck_m09_close_monitor`;
ALTER TABLE `alarm_runtime` DROP CHECK `ck_m09_close_active`;
ALTER TABLE `alarm_runtime` DROP CHECK `ck_m09_close_runtime`;
ALTER TABLE `alarm_delivery_attempt` DROP CHECK `ck_m09_close_attempt_terminal`;
ALTER TABLE `alarm_delivery_attempt` DROP CHECK `ck_m09_close_attempt`;
ALTER TABLE `alarm_delivery` DROP CHECK `ck_m09_close_cipher`;
ALTER TABLE `alarm_delivery` DROP CHECK `ck_m09_close_delivery_lease`;
ALTER TABLE `alarm_delivery` DROP CHECK `ck_m09_close_channel`;
ALTER TABLE `alarm_delivery` DROP CHECK `ck_m09_close_delivery_state`;
ALTER TABLE `alarm_event` DROP CHECK `ck_m09_close_event_json`;
ALTER TABLE `alarm_event` DROP CHECK `ck_m09_close_condition`;
ALTER TABLE `alarm_event` DROP CHECK `ck_m09_close_event_state`;
ALTER TABLE `alarm_record` DROP CHECK `ck_m09_close_resolved`;
ALTER TABLE `alarm_record` DROP CHECK `ck_m09_close_alarm_states`;
ALTER TABLE `alarm_record` DROP CHECK `ck_m09_close_handle`;
ALTER TABLE `alarm_notify_receiver` DROP CHECK `ck_m09_close_receiver_source`;
ALTER TABLE `alarm_mail_config` DROP CHECK `ck_m09_close_port`;
ALTER TABLE `alarm_notify_rule` DROP CHECK `ck_m09_close_rule_ready`;
ALTER TABLE `alarm_notify_rule` DROP CHECK `ck_m09_close_mode`;
ALTER TABLE `alarm_config_revision` DROP COLUMN `application_receipt`;
ALTER TABLE `alarm_config_revision` DROP COLUMN `decision_snapshot`;

END$$
DELIMITER ;
CALL m09_close_unused_rollback_20260911();
DROP PROCEDURE m09_close_unused_rollback_20260911;
