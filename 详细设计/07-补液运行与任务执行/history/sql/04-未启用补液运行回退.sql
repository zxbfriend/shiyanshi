-- 2026-09-10 M07设计稿，未执行。目标MySQL 8.0.16+的8.x；不得--force继续。
-- 新表无外键，服务端守卫及引用校验必须实施；不修改任何旧表。
-- 仅全套表完整且每表均为空的未启用安装可回退；有任何运行/审计/资源行即拒绝。
SET NAMES utf8mb4;
DELIMITER $$
CREATE PROCEDURE m07_empty_install_rollback()
BEGIN
 IF DATABASE() IS NULL OR COALESCE(@m07_maintenance_confirmed,0)<>1 OR COALESCE(@m07_native_backup_verified,0)<>1 OR COALESCE(@m07_never_enabled_confirmed,0)<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 requires explicit empty never-enabled rollback confirmation'; END IF;
 IF (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_type='BASE TABLE' AND table_name IN ('run_culture_runtime','run_workflow_instance','run_workflow_step','run_material_session','run_manual_result','run_confirmation','run_calculation','run_task','run_task_candidate','run_generation','run_execution','run_execution_segment','run_command','run_resource_guard','run_execution_sample','run_exception_handling','run_ledger','run_event'))<>18 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 partial or mismatched installation; inspect manually'; END IF;
 IF EXISTS(SELECT 1 FROM `run_culture_runtime` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 run_culture_runtime not empty'; END IF;
 IF EXISTS(SELECT 1 FROM `run_workflow_instance` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 run_workflow_instance not empty'; END IF;
 IF EXISTS(SELECT 1 FROM `run_workflow_step` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 run_workflow_step not empty'; END IF;
 IF EXISTS(SELECT 1 FROM `run_material_session` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 run_material_session not empty'; END IF;
 IF EXISTS(SELECT 1 FROM `run_manual_result` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 run_manual_result not empty'; END IF;
 IF EXISTS(SELECT 1 FROM `run_confirmation` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 run_confirmation not empty'; END IF;
 IF EXISTS(SELECT 1 FROM `run_calculation` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 run_calculation not empty'; END IF;
 IF EXISTS(SELECT 1 FROM `run_task` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 run_task not empty'; END IF;
 IF EXISTS(SELECT 1 FROM `run_task_candidate` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 run_task_candidate not empty'; END IF;
 IF EXISTS(SELECT 1 FROM `run_generation` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 run_generation not empty'; END IF;
 IF EXISTS(SELECT 1 FROM `run_execution` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 run_execution not empty'; END IF;
 IF EXISTS(SELECT 1 FROM `run_execution_segment` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 run_execution_segment not empty'; END IF;
 IF EXISTS(SELECT 1 FROM `run_command` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 run_command not empty'; END IF;
 IF EXISTS(SELECT 1 FROM `run_resource_guard` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 run_resource_guard not empty'; END IF;
 IF EXISTS(SELECT 1 FROM `run_execution_sample` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 run_execution_sample not empty'; END IF;
 IF EXISTS(SELECT 1 FROM `run_exception_handling` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 run_exception_handling not empty'; END IF;
 IF EXISTS(SELECT 1 FROM `run_ledger` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 run_ledger not empty'; END IF;
 IF EXISTS(SELECT 1 FROM `run_event` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M07 run_event not empty'; END IF;
 DROP TABLE `run_event`;
 DROP TABLE `run_ledger`;
 DROP TABLE `run_exception_handling`;
 DROP TABLE `run_execution_sample`;
 DROP TABLE `run_resource_guard`;
 DROP TABLE `run_command`;
 DROP TABLE `run_execution_segment`;
 DROP TABLE `run_execution`;
 DROP TABLE `run_generation`;
 DROP TABLE `run_task_candidate`;
 DROP TABLE `run_task`;
 DROP TABLE `run_calculation`;
 DROP TABLE `run_confirmation`;
 DROP TABLE `run_manual_result`;
 DROP TABLE `run_material_session`;
 DROP TABLE `run_workflow_step`;
 DROP TABLE `run_workflow_instance`;
 DROP TABLE `run_culture_runtime`;
END$$
DELIMITER ;
CALL m07_empty_install_rollback();
DROP PROCEDURE m07_empty_install_rollback;
