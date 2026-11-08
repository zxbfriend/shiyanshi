-- 2026-09-10 M07设计稿，未执行。目标MySQL 8.0.16+的8.x；不得--force继续。
-- 新表无外键，服务端守卫及引用校验必须实施；不修改任何旧表。
-- 结构与空表设计期核验，运行后行数不再要求0。
SELECT table_name,table_type,engine FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name IN ('run_culture_runtime','run_workflow_instance','run_workflow_step','run_material_session','run_manual_result','run_confirmation','run_calculation','run_task','run_task_candidate','run_generation','run_execution','run_execution_segment','run_command','run_resource_guard','run_execution_sample','run_exception_handling','run_ledger','run_event') ORDER BY table_name;
SELECT table_name,ordinal_position,column_name,column_type,is_nullable,extra,generation_expression FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('run_culture_runtime','run_workflow_instance','run_workflow_step','run_material_session','run_manual_result','run_confirmation','run_calculation','run_task','run_task_candidate','run_generation','run_execution','run_execution_segment','run_command','run_resource_guard','run_execution_sample','run_exception_handling','run_ledger','run_event') ORDER BY table_name,ordinal_position;
SELECT table_name,index_name,non_unique,seq_in_index,column_name FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name IN ('run_culture_runtime','run_workflow_instance','run_workflow_step','run_material_session','run_manual_result','run_confirmation','run_calculation','run_task','run_task_candidate','run_generation','run_execution','run_execution_segment','run_command','run_resource_guard','run_execution_sample','run_exception_handling','run_ledger','run_event') ORDER BY table_name,index_name,seq_in_index;
SELECT tc.table_name,tc.constraint_name,cc.check_clause FROM information_schema.table_constraints tc JOIN information_schema.check_constraints cc ON cc.constraint_schema=tc.constraint_schema AND cc.constraint_name=tc.constraint_name WHERE tc.constraint_schema=DATABASE() AND tc.table_name IN ('run_culture_runtime','run_workflow_instance','run_workflow_step','run_material_session','run_manual_result','run_confirmation','run_calculation','run_task','run_task_candidate','run_generation','run_execution','run_execution_segment','run_command','run_resource_guard','run_execution_sample','run_exception_handling','run_ledger','run_event') AND tc.constraint_type='CHECK' ORDER BY tc.table_name,tc.constraint_name;
SELECT 'run_culture_runtime' AS table_name, COUNT(*) AS row_count FROM `run_culture_runtime`;
SELECT 'run_workflow_instance' AS table_name, COUNT(*) AS row_count FROM `run_workflow_instance`;
SELECT 'run_workflow_step' AS table_name, COUNT(*) AS row_count FROM `run_workflow_step`;
SELECT 'run_material_session' AS table_name, COUNT(*) AS row_count FROM `run_material_session`;
SELECT 'run_manual_result' AS table_name, COUNT(*) AS row_count FROM `run_manual_result`;
SELECT 'run_confirmation' AS table_name, COUNT(*) AS row_count FROM `run_confirmation`;
SELECT 'run_calculation' AS table_name, COUNT(*) AS row_count FROM `run_calculation`;
SELECT 'run_task' AS table_name, COUNT(*) AS row_count FROM `run_task`;
SELECT 'run_task_candidate' AS table_name, COUNT(*) AS row_count FROM `run_task_candidate`;
SELECT 'run_generation' AS table_name, COUNT(*) AS row_count FROM `run_generation`;
SELECT 'run_execution' AS table_name, COUNT(*) AS row_count FROM `run_execution`;
SELECT 'run_execution_segment' AS table_name, COUNT(*) AS row_count FROM `run_execution_segment`;
SELECT 'run_command' AS table_name, COUNT(*) AS row_count FROM `run_command`;
SELECT 'run_resource_guard' AS table_name, COUNT(*) AS row_count FROM `run_resource_guard`;
SELECT 'run_execution_sample' AS table_name, COUNT(*) AS row_count FROM `run_execution_sample`;
SELECT 'run_exception_handling' AS table_name, COUNT(*) AS row_count FROM `run_exception_handling`;
SELECT 'run_ledger' AS table_name, COUNT(*) AS row_count FROM `run_ledger`;
SELECT 'run_event' AS table_name, COUNT(*) AS row_count FROM `run_event`;
-- 预期18表、314列（含生成列）、48条CHECK；逐项与05及字段字典比较，不只看总数。
