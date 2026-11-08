-- M03 SQL设计稿；2026-09-09；未在数据库执行。MySQL 8.0.16+，须在实际小版本隔离演练。
-- 先读主设计第5/6节。逐阶段执行，错误立即停止；DDL隐式提交，不能整包盲跑。
-- 旧datetime与M01审计保持上海业务时区；明确标UTC的新列仅写UTC值。
SET NAMES utf8mb4;
SET SESSION time_zone = '+08:00';

-- 维护窗口停止所有M03/M02相关写及运行消费者。先完成受保护的数据库备份；以下同库副本不替代灾备。
-- 固定一次性名字，已存在即报错停止；禁止IF NOT EXISTS掩盖旧备份。DDL逐条提交。
CREATE TABLE `m03_bak_20260909_res_project` LIKE `res_project`;
INSERT INTO `m03_bak_20260909_res_project` SELECT * FROM `res_project`;
CREATE TABLE `m03_bak_20260909_res_project_leader` LIKE `res_project_leader`;
INSERT INTO `m03_bak_20260909_res_project_leader` SELECT * FROM `res_project_leader`;
CREATE TABLE `m03_bak_20260909_res_project_lab` LIKE `res_project_lab`;
INSERT INTO `m03_bak_20260909_res_project_lab` SELECT * FROM `res_project_lab`;
CREATE TABLE `m03_bak_20260909_res_project_tag` LIKE `res_project_tag`;
INSERT INTO `m03_bak_20260909_res_project_tag` SELECT * FROM `res_project_tag`;
CREATE TABLE `m03_bak_20260909_res_project_member` LIKE `res_project_member`;
INSERT INTO `m03_bak_20260909_res_project_member` SELECT * FROM `res_project_member`;
CREATE TABLE `m03_bak_20260909_res_batch` LIKE `res_batch`;
INSERT INTO `m03_bak_20260909_res_batch` SELECT * FROM `res_batch`;
CREATE TABLE `m03_bak_20260909_res_batch_leader` LIKE `res_batch_leader`;
INSERT INTO `m03_bak_20260909_res_batch_leader` SELECT * FROM `res_batch_leader`;
CREATE TABLE `m03_bak_20260909_res_batch_member` LIKE `res_batch_member`;
INSERT INTO `m03_bak_20260909_res_batch_member` SELECT * FROM `res_batch_member`;
CREATE TABLE `m03_bak_20260909_res_culture` LIKE `res_culture`;
INSERT INTO `m03_bak_20260909_res_culture` SELECT * FROM `res_culture`;
CREATE TABLE `m03_bak_20260909_res_culture_leader` LIKE `res_culture_leader`;
INSERT INTO `m03_bak_20260909_res_culture_leader` SELECT * FROM `res_culture_leader`;
CREATE TABLE `m03_bak_20260909_res_culture_member` LIKE `res_culture_member`;
INSERT INTO `m03_bak_20260909_res_culture_member` SELECT * FROM `res_culture_member`;

ALTER TABLE `res_project`
  ADD COLUMN `object_version` bigint NOT NULL DEFAULT 1 COMMENT '对象并发版本；迁移基线1，每次领域变更递增',
  ADD COLUMN `creator_user_id` bigint NULL COMMENT '真实创建用户ID，逻辑关联sys_user；旧身份未知NULL，不按当前用户名猜测',
  ADD COLUMN `modifier_user_id` bigint NULL COMMENT '最近修改用户ID，旧身份未知NULL',
  ADD COLUMN `deleted_at` datetime(3) NULL COMMENT '逻辑删除确认时刻UTC；旧未知NULL',
  ADD COLUMN `deleted_by_user_id` bigint NULL COMMENT '逻辑删除操作者ID，旧未知NULL',
  ADD COLUMN `facts_status` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'REVIEW' COMMENT 'READY已核准，REVIEW待核验；新业务必须显式READY';

ALTER TABLE `res_batch`
  ADD COLUMN `object_version` bigint NOT NULL DEFAULT 1 COMMENT '对象并发版本；迁移基线1，每次领域变更递增',
  ADD COLUMN `creator_user_id` bigint NULL COMMENT '真实创建用户ID，逻辑关联sys_user；旧身份未知NULL，不按当前用户名猜测',
  ADD COLUMN `modifier_user_id` bigint NULL COMMENT '最近修改用户ID，旧身份未知NULL',
  ADD COLUMN `deleted_at` datetime(3) NULL COMMENT '逻辑删除确认时刻UTC；旧未知NULL',
  ADD COLUMN `deleted_by_user_id` bigint NULL COMMENT '逻辑删除操作者ID，旧未知NULL',
  ADD COLUMN `facts_status` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'REVIEW' COMMENT 'READY已核准，REVIEW待核验；新业务必须显式READY';

