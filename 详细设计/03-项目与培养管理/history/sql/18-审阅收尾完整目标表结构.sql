-- 2026-09-11 M03 19表276列；静态设计未执行。仅隔离空库参考，不与旧包重复创建。
-- M06场景种子仍取原02中已核验47行，单独初始化；本文件不凭空核准政策/现场能力。
CREATE TABLE `res_project` (
`project_id` bigint NOT NULL COMMENT '项目主键',

  `project_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目名称',

  `project_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '项目编号',

  `dept_id` bigint NULL DEFAULT NULL COMMENT '所属部门主键',

  `project_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0进行中 1已完成 2已暂停），字典：SMP项目状态',

  `start_date` date NULL DEFAULT NULL COMMENT '开始日期',

  `end_date` date NULL DEFAULT NULL COMMENT '结束日期',

  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',

  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',

  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',

  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',

  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',

  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',

  `object_version` bigint NOT NULL DEFAULT 1 COMMENT '对象并发版本；迁移基线1，每次领域变更递增',

  `creator_user_id` bigint NULL COMMENT '真实创建用户ID，逻辑关联sys_user；旧身份未知NULL，不按当前用户名猜测',

  `modifier_user_id` bigint NULL COMMENT '最近修改用户ID，旧身份未知NULL',

  `deleted_at` datetime(3) NULL COMMENT '逻辑删除确认时刻UTC；旧未知NULL',

  `deleted_by_user_id` bigint NULL COMMENT '逻辑删除操作者ID，旧未知NULL',

  `facts_status` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'REVIEW' COMMENT 'READY已核准，REVIEW待核验；新业务必须显式READY',

  `m03_live_code` varchar(50) GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN TRIM(`project_code`) ELSE NULL END) STORED COMMENT '逻辑删除释放编号，历史记录按内部主键保留',

  PRIMARY KEY (`project_id`) USING BTREE,

  INDEX `idx_res_project_dept`(`dept_id` ASC) USING BTREE,

  INDEX `idx_res_project_status`(`project_status` ASC) USING BTREE,

  CONSTRAINT `ck_m03_project_version` CHECK (`object_version` >= 1),

  CONSTRAINT `ck_m03_project_facts` CHECK (`facts_status` IN ('READY','REVIEW')),

  CONSTRAINT `ck_m03_project_identity` CHECK (`project_id` > 0 AND `del_flag` IS NOT NULL AND `del_flag` IN ('0','2') AND CHAR_LENGTH(TRIM(`project_code`)) > 0),

  INDEX `idx_m03_project_created` (`del_flag`,`create_time`,`project_id`),

  UNIQUE INDEX `uk_m03_project_code` (`m03_live_code`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `res_project_leader` (
`project_id` bigint NOT NULL COMMENT '项目主键',

  `user_id` bigint NOT NULL COMMENT '负责人用户主键',

  PRIMARY KEY (`project_id`, `user_id`) USING BTREE,

  INDEX `idx_res_project_leader_user`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目负责人关联表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `res_project_lab` (
`project_id` bigint NOT NULL COMMENT '项目主键',

  `lab_id` bigint NOT NULL COMMENT '实验室主键',

  PRIMARY KEY (`project_id`, `lab_id`) USING BTREE,

  INDEX `idx_res_project_lab_lab`(`lab_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目参与实验室关联表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `res_project_tag` (
`project_id` bigint NOT NULL COMMENT '项目主键',

  `dict_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典类型（如smp_project_tag）',

  `tag_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典值，字典：SMP项目标签',

  `tag_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典标签快照',

  PRIMARY KEY (`project_id`, `dict_code`, `tag_value`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目标签关联表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `res_project_member` (
`project_id` bigint NOT NULL COMMENT '项目主键',

  `user_id` bigint NOT NULL COMMENT '用户主键',

  `permission_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'member' COMMENT '权限类型（admin/member/view/share）',

  `expire_date` date NULL DEFAULT NULL COMMENT '权限截止日期，空为永久',

  `source_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'direct' COMMENT '来源（direct/group/share）',

  `joined_time` datetime NULL DEFAULT NULL COMMENT '加入时间',

  `grant_type` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'LEGACY' COMMENT 'MEMBER直接成员/SHARE直接分享/LEGACY旧语义待核准；新接口拒绝LEGACY',

  `granted_at` datetime(3) NULL COMMENT '本次直接授权开始时刻UTC；旧记录未知NULL',

  `granted_by_user_id` bigint NULL COMMENT '本次授权操作者ID，旧未知NULL',

  `modified_at` datetime(3) NULL COMMENT '最近改期时刻UTC，旧未知NULL',

  `modified_by_user_id` bigint NULL COMMENT '最近改期操作者ID，旧未知NULL',

  `selection_origin` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'USER手选/DEPARTMENT部门快照/GROUP组快照；旧未知NULL，不形成动态继承',

  `selection_ref` varchar(128) NULL COMMENT '选择来源证据引用，非授权关系主键；可空',

  PRIMARY KEY (`project_id`, `user_id`, `grant_type`) USING BTREE,

  INDEX `idx_res_project_member_user`(`user_id` ASC) USING BTREE,

  INDEX `idx_res_project_member_expire`(`expire_date` ASC) USING BTREE,

  CONSTRAINT `ck_m03_project_grant_type` CHECK (`grant_type` IN ('MEMBER','SHARE','LEGACY')),

  CONSTRAINT `ck_m03_project_origin` CHECK (`selection_origin` IS NULL OR `selection_origin` IN ('USER','DEPARTMENT','GROUP')),

  INDEX `idx_m03_project_grant_user` (`user_id`,`grant_type`,`expire_date`,`project_id`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目成员权限表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `res_batch` (
`batch_id` bigint NOT NULL COMMENT '批次主键',

  `project_id` bigint NOT NULL COMMENT '项目主键',

  `lab_id` bigint NOT NULL COMMENT '实验室主键',

  `batch_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '批次名称',

  `batch_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '批次编号',

  `alias` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '别名',

  `batch_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0进行中 1已完成 2已暂停），字典：SMP批次状态',

  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',

  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',

  `titer` decimal(10, 4) NULL DEFAULT NULL COMMENT '结束时填写的Titer',

  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',

  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',

  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',

  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',

  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',

  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',

  `object_version` bigint NOT NULL DEFAULT 1 COMMENT '对象并发版本；迁移基线1，每次领域变更递增',

  `creator_user_id` bigint NULL COMMENT '真实创建用户ID，逻辑关联sys_user；旧身份未知NULL，不按当前用户名猜测',

  `modifier_user_id` bigint NULL COMMENT '最近修改用户ID，旧身份未知NULL',

  `deleted_at` datetime(3) NULL COMMENT '逻辑删除确认时刻UTC；旧未知NULL',

  `deleted_by_user_id` bigint NULL COMMENT '逻辑删除操作者ID，旧未知NULL',

  `facts_status` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'REVIEW' COMMENT 'READY已核准，REVIEW待核验；新业务必须显式READY',

  `m03_live_code` varchar(50) GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN TRIM(`batch_code`) ELSE NULL END) STORED COMMENT '逻辑删除释放编号，历史记录按内部主键保留',

  PRIMARY KEY (`batch_id`) USING BTREE,

  INDEX `idx_res_batch_project`(`project_id` ASC) USING BTREE,

  INDEX `idx_res_batch_lab`(`lab_id` ASC) USING BTREE,

  INDEX `idx_res_batch_status`(`batch_status` ASC) USING BTREE,

  CONSTRAINT `ck_m03_batch_version` CHECK (`object_version` >= 1),

  CONSTRAINT `ck_m03_batch_facts` CHECK (`facts_status` IN ('READY','REVIEW')),

  CONSTRAINT `ck_m03_batch_identity` CHECK (`batch_id` > 0 AND `del_flag` IS NOT NULL AND `del_flag` IN ('0','2') AND CHAR_LENGTH(TRIM(`batch_code`)) > 0),

  INDEX `idx_m03_batch_list` (`project_id`,`del_flag`,`update_time`,`batch_id`),

  UNIQUE INDEX `uk_m03_batch_code` (`project_id`,`m03_live_code`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '批次表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `res_batch_leader` (
`batch_id` bigint NOT NULL COMMENT '批次主键',

  `user_id` bigint NOT NULL COMMENT '负责人用户主键',

  PRIMARY KEY (`batch_id`, `user_id`) USING BTREE,

  INDEX `idx_res_batch_leader_user`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '批次负责人关联表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `res_batch_member` (
`batch_id` bigint NOT NULL COMMENT '批次主键',

  `user_id` bigint NOT NULL COMMENT '用户主键',

  `permission_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'member' COMMENT '权限类型（admin/member/view/share）',

  `expire_date` date NULL DEFAULT NULL COMMENT '权限截止日期',

  `source_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'direct' COMMENT '来源（direct/project_share/group）',

  `grant_type` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'LEGACY' COMMENT 'MEMBER直接成员/SHARE直接分享/LEGACY旧语义待核准；新接口拒绝LEGACY',

  `granted_at` datetime(3) NULL COMMENT '本次直接授权开始时刻UTC；旧记录未知NULL',

  `granted_by_user_id` bigint NULL COMMENT '本次授权操作者ID，旧未知NULL',

  `modified_at` datetime(3) NULL COMMENT '最近改期时刻UTC，旧未知NULL',

  `modified_by_user_id` bigint NULL COMMENT '最近改期操作者ID，旧未知NULL',

  `selection_origin` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'USER手选/DEPARTMENT部门快照/GROUP组快照；旧未知NULL，不形成动态继承',

  `selection_ref` varchar(128) NULL COMMENT '选择来源证据引用，非授权关系主键；可空',

  PRIMARY KEY (`batch_id`, `user_id`, `grant_type`) USING BTREE,

  INDEX `idx_res_batch_member_user`(`user_id` ASC) USING BTREE,

  INDEX `idx_res_batch_member_expire`(`expire_date` ASC) USING BTREE,

  CONSTRAINT `ck_m03_batch_grant_type` CHECK (`grant_type` IN ('MEMBER','SHARE','LEGACY')),

  CONSTRAINT `ck_m03_batch_origin` CHECK (`selection_origin` IS NULL OR `selection_origin` IN ('USER','DEPARTMENT','GROUP')),

  INDEX `idx_m03_batch_grant_user` (`user_id`,`grant_type`,`expire_date`,`batch_id`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '批次成员权限表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `res_culture` (
`culture_id` bigint NOT NULL COMMENT '培养主键',

  `project_id` bigint NOT NULL COMMENT '项目主键',

  `batch_id` bigint NOT NULL COMMENT '批次主键',

  `lab_id` bigint NOT NULL COMMENT '实验室主键',

  `culture_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '培养编号',

  `culture_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '培养名称或别名',

  `culture_mode` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '培养模式（batch/perfusion/normal），字典：SMP培养模式',

  `is_special` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '是否特殊培养（0否 1是）',

  `reactor_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '反应器类型',

  `reactor_id` bigint NULL DEFAULT NULL COMMENT '反应器主键',

  `container_id` bigint NULL DEFAULT NULL COMMENT '培养容器主键',

  `cell_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '细胞类型，字典：ViCell细胞类型',

  `culture_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0进行中 1已完成 2已终止），字典：SMP培养状态',

  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',

  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',

  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',

  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',

  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',

  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',

  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',

  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',

  `object_version` bigint NOT NULL DEFAULT 1 COMMENT '对象并发版本；迁移基线1，每次领域变更递增',

  `creator_user_id` bigint NULL COMMENT '真实创建用户ID，逻辑关联sys_user；旧身份未知NULL，不按当前用户名猜测',

  `modifier_user_id` bigint NULL COMMENT '最近修改用户ID，旧身份未知NULL',

  `deleted_at` datetime(3) NULL COMMENT '逻辑删除确认时刻UTC；旧未知NULL',

  `deleted_by_user_id` bigint NULL COMMENT '逻辑删除操作者ID，旧未知NULL',

  `facts_status` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'REVIEW' COMMENT 'READY已核准，REVIEW待核验；新业务必须显式READY',

  `lifecycle_state` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'DRAFT草稿/NOT_STARTED未开始/RUNNING进行中/EXPIRED已过期/DELAYED已延期/CANCELLED已取消/FINISHED已结束；旧未知NULL',

  `mode_code` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'NORMAL普通/REACTOR反应器；旧culture_mode仅保留原值',

  `device_kind` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'INTEGRATED_REACTOR/CULTURE_CONTAINER/BENCH_CONTROLLER；选中主设备种类',

  `device_id` bigint NULL COMMENT '主设备稳定ID，按device_kind映射M02表，不按名称重绑',

  `planned_start_date` date NULL COMMENT '计划开始业务日Asia/Shanghai；不是实际流程开始时刻',

  `planned_end_date` date NULL COMMENT '计划结束业务日Asia/Shanghai；当天允许结束',

  `planned_duration_days` int NULL COMMENT '包含首尾的自然日数；两日期完整时DATEDIFF+1',

  `plan_version` bigint NOT NULL DEFAULT 0 COMMENT '计划并发版本；无计划基线0，有计划新建1；合法计划变更递增',

  `runtime_version` bigint NOT NULL DEFAULT 0 COMMENT '可信运行事实并发版本；迁移基线0，不重演历史事件',

  `n_marked` tinyint NULL COMMENT 'N阶段外部标识：0否/1是；新建显式0，旧未知NULL，不参与计算',

  `mode_changed_at` datetime(3) NULL COMMENT '普通转反应器的确认时刻UTC；未知NULL',

  `member_setup_state` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'UNKNOWN' COMMENT 'NEVER从未设置/CONFIGURED曾成功设置/UNKNOWN历史待核验；清空不重置',

  `first_workflow_started_at` datetime(3) NULL COMMENT '任意工作流首次可信开启时刻UTC；不是收到事件时刻',

  `start_completed_at` datetime(3) NULL COMMENT '开始培养可信完成时刻UTC；M07提供',

  `end_completed_at` datetime(3) NULL COMMENT '结束培养可信完成时刻UTC；本期仅隔离模拟',

  `cancel_confirmed_at` datetime(3) NULL COMMENT '取消业务可信确认时刻UTC，不等于设备释放',

  `start_delay_at` datetime(3) NULL COMMENT '开始阶段首次延期事实时刻UTC；历史保留，不作为当前原因开关',

  `end_delay_at` datetime(3) NULL COMMENT '结束阶段首次延期事实时刻UTC；历史保留',

  `start_delay_active` tinyint NOT NULL DEFAULT 0 COMMENT '当前开始阶段延期原因0无/1有；Q10消解按合法流程',

  `end_delay_active` tinyint NOT NULL DEFAULT 0 COMMENT '当前结束阶段延期原因0无/1有',

  `runtime_evidence_ref` varchar(128) NULL COMMENT '可信运行核准/事件证据引用；不存设备命令或未经校验payload',

  `m03_live_code` varchar(50) GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' AND (`lifecycle_state` IS NULL OR `lifecycle_state` <> 'CANCELLED') THEN TRIM(`culture_code`) ELSE NULL END) STORED COMMENT '有效占号键；取消或删除释放，未知状态保守占号',

  `runtime_stream_id` varchar(128) NULL DEFAULT NULL COMMENT '当前M07稳定事实流，重启不换ID',
  `runtime_stream_sequence` bigint NULL DEFAULT NULL COMMENT '已生效源序列；未建立为NULL',
  `delay_resolution_json` json NULL DEFAULT NULL COMMENT '开始及结束延期当前消解证据，不覆盖历史首次时间',
  PRIMARY KEY (`culture_id`) USING BTREE,

  INDEX `idx_res_culture_project`(`project_id` ASC) USING BTREE,

  INDEX `idx_res_culture_batch`(`batch_id` ASC) USING BTREE,

  INDEX `idx_res_culture_lab`(`lab_id` ASC) USING BTREE,

  INDEX `idx_res_culture_status`(`culture_status` ASC) USING BTREE,

  INDEX `idx_res_culture_reactor_status`(`reactor_type` ASC, `reactor_id` ASC, `culture_status` ASC, `del_flag` ASC) USING BTREE,

  CONSTRAINT `ck_m03_culture_version` CHECK (`object_version` >= 1),

  CONSTRAINT `ck_m03_culture_facts` CHECK (`facts_status` IN ('READY','REVIEW')),

  CONSTRAINT `ck_m03_culture_identity` CHECK (`culture_id` > 0 AND `del_flag` IS NOT NULL AND `del_flag` IN ('0','2') AND CHAR_LENGTH(TRIM(`culture_code`)) > 0),

  CONSTRAINT `ck_m03_culture_state` CHECK (`lifecycle_state` IS NULL OR `lifecycle_state` IN ('DRAFT','NOT_STARTED','RUNNING','EXPIRED','DELAYED','CANCELLED','FINISHED')),

  CONSTRAINT `ck_m03_culture_mode` CHECK (`mode_code` IS NULL OR `mode_code` IN ('NORMAL','REACTOR')),

  CONSTRAINT `ck_m03_culture_device` CHECK ((`device_kind` IS NULL AND `device_id` IS NULL) OR (`device_kind` IS NOT NULL AND `device_kind` IN ('INTEGRATED_REACTOR','CULTURE_CONTAINER','BENCH_CONTROLLER') AND `device_id` IS NOT NULL AND `device_id` > 0)),

  CONSTRAINT `ck_m03_culture_duration` CHECK ((`planned_duration_days` IS NULL OR `planned_duration_days` >= 1) AND (`planned_start_date` IS NULL OR `planned_end_date` IS NULL OR (`planned_end_date` >= `planned_start_date` AND `planned_duration_days` IS NOT NULL AND `planned_duration_days` = DATEDIFF(`planned_end_date`,`planned_start_date`) + 1))),

  CONSTRAINT `ck_m03_culture_plan_pair` CHECK (NOT ((`planned_start_date` IS NULL) <> (`planned_end_date` IS NULL)) OR `planned_duration_days` IS NULL),

  CONSTRAINT `ck_m03_culture_versions` CHECK (`plan_version` >= 0 AND `runtime_version` >= 0),

  CONSTRAINT `ck_m03_culture_flags` CHECK ((`n_marked` IS NULL OR `n_marked` IN (0,1)) AND `start_delay_active` IN (0,1) AND `end_delay_active` IN (0,1)),

  CONSTRAINT `ck_m03_culture_members` CHECK (`member_setup_state` IN ('NEVER','CONFIGURED','UNKNOWN')),

  CONSTRAINT `ck_m03_culture_ready` CHECK (`facts_status` <> 'READY' OR (`lifecycle_state` IS NOT NULL AND `mode_code` IS NOT NULL AND `device_kind` IS NOT NULL AND `device_id` IS NOT NULL AND `n_marked` IS NOT NULL AND `member_setup_state` <> 'UNKNOWN')),

  CONSTRAINT `ck_m03_culture_scheduled` CHECK (`facts_status` <> 'READY' OR `lifecycle_state` NOT IN ('NOT_STARTED','RUNNING','EXPIRED','DELAYED') OR (`planned_start_date` IS NOT NULL AND `planned_end_date` IS NOT NULL)),

  CONSTRAINT `ck_m03_culture_draft` CHECK (`facts_status` <> 'READY' OR `lifecycle_state` <> 'DRAFT' OR `planned_start_date` IS NULL OR `planned_end_date` IS NULL),

  CONSTRAINT `ck_m03_culture_runtime` CHECK (`facts_status` <> 'READY' OR ((`lifecycle_state` <> 'RUNNING' OR `first_workflow_started_at` IS NOT NULL) AND (`lifecycle_state` <> 'FINISHED' OR `end_completed_at` IS NOT NULL) AND (`lifecycle_state` <> 'CANCELLED' OR `cancel_confirmed_at` IS NOT NULL) AND (`lifecycle_state` <> 'DELAYED' OR (`first_workflow_started_at` IS NOT NULL AND (`start_delay_active` = 1 OR `end_delay_active` = 1))) AND (`lifecycle_state` NOT IN ('DRAFT','NOT_STARTED','EXPIRED') OR `first_workflow_started_at` IS NULL))),

  UNIQUE INDEX `uk_m03_culture_live_code` (`m03_live_code`),

  INDEX `idx_m03_culture_lab_state` (`lab_id`,`del_flag`,`lifecycle_state`,`batch_id`,`project_id`),

  INDEX `idx_m03_culture_batch_list` (`batch_id`,`del_flag`,`update_time`,`culture_id`),

  INDEX `idx_m03_culture_device` (`device_kind`,`device_id`,`del_flag`),

  INDEX `idx_m03_culture_start_due` (`facts_status`,`del_flag`,`lifecycle_state`,`planned_start_date`),

  INDEX `idx_m03_culture_end_due` (`facts_status`,`del_flag`,`lifecycle_state`,`planned_end_date`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '培养表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `res_culture_leader` (
`culture_id` bigint NOT NULL COMMENT '培养主键',

  `user_id` bigint NOT NULL COMMENT '负责人用户主键',

  PRIMARY KEY (`culture_id`, `user_id`) USING BTREE,

  INDEX `idx_res_culture_leader_user`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '培养负责人关联表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `res_culture_member` (
`culture_id` bigint NOT NULL COMMENT '培养主键',

  `user_id` bigint NOT NULL COMMENT '用户主键',

  `permission_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'member' COMMENT '权限类型（admin/member/view/share）',

  `expire_date` date NULL DEFAULT NULL COMMENT '权限截止日期',

  `source_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'direct' COMMENT '来源（direct/project_share/batch_share/group）',

  `grant_type` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'LEGACY' COMMENT 'MEMBER直接成员/SHARE直接分享/LEGACY旧语义待核准；新接口拒绝LEGACY',

  `granted_at` datetime(3) NULL COMMENT '本次直接授权开始时刻UTC；旧记录未知NULL',

  `granted_by_user_id` bigint NULL COMMENT '本次授权操作者ID，旧未知NULL',

  `modified_at` datetime(3) NULL COMMENT '最近改期时刻UTC，旧未知NULL',

  `modified_by_user_id` bigint NULL COMMENT '最近改期操作者ID，旧未知NULL',

  `selection_origin` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'USER手选/DEPARTMENT部门快照/GROUP组快照；旧未知NULL，不形成动态继承',

  `selection_ref` varchar(128) NULL COMMENT '选择来源证据引用，非授权关系主键；可空',

  PRIMARY KEY (`culture_id`, `user_id`, `grant_type`) USING BTREE,

  INDEX `idx_res_culture_member_user`(`user_id` ASC) USING BTREE,

  INDEX `idx_res_culture_member_expire`(`expire_date` ASC) USING BTREE,

  CONSTRAINT `ck_m03_culture_grant_type` CHECK (`grant_type` IN ('MEMBER','SHARE','LEGACY')),

  CONSTRAINT `ck_m03_culture_origin` CHECK (`selection_origin` IS NULL OR `selection_origin` IN ('USER','DEPARTMENT','GROUP')),

  INDEX `idx_m03_culture_grant_user` (`user_id`,`grant_type`,`expire_date`,`culture_id`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '培养成员权限表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `res_culture_occupancy` (
`occupancy_id` bigint NOT NULL COMMENT '一次取得主设备占用的不可复用主键，应用生成',

  `culture_id` bigint NOT NULL COMMENT '所属培养ID，逻辑关联res_culture',

  `device_kind` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'INTEGRATED_REACTOR/CULTURE_CONTAINER/BENCH_CONTROLLER',

  `device_id` bigint NOT NULL COMMENT 'M02对应表主键；身份与kind共同组成',

  `lab_id` bigint NOT NULL COMMENT '取得占用时实验室ID，须与培养及设备一致',

  `occupancy_state` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'RESERVED预约/RUNNING运行/RELEASE_PENDING待核验释放/RELEASED已确认释放',

  `acquired_at` datetime(3) NOT NULL COMMENT '取得占用的确认时刻UTC，不是计划开始日',

  `released_at` datetime(3) NULL COMMENT '已确认释放时刻UTC，其他状态NULL',

  `release_reason` varchar(24) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'EXPIRED/WITHDRAW/DELETE/REBOOK_REPLACED/FINISHED/CANCELLED；未释放NULL',

  `release_evidence_ref` varchar(128) NULL COMMENT '领域事务/可信运行释放凭据引用，释放必填',

  `created_request_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '取得占用的管理请求ID或迁移核准批号',

  `object_version` bigint NOT NULL COMMENT '占用事实版本，初始1；条件释放防止误放新预约',

  `active_slot` tinyint GENERATED ALWAYS AS (CASE WHEN `occupancy_state` <> 'RELEASED' THEN 1 ELSE NULL END) STORED COMMENT '非释放状态均占用唯一槽位；允许多条已释放历史',

  `resource_release_snapshot` json NULL DEFAULT NULL COMMENT 'M07全部附属资源释放证据快照',
  `release_source_event_id` bigint NULL DEFAULT NULL COMMENT '已应用M03运行收件事件ID',
  PRIMARY KEY (`occupancy_id`),

  UNIQUE INDEX `uk_m03_occupancy_device` (`device_kind`,`device_id`,`active_slot`),

  UNIQUE INDEX `uk_m03_occupancy_culture` (`culture_id`,`active_slot`),

  INDEX `idx_m03_occupancy_lab` (`lab_id`,`occupancy_state`,`culture_id`),

  CONSTRAINT `ck_m03_occupancy_kind` CHECK (`device_kind` IN ('INTEGRATED_REACTOR','CULTURE_CONTAINER','BENCH_CONTROLLER')),

  CONSTRAINT `ck_m03_occupancy_state` CHECK (`occupancy_state` IN ('RESERVED','RUNNING','RELEASE_PENDING','RELEASED')),

  CONSTRAINT `ck_m03_occupancy_identity` CHECK (`occupancy_id` > 0 AND `culture_id` > 0 AND `device_id` > 0 AND `lab_id` > 0 AND `object_version` >= 1),

  CONSTRAINT `ck_m03_occupancy_release` CHECK ((`occupancy_state` = 'RELEASED' AND `released_at` IS NOT NULL AND `released_at` >= `acquired_at` AND `release_reason` IS NOT NULL AND `release_reason` IN ('EXPIRED','WITHDRAW','DELETE','REBOOK_REPLACED','FINISHED','CANCELLED') AND `release_evidence_ref` IS NOT NULL AND CHAR_LENGTH(`release_evidence_ref`) > 0) OR (`occupancy_state` <> 'RELEASED' AND `released_at` IS NULL AND `release_reason` IS NULL AND `release_evidence_ref` IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M03主设备占用及释放历史；不是按日期排程';

CREATE TABLE `res_culture_notice_outbox` (
`event_id` bigint NOT NULL COMMENT '不可复用事件ID，应用生成，M09按此去重',

  `culture_id` bigint NOT NULL COMMENT '培养ID，逻辑关联res_culture，删除后保留',

  `event_type` varchar(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'N_MARK_CHANGED/DELAY_CHANGED；本表不接收设备控制事件',

  `culture_version` bigint NOT NULL COMMENT '产生事件后的培养object_version',

  `occurred_at` datetime(3) NOT NULL COMMENT '业务事实时刻UTC',

  `actor_user_id` bigint NULL COMMENT '用户操作者ID，系统判断NULL并由事件类型辨识',

  `request_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '管理请求或可信系统事件去重标识',

  `old_value` json NOT NULL COMMENT '变化前：N标记{marked:boolean}；延期{state:string,startActive:boolean,endActive:boolean}',

  `new_value` json NOT NULL COMMENT '变化后，同old_value闭合结构；无用户列表或秘密',

  `delivery_state` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'PENDING待交付/LEASED投递中/DELIVERED已被M09幂等接收',

  `attempt_count` int NOT NULL COMMENT '投递尝试次数，初始0',

  `next_attempt_at` datetime(3) NOT NULL COMMENT '下次可尝试时间UTC，初始业务提交时间',

  `lease_token` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '投递租用令牌，防止旧工作者覆盖新结果',

  `lease_until` datetime(3) NULL COMMENT '投递租约到期UTC，过期允许恢复',

  `delivered_at` datetime(3) NULL COMMENT 'M09确认接收时刻UTC；不等于用户阅读',

  `last_error_code` varchar(64) NULL COMMENT '最近脱敏错误码，不保存异常栈或远端敏感响应',

  PRIMARY KEY (`event_id`),

  UNIQUE INDEX `uk_m03_notice_fact` (`culture_id`,`event_type`,`culture_version`),

  INDEX `idx_m03_notice_dispatch` (`delivery_state`,`next_attempt_at`,`event_id`),

  CONSTRAINT `ck_m03_notice_type` CHECK (`event_type` IN ('N_MARK_CHANGED','DELAY_CHANGED')),

  CONSTRAINT `ck_m03_notice_state` CHECK (`delivery_state` IN ('PENDING','LEASED','DELIVERED') AND `attempt_count` >= 0 AND `culture_version` >= 1),

  CONSTRAINT `ck_m03_notice_lease` CHECK ((`delivery_state` = 'LEASED' AND `lease_token` IS NOT NULL AND `lease_until` IS NOT NULL AND `delivered_at` IS NULL) OR (`delivery_state` = 'PENDING' AND `lease_token` IS NULL AND `lease_until` IS NULL AND `delivered_at` IS NULL) OR (`delivery_state` = 'DELIVERED' AND `lease_token` IS NULL AND `lease_until` IS NULL AND `delivered_at` IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M03领域通知提交箱；M09拥有接收人与实际投递';

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

CREATE TABLE `res_culture_change_candidate` (
  `candidate_id` BIGINT NOT NULL COMMENT '培养基础变更候选',
  `culture_id` BIGINT NOT NULL COMMENT '培养',
  `scene_code` VARCHAR(32) NOT NULL,
  `change_key` VARCHAR(160) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `expected_target_version` BIGINT UNSIGNED NOT NULL,
  `before_snapshot` JSON NOT NULL COMMENT '固定原身份日期模式及设备版本',
  `after_snapshot` JSON NOT NULL COMMENT '受控基础字段候选',
  `candidate_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '候选摘要',
  `state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'PREPARED' COMMENT 'PREPARED/PENDING/APPLIED/DISCARDED/CONFLICT/UNKNOWN',
  `approval_id` BIGINT NULL COMMENT 'M06审批；DIRECT空',
  `policy_evidence` JSON NOT NULL COMMENT '固定政策与免审批依据',
  `reason` VARCHAR(500) NULL,
  `source_request_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '用户及原UUID',
  `source_request_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '请求内容',
  `decision_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '固定最终决定键',
  `decision_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '决定正文',
  `application_receipt` JSON NULL COMMENT '持久生效或封禁回执',
  `created_by` BIGINT NOT NULL COMMENT '原申请人',
  `created_at` DATETIME(3) NOT NULL COMMENT '候选提交；UTC',
  `applied_at` DATETIME(3) NULL COMMENT '实际应用；UTC',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'CAS版本',
  `active_culture_id` BIGINT GENERATED ALWAYS AS (CASE WHEN state IN ('PREPARED','PENDING','UNKNOWN') THEN culture_id ELSE NULL END) STORED,
  PRIMARY KEY (`candidate_id`),
  UNIQUE KEY `uk_m03_close_active_change` (`active_culture_id`),
  UNIQUE KEY `uk_m03_close_source` (`source_request_key`),
  UNIQUE KEY `uk_m03_close_decision` (`decision_key`),
  UNIQUE KEY `uk_m03_close_approval` (`approval_id`),
  CONSTRAINT `ck_m03_close_change_state` CHECK (state IN ('PREPARED','PENDING','APPLIED','DISCARDED','CONFLICT','UNKNOWN')),
  CONSTRAINT `ck_m03_close_change_scene` CHECK (scene_code IN ('M06_SC027','M06_SC028','M06_SC029','M03_DEVICE_CHANGE')),
  CONSTRAINT `ck_m03_close_change_json` CHECK (JSON_TYPE(before_snapshot)='OBJECT' AND JSON_TYPE(after_snapshot)='OBJECT' AND JSON_TYPE(policy_evidence)='OBJECT'),
  CONSTRAINT `ck_m03_close_change_applied` CHECK (state<>'APPLIED' OR (application_receipt IS NOT NULL AND applied_at IS NOT NULL AND decision_key IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='res_culture_change_candidate 当前设计目标';
