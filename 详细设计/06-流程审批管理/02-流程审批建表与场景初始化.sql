-- 2026-09-10 M06设计稿，未执行。目标MySQL8.0.16+的8.x，无外键。
-- 禁止--force；DDL隐式提交，部分失败停止保留现场。
SET NAMES utf8mb4;
-- 三个会话确认开关由执行者核验后设置；脚本不能证明外部停写/原生备份。
DELIMITER $$
CREATE PROCEDURE m06_preflight_20260910()
BEGIN
  IF DATABASE() IS NULL OR COALESCE(@m06_maintenance_confirmed,0)<>1 OR COALESCE(@m06_native_backup_verified,0)<>1 OR COALESCE(@m06_dependency_verified,0)<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M06 guard 1: stop and reconcile'; END IF;
  IF VERSION() NOT REGEXP '^8[.]' OR (SUBSTRING_INDEX(VERSION(),'.',2)='8.0' AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(VERSION(),'.',3),'.',-1) AS UNSIGNED)<16) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M06 guard 2: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name IN ('apr_scene','apr_lab_policy','apr_policy_revision','apr_request','apr_action','apr_delivery')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M06 guard 3: stop and reconcile'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND constraint_name IN ('ck_apr_scene_source','ck_apr_scene_scope','ck_apr_scene_owner','ck_apr_policy_version','ck_apr_policy_ready','ck_apr_policy_revision_no','ck_apr_policy_json','ck_apr_request_versions','ck_apr_request_actor','ck_apr_request_json','ck_apr_request_stage_actors','ck_apr_request_actor_time','ck_apr_request_state','ck_apr_request_review_stage','ck_apr_request_policy','ck_apr_request_stage','ck_apr_action_version','ck_apr_action_json','ck_apr_action_actor','ck_apr_action_reason','ck_apr_action_code','ck_apr_delivery_kind','ck_apr_delivery_state','ck_apr_delivery_json','ck_apr_delivery_ack','ck_apr_delivery_lease','ck_apr_delivery_version')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M06 guard 4: stop and reconcile'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_type='BASE TABLE' AND engine='InnoDB' AND table_name IN ('lab_lab','res_project','res_batch','res_culture','sys_management_revision','sys_management_request'))<>6 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M06 guard 5: stop and reconcile'; END IF;
