-- M03 SQL设计稿；2026-09-09；未在数据库执行。MySQL 8.0.16+，须在实际小版本隔离演练。
-- 先读主设计第5/6节。逐阶段执行，错误立即停止；DDL隐式提交，不能整包盲跑。
-- 旧datetime与M01审计保持上海业务时区；明确标UTC的新列仅写UTC值。
SET NAMES utf8mb4;
SET SESSION time_zone = '+08:00';

-- 只读，任何异常需核准处理；本文件不输出业务记录全文。
SELECT VERSION() AS mysql_version, DATABASE() AS current_database, @@sql_mode AS sql_mode;
SELECT TABLE_NAME,COLUMN_NAME,COLUMN_TYPE,IS_NULLABLE,COLUMN_DEFAULT,COLLATION_NAME,EXTRA FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME IN ('res_project','res_project_leader','res_project_lab','res_project_tag','res_project_member','res_batch','res_batch_leader','res_batch_member','res_culture','res_culture_leader','res_culture_member') ORDER BY TABLE_NAME,ORDINAL_POSITION;
SELECT TABLE_NAME,INDEX_NAME,NON_UNIQUE,SEQ_IN_INDEX,COLUMN_NAME FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME IN ('res_project','res_project_leader','res_project_lab','res_project_tag','res_project_member','res_batch','res_batch_leader','res_batch_member','res_culture','res_culture_leader','res_culture_member') ORDER BY TABLE_NAME,INDEX_NAME,SEQ_IN_INDEX;
SELECT scope_key,revision FROM sys_management_revision WHERE scope_key='SYSTEM';
SELECT 'res_project' AS table_name,COUNT(*) AS row_count FROM `res_project`;
SELECT 'res_project_leader' AS table_name,COUNT(*) AS row_count FROM `res_project_leader`;
SELECT 'res_project_lab' AS table_name,COUNT(*) AS row_count FROM `res_project_lab`;
SELECT 'res_project_tag' AS table_name,COUNT(*) AS row_count FROM `res_project_tag`;
SELECT 'res_project_member' AS table_name,COUNT(*) AS row_count FROM `res_project_member`;
SELECT 'res_batch' AS table_name,COUNT(*) AS row_count FROM `res_batch`;
SELECT 'res_batch_leader' AS table_name,COUNT(*) AS row_count FROM `res_batch_leader`;
SELECT 'res_batch_member' AS table_name,COUNT(*) AS row_count FROM `res_batch_member`;
SELECT 'res_culture' AS table_name,COUNT(*) AS row_count FROM `res_culture`;
SELECT 'res_culture_leader' AS table_name,COUNT(*) AS row_count FROM `res_culture_leader`;
SELECT 'res_culture_member' AS table_name,COUNT(*) AS row_count FROM `res_culture_member`;
SELECT 'res_project_invalid_delete_flag' AS check_name,COUNT(*) AS violation_count FROM `res_project` WHERE del_flag IS NULL OR del_flag NOT IN ('0','2');
SELECT 'res_project_blank_code' AS check_name,COUNT(*) AS violation_count FROM `res_project` WHERE CHAR_LENGTH(TRIM(project_code))=0;
SELECT 'res_project_creator_unmatched' AS check_name,COUNT(*) AS violation_count FROM `res_project` t WHERE t.del_flag='0' AND (SELECT COUNT(*) FROM sys_user u WHERE BINARY u.user_name=BINARY t.create_by)<>1;
SELECT 'res_batch_invalid_delete_flag' AS check_name,COUNT(*) AS violation_count FROM `res_batch` WHERE del_flag IS NULL OR del_flag NOT IN ('0','2');
SELECT 'res_batch_blank_code' AS check_name,COUNT(*) AS violation_count FROM `res_batch` WHERE CHAR_LENGTH(TRIM(batch_code))=0;
SELECT 'res_batch_creator_unmatched' AS check_name,COUNT(*) AS violation_count FROM `res_batch` t WHERE t.del_flag='0' AND (SELECT COUNT(*) FROM sys_user u WHERE BINARY u.user_name=BINARY t.create_by)<>1;
SELECT 'res_culture_invalid_delete_flag' AS check_name,COUNT(*) AS violation_count FROM `res_culture` WHERE del_flag IS NULL OR del_flag NOT IN ('0','2');
SELECT 'res_culture_blank_code' AS check_name,COUNT(*) AS violation_count FROM `res_culture` WHERE CHAR_LENGTH(TRIM(culture_code))=0;
SELECT 'res_culture_creator_unmatched' AS check_name,COUNT(*) AS violation_count FROM `res_culture` t WHERE t.del_flag='0' AND (SELECT COUNT(*) FROM sys_user u WHERE BINARY u.user_name=BINARY t.create_by)<>1;

