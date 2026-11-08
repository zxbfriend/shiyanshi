-- DD02 / MySQL 8.0 / 设计稿，未连接数据库执行。
-- 前提：按当前版本完整执行DD01并核验；目标库停写、全库备份及评审完成。
-- 客户端必须遇错停止，禁止--force；DDL不能用ROLLBACK整体撤销。
SET @m01_reviewed=0;
SET time_zone='+08:00';
DELIMITER $$
CREATE PROCEDURE m01_dd02_preflight()
BEGIN
 IF COALESCE(@m01_reviewed,0)<>1 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='DD02 design only: review and maintenance window required';
 END IF;
 IF DATABASE() IS NULL THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Select reviewed target database';
 END IF;
 IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='sys_user' AND column_name='active_user_name') THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Current DD01 must be completed first';
 END IF;
 IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND (table_name IN('m01b2_sys_venue','m01b2_sys_dept','m01b2_sys_role','m01b2_sys_user','m01b2_sys_group','m01b2_sys_user_role','m01b2_sys_dict_type','m01b2_sys_dict_data','m01b2_sys_oper_log','m01b2_sys_data_change_log','m01b2_sys_role_data_scope') OR table_name IN('sys_management_revision','sys_management_request'))) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Existing DD02 objects: inspect partial execution, do not rerun';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_venue WHERE del_flag='0' GROUP BY COALESCE(parent_id,0),venue_name HAVING COUNT(*)>1) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Duplicate active venue sibling name';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_venue WHERE del_flag='0' GROUP BY venue_code HAVING COUNT(*)>1) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Duplicate active venue code';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_venue WHERE del_flag='0' AND (venue_name IS NULL OR TRIM(venue_name)='' OR venue_code IS NULL OR TRIM(venue_code)='')) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Missing active venue name or code';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_venue c LEFT JOIN sys_venue p ON p.venue_id=c.parent_id AND p.del_flag='0' WHERE c.del_flag='0' AND COALESCE(c.parent_id,0)<>0 AND p.venue_id IS NULL) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Orphan venue parent';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_dept WHERE del_flag='0' GROUP BY COALESCE(parent_id,0),dept_name HAVING COUNT(*)>1) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Duplicate active dept sibling name';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_dept WHERE del_flag='0' GROUP BY dept_code HAVING COUNT(*)>1) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Duplicate active dept code';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_dept WHERE del_flag='0' AND (dept_name IS NULL OR TRIM(dept_name)='' OR dept_code IS NULL OR TRIM(dept_code)='')) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Missing active dept name or code';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_dept c LEFT JOIN sys_dept p ON p.dept_id=c.parent_id AND p.del_flag='0' WHERE c.del_flag='0' AND COALESCE(c.parent_id,0)<>0 AND p.dept_id IS NULL) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Orphan dept parent';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_group WHERE del_flag='0' GROUP BY group_name HAVING COUNT(*)>1) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Duplicate sys_group.group_name';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_group WHERE del_flag='0' AND group_code IS NOT NULL AND group_code<>'' GROUP BY group_code HAVING COUNT(*)>1) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Duplicate sys_group.group_code';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_role WHERE del_flag='0' GROUP BY role_name HAVING COUNT(*)>1) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Duplicate sys_role.role_name';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_role WHERE del_flag='0' GROUP BY role_key HAVING COUNT(*)>1) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Duplicate sys_role.role_key';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_dict_type WHERE del_flag='0' GROUP BY dict_name HAVING COUNT(*)>1) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Duplicate sys_dict_type.dict_name';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_dict_data WHERE del_flag='0' GROUP BY dict_type,dict_value HAVING COUNT(*)>1) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Duplicate active dictionary dict_value';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_dict_data WHERE del_flag='0' GROUP BY dict_type,dict_label HAVING COUNT(*)>1) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Duplicate active dictionary dict_label';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_group_leader a LEFT JOIN sys_group b ON a.group_id=b.group_id WHERE b.group_id IS NULL) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Orphan sys_group_leader.group_id';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_group_leader a LEFT JOIN sys_user b ON a.user_id=b.user_id WHERE b.user_id IS NULL) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Orphan sys_group_leader.user_id';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_group_member a LEFT JOIN sys_group b ON a.group_id=b.group_id WHERE b.group_id IS NULL) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Orphan sys_group_member.group_id';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_group_member a LEFT JOIN sys_user b ON a.user_id=b.user_id WHERE b.user_id IS NULL) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Orphan sys_group_member.user_id';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_user_role a LEFT JOIN sys_user b ON a.user_id=b.user_id WHERE b.user_id IS NULL) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Orphan sys_user_role.user_id';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_user_role a LEFT JOIN sys_role b ON a.role_id=b.role_id WHERE b.role_id IS NULL) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Orphan sys_user_role.role_id';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_role_menu a LEFT JOIN sys_role b ON a.role_id=b.role_id WHERE b.role_id IS NULL) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Orphan sys_role_menu.role_id';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_role_menu a LEFT JOIN sys_menu b ON a.menu_id=b.menu_id WHERE b.menu_id IS NULL) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Orphan sys_role_menu.menu_id';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_role_dept a LEFT JOIN sys_role b ON a.role_id=b.role_id WHERE b.role_id IS NULL) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Orphan sys_role_dept.role_id';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_role_dept a LEFT JOIN sys_dept b ON a.dept_id=b.dept_id WHERE b.dept_id IS NULL) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Orphan sys_role_dept.dept_id';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_role_data_scope a LEFT JOIN sys_role b ON a.role_id=b.role_id WHERE b.role_id IS NULL) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Orphan sys_role_data_scope.role_id';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_role WHERE del_flag='0' AND (data_scope IS NULL OR data_scope NOT IN('1','2','3','4','5')) AND NOT EXISTS(SELECT 1 FROM sys_role_data_scope s WHERE s.role_id=sys_role.role_id)) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unknown legacy role scope; never default to ALL';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_role_data_scope WHERE scope_type NOT IN('1','2','3','4','5')) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid multi role scope';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_role r WHERE r.del_flag='0'
   AND (EXISTS(SELECT 1 FROM sys_role_data_scope s WHERE s.role_id=r.role_id AND s.scope_type='2')
     OR (r.data_scope='2' AND NOT EXISTS(SELECT 1 FROM sys_role_data_scope s WHERE s.role_id=r.role_id)))
   AND NOT EXISTS(SELECT 1 FROM sys_role_dept d WHERE d.role_id=r.role_id)) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Custom scope has no departments: review legacy authorization';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_dict_data d LEFT JOIN sys_dict_type t ON t.dict_type=d.dict_type WHERE d.del_flag='0' AND (t.dict_id IS NULL OR t.del_flag<>'0')) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Orphan dictionary type';
 END IF;
 IF EXISTS(SELECT 1 FROM sys_dict_data d LEFT JOIN sys_dict_data p ON p.dict_code=d.parent_code WHERE d.del_flag='0' AND COALESCE(d.parent_code,0)<>0 AND (p.dict_code IS NULL OR p.del_flag<>'0' OR p.dict_type<>d.dict_type OR p.parent_code<>0)) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid dictionary second level';
 END IF;
 IF (WITH RECURSIVE reachable AS (
   SELECT dept_id FROM sys_dept WHERE del_flag='0' AND COALESCE(parent_id,0)=0
   UNION ALL SELECT c.dept_id FROM sys_dept c JOIN reachable r ON c.parent_id=r.dept_id WHERE c.del_flag='0'
 ) SELECT COUNT(*) FROM reachable) <> (SELECT COUNT(*) FROM sys_dept WHERE del_flag='0') THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unreachable/cyclic dept tree';
 END IF;
 IF (WITH RECURSIVE reachable AS (
   SELECT venue_id FROM sys_venue WHERE del_flag='0' AND COALESCE(parent_id,0)=0
   UNION ALL SELECT c.venue_id FROM sys_venue c JOIN reachable r ON c.parent_id=r.venue_id WHERE c.del_flag='0'
 ) SELECT COUNT(*) FROM reachable) <> (SELECT COUNT(*) FROM sys_venue WHERE del_flag='0') THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unreachable/cyclic venue tree';
 END IF;
