-- FutureFab 定向结构修复（开发/联调库专用，不属于正式安装链）
-- 生成时间：2026-10-18；生成方式：与 docs/开发基线/01-完整建表.sql 逐表逐列程序化比对，按基线原文抽取。
-- 适用范围：已确认的开发库（本任务 dev-api 实际库）。禁止用于生产或客户环境。
-- 本文件保留已执行操作的审查记录；不是幂等安装器，不得对现有库整包再次执行。
-- 约束：仅新增（CREATE TABLE / ADD COLUMN / ADD KEY / ADD CONSTRAINT），不 DROP、不改类型、不动既有数据；
--       缺失列全部来自基线定义且可空或有默认值；不重跑 01/02/03 三件套，不回填任何历史值。
--
-- ============ 执行记录（2026-10-18 实际执行，逐部分如实记录） ============
-- 事务模式如实说明：本文件并非一次单事务执行完毕。实际执行为：
--   第一部分（16 张缺失表）  ：执行器 autocommit=True，逐条独立提交；
--   第二部分（5 张既有表修复）：执行器 autocommit=True，逐条独立提交；
--   第三部分（开始培养种子）  ：执行器 autocommit=True，逐条独立提交；
--   第四部分（中试测试数据）  ：单事务（START TRANSACTION ... COMMIT，失败整体 ROLLBACK）；
--   第五部分（小试测试数据）  ：单事务（START TRANSACTION ... COMMIT，失败整体 ROLLBACK）。
--   因此文件内第四、五部分的 "单事务执行，失败整体回滚" 注释仅对这两部分成立；
--   前三部分为逐条自动提交（DDL 在 MySQL 中本身隐式提交，无法回滚）。
-- 逐项执行结果：
--   第一部分：16/16 条 CREATE TABLE 全部成功（含脚本内对基线两处 CHECK 少右括号笔误的最小更正，见第二部分末注释）。
--   第二部分：执行成功；但基线版 CONSTRAINT ck_m03_initial_weight 对 res_culture 应用被既有行 861016201
--           （initial_weight_g=1250 且 source_kind 为空）拒绝（错误 3819），按"不改既有行业务数据"纪律，
--           已原样恢复库中旧约束定义并完成加列/加键/加约束；基线版约束未应用，记 BLOCKED_DATA，
--           待数据属主对该行分类后另行应用（不得编造分类）。
--   第三部分：执行成功；因 uk_workflow_node_code（节点 3 已占 start_culture）未新建节点，
--           uk_workflow_subflow_order（旧行占 sort_order 1/2）新子流程取 sort_order 3/4。
--   第四部分：单事务 9/9 条 INSERT 全部成功并提交（ID 段 990000000000004501-508，remark=MOCK-SYNC-20261018）。
--           排坑记录：res_project.m03_live_code、res_culture_occupancy.active_slot 为 STORED GENERATED 列，
--           不能出现在 INSERT 列清单（错误 3105），已剔除（自动生成值与手工值一致，已核验）；
--           ck_m03_culture_duration 要求 planned_duration_days = DATEDIFF(end,start)+1（含首尾），10-18→10-19 为 2。
--   第五部分：单事务全部成功并提交（ID 段 990000000000004509-514，remark=MOCK-SYNC-20261018）。
-- 数据性质：第四、五部分为数据库持久化测试样本（remark 统一 MOCK-SYNC-20261018 可识别、可清理），
--           不是真实设备采集数据；原详情页 pH/温度/DO 等曾为前端常量/生成曲线，后续已在真实模式门控，不能作为真实采集证据。
SET NAMES utf8mb4;
SET time_zone = '+00:00';

-- ============ 第一部分：基线缺失的 16 张表（基线 CREATE TABLE 原文） ============

-- [缺失表] alarm_start_culture_collection
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

