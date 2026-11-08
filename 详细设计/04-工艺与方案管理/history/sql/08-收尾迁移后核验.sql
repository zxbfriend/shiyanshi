-- M04收尾设计，2026-09-10。未执行SQL；MySQL8.0.16+；无物理外键。
-- 先完成旧基线包再执行本次增量；与最终空库目标二选一。必须指定核准数据库并停写/备份；DDL隐式提交，禁止忽略错误继续。
SELECT table_name,COUNT(*) AS column_count FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('prc_template','prc_template_version','prc_template_binding','prc_template_version_model','prc_template_import_map') GROUP BY table_name ORDER BY table_name;
SELECT version_id FROM prc_template_version WHERE (engineering_schema_version IS NULL) <> (engineering_snapshot_json IS NULL) OR (engineering_snapshot_json IS NULL) <> (engineering_hash IS NULL);
-- 三项全NULL是旧未核准，不能因此默认工程可用；内容与hash由应用复算。
