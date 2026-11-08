-- M09 SQL设计稿，2026-09-10。未在MySQL执行。仅核准维护窗口手动使用；不含业务回填或真实通知。
-- MySQL >= 8.0.16，固定USE目标库须由执行人显式完成；禁止在未知库/生产业务活动中直接运行。
-- 仅在01逐列结构比对、备份、停写和依赖核准完成后运行。计数门禁只是附加检查，不能代替逐列比对。
-- DDL隐式提交。任何错误立即停下；禁止mysql --force，禁止全脚本重复执行。
DELIMITER $$
CREATE PROCEDURE m09_check_baseline()
BEGIN
IF DATABASE() IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Select approved database explicitly'; END IF;
IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='alarm_mail_config') <> 18 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 baseline column count mismatch: alarm_mail_config'; END IF;
IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='alarm_notify_receiver') <> 7 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 baseline column count mismatch: alarm_notify_receiver'; END IF;
IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='alarm_notify_rule') <> 18 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 baseline column count mismatch: alarm_notify_rule'; END IF;
IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='alarm_record') <> 28 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 baseline column count mismatch: alarm_record'; END IF;
IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='lab_offline_alarm_config') <> 13 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 baseline column count mismatch: lab_offline_alarm_config'; END IF;
IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='lab_status_alarm_config') <> 18 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 baseline column count mismatch: lab_status_alarm_config'; END IF;
IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='sys_notification') <> 11 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 baseline column count mismatch: sys_notification'; END IF;
IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='alarm_online_config') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 new table already exists: alarm_online_config'; END IF;
IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='alarm_monitor_policy') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 new table already exists: alarm_monitor_policy'; END IF;
IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='alarm_config_revision') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 new table already exists: alarm_config_revision'; END IF;
IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='alarm_event') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 new table already exists: alarm_event'; END IF;
IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='alarm_recipient') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 new table already exists: alarm_recipient'; END IF;
IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='alarm_delivery') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 new table already exists: alarm_delivery'; END IF;
IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='alarm_delivery_attempt') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 new table already exists: alarm_delivery_attempt'; END IF;
IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='alarm_runtime') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M09 new table already exists: alarm_runtime'; END IF;
END$$
DELIMITER ;
CALL m09_check_baseline();
DROP PROCEDURE m09_check_baseline;

ALTER TABLE `alarm_mail_config`
  ADD COLUMN `secret_key_version` varchar(64) NULL DEFAULT NULL COMMENT '密文密钥版本；未知禁止投递',
  ADD COLUMN `active_revision_id` bigint NULL DEFAULT NULL COMMENT '当前配置修订ID';

ALTER TABLE `alarm_notify_receiver`
  ADD COLUMN `stable_source_key` varchar(100) NULL DEFAULT NULL COMMENT '来源稳定键；CULTURE_MEMBER或DEVICE_OWNER或ROLE角色ID';

ALTER TABLE `alarm_notify_rule`
  ADD COLUMN `active_revision_id` bigint NULL DEFAULT NULL COMMENT '当前核准规则修订ID',
  ADD COLUMN `rule_key` varchar(64) NULL DEFAULT NULL COMMENT '稳定规则键；附件M09-R001至R042及扩展规则',
  ADD COLUMN `window_policy` varchar(30) NULL DEFAULT NULL COMMENT 'NO_CATCH_UP；Q02已确认：时段外触发仅记录，开窗不补发',
  ADD UNIQUE KEY `uk_m09_rule_key` (`rule_key`);