-- [缺失表] det_correction_evidence
CREATE TABLE `det_correction_evidence` (
  `attachment_id` bigint NOT NULL COMMENT 'M05应用生成不可变证据ID',
  `version_no` bigint NOT NULL COMMENT '精确不可变版本；首次为1，不覆盖',
  `result_id` bigint NOT NULL COMMENT '固定所属结果；不可跨结果借用',
  `uploaded_result_version` bigint NOT NULL COMMENT '上传时当前结果版本',
  `display_name` varchar(100) NOT NULL COMMENT '展示名，不含路径或控制字符',
  `content_type` varchar(128) NOT NULL COMMENT '服务端确定的下载媒体类型',
  `size_bytes` bigint NOT NULL COMMENT '原件真实字节数',
  `content_sha256` binary(32) NOT NULL COMMENT '服务端原始字节SHA256',
  `original_bytes` LONGBLOB NOT NULL COMMENT '普通更正证据原件；禁止更新删除和自动到期',
  `uploaded_by` bigint NOT NULL COMMENT '稳定上传人身份',
  `uploaded_at` datetime(6) NOT NULL COMMENT '服务端首次上传时刻UTC',
  `upload_request_id` char(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '长期领域上传幂等键',
  `upload_payload_hash` binary(32) NOT NULL COMMENT '规范上传意图摘要，不存原件到审计',
  `committed_management_revision` bigint NOT NULL COMMENT '首次上传成功管理版本，用于长期回放',
  PRIMARY KEY (`attachment_id`,`version_no`),
  UNIQUE KEY `uk_m05_evidence_upload` (`uploaded_by`,`upload_request_id`),
  KEY `ix_m05_evidence_result` (`result_id`,`uploaded_at`,`attachment_id`),
  CONSTRAINT `ck_m05_evidence_identity` CHECK (attachment_id>0 AND version_no>0 AND result_id>0 AND uploaded_result_version>0 AND uploaded_by>0 AND committed_management_revision>0),
  CONSTRAINT `ck_m05_evidence_bytes` CHECK (size_bytes>0 AND OCTET_LENGTH(original_bytes)=size_bytes),
  CONSTRAINT `ck_m05_evidence_name` CHECK (CHAR_LENGTH(TRIM(display_name)) BETWEEN 1 AND 100 AND CHAR_LENGTH(TRIM(content_type))>0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M05普通更正不可变原件及长期上传回执';

-- [缺失表] lab_communication_apply_receipt
CREATE TABLE `lab_communication_apply_receipt` (
  `evidence_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '设备修订适配器及规范化回报SHA256',
  `comm_id` BIGINT NOT NULL COMMENT '原通讯配置ID',
  `configuration_revision` BIGINT UNSIGNED NOT NULL COMMENT '回报对应修订',
  `adapter_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '服务端登记实例身份',
  `evidence_json` JSON NOT NULL COMMENT '无秘密加载证据，含原观测UTC时刻',
  `receipt_json` JSON NOT NULL COMMENT '不可变原受理结果',
  `received_at` DATETIME(3) NOT NULL COMMENT '服务端接收时间UTC',
  PRIMARY KEY (`evidence_hash`),
  INDEX `idx_m02_apply_configuration` (`comm_id`,`configuration_revision`),
  CONSTRAINT `ck_m02_apply_receipt_revision` CHECK (`comm_id`>0 AND `configuration_revision`>0),
  CONSTRAINT `ck_m02_apply_receipt_json` CHECK (JSON_TYPE(`evidence_json`)='OBJECT' AND JSON_TYPE(`receipt_json`)='OBJECT')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='通讯配置加载回报不可变回执';

-- [缺失表] lab_communication_usage
CREATE TABLE `lab_communication_usage` (
  `device_kind` VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '冻结通讯设备种类',
  `device_id` BIGINT NOT NULL COMMENT '真实设备实例ID',
  `lab_id` BIGINT NOT NULL COMMENT '真实实验室ID',
  `configuration_version` BIGINT NOT NULL COMMENT '核验时通讯配置版本',
  `owner_module` VARCHAR(3) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'M05或M07事实拥有方',
  `links_json` JSON NOT NULL COMMENT '拥有方核验的完整关联身份集合，不存自报结束状态',
  `adapter_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '独立授权设备适配器',
  `object_version` BIGINT NOT NULL COMMENT '关联登记CAS版本，从1递增',
  `verified_at` DATETIME(6) NOT NULL COMMENT '服务器核验时间UTC',
  PRIMARY KEY (`device_kind`,`device_id`,`lab_id`,`configuration_version`,`owner_module`),
  CONSTRAINT `ck_m02_comm_usage_kind` CHECK (device_kind IN ('DETECTOR','FLOOR_SCALE','DOWNSTREAM_DEVICE')),
  CONSTRAINT `ck_m02_comm_usage_owner` CHECK (owner_module IN ('M05','M07')),
  CONSTRAINT `ck_m02_comm_usage_ids` CHECK (device_id>0 AND lab_id>0 AND configuration_version>0 AND object_version>0),
  CONSTRAINT `ck_m02_comm_usage_links` CHECK (JSON_TYPE(links_json)='ARRAY' AND JSON_LENGTH(links_json)<=1000)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='按配置代次核验的通讯关联登记';

-- [缺失表] lab_device_operation_grant
CREATE TABLE `lab_device_operation_grant` (
  `grant_id` BIGINT NOT NULL COMMENT '逐设备运维授权主键，应用生成',
  `user_id` BIGINT NOT NULL COMMENT '被授权用户',
  `lab_id` BIGINT NOT NULL COMMENT '授权实验室',
  `resource_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '授权设备资源键',
  `permission_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '固定DEVICE_OPERATE',
  `state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'ACTIVE/REVOKED',
  `granted_by_user_id` BIGINT NOT NULL COMMENT '实际授权维护人',
  `granted_at` DATETIME(3) NOT NULL COMMENT 'UTC授权时间',
  `expires_at` DATETIME(3) NULL COMMENT 'UTC失效时间；空为未设失效',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'CAS版本',
  PRIMARY KEY (`grant_id`),
  UNIQUE KEY `uk_m02_device_operation_grant` (`user_id`,`lab_id`,`resource_key`,`permission_code`),
  KEY `idx_m02_device_operation_grant_lookup` (`lab_id`,`resource_key`,`state`,`expires_at`),
  CONSTRAINT `ck_m02_device_operation_grant_state` CHECK (`state` IN ('ACTIVE','REVOKED')),
  CONSTRAINT `ck_m02_device_operation_grant_code` CHECK (`permission_code`='DEVICE_OPERATE'),
  CONSTRAINT `ck_m02_device_operation_grant_values` CHECK (`user_id`>0 AND `lab_id`>0 AND `object_version`>0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M02逐设备运维授权事实';

-- [缺失表] lab_device_read_grant
CREATE TABLE `lab_device_read_grant` (
  `grant_id` BIGINT NOT NULL COMMENT '逐设备读取授权主键，应用生成',
  `user_id` BIGINT NOT NULL COMMENT '被授权用户',
  `lab_id` BIGINT NOT NULL COMMENT '授权实验室',
  `resource_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '授权设备资源键',
  `permission_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '固定DEVICE_READ',
  `state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'ACTIVE/REVOKED',
  `granted_by_user_id` BIGINT NOT NULL COMMENT '实际授权维护人',
  `granted_at` DATETIME(3) NOT NULL COMMENT 'UTC授权时间',
  `expires_at` DATETIME(3) NULL COMMENT 'UTC失效时间；空为未设失效',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'CAS版本',
  PRIMARY KEY (`grant_id`),
  UNIQUE KEY `uk_m02_device_read_grant` (`user_id`,`lab_id`,`resource_key`,`permission_code`),
  KEY `idx_m02_device_read_grant_lookup` (`lab_id`,`resource_key`,`state`,`expires_at`),
  CONSTRAINT `ck_m02_device_read_grant_state` CHECK (`state` IN ('ACTIVE','REVOKED')),
  CONSTRAINT `ck_m02_device_read_grant_code` CHECK (`permission_code`='DEVICE_READ'),
  CONSTRAINT `ck_m02_device_read_grant_values` CHECK (`user_id`>0 AND `lab_id`>0 AND `object_version`>0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M02逐设备读取授权事实；只用于原批次回执恢复读取';

-- [缺失表] lab_executor_control_verification
CREATE TABLE `lab_executor_control_verification` (
  `verification_id` BIGINT NOT NULL COMMENT '受信适配器核验主键，应用生成',
  `group_id` BIGINT NOT NULL COMMENT '核验资源组',
  `group_revision` BIGINT UNSIGNED NOT NULL COMMENT '核验对应资源组版本',
  `old_executor_id` VARCHAR(128) NOT NULL COMMENT '待隔离旧执行器',
  `new_executor_id` VARCHAR(128) NOT NULL COMMENT '待绑定新执行器',
  `adapter_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '受信设备适配器身份',
  `evidence_reference` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '外部核验证据稳定引用摘要',
  `evidence_payload` JSON NOT NULL COMMENT '无凭据隔离、停泵、对账、绑定核验证据',
  `old_executor_physically_isolated` TINYINT NOT NULL COMMENT '1仅当旧物理控制入口已失效',
  `commands_reconciled_and_stopped` TINYINT NOT NULL COMMENT '1仅当未决命令核对且设备已停',
  `new_executor_binding_verified` TINYINT NOT NULL COMMENT '1仅当新执行器绑定及旧epoch拒绝已核验',
  `state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'VERIFIED/REJECTED/UNKNOWN',
  `verified_at` DATETIME(3) NOT NULL COMMENT '适配器观测UTC时间',
  `expires_at` DATETIME(3) NOT NULL COMMENT '核验有效截止UTC',
  `received_at` DATETIME(3) NOT NULL COMMENT '服务端接收UTC时间',
  `payload_hash` BINARY(32) NOT NULL COMMENT '规范证据摘要SHA256',
  PRIMARY KEY (`verification_id`),
  UNIQUE KEY `uk_m02_executor_verification_evidence` (`evidence_reference`),
  KEY `idx_m02_executor_verification_lookup` (`group_id`,`group_revision`,`old_executor_id`,`new_executor_id`,`state`,`expires_at`),
  CONSTRAINT `ck_m02_executor_verification_state` CHECK (`state` IN ('VERIFIED','REJECTED','UNKNOWN')),
  CONSTRAINT `ck_m02_executor_verification_flags` CHECK ((`old_executor_physically_isolated` IN (0,1)) AND (`commands_reconciled_and_stopped` IN (0,1)) AND (`new_executor_binding_verified` IN (0,1))),
  CONSTRAINT `ck_m02_executor_verification_values` CHECK (`group_revision`>0 AND `expires_at`>=`verified_at` AND JSON_TYPE(`evidence_payload`)='OBJECT')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M02受信执行器隔离及绑定核验事实';

-- [缺失表] lab_executor_resource_group
CREATE TABLE `lab_executor_resource_group` (
  `group_id` BIGINT NOT NULL COMMENT '资源组主键，应用生成',
  `group_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '稳定资源组规范键',
  `lab_id` BIGINT NOT NULL COMMENT '所属实验室',
  `group_revision` BIGINT UNSIGNED NOT NULL COMMENT '成员或控制配置变更递增',
  `group_hash` BINARY(32) NOT NULL COMMENT '规范成员及控制配置摘要SHA256',
  `control_profile` JSON NOT NULL COMMENT '控制方、协议和能力核准引用；不含凭据',
  `state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'ACTIVE/DISABLED',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'CAS版本',
  `updated_by_user_id` BIGINT NOT NULL COMMENT '实际维护人',
  `updated_at` DATETIME(3) NOT NULL COMMENT 'UTC修改时间',
  PRIMARY KEY (`group_id`),
  UNIQUE KEY `uk_m02_executor_group_key` (`group_key`),
  KEY `idx_m02_executor_group_lab_state` (`lab_id`,`state`),
  CONSTRAINT `ck_m02_executor_group_state` CHECK (`state` IN ('ACTIVE','DISABLED')),
  CONSTRAINT `ck_m02_executor_group_values` CHECK (`group_revision`>0 AND `object_version`>0 AND JSON_TYPE(`control_profile`)='OBJECT')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M02共享物理资源组身份及控制配置';

-- [缺失表] lab_executor_resource_group_member
CREATE TABLE `lab_executor_resource_group_member` (
  `group_id` BIGINT NOT NULL COMMENT '所属资源组',
  `resource_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'M07稳定资源声明键',
  `device_kind` VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'M02设备实例种类',
  `device_id` BIGINT NOT NULL COMMENT 'M02设备实例ID',
  `channel_key` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '泵位/管路/通道；无则空',
  `member_role` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'PUMP/SCALE/PIPELINE/CONTROLLER',
  `member_revision` BIGINT UNSIGNED NOT NULL COMMENT '成员映射版本',
  `state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'ACTIVE/DISABLED',
  PRIMARY KEY (`group_id`,`resource_key`),
  UNIQUE KEY `uk_m02_executor_member_resource` (`resource_key`),
  KEY `idx_m02_executor_member_device` (`device_kind`,`device_id`),
  CONSTRAINT `ck_m02_executor_member_state` CHECK (`state` IN ('ACTIVE','DISABLED')),
  CONSTRAINT `ck_m02_executor_member_values` CHECK (`device_id`>0 AND `member_revision`>0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M02共享物理资源组成员映射';

-- [缺失表] lab_observation_raw_evidence
CREATE TABLE lab_observation_raw_evidence (
  evidence_id BIGINT NOT NULL COMMENT '应用生成的正数证据ID',
  adapter_id VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '已验签接入适配器身份',
  lab_id BIGINT NOT NULL COMMENT '核准实验室ID',
  device_kind VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '测量设备种类',
  device_id BIGINT NOT NULL COMMENT '核准设备实例ID',
  key_id VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '部署受控密钥版本，不存密钥',
  nonce BINARY(12) NOT NULL COMMENT 'AES-GCM随机nonce',
  ciphertext MEDIUMBLOB NOT NULL COMMENT '带身份附加认证数据的AES-256-GCM签名包密文',
  packet_hash BINARY(32) NOT NULL COMMENT '解码原始设备报文字节SHA-256',
  created_at DATETIME(6) NOT NULL COMMENT '服务端首次保存时刻UTC',
  PRIMARY KEY (evidence_id),
  CONSTRAINT ck_obs_raw_ids CHECK (evidence_id > 0 AND lab_id > 0 AND device_id > 0),
  CONSTRAINT ck_obs_raw_device_kind CHECK (device_kind IN ('DETECTOR','FLOOR_SCALE','DOWNSTREAM_DEVICE')),
  CONSTRAINT ck_obs_raw_cipher CHECK (OCTET_LENGTH(ciphertext) >= 16)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M02受控原始观测证据';

-- [缺失表] run_executor_transfer
CREATE TABLE `run_executor_transfer` (
  `transfer_id` BIGINT NOT NULL COMMENT '执行器整组移交批次ID',
  `source_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'SHA256(M07_EXECUTOR_TRANSFER+actor+requestId)幂等键',
  `request_hash` BINARY(32) NOT NULL COMMENT '规范请求摘要SHA256',
  `anchor_resource_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'HTTP路径锚点资源键',
  `lab_id` BIGINT NOT NULL COMMENT '资源组所属实验室',
  `old_executor_id` VARCHAR(128) NOT NULL COMMENT '移交前固定执行器',
  `new_executor_id` VARCHAR(128) NOT NULL COMMENT '移交后固定执行器',
  `group_snapshot` JSON NOT NULL COMMENT 'M02完整资源组成员冻结快照',
  `group_hash` BINARY(32) NOT NULL COMMENT '规范资源组快照SHA256',
  `eligibility_evidence` JSON NOT NULL COMMENT 'M02逐设备授权、隔离及命令对账证据',
  `state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'SUBMITTED/REJECTED/APPLIED/UNKNOWN',
  `submitted_by` BIGINT NOT NULL COMMENT '可信提交操作者',
  `submitted_at` DATETIME(3) NOT NULL COMMENT '提交时刻UTC',
  `completed_at` DATETIME(3) NULL COMMENT '终态时刻UTC',
  `rejection_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '受控拒绝码',
  `rejection_reason` VARCHAR(1000) NULL COMMENT '去敏拒绝原因',
  `result_receipt` JSON NULL COMMENT '长期精确移交回执',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '批次版本',
  PRIMARY KEY (`transfer_id`),
  UNIQUE KEY `uk_m07_executor_transfer_source` (`source_key`),
  KEY `idx_m07_executor_transfer_lab_state` (`lab_id`,`state`,`submitted_at`),
  CONSTRAINT `ck_m07_executor_transfer_state` CHECK (`state` IN ('SUBMITTED','REJECTED','APPLIED','UNKNOWN')),
  CONSTRAINT `ck_m07_executor_transfer_json` CHECK (JSON_TYPE(`group_snapshot`)='OBJECT' AND JSON_TYPE(`eligibility_evidence`)='OBJECT'),
  CONSTRAINT `ck_m07_executor_transfer_terminal` CHECK ((`state`='APPLIED' AND `completed_at` IS NOT NULL AND `result_receipt` IS NOT NULL) OR (`state`='REJECTED' AND `completed_at` IS NOT NULL AND `rejection_code` IS NOT NULL) OR (`state` IN ('SUBMITTED','UNKNOWN'))),  -- 基线笔误更正：原少 1 个右括号
  CONSTRAINT `ck_m07_executor_transfer_version` CHECK (`object_version`>0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='执行器整组移交不可变批次及长期回执';

-- [缺失表] run_executor_transfer_member
CREATE TABLE `run_executor_transfer_member` (
  `transfer_id` BIGINT NOT NULL COMMENT '所属移交批次',
  `resource_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '资源组成员键',
  `device_ref` JSON NOT NULL COMMENT 'M02冻结设备身份',
  `assignment_epoch_before` BIGINT UNSIGNED NOT NULL COMMENT '移交前归属纪元',
  `object_version_before` BIGINT UNSIGNED NOT NULL COMMENT '移交前归属版本',
  `assignment_epoch_after` BIGINT UNSIGNED NULL COMMENT '移交后归属纪元；仅APPLIED',
  `object_version_after` BIGINT UNSIGNED NULL COMMENT '移交后归属版本；仅APPLIED',
  `executor_id_before` VARCHAR(128) NOT NULL COMMENT '移交前执行器',
  `executor_id_after` VARCHAR(128) NOT NULL COMMENT '目标执行器',
  `state_before` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '移交前归属状态',
  `state_after` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '移交后归属状态；仅APPLIED',
  PRIMARY KEY (`transfer_id`,`resource_key`),
  KEY `idx_m07_executor_transfer_member_resource` (`resource_key`,`transfer_id`),
  CONSTRAINT `ck_m07_executor_transfer_member_versions` CHECK (`assignment_epoch_before`>0 AND `object_version_before`>0 AND ((`assignment_epoch_after` IS NULL AND `object_version_after` IS NULL AND `state_after` IS NULL) OR (`assignment_epoch_after`=`assignment_epoch_before`+1 AND `object_version_after`=`object_version_before`+1 AND `state_after`='ENABLED'))),  -- 基线笔误更正：原少 1 个右括号
  CONSTRAINT `ck_m07_executor_transfer_member_state` CHECK (`state_before`='ISOLATED')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='执行器整组移交成员冻结快照及前后版本';

-- [缺失表] run_start_culture_receipt
CREATE TABLE `run_start_culture_receipt` (
  `actor_user_id` BIGINT NOT NULL COMMENT '原请求操作者，隔离查询及幂等命名空间',
  `request_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '原写请求ID',
  `lab_id` BIGINT NOT NULL COMMENT '原实验室',
  `workflow_kind` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '原开始培养类型',
  `session_id` BIGINT NOT NULL COMMENT '原页面会话',
  `operation` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '成功提交的固定操作',
  `payload_hash` BINARY(32) NOT NULL COMMENT '规范化原请求SHA256；不保存正文',
  `workflow_ids_json` JSON NOT NULL COMMENT '已提交实例ID字符串数组；OPEN为空',
  `batch_id` BIGINT NULL COMMENT '小试组引用',
  `created_at` DATETIME(3) NOT NULL COMMENT '原事务提交时间，UTC',
  PRIMARY KEY (`actor_user_id`,`request_id`),
  KEY `idx_m07_sc_receipt_session` (`session_id`,`created_at`),
  CONSTRAINT `ck_m07_sc_receipt_kind` CHECK (workflow_kind IN ('START_CULTURE_SMALL','START_CULTURE_PILOT')),
  CONSTRAINT `ck_m07_sc_receipt_refs` CHECK (JSON_TYPE(workflow_ids_json)='ARRAY')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='不可变成功请求引用；不按24小时清理；缺记录不能推断未执行';

-- [缺失表] run_start_culture_session
CREATE TABLE `run_start_culture_session` (
  `session_id` BIGINT NOT NULL COMMENT '页面会话；小试同时作为整组身份',
  `lab_id` BIGINT NOT NULL COMMENT '真实实验室',
  `workflow_kind` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'START_CULTURE_SMALL/START_CULTURE_PILOT',
  `actor_user_id` BIGINT NOT NULL COMMENT '会话所属服务端用户',
  `entry_business_date` DATE NOT NULL COMMENT '页面进入上海业务日',
  `deadline_at` DATETIME(3) NOT NULL COMMENT '当日次日零点的UTC时刻，禁止滚动延期',
  `interaction_state` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'ACTIVE/CANCEL_REQUESTED/CLOSED',
  `object_version` BIGINT UNSIGNED NOT NULL COMMENT '会话与小试组共用CAS版本',
  `current_step` INT UNSIGNED NOT NULL COMMENT '当前步骤1至4',
  `state_json` JSON NOT NULL COMMENT '类型化身份、访问、校验摘要和跳过意图；禁止业务草稿',
  `batch_id` BIGINT NULL COMMENT '小试绑定后=session_id；中试NULL',
  `created_at` DATETIME(3) NOT NULL COMMENT 'UTC',
  `closed_at` DATETIME(3) NULL COMMENT '安全关闭或完成，UTC；未闭合NULL',
  PRIMARY KEY (`session_id`),
  UNIQUE KEY `uk_m07_sc_batch` (`batch_id`),
  KEY `idx_m07_sc_actor` (`actor_user_id`,`lab_id`,`created_at`),
  KEY `idx_m07_sc_deadline` (`interaction_state`,`deadline_at`),
  CONSTRAINT `ck_m07_sc_kind` CHECK (workflow_kind IN ('START_CULTURE_SMALL','START_CULTURE_PILOT')),
  CONSTRAINT `ck_m07_sc_state` CHECK (interaction_state IN ('ACTIVE','CANCEL_REQUESTED','CLOSED') AND object_version>0 AND current_step BETWEEN 1 AND 4),
  CONSTRAINT `ck_m07_sc_batch` CHECK (batch_id IS NULL OR (workflow_kind='START_CULTURE_SMALL' AND batch_id=session_id)),
  CONSTRAINT `ck_m07_sc_closed` CHECK ((interaction_state='CLOSED' AND closed_at IS NOT NULL AND closed_at>=created_at) OR (interaction_state<>'CLOSED' AND closed_at IS NULL)),
  CONSTRAINT `ck_m07_sc_deadline` CHECK (deadline_at>created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='开始培养页面会话与整组聚合';

-- [缺失表] run_workflow_step_visit
CREATE TABLE `run_workflow_step_visit` (
  `visit_id` BIGINT NOT NULL COMMENT '访问身份',
  `page_session_id` BIGINT NOT NULL COMMENT '会话；第1步可先于运行实例存在',
  `step_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '稳定固定步骤编码',
  `visit_no` INT UNSIGNED NOT NULL COMMENT '同会话同一步锁内递增访问序号',
  `started_at` DATETIME(3) NOT NULL COMMENT '服务端进入UTC时刻',
  `ended_at` DATETIME(3) NULL COMMENT '已确认结束UTC时刻；未知保持NULL',
  `started_by` BIGINT NOT NULL COMMENT '进入操作者',
  `ended_by` BIGINT NULL COMMENT '结束操作者；自动中断可NULL',
  `end_reason` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'NEXT/COMPLETED/SKIPPED/BACK/CANCELLED/PAGE_REFRESH/DEADLINE_EXPIRED',
  `end_time_basis` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'SERVER_TRANSITION/DETECTED_INTERRUPTION；未知NULL',
  `start_request_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '开始请求引用',
  `end_request_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '独立结束请求引用',
  PRIMARY KEY (`visit_id`),
  UNIQUE KEY `uk_m07_sc_visit` (`page_session_id`,`step_code`,`visit_no`),
  CONSTRAINT `ck_m07_sc_visit_no` CHECK (visit_no>0),
  CONSTRAINT `ck_m07_sc_visit_end` CHECK ((ended_at IS NULL AND end_reason IS NULL AND end_time_basis IS NULL AND end_request_id IS NULL AND ended_by IS NULL) OR (ended_at IS NOT NULL AND ended_at>=started_at AND end_reason IS NOT NULL AND end_time_basis IS NOT NULL AND end_request_id IS NOT NULL)),
  CONSTRAINT `ck_m07_sc_visit_reason` CHECK (end_reason IS NULL OR end_reason IN ('NEXT','COMPLETED','SKIPPED','BACK','CANCELLED','PAGE_REFRESH','DEADLINE_EXPIRED')),
  CONSTRAINT `ck_m07_sc_visit_basis` CHECK (end_time_basis IS NULL OR end_time_basis IN ('SERVER_TRANSITION','DETECTED_INTERRUPTION'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='共享步骤访问时间审计；不可用结束时间证明物理停止';

-- [缺失表] run_workflow_step_visit_member
CREATE TABLE `run_workflow_step_visit_member` (
  `visit_id` BIGINT NOT NULL COMMENT '共享会话访问',
  `step_instance_id` BIGINT NOT NULL COMMENT '成员运行步骤',
  `workflow_id` BIGINT NOT NULL COMMENT '成员运行实例',
  `member_outcome` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '该访问成员结果，非整组结论',
  `evidence_refs` JSON NULL COMMENT '物理命令及确认引用；不含表单正文',
  PRIMARY KEY (`visit_id`,`step_instance_id`),
  KEY `idx_m07_sc_member_workflow` (`workflow_id`,`visit_id`),
  CONSTRAINT `ck_m07_sc_member_outcome` CHECK (member_outcome IN ('IN_PROGRESS','COMPLETED','SKIPPED','CANCELLED','UNKNOWN','PENDING'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='共享访问与各实例步骤关联及逐成员结果';

-- ============ 第二部分：5 张既有表缺失列与相关键/约束（基线定义追加） ============

-- [缺列] apr_reconciliation: withdraw_key, withdraw_hash, withdraw_evidence, withdrawn_at
ALTER TABLE `apr_reconciliation`
  ADD COLUMN `withdraw_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '撤回请求持久键',
  ADD COLUMN `withdraw_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '撤回原始语义载荷摘要',
  ADD COLUMN `withdraw_evidence` JSON NULL COMMENT '服务端撤回V1身份、原因及原时刻',
  ADD COLUMN `withdrawn_at` DATETIME(3) NULL COMMENT '原撤回时刻；UTC',
  ADD UNIQUE KEY `uk_apr_rec_withdraw` (`withdraw_key`),
  ADD CONSTRAINT `ck_apr_rec_withdraw` CHECK ( (state='WITHDRAWN' AND withdraw_key IS NOT NULL AND withdraw_hash IS NOT NULL AND withdraw_evidence IS NOT NULL AND withdrawn_at IS NOT NULL AND withdraw_key REGEXP '^[0-9A-Fa-f]{64}$' AND withdraw_hash REGEXP '^[0-9A-Fa-f]{64}$' AND JSON_TYPE(withdraw_evidence)='OBJECT' AND COALESCE(JSON_TYPE(JSON_EXTRACT(withdraw_evidence,'$.schemaVersion'))='INTEGER' AND JSON_UNQUOTE(JSON_EXTRACT(withdraw_evidence,'$.schemaVersion'))='1',FALSE)) OR (state<>'WITHDRAWN' AND withdraw_key IS NULL AND withdraw_hash IS NULL AND withdraw_evidence IS NULL AND withdrawn_at IS NULL));

-- [约束分歧-保持现状] res_culture.ck_m03_initial_weight：库中为早前迭代版本（只认 candidate_id，
-- 不含 initial_weight_source_kind/workflow_id 分支）。现行基线版本无法直接应用：
-- 既有行 861016201（DEV-M07-1016-C1）已写 initial_weight_g=1250 且无 source_kind，
-- 基线约束会拒绝该行；按授权不改既有业务数据，故按库中既有定义原样恢复该约束，保持现状。
-- 基线版约束应用记为 BLOCKED_DATA，待数据属主对该行来源分类后另行处理。
ALTER TABLE `res_culture` ADD CONSTRAINT `ck_m03_initial_weight` CHECK (((`initial_weight_g` is null) and (`initial_weight_revision` = 0) and (`initial_weight_effective_at` is null) and (`initial_weight_candidate_id` is null)) or ((`initial_weight_g` is not null) and (`initial_weight_g` > 0) and (`initial_weight_g` = floor(`initial_weight_g`)) and (`initial_weight_revision` >= 1) and (`initial_weight_effective_at` is not null) and (`initial_weight_candidate_id` is not null)));

-- [缺列] res_culture: initial_weight_source_kind, initial_weight_workflow_id, cell_type_id, cell_type_name, cell_type_value, cell_type_prefix, cell_type_workflow_id, cell_type_effective_at, start_completed_workflow_id
ALTER TABLE `res_culture`
  ADD COLUMN `initial_weight_source_kind` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'CHANGE_CANDIDATE/WORKFLOW_START；无有效重量NULL',
  ADD COLUMN `initial_weight_workflow_id` BIGINT NULL COMMENT '首次登记可信开始培养工作流；不伪造candidate',
  ADD COLUMN `cell_type_id` BIGINT NULL COMMENT '首次类型合法字典身份',
  ADD COLUMN `cell_type_name` VARCHAR(100) NULL COMMENT '首次类型名称快照',
  ADD COLUMN `cell_type_value` VARCHAR(100) NULL COMMENT '首次类型合法字典值快照，与显示名称分离',
  ADD COLUMN `cell_type_prefix` VARCHAR(100) NULL COMMENT '独立类型前缀；SC-Q07核准前拒绝非空输入',
  ADD COLUMN `cell_type_workflow_id` BIGINT NULL COMMENT '首次类型来源工作流',
  ADD COLUMN `cell_type_effective_at` DATETIME(3) NULL COMMENT '首次类型生效UTC时刻',
  ADD COLUMN `start_completed_workflow_id` BIGINT NULL COMMENT '已应用开始培养完成工作流；只写一次',
  ADD UNIQUE KEY `uk_m03_start_completed_workflow` (`start_completed_workflow_id`),
  -- 基线版 ck_m03_initial_weight 暂不应用（见上方 BLOCKED_DATA 说明）
  ADD CONSTRAINT `ck_m03_start_cell_type` CHECK ((cell_type_id IS NULL AND cell_type_name IS NULL AND cell_type_value IS NULL AND cell_type_prefix IS NULL AND cell_type_workflow_id IS NULL AND cell_type_effective_at IS NULL) OR (cell_type_id IS NOT NULL AND cell_type_name IS NOT NULL AND CHAR_LENGTH(TRIM(cell_type_name))>0 AND cell_type_value IS NOT NULL AND CHAR_LENGTH(TRIM(cell_type_value))>0 AND cell_type_workflow_id IS NOT NULL AND cell_type_effective_at IS NOT NULL));

-- [缺列] res_culture_parameter_snapshot: candidate_identity, candidate_hash
ALTER TABLE `res_culture_parameter_snapshot`
  ADD COLUMN `candidate_identity` json NULL COMMENT 'M03 v1不可变候选信封，历史候选可空',
  ADD COLUMN `candidate_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'M03候选信封SHA256，与包摘要独立',
  ADD CONSTRAINT `ck_m03_parameter_candidate_identity_pair` CHECK ( (`candidate_identity` IS NULL AND `candidate_hash` IS NULL) OR (`candidate_identity` IS NOT NULL AND `candidate_hash` IS NOT NULL));

-- [缺列] run_culture_runtime: runtime_stream_id, runtime_stream_sequence, runtime_last_event_key
ALTER TABLE `run_culture_runtime`
  ADD COLUMN `runtime_stream_id` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'M07生产侧稳定运行事实流；服务重启或执行器换主不改变',
  ADD COLUMN `runtime_stream_sequence` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'M07已生产的培养级运行事实最大序号；0表示尚未生产',
  ADD COLUMN `runtime_last_event_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'M07最后已生产事实的sourceEventKey；用于下一事实previousEventKey',
  ADD CONSTRAINT `ck_m07_runtime_stream` CHECK ((runtime_stream_sequence=0 AND runtime_stream_id IS NULL AND runtime_last_event_key IS NULL) OR (runtime_stream_sequence>0 AND runtime_stream_id IS NOT NULL AND runtime_last_event_key IS NOT NULL));

-- [缺列] run_workflow_instance: workflow_kind, page_session_id, batch_id, business_date, deadline_at, active_start_culture_id, completed_start_culture_id
ALTER TABLE `run_workflow_instance`
  ADD COLUMN `workflow_kind` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '开始培养专用类型；旧工作流NULL',
  ADD COLUMN `page_session_id` BIGINT NULL COMMENT '开始培养页面会话',
  ADD COLUMN `batch_id` BIGINT NULL COMMENT '小试整组身份，等于页面会话ID；中试NULL',
  ADD COLUMN `business_date` DATE NULL COMMENT '冻结上海业务日',
  ADD COLUMN `deadline_at` DATETIME(3) NULL COMMENT '冻结次日零点UTC时刻',
  ADD COLUMN `active_start_culture_id` BIGINT GENERATED ALWAYS AS (CASE WHEN workflow_kind IN ('START_CULTURE_SMALL','START_CULTURE_PILOT') AND state IN ('OPEN','IN_PROGRESS','NEEDS_RECONCILIATION') THEN culture_id ELSE NULL END) STORED COMMENT '未安全闭合尝试独占培养',
  ADD COLUMN `completed_start_culture_id` BIGINT GENERATED ALWAYS AS (CASE WHEN workflow_kind IN ('START_CULTURE_SMALL','START_CULTURE_PILOT') AND state='COMPLETED' THEN culture_id ELSE NULL END) STORED COMMENT '每培养唯一完成槽',
  ADD UNIQUE KEY `uk_m07_start_active` (`active_start_culture_id`),
  ADD UNIQUE KEY `uk_m07_start_completed` (`completed_start_culture_id`),
  ADD KEY `idx_m07_start_session` (`page_session_id`,`workflow_id`),
  ADD KEY `idx_m07_start_batch` (`batch_id`,`workflow_id`),
  ADD CONSTRAINT `ck_m07_start_kind` CHECK (workflow_kind IS NULL OR (workflow_kind IN ('START_CULTURE_SMALL','START_CULTURE_PILOT') AND culture_id IS NOT NULL AND page_session_id IS NOT NULL AND business_date IS NOT NULL AND deadline_at IS NOT NULL AND ((workflow_kind='START_CULTURE_SMALL' AND batch_id IS NOT NULL AND batch_id=page_session_id) OR (workflow_kind='START_CULTURE_PILOT' AND batch_id IS NULL)))),
  ADD CONSTRAINT `ck_m07_start_applied` CHECK (workflow_kind IS NULL OR state<>'COMPLETED' OR application_state='APPLIED');

-- ============ 第三部分：开始培养固定子流程与步骤补齐（SC-20261017 现行编码） ============
-- 背景：本开发库 workflow 种子为 2026-10-17 之前的旧版：既有 start_culture 节点（node_id=3，
-- 已绑定 11001/11002）下只有 start_cell_culture_small/pilot 旧编码子流程；现行基线 02 与后端
-- StartCultureApplicationService 使用 start_culture_small/pilot 编码，旧种子导致
-- START_DEFINITION_UNAVAILABLE。
-- 处理：workflow_node.node_code 唯一（节点 3 已占 start_culture），不新建节点；
--       workflow_subflow.uk_workflow_subflow_order 唯一（node_id+sort_order，旧行已占 1/2），
--       新子流程 sort_order 取 3/4（仅展示排序，不影响解析）；
--       在既有节点 3 下按基线 02 的 SC-20261017 片段补齐两个现行编码子流程及 8 个四步定义，
--       使用基线固定 ID（40011/40012、40021-40034），与库内无冲突；旧行（subflow 5,6 及其步骤）
--       保持不动，不删除既有数据。实验室绑定沿用既有 node 3 绑定，不新增直插。
INSERT INTO workflow_subflow(subflow_id,node_id,subflow_code,subflow_name,lab_type,repeatable,sort_order,del_flag,create_by,create_time,remark)
VALUES
(40011,3,'start_culture_small','小试开始培养','1',0,3,'0','INSTALL',UTC_TIMESTAMP(),'START_CULTURE_SMALL'),
(40012,3,'start_culture_pilot','中试开始培养','3',0,4,'0','INSTALL',UTC_TIMESTAMP(),'START_CULTURE_PILOT');
INSERT INTO workflow_step(step_id,node_id,subflow_id,step_code,step_order,step_name,step_description,image_path,del_flag,create_by,create_time,remark)
VALUES
(40021,3,40011,'START',1,'开始','冻结选择与当天期限',NULL,'0','INSTALL',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40022,3,40011,'INOCULATION',2,'接种信息','仅页面输入；最终完成事务保存',NULL,'0','INSTALL',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40023,3,40011,'SAMPLE_PRIME',3,'取样管路填充','物理能力未核准时阻断，允许显式跳过',NULL,'0','INSTALL',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40024,3,40011,'DEVICE_CONFIRM',4,'设备确认','全部可信确认后完成',NULL,'0','INSTALL',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40031,3,40012,'START',1,'开始','中试仅单台并冻结当天期限',NULL,'0','INSTALL',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40032,3,40012,'INOCULATION',2,'接种信息','仅页面输入；最终完成事务保存',NULL,'0','INSTALL',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40033,3,40012,'ONLINE_ALARM_CONFIRM',3,'在线告警确认','M09纯校验；此步骤不保存配置',NULL,'0','INSTALL',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40034,3,40012,'OPC_CONFIRM',4,'OPC确认','真实可信观测后完成；重启未核准时阻断',NULL,'0','INSTALL',UTC_TIMESTAMP(),'SC schemaVersion=2');

-- ============ 第四部分：Mock 一致测试数据（中试开始培养真实成功路径） ============
-- 目的：前端 Mock（mock-store.ts）约定 反应器 FX0xx / 培养 16407FX0xx / 项目 P-SMP-2026 /
--       批次 BATCH-1015 / 规格 15L。本部分按同一约定在开发库补录合法测试数据，使
--       START_CULTURE_PILOT 候选可达 eligible，进而验证 开始→步骤→完成 真实链路。
-- 约束：显式列名；ID 使用可识别测试段 9900000000000045xx；remark 统一标记 MOCK-SYNC-20261018；
--       不触碰任何既有行业务数据；单事务执行，失败整体回滚。
-- 业务日期按服务器上海时区当天（2026-10-18）设置，这是开始培养准入的硬性要求。
START TRANSACTION;

-- 项目（Mock: P-SMP-2026；m03_live_code 为生成列=trim(project_code)，不显式插入）
INSERT INTO res_project (project_id,project_name,project_code,dept_id,project_status,del_flag,create_by,create_time,update_by,update_time,remark,object_version,facts_status)
VALUES (990000000000004501,'P-SMP-2026','P-SMP-2026',100,'0','0','admin',UTC_TIMESTAMP(),'admin',UTC_TIMESTAMP(),'MOCK-SYNC-20261018 中试开始培养测试项目',1,'READY');

-- 项目成员（admin，MEMBER，无过期）— 保证培养属主可见性
INSERT INTO res_project_member (project_id,user_id,permission_type,expire_date,source_type,joined_time,grant_type,granted_at,granted_by_user_id,modified_at,modified_by_user_id)
VALUES (990000000000004501,1,'member',NULL,'manual',UTC_TIMESTAMP(),'MEMBER',UTC_TIMESTAMP(),1,UTC_TIMESTAMP(),1);

-- 批次（Mock: BATCH-1015，归属 11002）
INSERT INTO res_batch (batch_id,project_id,lab_id,batch_name,batch_code,batch_status,start_time,end_time,del_flag,create_by,create_time,update_by,update_time,remark,object_version,facts_status,feeding_interval_hours,sampling_interval_hours)
VALUES (990000000000004502,990000000000004501,11002,'BATCH-1015','BATCH-1015','0','2026-10-18','2026-10-24','0','admin',UTC_TIMESTAMP(),'admin',UTC_TIMESTAMP(),'MOCK-SYNC-20261018 中试开始培养测试批次',1,'READY',8,8);

-- 反应器地秤（启用；floorScaleReady 要求 status='0' 且 del_flag='0'）
INSERT INTO lab_floor_scale (scale_id,lab_id,venue_id,device_no,asset_no,model,spec,precision_value,alarm_low_limit,alarm_high_limit,is_feed_scale,owner_user_id,status,del_flag,create_by,create_time,update_by,update_time,remark)
VALUES (990000000000004503,11002,1304533223149277184,'FX045-SC1','FX045-SC1','MOCK-SCALE-15','15kg','1',0,15000,'0',1,'0','0','admin',UTC_TIMESTAMP(),'admin',UTC_TIMESTAMP(),'MOCK-SYNC-20261018 FX045 罐地秤');

-- 补料地秤（启用；lab_integrated_reactor.feed_scale_id 非空）
INSERT INTO lab_floor_scale (scale_id,lab_id,venue_id,device_no,asset_no,model,spec,precision_value,alarm_low_limit,alarm_high_limit,is_feed_scale,owner_user_id,status,del_flag,create_by,create_time,update_by,update_time,remark)
VALUES (990000000000004504,11002,1304533223149277184,'FX045-SC2','FX045-SC2','MOCK-SCALE-15F','15kg','1',0,15000,'1',1,'0','0','admin',UTC_TIMESTAMP(),'admin',UTC_TIMESTAMP(),'MOCK-SYNC-20261018 FX045 补料地秤');

-- 设备型号（Mock: 15L；integratedSpecification 读 dev_integrated_reactor.spec）
INSERT INTO dev_integrated_reactor (model_id,model_name,spec,capacity,pressure_unit,description,del_flag,create_by,create_time,update_by,update_time,remark,pump_count)
VALUES (990000000000004505,'FX045','15L',15000,'bar','MOCK-SYNC-20261018 FX045 15L 集成反应器型号','0','admin',UTC_TIMESTAMP(),'admin',UTC_TIMESTAMP(),'MOCK-SYNC-20261018',4);

-- 实验室集成反应器实例（Mock: FX045，绑定上述地秤）
INSERT INTO lab_integrated_reactor (integrated_id,lab_id,venue_id,model_id,device_no,asset_no,reactor_name,volume_ml,floor_scale_id,floor_scale_low_limit,floor_scale_high_limit,feed_scale_id,owner_user_id,status,del_flag,need_external_pump,create_by,create_time,update_by,update_time,remark)
VALUES (990000000000004506,11002,1304533223149277184,990000000000004505,'FX045','FX045','FX045',15000,990000000000004503,0,15000,990000000000004504,1,'0','0','0','admin',UTC_TIMESTAMP(),'admin',UTC_TIMESTAMP(),'MOCK-SYNC-20261018');

-- 培养（Mock: 16407FX045；REACTOR 模式；计划日期为上海当天→次日；
-- 注意 ck_m03_culture_duration 要求 planned_duration_days = DATEDIFF(end,start)+1（含首尾），故 10-18→10-19 为 2；
-- 工作流选择含开始培养节点 3）
INSERT INTO res_culture (culture_id,project_id,batch_id,lab_id,culture_code,culture_name,culture_mode,reactor_type,reactor_id,container_id,facts_status,lifecycle_state,mode_code,device_kind,device_id,planned_start_date,planned_end_date,planned_duration_days,workflow_selection_json,plan_version,object_version,del_flag,create_by,create_time,update_by,update_time,remark,member_setup_state,n_marked,start_delay_active,end_delay_active)
VALUES (990000000000004507,990000000000004501,990000000000004502,11002,'16407FX045','16407FX045','NORMAL','integrated_reactor',990000000000004506,NULL,'READY','NOT_STARTED','REACTOR','INTEGRATED_REACTOR',990000000000004506,'2026-10-18','2026-10-19',2,'["3"]',1,1,'0','admin',UTC_TIMESTAMP(),'admin',UTC_TIMESTAMP(),'MOCK-SYNC-20261018 中试开始培养测试培养','CONFIGURED',0,0,0);

-- 设备占用（RESERVED 激活槽；active_slot 为生成列=state<>'RELEASED'?1:NULL，不显式插入；
-- OCCUPANCY_INVALID 要求 state in RESERVED/RUNNING）
INSERT INTO res_culture_occupancy (occupancy_id,culture_id,device_kind,device_id,lab_id,occupancy_state,acquired_at,created_request_id,object_version)
VALUES (990000000000004508,990000000000004507,'INTEGRATED_REACTOR',990000000000004506,11002,'RESERVED',UTC_TIMESTAMP(),'MOCK-SYNC-20261018',1);

COMMIT;

-- ============ 第五部分：小试开始培养 Mock 一致测试数据（START_CULTURE_SMALL 真实链路） ============
-- 背景核对结论（2026-10-18 只读排查）：
--   1) 小试候选要求 lab_lab.lab_type='1'（11002 为 '3' 故 LAB_TYPE_NOT_SUPPORTED）；11001 为 '1' 且已绑定节点 3。
--   2) M02StartCultureDeviceAdapter.resolve(BENCH_CONTROLLER) 只校验 lab_bench_reactor 存在/启用 +
--      dev_bench_reactor.capacity（benchSpecification 联接）；控制器连接表不在开始培养候选链路。
--   3) 全库 28 个 dev_bench_reactor 型号 capacity 均为 NULL（含 DEV-M07-1016-R1 所用 1300175020131225600），
--      这是既有小试候选一律 SPECIFICATION_UNAVAILABLE 的根因；按不修改他人生成数据纪律，新建型号行。
--   4) Mock（mock-store.ts）仅定义中试 FX033–044/15L 约定，无小试命名；沿用同族可识别约定 FX045B/16407FX045B。
-- 纪律同上：显式列名；ID 段 9900000000000045xx；remark=MOCK-SYNC-20261018；单事务；不动既有行业务数据。
START TRANSACTION;

-- 台面反应器型号（2L；dev_bench_reactor 既有行 capacity 全为 NULL，必须新建可用型号；
-- m02_active 为生成列不显式插入；brand NOT NULL）
INSERT INTO dev_bench_reactor (model_id,brand,category,capacity,capacity_unit,description,del_flag,create_by,create_time,update_by,update_time,remark)
VALUES (990000000000004511,'MOCK','bench',2,'L','MOCK-SYNC-20261018 小试台面反应器型号 2L','0','admin',UTC_TIMESTAMP(),'admin',UTC_TIMESTAMP(),'MOCK-SYNC-20261018');

-- 实验室台面反应器实例（11001；status='0'/del_flag='0'；m02_asset_key/m02_active 为生成列；
-- asset_no/vessel_no NOT NULL）
INSERT INTO lab_bench_reactor (reactor_id,lab_id,venue_id,model_id,device_no,asset_no,reactor_name,vessel_no,volume_ml,status,del_flag,create_by,create_time,update_by,update_time,remark)
VALUES (990000000000004512,11001,1304533223149277184,990000000000004511,'FX045B','FX045B','FX045B','V1',2000,'0','0','admin',UTC_TIMESTAMP(),'admin',UTC_TIMESTAMP(),'MOCK-SYNC-20261018 FX045B 台面反应器');

-- 培养（Mock 同族约定 16407FX045B；BENCH_CONTROLLER；计划日期上海当天→次日，duration=DATEDIFF+1=2；
-- 工作流选择含开始培养节点 3（node_code='start_culture'，status='0'，11001 已绑定）；
-- 复用 P-SMP-2026/BATCH-1015（admin 为项目成员，member() 通过；候选链路不校验批次实验室归属）；
-- m03_live_code 为生成列不显式插入）
INSERT INTO res_culture (culture_id,project_id,batch_id,lab_id,culture_code,culture_name,culture_mode,reactor_type,reactor_id,container_id,facts_status,lifecycle_state,mode_code,device_kind,device_id,planned_start_date,planned_end_date,planned_duration_days,workflow_selection_json,plan_version,object_version,del_flag,create_by,create_time,update_by,update_time,remark,member_setup_state,n_marked,start_delay_active,end_delay_active)
VALUES (990000000000004513,990000000000004501,990000000000004502,11001,'16407FX045B','16407FX045B','NORMAL','bench_reactor',990000000000004512,NULL,'READY','NOT_STARTED','NORMAL','BENCH_CONTROLLER',990000000000004512,'2026-10-18','2026-10-19',2,'["3"]',1,1,'0','admin',UTC_TIMESTAMP(),'admin',UTC_TIMESTAMP(),'MOCK-SYNC-20261018 小试开始培养测试培养','CONFIGURED',0,0,0);

-- 设备占用（RESERVED；须与培养 lab/device_kind/device_id 一致才能被 read 联接；
-- active_slot 生成列不显式插入）
INSERT INTO res_culture_occupancy (occupancy_id,culture_id,device_kind,device_id,lab_id,occupancy_state,acquired_at,created_request_id,object_version)
VALUES (990000000000004514,990000000000004513,'BENCH_CONTROLLER',990000000000004512,11001,'RESERVED',UTC_TIMESTAMP(),'MOCK-SYNC-20261018',1);

COMMIT;