END$$
DELIMITER ;
CALL m01_dd02_preflight();
DROP PROCEDURE m01_dd02_preflight;

CREATE TABLE m01b2_sys_venue LIKE sys_venue;
INSERT INTO m01b2_sys_venue SELECT * FROM sys_venue;
CREATE TABLE m01b2_sys_dept LIKE sys_dept;
INSERT INTO m01b2_sys_dept SELECT * FROM sys_dept;
CREATE TABLE m01b2_sys_role LIKE sys_role;
INSERT INTO m01b2_sys_role SELECT * FROM sys_role;
CREATE TABLE m01b2_sys_user LIKE sys_user;
-- active_user_name为DD01生成列，备份插入必须省略，由目标表自动计算。
INSERT INTO m01b2_sys_user(`user_id`,`dept_id`,`user_name`,`nick_name`,`user_type`,`email`,`phonenumber`,`sex`,`avatar`,`password`,`status`,`del_flag`,`login_ip`,`login_date`,`pwd_update_date`,`password_valid_days`,`create_by`,`create_time`,`update_by`,`update_time`,`remark`,`notify_email`,`notify_sms`,`notify_insite`,`login_count`,`is_initial_password`,`credential_version`) SELECT `user_id`,`dept_id`,`user_name`,`nick_name`,`user_type`,`email`,`phonenumber`,`sex`,`avatar`,`password`,`status`,`del_flag`,`login_ip`,`login_date`,`pwd_update_date`,`password_valid_days`,`create_by`,`create_time`,`update_by`,`update_time`,`remark`,`notify_email`,`notify_sms`,`notify_insite`,`login_count`,`is_initial_password`,`credential_version` FROM sys_user;
CREATE TABLE m01b2_sys_group LIKE sys_group;
INSERT INTO m01b2_sys_group SELECT * FROM sys_group;
CREATE TABLE m01b2_sys_user_role LIKE sys_user_role;
INSERT INTO m01b2_sys_user_role SELECT * FROM sys_user_role;
CREATE TABLE m01b2_sys_dict_type LIKE sys_dict_type;
INSERT INTO m01b2_sys_dict_type SELECT * FROM sys_dict_type;
CREATE TABLE m01b2_sys_dict_data LIKE sys_dict_data;
INSERT INTO m01b2_sys_dict_data SELECT * FROM sys_dict_data;
CREATE TABLE m01b2_sys_oper_log LIKE sys_oper_log;
INSERT INTO m01b2_sys_oper_log SELECT * FROM sys_oper_log;
CREATE TABLE m01b2_sys_data_change_log LIKE sys_data_change_log;
INSERT INTO m01b2_sys_data_change_log SELECT * FROM sys_data_change_log;
CREATE TABLE m01b2_sys_role_data_scope LIKE sys_role_data_scope;
INSERT INTO m01b2_sys_role_data_scope SELECT * FROM sys_role_data_scope;

