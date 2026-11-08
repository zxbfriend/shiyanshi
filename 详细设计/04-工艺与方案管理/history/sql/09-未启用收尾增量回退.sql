-- M04收尾设计，2026-09-10。未执行SQL；MySQL8.0.16+；无物理外键。
-- 先完成旧基线包再执行本次增量；与最终空库目标二选一。必须指定核准数据库并停写/备份；DDL隐式提交，禁止忽略错误继续。
-- 仅增量从未使用。任一新增列有值或新表有行均禁止删除审计数据回退。
DELIMITER $$
CREATE PROCEDURE close_m04_unused()
BEGIN
IF EXISTS(SELECT 1 FROM `prc_template_version` WHERE `engineering_schema_version` IS NOT NULL OR `engineering_snapshot_json` IS NOT NULL OR `engineering_hash` IS NOT NULL LIMIT 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Extension already used: prc_template_version'; END IF;
END$$
DELIMITER ;
CALL close_m04_unused();
DROP PROCEDURE close_m04_unused;
ALTER TABLE `prc_template_version` DROP COLUMN `engineering_schema_version`, DROP COLUMN `engineering_snapshot_json`, DROP COLUMN `engineering_hash`;
ALTER TABLE `prc_template` DROP CHECK `ck_close_template_name`;
