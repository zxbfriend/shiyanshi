-- M04 SQL设计稿；2026-09-10；未连接或执行数据库。
-- MySQL 8.0.16+；维护窗口同一连接按交付清单执行，禁止 --force/忽略错误。
-- 全部为逻辑关联，无数据库外键；DDL隐式提交，不假设整个脚本可事务回滚。
SET NAMES utf8mb4;
-- 同一连接在02成功后运行；后续独立核验也可使用本文件，不修改业务行。
DELIMITER $$
CREATE PROCEDURE m04_assert_core_v1()
BEGIN
  IF (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_type='BASE TABLE'
      AND engine='InnoDB' AND table_collation='utf8mb4_0900_ai_ci'
      AND table_name IN ('prc_template','prc_template_version','prc_template_binding','prc_template_version_model','prc_template_import_map')) <> 5 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: missing table or engine/collation mismatch';
  END IF;
  IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE()
      AND table_name IN ('prc_template','prc_template_version','prc_template_binding','prc_template_version_model','prc_template_import_map')) <> 67 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: expected exactly 67 core columns';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.referential_constraints WHERE constraint_schema=DATABASE()
      AND table_name IN ('prc_template','prc_template_version','prc_template_binding','prc_template_version_model','prc_template_import_map')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: unexpected database foreign key';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE()
      AND table_name='prc_template' AND column_name='live_name' AND extra LIKE '%STORED GENERATED%') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: missing stored generated live_name';
  END IF;
  IF (SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE()
      AND table_name IN ('prc_template','prc_template_version','prc_template_binding','prc_template_version_model','prc_template_import_map')
      AND constraint_type='CHECK' AND enforced='YES') <> 24 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: expected 24 enforced CHECK constraints';
  END IF;
  IF EXISTS (SELECT 1 FROM prc_template t LEFT JOIN prc_template_version v ON v.version_id=t.current_version_id
      WHERE v.version_id IS NULL OR v.template_id<>t.template_id OR BINARY v.name_snapshot<>BINARY t.template_name) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: current pointer or name projection mismatch';
  END IF;
  IF EXISTS (SELECT 1 FROM prc_template_version v LEFT JOIN prc_template t ON t.template_id=v.template_id
      LEFT JOIN prc_template_version p ON p.version_id=v.previous_version_id
      WHERE t.template_id IS NULL OR (v.previous_version_id IS NOT NULL AND
           (p.version_id IS NULL OR p.template_id<>v.template_id OR p.version_no<>v.version_no-1))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: version owner or predecessor mismatch';
  END IF;
  IF EXISTS (SELECT 1 FROM prc_template_binding b
      LEFT JOIN prc_template_version p ON p.version_id=b.parent_version_id
      LEFT JOIN prc_template_version s ON s.version_id=b.source_version_id
      LEFT JOIN prc_template t ON t.template_id=b.source_template_id
      LEFT JOIN prc_template_binding d ON d.binding_id=b.derived_from_binding_id
      WHERE p.version_id IS NULL OR s.version_id IS NULL OR t.template_id IS NULL
      OR s.template_id<>b.source_template_id OR t.template_kind<>b.source_kind
      OR (b.derived_from_binding_id IS NOT NULL AND d.binding_id IS NULL)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: binding owner, source, or provenance missing';
  END IF;
  IF EXISTS (SELECT 1 FROM prc_template_version_model m LEFT JOIN prc_template_version v ON v.version_id=m.version_id
      WHERE v.version_id IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: orphan model projection';
  END IF;
  IF EXISTS (SELECT 1 FROM prc_template_import_map m
      LEFT JOIN prc_template_version v ON v.version_id=m.target_version_id
      LEFT JOIN prc_template t ON t.template_id=m.target_template_id
      WHERE v.version_id IS NULL OR t.template_id IS NULL OR v.template_id<>m.target_template_id
         OR v.version_no<>1 OR v.change_kind<>'IMPORT' OR t.origin_kind<>'IMPORT') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M04: import mapping owner or initial version mismatch';
  END IF;
END$$
DELIMITER ;
CALL m04_assert_core_v1();
DROP PROCEDURE m04_assert_core_v1;
SELECT 'M04_CORE_BASIC_CHECK_PASSED' AS result;
-- 结构/逻辑关联检查不替代六类JSON、权限、资源、hash重算、并发及MySQL精确结构比对。
SELECT table_name, column_name, column_type, is_nullable, column_default, collation_name, extra, generation_expression
FROM information_schema.columns WHERE table_schema=DATABASE()
AND table_name IN ('prc_template','prc_template_version','prc_template_binding','prc_template_version_model','prc_template_import_map')
ORDER BY table_name, ordinal_position;
SELECT table_name,index_name,non_unique,seq_in_index,column_name
FROM information_schema.statistics WHERE table_schema=DATABASE()
AND table_name IN ('prc_template','prc_template_version','prc_template_binding','prc_template_version_model','prc_template_import_map')
ORDER BY table_name,index_name,seq_in_index;