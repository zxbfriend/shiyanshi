-- M01认证安全增强；新空库来源定义，不单独与完整建表重复执行。
-- 既有库须另行审核升级，禁止重跑空库安装。MySQL 8.0.16+。
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
