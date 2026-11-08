-- 仅供独立授权后人工执行。不要与后续变更连跑；不得使用--force。
-- 先确认选中的目标库正确、维护窗口已暂停相关业务写/扫描，并保留SHOW CREATE TABLE结果。
SELECT DATABASE() AS selected_database, VERSION() AS mysql_version;
SHOW CREATE TABLE res_culture;
SELECT tc.constraint_name, tc.enforced, cc.check_clause
FROM information_schema.table_constraints tc
JOIN information_schema.check_constraints cc ON cc.constraint_schema=tc.constraint_schema AND cc.constraint_name=tc.constraint_name
WHERE tc.constraint_schema=DATABASE() AND tc.table_name='res_culture' AND tc.constraint_name='ck_m03_culture_runtime';
-- 以上必须恰为该表已启用的旧CHECK；若已是新定义，停止，不必重复变更；其他定义交回核对。
-- 以下必须为0；非0不得修数据或继续DDL。
SELECT COUNT(*) AS rows_violating_target_check FROM res_culture WHERE NOT (`facts_status` <> 'READY' OR ((`lifecycle_state` <> 'RUNNING' OR `first_workflow_started_at` IS NOT NULL) AND (`lifecycle_state` <> 'FINISHED' OR `end_completed_at` IS NOT NULL) AND (`lifecycle_state` <> 'CANCELLED' OR `cancel_confirmed_at` IS NOT NULL) AND (`lifecycle_state` <> 'DELAYED' OR (`first_workflow_started_at` IS NOT NULL AND (`start_delay_active` = 1 OR `end_delay_active` = 1))) AND (`lifecycle_state` <> 'DRAFT' OR `first_workflow_started_at` IS NULL)));
-- 核查通过仅表示可以评审变更，不是执行授权。本文件没有ALTER或数据写。
