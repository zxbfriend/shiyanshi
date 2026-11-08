-- 2026-10-16 M03 培养补液计算规则增量（独立当前版本表）。
-- 仅供已存在开发库升级；新库请使用 docs/开发基线/01-完整建表.sql，勿与本文件重复执行。
CREATE TABLE res_culture_feeding_config (
  culture_id bigint NOT NULL COMMENT '培养主键；每个培养一行当前规则',
  enabled tinyint NOT NULL DEFAULT 1 COMMENT '1当前生效/0停用保留',
  calculation_basis varchar(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'INITIAL_WEIGHT/CURRENT_WEIGHT',
  residual_sugar_confirmation_mode varchar(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'NOT_REQUIRED/MANUAL_REQUIRED/COMPREHENSIVE',
  calculate_sugar_concentration_change tinyint NOT NULL DEFAULT 1,
  require_residual_sugar_confirmation_before_sugar tinyint NOT NULL DEFAULT 1,
  sugar_calculation_mode varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'RESIDUAL_SUGAR/RESIDUAL_SUGAR_AND_LACTATE',
  config_version bigint NOT NULL DEFAULT 1 COMMENT 'M07 任务冻结版本',
  creator_user_id bigint NULL,
  modifier_user_id bigint NULL,
  create_time datetime(3) NOT NULL,
  update_time datetime(3) NOT NULL,
  PRIMARY KEY (culture_id),
  CONSTRAINT ck_m03_feeding_config_enabled CHECK (enabled IN (0,1)),
  CONSTRAINT ck_m03_feeding_config_basis CHECK (calculation_basis IN ('INITIAL_WEIGHT','CURRENT_WEIGHT')),
  CONSTRAINT ck_m03_feeding_config_confirmation CHECK (residual_sugar_confirmation_mode IN ('NOT_REQUIRED','MANUAL_REQUIRED','COMPREHENSIVE')),
  CONSTRAINT ck_m03_feeding_config_change CHECK (calculate_sugar_concentration_change IN (0,1)),
  CONSTRAINT ck_m03_feeding_config_before_sugar CHECK (require_residual_sugar_confirmation_before_sugar IN (0,1)),
  CONSTRAINT ck_m03_feeding_config_mode CHECK (sugar_calculation_mode IN ('RESIDUAL_SUGAR','RESIDUAL_SUGAR_AND_LACTATE')),
  CONSTRAINT ck_m03_feeding_config_version CHECK (config_version >= 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='培养补液计算规则当前版本；M07任务须冻结快照';
