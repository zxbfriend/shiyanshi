-- DD01 / MySQL 8.0 / 设计稿：本轮未执行。
-- 仅适用于字段字典记录的 ymsw.sql 基线；目标环境先核实并备份。
-- 不导入cdp/npp数据，不建立外键。客户端必须遇错停止，禁止使用 --force。
-- 评审/停写/全库备份完成后才把下一行改成1。一次性执行，不支持盲目重跑。
SET @dd01_reviewed = 0;
-- Q08已确认（2026-09-09）：缺失有效期90天、缺失提醒5天；合法配置保留，旧有效期0改90。其他非法值仍预检阻断。本脚本未执行。
SET @dd01_valid_days = 90;
SET @dd01_remind_days = 5;
SET time_zone = '+08:00';

DELIMITER $$
CREATE PROCEDURE dd01_preflight()
BEGIN
  IF COALESCE(@dd01_reviewed,0) <> 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='DD01 design only: review and maintenance window required';
  END IF;
  IF DATABASE() IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Select reviewed target database first';
  END IF;
  IF @dd01_valid_days IS NULL OR @dd01_remind_days IS NULL
    OR @dd01_valid_days NOT BETWEEN 1 AND 100 OR @dd01_remind_days NOT BETWEEN 1 AND 15
    OR @dd01_valid_days<>FLOOR(@dd01_valid_days) OR @dd01_remind_days<>FLOOR(@dd01_remind_days) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid migration policy';
  END IF;
  IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE()
    AND table_name IN ('dd01_bak_sys_user','dd01_bak_pwd_history','dd01_bak_sys_config',
      'dd01_bak_logininfor','dd01_bak_dict_type','dd01_bak_dict_data','sys_user_auth_state')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Existing DD01 backup/new table: do not rerun';
  END IF;
  IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE()
    AND table_name='sys_user' AND column_name IN ('is_initial_password','credential_version')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Target differs from reviewed DD01 baseline';
  END IF;
  IF EXISTS(SELECT 1 FROM sys_user WHERE del_flag='0' GROUP BY user_name HAVING COUNT(*)>1)
    OR EXISTS(SELECT 1 FROM sys_user WHERE del_flag='0' AND (user_name='' OR user_name<>TRIM(user_name))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Duplicate or noncanonical usernames: resolve explicitly';
  END IF;
  IF EXISTS(SELECT 1 FROM sys_config GROUP BY config_key HAVING COUNT(*)>1)
    OR EXISTS(SELECT 1 FROM sys_config WHERE config_key IS NULL OR config_key='') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Duplicate or empty config keys';
  END IF;
  IF EXISTS(SELECT 1 FROM sys_user_password_history
    WHERE user_id NOT REGEXP '^[1-9][0-9]{0,18}$'
       OR CAST(user_id AS DECIMAL(20,0))>9223372036854775807) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='History user_id cannot safely convert to bigint';
  END IF;
  IF EXISTS(SELECT 1 FROM sys_user_password_history h LEFT JOIN sys_user u
    ON u.user_id=CAST(h.user_id AS UNSIGNED) WHERE u.user_id IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Orphan password history: resolve without deleting history';
  END IF;
  IF EXISTS(SELECT 1 FROM sys_user_password_history WHERE create_time IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unknown history ordering: supply evidence before migration';
  END IF;
  IF EXISTS(SELECT 1 FROM sys_dict_type WHERE dict_type IN ('sys_auth_initial','sys_auth_pwd_change'))
    OR EXISTS(SELECT 1 FROM sys_dict_data WHERE dict_type IN ('sys_auth_initial','sys_auth_pwd_change')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Dictionary already exists: compare rather than overwrite';
  END IF;
  IF EXISTS(SELECT 1 FROM sys_config WHERE config_key='sys.account.passwordValidateDays'
    AND (config_value IS NULL OR config_value NOT REGEXP '^[0-9]+$' OR CAST(config_value AS UNSIGNED)>100))
    OR EXISTS(SELECT 1 FROM sys_config WHERE config_key='sys.account.passwordRemindDays'
    AND (config_value IS NULL OR config_value NOT REGEXP '^[0-9]+$' OR CAST(config_value AS UNSIGNED) NOT BETWEEN 1 AND 15)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Existing policy outside supported range';
  END IF;
  IF EXISTS(SELECT 1 FROM sys_config WHERE config_key='sys.account.passwordPolicyVersion'
    AND (config_value IS NULL OR config_value NOT REGEXP '^[1-9][0-9]{0,18}$'
      OR CAST(config_value AS DECIMAL(20,0))>=9223372036854775807)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Existing policy version invalid or exhausted';
  END IF;
END$$
DELIMITER ;
CALL dd01_preflight();
DROP PROCEDURE dd01_preflight;

-- 停写后建立本批次原样备份；备份含口令摘要，使用与原表相同访问保护。
CREATE TABLE dd01_bak_sys_user LIKE sys_user;
INSERT INTO dd01_bak_sys_user SELECT * FROM sys_user;
CREATE TABLE dd01_bak_pwd_history LIKE sys_user_password_history;
INSERT INTO dd01_bak_pwd_history SELECT * FROM sys_user_password_history;
CREATE TABLE dd01_bak_sys_config LIKE sys_config;
INSERT INTO dd01_bak_sys_config SELECT * FROM sys_config;
CREATE TABLE dd01_bak_logininfor LIKE sys_logininfor;
INSERT INTO dd01_bak_logininfor SELECT * FROM sys_logininfor;
CREATE TABLE dd01_bak_dict_type LIKE sys_dict_type;
INSERT INTO dd01_bak_dict_type SELECT * FROM sys_dict_type;
CREATE TABLE dd01_bak_dict_data LIKE sys_dict_data;
INSERT INTO dd01_bak_dict_data SELECT * FROM sys_dict_data;

ALTER TABLE sys_user
  ADD COLUMN is_initial_password char(1) NOT NULL DEFAULT '1'
    COMMENT '初始密码标记；字典sys_auth_initial：0普通密码、1初始密码',
  ADD COLUMN credential_version bigint NOT NULL DEFAULT 0 COMMENT '凭据版本，每次改密递增',
  ADD COLUMN active_user_name varchar(30) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN user_name ELSE NULL END) STORED COMMENT '有效账号唯一键；删除后为NULL，允许账号重建',
  ADD UNIQUE INDEX uk_sys_user_active_name(active_user_name);

ALTER TABLE sys_user_password_history
  MODIFY COLUMN user_id bigint NOT NULL COMMENT '用户主键，逻辑关联sys_user.user_id，无外键',
  ADD COLUMN credential_version bigint NULL DEFAULT NULL COMMENT '对应sys_user.credential_version；旧历史未知为NULL',
  ADD COLUMN request_id varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT '改密请求ID，同用户去重',
  ADD COLUMN change_type varchar(20) NOT NULL DEFAULT 'LEGACY'
    COMMENT '字典sys_auth_pwd_change：LEGACY旧记录、BASELINE迁移基线、SELF本人、ADMIN_RESET管理员、INITIAL_CREATE创建',
  ADD COLUMN operator_id bigint NULL DEFAULT NULL COMMENT '操作者，逻辑关联sys_user.user_id，无外键',
  ADD INDEX idx_pwd_history_recent(user_id,create_time,id),
  ADD UNIQUE INDEX uk_pwd_history_version(user_id,credential_version),
  ADD UNIQUE INDEX uk_pwd_history_request(user_id,request_id);

CREATE TABLE sys_user_auth_state (
  user_id bigint NOT NULL COMMENT '用户主键，逻辑关联sys_user.user_id，无外键',
  locked_until datetime(3) NULL DEFAULT NULL COMMENT '账号锁定截止时刻，NULL未锁',
  login_failures json NOT NULL COMMENT '最近15分钟登录失败数组，每项requestId和at毫秒；第7次锁定',
  change_failures json NOT NULL COMMENT '最近15分钟旧密码失败数组，每项requestId和at毫秒；第6次锁定',
  current_session_key varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT '当前会话随机ID，非JWT',
  session_version bigint NOT NULL DEFAULT 0 COMMENT '当前会话代次',
  last_login_request_id varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT '当前会话登录请求，防止重复计数',
  version bigint NOT NULL DEFAULT 0 COMMENT '认证状态并发版本',
  update_time datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '最近更新时间',
  PRIMARY KEY(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户当前认证状态';

ALTER TABLE sys_logininfor
  ADD COLUMN user_id bigint NULL DEFAULT NULL COMMENT '用户主键，逻辑关联sys_user.user_id；未知用户允许NULL，无外键',
  ADD COLUMN nick_name varchar(50) NULL DEFAULT NULL COMMENT '当时显示名快照，旧记录不凭当前值补造',
  ADD COLUMN pc_name varchar(64) NULL DEFAULT NULL COMMENT 'PC名称，浏览器无法获取时为空',
  ADD COLUMN mac_address varchar(64) NULL DEFAULT NULL COMMENT 'MAC地址预留，浏览器无法获取时为空',
  ADD COLUMN request_id varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT '请求关联ID',
  ADD COLUMN session_key varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT '会话随机ID，非JWT',
  ADD COLUMN event_type varchar(24) NOT NULL DEFAULT 'LEGACY'
    COMMENT 'LEGACY/LOGIN/LOGIN_CHALLENGE/LOGOUT/LOCK/SESSION_REPLACED/PASSWORD_CHANGE/ADMIN_RESET',
  ADD INDEX idx_login_user_time(user_id,login_time),
  ADD INDEX idx_login_request(request_id);

ALTER TABLE sys_config ADD UNIQUE INDEX uk_sys_config_key(config_key);

START TRANSACTION;
INSERT INTO sys_user_auth_state(user_id,login_failures,change_failures)
SELECT user_id,JSON_ARRAY(),JSON_ARRAY() FROM sys_user;

-- 初始标记保守为1。正式启用前，应用迁移核验对每个旧账号做bcrypt匹配及来源核对，
-- 将经证据确认非初始且无需强制改密的账号置0；不能用摘要字符串等于'123456'判断。
-- 下列基线只记录迁移时观察到的当前摘要，不伪造过去改密时间，也不恢复不存在的历史。
INSERT INTO sys_user_password_history(id,user_id,password,create_time,credential_version,request_id,change_type,operator_id)
SELECT LEFT(SHA2(CONCAT('DD01-BASELINE:',u.user_id),256),20),u.user_id,u.password,NOW(),0,
       CONCAT('DD01-BASELINE:',u.user_id),'BASELINE',NULL
FROM sys_user u WHERE u.password IS NOT NULL AND u.password<>'';

SET @dd01_config_id = (SELECT COALESCE(MAX(config_id),0) FROM sys_config);
INSERT INTO sys_config(config_id,config_name,config_key,config_value,config_type,create_by,create_time,remark)
SELECT @dd01_config_id+1,'密码有效期','sys.account.passwordValidateDays',CAST(@dd01_valid_days AS CHAR),'Y','DD01',NOW(),'1-100天，缺失/旧0经评审转默认'
WHERE NOT EXISTS(SELECT 1 FROM sys_config WHERE config_key='sys.account.passwordValidateDays');
UPDATE sys_config SET config_value=CAST(@dd01_valid_days AS CHAR),update_by='DD01',update_time=NOW()
WHERE config_key='sys.account.passwordValidateDays' AND CAST(config_value AS UNSIGNED)=0;
INSERT INTO sys_config(config_id,config_name,config_key,config_value,config_type,create_by,create_time,remark)
SELECT @dd01_config_id+2,'密码到期提醒天数','sys.account.passwordRemindDays',CAST(@dd01_remind_days AS CHAR),'Y','DD01',NOW(),'1-15天'
WHERE NOT EXISTS(SELECT 1 FROM sys_config WHERE config_key='sys.account.passwordRemindDays');
INSERT INTO sys_config(config_id,config_name,config_key,config_value,config_type,create_by,create_time,remark)
SELECT @dd01_config_id+3,'首次登录强制改密','sys.account.initPasswordModify','1','Y','DD01',NOW(),'本期固定1不可关闭'
WHERE NOT EXISTS(SELECT 1 FROM sys_config WHERE config_key='sys.account.initPasswordModify');
UPDATE sys_config SET config_value='1',update_by='DD01',update_time=NOW()
WHERE config_key='sys.account.initPasswordModify';
INSERT INTO sys_config(config_id,config_name,config_key,config_value,config_type,create_by,create_time,remark)
SELECT @dd01_config_id+4,'密码政策版本','sys.account.passwordPolicyVersion','1','Y','DD01',NOW(),'政策保存同事务递增，禁止直接编辑'
WHERE NOT EXISTS(SELECT 1 FROM sys_config WHERE config_key='sys.account.passwordPolicyVersion');

SET @dd01_dict_id = (SELECT COALESCE(MAX(dict_id),0) FROM sys_dict_type);
INSERT INTO sys_dict_type(dict_id,dict_name,dict_type,status,create_by,create_time,remark,del_flag,is_editable)
VALUES (@dd01_dict_id+1,'初始密码标记','sys_auth_initial','0','DD01',NOW(),'0普通密码，1初始密码','0','N'),
       (@dd01_dict_id+2,'密码变更来源','sys_auth_pwd_change','0','DD01',NOW(),'固定认证枚举，不允许任意停用','0','N');
SET @dd01_dict_code = (SELECT COALESCE(MAX(dict_code),0) FROM sys_dict_data);
INSERT INTO sys_dict_data(dict_code,dict_label,dict_value,parent_code,dict_sort,dict_level,dict_type,is_default,status,is_editable,del_flag,create_by,create_time)
VALUES
(@dd01_dict_code+1,'普通密码','0',0,1,1,'sys_auth_initial','N','0','N','0','DD01',NOW()),
(@dd01_dict_code+2,'初始密码','1',0,2,1,'sys_auth_initial','Y','0','N','0','DD01',NOW()),
(@dd01_dict_code+3,'旧记录','LEGACY',0,1,1,'sys_auth_pwd_change','Y','0','N','0','DD01',NOW()),
(@dd01_dict_code+4,'迁移基线','BASELINE',0,2,1,'sys_auth_pwd_change','N','0','N','0','DD01',NOW()),
(@dd01_dict_code+5,'本人改密','SELF',0,3,1,'sys_auth_pwd_change','N','0','N','0','DD01',NOW()),
(@dd01_dict_code+6,'管理员重置','ADMIN_RESET',0,4,1,'sys_auth_pwd_change','N','0','N','0','DD01',NOW()),
(@dd01_dict_code+7,'新建初始化','INITIAL_CREATE',0,5,1,'sys_auth_pwd_change','N','0','N','0','DD01',NOW());
COMMIT;

-- 后续：执行02核验、应用旧账号初始标记核验、刷新配置/字典缓存，统一升级auth/system/gateway/ui。
-- 所有旧会话作废并重新登录；未完成核验不得开放业务入口。不要删除备份表。
