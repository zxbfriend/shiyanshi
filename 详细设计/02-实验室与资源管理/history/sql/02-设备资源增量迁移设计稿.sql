-- M02 设计稿，2026-09-09；未在数据库执行。MySQL 8语法。
-- 先读数据库增量设计.md；逐阶段执行并检查结果，不能整包盲跑或失败重跑。
SET NAMES utf8mb4;

-- 前置：停管理写入、业务启动与适配器写回；先完成数据库原生一致性备份。
-- 以下快照为辅助审阅备份，无索引/约束，不替代完整备份。备份已存在必须停止，不使用IF NOT EXISTS。
CREATE TABLE `bak_m02_20260909_bottle_config` AS SELECT * FROM `bottle_config`;
CREATE TABLE `bak_m02_20260909_calibration_object` AS SELECT * FROM `calibration_object`;
CREATE TABLE `bak_m02_20260909_consumable_master` AS SELECT * FROM `consumable_master`;
CREATE TABLE `bak_m02_20260909_consumption_rule` AS SELECT * FROM `consumption_rule`;
CREATE TABLE `bak_m02_20260909_dev_air_pump_model` AS SELECT * FROM `dev_air_pump_model`;
CREATE TABLE `bak_m02_20260909_dev_analyzer_model` AS SELECT * FROM `dev_analyzer_model`;
CREATE TABLE `bak_m02_20260909_dev_bench_reactor` AS SELECT * FROM `dev_bench_reactor`;
CREATE TABLE `bak_m02_20260909_dev_culture_container_spec` AS SELECT * FROM `dev_culture_container_spec`;
CREATE TABLE `bak_m02_20260909_dev_detector_item` AS SELECT * FROM `dev_detector_item`;
CREATE TABLE `bak_m02_20260909_dev_detector_model` AS SELECT * FROM `dev_detector_model`;
CREATE TABLE `bak_m02_20260909_dev_floor_scale_model` AS SELECT * FROM `dev_floor_scale_model`;
CREATE TABLE `bak_m02_20260909_dev_integrated_reactor` AS SELECT * FROM `dev_integrated_reactor`;
CREATE TABLE `bak_m02_20260909_dev_peristaltic_pump_model` AS SELECT * FROM `dev_peristaltic_pump_model`;
CREATE TABLE `bak_m02_20260909_feed_medium` AS SELECT * FROM `feed_medium`;
CREATE TABLE `bak_m02_20260909_lab_air_pump` AS SELECT * FROM `lab_air_pump`;
CREATE TABLE `bak_m02_20260909_lab_balance` AS SELECT * FROM `lab_balance`;
CREATE TABLE `bak_m02_20260909_lab_bench_reactor` AS SELECT * FROM `lab_bench_reactor`;
CREATE TABLE `bak_m02_20260909_lab_bench_reactor_controller` AS SELECT * FROM `lab_bench_reactor_controller`;
CREATE TABLE `bak_m02_20260909_lab_bench_reactor_controller_channel` AS SELECT * FROM `lab_bench_reactor_controller_channel`;
CREATE TABLE `bak_m02_20260909_lab_communication` AS SELECT * FROM `lab_communication`;
CREATE TABLE `bak_m02_20260909_lab_culture_container` AS SELECT * FROM `lab_culture_container`;
CREATE TABLE `bak_m02_20260909_lab_detection_rule` AS SELECT * FROM `lab_detection_rule`;
CREATE TABLE `bak_m02_20260909_lab_detector` AS SELECT * FROM `lab_detector`;
CREATE TABLE `bak_m02_20260909_lab_detector_item_config` AS SELECT * FROM `lab_detector_item_config`;
CREATE TABLE `bak_m02_20260909_lab_downstream_device` AS SELECT * FROM `lab_downstream_device`;
CREATE TABLE `bak_m02_20260909_lab_floor_scale` AS SELECT * FROM `lab_floor_scale`;
CREATE TABLE `bak_m02_20260909_lab_integrated_reactor` AS SELECT * FROM `lab_integrated_reactor`;
CREATE TABLE `bak_m02_20260909_lab_integrated_reactor_pump` AS SELECT * FROM `lab_integrated_reactor_pump`;
CREATE TABLE `bak_m02_20260909_lab_integrated_reactor_pump_config` AS SELECT * FROM `lab_integrated_reactor_pump_config`;
CREATE TABLE `bak_m02_20260909_lab_lab` AS SELECT * FROM `lab_lab`;
CREATE TABLE `bak_m02_20260909_lab_lab_leader` AS SELECT * FROM `lab_lab_leader`;
CREATE TABLE `bak_m02_20260909_lab_peristaltic_pump` AS SELECT * FROM `lab_peristaltic_pump`;
CREATE TABLE `bak_m02_20260909_lab_printer` AS SELECT * FROM `lab_printer`;
CREATE TABLE `bak_m02_20260909_lab_printer_layout_setting` AS SELECT * FROM `lab_printer_layout_setting`;
CREATE TABLE `bak_m02_20260909_lab_relay` AS SELECT * FROM `lab_relay`;
CREATE TABLE `bak_m02_20260909_lab_sound_alarm` AS SELECT * FROM `lab_sound_alarm`;
CREATE TABLE `bak_m02_20260909_liquid_bag` AS SELECT * FROM `liquid_bag`;
CREATE TABLE `bak_m02_20260909_sys_user_lab` AS SELECT * FROM `sys_user_lab`;

