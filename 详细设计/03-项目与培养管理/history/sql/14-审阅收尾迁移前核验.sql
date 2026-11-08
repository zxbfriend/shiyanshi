-- M03 只读前置；必须逐列/索引/CHECK与原完整目标比对，不以数量相同代替一致。
SELECT DATABASE(),VERSION();
SELECT table_name,column_name,column_type,is_nullable,column_default,extra FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('res_project','res_project_leader','res_project_lab','res_project_tag','res_project_member','res_batch','res_batch_leader','res_batch_member','res_culture','res_culture_leader','res_culture_member','res_culture_occupancy','res_culture_notice_outbox','res_culture_parameter_application','res_culture_parameter_snapshot','res_culture_parameter_state','res_culture_workflow_reference','res_culture_runtime_event') ORDER BY table_name,ordinal_position;
SHOW CREATE TABLE `res_project`;
SHOW CREATE TABLE `res_project_leader`;
SHOW CREATE TABLE `res_project_lab`;
SHOW CREATE TABLE `res_project_tag`;
SHOW CREATE TABLE `res_project_member`;
SHOW CREATE TABLE `res_batch`;
SHOW CREATE TABLE `res_batch_leader`;
SHOW CREATE TABLE `res_batch_member`;
SHOW CREATE TABLE `res_culture`;
SHOW CREATE TABLE `res_culture_leader`;
SHOW CREATE TABLE `res_culture_member`;
SHOW CREATE TABLE `res_culture_occupancy`;
SHOW CREATE TABLE `res_culture_notice_outbox`;
SHOW CREATE TABLE `res_culture_parameter_application`;
SHOW CREATE TABLE `res_culture_parameter_snapshot`;
SHOW CREATE TABLE `res_culture_parameter_state`;
SHOW CREATE TABLE `res_culture_workflow_reference`;
SHOW CREATE TABLE `res_culture_runtime_event`;
-- 任一invalid_rows非0则停止；保留原数据，不自动清洗。备份与维护核准完成才设置本包维护/基线/备份确认变量。
