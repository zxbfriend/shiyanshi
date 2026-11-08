-- M01 SEC04 登录快照物理DDL片段（2026-11-01）。仅供主代理统一目标DDL/空库基线及单独审核的既有库升级。
-- 本文件不是自动部署入口；不得直接对未经授权的共享库运行。既有库先只读检查可信LOGIN去重冲突，存在冲突时停止并人工核实，禁止删除日志绕过。
-- SELECT user_id, request_id, COUNT(*) FROM sys_logininfor WHERE event_type='LOGIN'
--   AND user_id IS NOT NULL AND request_id IS NOT NULL GROUP BY user_id,request_id HAVING COUNT(*)>1;

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

-- 下列变更应折入新空库CREATE TABLE sys_logininfor；既有库授权升级时方可采用ALTER。
ALTER TABLE sys_logininfor
  MODIFY COLUMN login_time DATETIME(3) NULL DEFAULT NULL,
  ADD COLUMN auth_event_sequence BIGINT NULL COMMENT '认证状态version递增后的序号；历史未知不回填',
  ADD COLUMN login_request_dedup VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin
    GENERATED ALWAYS AS (CASE WHEN event_type='LOGIN' AND user_id IS NOT NULL THEN request_id ELSE NULL END) STORED,
  ADD UNIQUE KEY uk_login_user_sequence (user_id, auth_event_sequence),
  ADD UNIQUE KEY uk_login_user_request (user_id, login_request_dedup),
  ADD KEY idx_login_previous_event (user_id, event_type, status, auth_event_sequence);

-- 锁序保持认证状态→用户更新：I01 LOGIN/I02先幂等确保auth_state存在并加锁，读取version=v；
-- 本事务recordLoginFailure/activateSession令version=v+1，同事务LOGIN审计auth_event_sequence=v+1。
-- 失败请求按可信user_id+request_id持久去重；LOGIN_CHALLENGE/UNLOCK/STEP_UP不作为LOGIN历史。
-- 历史auth_event_sequence保持NULL：以原可信user_id、LOGIN、非空login_time检索，按原time/info_id稳定选取。
-- 无法证明旧同刻事件先后，不伪造序号；返回相同时间不推断同刻事件的真实先后。
