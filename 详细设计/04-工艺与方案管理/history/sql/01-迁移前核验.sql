-- M04 SQL设计稿；2026-09-10；未连接或执行数据库。
-- MySQL 8.0.16+；维护窗口同一连接按交付清单执行，禁止 --force/忽略错误。
-- 全部为逻辑关联，无数据库外键；DDL隐式提交，不假设整个脚本可事务回滚。
SET NAMES utf8mb4;
-- 只创建本脚本专用核验过程；不改业务表。若同名过程已存在，先核实上次失败现场，不自动DROP。
SET @m04_preflight_ok = 0;
SET @m04_preflight_db = NULL;
SET @m04_core_install_started = 0;
SET @m04_core_install_complete = 0;
DELIMITER $$
CREATE PROCEDURE m04_assert_preflight_v1()
BEGIN
  DECLARE v_major int;
  DECLARE v_minor int;
  DECLARE v_patch int;
  IF DATABASE() IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: explicitly select the reviewed target database';
  END IF;
  SET v_major = CAST(SUBSTRING_INDEX(VERSION(), '.', 1) AS UNSIGNED);
  SET v_minor = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(VERSION(), '.', 2), '.', -1) AS UNSIGNED);
  SET v_patch = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(VERSION(), '.', 3), '.', -1) AS UNSIGNED);
  IF VERSION() LIKE '%MariaDB%' OR v_major < 8 OR (v_major = 8 AND v_minor = 0 AND v_patch < 16) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: MySQL 8.0.16+ with enforced CHECK is required';
  END IF;
  IF @@SESSION.sql_mode NOT LIKE '%STRICT_TRANS_TABLES%' AND @@SESSION.sql_mode NOT LIKE '%STRICT_ALL_TABLES%' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: strict SQL mode is required';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.collations WHERE collation_name='utf8mb4_0900_ai_ci') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: required utf8mb4 collation unavailable';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE()
      AND table_name IN ('prc_template','prc_template_version','prc_template_binding','prc_template_version_model','prc_template_import_map')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: target object exists; inspect prior or partial installation';
  END IF;
  IF (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_type='BASE TABLE'
      AND table_name IN ('workflow_node','workflow_subflow','workflow_step','lab_workflow_node','sys_management_revision','sys_management_request','sys_oper_log')) <> 7 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: required workflow or M01 management tables missing';
  END IF;
  IF (SELECT COUNT(*) FROM sys_management_revision WHERE scope_key='SYSTEM' AND revision>=0) <> 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: exactly one valid SYSTEM management guard required';
  END IF;
  IF EXISTS (SELECT 1 FROM workflow_subflow s LEFT JOIN workflow_node n ON n.node_id=s.node_id
      WHERE s.del_flag='0' AND (n.node_id IS NULL OR COALESCE(n.del_flag,'?')<>'0')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: active subflow has no valid parent';
  END IF;
  IF EXISTS (SELECT 1 FROM workflow_step s LEFT JOIN workflow_subflow f ON f.subflow_id=s.subflow_id
      LEFT JOIN workflow_node n ON n.node_id=s.node_id WHERE s.del_flag='0'
      AND (f.subflow_id IS NULL OR COALESCE(f.del_flag,'?')<>'0' OR f.node_id<>s.node_id OR n.node_id IS NULL OR COALESCE(n.del_flag,'?')<>'0'
           OR s.step_code IS NULL OR TRIM(s.step_code)='')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: active step identity or parent relation requires review';
  END IF;
  SET @m04_preflight_db = DATABASE();
  SET @m04_preflight_ok = 1;
END$$
DELIMITER ;
CALL m04_assert_preflight_v1();
DROP PROCEDURE m04_assert_preflight_v1;
SELECT DATABASE() AS reviewed_database, VERSION() AS mysql_version, @m04_preflight_ok AS preflight_passed;
-- 记录四表当前结构、索引和行数到受保护的演练记录；此脚本不导出业务内容或备份敏感数据。
SELECT table_name, column_name, column_type, is_nullable, column_default, extra
FROM information_schema.columns WHERE table_schema=DATABASE()
AND table_name IN ('workflow_node','workflow_subflow','workflow_step','lab_workflow_node')
ORDER BY table_name, ordinal_position;