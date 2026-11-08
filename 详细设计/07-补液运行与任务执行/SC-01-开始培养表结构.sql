-- SC-20261017: design source only. Installed only through 开发基线/01-完整建表.sql.
-- No business form drafts. UTC millisecond timestamps. No physical foreign keys.
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
