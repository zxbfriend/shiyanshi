-- 2026-09-10 M07设计稿，未执行。目标MySQL 8.0.16+的8.x；不得--force继续。
-- 新表无外键，服务端守卫及引用校验必须实施；不修改任何旧表。
-- 只读核验；不自动设置安装开关。
SELECT DATABASE() AS target_schema, VERSION() AS mysql_version, @@session.time_zone AS session_timezone;
SELECT table_name,table_type,engine FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name IN ('run_culture_runtime','run_workflow_instance','run_workflow_step','run_material_session','run_manual_result','run_confirmation','run_calculation','run_task','run_task_candidate','run_generation','run_execution','run_execution_segment','run_command','run_resource_guard','run_execution_sample','run_exception_handling','run_ledger','run_event','lab_lab','res_culture','res_project','res_batch','sys_management_revision','sys_management_request','apr_request','workflow_subflow') ORDER BY table_name;
SELECT table_name,column_name,column_type,is_nullable FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('lab_lab','res_culture','res_project','res_batch','sys_management_revision','sys_management_request','apr_request','workflow_subflow') ORDER BY table_name,ordinal_position;
SELECT constraint_name,table_name,constraint_type FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND constraint_name LIKE 'ck_m07_%';
-- 对照M01/M02/M03/M06已核准DDL及接口，不以同名表存在当接口已完成。
-- M07-Q01/Q02生产规则及EXT01至05必须单独核准；建空表不启用执行器。
