-- 既有库定向升级；不属于新空库三脚本安装链。具体环境执行证据见认证安全增强部署说明。
-- 需另行确认目标库、备份、停写及授权。DDL不能整包回滚，遇错停止；不使用--force。
-- 不删除/回填历史日志。重复请求或重复序号须人工核实，不可删日志绕过。
SELECT DATABASE() AS target_database, VERSION() AS target_version;
DELIMITER //
CREATE PROCEDURE m01_auth_security_precheck()
BEGIN
  IF DATABASE() IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='No target database selected'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='sys_logininfor' AND column_name='auth_event_sequence') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Authentication schema already changed; inspect before retry';
  END IF;
  IF EXISTS(SELECT 1 FROM sys_logininfor WHERE event_type='LOGIN' AND user_id IS NOT NULL AND request_id IS NOT NULL GROUP BY user_id,request_id HAVING COUNT(*)>1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Duplicate known-user LOGIN requests; manual review required';
  END IF;
END//
DELIMITER ;
CALL m01_auth_security_precheck();
DROP PROCEDURE m01_auth_security_precheck;

CREATE TABLE `sys_sensitive_operation_receipt` (
  `actor_user_id` bigint NOT NULL COMMENT '操作者用户编号',
  `business_request_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '业务请求唯一编号',
  `operation` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '操作类型：密码重置或密码策略修改',
  `session_binding` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '当前会话绑定摘要',
  `actor_credential_version` bigint NOT NULL COMMENT '操作者凭证版本',
  `payload_hmac` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '操作参数完整性校验摘要',
  `key_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '摘要密钥版本标识',
  `proof_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '操作凭证哈希值',
  `state` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '操作状态：待验证、就绪、已执行、已拒绝或已取消',
  `active_challenge_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '当前认证挑战哈希值',
  `challenge_expires_at` datetime(3) NOT NULL COMMENT '认证挑战到期时间（UTC）',
  `authentication_method` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '身份认证方式',
  `verified_at` datetime(3) NULL COMMENT '二次认证通过时间（UTC）',
  `proof_expires_at` datetime(3) NULL COMMENT '操作凭证到期时间（UTC）',
  `result_json` json NULL COMMENT '成功执行结果回执',
  `reject_code` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '操作拒绝错误码',
  `created_at` datetime(3) NOT NULL COMMENT '记录创建时间（UTC）',
  `retain_until` datetime(3) NOT NULL COMMENT '记录至少保留至此时间（UTC）',
  PRIMARY KEY (`actor_user_id`,`business_request_id`),
  UNIQUE KEY `uk_sensitive_proof` (`proof_hash`),
  KEY `idx_sensitive_retention` (`retain_until`),
  CONSTRAINT `ck_sensitive_operation` CHECK (`operation` IN ('PASSWORD_RESET','PASSWORD_POLICY_UPDATE')),
  CONSTRAINT `ck_sensitive_state` CHECK (`state` IN ('PENDING','READY','APPLIED','REJECTED','CANCELLED')),
  CONSTRAINT `ck_sensitive_verified` CHECK (`state` NOT IN ('READY','APPLIED') OR (`proof_hash` IS NOT NULL AND `verified_at` IS NOT NULL AND `proof_expires_at` IS NOT NULL)),
  CONSTRAINT `ck_sensitive_result` CHECK ((`state`='APPLIED' AND `result_json` IS NOT NULL) OR (`state`<>'APPLIED' AND `result_json` IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='敏感操作二次认证及执行回执';

CREATE TABLE sys_login_security_snapshot (
  user_id BIGINT NOT NULL COMMENT '用户编号',
  session_version BIGINT NOT NULL COMMENT '登录会话版本',
  login_request_id VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '登录请求唯一编号',
  previous_success_at DATETIME(3) NULL COMMENT '本次登录前最近成功登录时间（UTC）',
  previous_failure_at DATETIME(3) NULL COMMENT '本次登录前最近失败登录时间（UTC）',
  current_login_at DATETIME(3) NOT NULL COMMENT '本次成功登录时间（UTC）',
  created_at DATETIME(3) NOT NULL COMMENT '快照创建时间（UTC）',
  success_event_id BIGINT NULL COMMENT '上次成功登录日志编号',
  failure_event_id BIGINT NULL COMMENT '上次失败登录日志编号',
  PRIMARY KEY (user_id, session_version),
  UNIQUE KEY uk_login_snapshot_request (user_id, login_request_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户登录安全反馈快照';

ALTER TABLE sys_logininfor
  MODIFY COLUMN login_time DATETIME(3) NULL DEFAULT NULL,
  ADD COLUMN auth_event_sequence BIGINT NULL COMMENT '认证状态version递增后的序号；历史未知不回填',
  ADD COLUMN login_request_dedup VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin
    GENERATED ALWAYS AS (CASE WHEN event_type='LOGIN' AND user_id IS NOT NULL THEN request_id ELSE NULL END) STORED,
  ADD UNIQUE KEY uk_login_user_sequence (user_id, auth_event_sequence),
  ADD UNIQUE KEY uk_login_user_request (user_id, login_request_dedup),
  ADD KEY idx_login_previous_event (user_id, event_type, status, auth_event_sequence);
