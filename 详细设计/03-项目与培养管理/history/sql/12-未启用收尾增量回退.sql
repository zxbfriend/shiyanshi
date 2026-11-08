-- M03收尾设计，2026-09-10。未执行SQL；MySQL8.0.16+；无物理外键。
-- 先完成旧基线包再执行本次增量；与最终空库目标二选一。必须指定核准数据库并停写/备份；DDL隐式提交，禁止忽略错误继续。
-- 仅增量从未使用。任一新增列有值或新表有行均禁止删除审计数据回退。
DELIMITER $$
CREATE PROCEDURE close_m03_unused()
BEGIN
IF EXISTS(SELECT 1 FROM `res_culture` WHERE `runtime_stream_id` IS NOT NULL OR `runtime_stream_sequence` IS NOT NULL OR `delay_resolution_json` IS NOT NULL LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Extension already used: res_culture'; END IF;
IF EXISTS(SELECT 1 FROM `res_culture_occupancy` WHERE `resource_release_snapshot` IS NOT NULL OR `release_source_event_id` IS NOT NULL LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Extension already used: res_culture_occupancy'; END IF;
IF EXISTS(SELECT 1 FROM `res_culture_parameter_application` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New table already used: res_culture_parameter_application'; END IF;
IF EXISTS(SELECT 1 FROM `res_culture_parameter_snapshot` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New table already used: res_culture_parameter_snapshot'; END IF;
IF EXISTS(SELECT 1 FROM `res_culture_parameter_state` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New table already used: res_culture_parameter_state'; END IF;
IF EXISTS(SELECT 1 FROM `res_culture_workflow_reference` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New table already used: res_culture_workflow_reference'; END IF;
IF EXISTS(SELECT 1 FROM `res_culture_runtime_event` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New table already used: res_culture_runtime_event'; END IF;
END$$
DELIMITER ;
CALL close_m03_unused();
DROP PROCEDURE close_m03_unused;
DROP TABLE `res_culture_runtime_event`;
DROP TABLE `res_culture_workflow_reference`;
DROP TABLE `res_culture_parameter_state`;
DROP TABLE `res_culture_parameter_snapshot`;
DROP TABLE `res_culture_parameter_application`;
ALTER TABLE `res_culture` DROP COLUMN `runtime_stream_id`, DROP COLUMN `runtime_stream_sequence`, DROP COLUMN `delay_resolution_json`;
ALTER TABLE `res_culture_occupancy` DROP COLUMN `resource_release_snapshot`, DROP COLUMN `release_source_event_id`;