-- 不伪造历史时间；站内必选是确认的业务变更。
UPDATE sys_user SET notify_insite='1';
UPDATE sys_dept SET parent_id=0 WHERE parent_id IS NULL;
UPDATE sys_venue SET parent_id=0 WHERE parent_id IS NULL;

ALTER TABLE sys_venue
  MODIFY COLUMN ancestors varchar(2000) NULL DEFAULT '' COMMENT '祖先ID链，0开头逗号分隔；应用防环且不得截断',
  MODIFY COLUMN parent_id bigint NOT NULL DEFAULT 0 COMMENT '上级主键，逻辑关联本表主键；根为0，无外键',
  ADD COLUMN active_venue_name varchar(50) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN venue_name ELSE NULL END) STORED COMMENT '未删除记录唯一校验生成键，删除后NULL',
  ADD COLUMN active_venue_code varchar(50) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN venue_code ELSE NULL END) STORED COMMENT '未删除记录唯一校验生成键，删除后NULL',
  ADD UNIQUE INDEX uk_m01_venue_name(parent_id,active_venue_name),
  ADD UNIQUE INDEX uk_m01_venue_code(active_venue_code);

ALTER TABLE sys_dept
  MODIFY COLUMN ancestors varchar(2000) NULL DEFAULT '' COMMENT '祖先ID链，0开头逗号分隔；应用防环且不得截断',
  MODIFY COLUMN parent_id bigint NOT NULL DEFAULT 0 COMMENT '上级主键，逻辑关联本表主键；根为0，无外键',
  ADD COLUMN active_dept_name varchar(50) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN dept_name ELSE NULL END) STORED COMMENT '未删除记录唯一校验生成键，删除后NULL',
  ADD COLUMN active_dept_code varchar(50) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN dept_code ELSE NULL END) STORED COMMENT '未删除记录唯一校验生成键，删除后NULL',
  ADD UNIQUE INDEX uk_m01_dept_name(parent_id,active_dept_name),
  ADD UNIQUE INDEX uk_m01_dept_code(active_dept_code);

ALTER TABLE sys_role
  MODIFY COLUMN remark varchar(1000) NULL DEFAULT NULL COMMENT '角色描述，最多1000字符',
  ADD COLUMN active_role_name varchar(30) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN role_name ELSE NULL END) STORED COMMENT '有效角色唯一生成键',
  ADD COLUMN active_role_key varchar(100) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN role_key ELSE NULL END) STORED COMMENT '有效角色唯一生成键',
  ADD UNIQUE INDEX uk_m01_role_name(active_role_name),
  ADD UNIQUE INDEX uk_m01_role_key(active_role_key);

