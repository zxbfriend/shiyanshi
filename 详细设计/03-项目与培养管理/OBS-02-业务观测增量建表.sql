-- DD-20260917-OBS：MySQL 8.0.16+ 目标增量设计稿，未执行。
-- 先执行本包迁移前核验并人工核准；无 IF NOT EXISTS，遇已有同名表停止。
-- DDL 隐式提交；不得将 ROLLBACK 视为建表回退；无物理跨模块外键。

CREATE TABLE `res_observation_binding_revision` (
  `revision_id` BIGINT NOT NULL COMMENT '修订ID',
  `device_kind` VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '测量设备种类',
  `device_id` BIGINT NOT NULL COMMENT '测量设备ID',
  `channel_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '核准物理通道或DEVICE',
  `revision_no` BIGINT NOT NULL COMMENT '同流递增版本',
  `request_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '幂等请求，首次版本也受唯一键保护',
  `request_hash` BINARY(32) NOT NULL COMMENT '完整请求hash',
  `evidence_ref` VARCHAR(500) NOT NULL COMMENT '绑定/占用/迁移核准依据',
  `approved_by` BIGINT NULL COMMENT '自动领域事务为空，人工核准必填',
  `created_at` DATETIME(6) NOT NULL COMMENT '提交时刻',
  `reason` VARCHAR(500) NOT NULL COMMENT '绑定变更或纠正理由',
  PRIMARY KEY (`revision_id`),
  UNIQUE KEY `uk_binding_version` (`device_kind`,`device_id`,`channel_code`,`revision_no`),
  UNIQUE KEY `uk_binding_request` (`request_id`),
  CHECK (`revision_no` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='设备测量通道的完整历史关系修订';

CREATE TABLE `res_observation_binding_interval` (
  `interval_id` BIGINT NOT NULL COMMENT '区间ID',
  `revision_id` BIGINT NOT NULL COMMENT '完整修订头',
  `valid_from` DATETIME(6) NOT NULL COMMENT '包含起点',
  `valid_to` DATETIME(6) NULL COMMENT '不含终点，开放末段可空',
  `state` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'MATCHED或UNASSOCIATED',
  `culture_id` BIGINT NULL COMMENT '空闲时空',
  `project_id` BIGINT NULL COMMENT '发生时项目',
  `batch_id` BIGINT NULL COMMENT '发生时批次',
  `lab_id` BIGINT NOT NULL COMMENT '发生时实验室',
  `occupancy_id` BIGINT NULL COMMENT '主占用证据，不代替测点映射',
  `configuration_revision` VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '核准通道/绑定配置版本',
  `evidence_ref` VARCHAR(500) NOT NULL COMMENT '具体绑定或空闲证明',
  PRIMARY KEY (`interval_id`),
  UNIQUE KEY `uk_binding_start` (`revision_id`,`valid_from`),
  KEY `ix_binding_culture` (`culture_id`,`valid_from`,`valid_to`),
  CHECK (`valid_to` IS NULL OR `valid_to` > `valid_from`),
  CHECK ((`state` = 'MATCHED' AND `culture_id` IS NOT NULL AND `project_id` IS NOT NULL AND `batch_id` IS NOT NULL AND `occupancy_id` IS NOT NULL) OR (`state` = 'UNASSOCIATED' AND `culture_id` IS NULL AND `project_id` IS NULL AND `batch_id` IS NULL AND `occupancy_id` IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='修订内不可变半开历史区间，显式空闲亦有证据';

