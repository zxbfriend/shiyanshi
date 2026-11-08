-- DD-20260917-OBS：MySQL 8.0.16+ 目标增量设计稿，未执行。
-- 先执行本包迁移前核验并人工核准；无 IF NOT EXISTS，遇已有同名表停止。
-- DDL 隐式提交；不得将 ROLLBACK 视为建表回退；无物理跨模块外键。

CREATE TABLE `lab_observation_mapping` (
  `mapping_id` BIGINT NOT NULL COMMENT '映射版本ID',
  `device_kind` VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '设备种类',
  `device_id` BIGINT NOT NULL COMMENT '设备ID',
  `channel_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '核准通道；设备级用固定DEVICE',
  `raw_metric_code` VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '原指标码',
  `mapping_version` BIGINT NOT NULL COMMENT '同设备通道指标递增版本',
  `item_id` BIGINT NOT NULL COMMENT 'dev_detector_item稳定ID',
  `raw_unit` VARCHAR(30) NOT NULL COMMENT '原单位，不得默认g',
  `unit` VARCHAR(30) NOT NULL COMMENT '核准目标单位',
  `profile` JSON NOT NULL COMMENT '固定MappingProfile v1',
  `effective_from` DATETIME(6) NOT NULL COMMENT '生效起点UTC',
  `effective_to` DATETIME(6) NULL COMMENT '半开区间终点；仅受控关闭',
  `approved_by` BIGINT NOT NULL COMMENT '核准操作者',
  `approved_at` DATETIME(6) NOT NULL COMMENT '核准时刻',
  `request_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '幂等管理请求',
  `request_hash` BINARY(32) NOT NULL COMMENT '规范请求SHA256',
  PRIMARY KEY (`mapping_id`),
  UNIQUE KEY `uk_obs_mapping_version` (`device_kind`,`device_id`,`channel_code`,`raw_metric_code`,`mapping_version`),
  UNIQUE KEY `uk_obs_mapping_request` (`request_id`),
  CHECK (`mapping_version` > 0 AND (`effective_to` IS NULL OR `effective_to` > `effective_from`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='核准在线指标映射版本，不复制指标主数据';

CREATE TABLE `lab_observation_receipt` (
  `receipt_id` BIGINT NOT NULL COMMENT '收件ID',
  `event_key` BINARY(32) NOT NULL COMMENT '规范稳定身份SHA256',
  `identity_json` JSON NOT NULL COMMENT 'Identity v1，碰撞时逐字段比对',
  `packet_hash` BINARY(32) NOT NULL COMMENT '原始内容哈希',
  `raw_payload_ref` VARCHAR(500) NOT NULL COMMENT '受保护持久证据引用，不是任意URL',
  `envelope` JSON NOT NULL COMMENT 'Envelope v1固定叶子，不存凭据',
  `device_kind` VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '经凭据核实的设备种类',
  `device_id` BIGINT NOT NULL COMMENT '经核实设备ID',
  `lab_id` BIGINT NOT NULL COMMENT '接收身份所属实验室快照',
  `channel_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '接入通道',
  `received_at` DATETIME(6) NOT NULL COMMENT '首接收服务端时刻',
  `state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'QUARANTINED或ARCHIVED；不是告警ACK',
  `reason_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '隔离原因',
  `process_version` BIGINT NOT NULL COMMENT '处理投影CAS版本',
  `next_retry_at` DATETIME(6) NULL COMMENT '补偿计划',
  `lease_token` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '工作进程租约token',
  `lease_until` DATETIME(6) NULL COMMENT '租约UTC',
  `created_at` DATETIME(6) NOT NULL COMMENT '创建时刻',
  PRIMARY KEY (`receipt_id`),
  UNIQUE KEY `uk_obs_receipt_event` (`event_key`),
  KEY `ix_obs_receipt_retry` (`state`,`next_retry_at`,`receipt_id`),
  CHECK (`state` IN ('QUARANTINED','ARCHIVED') AND `process_version` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='原始业务收件证据及处理进度';

CREATE TABLE `lab_observation_conflict` (
  `conflict_id` BIGINT NOT NULL COMMENT '冲突ID',
  `receipt_id` BIGINT NOT NULL COMMENT '原始收件',
  `packet_hash` BINARY(32) NOT NULL COMMENT '冲突内容hash',
  `raw_payload_ref` VARCHAR(500) NOT NULL COMMENT '冲突原包受保护引用',
  `identity_json` JSON NOT NULL COMMENT '用于排除hash碰撞',
  `received_at` DATETIME(6) NOT NULL COMMENT '冲突接收时刻',
  `reason_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'EVENT_CONTENT_CONFLICT或IDENTITY_HASH_COLLISION',
  PRIMARY KEY (`conflict_id`),
  UNIQUE KEY `uk_obs_conflict` (`receipt_id`,`packet_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='同身份不同内容证据，不能覆盖首次事实';

CREATE TABLE `lab_observation` (
  `observation_id` BIGINT NOT NULL COMMENT '观测版本ID',
  `receipt_id` BIGINT NOT NULL COMMENT '原包收件',
  `process_version` BIGINT NOT NULL COMMENT '与重处理版本对应',
  `mapping_id` BIGINT NULL COMMENT '隔离时可空',
  `item_id` BIGINT NULL COMMENT '未核准指标可空',
  `raw_value` VARCHAR(256) NULL COMMENT '原十进制字符串原精度',
  `raw_unit` VARCHAR(30) NULL COMMENT '原单位',
  `value` DECIMAL(38,12) NULL COMMENT '规范值；超范围不截断',
  `unit` VARCHAR(30) NULL COMMENT '规范单位',
  `observed_at` DATETIME(6) NULL COMMENT '可信UTC；不可信保持空',
  `quality` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '来源质量',
  `validation_state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'VALID或QUARANTINED',
  `reason_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '处理原因',
  `evidence` JSON NOT NULL COMMENT 'ProcessingEvidence v1',
  `processed_at` DATETIME(6) NOT NULL COMMENT '处理时刻',
  `processed_by` BIGINT NULL COMMENT '自动空，人工重处理用户ID',
  PRIMARY KEY (`observation_id`),
  UNIQUE KEY `uk_obs_process` (`receipt_id`,`process_version`),
  KEY `ix_obs_item_time` (`item_id`,`observed_at`,`observation_id`),
  CHECK (`quality` IN ('GOOD','STALE','BAD','UNKNOWN')),
  CHECK (`validation_state` IN ('VALID','QUARANTINED')),
  CHECK (`validation_state` <> 'VALID' OR (`mapping_id` IS NOT NULL AND `item_id` IS NOT NULL AND `observed_at` IS NOT NULL AND `unit` IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='不可变规范业务观测及重处理版本';

CREATE TABLE `lab_observation_association` (
  `association_id` BIGINT NOT NULL COMMENT '关联证据ID',
  `observation_id` BIGINT NOT NULL COMMENT '观测版本',
  `association_version` BIGINT NOT NULL COMMENT '同观测递增',
  `state` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'MATCHED/UNASSOCIATED/AMBIGUOUS/UNKNOWN',
  `binding_revision_id` BIGINT NULL COMMENT 'M03完整关系修订',
  `binding_interval_id` BIGINT NULL COMMENT 'M03匹配区间',
  `culture_id` BIGINT NULL COMMENT '可信培养',
  `project_id` BIGINT NULL COMMENT '可信项目',
  `batch_id` BIGINT NULL COMMENT '可信批次',
  `lab_id` BIGINT NULL COMMENT '发生时实验室',
  `evidence` JSON NOT NULL COMMENT 'AssociationEvidence v1',
  `resolved_at` DATETIME(6) NOT NULL COMMENT '解析时刻',
  PRIMARY KEY (`association_id`),
  UNIQUE KEY `uk_obs_association` (`observation_id`,`association_version`),
  KEY `ix_obs_culture` (`culture_id`,`observation_id`,`association_version`),
  CHECK (`state` IN ('MATCHED','UNASSOCIATED','AMBIGUOUS','UNKNOWN')),
  CHECK (`state` <> 'MATCHED' OR (`binding_revision_id` IS NOT NULL AND `binding_interval_id` IS NOT NULL AND `culture_id` IS NOT NULL AND `project_id` IS NOT NULL AND `batch_id` IS NOT NULL AND `lab_id` IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M03历史解析结果的版本证据，不是关系权威';

CREATE TABLE `lab_observation_current` (
  `device_kind` VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '设备种类',
  `device_id` BIGINT NOT NULL COMMENT '设备ID',
  `channel_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '通道',
  `item_id` BIGINT NOT NULL COMMENT '指标',
  `current_observation_id` BIGINT NOT NULL COMMENT '最新合法时刻观测，允许BAD',
  `last_good_observation_id` BIGINT NULL COMMENT '最后GOOD，仅供明确标旧值',
  `observed_at` DATETIME(6) NOT NULL COMMENT '当前值排序时刻',
  `event_key` BINARY(32) NOT NULL COMMENT '同刻确定排序',
  `state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'NORMAL或CONFLICT',
  `row_version` BIGINT NOT NULL COMMENT '并发CAS',
  `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`device_kind`,`device_id`,`channel_code`,`item_id`),
  CHECK (`state` IN ('NORMAL','CONFLICT') AND `row_version` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='可重建业务当前值指针，绝非唯一历史';

CREATE TABLE `lab_observation_outbox` (
  `event_id` BIGINT NOT NULL COMMENT '事件ID',
  `source_key` VARCHAR(160) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '稳定来源事件幂等键',
  `event_type` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'OBSERVATION_ARCHIVED/ASSOCIATION_REVISED/REPROCESS等',
  `receipt_id` BIGINT NULL COMMENT '收件来源',
  `observation_id` BIGINT NULL COMMENT '观测来源',
  `payload` JSON NOT NULL COMMENT '按事件类型闭合模式',
  `payload_hash` BINARY(32) NOT NULL COMMENT '完整不可变payload哈希',
  `created_at` DATETIME(6) NOT NULL COMMENT '事件时刻',
  `publish_state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'LOCAL/PENDING/RETRY/PUBLISHED',
  `attempts` INT UNSIGNED NOT NULL COMMENT '投递次数初始0',
  `next_publish_at` DATETIME(6) NULL COMMENT '下次重试',
  `published_at` DATETIME(6) NULL COMMENT '代理持久确认时间',
  `lease_token` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '领取token',
  `lease_until` DATETIME(6) NULL COMMENT '租约到期',
  `last_error` VARCHAR(1000) NULL COMMENT '脱敏错误',
  PRIMARY KEY (`event_id`),
  UNIQUE KEY `uk_obs_outbox_source` (`source_key`),
  KEY `ix_obs_outbox_retry` (`publish_state`,`next_publish_at`,`event_id`),
  CHECK (`publish_state` IN ('LOCAL','PENDING','RETRY','PUBLISHED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='业务可靠事实及补偿审计，独立于M08消费者';

CREATE TABLE `lab_observation_monitor` (
  `condition_key` BINARY(32) NOT NULL COMMENT '稳定告警condition SHA256',
  `identity_json` JSON NOT NULL COMMENT 'MonitorIdentity v1核对碰撞',
  `sequence` BIGINT NOT NULL COMMENT '持久单调事件序列，初始0',
  `evaluation_version` BIGINT NOT NULL COMMENT '每轮评价CAS版本',
  `last_input_key` VARCHAR(160) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '已处理样本或缺测时间槽身份',
  `last_evaluated_at` DATETIME(6) NULL COMMENT '评价水位，旧样本不得倒退',
  `condition_state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'UNKNOWN/NORMAL/ACTIVE',
  `evidence` JSON NOT NULL COMMENT 'MonitorEvidence v1含连续次数及profile',
  `row_version` BIGINT NOT NULL COMMENT '并发CAS',
  `updated_at` DATETIME(6) NOT NULL COMMENT '更新时刻',
  PRIMARY KEY (`condition_key`),
  CHECK (`sequence` >= 0 AND `evaluation_version` >= 0 AND `row_version` > 0),
  CHECK (`condition_state` IN ('UNKNOWN','NORMAL','ACTIVE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='非运行在线判定状态；与告警outbox原子提交';

