-- M03收尾设计，2026-09-10。未执行SQL；MySQL8.0.16+；无物理外键。
-- 先完成旧基线包再执行本次增量；与最终空库目标二选一。必须指定核准数据库并停写/备份；DDL隐式提交，禁止忽略错误继续。
-- 列数只是附加门禁，先逐列/索引比对前核验输出。重复/部分执行必须停止并逐句核对，不重跑全稿。
DELIMITER $$
CREATE PROCEDURE close_m03_check()
BEGIN
IF DATABASE() IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Explicit approved database required'; END IF;
IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='res_culture') <> 49 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M03 baseline mismatch: res_culture'; END IF;
IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='res_culture_occupancy') <> 13 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M03 baseline mismatch: res_culture_occupancy'; END IF;
IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='res_culture_parameter_application') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New table already exists: res_culture_parameter_application'; END IF;
IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='res_culture_parameter_snapshot') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New table already exists: res_culture_parameter_snapshot'; END IF;
IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='res_culture_parameter_state') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New table already exists: res_culture_parameter_state'; END IF;
IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='res_culture_workflow_reference') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New table already exists: res_culture_workflow_reference'; END IF;
IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='res_culture_runtime_event') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New table already exists: res_culture_runtime_event'; END IF;
END$$
DELIMITER ;
CALL close_m03_check();
DROP PROCEDURE close_m03_check;

ALTER TABLE `res_culture`
 ADD COLUMN `runtime_stream_id` varchar(128) NULL DEFAULT NULL COMMENT '当前M07稳定事实流，重启不换ID',
 ADD COLUMN `runtime_stream_sequence` bigint NULL DEFAULT NULL COMMENT '已生效源序列；未建立为NULL',
 ADD COLUMN `delay_resolution_json` json NULL DEFAULT NULL COMMENT '开始及结束延期当前消解证据，不覆盖历史首次时间';

ALTER TABLE `res_culture_occupancy`
 ADD COLUMN `resource_release_snapshot` json NULL DEFAULT NULL COMMENT 'M07全部附属资源释放证据快照',
 ADD COLUMN `release_source_event_id` bigint NULL DEFAULT NULL COMMENT '已应用M03运行收件事件ID';

