-- 只读设计稿；选择已核准隔离库，先完整比对20目标的列类型/索引/CHECK，不以数量相等冒充结构一致。
SELECT DATABASE() AS target_schema,VERSION() AS mysql_version;
SELECT table_name,column_name,column_type,is_nullable,extra FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('det_approval_assignee','det_ccpd_upload_log','det_dispatch_log','det_exception_note','det_print_export_log','det_result','det_result_item','det_result_sign_record','det_review_audit_log','det_sample','det_sample_id_history','det_sample_item','det_device_event','det_result_revision') ORDER BY table_name,ordinal_position;
SELECT COUNT(*) AS source_id_missing FROM det_result_revision WHERE source_id IS NULL OR source_id<=0;
SELECT COUNT(*) AS unexpected_correction_table FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='det_result_correction';
SELECT COUNT(*) AS unexpected_pointer FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result' AND column_name='current_correction_id';
-- 原14表267列、零未知目标结构；维护期间备份14表及证据对象，记录可恢复备份引用。
-- 维护人另行设置 @m05_corr_maintenance_confirmed=1、@m05_corr_baseline_verified=1、@m05_corr_backup_ref=非空可恢复备份记录ID。
