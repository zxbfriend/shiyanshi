-- M03 SQL设计稿；2026-09-09；未在数据库执行。MySQL 8.0.16+，须在实际小版本隔离演练。
-- 先读主设计第5/6节。逐阶段执行，错误立即停止；DDL隐式提交，不能整包盲跑。
-- 旧datetime与M01审计保持上海业务时区；明确标UTC的新列仅写UTC值。
SET NAMES utf8mb4;
SET SESSION time_zone = '+08:00';

-- 迁移专用空审核表；由核准数据导入，禁止浏览器业务接口写入。未填齐则04明确停止。
CREATE TABLE `m03_migration_object_review` (
`target_type` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'PROJECT/BATCH/CULTURE',
  `target_id` bigint NOT NULL COMMENT '原对象ID',
  `creator_user_id` bigint NOT NULL COMMENT '核准真实创建人ID，必须有证据，不按当前用户名自动认领',
  `source_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '基线全列JSON_ARRAY的SHA256，01/本文件末尾查询取得',
  `reviewer_user_id` bigint NOT NULL COMMENT '核准人ID',
  `reviewed_at` datetime(3) NOT NULL COMMENT '核准时刻UTC',
  `evidence_ref` varchar(128) NOT NULL COMMENT '受保护核准证据引用',
  PRIMARY KEY (`target_type`,`target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M03迁移审核输入；切换后只读保留，不是运行权限主表';

CREATE TABLE `m03_migration_culture_review` (
`culture_id` bigint NOT NULL COMMENT '原培养ID',
  `lifecycle_state` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '核准目标七态',
  `mode_code` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'NORMAL/REACTOR',
  `device_kind` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'INTEGRATED_REACTOR/CULTURE_CONTAINER/BENCH_CONTROLLER',
  `device_id` bigint NOT NULL COMMENT '核准真实设备ID，不能按名称替换',
  `planned_start_date` date NULL COMMENT '核准计划开始日，不自动DATE旧datetime',
  `planned_end_date` date NULL COMMENT '核准计划结束日',
  `planned_duration_days` int NULL COMMENT '包含首尾自然日数',
  `n_marked` tinyint NOT NULL COMMENT '核准N标记0/1，不将旧is_special直接视为N',
  `member_setup_state` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'NEVER/CONFIGURED，不能仅当前无成员推断NEVER',
  `first_workflow_started_at` datetime(3) NULL COMMENT '已核准可信首次开启时刻UTC',
  `start_completed_at` datetime(3) NULL COMMENT '已核准开始培养完成UTC',
  `end_completed_at` datetime(3) NULL COMMENT '已核准结束培养完成UTC',
  `cancel_confirmed_at` datetime(3) NULL COMMENT '已核准取消UTC',
  `start_delay_at` datetime(3) NULL COMMENT '历史开始延期UTC',
  `end_delay_at` datetime(3) NULL COMMENT '历史结束延期UTC',
  `start_delay_active` tinyint NOT NULL COMMENT '当前原因0/1',
  `end_delay_active` tinyint NOT NULL COMMENT '当前原因0/1',
  `occupancy_state` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'NONE无当前占用/RESERVED/RUNNING/RELEASE_PENDING',
  `occupancy_id` bigint NULL COMMENT '有占用时核准唯一ID，应用预分配',
  `occupancy_acquired_at` datetime(3) NULL COMMENT '有占用时真实取得时刻UTC，不知道则不能核准',
  `source_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '原培养全部基线列指纹',
  `reviewer_user_id` bigint NOT NULL COMMENT '核准人ID',
  `reviewed_at` datetime(3) NOT NULL COMMENT '核准时刻UTC',
  `evidence_ref` varchar(128) NOT NULL COMMENT '状态、计划和释放/占用核准证据引用',
  PRIMARY KEY (`culture_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M03迁移审核输入；切换后只读保留，不是运行权限主表';

CREATE TABLE `m03_migration_grant_review` (
`target_type` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'PROJECT/BATCH/CULTURE',
  `target_id` bigint NOT NULL COMMENT '原对象ID',
  `user_id` bigint NOT NULL COMMENT '原关联用户ID',
  `decision` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'MEMBER/SHARE核准直接来源，INHERITED核准派生，RETIRED核准失效；同原行可核准两个直接类型',
  `expire_date` date NULL COMMENT '核准单个来源的截止日；不能取多来源最大日期',
  `granted_at` datetime(3) NULL COMMENT '已知授权发生UTC，未知NULL',
  `source_target_type` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'INHERITED时PROJECT/BATCH，其余NULL',
  `source_target_id` bigint NULL COMMENT 'INHERITED时核准实际祖先对象ID，其余NULL',
  `source_grant_type` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'INHERITED时MEMBER/SHARE/CREATOR/LEADER，其余NULL',
  `source_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '原成员表完整行指纹',
  `reviewer_user_id` bigint NOT NULL COMMENT '核准人ID',
  `reviewed_at` datetime(3) NOT NULL COMMENT '核准时刻UTC',
  `evidence_ref` varchar(128) NOT NULL COMMENT '原权限类型/继承来源核准依据',
  PRIMARY KEY (`target_type`,`target_id`,`user_id`,`decision`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M03迁移审核输入；切换后只读保留，不是运行权限主表';

-- 以下只读取得每条旧记录指纹及稳定ID，不输出完整业务字段。审核导入必须据受保护原始证据判断。
SELECT 'PROJECT' AS target_type,t.project_id AS target_id,SHA2(CAST(JSON_ARRAY(t.`project_id`,t.`project_name`,t.`project_code`,t.`dept_id`,t.`project_status`,t.`start_date`,t.`end_date`,t.`del_flag`,t.`create_by`,t.`create_time`,t.`update_by`,t.`update_time`,t.`remark`) AS CHAR CHARACTER SET utf8mb4),256) AS source_hash FROM `res_project` t;
SELECT 'PROJECT' AS target_type,t.project_id AS target_id,t.user_id,SHA2(CAST(JSON_ARRAY(t.`project_id`,t.`user_id`,t.`permission_type`,t.`expire_date`,t.`source_type`,t.`joined_time`) AS CHAR CHARACTER SET utf8mb4),256) AS source_hash FROM `m03_bak_20260909_res_project_member` t;
SELECT 'BATCH' AS target_type,t.batch_id AS target_id,SHA2(CAST(JSON_ARRAY(t.`batch_id`,t.`project_id`,t.`lab_id`,t.`batch_name`,t.`batch_code`,t.`alias`,t.`batch_status`,t.`start_time`,t.`end_time`,t.`titer`,t.`del_flag`,t.`create_by`,t.`create_time`,t.`update_by`,t.`update_time`,t.`remark`) AS CHAR CHARACTER SET utf8mb4),256) AS source_hash FROM `res_batch` t;
SELECT 'BATCH' AS target_type,t.batch_id AS target_id,t.user_id,SHA2(CAST(JSON_ARRAY(t.`batch_id`,t.`user_id`,t.`permission_type`,t.`expire_date`,t.`source_type`) AS CHAR CHARACTER SET utf8mb4),256) AS source_hash FROM `m03_bak_20260909_res_batch_member` t;
SELECT 'CULTURE' AS target_type,t.culture_id AS target_id,SHA2(CAST(JSON_ARRAY(t.`culture_id`,t.`project_id`,t.`batch_id`,t.`lab_id`,t.`culture_code`,t.`culture_name`,t.`culture_mode`,t.`is_special`,t.`reactor_type`,t.`reactor_id`,t.`container_id`,t.`cell_type`,t.`culture_status`,t.`start_time`,t.`end_time`,t.`del_flag`,t.`create_by`,t.`create_time`,t.`update_by`,t.`update_time`,t.`remark`) AS CHAR CHARACTER SET utf8mb4),256) AS source_hash FROM `res_culture` t;
SELECT 'CULTURE' AS target_type,t.culture_id AS target_id,t.user_id,SHA2(CAST(JSON_ARRAY(t.`culture_id`,t.`user_id`,t.`permission_type`,t.`expire_date`,t.`source_type`) AS CHAR CHARACTER SET utf8mb4),256) AS source_hash FROM `m03_bak_20260909_res_culture_member` t;
