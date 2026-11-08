-- M05 后置只读设计；预期15表294列。旧列逐主键与备份逐值核对，不只看计数。
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
SELECT table_name,constraint_name,enforced FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND constraint_type='CHECK' AND table_name IN ('det_approval_assignee','det_ccpd_upload_log','det_dispatch_log','det_exception_note','det_print_export_log','det_result','det_result_item','det_result_sign_record','det_review_audit_log','det_sample','det_sample_id_history','det_sample_item','det_device_event','det_result_revision','det_result_correction');
SELECT 'nonnull_source_id' AS check_name,COUNT(*) AS invalid_rows FROM `det_result_revision` WHERE `source_id` IS NULL;
SELECT 'ck_m05_close_current_result' AS check_name,COUNT(*) AS invalid_rows FROM `det_sample` WHERE (current_result_id IS NULL OR current_result_id>0) IS FALSE;