CREATE TABLE `res_culture_parameter_application` (
  `application_id` bigint NOT NULL COMMENT '主键',
  `snapshot_id` bigint NOT NULL COMMENT '不可变候选快照',
  `culture_id` bigint NOT NULL COMMENT '培养ID',
  `decision_key` varchar(128) NOT NULL COMMENT '唯一M06决定键或DIRECT请求键',
  `decision_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '完整决定摘要',
  `approval_id` bigint NULL COMMENT 'M06单据；DIRECT为空',
  `policy_evidence` json NOT NULL COMMENT '精确审批或免审批政策证据',
  `outcome` varchar(20) NOT NULL COMMENT 'APPLIED/DISCARDED/CONFLICT',
  `previous_snapshot_id` bigint NULL COMMENT '实际旧现行指针',
  `effective_snapshot_id` bigint NULL COMMENT '实际新现行指针，未应用仍为旧值',
  `parameter_generation` bigint NOT NULL COMMENT '处理后的参数代次',
  `result_json` json NOT NULL COMMENT '不可覆盖的回执与依赖结果',
  `handled_at` datetime(3) NOT NULL COMMENT '处理UTC时间',
  `actor_user_id` bigint NULL COMMENT '真实人工或系统空',
  PRIMARY KEY (`application_id`),
  UNIQUE KEY `uk_close_parameter_decision` (`decision_key`),
  KEY `ix_close_parameter_application` (`snapshot_id`,`handled_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='培养参数决定应用历史';

CREATE TABLE `res_culture_parameter_snapshot` (
  `snapshot_id` bigint NOT NULL COMMENT '主键，应用生成',
  `culture_id` bigint NOT NULL COMMENT 'M03培养稳定ID',
  `workflow_node_id` bigint NOT NULL COMMENT '一级流程稳定ID',
  `template_kind` varchar(16) NOT NULL COMMENT 'CONFIG/PERFUSION/SAMPLING/AUTO_CONTROL/FEEDING/PUMP_SPEED',
  `package_schema_version` int NOT NULL COMMENT 'TemplatePackage模式1历史或2新包',
  `template_package` json NOT NULL COMMENT '完整固定参数包，含工程快照',
  `package_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '固定包SHA256',
  `previous_snapshot_id` bigint NULL COMMENT '上一次同培养槽位快照',
  `base_effective_snapshot_id` bigint NULL COMMENT '捕获时现行快照',
  `base_config_snapshot_id` bigint NULL COMMENT '灌注生效所依赖Config快照',
  `culture_object_version` bigint NOT NULL COMMENT '捕获时培养对象版本',
  `schedule_plan_version` bigint NOT NULL COMMENT '捕获时日期计划版本，非参数代次',
  `device_kind` varchar(40) NOT NULL COMMENT '捕获时M02设备类型',
  `device_id` bigint NOT NULL COMMENT '捕获时设备稳定ID',
  `saved_by_user_id` bigint NOT NULL COMMENT '真实提交人',
  `saved_at` datetime(3) NOT NULL COMMENT '捕获UTC时间',
  `request_key` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '用户、源动作与请求ID摘要',
  `request_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '请求规范摘要',
  `request_id` varchar(64) NOT NULL COMMENT '源请求标识',
  `reason` varchar(500) NULL COMMENT '业务提交原因',
  PRIMARY KEY (`snapshot_id`),
  UNIQUE KEY `uk_close_snapshot_request` (`request_key`),
  KEY `ix_close_snapshot_culture` (`culture_id`,`workflow_node_id`,`saved_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='培养不可变方案参数包';

CREATE TABLE `res_culture_parameter_state` (
  `state_id` bigint NOT NULL COMMENT '主键',
  `culture_id` bigint NOT NULL COMMENT '培养ID',
  `workflow_node_id` bigint NOT NULL COMMENT '一级流程稳定ID',
  `template_kind` varchar(16) NOT NULL COMMENT '参数种类',
  `effective_snapshot_id` bigint NULL COMMENT '已合法生效快照',
  `candidate_snapshot_id` bigint NULL COMMENT '活动候选快照',
  `parameter_generation` bigint NOT NULL COMMENT '独立参数代次，从0开始',
  `approval_id` bigint NULL COMMENT 'M06审批单，明确DIRECT可空',
  `apply_state` varchar(20) NOT NULL COMMENT 'NONE/PENDING/APPLIED/DISCARDED/CONFLICT',
  `decision_key` varchar(128) NULL COMMENT 'M06 approvalId及decisionVersion或DIRECT回执键',
  `application_receipt` json NULL COMMENT '精确候选、决定与结果证据',
  `object_version` bigint NOT NULL COMMENT '指针/状态并发版本，从1开始',
  `updated_at` datetime(3) NOT NULL COMMENT '更新时间UTC',
  PRIMARY KEY (`state_id`),
  UNIQUE KEY `uk_close_parameter_slot` (`culture_id`,`workflow_node_id`,`template_kind`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='培养参数现行候选指针';

CREATE TABLE `res_culture_workflow_reference` (
  `reference_id` bigint NOT NULL COMMENT '主键',
  `culture_id` bigint NOT NULL COMMENT '培养ID，逻辑删除仍保留',
  `lab_id` bigint NOT NULL COMMENT '发生时实验室',
  `workflow_node_id` bigint NOT NULL COMMENT '一级流程稳定身份',
  `snapshot_id` bigint NULL COMMENT '参数快照；仅流程选择引用可空',
  `source_kind` varchar(20) NOT NULL COMMENT 'SNAPSHOT/WORKFLOW_SELECTION/LEGACY_VERIFIED',
  `source_key` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '来源稳定键摘要',
  `created_at` datetime(3) NOT NULL COMMENT '真实建立时间',
  `evidence_ref` json NOT NULL COMMENT '来源版本及核准证据',
  PRIMARY KEY (`reference_id`),
  UNIQUE KEY `uk_close_workflow_ref_source` (`source_key`),
  KEY `ix_close_workflow_ref_node` (`lab_id`,`workflow_node_id`,`culture_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='培养流程全历史引用';

CREATE TABLE `res_culture_runtime_event` (
  `event_id` bigint NOT NULL COMMENT '主键',
  `culture_id` bigint NOT NULL COMMENT '培养ID',
  `source_module` varchar(16) NOT NULL COMMENT 'M07或M03_SCHEDULER或SIMULATOR',
  `source_event_id` varchar(128) NOT NULL COMMENT '来源不可变事件身份',
  `source_event_key` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '来源模块及事件ID摘要',
  `stream_id` varchar(128) NOT NULL COMMENT '稳定运行事实流身份，重启不改变',
  `stream_sequence` bigint NOT NULL COMMENT '同流单调序列',
  `previous_event_key` char(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '前序源键；首事件空',
  `event_type` varchar(40) NOT NULL COMMENT 'FIRST_WORKFLOW_STARTED/START_COMPLETED/TERMINAL_CONFIRMED/RESOURCES_RELEASED/DEADLINE_EVALUATED/DELAY_RESOLVED',
  `source_object_version` bigint NOT NULL COMMENT '来源事实版本',
  `expected_culture_version` bigint NOT NULL COMMENT '预期培养版本',
  `expected_plan_version` bigint NOT NULL COMMENT '预期日期计划版本',
  `occupancy_id` bigint NULL COMMENT '目标主设备占用实例',
  `occurred_at` datetime(3) NOT NULL COMMENT '发生UTC时间',
  `received_at` datetime(3) NOT NULL COMMENT '接收UTC时间',
  `payload_json` json NOT NULL COMMENT '完整RuntimeFact模式1',
  `payload_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '源事实SHA256',
  `apply_state` varchar(20) NOT NULL COMMENT 'RECEIVED/APPLIED/IGNORED/BLOCKED',
  `result_json` json NULL COMMENT '前后版本、状态、占用和原因',
  `applied_at` datetime(3) NULL COMMENT '应用UTC时间',
  `object_version` bigint NOT NULL COMMENT '收件投影版本',
  `lease_token` varchar(64) NULL COMMENT '收件工作器栅栏token',
  `lease_until` datetime(3) NULL COMMENT '租约截止UTC',
  PRIMARY KEY (`event_id`),
  UNIQUE KEY `uk_close_runtime_source` (`source_event_key`),
  UNIQUE KEY `uk_close_runtime_sequence` (`culture_id`,`stream_id`,`stream_sequence`),
  KEY `ix_close_runtime_work` (`apply_state`,`lease_until`,`event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='培养运行事实收件与生效回执';