ALTER TABLE `res_culture`
  ADD COLUMN `object_version` bigint NOT NULL DEFAULT 1 COMMENT '对象并发版本；迁移基线1，每次领域变更递增',
  ADD COLUMN `creator_user_id` bigint NULL COMMENT '真实创建用户ID，逻辑关联sys_user；旧身份未知NULL，不按当前用户名猜测',
  ADD COLUMN `modifier_user_id` bigint NULL COMMENT '最近修改用户ID，旧身份未知NULL',
  ADD COLUMN `deleted_at` datetime(3) NULL COMMENT '逻辑删除确认时刻UTC；旧未知NULL',
  ADD COLUMN `deleted_by_user_id` bigint NULL COMMENT '逻辑删除操作者ID，旧未知NULL',
  ADD COLUMN `facts_status` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'REVIEW' COMMENT 'READY已核准，REVIEW待核验；新业务必须显式READY',
  ADD COLUMN `lifecycle_state` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'DRAFT草稿/NOT_STARTED未开始/RUNNING进行中/EXPIRED已过期/DELAYED已延期/CANCELLED已取消/FINISHED已结束；旧未知NULL',
  ADD COLUMN `mode_code` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'NORMAL普通/REACTOR反应器；旧culture_mode仅保留原值',
  ADD COLUMN `device_kind` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'INTEGRATED_REACTOR/CULTURE_CONTAINER/BENCH_CONTROLLER；选中主设备种类',
  ADD COLUMN `device_id` bigint NULL COMMENT '主设备稳定ID，按device_kind映射M02表，不按名称重绑',
  ADD COLUMN `planned_start_date` date NULL COMMENT '计划开始业务日Asia/Shanghai；不是实际流程开始时刻',
  ADD COLUMN `planned_end_date` date NULL COMMENT '计划结束业务日Asia/Shanghai；当天允许结束',
  ADD COLUMN `planned_duration_days` int NULL COMMENT '包含首尾的自然日数；两日期完整时DATEDIFF+1',
  ADD COLUMN `plan_version` bigint NOT NULL DEFAULT 0 COMMENT '计划并发版本；无计划基线0，有计划新建1；合法计划变更递增',
  ADD COLUMN `runtime_version` bigint NOT NULL DEFAULT 0 COMMENT '可信运行事实并发版本；迁移基线0，不重演历史事件',
  ADD COLUMN `n_marked` tinyint NULL COMMENT 'N阶段外部标识：0否/1是；新建显式0，旧未知NULL，不参与计算',
  ADD COLUMN `mode_changed_at` datetime(3) NULL COMMENT '普通转反应器的确认时刻UTC；未知NULL',
  ADD COLUMN `member_setup_state` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'UNKNOWN' COMMENT 'NEVER从未设置/CONFIGURED曾成功设置/UNKNOWN历史待核验；清空不重置',
  ADD COLUMN `first_workflow_started_at` datetime(3) NULL COMMENT '任意工作流首次可信开启时刻UTC；不是收到事件时刻',
  ADD COLUMN `start_completed_at` datetime(3) NULL COMMENT '开始培养可信完成时刻UTC；M07提供',
  ADD COLUMN `end_completed_at` datetime(3) NULL COMMENT '结束培养可信完成时刻UTC；本期仅隔离模拟',
  ADD COLUMN `cancel_confirmed_at` datetime(3) NULL COMMENT '取消业务可信确认时刻UTC，不等于设备释放',
  ADD COLUMN `start_delay_at` datetime(3) NULL COMMENT '开始阶段首次延期事实时刻UTC；历史保留，不作为当前原因开关',
  ADD COLUMN `end_delay_at` datetime(3) NULL COMMENT '结束阶段首次延期事实时刻UTC；历史保留',
  ADD COLUMN `start_delay_active` tinyint NOT NULL DEFAULT 0 COMMENT '当前开始阶段延期原因0无/1有；Q10消解按合法流程',
  ADD COLUMN `end_delay_active` tinyint NOT NULL DEFAULT 0 COMMENT '当前结束阶段延期原因0无/1有',
  ADD COLUMN `runtime_evidence_ref` varchar(128) NULL COMMENT '可信运行核准/事件证据引用；不存设备命令或未经校验payload';

