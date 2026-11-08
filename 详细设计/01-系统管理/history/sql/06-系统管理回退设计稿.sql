-- 部分失败禁止直接执行整批回退；先保留现场/备份，核实已完成DDL与新写入，按主设计第24节形成逐表恢复清单。不得先删除备份或失败版本再重跑。
-- DD02回退设计稿，未执行；仅完整迁移后、停写且无任何新业务写入。
-- 先回退DD02，再按需要回退DD01。已有新数据时不得覆盖旧备份。
SET @m01_rollback_reviewed=0;
DELIMITER $$
CREATE PROCEDURE m01_dd02_rollback_check()
BEGIN
 IF COALESCE(@m01_rollback_reviewed,0)<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Review rollback and prove no new writes'; END IF;
 IF EXISTS(SELECT 1 FROM sys_management_revision WHERE revision<>0)
  OR EXISTS(SELECT 1 FROM sys_management_request)
  OR EXISTS(SELECT 1 FROM sys_user u JOIN m01b2_sys_user b ON u.user_id=b.user_id WHERE u.credential_version<>b.credential_version OR NOT(u.password <=> b.password)) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Post-migration writes detected; no backup overwrite';
 END IF;
END$$
DELIMITER ;
CALL m01_dd02_rollback_check();
DROP PROCEDURE m01_dd02_rollback_check;
-- 检查不覆盖所有业务路径，不能替代停写证据；保留失败版本而非DROP。
RENAME TABLE
 sys_venue TO m01f2_sys_venue,
 m01b2_sys_venue TO sys_venue,
 sys_dept TO m01f2_sys_dept,
 m01b2_sys_dept TO sys_dept,
 sys_role TO m01f2_sys_role,
 m01b2_sys_role TO sys_role,
 sys_user TO m01f2_sys_user,
 m01b2_sys_user TO sys_user,
 sys_group TO m01f2_sys_group,
 m01b2_sys_group TO sys_group,
 sys_user_role TO m01f2_sys_user_role,
 m01b2_sys_user_role TO sys_user_role,
 sys_dict_type TO m01f2_sys_dict_type,
 m01b2_sys_dict_type TO sys_dict_type,
 sys_dict_data TO m01f2_sys_dict_data,
 m01b2_sys_dict_data TO sys_dict_data,
 sys_oper_log TO m01f2_sys_oper_log,
 m01b2_sys_oper_log TO sys_oper_log,
 sys_data_change_log TO m01f2_sys_data_change_log,
 m01b2_sys_data_change_log TO sys_data_change_log,
 sys_role_data_scope TO m01f2_sys_role_data_scope,
 m01b2_sys_role_data_scope TO sys_role_data_scope,
 sys_management_revision TO m01f2_sys_management_revision,
 sys_management_request TO m01f2_sys_management_request;
-- 04部分失败不可直接执行该整批回退；核对已完成DDL与备份逐表恢复。