ALTER TABLE sys_user
  MODIFY COLUMN notify_insite char(1) NOT NULL DEFAULT '1' COMMENT '站内通知固定1必选；0是历史关闭值不再允许';

ALTER TABLE sys_group
  DROP INDEX uk_sys_group_name_del,
  DROP INDEX uk_sys_group_code_del,
  ADD COLUMN active_group_name varchar(20) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN group_name ELSE NULL END) STORED COMMENT '有效实验组唯一键；删除及空编码不占唯一性',
  ADD COLUMN active_group_code varchar(50) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN NULLIF(group_code,'') ELSE NULL END) STORED COMMENT '有效实验组唯一键；删除及空编码不占唯一性',
  ADD UNIQUE INDEX uk_m01_group_name(active_group_name),
  ADD UNIQUE INDEX uk_m01_group_code(active_group_code);

ALTER TABLE sys_user_role
  ADD COLUMN assigned_at datetime(3) NULL DEFAULT NULL COMMENT '角色关联时间，旧记录无依据保留NULL，新增必须写入';

ALTER TABLE sys_dict_type
  ADD COLUMN active_dict_name varchar(100) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN dict_name ELSE NULL END) STORED COMMENT '有效字典名称唯一键',
  ADD UNIQUE INDEX uk_m01_dict_name(active_dict_name);

ALTER TABLE sys_dict_data
  ADD COLUMN active_dict_value varchar(100) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN dict_value ELSE NULL END) STORED COMMENT '当前类型内有效字典项唯一键',
  ADD COLUMN active_dict_label varchar(100) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN dict_label ELSE NULL END) STORED COMMENT '当前类型内有效字典项唯一键',
  ADD UNIQUE INDEX uk_m01_dict_value(dict_type,active_dict_value),
  ADD UNIQUE INDEX uk_m01_dict_label(dict_type,active_dict_label);

ALTER TABLE sys_oper_log
  MODIFY COLUMN status int NULL DEFAULT 0 COMMENT '操作状态（0成功 1失败），字典：系统状态',
  ADD COLUMN user_id bigint NULL DEFAULT NULL COMMENT '操作者ID，逻辑关联sys_user.user_id，旧记录未知NULL',
  ADD COLUMN nick_name varchar(50) NULL DEFAULT NULL COMMENT '操作者当时显示名快照',
  ADD COLUMN request_id varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT '操作请求ID，关联管理回执及链路',
  ADD INDEX idx_m01_oper_request(request_id),
  ADD INDEX idx_m01_oper_user_time(user_id,oper_time);

ALTER TABLE sys_data_change_log
  ADD INDEX idx_m01_change_oper(oper_id);

CREATE TABLE sys_management_revision (
 scope_key varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '固定SYSTEM；系统管理事务守卫键',
 revision bigint NOT NULL DEFAULT 0 COMMENT '管理数据版本，每次成功管理变更递增',
 update_time datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '最近管理变更时间',
 PRIMARY KEY(scope_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统管理版本与事务守卫';
CREATE TABLE sys_management_request (
 actor_user_id bigint NOT NULL COMMENT '操作者，逻辑关联sys_user.user_id，无外键',
 request_id varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '请求UUID，同操作者唯一',
 operation_code varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '本设计接口动作编码ORG/ACL/USR/DIC/CFG及序号',
 payload_hash char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '规范化请求的HMAC-SHA256十六进制摘要，不记录敏感原文',
 result_json json NOT NULL COMMENT '完整W成功结果，不含敏感信息，和业务同事务提交',
 create_time datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '提交时间',
 expires_at datetime(3) NOT NULL COMMENT '回执到期，创建后24小时',
 PRIMARY KEY(actor_user_id,request_id),
 INDEX idx_m01_request_expiry(expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统管理写请求幂等回执';
START TRANSACTION;
INSERT INTO sys_management_revision(scope_key,revision) VALUES('SYSTEM',0);
INSERT INTO sys_role_data_scope(role_id,scope_type)
SELECT r.role_id,r.data_scope FROM sys_role r WHERE r.del_flag='0' AND r.data_scope IN('1','2','3','4','5')
AND NOT EXISTS(SELECT 1 FROM sys_role_data_scope s WHERE s.role_id=r.role_id);
COMMIT;
-- 后续执行05只读核验、全模块应用升级与权限缓存刷新；未完成不得开放写入。