-- 当前培养Mapper按全局del_flag=0查重，但旧索引仍是批次内，取消尚未从Mapper占号范围排除。
SELECT 'culture_live_global_duplicates' AS check_name,COUNT(*) AS duplicate_groups FROM (SELECT TRIM(culture_code) FROM res_culture WHERE del_flag='0' GROUP BY TRIM(culture_code) HAVING COUNT(*)>1) q;
SELECT culture_status,culture_mode,reactor_type,del_flag,COUNT(*) AS row_count FROM res_culture GROUP BY culture_status,culture_mode,reactor_type,del_flag;
SELECT 'legacy_time_needs_review' AS check_name,COUNT(*) AS row_count FROM res_culture WHERE start_time IS NOT NULL OR end_time IS NOT NULL;
SELECT 'batch_parent_or_lab_missing' AS check_name,COUNT(*) AS violation_count FROM res_batch b LEFT JOIN res_project p ON p.project_id=b.project_id LEFT JOIN lab_lab l ON l.lab_id=b.lab_id WHERE p.project_id IS NULL OR l.lab_id IS NULL OR (b.del_flag='0' AND p.del_flag<>'0');
SELECT 'culture_parent_mismatch' AS check_name,COUNT(*) AS violation_count FROM res_culture c LEFT JOIN res_batch b ON b.batch_id=c.batch_id WHERE b.batch_id IS NULL OR c.project_id<>b.project_id OR c.lab_id<>b.lab_id OR (c.del_flag='0' AND b.del_flag<>'0');
SELECT 'batch_lab_not_in_project' AS check_name,COUNT(*) AS violation_count FROM res_batch b LEFT JOIN res_project_lab r ON r.project_id=b.project_id AND r.lab_id=b.lab_id WHERE b.del_flag='0' AND r.project_id IS NULL;
SELECT 'res_project_member' AS table_name,permission_type,source_type,COUNT(*) AS row_count FROM `res_project_member` GROUP BY permission_type,source_type;
SELECT 'res_project_member_orphan' AS check_name,COUNT(*) AS violation_count FROM `res_project_member` r LEFT JOIN res_project p ON p.project_id=r.project_id LEFT JOIN sys_user u ON u.user_id=r.user_id WHERE p.project_id IS NULL OR u.user_id IS NULL;
SELECT 'res_batch_member' AS table_name,permission_type,source_type,COUNT(*) AS row_count FROM `res_batch_member` GROUP BY permission_type,source_type;
SELECT 'res_batch_member_orphan' AS check_name,COUNT(*) AS violation_count FROM `res_batch_member` r LEFT JOIN res_batch p ON p.batch_id=r.batch_id LEFT JOIN sys_user u ON u.user_id=r.user_id WHERE p.batch_id IS NULL OR u.user_id IS NULL;
SELECT 'res_culture_member' AS table_name,permission_type,source_type,COUNT(*) AS row_count FROM `res_culture_member` GROUP BY permission_type,source_type;
SELECT 'res_culture_member_orphan' AS check_name,COUNT(*) AS violation_count FROM `res_culture_member` r LEFT JOIN res_culture p ON p.culture_id=r.culture_id LEFT JOIN sys_user u ON u.user_id=r.user_id WHERE p.culture_id IS NULL OR u.user_id IS NULL;
SELECT 'res_project_leader_orphan' AS check_name,COUNT(*) AS violation_count FROM `res_project_leader` r LEFT JOIN res_project p ON p.project_id=r.project_id LEFT JOIN sys_user u ON u.user_id=r.user_id WHERE p.project_id IS NULL OR u.user_id IS NULL;
SELECT 'res_batch_leader_orphan' AS check_name,COUNT(*) AS violation_count FROM `res_batch_leader` r LEFT JOIN res_batch p ON p.batch_id=r.batch_id LEFT JOIN sys_user u ON u.user_id=r.user_id WHERE p.batch_id IS NULL OR u.user_id IS NULL;
SELECT 'res_culture_leader_orphan' AS check_name,COUNT(*) AS violation_count FROM `res_culture_leader` r LEFT JOIN res_culture p ON p.culture_id=r.culture_id LEFT JOIN sys_user u ON u.user_id=r.user_id WHERE p.culture_id IS NULL OR u.user_id IS NULL;
