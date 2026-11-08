-- M04收尾设计，2026-09-10。未执行SQL；MySQL8.0.16+；无物理外键。
-- 先完成旧基线包再执行本次增量；与最终空库目标二选一。必须指定核准数据库并停写/备份；DDL隐式提交，禁止忽略错误继续。
-- 列数只是附加门禁，先逐列/索引比对前核验输出。重复/部分执行必须停止并逐句核对，不重跑全稿。
DELIMITER $$
CREATE PROCEDURE close_m04_check()
BEGIN
IF DATABASE() IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Explicit approved database required'; END IF;
IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='prc_template_version') <> 22 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04 baseline mismatch: prc_template_version'; END IF;
END$$
DELIMITER ;
CALL close_m04_check();
DROP PROCEDURE close_m04_check;

ALTER TABLE `prc_template` ADD CONSTRAINT `ck_close_template_name` CHECK ((template_kind IN ('CONFIG','PERFUSION','SAMPLING','AUTO_CONTROL','FEEDING') AND CHAR_LENGTH(TRIM(template_name)) BETWEEN 2 AND 50) OR (template_kind='PUMP_SPEED' AND CHAR_LENGTH(TRIM(template_name)) BETWEEN 1 AND 19));

ALTER TABLE `prc_template_version`
 ADD COLUMN `engineering_schema_version` int NULL DEFAULT NULL COMMENT '新工程快照模式1；旧历史未知NULL',
 ADD COLUMN `engineering_snapshot_json` json NULL DEFAULT NULL COMMENT '固定EngineeringBundle；非工程类型显式空集合',
 ADD COLUMN `engineering_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT '工程快照规范SHA256；历史未知NULL';
