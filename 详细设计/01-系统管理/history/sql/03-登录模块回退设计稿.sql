-- 部分失败禁止直接执行整批回退；先保留现场/备份，核实已完成DDL与新写入，按主设计第24节形成逐表恢复清单。不得先删除备份或失败版本再重跑。
-- DD01回退设计稿，本轮未执行。
-- 仅限01已完整执行、仍处停写窗口、尚无新业务写入的场景。
-- 若已开放新业务：先停写并备份新状态，使用保留新认证规则的兼容应用恢复；
-- 不得运行本文件把新口令/历史覆盖成旧数据。MySQL DDL不按事务整体回滚。
SET @dd01_rollback_reviewed = 0;
DELIMITER $$
CREATE PROCEDURE dd01_rollback_check()
BEGIN
 IF COALESCE(@dd01_rollback_reviewed,0)<>1 THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rollback requires review and no post-migration writes';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_user WHERE credential_version<>0)
   OR EXISTS(SELECT 1 FROM sys_user_auth_state WHERE version<>0 OR session_version<>0)
   OR EXISTS(SELECT 1 FROM sys_user_password_history WHERE change_type NOT IN('LEGACY','BASELINE')) THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New authentication writes exist: no destructive schema rollback';
 END IF;
END$$
DELIMITER ;
CALL dd01_rollback_check();
DROP PROCEDURE dd01_rollback_check;
-- 原子重命名恢复原始表；失败版本仍留存，不删除。
RENAME TABLE
 sys_user TO dd01_failed_sys_user, dd01_bak_sys_user TO sys_user,
 sys_user_password_history TO dd01_failed_pwd_history, dd01_bak_pwd_history TO sys_user_password_history,
 sys_config TO dd01_failed_sys_config, dd01_bak_sys_config TO sys_config,
 sys_logininfor TO dd01_failed_logininfor, dd01_bak_logininfor TO sys_logininfor,
 sys_dict_type TO dd01_failed_dict_type, dd01_bak_dict_type TO sys_dict_type,
 sys_dict_data TO dd01_failed_dict_data, dd01_bak_dict_data TO sys_dict_data,
 sys_user_auth_state TO dd01_failed_auth_state;
-- 清理并重建认证相关缓存、检查旧应用兼容、强制重新登录后再开放。
-- 01部分失败时按已完成语句清单逐项恢复，不能直接调用此完整回退脚本。
