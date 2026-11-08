-- DD-20260917-OBS：MySQL 8.0.16+ 目标增量设计稿，未执行。
-- 先执行本包迁移前核验并人工核准；无 IF NOT EXISTS，遇已有同名表停止。
-- DDL 隐式提交；不得将 ROLLBACK 视为建表回退；无物理跨模块外键。

CREATE TABLE `run_observation_monitor` (
  `condition_key` BINARY(32) NOT NULL COMMENT '稳定告警condition SHA256',
  `identity_json` JSON NOT NULL COMMENT 'MonitorIdentity v1核对碰撞',
  `sequence` BIGINT NOT NULL COMMENT '持久单调事件序列，初始0',
  `evaluation_version` BIGINT NOT NULL COMMENT '每轮评价CAS版本',
  `last_input_key` VARCHAR(160) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '已处理样本或缺测时间槽身份',
  `last_evaluated_at` DATETIME(6) NULL COMMENT '评价水位，旧样本不得倒退',
  `condition_state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'UNKNOWN/NORMAL/ACTIVE',
  `evidence` JSON NOT NULL COMMENT 'MonitorEvidence v1含连续次数及profile',
  `row_version` BIGINT NOT NULL COMMENT '并发CAS',
  `updated_at` DATETIME(6) NOT NULL COMMENT '更新时刻',
  PRIMARY KEY (`condition_key`),
  CHECK (`sequence` >= 0 AND `evaluation_version` >= 0 AND `row_version` > 0),
  CHECK (`condition_state` IN ('UNKNOWN','NORMAL','ACTIVE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='运行/连接会话判定状态，不复制M02观测库';

