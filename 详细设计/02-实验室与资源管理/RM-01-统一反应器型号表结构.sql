-- RM-01 unified reactor models. Design source only; install via docs/开发基线/README.md.
-- Not an existing-database migration. Old model tables remain until consumer cutover.
-- Controller definition supersedes only that table in 13-最终目标表结构.sql.

CREATE TABLE dev_reactor_model (
  model_id bigint NOT NULL,
  reactor_type varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  model_name varchar(50) NOT NULL,
  capacity_g decimal(12,3) NULL,
  spec varchar(50) NOT NULL DEFAULT '',
  pressure_unit varchar(20) NULL,
  threshold_weight_g decimal(12,3) NULL,
  temperature_control tinyint NOT NULL DEFAULT 1,
  weight_control tinyint NOT NULL DEFAULT 1,
  pressure_control tinyint NOT NULL DEFAULT 1,
  description varchar(100) NOT NULL DEFAULT '',
  icon_path varchar(255) NULL,
  del_flag char(1) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '0',
  create_by varchar(64) NOT NULL DEFAULT '',
  create_time datetime NULL,
  update_by varchar(64) NOT NULL DEFAULT '',
  update_time datetime NULL,
  remark varchar(500) NULL,
  m02_active tinyint GENERATED ALWAYS AS
    (CASE WHEN del_flag = '0' THEN 1 ELSE NULL END) STORED,
  PRIMARY KEY (model_id),
  UNIQUE KEY uk_reactor_model_name (reactor_type, model_name, m02_active),
  KEY idx_reactor_model_list (del_flag, reactor_type, update_time, model_id),
  CONSTRAINT ck_rm_id CHECK (model_id > 0),
  CONSTRAINT ck_rm_type CHECK
    (reactor_type IN ('INTEGRATED_REACTOR', 'BENCH_CONTROLLER')),
  CONSTRAINT ck_rm_name CHECK (CHAR_LENGTH(TRIM(model_name)) > 0),
  CONSTRAINT ck_rm_capacity CHECK
    (capacity_g IS NULL OR (capacity_g > 0 AND capacity_g = FLOOR(capacity_g))),
  CONSTRAINT ck_rm_threshold CHECK
    (threshold_weight_g IS NULL OR
      (threshold_weight_g > 0 AND threshold_weight_g = FLOOR(threshold_weight_g))),
  CONSTRAINT ck_rm_pressure CHECK
    (pressure_unit IS NULL OR CHAR_LENGTH(TRIM(pressure_unit)) > 0),
  CONSTRAINT ck_rm_required CHECK
    (reactor_type = 'BENCH_CONTROLLER' OR
      (capacity_g IS NOT NULL AND pressure_unit IS NOT NULL
       AND threshold_weight_g IS NOT NULL)),
  CONSTRAINT ck_rm_controls CHECK
    (temperature_control IN (0,1) AND weight_control IN (0,1)
     AND pressure_control IN (0,1)),
  CONSTRAINT ck_rm_deleted CHECK (del_flag IN ('0','2'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='资源管理-反应器与台式控制器统一型号';

CREATE TABLE dev_reactor_model_channel (
  channel_id bigint NOT NULL,
  model_id bigint NOT NULL,
  channel_kind varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  channel_no int NOT NULL,
  channel_code varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  max_range decimal(18,2) NULL,
  range_unit varchar(16) CHARACTER SET ascii COLLATE ascii_bin NULL,
  strategy_id bigint NULL,
  pump_type varchar(16) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'PUMP: INTERNAL内置/EXTERNAL外置；其他通道NULL',
  external_pump_model_id bigint NULL COMMENT '外置泵资源型号ID，不是实验室实物ID',
  del_flag char(1) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '0',
  create_by varchar(64) NOT NULL DEFAULT '',
  create_time datetime NULL,
  update_by varchar(64) NOT NULL DEFAULT '',
  update_time datetime NULL,
  m02_active tinyint GENERATED ALWAYS AS
    (CASE WHEN del_flag = '0' THEN 1 ELSE NULL END) STORED,
  PRIMARY KEY (channel_id),
  UNIQUE KEY uk_rm_channel_no (model_id, channel_kind, channel_no, m02_active),
  UNIQUE KEY uk_rm_channel_code (model_id, channel_code, m02_active),
  KEY idx_rmc_external_pump_model (external_pump_model_id, del_flag),
  CONSTRAINT fk_rmc_external_pump_model FOREIGN KEY (external_pump_model_id)
    REFERENCES dev_peristaltic_pump_model (model_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_rm_channel_model FOREIGN KEY (model_id)
    REFERENCES dev_reactor_model (model_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_rmc_id CHECK (channel_id > 0 AND model_id > 0),
  CONSTRAINT ck_rmc_kind CHECK
    (channel_kind IN ('PUMP','MFC','SAMPLING_PUMP','VALVE')),
  CONSTRAINT ck_rmc_no CHECK
    (channel_no > 0 AND (channel_kind <> 'PUMP' OR channel_no <= 65535)
     AND (channel_kind <> 'SAMPLING_PUMP' OR channel_no = 1)),
  CONSTRAINT ck_rmc_code CHECK
    (channel_code = CONCAT(channel_kind, CAST(channel_no AS CHAR))),
  CONSTRAINT ck_rmc_range CHECK (max_range IS NULL OR max_range >= 0),
  CONSTRAINT ck_rmc_pump_source CHECK (
    (channel_kind = 'PUMP' AND pump_type IS NOT NULL AND
      ((pump_type = 'INTERNAL' AND external_pump_model_id IS NULL)
       OR (pump_type = 'EXTERNAL' AND external_pump_model_id IS NOT NULL AND external_pump_model_id > 0)))
    OR (channel_kind <> 'PUMP' AND pump_type IS NULL AND external_pump_model_id IS NULL)
  ),
  CONSTRAINT ck_rmc_payload CHECK (
    (channel_kind = 'PUMP' AND max_range IS NOT NULL
      AND range_unit IS NOT NULL AND range_unit = 'g/min' AND strategy_id IS NULL)
    OR (channel_kind = 'MFC' AND max_range IS NOT NULL
      AND range_unit IS NOT NULL AND range_unit = 'L/min' AND strategy_id IS NULL)
    OR (channel_kind = 'SAMPLING_PUMP' AND max_range IS NULL
      AND range_unit IS NOT NULL AND range_unit = 'g/min' AND strategy_id IS NULL)
    OR (channel_kind = 'VALVE' AND max_range IS NULL
      AND range_unit IS NULL AND strategy_id IS NULL)
  ),
  CONSTRAINT ck_rmc_deleted CHECK (del_flag IN ('0','2'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='资源管理-型号通道与隐藏组件预留';

CREATE TABLE dev_reactor_model_pid (
  pid_id bigint NOT NULL,
  model_id bigint NOT NULL,
  loop_code varchar(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  gain_value decimal(10,1) NOT NULL,
  reset_seconds int NOT NULL,
  rate_value decimal(10,1) NULL,
  del_flag char(1) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '0',
  create_by varchar(64) NOT NULL DEFAULT '',
  create_time datetime NULL,
  update_by varchar(64) NOT NULL DEFAULT '',
  update_time datetime NULL,
  m02_active tinyint GENERATED ALWAYS AS
    (CASE WHEN del_flag = '0' THEN 1 ELSE NULL END) STORED,
  PRIMARY KEY (pid_id),
  UNIQUE KEY uk_rm_pid_loop (model_id, loop_code, m02_active),
  KEY idx_rm_pid_model (model_id, del_flag),
  CONSTRAINT fk_rm_pid_model FOREIGN KEY (model_id)
    REFERENCES dev_reactor_model (model_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_rmp_id CHECK (pid_id > 0 AND model_id > 0),
  CONSTRAINT ck_rmp_loop CHECK
    (loop_code IN ('DO','PH','VESSEL_TEMP','JACKET_TEMP','VESSEL_PRESSURE')),
  CONSTRAINT ck_rmp_values CHECK
    (gain_value > 0 AND reset_seconds > 0 AND (rate_value IS NULL OR rate_value >= 0)),
  CONSTRAINT ck_rmp_deleted CHECK (del_flag IN ('0','2'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='资源管理-反应器型号PID默认参数';

CREATE TABLE `lab_bench_reactor_controller` (
`connection_id` bigint NOT NULL COMMENT '泵连接主键',
  `lab_id` bigint NOT NULL COMMENT '实验室主键',
  `reactor_id` bigint NULL DEFAULT NULL COMMENT '历史迁移关联；新关系使用lab_bench_reactor.controller_id',
  `controller_no` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '控制器编号',
  `feed_unit_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '当前实验室控制器对应的补料单元编码；NULL未配置',
  `sampling_unit_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '当前实验室控制器对应的取样单元编码；内置唯一取样泵；NULL未配置',
  `balance_id` bigint NULL DEFAULT NULL COMMENT '称重设备主键',
  `connection_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '连接名称',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用），字典：系统开关',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `mfc_count` int UNSIGNED NULL COMMENT 'MFC数量；NULL未知',
  `threshold_weight_g` decimal(12,3) NULL COMMENT '达阈重量g；NULL未知',
  `temperature_control` char(1) NULL COMMENT '0否1是NULL未知',
  `weight_control` char(1) NULL COMMENT '0否1是NULL未知',
  `pressure_control` char(1) NULL COMMENT '0否1是NULL未知',
  `balance_kind` varchar(32) NULL COMMENT 'FLOOR_SCALE或BALANCE；历史需核验',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  `model_id` bigint NULL COMMENT '统一型号ID；仅允许有效BENCH_CONTROLLER，由应用校验',
  KEY idx_bench_controller_model (model_id),
  `model_dict_code` bigint NULL DEFAULT NULL COMMENT '核准控制器型号dict_code；NULL旧未知，无默认型号',
  `model_verification_evidence` json NULL COMMENT '型号核准来源文档、摘要、章节、可信核准人及时刻；只由M02-227写入',
  PRIMARY KEY (`connection_id`) USING BTREE,
  INDEX `idx_lab_pump_connection_lab`(`lab_id` ASC) USING BTREE,
  INDEX `idx_lab_pump_connection_reactor`(`reactor_id` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_controller` (`lab_id`,`controller_no`,`m02_active`),
  UNIQUE INDEX `uk_m02_feed_unit` (`lab_id`,`feed_unit_code`,`m02_active`),
  UNIQUE INDEX `uk_m02_sampling_unit` (`lab_id`,`sampling_unit_code`,`m02_active`),
  CONSTRAINT `ck_m02_feed_unit_nonblank` CHECK (`feed_unit_code` IS NULL OR CHAR_LENGTH(TRIM(`feed_unit_code`)) > 0),
  CONSTRAINT `ck_m02_sampling_unit_nonblank` CHECK (`sampling_unit_code` IS NULL OR CHAR_LENGTH(TRIM(`sampling_unit_code`)) > 0)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-台式反应器-控制器通道配置表' ROW_FORMAT = DYNAMIC;

-- 型号普通泵明确关联；旧字段保留，禁止按channel_no文本猜测关联。
-- 跨表型号归属、PUMP类型及有效性由M02守卫事务校验，本处不增加跨表外键。
CREATE TABLE `lab_bench_reactor_controller_channel` (
`channel_id` bigint NOT NULL COMMENT '通道主键',
  `connection_id` bigint NOT NULL COMMENT '泵连接主键',
  `model_channel_id` bigint NULL COMMENT '对应统一型号普通泵通道ID；NULL未转换或非型号普通泵',
  UNIQUE KEY uk_bench_model_channel (connection_id, model_channel_id),
  CONSTRAINT ck_bench_model_channel_positive CHECK (model_channel_id IS NULL OR model_channel_id > 0),
  `channel_no` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '通道号',
  `pump_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '泵类型',
  `pump_id` bigint NULL DEFAULT NULL COMMENT '关联泵主键',
  `pump_usage` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用途',
  `material_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '补料液体或物料名称，字典：SMP补料液体种类',
  `feed_container` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '补料容器，字典：SMP补料容器类型',
  `default_speed` decimal(12, 4) NULL DEFAULT NULL COMMENT '默认速度',
  `max_speed` decimal(12, 4) NULL DEFAULT NULL COMMENT '最高速度',
  `speed_strategy` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '泵速策略',
  PRIMARY KEY (`channel_id`) USING BTREE,
  UNIQUE INDEX `uk_lab_pump_channel_no`(`connection_id` ASC, `channel_no` ASC) USING BTREE,
  INDEX `idx_lab_pump_channel_connection`(`connection_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-台式反应器-控制器表' ROW_FORMAT = DYNAMIC;
