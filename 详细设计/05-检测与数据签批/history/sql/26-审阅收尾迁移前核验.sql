-- M05 只读前置；必须逐列/索引/CHECK与原完整目标比对，不以数量相同代替一致。
SELECT DATABASE(),VERSION();
SELECT table_name,column_name,column_type,is_nullable,column_default,extra FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('det_approval_assignee','det_ccpd_upload_log','det_dispatch_log','det_exception_note','det_print_export_log','det_result','det_result_item','det_result_sign_record','det_review_audit_log','det_sample','det_sample_id_history','det_sample_item','det_device_event','det_result_revision','det_result_correction') ORDER BY table_name,ordinal_position;
SHOW CREATE TABLE `det_approval_assignee`;
SHOW CREATE TABLE `det_ccpd_upload_log`;
SHOW CREATE TABLE `det_dispatch_log`;
SHOW CREATE TABLE `det_exception_note`;
SHOW CREATE TABLE `det_print_export_log`;
SHOW CREATE TABLE `det_result`;
SHOW CREATE TABLE `det_result_item`;
SHOW CREATE TABLE `det_result_sign_record`;
SHOW CREATE TABLE `det_review_audit_log`;
SHOW CREATE TABLE `det_sample`;
SHOW CREATE TABLE `det_sample_id_history`;
SHOW CREATE TABLE `det_sample_item`;
SHOW CREATE TABLE `det_device_event`;
SHOW CREATE TABLE `det_result_revision`;
SHOW CREATE TABLE `det_result_correction`;
SELECT 'nonnull_source_id' AS check_name,COUNT(*) AS invalid_rows FROM `det_result_revision` WHERE `source_id` IS NULL;
-- 任一invalid_rows非0则停止；保留原数据，不自动清洗。备份与维护核准完成才设置本包维护/基线/备份确认变量。
