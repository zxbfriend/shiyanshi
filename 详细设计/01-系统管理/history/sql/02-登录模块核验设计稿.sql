-- DD01只读核验设计稿，需先完成01；本轮未连接数据库执行。
-- 查询只返回结构、数量、ID和非敏感政策，不返回密码摘要。
SELECT table_name,column_name,column_type,is_nullable,column_default,column_comment
FROM information_schema.columns WHERE table_schema=DATABASE()
AND table_name IN('sys_user','sys_user_password_history','sys_user_auth_state','sys_logininfor','sys_config')
ORDER BY table_name,ordinal_position;
SELECT table_name,index_name,non_unique,GROUP_CONCAT(column_name ORDER BY seq_in_index) AS indexed_columns
FROM information_schema.statistics WHERE table_schema=DATABASE()
AND table_name IN('sys_user','sys_user_password_history','sys_user_auth_state','sys_logininfor','sys_config')
GROUP BY table_name,index_name,non_unique;
-- 下列孤立/非法计数应全部为0。
SELECT COUNT(*) AS missing_auth_state FROM sys_user u LEFT JOIN sys_user_auth_state a ON a.user_id=u.user_id WHERE a.user_id IS NULL;
SELECT COUNT(*) AS orphan_history FROM sys_user_password_history h LEFT JOIN sys_user u ON u.user_id=h.user_id WHERE u.user_id IS NULL;
SELECT COUNT(*) AS invalid_initial_flag FROM sys_user WHERE is_initial_password NOT IN('0','1');
SELECT COUNT(*) AS nonempty_new_session FROM sys_user_auth_state WHERE current_session_key IS NOT NULL OR locked_until IS NOT NULL;
SELECT COUNT(*) AS invalid_windows FROM sys_user_auth_state WHERE JSON_TYPE(login_failures)<>'ARRAY' OR JSON_TYPE(change_failures)<>'ARRAY';
SELECT config_key,config_value FROM sys_config WHERE config_key IN
('sys.account.passwordValidateDays','sys.account.passwordRemindDays','sys.account.initPasswordModify','sys.account.passwordPolicyVersion');
SELECT dict_type,dict_value,dict_label,is_default,is_editable FROM sys_dict_data
WHERE dict_type IN('sys_auth_initial','sys_auth_pwd_change') ORDER BY dict_type,dict_sort;
SELECT COUNT(*) AS baseline_count FROM sys_user_password_history WHERE change_type='BASELINE';
SELECT COUNT(*) AS expected_baseline_count FROM dd01_bak_sys_user WHERE password IS NOT NULL AND password<>'';
SELECT (SELECT COUNT(*) FROM sys_user) AS current_users,(SELECT COUNT(*) FROM dd01_bak_sys_user) AS before_users;
SELECT (SELECT COUNT(*) FROM sys_logininfor) AS current_login_rows,(SELECT COUNT(*) FROM dd01_bak_logininfor) AS before_login_rows;
SELECT constraint_name,table_name FROM information_schema.table_constraints
WHERE constraint_schema=DATABASE() AND constraint_type='FOREIGN KEY'
AND table_name IN('sys_user','sys_user_password_history','sys_user_auth_state','sys_logininfor','sys_config');
-- 预期不新增任何外键。初始密码标记的正确性须应用bcrypt核验，SQL不能证明。
