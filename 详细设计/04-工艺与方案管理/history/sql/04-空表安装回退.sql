-- M04 SQL设计稿；2026-09-10；未连接或执行数据库。
-- MySQL 8.0.16+；维护窗口同一连接按交付清单执行，禁止 --force/忽略错误。
-- 全部为逻辑关联，无数据库外键；DDL隐式提交，不假设整个脚本可事务回滚。
SET NAMES utf8mb4;
-- 仅本连接刚安装且从未开放业务写入的空表可用；要求人工先设置 @m04_confirm_empty_rollback = 1。
-- 不在本文件自动将确认值改1。已发生业务写入/旧数据导入后禁止用此脚本回退。
DELIMITER $$
CREATE PROCEDURE m04_rollback_empty_v1()
BEGIN
  DECLARE v_done int DEFAULT 0;
  DECLARE v_table varchar(64);
  DECLARE v_cursor CURSOR FOR
    SELECT table_name FROM information_schema.tables WHERE table_schema=DATABASE() AND table_type='BASE TABLE'
      AND table_name IN ('prc_template','prc_template_version','prc_template_binding','prc_template_version_model','prc_template_import_map');
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done=1;
  IF COALESCE(@m04_confirm_empty_rollback,0)<>1 OR COALESCE(@m04_core_install_started,0)<>1
      OR @m04_preflight_db IS NULL OR @m04_preflight_db<>DATABASE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: no confirmed same-session empty-install rollback context';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_type<>'BASE TABLE'
      AND table_name IN ('prc_template','prc_template_version','prc_template_binding','prc_template_version_model','prc_template_import_map')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: unexpected object type; manual review required';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.key_column_usage WHERE referenced_table_schema=DATABASE()
      AND referenced_table_name IN ('prc_template','prc_template_version','prc_template_binding','prc_template_version_model','prc_template_import_map')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: unexpected foreign references; do not drop';
  END IF;
  OPEN v_cursor;
  count_loop: LOOP
    FETCH v_cursor INTO v_table;
    IF v_done=1 THEN LEAVE count_loop; END IF;
    -- v_table只可能为上面固定白名单中的五个名称，不接受外部表名。
    SET @m04_count_sql=CONCAT('SELECT COUNT(*) INTO @m04_count_rows FROM `',v_table,'`');
    PREPARE m04_count_stmt FROM @m04_count_sql;
    EXECUTE m04_count_stmt;
    DEALLOCATE PREPARE m04_count_stmt;
    IF @m04_count_rows<>0 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: data exists; empty rollback refused before any DROP';
    END IF;
  END LOOP;
  CLOSE v_cursor;
  -- 整个窗口必须停止所有M04写入；DDL隐式提交，不能只靠事务覆盖先数行后DROP之间的并发。
  DROP TABLE IF EXISTS prc_template_import_map;
  DROP TABLE IF EXISTS prc_template_version_model;
  DROP TABLE IF EXISTS prc_template_binding;
  DROP TABLE IF EXISTS prc_template_version;
  DROP TABLE IF EXISTS prc_template;
  SET @m04_core_install_started=0;
  SET @m04_core_install_complete=0;
  SET @m04_confirm_empty_rollback=0;
END$$
DELIMITER ;
CALL m04_rollback_empty_v1();
DROP PROCEDURE m04_rollback_empty_v1;
-- 失败遗留的m04_create_core_v1等脚本专用过程，须核对SHOW CREATE PROCEDURE后人工清理，不自动覆盖。