ALTER TABLE `alarm_record`
  ADD COLUMN `event_id` bigint NULL DEFAULT NULL COMMENT '首次触发事件ID',
  ADD COLUMN `condition_key` varchar(64) NULL DEFAULT NULL COMMENT '语义条件SHA256；旧数据未知为NULL',
  ADD COLUMN `episode_no` bigint NULL DEFAULT NULL COMMENT '同条件告警轮次，从1开始',
  ADD COLUMN `condition_state` varchar(20) NULL DEFAULT NULL COMMENT 'ACTIVE或RESOLVED；与人工处理独立',
  ADD COLUMN `resolved_at` datetime(3) NULL DEFAULT NULL COMMENT '可信恢复时间',
  ADD COLUMN `rule_revision_id` bigint NULL DEFAULT NULL COMMENT '触发时通知规则修订ID',
  ADD COLUMN `recipient_state` varchar(20) NULL DEFAULT NULL COMMENT 'RESOLVED或KNOWN_EMPTY或UNKNOWN',
  ADD COLUMN `handled_user_id` bigint NULL DEFAULT NULL COMMENT '人工处理稳定用户ID',
  ADD COLUMN `row_version` bigint NULL DEFAULT NULL COMMENT 'V2并发版本，从1递增',
  ADD COLUMN `handle_request_id` varchar(64) NULL DEFAULT NULL COMMENT '最终成功处理请求ID',
  ADD COLUMN `handle_request_hash` varchar(64) NULL DEFAULT NULL COMMENT '处理请求规范摘要',
  ADD COLUMN `fact_snapshot` json NULL DEFAULT NULL COMMENT '首次事实白名单快照',
  ADD UNIQUE KEY `uk_m09_alarm_episode` (`condition_key`,`episode_no`),
  ADD KEY `ix_m09_alarm_scope_time` (`lab_id`,`trigger_time`,`alarm_id`);

ALTER TABLE `lab_offline_alarm_config`
  ADD COLUMN `culture_id` bigint NULL DEFAULT NULL COMMENT '当前培养ID；旧实验室全局配置不自动扩散',
  ADD COLUMN `active_key` varchar(64) NULL DEFAULT NULL COMMENT '培养检测类型指标有效键SHA256',
  ADD COLUMN `revision_id` bigint NULL DEFAULT NULL COMMENT '生效修订ID',
  ADD COLUMN `row_version` bigint NULL DEFAULT NULL COMMENT 'V2版本，从1递增',
  ADD UNIQUE KEY `uk_m09_offline_scope` (`active_key`);

ALTER TABLE `lab_status_alarm_config`
  ADD COLUMN `revision_id` bigint NULL DEFAULT NULL COMMENT '当前整组配置修订ID',
  ADD COLUMN `row_version` bigint NULL DEFAULT NULL COMMENT 'V2版本，从1递增',
  ADD COLUMN `quantity_source_ref` json NULL DEFAULT NULL COMMENT '可信当前数量来源；未知不得触发',
  ADD COLUMN `quantity_observed_at` datetime(3) NULL DEFAULT NULL COMMENT '可信当前数量观测时间';

ALTER TABLE `sys_notification`
  ADD COLUMN `delivery_id` bigint NULL DEFAULT NULL COMMENT '唯一站内信投递ID',
  ADD COLUMN `event_id` bigint NULL DEFAULT NULL COMMENT '来源事件ID',
  ADD COLUMN `alarm_id` bigint NULL DEFAULT NULL COMMENT '关联告警ID；普通消息可空',
  ADD COLUMN `read_actor_id` bigint NULL DEFAULT NULL COMMENT '实际标记已读人稳定ID；管理员与目标人区分',
  ADD COLUMN `row_version` bigint NULL DEFAULT NULL COMMENT 'V2版本，从1递增',
  ADD UNIQUE KEY `uk_m09_notification_delivery` (`delivery_id`);

