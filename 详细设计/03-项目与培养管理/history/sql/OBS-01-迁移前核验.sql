-- DD-20260917-OBS，只读迁移前核验；未执行。结果须由实施人逐项核准。
SELECT DATABASE() AS target_schema, VERSION() AS mysql_version;
-- 本包新表应不存在；任一命中即停止，禁止IF NOT EXISTS掩盖漂移。
SELECT table_name FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name IN ('res_observation_binding_revision','res_observation_binding_interval');
-- 基线依赖必须全部存在，逐字段与当前完整DDL比对；不能只看表名。
SELECT table_name,column_name,column_type,is_nullable FROM information_schema.columns
WHERE table_schema=DATABASE() AND table_name IN ('res_culture','res_culture_occupancy') ORDER BY table_name,ordinal_position;
-- 确认MySQL>=8.0.16、UTC会话、SQL严格模式、备份恢复证据及无并发迁移后，另行审批执行OBS-02。
SELECT @@session.time_zone AS session_timezone,@@session.sql_mode AS sql_mode;

