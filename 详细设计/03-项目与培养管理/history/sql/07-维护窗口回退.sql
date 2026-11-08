-- M03 SQL设计稿；2026-09-09；未在数据库执行。MySQL 8.0.16+，须在实际小版本隔离演练。
-- 先读主设计第5/6节。逐阶段执行，错误立即停止；DDL隐式提交，不能整包盲跑。
-- 旧datetime与M01审计保持上海业务时区；明确标UTC的新列仅写UTC值。
SET NAMES utf8mb4;
SET SESSION time_zone = '+08:00';

-- 仅在首次恢复业务写之前回退；M03/M02/M07相关写及消费者仍停止。
-- 已接收新请求/运行事件后禁止本脚本；需单独设计保留新业务的前向修复。
-- 本脚本保留所有迁移后表为m03_failed_20260909_*，不DROP、不回退共享SYSTEM版本。
DELIMITER $$
CREATE PROCEDURE m03_assert_rollback_20260909()
BEGIN
  IF EXISTS (SELECT 1 WHERE NOT EXISTS (SELECT 1 FROM m03_migration_run r JOIN sys_management_revision s ON s.scope_key='SYSTEM' WHERE r.run_key='M03_20260909' AND ((r.phase='EXPANDED' AND s.revision=r.system_revision_before) OR (r.phase='BACKFILLED' AND s.revision=r.system_revision_after)))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='SYSTEM changed or migration metadata missing';
  END IF;
  IF EXISTS (SELECT 1 FROM res_culture_notice_outbox) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New domain notices exist; rollback prohibited';
  END IF;
  IF EXISTS (SELECT 1 FROM res_project WHERE object_version<>1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New object mutations exist: project';
  END IF;
  IF EXISTS (SELECT 1 FROM res_batch WHERE object_version<>1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New object mutations exist: batch';
  END IF;
  IF EXISTS (SELECT 1 FROM res_culture WHERE object_version<>1 OR runtime_version<>0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New object mutations exist: culture';
  END IF;
  IF EXISTS (SELECT 1 FROM res_culture_occupancy WHERE created_request_id<>'M03_20260909' OR object_version<>1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New occupancy mutations exist';
  END IF;
END$$
DELIMITER ;
CALL m03_assert_rollback_20260909();
DROP PROCEDURE m03_assert_rollback_20260909;

RENAME TABLE
  `res_project` TO `m03_failed_20260909_res_project`,
  `m03_bak_20260909_res_project` TO `res_project`,
  `res_project_leader` TO `m03_failed_20260909_res_project_leader`,
  `m03_bak_20260909_res_project_leader` TO `res_project_leader`,
  `res_project_lab` TO `m03_failed_20260909_res_project_lab`,
  `m03_bak_20260909_res_project_lab` TO `res_project_lab`,
  `res_project_tag` TO `m03_failed_20260909_res_project_tag`,
  `m03_bak_20260909_res_project_tag` TO `res_project_tag`,
  `res_project_member` TO `m03_failed_20260909_res_project_member`,
  `m03_bak_20260909_res_project_member` TO `res_project_member`,
  `res_batch` TO `m03_failed_20260909_res_batch`,
  `m03_bak_20260909_res_batch` TO `res_batch`,
  `res_batch_leader` TO `m03_failed_20260909_res_batch_leader`,
  `m03_bak_20260909_res_batch_leader` TO `res_batch_leader`,
  `res_batch_member` TO `m03_failed_20260909_res_batch_member`,
  `m03_bak_20260909_res_batch_member` TO `res_batch_member`,
  `res_culture` TO `m03_failed_20260909_res_culture`,
  `m03_bak_20260909_res_culture` TO `res_culture`,
  `res_culture_leader` TO `m03_failed_20260909_res_culture_leader`,
  `m03_bak_20260909_res_culture_leader` TO `res_culture_leader`,
  `res_culture_member` TO `m03_failed_20260909_res_culture_member`,
  `m03_bak_20260909_res_culture_member` TO `res_culture_member`;

-- 新增事实/审核表保留原名并封存只读，旧应用不会读取。恢复前对原表SHOW CREATE TABLE及数据指纹复核。
-- 下次迁移必须分配新批号，禁止复用本次固定对象名。
