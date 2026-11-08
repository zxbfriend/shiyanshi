-- M02收尾设计，2026-09-10。未执行SQL；MySQL8.0.16+；无物理外键。
-- 先完成旧基线包再执行本次增量；与最终空库目标二选一。必须指定核准数据库并停写/备份；DDL隐式提交，禁止忽略错误继续。
-- 列数只是附加门禁，先逐列/索引比对前核验输出。重复/部分执行必须停止并逐句核对，不重跑全稿。
DELIMITER $$
CREATE PROCEDURE close_m02_check()
BEGIN
IF DATABASE() IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Explicit approved database required'; END IF;
IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='lab_bench_reactor_controller') <> 20 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M02 baseline mismatch: lab_bench_reactor_controller'; END IF;
IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='lab_engineering_profile') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New table already exists: lab_engineering_profile'; END IF;
IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='lab_engineering_profile_version') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New table already exists: lab_engineering_profile_version'; END IF;
END$$
DELIMITER ;
CALL close_m02_check();
DROP PROCEDURE close_m02_check;

ALTER TABLE `lab_bench_reactor_controller`
 ADD COLUMN `model_dict_code` bigint NULL DEFAULT NULL COMMENT '核准控制器型号dict_code；NULL旧未知，无默认型号';

CREATE TABLE `lab_engineering_profile` (
  `profile_id` bigint NOT NULL COMMENT '主键，应用生成',
  `scope_key` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'MODEL或INSTANCE及稳定身份规范摘要',
  `scope_kind` varchar(16) NOT NULL COMMENT 'MODEL或INSTANCE',
  `model_kind` varchar(40) NULL COMMENT 'M04 ModelRef类别，MODEL必填',
  `model_id` bigint NULL COMMENT '真实型号ID或控制器字典dict_code',
  `device_kind` varchar(40) NULL COMMENT 'M02 DeviceRef类型，INSTANCE必填',
  `device_id` bigint NULL COMMENT '实例稳定ID',
  `current_version_id` bigint NULL COMMENT '现行工程版本，未核准可空',
  `status` varchar(16) NOT NULL COMMENT 'DRAFT或VERIFIED或REVOKED',
  `object_version` bigint NOT NULL COMMENT '并发版本，从1开始',
  `updated_by_user_id` bigint NOT NULL COMMENT '实际技术维护人',
  `updated_at` datetime(3) NOT NULL COMMENT 'UTC修改时间',
  PRIMARY KEY (`profile_id`),
  UNIQUE KEY `uk_close_engineering_scope` (`scope_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='工程能力配置身份';

CREATE TABLE `lab_engineering_profile_version` (
  `version_id` bigint NOT NULL COMMENT '主键，应用生成',
  `profile_id` bigint NOT NULL COMMENT '所属工程身份',
  `version_no` bigint NOT NULL COMMENT '同身份版本从1递增',
  `previous_version_id` bigint NULL COMMENT '前版，首版空',
  `schema_version` int NOT NULL COMMENT '工程模式1',
  `profile_json` json NOT NULL COMMENT '闭合EngineeringProfile完整对象',
  `canonical_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '规范化内容SHA256',
  `evidence_json` json NOT NULL COMMENT '供应商资料、核准范围及文件摘要',
  `recorded_by_user_id` bigint NOT NULL COMMENT '记录人',
  `recorded_at` datetime(3) NOT NULL COMMENT '记录UTC时间',
  `verified_by_user_id` bigint NULL COMMENT '核准执行人；未核准空',
  `verified_at` datetime(3) NULL COMMENT '核准UTC时间',
  `request_key` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '操作者、动作、requestId摘要',
  `request_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '请求摘要',
  PRIMARY KEY (`version_id`),
  UNIQUE KEY `uk_close_engineering_version` (`profile_id`,`version_no`),
  UNIQUE KEY `uk_close_engineering_request` (`request_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='不可变工程参数与核准版本';
