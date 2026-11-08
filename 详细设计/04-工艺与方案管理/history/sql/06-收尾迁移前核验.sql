-- M04收尾设计，2026-09-10。未执行SQL；MySQL8.0.16+；无物理外键。
-- 先完成旧基线包再执行本次增量；与最终空库目标二选一。必须指定核准数据库并停写/备份；DDL隐式提交，禁止忽略错误继续。
SELECT DATABASE() AS approved_database,VERSION() AS mysql_version;
SELECT table_name,column_name,ordinal_position,column_type,is_nullable,column_default,extra FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('prc_template','prc_template_version','prc_template_binding','prc_template_version_model','prc_template_import_map') ORDER BY table_name,ordinal_position;
SELECT table_name,index_name,seq_in_index,column_name,non_unique FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name IN ('prc_template','prc_template_version','prc_template_binding','prc_template_version_model','prc_template_import_map') ORDER BY table_name,index_name,seq_in_index;
SELECT 'prc_template_version' AS source_table,COUNT(*) AS baseline_rows FROM `prc_template_version`;
SELECT template_id,template_kind,CHAR_LENGTH(TRIM(template_name)) AS name_length FROM prc_template WHERE (template_kind IN ('CONFIG','PERFUSION','SAMPLING','AUTO_CONTROL','FEEDING') AND CHAR_LENGTH(TRIM(template_name)) NOT BETWEEN 2 AND 50) OR (template_kind='PUMP_SPEED' AND CHAR_LENGTH(TRIM(template_name)) NOT BETWEEN 1 AND 19);
-- 非零结果阻断新增名称约束，不自动改名。
