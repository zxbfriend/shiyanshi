-- M03 SQL设计稿；2026-09-09；未在数据库执行。MySQL 8.0.16+，须在实际小版本隔离演练。
-- 先读主设计第5/6节。逐阶段执行，错误立即停止；DDL隐式提交，不能整包盲跑。
-- 旧datetime与M01审计保持上海业务时区；明确标UTC的新列仅写UTC值。
SET NAMES utf8mb4;
SET SESSION time_zone = '+08:00';

-- 回填完成、相关写仍停止；先检查，再逐表替换唯一键。每个ALTER单独提交，部分失败不得重跑整个文件。
DELIMITER $$
CREATE PROCEDURE m03_assert_constraints_20260909()
BEGIN
  IF EXISTS (SELECT 1 WHERE NOT EXISTS (SELECT 1 FROM m03_migration_run WHERE run_key='M03_20260909' AND phase='BACKFILLED')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Backfill not complete';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_run r JOIN sys_management_revision s ON s.scope_key='SYSTEM' WHERE r.run_key='M03_20260909' AND r.system_revision_after<>s.revision) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='SYSTEM changed before constraint switch';
  END IF;
  IF EXISTS (SELECT 1 FROM res_project WHERE del_flag='0' AND (facts_status<>'READY' OR creator_user_id IS NULL)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='project_unreviewed_active';
  END IF;
  IF EXISTS (SELECT 1 FROM res_project_member r JOIN res_project t ON t.project_id=r.project_id WHERE t.del_flag='0' AND r.grant_type='LEGACY') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='project_legacy_active_grant';
  END IF;
  IF EXISTS (SELECT 1 FROM res_project WHERE del_flag='0' GROUP BY TRIM(project_code) HAVING COUNT(*)>1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='project_duplicate_code';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_grant_review r LEFT JOIN res_project_member t ON t.project_id=r.target_id AND t.user_id=r.user_id AND t.grant_type=r.decision WHERE r.target_type='PROJECT' AND r.decision IN ('MEMBER','SHARE') AND (t.user_id IS NULL OR NOT (t.expire_date <=> r.expire_date) OR NOT (t.granted_at <=> r.granted_at))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='project_grant_review_result';
  END IF;
  IF EXISTS (SELECT 1 WHERE (SELECT COUNT(*) FROM res_project_member) <> ((SELECT COUNT(*) FROM m03_bak_20260909_res_project_member b WHERE NOT EXISTS (SELECT 1 FROM m03_migration_grant_review r WHERE r.target_type='PROJECT' AND r.target_id=b.project_id AND r.user_id=b.user_id))+(SELECT COUNT(*) FROM m03_migration_grant_review r WHERE r.target_type='PROJECT' AND r.decision IN ('MEMBER','SHARE')))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='project_grant_count';
  END IF;
  IF EXISTS (SELECT 1 FROM res_batch WHERE del_flag='0' AND (facts_status<>'READY' OR creator_user_id IS NULL)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='batch_unreviewed_active';
  END IF;
  IF EXISTS (SELECT 1 FROM res_batch_member r JOIN res_batch t ON t.batch_id=r.batch_id WHERE t.del_flag='0' AND r.grant_type='LEGACY') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='batch_legacy_active_grant';
  END IF;
  IF EXISTS (SELECT 1 FROM res_batch WHERE del_flag='0' GROUP BY project_id,TRIM(batch_code) HAVING COUNT(*)>1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='batch_duplicate_code';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_grant_review r LEFT JOIN res_batch_member t ON t.batch_id=r.target_id AND t.user_id=r.user_id AND t.grant_type=r.decision WHERE r.target_type='BATCH' AND r.decision IN ('MEMBER','SHARE') AND (t.user_id IS NULL OR NOT (t.expire_date <=> r.expire_date) OR NOT (t.granted_at <=> r.granted_at))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='batch_grant_review_result';
  END IF;
  IF EXISTS (SELECT 1 WHERE (SELECT COUNT(*) FROM res_batch_member) <> ((SELECT COUNT(*) FROM m03_bak_20260909_res_batch_member b WHERE NOT EXISTS (SELECT 1 FROM m03_migration_grant_review r WHERE r.target_type='BATCH' AND r.target_id=b.batch_id AND r.user_id=b.user_id))+(SELECT COUNT(*) FROM m03_migration_grant_review r WHERE r.target_type='BATCH' AND r.decision IN ('MEMBER','SHARE')))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='batch_grant_count';
  END IF;
  IF EXISTS (SELECT 1 FROM res_culture WHERE del_flag='0' AND (facts_status<>'READY' OR creator_user_id IS NULL)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='culture_unreviewed_active';
  END IF;
  IF EXISTS (SELECT 1 FROM res_culture_member r JOIN res_culture t ON t.culture_id=r.culture_id WHERE t.del_flag='0' AND r.grant_type='LEGACY') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='culture_legacy_active_grant';
  END IF;
  IF EXISTS (SELECT 1 FROM res_culture WHERE del_flag='0' AND (lifecycle_state IS NULL OR lifecycle_state<>'CANCELLED') GROUP BY TRIM(culture_code) HAVING COUNT(*)>1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='culture_duplicate_code';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_grant_review r LEFT JOIN res_culture_member t ON t.culture_id=r.target_id AND t.user_id=r.user_id AND t.grant_type=r.decision WHERE r.target_type='CULTURE' AND r.decision IN ('MEMBER','SHARE') AND (t.user_id IS NULL OR NOT (t.expire_date <=> r.expire_date) OR NOT (t.granted_at <=> r.granted_at))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='culture_grant_review_result';
  END IF;
  IF EXISTS (SELECT 1 WHERE (SELECT COUNT(*) FROM res_culture_member) <> ((SELECT COUNT(*) FROM m03_bak_20260909_res_culture_member b WHERE NOT EXISTS (SELECT 1 FROM m03_migration_grant_review r WHERE r.target_type='CULTURE' AND r.target_id=b.culture_id AND r.user_id=b.user_id))+(SELECT COUNT(*) FROM m03_migration_grant_review r WHERE r.target_type='CULTURE' AND r.decision IN ('MEMBER','SHARE')))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='culture_grant_count';
  END IF;
  IF EXISTS (SELECT 1 FROM res_culture c LEFT JOIN res_culture_occupancy o ON o.culture_id=c.culture_id AND o.occupancy_state<>'RELEASED' WHERE c.del_flag='0' AND c.facts_status='READY' AND ((c.lifecycle_state IN ('DRAFT','EXPIRED') AND o.occupancy_id IS NOT NULL) OR (c.lifecycle_state='NOT_STARTED' AND (o.occupancy_id IS NULL OR o.occupancy_state<>'RESERVED')) OR (c.lifecycle_state IN ('RUNNING','DELAYED') AND (o.occupancy_id IS NULL OR o.occupancy_state<>'RUNNING')) OR (c.lifecycle_state IN ('FINISHED','CANCELLED') AND o.occupancy_id IS NOT NULL AND o.occupancy_state<>'RELEASE_PENDING'))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='active_occupancy_mismatch';
  END IF;
  IF EXISTS (SELECT 1 FROM res_culture_occupancy o LEFT JOIN res_culture c ON c.culture_id=o.culture_id WHERE c.culture_id IS NULL OR (o.occupancy_state<>'RELEASED' AND (c.del_flag<>'0' OR c.device_kind<>o.device_kind OR c.device_id<>o.device_id OR c.lab_id<>o.lab_id))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='occupancy_identity_mismatch';
  END IF;
  IF EXISTS (SELECT 1 FROM res_culture c JOIN res_culture_member r ON r.culture_id=c.culture_id AND r.grant_type='MEMBER' WHERE c.del_flag='0' AND c.member_setup_state<>'CONFIGURED') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='culture_setup_mismatch';
  END IF;
  IF EXISTS (SELECT 1 FROM res_culture c LEFT JOIN res_batch b ON b.batch_id=c.batch_id WHERE c.del_flag='0' AND (b.batch_id IS NULL OR b.del_flag<>'0' OR c.project_id<>b.project_id OR c.lab_id<>b.lab_id)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='active_culture_parent_mismatch';
  END IF;
END$$
DELIMITER ;
CALL m03_assert_constraints_20260909();
DROP PROCEDURE m03_assert_constraints_20260909;

ALTER TABLE `res_project`
  ADD COLUMN `m03_live_code` varchar(50) GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN TRIM(`project_code`) ELSE NULL END) STORED COMMENT '逻辑删除释放编号，历史记录按内部主键保留',
  DROP INDEX `uk_res_project_code_del`,
  ADD CONSTRAINT `ck_m03_project_version` CHECK (`object_version` >= 1),
  ADD CONSTRAINT `ck_m03_project_facts` CHECK (`facts_status` IN ('READY','REVIEW')),
  ADD CONSTRAINT `ck_m03_project_identity` CHECK (`project_id` > 0 AND `del_flag` IS NOT NULL AND `del_flag` IN ('0','2') AND CHAR_LENGTH(TRIM(`project_code`)) > 0),
  ADD INDEX `idx_m03_project_created` (`del_flag`,`create_time`,`project_id`),
  ADD UNIQUE INDEX `uk_m03_project_code` (`m03_live_code`);

ALTER TABLE `res_batch`
  ADD COLUMN `m03_live_code` varchar(50) GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN TRIM(`batch_code`) ELSE NULL END) STORED COMMENT '逻辑删除释放编号，历史记录按内部主键保留',
  DROP INDEX `uk_res_batch_code_del`,
  ADD CONSTRAINT `ck_m03_batch_version` CHECK (`object_version` >= 1),
  ADD CONSTRAINT `ck_m03_batch_facts` CHECK (`facts_status` IN ('READY','REVIEW')),
  ADD CONSTRAINT `ck_m03_batch_identity` CHECK (`batch_id` > 0 AND `del_flag` IS NOT NULL AND `del_flag` IN ('0','2') AND CHAR_LENGTH(TRIM(`batch_code`)) > 0),
  ADD INDEX `idx_m03_batch_list` (`project_id`,`del_flag`,`update_time`,`batch_id`),
  ADD UNIQUE INDEX `uk_m03_batch_code` (`project_id`,`m03_live_code`);

ALTER TABLE `res_culture`
  ADD COLUMN `m03_live_code` varchar(50) GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' AND (`lifecycle_state` IS NULL OR `lifecycle_state` <> 'CANCELLED') THEN TRIM(`culture_code`) ELSE NULL END) STORED COMMENT '有效占号键；取消或删除释放，未知状态保守占号',
  DROP INDEX `uk_res_culture_code_del`,
  ADD CONSTRAINT `ck_m03_culture_version` CHECK (`object_version` >= 1),
  ADD CONSTRAINT `ck_m03_culture_facts` CHECK (`facts_status` IN ('READY','REVIEW')),
  ADD CONSTRAINT `ck_m03_culture_identity` CHECK (`culture_id` > 0 AND `del_flag` IS NOT NULL AND `del_flag` IN ('0','2') AND CHAR_LENGTH(TRIM(`culture_code`)) > 0),
  ADD CONSTRAINT `ck_m03_culture_state` CHECK (`lifecycle_state` IS NULL OR `lifecycle_state` IN ('DRAFT','NOT_STARTED','RUNNING','EXPIRED','DELAYED','CANCELLED','FINISHED')),
  ADD CONSTRAINT `ck_m03_culture_mode` CHECK (`mode_code` IS NULL OR `mode_code` IN ('NORMAL','REACTOR')),
  ADD CONSTRAINT `ck_m03_culture_device` CHECK ((`device_kind` IS NULL AND `device_id` IS NULL) OR (`device_kind` IS NOT NULL AND `device_kind` IN ('INTEGRATED_REACTOR','CULTURE_CONTAINER','BENCH_CONTROLLER') AND `device_id` IS NOT NULL AND `device_id` > 0)),
  ADD CONSTRAINT `ck_m03_culture_duration` CHECK ((`planned_duration_days` IS NULL OR `planned_duration_days` >= 1) AND (`planned_start_date` IS NULL OR `planned_end_date` IS NULL OR (`planned_end_date` >= `planned_start_date` AND `planned_duration_days` IS NOT NULL AND `planned_duration_days` = DATEDIFF(`planned_end_date`,`planned_start_date`) + 1))),
  ADD CONSTRAINT `ck_m03_culture_plan_pair` CHECK (NOT ((`planned_start_date` IS NULL) <> (`planned_end_date` IS NULL)) OR `planned_duration_days` IS NULL),
  ADD CONSTRAINT `ck_m03_culture_versions` CHECK (`plan_version` >= 0 AND `runtime_version` >= 0),
  ADD CONSTRAINT `ck_m03_culture_flags` CHECK ((`n_marked` IS NULL OR `n_marked` IN (0,1)) AND `start_delay_active` IN (0,1) AND `end_delay_active` IN (0,1)),
  ADD CONSTRAINT `ck_m03_culture_members` CHECK (`member_setup_state` IN ('NEVER','CONFIGURED','UNKNOWN')),
  ADD CONSTRAINT `ck_m03_culture_ready` CHECK (`facts_status` <> 'READY' OR (`lifecycle_state` IS NOT NULL AND `mode_code` IS NOT NULL AND `device_kind` IS NOT NULL AND `device_id` IS NOT NULL AND `n_marked` IS NOT NULL AND `member_setup_state` <> 'UNKNOWN')),
  ADD CONSTRAINT `ck_m03_culture_scheduled` CHECK (`facts_status` <> 'READY' OR `lifecycle_state` NOT IN ('NOT_STARTED','RUNNING','EXPIRED','DELAYED') OR (`planned_start_date` IS NOT NULL AND `planned_end_date` IS NOT NULL)),
  ADD CONSTRAINT `ck_m03_culture_draft` CHECK (`facts_status` <> 'READY' OR `lifecycle_state` <> 'DRAFT' OR `planned_start_date` IS NULL OR `planned_end_date` IS NULL),
  ADD CONSTRAINT `ck_m03_culture_runtime` CHECK (`facts_status` <> 'READY' OR ((`lifecycle_state` <> 'RUNNING' OR `first_workflow_started_at` IS NOT NULL) AND (`lifecycle_state` <> 'FINISHED' OR `end_completed_at` IS NOT NULL) AND (`lifecycle_state` <> 'CANCELLED' OR `cancel_confirmed_at` IS NOT NULL) AND (`lifecycle_state` <> 'DELAYED' OR (`first_workflow_started_at` IS NOT NULL AND (`start_delay_active` = 1 OR `end_delay_active` = 1))) AND (`lifecycle_state` NOT IN ('DRAFT','NOT_STARTED','EXPIRED') OR `first_workflow_started_at` IS NULL))),
  ADD UNIQUE INDEX `uk_m03_culture_live_code` (`m03_live_code`),
  ADD INDEX `idx_m03_culture_lab_state` (`lab_id`,`del_flag`,`lifecycle_state`,`batch_id`,`project_id`),
  ADD INDEX `idx_m03_culture_batch_list` (`batch_id`,`del_flag`,`update_time`,`culture_id`),
  ADD INDEX `idx_m03_culture_device` (`device_kind`,`device_id`,`del_flag`),
  ADD INDEX `idx_m03_culture_start_due` (`facts_status`,`del_flag`,`lifecycle_state`,`planned_start_date`),
  ADD INDEX `idx_m03_culture_end_due` (`facts_status`,`del_flag`,`lifecycle_state`,`planned_end_date`);

ALTER TABLE `res_project_member`
  ADD CONSTRAINT `ck_m03_project_grant_type` CHECK (`grant_type` IN ('MEMBER','SHARE','LEGACY')),
  ADD CONSTRAINT `ck_m03_project_origin` CHECK (`selection_origin` IS NULL OR `selection_origin` IN ('USER','DEPARTMENT','GROUP')),
  ADD INDEX `idx_m03_project_grant_user` (`user_id`,`grant_type`,`expire_date`,`project_id`);

ALTER TABLE `res_batch_member`
  ADD CONSTRAINT `ck_m03_batch_grant_type` CHECK (`grant_type` IN ('MEMBER','SHARE','LEGACY')),
  ADD CONSTRAINT `ck_m03_batch_origin` CHECK (`selection_origin` IS NULL OR `selection_origin` IN ('USER','DEPARTMENT','GROUP')),
  ADD INDEX `idx_m03_batch_grant_user` (`user_id`,`grant_type`,`expire_date`,`batch_id`);

ALTER TABLE `res_culture_member`
  ADD CONSTRAINT `ck_m03_culture_grant_type` CHECK (`grant_type` IN ('MEMBER','SHARE','LEGACY')),
  ADD CONSTRAINT `ck_m03_culture_origin` CHECK (`selection_origin` IS NULL OR `selection_origin` IN ('USER','DEPARTMENT','GROUP')),
  ADD INDEX `idx_m03_culture_grant_user` (`user_id`,`grant_type`,`expire_date`,`culture_id`);
