-- 仅供另获数据库执行授权后，由维护人员在核准目标库执行；本次代理未执行。
-- 本文件不自动执行前置核查。必须先人工审阅同目录“执行前核查.sql”的结果并确认0冲突。
-- 旧CHECK缺失、未启用、不同定义、目标库不明、存在冲突数据时停止；已是新CHECK无需执行。
-- 同一ALTER内只替换本CHECK，保留其他约束；不修改业务数据，不清除FIRST，不设置check_constraint_checks=OFF。
ALTER TABLE res_culture
  DROP CHECK ck_m03_culture_runtime,
  ADD CONSTRAINT ck_m03_culture_runtime CHECK (`facts_status` <> 'READY' OR ((`lifecycle_state` <> 'RUNNING' OR `first_workflow_started_at` IS NOT NULL) AND (`lifecycle_state` <> 'FINISHED' OR `end_completed_at` IS NOT NULL) AND (`lifecycle_state` <> 'CANCELLED' OR `cancel_confirmed_at` IS NOT NULL) AND (`lifecycle_state` <> 'DELAYED' OR (`first_workflow_started_at` IS NOT NULL AND (`start_delay_active` = 1 OR `end_delay_active` = 1))) AND (`lifecycle_state` <> 'DRAFT' OR `first_workflow_started_at` IS NULL)));
-- 执行后人工核SHOW CREATE TABLE及同目录核查SQL；仅以后真正执行成功才能报告数据库验证通过。
