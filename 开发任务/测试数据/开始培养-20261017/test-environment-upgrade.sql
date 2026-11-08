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

ALTER TABLE res_culture ADD COLUMN `initial_weight_source_kind` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'CHANGE_CANDIDATE/WORKFLOW_START；无有效重量NULL',
ADD COLUMN `initial_weight_workflow_id` BIGINT NULL COMMENT '首次登记可信开始培养工作流；不伪造candidate',
ADD COLUMN `cell_type_id` BIGINT NULL COMMENT '首次类型合法字典身份',
ADD COLUMN `cell_type_name` VARCHAR(100) NULL COMMENT '首次类型名称快照',
ADD COLUMN `cell_type_value` VARCHAR(100) NULL COMMENT '首次类型合法字典值快照，与显示名称分离',
ADD COLUMN `cell_type_prefix` VARCHAR(100) NULL COMMENT '独立类型前缀；SC-Q07核准前拒绝非空输入',
ADD COLUMN `cell_type_workflow_id` BIGINT NULL COMMENT '首次类型来源工作流',
ADD COLUMN `cell_type_effective_at` DATETIME(3) NULL COMMENT '首次类型生效UTC时刻',
ADD COLUMN `start_completed_workflow_id` BIGINT NULL COMMENT '已应用开始培养完成工作流；只写一次';

UPDATE res_culture c JOIN res_culture_change_candidate cc ON cc.candidate_id=c.initial_weight_candidate_id AND cc.culture_id=c.culture_id AND cc.state='APPLIED' SET c.initial_weight_source_kind='CHANGE_CANDIDATE' WHERE c.initial_weight_g IS NOT NULL AND c.initial_weight_source_kind IS NULL;

ALTER TABLE res_culture DROP CHECK ck_m03_initial_weight,
ADD UNIQUE KEY `uk_m03_start_completed_workflow` (`start_completed_workflow_id`),
ADD CONSTRAINT `ck_m03_initial_weight` CHECK (
    (initial_weight_g IS NULL AND initial_weight_revision=0 AND initial_weight_effective_at IS NULL AND initial_weight_candidate_id IS NULL AND initial_weight_source_kind IS NULL AND initial_weight_workflow_id IS NULL)
    OR (initial_weight_g IS NOT NULL AND initial_weight_g>0 AND initial_weight_g=FLOOR(initial_weight_g)
    AND initial_weight_revision>=1 AND initial_weight_effective_at IS NOT NULL AND initial_weight_source_kind IS NOT NULL
    AND ((initial_weight_source_kind='CHANGE_CANDIDATE' AND initial_weight_candidate_id IS NOT NULL AND initial_weight_workflow_id IS NULL)
    OR (initial_weight_source_kind='WORKFLOW_START' AND initial_weight_candidate_id IS NULL AND initial_weight_workflow_id IS NOT NULL)))),
ADD CONSTRAINT `ck_m03_start_cell_type` CHECK ((cell_type_id IS NULL AND cell_type_name IS NULL AND cell_type_value IS NULL AND cell_type_prefix IS NULL AND cell_type_workflow_id IS NULL AND cell_type_effective_at IS NULL) OR (cell_type_id IS NOT NULL AND cell_type_name IS NOT NULL AND CHAR_LENGTH(TRIM(cell_type_name))>0 AND cell_type_value IS NOT NULL AND CHAR_LENGTH(TRIM(cell_type_value))>0 AND cell_type_workflow_id IS NOT NULL AND cell_type_effective_at IS NOT NULL));

ALTER TABLE run_workflow_instance ADD COLUMN `workflow_kind` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '开始培养专用类型；旧工作流NULL',
ADD COLUMN `page_session_id` BIGINT NULL COMMENT '开始培养页面会话',
ADD COLUMN `batch_id` BIGINT NULL COMMENT '小试整组身份，等于页面会话ID；中试NULL',
ADD COLUMN `business_date` DATE NULL COMMENT '冻结上海业务日',
ADD COLUMN `deadline_at` DATETIME(3) NULL COMMENT '冻结次日零点UTC时刻',
ADD COLUMN `active_start_culture_id` BIGINT GENERATED ALWAYS AS (CASE WHEN workflow_kind IN ('START_CULTURE_SMALL','START_CULTURE_PILOT') AND state IN ('OPEN','IN_PROGRESS','NEEDS_RECONCILIATION') THEN culture_id ELSE NULL END) STORED COMMENT '未安全闭合尝试独占培养',
ADD COLUMN `completed_start_culture_id` BIGINT GENERATED ALWAYS AS (CASE WHEN workflow_kind IN ('START_CULTURE_SMALL','START_CULTURE_PILOT') AND state='COMPLETED' THEN culture_id ELSE NULL END) STORED COMMENT '每培养唯一完成槽';

ALTER TABLE run_workflow_instance ADD UNIQUE KEY `uk_m07_start_active` (`active_start_culture_id`),
ADD UNIQUE KEY `uk_m07_start_completed` (`completed_start_culture_id`),
ADD KEY `idx_m07_start_session` (`page_session_id`,`workflow_id`),
ADD KEY `idx_m07_start_batch` (`batch_id`,`workflow_id`),
ADD CONSTRAINT `ck_m07_start_kind` CHECK (workflow_kind IS NULL OR (workflow_kind IN ('START_CULTURE_SMALL','START_CULTURE_PILOT') AND culture_id IS NOT NULL AND page_session_id IS NOT NULL AND business_date IS NOT NULL AND deadline_at IS NOT NULL AND ((workflow_kind='START_CULTURE_SMALL' AND batch_id IS NOT NULL AND batch_id=page_session_id) OR (workflow_kind='START_CULTURE_PILOT' AND batch_id IS NULL)))),
ADD CONSTRAINT `ck_m07_start_applied` CHECK (workflow_kind IS NULL OR state<>'COMPLETED' OR application_state='APPLIED');