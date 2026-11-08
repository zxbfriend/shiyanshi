-- SC-20261017 design source only, installed through 开发基线/01-完整建表.sql.
CREATE TABLE `alarm_start_culture_collection` (
  `culture_id` BIGINT NOT NULL COMMENT '培养配置集合标记；零项也保留',
  `device_kind` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '真实设备类别',
  `device_id` BIGINT NOT NULL COMMENT '真实设备稳定身份',
  `lab_id` BIGINT NOT NULL COMMENT '真实实验室',
  `workflow_id` BIGINT NOT NULL COMMENT '首次提交开始培养工作流',
  `source_scope` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'CULTURE/DEVICE/NONE',
  `source_revision` VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '继承源版本',
  `source_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '继承源SHA256',
  `content_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '最终配置SHA256',
  `created_at` DATETIME(3) NOT NULL COMMENT 'UTC生效时间',
  `actor_user_id` BIGINT NOT NULL COMMENT '操作者',
  PRIMARY KEY (`culture_id`),
  UNIQUE KEY `uk_m09_sc_workflow` (`workflow_id`),
  CONSTRAINT `ck_m09_sc_source` CHECK (source_scope IN ('CULTURE','DEVICE','NONE')),
  CONSTRAINT `ck_m09_sc_hash` CHECK (source_hash REGEXP '^[0-9a-f]{64}$' AND content_hash REGEXP '^[0-9a-f]{64}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='首次培养在线配置集合；区分已有空集合与不存在';