END$$
DELIMITER ;
CALL m06_preflight_20260910();
DROP PROCEDURE m06_preflight_20260910;
CREATE TABLE `apr_scene` (
  `scene_code` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '受控场景码主键；不是可编辑业务名称',
  `source_kind` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'TASK/CULTURE_OPERATION/PLAN_INITIALIZATION/DATA_MANAGEMENT',
  `module_level1` VARCHAR(64) NOT NULL COMMENT '源一级模块名称',
  `module_level2` VARCHAR(100) NOT NULL COMMENT '源二级模块名称',
  `operation_code` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'MODIFY/MANUAL_CREATE/SYSTEM_CREATE/CREATE/INIT/CANCEL/ALARM_BLOCK/CANCEL_COPY/VOID',
  `owner_module` VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'M03/M05/M07/M09；真实变更拥有方',
  `scope_state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'SUPPORTED/OWNER_GATED/EXCLUDED',
  `source_reference` VARCHAR(255) NOT NULL COMMENT '冻结源文件工作表行号',
  `source_hash` BINARY(32) NOT NULL COMMENT '源附件SHA256',
  `schema_version` SMALLINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '受控目录版本',
  `sort_order` INT UNSIGNED NOT NULL COMMENT '展示顺序',
  `scope_reason` VARCHAR(500) NOT NULL COMMENT '本期范围或排除依据',
  PRIMARY KEY (`scene_code`),
  CONSTRAINT `ck_apr_scene_source` CHECK (source_kind IN ('TASK','CULTURE_OPERATION','PLAN_INITIALIZATION','DATA_MANAGEMENT')),
  CONSTRAINT `ck_apr_scene_scope` CHECK (scope_state IN ('SUPPORTED','OWNER_GATED','EXCLUDED')),
  CONSTRAINT `ck_apr_scene_owner` CHECK (owner_module IN ('M03','M05','M07','M09'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M06流程审批目标表';

CREATE TABLE `apr_lab_policy` (
  `policy_id` BIGINT NOT NULL COMMENT '平台分配主键',
  `lab_id` BIGINT NOT NULL COMMENT '真实lab_lab实验室；逻辑唯一',
  `current_revision_id` BIGINT NULL COMMENT '当前不可变配置版本；初始NULL',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '整份配置共同版本',
  `readiness` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'UNVERIFIED' COMMENT 'UNVERIFIED/READY；不默认免审批',
  `created_at` DATETIME(3) NOT NULL COMMENT '创建时刻',
  `updated_at` DATETIME(3) NOT NULL COMMENT '最近更新时刻',
  `updated_by` BIGINT NOT NULL COMMENT '稳定配置操作者',
  PRIMARY KEY (`policy_id`),
  UNIQUE INDEX `uk_apr_policy_lab` (`lab_id`),
  CONSTRAINT `ck_apr_policy_version` CHECK (object_version>=1),
  CONSTRAINT `ck_apr_policy_ready` CHECK (readiness IN ('UNVERIFIED','READY') AND (readiness<>'READY' OR current_revision_id IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M06流程审批目标表';

CREATE TABLE `apr_policy_revision` (
  `revision_id` BIGINT NOT NULL COMMENT '不可变配置版本主键',
  `policy_id` BIGINT NOT NULL COMMENT '配置根逻辑关联',
  `revision_no` BIGINT UNSIGNED NOT NULL COMMENT '同配置从1递增',
  `policy_snapshot` JSON NOT NULL COMMENT 'schema/entries/resolutionRules完整快照',
  `content_hash` BINARY(32) NOT NULL COMMENT '规范化配置SHA256',
  `source_evidence` JSON NOT NULL COMMENT '初始化资料或人工维护事实及核准人时间',
  `created_by` BIGINT NOT NULL COMMENT '真实配置操作者',
  `created_at` DATETIME(3) NOT NULL COMMENT '版本形成时刻',
  `change_reason` VARCHAR(500) NULL COMMENT '管理变更说明，可空；非审批原因',
  PRIMARY KEY (`revision_id`),
  UNIQUE INDEX `uk_apr_policy_revision` (`policy_id`,`revision_no`),
  CONSTRAINT `ck_apr_policy_revision_no` CHECK (revision_no>=1),
  CONSTRAINT `ck_apr_policy_json` CHECK (JSON_TYPE(policy_snapshot)='OBJECT' AND JSON_TYPE(source_evidence)='OBJECT')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M06流程审批目标表';

CREATE TABLE `apr_request` (
  `approval_id` BIGINT NOT NULL COMMENT '审批单主键',
  `scene_code` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'apr_scene场景逻辑关联',
  `lab_id` BIGINT NOT NULL COMMENT '固定真实实验室',
  `project_id` BIGINT NOT NULL COMMENT '固定真实项目',
  `batch_id` BIGINT NOT NULL COMMENT '固定真实批次',
  `culture_id` BIGINT NOT NULL COMMENT '固定真实培养',
  `owner_module` VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'M03/M07/M09',
  `source_request_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '拥有方持久幂等请求键',
  `change_key` VARCHAR(160) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '受控业务操作唯一槽；不由客户端任意选择',
  `target_type` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'CULTURE/TASK/PLAN/ALARM_CONFIG',
  `target_id` BIGINT NOT NULL COMMENT '业务对象或预分配候选任务ID',
  `expected_target_version` BIGINT UNSIGNED NOT NULL COMMENT '审阅所依赖源版本；新增候选0',
  `candidate_id` BIGINT NOT NULL COMMENT '来源不可变候选ID',
  `candidate_version` BIGINT UNSIGNED NOT NULL COMMENT '来源候选版本',
  `candidate_hash` BINARY(32) NOT NULL COMMENT '精确内容SHA256',
  `policy_revision_id` BIGINT NOT NULL COMMENT '申请固定政策版本',
  `policy_snapshot` JSON NOT NULL COMMENT '仅本场景策略与分离/回退规则快照',
  `change_snapshot` JSON NOT NULL COMMENT '全部前后差异与关联对象和影响规则',
  `initiator_kind` VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'USER/SYSTEM',
  `initiator_user_id` BIGINT NULL COMMENT '人工申请人；系统NULL',
  `initiator_snapshot` JSON NOT NULL COMMENT '提交身份和合法来源证据',
  `submission_reason` VARCHAR(500) NULL COMMENT '提交补充说明',
  `state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'PENDING_REVIEW' COMMENT 'PENDING_REVIEW/PENDING_APPROVAL/APPROVED/CANCELLED',
  `apply_state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'NONE' COMMENT 'NONE/NOT_APPLICABLE/PENDING/APPLIED/CONFLICT/FAILED/UNKNOWN',
  `cancel_kind` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'REJECTED/WITHDRAWN/SOURCE_INVALIDATED',
  `decision_version` BIGINT UNSIGNED NULL COMMENT '最终决定版本；后续ack不改变',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '审批及生效投影共同版本',
  `reviewer_user_id` BIGINT NULL COMMENT '首级真实审核人',
  `reviewed_at` DATETIME(3) NULL COMMENT '首级通过时刻',
  `approver_user_id` BIGINT NULL COMMENT '第二级真实批准人',
  `approved_at` DATETIME(3) NULL COMMENT '第二级通过时刻；单级NULL',
  `submitted_at` DATETIME(3) NOT NULL COMMENT '首次提交，用于列表排序',
  `operation_at` DATETIME(3) NOT NULL COMMENT '最近提交/撤回时刻，不被审批/投递覆盖',
  `operator_user_id` BIGINT NULL COMMENT '最近提交/撤回用户，系统NULL',
  `supersedes_approval_id` BIGINT NULL COMMENT '重新申请关联旧单，不复活旧单',
  `active_change_key` VARCHAR(160) CHARACTER SET ascii COLLATE ascii_bin GENERATED ALWAYS AS (CASE WHEN state IN ('PENDING_REVIEW','PENDING_APPROVAL') OR (state='APPROVED' AND apply_state IN ('PENDING','UNKNOWN')) THEN change_key ELSE NULL END) STORED COMMENT '待审及通过待生效/未知占用同业务变更槽',
  PRIMARY KEY (`approval_id`),
  UNIQUE INDEX `uk_apr_request_source` (`owner_module`,`source_request_id`),
  UNIQUE INDEX `uk_apr_active_change` (`owner_module`,`active_change_key`),
  INDEX `idx_apr_lab_submit` (`lab_id`,`submitted_at`,`approval_id`),
  INDEX `idx_apr_lab_state` (`lab_id`,`state`,`submitted_at`,`approval_id`),
  INDEX `idx_apr_culture` (`culture_id`,`approval_id`),
  CONSTRAINT `ck_apr_request_versions` CHECK (object_version>=1 AND candidate_version>=1 AND (decision_version IS NULL OR decision_version<=object_version)),
  CONSTRAINT `ck_apr_request_actor` CHECK ((initiator_kind='USER' AND initiator_user_id IS NOT NULL AND initiator_user_id>0) OR (initiator_kind='SYSTEM' AND initiator_user_id IS NULL)),
  CONSTRAINT `ck_apr_request_json` CHECK (JSON_TYPE(policy_snapshot)='OBJECT' AND JSON_TYPE(change_snapshot)='OBJECT' AND JSON_TYPE(initiator_snapshot)='OBJECT'),
  CONSTRAINT `ck_apr_request_stage_actors` CHECK ((reviewer_user_id IS NULL OR initiator_user_id IS NULL OR reviewer_user_id<>initiator_user_id) AND (approver_user_id IS NULL OR initiator_user_id IS NULL OR approver_user_id<>initiator_user_id) AND (reviewer_user_id IS NULL OR approver_user_id IS NULL OR reviewer_user_id<>approver_user_id)),
  CONSTRAINT `ck_apr_request_actor_time` CHECK ((reviewer_user_id IS NULL AND reviewed_at IS NULL OR reviewer_user_id IS NOT NULL AND reviewed_at IS NOT NULL) AND (approver_user_id IS NULL AND approved_at IS NULL OR approver_user_id IS NOT NULL AND approved_at IS NOT NULL)),
  CONSTRAINT `ck_apr_request_state` CHECK ((state IN ('PENDING_REVIEW','PENDING_APPROVAL') AND apply_state='NONE' AND cancel_kind IS NULL AND decision_version IS NULL) OR (state='APPROVED' AND apply_state IN ('PENDING','APPLIED','CONFLICT','FAILED','UNKNOWN') AND cancel_kind IS NULL AND decision_version IS NOT NULL) OR (state='CANCELLED' AND apply_state='NOT_APPLICABLE' AND cancel_kind IS NOT NULL AND cancel_kind IN ('REJECTED','WITHDRAWN','SOURCE_INVALIDATED') AND decision_version IS NOT NULL)),
  CONSTRAINT `ck_apr_request_review_stage` CHECK (state NOT IN ('PENDING_APPROVAL','APPROVED') OR reviewer_user_id IS NOT NULL),
  CONSTRAINT `ck_apr_request_policy` CHECK (COALESCE(JSON_UNQUOTE(JSON_EXTRACT(policy_snapshot,'$.entry.reviewMode')),'') IN ('BATCH','PROJECT') AND COALESCE(JSON_UNQUOTE(JSON_EXTRACT(policy_snapshot,'$.entry.approveMode')),'') IN ('NONE','BATCH','PROJECT') AND COALESCE(JSON_UNQUOTE(JSON_EXTRACT(policy_snapshot,'$.resolutionRules.differentStageActors')),'')='true'),
  CONSTRAINT `ck_apr_request_stage` CHECK ((state='PENDING_REVIEW' AND reviewer_user_id IS NULL AND approver_user_id IS NULL) OR (state='PENDING_APPROVAL' AND reviewer_user_id IS NOT NULL AND approver_user_id IS NULL AND COALESCE(JSON_UNQUOTE(JSON_EXTRACT(policy_snapshot,'$.entry.approveMode')),'') IN ('BATCH','PROJECT')) OR (state='APPROVED' AND reviewer_user_id IS NOT NULL AND ((COALESCE(JSON_UNQUOTE(JSON_EXTRACT(policy_snapshot,'$.entry.approveMode')),'')='NONE' AND approver_user_id IS NULL) OR (COALESCE(JSON_UNQUOTE(JSON_EXTRACT(policy_snapshot,'$.entry.approveMode')),'') IN ('BATCH','PROJECT') AND approver_user_id IS NOT NULL))) OR (state='CANCELLED' AND approver_user_id IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M06流程审批目标表';

CREATE TABLE `apr_action` (
  `action_id` BIGINT NOT NULL COMMENT '动作主键',
  `approval_id` BIGINT NOT NULL COMMENT '审批单逻辑关联',
  `action_code` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'SUBMIT/REVIEW_PASS/APPROVE_PASS/REJECT/WITHDRAW/SOURCE_INVALIDATE/APPLY_RESULT',
  `actor_kind` VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'USER/SYSTEM',
  `actor_user_id` BIGINT NULL COMMENT '系统动作NULL',
  `event_key` BINARY(32) NOT NULL COMMENT '规范化用户请求或来源回执身份摘要',
  `request_id` VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '人工UUID；系统来源身份在action_snapshot',
  `before_version` BIGINT UNSIGNED NOT NULL COMMENT 'SUBMIT前为0',
  `after_version` BIGINT UNSIGNED NOT NULL COMMENT '成功后=before+1',
  `before_state` VARCHAR(24) NULL COMMENT 'SUBMIT前NULL',
  `after_state` VARCHAR(24) NOT NULL COMMENT '动作后审批状态',
  `reason` VARCHAR(500) NULL COMMENT '拒绝/撤回必填，其他可空',
  `action_snapshot` JSON NOT NULL COMMENT '身份、权限、前后状态/应用态、源证据及请求摘要',
  `occurred_at` DATETIME(3) NOT NULL COMMENT '稳定服务端操作时刻',
  PRIMARY KEY (`action_id`),
  UNIQUE INDEX `uk_apr_action_event` (`approval_id`,`event_key`),
  INDEX `idx_apr_action_order` (`approval_id`,`occurred_at`,`action_id`),
  CONSTRAINT `ck_apr_action_version` CHECK (after_version=before_version+1),
  CONSTRAINT `ck_apr_action_json` CHECK (JSON_TYPE(action_snapshot)='OBJECT'),
  CONSTRAINT `ck_apr_action_actor` CHECK ((actor_kind='USER' AND actor_user_id IS NOT NULL AND actor_user_id>0 AND request_id IS NOT NULL AND CHAR_LENGTH(request_id)=36) OR (actor_kind='SYSTEM' AND actor_user_id IS NULL)),
  CONSTRAINT `ck_apr_action_reason` CHECK (action_code NOT IN ('REJECT','WITHDRAW','SOURCE_INVALIDATE') OR (reason IS NOT NULL AND CHAR_LENGTH(TRIM(reason)) BETWEEN 1 AND 500)),
  CONSTRAINT `ck_apr_action_code` CHECK (action_code IN ('SUBMIT','REVIEW_PASS','APPROVE_PASS','REJECT','WITHDRAW','SOURCE_INVALIDATE','APPLY_RESULT'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M06流程审批目标表';

CREATE TABLE `apr_delivery` (
  `delivery_id` BIGINT NOT NULL COMMENT '固定决定交付主键',
  `approval_id` BIGINT NOT NULL COMMENT '审批单逻辑关联',
  `decision_version` BIGINT UNSIGNED NOT NULL COMMENT '冻结最终决定版本',
  `decision_kind` VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'APPLY/DISCARD',
  `candidate_hash` BINARY(32) NOT NULL COMMENT '冻结候选SHA256',
  `payload_json` JSON NOT NULL COMMENT 'API11完整不可变决定',
  `state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING/RETRY/ACKNOWLEDGED/UNKNOWN/CONFLICT/FAILED',
  `attempts` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '技术交付次数',
  `next_attempt_at` DATETIME(3) NULL COMMENT '下一次重试或查询时间',
  `lease_token` VARCHAR(36) NULL COMMENT 'worker租约随机UUID',
  `lease_until` DATETIME(3) NULL COMMENT '租约过期时刻',
  `owner_receipt` JSON NULL COMMENT '最后可核验来源回执，完整历史见操作记录',
  `last_error` VARCHAR(1000) NULL COMMENT '无凭据错误摘要',
  `created_at` DATETIME(3) NOT NULL COMMENT '交付形成时刻',
  `updated_at` DATETIME(3) NOT NULL COMMENT '交付状态更新时刻',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '投递worker CAS版本',
  PRIMARY KEY (`delivery_id`),
  UNIQUE INDEX `uk_apr_delivery_decision` (`approval_id`,`decision_version`),
  INDEX `idx_apr_delivery_due` (`state`,`next_attempt_at`,`delivery_id`),
  CONSTRAINT `ck_apr_delivery_kind` CHECK (decision_kind IN ('APPLY','DISCARD')),
  CONSTRAINT `ck_apr_delivery_state` CHECK (state IN ('PENDING','RETRY','ACKNOWLEDGED','UNKNOWN','CONFLICT','FAILED')),
  CONSTRAINT `ck_apr_delivery_json` CHECK (JSON_TYPE(payload_json)='OBJECT' AND (owner_receipt IS NULL OR JSON_TYPE(owner_receipt)='OBJECT')),
  CONSTRAINT `ck_apr_delivery_ack` CHECK (state<>'ACKNOWLEDGED' OR owner_receipt IS NOT NULL),
  CONSTRAINT `ck_apr_delivery_lease` CHECK ((lease_token IS NULL AND lease_until IS NULL) OR (lease_token IS NOT NULL AND lease_until IS NOT NULL)),
  CONSTRAINT `ck_apr_delivery_version` CHECK (object_version>=1 AND decision_version>=1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M06流程审批目标表';

-- 初始化52条受控场景目录（含最新统计4项及原补液方案修改），不初始化任何实验室审批政策。
START TRANSACTION;
INSERT INTO apr_scene (scene_code,source_kind,module_level1,module_level2,operation_code,owner_module,scope_state,source_reference,source_hash,schema_version,sort_order,scope_reason) VALUES
('M06_SC001','TASK','任务审批','补料任务','MODIFY','M07','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r3',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,1,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC002','TASK','任务审批','补料任务','MANUAL_CREATE','M07','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r4',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,2,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC003','TASK','任务审批','补料任务','SYSTEM_CREATE','M07','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r5',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,3,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC004','TASK','任务审批','补糖任务','SYSTEM_CREATE','M07','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r6',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,4,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC005','TASK','任务审批','补糖任务','MODIFY','M07','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r7',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,5,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC006','TASK','任务审批','补糖任务','MANUAL_CREATE','M07','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r8',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,6,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC007','TASK','任务审批','补料任务','CANCEL','M07','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r9',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,7,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC008','TASK','任务审批','补糖任务','CANCEL','M07','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r10',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,8,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC049','TASK','任务审批','补液任务跨天间隔时间过短','ALARM_BLOCK','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r11',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,9,'执行前发现前8/12小时内已执行过同类型补液任务'),
('M06_SC050','TASK','任务审批','一天多次重复补液告警','ALARM_BLOCK','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r12',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,10,'执行前发现同一天已执行过同类型补液任务'),
('M06_SC009','TASK','任务审批','执行出错修复','CREATE','M07','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r13',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,11,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC010','TASK','任务审批','PH校准','CREATE','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r14',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,12,'现行范围已纳入；仅配置档位，不据目录恢复业务入口或跳过拥有方校验'),
('M06_SC011','TASK','任务审批','PH校准','MODIFY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r15',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,13,'现行范围已纳入；仅配置档位，不据目录恢复业务入口或跳过拥有方校验'),
('M06_SC012','TASK','任务审批','PH校准','CANCEL','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r16',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,14,'现行范围已纳入；仅配置档位，不据目录恢复业务入口或跳过拥有方校验'),
('M06_SC013','TASK','任务审批','取样检测','CREATE','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r17',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,15,'现行范围已纳入；仅配置档位，不据目录恢复业务入口或跳过拥有方校验'),
('M06_SC014','TASK','任务审批','取样检测','MODIFY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r18',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,16,'现行范围已纳入；仅配置档位，不据目录恢复业务入口或跳过拥有方校验'),
('M06_SC015','TASK','任务审批','取样检测','CANCEL','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r19',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,17,'现行范围已纳入；仅配置档位，不据目录恢复业务入口或跳过拥有方校验'),
('M06_SC051','TASK','任务审批','取样检测','CANCEL_COPY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r20',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,18,'仅登记审批配置场景；业务来源、候选及生效由拥有模块校验'),
('M06_SC016','PLAN_INITIALIZATION','工艺方案初始化','培养执行的工作流','INIT','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r21',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,19,'初始化候选契约保留；不恢复Q33排除编辑页，来源入口及固定包具备后方可申请'),
('M06_SC017','PLAN_INITIALIZATION','工艺方案初始化','config关联设置方案','INIT','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r22',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,20,'初始化候选契约保留；不恢复Q33排除编辑页，来源入口及固定包具备后方可申请'),
('M06_SC018','PLAN_INITIALIZATION','工艺方案初始化','灌注培养基方案','INIT','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r23',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,21,'初始化候选契约保留；不恢复Q33排除编辑页，来源入口及固定包具备后方可申请'),
('M06_SC019','PLAN_INITIALIZATION','工艺方案初始化','补液方案','INIT','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r24',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,22,'2026-10-24仅开放补液方案初始化入口；独立核准INIT政策，其他配置入口保持原范围'),
('M06_SC020','PLAN_INITIALIZATION','工艺方案初始化','自动控制方案','INIT','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r25',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,23,'初始化候选契约保留；不恢复Q33排除编辑页，来源入口及固定包具备后方可申请'),
('M06_SC021','PLAN_INITIALIZATION','工艺方案初始化','取样方案','INIT','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r26',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,24,'初始化候选契约保留；不恢复Q33排除编辑页，来源入口及固定包具备后方可申请'),
('M06_SC022','PLAN_INITIALIZATION','工艺方案初始化','测样方案','INIT','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r27',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,25,'初始化候选契约保留；不恢复Q33排除编辑页，来源入口及固定包具备后方可申请'),
('M06_SC023','PLAN_INITIALIZATION','工艺方案初始化','澄清方案','INIT','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r28',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,26,'初始化候选契约保留；不恢复Q33排除编辑页，来源入口及固定包具备后方可申请'),
('M06_SC024','PLAN_INITIALIZATION','工艺方案初始化','结束策略','INIT','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r29',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,27,'初始化候选契约保留；不恢复Q33排除编辑页，来源入口及固定包具备后方可申请'),
('M06_SC025','CULTURE_OPERATION','设备信息','更换设备','MODIFY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r30',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,28,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC026','CULTURE_OPERATION','设备信息','默认连接','MODIFY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r31',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,29,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC027','CULTURE_OPERATION','培养基本信息','培养ID','MODIFY','M03','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r32',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,30,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC028','CULTURE_OPERATION','培养基本信息','培养时间（开始时间/结束时间/培养天数）','MODIFY','M03','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r33',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,31,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC029','CULTURE_OPERATION','培养基本信息','培养模式','MODIFY','M03','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r34',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,32,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC030','CULTURE_OPERATION','重量信息','初始体积','MODIFY','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r35',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,33,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效；沿Q7当前初始培养重量口径，旧体积标签不推导g/mL换算'),
('M06_SC031','CULTURE_OPERATION','重量信息','接种体积','MODIFY','M03','EXCLUDED','审批场景统计.xlsx/Sheet1 (2)/r36',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,34,'Q34：接种体积旧入口本阶段排除，不与初始培养重量并建字段'),
('M06_SC032','CULTURE_OPERATION','重量信息','取测减少总体积','MODIFY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r37',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,35,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC033','CULTURE_OPERATION','残糖确认','补液计算规则','MODIFY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r38',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,36,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC034','CULTURE_OPERATION','残糖确认','残糖确认','MODIFY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r39',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,37,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC035','CULTURE_OPERATION','工艺设置','培养执行的工作流','MODIFY','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r40',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,38,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC036','CULTURE_OPERATION','工艺设置','config关联设置方案','MODIFY','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r41',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,39,'现行范围已纳入；仅配置档位，不据目录恢复业务入口或跳过拥有方校验'),
('M06_SC037','CULTURE_OPERATION','工艺设置','灌注培养基方案','MODIFY','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r42',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,40,'现行范围已纳入；仅配置档位，不据目录恢复业务入口或跳过拥有方校验'),
('M06_SC038','CULTURE_OPERATION','工艺设置','补料任务','MODIFY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r43',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,41,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC039','CULTURE_OPERATION','工艺设置','补糖规则','MODIFY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r44',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,42,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC040','CULTURE_OPERATION','工艺设置','自动控制方案','MODIFY','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r45',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,43,'现行范围已纳入；仅配置档位，不据目录恢复业务入口或跳过拥有方校验'),
('M06_SC041','CULTURE_OPERATION','工艺设置','取样方案','MODIFY','M03','EXCLUDED','审批场景统计.xlsx/Sheet1 (2)/r46',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,44,'Q33：培养方案修改七配置页本阶段排除'),
('M06_SC042','CULTURE_OPERATION','工艺设置','测样方案','MODIFY','M03','EXCLUDED','审批场景统计.xlsx/Sheet1 (2)/r47',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,45,'Q33：培养方案修改七配置页本阶段排除'),
('M06_SC043','CULTURE_OPERATION','工艺设置','澄清方案','MODIFY','M03','EXCLUDED','审批场景统计.xlsx/Sheet1 (2)/r48',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,46,'Q33：培养方案修改七配置页本阶段排除'),
('M06_SC044','CULTURE_OPERATION','工艺设置','结束策略','MODIFY','M03','EXCLUDED','审批场景统计.xlsx/Sheet1 (2)/r49',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,47,'Q33：培养方案修改七配置页本阶段排除'),
('M06_SC045','CULTURE_OPERATION','在线数据','在线告警设置','MODIFY','M09','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r50',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,48,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC046','CULTURE_OPERATION','离线数据','离线告警设置','MODIFY','M09','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r51',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,49,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC047','CULTURE_OPERATION','结束培养','取消培养','CANCEL','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r52',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,50,'Q36：不实现真实结束培养工作流；只消费拥有方本期合法候选/模拟事实，不新增停机入口'),
('M06_SC052','DATA_MANAGEMENT','样本作废','样本作废','VOID','M05','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r53',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,51,'仅登记审批配置场景；业务来源、候选及生效由拥有模块校验'),
('M06_SC048','CULTURE_OPERATION','工艺设置','补液方案','MODIFY','M03','OWNER_GATED','用户确认/2026-10-24/补液方案入口',UNHEX('38b7f45162b2a67f64aeb6c1fcb8dc530c6dc269da1b3a91ba572da5a1b2272d'),1,52,'仅开放补液方案替换；独立核准MODIFY政策，不复用INIT或补料任务政策；原任务安全屏障仍适用');
COMMIT;
