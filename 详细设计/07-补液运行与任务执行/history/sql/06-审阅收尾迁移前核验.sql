-- M07 只读前置；必须逐列/索引/CHECK与原完整目标比对，不以数量相同代替一致。
SELECT DATABASE(),VERSION();
SELECT table_name,column_name,column_type,is_nullable,column_default,extra FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('run_culture_runtime','run_workflow_instance','run_workflow_step','run_material_session','run_manual_result','run_confirmation','run_calculation','run_task','run_task_candidate','run_generation','run_execution','run_execution_segment','run_command','run_resource_guard','run_execution_sample','run_exception_handling','run_ledger','run_event') ORDER BY table_name,ordinal_position;
SHOW CREATE TABLE `run_culture_runtime`;
SHOW CREATE TABLE `run_workflow_instance`;
SHOW CREATE TABLE `run_workflow_step`;
SHOW CREATE TABLE `run_material_session`;
SHOW CREATE TABLE `run_manual_result`;
SHOW CREATE TABLE `run_confirmation`;
SHOW CREATE TABLE `run_calculation`;
SHOW CREATE TABLE `run_task`;
SHOW CREATE TABLE `run_task_candidate`;
SHOW CREATE TABLE `run_generation`;
SHOW CREATE TABLE `run_execution`;
SHOW CREATE TABLE `run_execution_segment`;
SHOW CREATE TABLE `run_command`;
SHOW CREATE TABLE `run_resource_guard`;
SHOW CREATE TABLE `run_execution_sample`;
SHOW CREATE TABLE `run_exception_handling`;
SHOW CREATE TABLE `run_ledger`;
SHOW CREATE TABLE `run_event`;
-- 任一invalid_rows非0则停止；保留原数据，不自动清洗。备份与维护核准完成才设置本包维护/基线/备份确认变量。
