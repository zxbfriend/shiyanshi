-- 2026-09-11 COMMON 3表31列；静态设计未执行。仅隔离空库参考，不与旧包重复创建。
-- M06场景种子仍取原02中已核验47行，单独初始化；本文件不凭空核准政策/现场能力。
CREATE TABLE `audit_archive_manifest` (
  `manifest_id` BIGINT NOT NULL COMMENT '归档批次',
  `owner_module` VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'COPYING' COMMENT 'COPYING/VERIFIED/ACTIVE/FAILED',
  `schema_version` INT NOT NULL,
  `object_uri` VARCHAR(500) NOT NULL,
  `object_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '加密归档包摘要',
  `key_version` VARCHAR(64) NOT NULL,
  `row_count` BIGINT UNSIGNED NOT NULL,
  `byte_count` BIGINT UNSIGNED NOT NULL,
  `scope_snapshot` JSON NOT NULL COMMENT '归档范围及在线门禁证据',
  `restore_proof` JSON NULL COMMENT '恢复验证',
  `created_by` BIGINT NOT NULL COMMENT '受控归档维护身份',
  `created_at` DATETIME(3) NOT NULL COMMENT '归档；UTC',
  `activated_at` DATETIME(3) NULL COMMENT '切换；UTC',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'CAS版本',
  PRIMARY KEY (`manifest_id`),
  CONSTRAINT `ck_archive_manifest` CHECK (state IN ('COPYING','VERIFIED','ACTIVE','FAILED') AND row_count>0 AND schema_version>0 AND (state<>'ACTIVE' OR (restore_proof IS NOT NULL AND activated_at IS NOT NULL)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='audit_archive_manifest 当前设计目标';

CREATE TABLE `audit_archive_record` (
  `record_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '模块表与原主键摘要',
  `manifest_id` BIGINT NOT NULL COMMENT '归档批次',
  `owner_module` VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `table_name` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `original_key` VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `object_version` BIGINT UNSIGNED NOT NULL,
  `object_offset` VARCHAR(128) NOT NULL,
  `content_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '原行规范摘要',
  `authorization_scope` JSON NOT NULL COMMENT '真实归属与用途定位',
  `occurred_at` DATETIME(3) NOT NULL COMMENT '业务时间；UTC',
  `archived_at` DATETIME(3) NOT NULL COMMENT '归档时间；UTC',
  PRIMARY KEY (`record_key`),
  UNIQUE KEY `uk_archive_original` (`owner_module`,`table_name`,`original_key`),
  KEY `ix_archive_query` (`owner_module`,`table_name`,`occurred_at`,`record_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='audit_archive_record 当前设计目标';

CREATE TABLE `audit_archive_key` (
  `key_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '唯一键命名空间与规范值摘要',
  `key_namespace` VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `record_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '定位归档原记录',
  `canonical_key` VARBINARY(768) NOT NULL,
  `created_at` DATETIME(3) NOT NULL COMMENT '形成时间；UTC',
  PRIMARY KEY (`key_hash`),
  KEY `ix_archive_key_record` (`record_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='audit_archive_key 当前设计目标';