ALTER TABLE `res_project_member`
  ADD COLUMN `grant_type` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'LEGACY' COMMENT 'MEMBER直接成员/SHARE直接分享/LEGACY旧语义待核准；新接口拒绝LEGACY',
  ADD COLUMN `granted_at` datetime(3) NULL COMMENT '本次直接授权开始时刻UTC；旧记录未知NULL',
  ADD COLUMN `granted_by_user_id` bigint NULL COMMENT '本次授权操作者ID，旧未知NULL',
  ADD COLUMN `modified_at` datetime(3) NULL COMMENT '最近改期时刻UTC，旧未知NULL',
  ADD COLUMN `modified_by_user_id` bigint NULL COMMENT '最近改期操作者ID，旧未知NULL',
  ADD COLUMN `selection_origin` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'USER手选/DEPARTMENT部门快照/GROUP组快照；旧未知NULL，不形成动态继承',
  ADD COLUMN `selection_ref` varchar(128) NULL COMMENT '选择来源证据引用，非授权关系主键；可空',
  DROP PRIMARY KEY,
  ADD PRIMARY KEY (`project_id`,`user_id`,`grant_type`);

ALTER TABLE `res_batch_member`
  ADD COLUMN `grant_type` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'LEGACY' COMMENT 'MEMBER直接成员/SHARE直接分享/LEGACY旧语义待核准；新接口拒绝LEGACY',
  ADD COLUMN `granted_at` datetime(3) NULL COMMENT '本次直接授权开始时刻UTC；旧记录未知NULL',
  ADD COLUMN `granted_by_user_id` bigint NULL COMMENT '本次授权操作者ID，旧未知NULL',
  ADD COLUMN `modified_at` datetime(3) NULL COMMENT '最近改期时刻UTC，旧未知NULL',
  ADD COLUMN `modified_by_user_id` bigint NULL COMMENT '最近改期操作者ID，旧未知NULL',
  ADD COLUMN `selection_origin` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'USER手选/DEPARTMENT部门快照/GROUP组快照；旧未知NULL，不形成动态继承',
  ADD COLUMN `selection_ref` varchar(128) NULL COMMENT '选择来源证据引用，非授权关系主键；可空',
  DROP PRIMARY KEY,
  ADD PRIMARY KEY (`batch_id`,`user_id`,`grant_type`);

ALTER TABLE `res_culture_member`
  ADD COLUMN `grant_type` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'LEGACY' COMMENT 'MEMBER直接成员/SHARE直接分享/LEGACY旧语义待核准；新接口拒绝LEGACY',
  ADD COLUMN `granted_at` datetime(3) NULL COMMENT '本次直接授权开始时刻UTC；旧记录未知NULL',
  ADD COLUMN `granted_by_user_id` bigint NULL COMMENT '本次授权操作者ID，旧未知NULL',
  ADD COLUMN `modified_at` datetime(3) NULL COMMENT '最近改期时刻UTC，旧未知NULL',
  ADD COLUMN `modified_by_user_id` bigint NULL COMMENT '最近改期操作者ID，旧未知NULL',
  ADD COLUMN `selection_origin` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'USER手选/DEPARTMENT部门快照/GROUP组快照；旧未知NULL，不形成动态继承',
  ADD COLUMN `selection_ref` varchar(128) NULL COMMENT '选择来源证据引用，非授权关系主键；可空',
  DROP PRIMARY KEY,
  ADD PRIMARY KEY (`culture_id`,`user_id`,`grant_type`);

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

CREATE TABLE `m03_migration_run` (
  `run_key` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '固定M03_20260909',
  `phase` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'EXPANDED/BACKFILLED；不是运行验收标记',
  `system_revision_before` bigint NOT NULL COMMENT '迁移前SYSTEM版本',
  `system_revision_after` bigint NULL COMMENT '回填后版本，回退必须匹配且写仍暂停',
  `source_file_sha256` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '设计依据文件哈希，不冒充现场库哈希',
  PRIMARY KEY (`run_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M03单次迁移过程记录，不参与业务';
INSERT INTO m03_migration_run (run_key,phase,system_revision_before,system_revision_after,source_file_sha256) SELECT 'M03_20260909','EXPANDED',revision,NULL,'B3F185BD23B399CAC0E1B12593F9F68D0E42CDE7C457EDD3B2F472A7286F4366' FROM sys_management_revision WHERE scope_key='SYSTEM';
