-- M02收尾设计，2026-09-10。未执行SQL；MySQL8.0.16+；无物理外键。
-- 先完成旧基线包再执行本次增量；与最终空库目标二选一。必须指定核准数据库并停写/备份；DDL隐式提交，禁止忽略错误继续。
-- 仅增量从未使用。任一新增列有值或新表有行均禁止删除审计数据回退。
DELIMITER $$
CREATE PROCEDURE close_m02_unused()
BEGIN
IF EXISTS(SELECT 1 FROM `lab_bench_reactor_controller` WHERE `model_dict_code` IS NOT NULL LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Extension already used: lab_bench_reactor_controller'; END IF;
IF EXISTS(SELECT 1 FROM `lab_engineering_profile` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New table already used: lab_engineering_profile'; END IF;
IF EXISTS(SELECT 1 FROM `lab_engineering_profile_version` LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New table already used: lab_engineering_profile_version'; END IF;
END$$
DELIMITER ;
CALL close_m02_unused();
DROP PROCEDURE close_m02_unused;
DROP TABLE `lab_engineering_profile_version`;
DROP TABLE `lab_engineering_profile`;
ALTER TABLE `lab_bench_reactor_controller` DROP COLUMN `model_dict_code`;