ALTER TABLE `dev_integrated_reactor`
  ADD COLUMN `mfc_count` int UNSIGNED NULL COMMENT 'MFC数量；NULL未知',
  ADD COLUMN `threshold_weight_g` decimal(12,3) NULL COMMENT '达阈重量g；NULL未知',
  ADD COLUMN `temperature_control` char(1) NULL COMMENT '0否1是NULL未知',
  ADD COLUMN `weight_control` char(1) NULL COMMENT '0否1是NULL未知',
  ADD COLUMN `pressure_control` char(1) NULL COMMENT '0否1是NULL未知',
  ADD COLUMN `pump_count` smallint UNSIGNED NULL COMMENT '固定泵数量；NULL未知',
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `lab_bench_reactor_controller`
  ADD COLUMN `mfc_count` int UNSIGNED NULL COMMENT 'MFC数量；NULL未知',
  ADD COLUMN `threshold_weight_g` decimal(12,3) NULL COMMENT '达阈重量g；NULL未知',
  ADD COLUMN `temperature_control` char(1) NULL COMMENT '0否1是NULL未知',
  ADD COLUMN `weight_control` char(1) NULL COMMENT '0否1是NULL未知',
  ADD COLUMN `pressure_control` char(1) NULL COMMENT '0否1是NULL未知',
  ADD COLUMN `balance_kind` varchar(32) NULL COMMENT 'FLOOR_SCALE或BALANCE；历史需核验',
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `lab_balance`
  ADD COLUMN `model_id` bigint NULL COMMENT '称重型号dev_floor_scale_model.model_id',
  ADD COLUMN `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `lab_bench_reactor`
  ADD COLUMN `capacity_unit` varchar(20) NULL COMMENT 'volume_ml实际最大容量单位；NULL待核验',
  ADD COLUMN `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `lab_integrated_reactor`
  ADD COLUMN `air_pump_id` bigint NULL COMMENT '空气泵lab_air_pump.air_pump_id',
  ADD COLUMN `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `dev_detector_model`
  ADD COLUMN `rule_profile` JSON NULL COMMENT '扩展规则schemaVersion、layout补充、scheduling、workCapacity.unit、protection、occlusion、inputProfile；不重复旧标量',
  ADD COLUMN `rule_revision` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '0未核准；发布成功递增，模型当前配置版本',
  ADD COLUMN `model_name` varchar(50) NULL COMMENT '展示型号；不得用其替换驱动detect_type',
  ADD COLUMN `single_send_limit` tinyint UNSIGNED NULL COMMENT '单次发送上限1至99；NULL未知',
  ADD COLUMN `support_dilution` char(1) NULL COMMENT '0否1是NULL未知；新建由应用默认0',
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `dev_floor_scale_model`
  ADD COLUMN `image_paths` json NULL COMMENT '有序图片URL数组；首项兼容icon_path',
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `dev_analyzer_model`
  ADD COLUMN `image_paths` json NULL COMMENT '有序图片URL数组；首项兼容icon_path',
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `lab_communication`
  ADD COLUMN `device_kind` varchar(32) NULL COMMENT '服务端设备种类白名单',
  ADD COLUMN `desired_revision` bigint UNSIGNED NOT NULL DEFAULT 0 COMMENT '期望配置版本；0未纳管',
  ADD COLUMN `applied_revision` bigint UNSIGNED NULL COMMENT '适配器确认的配置版本',
  ADD COLUMN `apply_state` varchar(20) NOT NULL DEFAULT 'NOT_CONFIGURED' COMMENT 'NOT_CONFIGURED/PENDING/APPLIED/FAILED/UNKNOWN',
  ADD COLUMN `apply_error_code` varchar(64) NULL COMMENT '去敏错误码',
  ADD COLUMN `applied_at` datetime(3) NULL COMMENT '配置加载回报时间UTC',
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `bottle_config`
  ADD COLUMN `configuration_revision` bigint UNSIGNED NOT NULL DEFAULT 0 COMMENT '液瓶配置版本',
  ADD COLUMN `observed_revision` bigint UNSIGNED NULL COMMENT '读数对应配置版本',
  ADD COLUMN `observed_at` datetime(3) NULL COMMENT '设备观测时间UTC',
  ADD COLUMN `reading_quality` varchar(20) NOT NULL DEFAULT 'UNKNOWN' COMMENT 'GOOD/STALE/BAD/UNKNOWN',
  ADD COLUMN `standard_source` varchar(64) NULL COMMENT 'PLC标准重量来源标识';

ALTER TABLE `lab_air_pump`
  ADD COLUMN `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `lab_detector`
  ADD COLUMN `queue_revision` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '设备队列/位置事实版本，改变可操作性时同事务递增',
  ADD COLUMN `applied_rule_revision` BIGINT UNSIGNED NULL COMMENT '当前实例实际接入运行的型号规则修订；与所属model_id组成身份',
  ADD COLUMN `applied_rule_snapshot` JSON NULL COMMENT '已核准且已接入的完整规则快照，包含modelId/修订及旧标量固定值',
  ADD COLUMN `position_evidence` JSON NULL COMMENT '初始/当前位置证据、采集时间、事件身份与源；NULL不是初始态',
  ADD COLUMN `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `lab_downstream_device`
  ADD COLUMN `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `lab_floor_scale`
  ADD COLUMN `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `lab_lab`
  ADD COLUMN `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`lab_code`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `lab_peristaltic_pump`
  ADD COLUMN `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `lab_printer`
  ADD COLUMN `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `lab_relay`
  ADD COLUMN `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `lab_sound_alarm`
  ADD COLUMN `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `lab_culture_container`
  ADD COLUMN `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`container_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `dev_bench_reactor`
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `dev_culture_container_spec`
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `dev_detector_item`
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `dev_peristaltic_pump_model`
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `dev_air_pump_model`
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `calibration_object`
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `feed_medium`
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `consumable_master`
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `liquid_bag`
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';

ALTER TABLE `lab_detection_rule`
  ADD COLUMN `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束';