CREATE TABLE `alarm_online_config` (
  `config_id` bigint NOT NULL COMMENT '主键',
  `scope_key` varchar(64) NOT NULL COMMENT '设备或培养加设备及指标的SHA256有效键',
  `scope_kind` varchar(20) NOT NULL COMMENT 'DEVICE或CULTURE',
  `lab_id` bigint NOT NULL COMMENT '所属实验室',
  `device_kind` varchar(40) NOT NULL COMMENT 'M02 DeviceKind',
  `device_id` bigint NOT NULL COMMENT '设备稳定ID',
  `culture_id` bigint NULL COMMENT '培养ID；DEVICE时空',
  `item_id` bigint NOT NULL COMMENT 'M02检测项目ID',
  `unit` varchar(30) NOT NULL COMMENT '项目单位快照',
  `set_value` decimal(20,6) NULL COMMENT '设定值',
  `limit_percent` int NULL COMMENT '正整数上下限百分比',
  `lower_limit` decimal(20,6) NULL COMMENT '最终报警下限',
  `upper_limit` decimal(20,6) NULL COMMENT '最终报警上限',
  `stagnant_limit` decimal(20,6) NULL COMMENT '呆滞限值，仅保存待外部逻辑核准',
  `stagnant_seconds` decimal(14,3) NULL COMMENT '呆滞时长秒，仅保存',
  `upper_delay_seconds` decimal(14,3) NULL COMMENT '上限延迟秒，仅保存',
  `lower_delay_seconds` decimal(14,3) NULL COMMENT '下限延迟秒，仅保存',
  `cycle_seconds` decimal(14,3) NULL COMMENT '循环间隔秒，仅保存',
  `cycle_enabled` char(1) NOT NULL COMMENT '0关闭或1开启',
  `methods_json` json NOT NULL COMMENT '保存原页面sms、phone、email、sound选项',
  `enabled` char(1) NOT NULL COMMENT '0关闭或1开启；与旧离线enabled编码不同',
  `evaluation_state` varchar(20) NOT NULL COMMENT 'SAVE_ONLY或VERIFIED',
  `logic_profile_ref` json NULL COMMENT '核准外部告警逻辑及版本；无则不得执行高级字段',
  `revision_id` bigint NOT NULL COMMENT '生效配置修订',
  `row_version` bigint NOT NULL COMMENT '并发版本',
  `updated_by` bigint NOT NULL COMMENT '修改人',
  `updated_at` datetime(3) NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `uk_m09_online_scope` (`scope_key`),
  KEY `ix_m09_online_culture` (`culture_id`,`device_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='在线告警现行配置';

CREATE TABLE `alarm_monitor_policy` (
  `policy_id` bigint NOT NULL COMMENT '主键',
  `scope_key` varchar(64) NOT NULL COMMENT '设备和培养稳定键',
  `lab_id` bigint NOT NULL COMMENT '实验室',
  `device_kind` varchar(40) NOT NULL COMMENT 'M02设备类型',
  `device_id` bigint NOT NULL COMMENT '设备ID',
  `culture_id` bigint NULL COMMENT '培养ID',
  `monitor_mode` varchar(20) NOT NULL COMMENT 'ON或TEMP_OFF或LONG_OFF',
  `remark` varchar(500) NULL COMMENT '备注',
  `revision_id` bigint NOT NULL COMMENT '生效修订ID',
  `row_version` bigint NOT NULL COMMENT '并发版本',
  `updated_by` bigint NOT NULL COMMENT '修改人',
  `updated_at` datetime(3) NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`policy_id`),
  UNIQUE KEY `uk_m09_monitor_scope` (`scope_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='泵速异动和台秤移动监控开关';

CREATE TABLE `alarm_config_revision` (
  `revision_id` bigint NOT NULL COMMENT '主键',
  `config_kind` varchar(20) NOT NULL COMMENT 'RULE或MAIL或ONLINE或OFFLINE或STATUS或MONITOR',
  `scope_key` varchar(64) NOT NULL COMMENT '配置集合语义键',
  `base_revision_id` bigint NULL COMMENT '修改前修订；首次为NULL',
  `request_key` varchar(64) NOT NULL COMMENT '用户、接口、requestId的SHA256',
  `request_hash` varchar(64) NOT NULL COMMENT '请求规范摘要',
  `content_json` json NOT NULL COMMENT '固定候选内容，不含明文密码',
  `content_hash` varchar(64) NOT NULL COMMENT '固定内容SHA256',
  `revision_state` varchar(20) NOT NULL COMMENT 'PENDING或APPLIED或DISCARDED或CONFLICT',
  `approval_id` bigint NULL COMMENT 'M06审批单ID',
  `created_by` bigint NOT NULL COMMENT '申请人',
  `created_at` datetime(3) NOT NULL COMMENT '创建时间',
  `applied_at` datetime(3) NULL COMMENT '实际生效时间',
  `reason` varchar(500) NULL COMMENT '原因',
  `row_version` bigint NOT NULL COMMENT '状态转换版本',
  PRIMARY KEY (`revision_id`),
  UNIQUE KEY `uk_m09_config_request` (`request_key`),
  KEY `ix_m09_config_scope` (`scope_key`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='不可变配置候选与生效证据';

CREATE TABLE `alarm_event` (
  `event_id` bigint NOT NULL COMMENT '主键',
  `source_module` varchar(20) NOT NULL COMMENT 'M01至M09或核准适配器',
  `source_event_key` varchar(64) NOT NULL COMMENT '源事件ID规范SHA256',
  `source_event_id` varchar(200) NOT NULL COMMENT '源事件原ID',
  `source_object_kind` varchar(40) NOT NULL COMMENT '来源对象类型',
  `source_object_id` varchar(100) NOT NULL COMMENT '来源对象稳定ID',
  `source_version` varchar(100) NOT NULL COMMENT '来源事实版本',
  `rule_key` varchar(64) NULL COMMENT '规则键，外部推送可空',
  `event_kind` varchar(30) NOT NULL COMMENT 'TRIGGER或RECOVER或BUSINESS或EXTERNAL_PUSH',
  `condition_key` varchar(64) NULL COMMENT '持续条件语义键',
  `source_sequence` bigint NULL COMMENT '同条件单调序列；持续条件必填',
  `lab_id` bigint NULL COMMENT '实验室',
  `culture_id` bigint NULL COMMENT '培养ID',
  `occurred_at` datetime(3) NOT NULL COMMENT '事实发生时间',
  `received_at` datetime(3) NOT NULL COMMENT '收件时间',
  `payload_json` json NOT NULL COMMENT '版本1白名单事实',
  `payload_hash` varchar(64) NOT NULL COMMENT '相同源ID重复内容校验',
  `process_state` varchar(20) NOT NULL COMMENT 'RECEIVED或APPLIED或IGNORED或BLOCKED',
  `result_ref` json NULL COMMENT '生成告警和投递ID及原因',
  `lease_token` varchar(64) NULL COMMENT '处理租约栅栏token',
  `lease_until` datetime(3) NULL COMMENT '租约截止',
  `row_version` bigint NOT NULL COMMENT '并发版本',
  PRIMARY KEY (`event_id`),
  UNIQUE KEY `uk_m09_event_source` (`source_module`,`source_event_key`),
  KEY `ix_m09_event_work` (`process_state`,`lease_until`,`event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='可靠事件收件与处理证据';

CREATE TABLE `alarm_recipient` (
  `recipient_id` bigint NOT NULL COMMENT '主键',
  `alarm_id` bigint NOT NULL COMMENT '告警ID',
  `user_id` bigint NOT NULL COMMENT '用户稳定ID',
  `source_json` json NOT NULL COMMENT 'CULTURE_MEMBER、DEVICE_OWNER、ROLE来源并集',
  `display_name` varchar(100) NOT NULL COMMENT '触发时姓名快照',
  `authorization_ref` json NOT NULL COMMENT '当时资格版本，不替代当前鉴权',
  `created_at` datetime(3) NOT NULL COMMENT '解析时间',
  PRIMARY KEY (`recipient_id`),
  UNIQUE KEY `uk_m09_recipient` (`alarm_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='告警稳定接收人与资格快照';

CREATE TABLE `alarm_delivery` (
  `delivery_id` bigint NOT NULL COMMENT '主键',
  `delivery_key` varchar(64) NOT NULL COMMENT '事件或告警、轮次、目标、通道SHA256',
  `event_id` bigint NOT NULL COMMENT '来源事件ID',
  `alarm_id` bigint NULL COMMENT '告警ID；外部推送和普通消息可空',
  `round_no` int NOT NULL COMMENT '告警通知轮次，从1开始',
  `target_kind` varchar(20) NOT NULL COMMENT 'USER或SOUND或EXTERNAL',
  `target_key` varchar(100) NOT NULL COMMENT '用户ID或设备身份或外部目的端配置ID',
  `channel` varchar(20) NOT NULL COMMENT 'site或email或sms或sound或external',
  `rule_revision_id` bigint NULL COMMENT '规则修订',
  `config_revision_id` bigint NULL COMMENT '投递配置修订',
  `template_revision` varchar(64) NOT NULL COMMENT '核准模板版本',
  `address_cipher` text NULL COMMENT '邮箱手机号等目标密文；站内无需',
  `address_key_version` varchar(64) NULL COMMENT '目标加密密钥版本',
  `title` varchar(200) NOT NULL COMMENT '脱敏受控标题',
  `content_cipher` mediumtext NULL COMMENT '发送内容密文；无秘密时仍按受控内容存储',
  `content_key_version` varchar(64) NULL COMMENT '内容密钥版本',
  `content_hash` varchar(64) NOT NULL COMMENT '固定发送内容摘要',
  `delivery_state` varchar(20) NOT NULL COMMENT 'PENDING或SENDING或SUCCEEDED或FAILED或UNKNOWN或SKIPPED或CANCELLED',
  `reason_code` varchar(64) NULL COMMENT '失败、跳过或取消原因',
  `scheduled_at` datetime(3) NOT NULL COMMENT '最早发送时间',
  `attempt_count` int NOT NULL COMMENT '实际尝试次数，从0开始',
  `provider_ref` varchar(200) NULL COMMENT '提供商回执ID；接收不等于送达',
  `lease_token` varchar(64) NULL COMMENT '发送租约栅栏token',
  `lease_until` datetime(3) NULL COMMENT '发送租约截止',
  `created_at` datetime(3) NOT NULL COMMENT '建任务时间',
  `updated_at` datetime(3) NOT NULL COMMENT '投影更新时间',
  `row_version` bigint NOT NULL COMMENT '并发版本',
  PRIMARY KEY (`delivery_id`),
  UNIQUE KEY `uk_m09_delivery` (`delivery_key`),
  KEY `ix_m09_delivery_work` (`delivery_state`,`scheduled_at`,`delivery_id`),
  KEY `ix_m09_delivery_target` (`target_kind`,`target_key`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='每轮每目标每通道的投递任务';

CREATE TABLE `alarm_delivery_attempt` (
  `attempt_id` bigint NOT NULL COMMENT '主键',
  `delivery_id` bigint NOT NULL COMMENT '投递ID',
  `attempt_no` int NOT NULL COMMENT '该投递尝试序号',
  `request_key` varchar(64) NOT NULL COMMENT '自动租约或人工requestId规范键',
  `request_hash` varchar(64) NOT NULL COMMENT '重发请求摘要',
  `actor_user_id` bigint NULL COMMENT '人工操作人；自动为空',
  `provider_idempotency_key` varchar(100) NOT NULL COMMENT '同一投递固定提供商幂等键',
  `started_at` datetime(3) NOT NULL COMMENT '尝试开始',
  `finished_at` datetime(3) NULL COMMENT '结果落库时间',
  `attempt_state` varchar(20) NOT NULL COMMENT 'INVOKING或SUCCEEDED或FAILED或UNKNOWN',
  `provider_ref` varchar(200) NULL COMMENT '外部回执',
  `response_code` varchar(64) NULL COMMENT '脱敏错误码',
  `response_summary` varchar(500) NULL COMMENT '白名单摘要，禁止回显秘密',
  `evidence_ref` json NULL COMMENT '查单或回调证明',
  `lease_token` varchar(64) NOT NULL COMMENT '尝试与任务租约一致',
  PRIMARY KEY (`attempt_id`),
  UNIQUE KEY `uk_m09_attempt_no` (`delivery_id`,`attempt_no`),
  UNIQUE KEY `uk_m09_attempt_request` (`request_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='通知尝试及人工重发证据';

CREATE TABLE `alarm_runtime` (
  `runtime_id` bigint NOT NULL COMMENT '主键',
  `condition_key` varchar(64) NOT NULL COMMENT '规则、实体、指标、方向、任务或结果版本语义摘要',
  `latest_source_sequence` bigint NOT NULL COMMENT '已应用最大源序列',
  `episode_no` bigint NOT NULL COMMENT '累计异常周期数；恢复先到可为0',
  `active_alarm_id` bigint NULL COMMENT '本周期告警ID；恢复先到可空',
  `condition_state` varchar(20) NOT NULL COMMENT 'NORMAL或ACTIVE或RESOLVED',
  `first_trigger_at` datetime(3) NULL COMMENT '本周期开始',
  `last_observed_at` datetime(3) NOT NULL COMMENT '最后可信观测时间',
  `resolved_at` datetime(3) NULL COMMENT '恢复时间',
  `rounds_created` int NOT NULL COMMENT '本周期已生成通知轮次',
  `next_round_at` datetime(3) NULL COMMENT '下一轮到期',
  `notify_eligibility` varchar(30) NOT NULL COMMENT 'ELIGIBLE或RECORD_ONLY或STOPPED',
  `rule_revision_id` bigint NULL COMMENT '本周期固定规则修订',
  `row_version` bigint NOT NULL COMMENT '并发版本',
  `updated_at` datetime(3) NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`runtime_id`),
  UNIQUE KEY `uk_m09_runtime_condition` (`condition_key`),
  KEY `ix_m09_runtime_due` (`notify_eligibility`,`next_round_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='持续条件与重复通知游标';
