-- DD02只读核验设计稿；先执行04。本轮未执行。
SELECT table_name,column_name,column_type,is_nullable,column_default,extra,column_comment FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN('sys_venue','sys_dept','sys_role','sys_user','sys_group','sys_user_role','sys_dict_type','sys_dict_data','sys_oper_log','sys_data_change_log','sys_role_data_scope','sys_management_revision','sys_management_request') ORDER BY table_name,ordinal_position;
SELECT table_name,index_name,non_unique,GROUP_CONCAT(column_name ORDER BY seq_in_index) columns_in_order FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name IN('sys_venue','sys_dept','sys_role','sys_user','sys_group','sys_user_role','sys_dict_type','sys_dict_data','sys_oper_log','sys_data_change_log','sys_role_data_scope','sys_management_revision','sys_management_request') GROUP BY table_name,index_name,non_unique;
SELECT 'sys_venue' table_name,(SELECT COUNT(*) FROM sys_venue) current_rows,(SELECT COUNT(*) FROM m01b2_sys_venue) before_rows;
SELECT 'sys_dept' table_name,(SELECT COUNT(*) FROM sys_dept) current_rows,(SELECT COUNT(*) FROM m01b2_sys_dept) before_rows;
SELECT 'sys_role' table_name,(SELECT COUNT(*) FROM sys_role) current_rows,(SELECT COUNT(*) FROM m01b2_sys_role) before_rows;
SELECT 'sys_user' table_name,(SELECT COUNT(*) FROM sys_user) current_rows,(SELECT COUNT(*) FROM m01b2_sys_user) before_rows;
SELECT 'sys_group' table_name,(SELECT COUNT(*) FROM sys_group) current_rows,(SELECT COUNT(*) FROM m01b2_sys_group) before_rows;
SELECT 'sys_user_role' table_name,(SELECT COUNT(*) FROM sys_user_role) current_rows,(SELECT COUNT(*) FROM m01b2_sys_user_role) before_rows;
SELECT 'sys_dict_type' table_name,(SELECT COUNT(*) FROM sys_dict_type) current_rows,(SELECT COUNT(*) FROM m01b2_sys_dict_type) before_rows;
SELECT 'sys_dict_data' table_name,(SELECT COUNT(*) FROM sys_dict_data) current_rows,(SELECT COUNT(*) FROM m01b2_sys_dict_data) before_rows;
SELECT 'sys_oper_log' table_name,(SELECT COUNT(*) FROM sys_oper_log) current_rows,(SELECT COUNT(*) FROM m01b2_sys_oper_log) before_rows;
SELECT 'sys_data_change_log' table_name,(SELECT COUNT(*) FROM sys_data_change_log) current_rows,(SELECT COUNT(*) FROM m01b2_sys_data_change_log) before_rows;
SELECT 'sys_role_data_scope' table_name,(SELECT COUNT(*) FROM sys_role_data_scope) current_rows,(SELECT COUNT(*) FROM m01b2_sys_role_data_scope) before_rows;
-- 除sys_role_data_scope合法补齐外，迁移前后行数应相等。以下异常数量应为0。
SELECT COUNT(*) invalid_insite FROM sys_user WHERE notify_insite<>'1' OR notify_insite IS NULL;
SELECT COUNT(*) missing_scope FROM sys_role r WHERE r.del_flag='0' AND NOT EXISTS(SELECT 1 FROM sys_role_data_scope s WHERE s.role_id=r.role_id);
SELECT COUNT(*) unexpected_role_time FROM sys_user_role WHERE assigned_at IS NOT NULL;
SELECT scope_key,revision FROM sys_management_revision;
SELECT COUNT(*) request_rows FROM sys_management_request;
SELECT 'sys_group_leader.group_id' reference_name,COUNT(*) orphan_count FROM sys_group_leader a LEFT JOIN sys_group b ON a.group_id=b.group_id WHERE b.group_id IS NULL;
SELECT 'sys_group_leader.user_id' reference_name,COUNT(*) orphan_count FROM sys_group_leader a LEFT JOIN sys_user b ON a.user_id=b.user_id WHERE b.user_id IS NULL;
SELECT 'sys_group_member.group_id' reference_name,COUNT(*) orphan_count FROM sys_group_member a LEFT JOIN sys_group b ON a.group_id=b.group_id WHERE b.group_id IS NULL;
SELECT 'sys_group_member.user_id' reference_name,COUNT(*) orphan_count FROM sys_group_member a LEFT JOIN sys_user b ON a.user_id=b.user_id WHERE b.user_id IS NULL;
SELECT 'sys_user_role.user_id' reference_name,COUNT(*) orphan_count FROM sys_user_role a LEFT JOIN sys_user b ON a.user_id=b.user_id WHERE b.user_id IS NULL;
SELECT 'sys_user_role.role_id' reference_name,COUNT(*) orphan_count FROM sys_user_role a LEFT JOIN sys_role b ON a.role_id=b.role_id WHERE b.role_id IS NULL;
SELECT 'sys_role_menu.role_id' reference_name,COUNT(*) orphan_count FROM sys_role_menu a LEFT JOIN sys_role b ON a.role_id=b.role_id WHERE b.role_id IS NULL;
SELECT 'sys_role_menu.menu_id' reference_name,COUNT(*) orphan_count FROM sys_role_menu a LEFT JOIN sys_menu b ON a.menu_id=b.menu_id WHERE b.menu_id IS NULL;
SELECT 'sys_role_dept.role_id' reference_name,COUNT(*) orphan_count FROM sys_role_dept a LEFT JOIN sys_role b ON a.role_id=b.role_id WHERE b.role_id IS NULL;
SELECT 'sys_role_dept.dept_id' reference_name,COUNT(*) orphan_count FROM sys_role_dept a LEFT JOIN sys_dept b ON a.dept_id=b.dept_id WHERE b.dept_id IS NULL;
SELECT 'sys_role_data_scope.role_id' reference_name,COUNT(*) orphan_count FROM sys_role_data_scope a LEFT JOIN sys_role b ON a.role_id=b.role_id WHERE b.role_id IS NULL;
SELECT table_name,constraint_name FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND constraint_type='FOREIGN KEY';
-- 不应由DD01/DD02新增外键；系统权限/设备引用全链路必须另外运行验收。

-- 审阅补充：有效默认项唯一检查，结果应为空；也可作为初始化/修正数据前后的独立只读检查。
-- 未启用、类型停用或父项停用的数据不参加运行期默认选择。冲突不得自动选第一条。
SELECT d.dict_type,d.parent_code,COUNT(*) AS duplicate_default_count
FROM sys_dict_data d
JOIN sys_dict_type t ON t.dict_type=d.dict_type
WHERE d.is_default='Y' AND d.status='0' AND d.del_flag='0' AND t.status='0' AND t.del_flag='0'
  AND (d.parent_code=0 OR EXISTS(SELECT 1 FROM sys_dict_data p WHERE p.dict_code=d.parent_code AND p.dict_type=d.dict_type AND p.status='0' AND p.del_flag='0'))
GROUP BY d.dict_type,d.parent_code HAVING COUNT(*)>1;
