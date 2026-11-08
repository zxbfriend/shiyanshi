-- DD-20260917-OBS，只读核验；未执行。必须先完成本模块OBS-02。
SELECT table_name,COUNT(*) AS column_count FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('run_observation_monitor') GROUP BY table_name ORDER BY table_name;
SELECT table_name,index_name,non_unique,seq_in_index,column_name FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name IN ('run_observation_monitor') ORDER BY table_name,index_name,seq_in_index;
SELECT table_name,constraint_name,constraint_type FROM information_schema.table_constraints WHERE table_schema=DATABASE() AND table_name IN ('run_observation_monitor') ORDER BY table_name,constraint_name;
-- 用于核查升级前后样本版本分布，不自动把v1补成v2。
SELECT JSON_UNQUOTE(JSON_EXTRACT(raw_readings,'$.schemaVersion')) AS schema_version,COUNT(*) AS rows_count FROM run_execution_sample GROUP BY schema_version;
SELECT condition_key FROM run_observation_monitor WHERE sequence<0 OR evaluation_version<0 OR row_version<1 OR condition_state NOT IN ('UNKNOWN','NORMAL','ACTIVE');

