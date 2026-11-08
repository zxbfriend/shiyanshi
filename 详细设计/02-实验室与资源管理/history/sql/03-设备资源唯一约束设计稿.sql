-- M02 设计稿，2026-09-09；未在数据库执行。MySQL 8语法。
-- 先读数据库增量设计.md；逐阶段执行并检查结果，不能整包盲跑或失败重跑。
SET NAMES utf8mb4;

-- 仅在历史数据映射、孤儿引用和重复检查全部完成后执行。
-- 新增字段留NULL是扩展阶段兼容行为；不是允许未配置设备投用。
SELECT model_id FROM dev_detector_model WHERE del_flag='0' AND (model_name IS NULL OR TRIM(model_name)='');
SELECT comm_id FROM lab_communication WHERE del_flag='0' AND device_kind IS NULL;
-- 以上有结果时停止本阶段。历史补值须使用数据库增量设计中的逐主键批准映射，不按文本或ID巧合猜测。

SELECT `brand`,`category`,`m02_active`,COUNT(*) AS duplicate_count FROM `dev_bench_reactor` WHERE m02_active=1 GROUP BY `brand`,`category`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `dev_bench_reactor`
  ADD UNIQUE INDEX `uk_m02_business` (`brand`,`category`,`m02_active`);

SELECT `model_name`,`m02_active`,COUNT(*) AS duplicate_count FROM `dev_integrated_reactor` WHERE m02_active=1 GROUP BY `model_name`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `dev_integrated_reactor`
  ADD UNIQUE INDEX `uk_m02_business` (`model_name`,`m02_active`);

SELECT `container_type`,`spec`,`m02_active`,COUNT(*) AS duplicate_count FROM `dev_culture_container_spec` WHERE m02_active=1 GROUP BY `container_type`,`spec`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `dev_culture_container_spec`
  ADD UNIQUE INDEX `uk_m02_business` (`container_type`,`spec`,`m02_active`);

SELECT `brand`,`model_name`,`m02_active`,COUNT(*) AS duplicate_count FROM `dev_floor_scale_model` WHERE m02_active=1 GROUP BY `brand`,`model_name`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `dev_floor_scale_model`
  ADD UNIQUE INDEX `uk_m02_business` (`brand`,`model_name`,`m02_active`);

SELECT `detect_class`,`model_name`,`m02_active`,COUNT(*) AS duplicate_count FROM `dev_detector_model` WHERE m02_active=1 GROUP BY `detect_class`,`model_name`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `dev_detector_model`
  ADD UNIQUE INDEX `uk_m02_business` (`detect_class`,`model_name`,`m02_active`);

SELECT `detect_class`,`item_code`,`m02_active`,COUNT(*) AS duplicate_count FROM `dev_detector_item` WHERE m02_active=1 GROUP BY `detect_class`,`item_code`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `dev_detector_item`
  ADD UNIQUE INDEX `uk_m02_business` (`detect_class`,`item_code`,`m02_active`);

SELECT `brand`,`model_name`,`m02_active`,COUNT(*) AS duplicate_count FROM `dev_peristaltic_pump_model` WHERE m02_active=1 GROUP BY `brand`,`model_name`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `dev_peristaltic_pump_model`
  ADD UNIQUE INDEX `uk_m02_business` (`brand`,`model_name`,`m02_active`);

SELECT `brand`,`model_name`,`m02_active`,COUNT(*) AS duplicate_count FROM `dev_air_pump_model` WHERE m02_active=1 GROUP BY `brand`,`model_name`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `dev_air_pump_model`
  ADD UNIQUE INDEX `uk_m02_business` (`brand`,`model_name`,`m02_active`);

SELECT `brand`,`model_name`,`m02_active`,COUNT(*) AS duplicate_count FROM `dev_analyzer_model` WHERE m02_active=1 GROUP BY `brand`,`model_name`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `dev_analyzer_model`
  ADD UNIQUE INDEX `uk_m02_business` (`brand`,`model_name`,`m02_active`);

SELECT `weight_name`,`m02_active`,COUNT(*) AS duplicate_count FROM `calibration_object` WHERE m02_active=1 GROUP BY `weight_name`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `calibration_object`
  ADD UNIQUE INDEX `uk_m02_business` (`weight_name`,`m02_active`);

SELECT `medium_name`,`m02_active`,COUNT(*) AS duplicate_count FROM `feed_medium` WHERE m02_active=1 GROUP BY `medium_name`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `feed_medium`
  ADD UNIQUE INDEX `uk_m02_business` (`medium_name`,`m02_active`);

SELECT `item_code`,`m02_active`,COUNT(*) AS duplicate_count FROM `consumable_master` WHERE m02_active=1 GROUP BY `item_code`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `consumable_master`
  ADD UNIQUE INDEX `uk_m02_business` (`item_code`,`m02_active`);

SELECT `description`,`m02_active`,COUNT(*) AS duplicate_count FROM `liquid_bag` WHERE m02_active=1 GROUP BY `description`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `liquid_bag`
  ADD UNIQUE INDEX `uk_m02_business` (`description`,`m02_active`);

SELECT `lab_name`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_lab` WHERE m02_active=1 GROUP BY `lab_name`,`m02_active` HAVING COUNT(*)>1;

SELECT `lab_code`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_lab` WHERE m02_active=1 GROUP BY `lab_code`,`m02_active` HAVING COUNT(*)>1;

SELECT `m02_asset_key`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_lab` WHERE m02_active=1 GROUP BY `m02_asset_key`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `lab_lab`
  ADD UNIQUE INDEX `uk_m02_business` (`lab_name`,`m02_active`),
  ADD UNIQUE INDEX `uk_m02_code` (`lab_code`,`m02_active`),
  ADD UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`);

SELECT `lab_id`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_detection_rule` WHERE m02_active=1 GROUP BY `lab_id`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `lab_detection_rule`
  ADD UNIQUE INDEX `uk_m02_business` (`lab_id`,`m02_active`);

SELECT `reactor_id`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_bench_reactor_controller` WHERE m02_active=1 GROUP BY `reactor_id`,`m02_active` HAVING COUNT(*)>1;

SELECT `lab_id`,`controller_no`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_bench_reactor_controller` WHERE m02_active=1 GROUP BY `lab_id`,`controller_no`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `lab_bench_reactor_controller`
  ADD UNIQUE INDEX `uk_m02_business` (`reactor_id`,`m02_active`),
  ADD UNIQUE INDEX `uk_m02_controller` (`lab_id`,`controller_no`,`m02_active`);

SELECT `device_kind`,`device_id`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_communication` WHERE m02_active=1 GROUP BY `device_kind`,`device_id`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `lab_communication`
  ADD UNIQUE INDEX `uk_m02_business` (`device_kind`,`device_id`,`m02_active`);

SELECT `lab_id`,`device_no`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_air_pump` WHERE m02_active=1 GROUP BY `lab_id`,`device_no`,`m02_active` HAVING COUNT(*)>1;

SELECT `m02_asset_key`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_air_pump` WHERE m02_active=1 GROUP BY `m02_asset_key`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `lab_air_pump`
  ADD UNIQUE INDEX `uk_m02_device` (`lab_id`,`device_no`,`m02_active`),
  ADD UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`);

SELECT `lab_id`,`device_no`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_balance` WHERE m02_active=1 GROUP BY `lab_id`,`device_no`,`m02_active` HAVING COUNT(*)>1;

SELECT `m02_asset_key`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_balance` WHERE m02_active=1 GROUP BY `m02_asset_key`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `lab_balance`
  ADD UNIQUE INDEX `uk_m02_device` (`lab_id`,`device_no`,`m02_active`),
  ADD UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`);

SELECT `lab_id`,`device_no`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_bench_reactor` WHERE m02_active=1 GROUP BY `lab_id`,`device_no`,`m02_active` HAVING COUNT(*)>1;

SELECT `lab_id`,`vessel_no`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_bench_reactor` WHERE m02_active=1 GROUP BY `lab_id`,`vessel_no`,`m02_active` HAVING COUNT(*)>1;

SELECT `lab_id`,`controller_no`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_bench_reactor` WHERE m02_active=1 GROUP BY `lab_id`,`controller_no`,`m02_active` HAVING COUNT(*)>1;

SELECT `m02_asset_key`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_bench_reactor` WHERE m02_active=1 GROUP BY `m02_asset_key`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `lab_bench_reactor`
  ADD UNIQUE INDEX `uk_m02_device` (`lab_id`,`device_no`,`m02_active`),
  ADD UNIQUE INDEX `uk_m02_vessel_no` (`lab_id`,`vessel_no`,`m02_active`),
  ADD UNIQUE INDEX `uk_m02_controller_no` (`lab_id`,`controller_no`,`m02_active`),
  ADD UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`);

SELECT `device_no`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_detector` WHERE m02_active=1 GROUP BY `device_no`,`m02_active` HAVING COUNT(*)>1;

SELECT `m02_asset_key`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_detector` WHERE m02_active=1 GROUP BY `m02_asset_key`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `lab_detector`
  ADD UNIQUE INDEX `uk_m02_device` (`device_no`,`m02_active`),
  ADD UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`);

SELECT `lab_id`,`device_no`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_downstream_device` WHERE m02_active=1 GROUP BY `lab_id`,`device_no`,`m02_active` HAVING COUNT(*)>1;

SELECT `m02_asset_key`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_downstream_device` WHERE m02_active=1 GROUP BY `m02_asset_key`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `lab_downstream_device`
  ADD UNIQUE INDEX `uk_m02_device` (`lab_id`,`device_no`,`m02_active`),
  ADD UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`);

SELECT `lab_id`,`device_no`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_floor_scale` WHERE m02_active=1 GROUP BY `lab_id`,`device_no`,`m02_active` HAVING COUNT(*)>1;

SELECT `m02_asset_key`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_floor_scale` WHERE m02_active=1 GROUP BY `m02_asset_key`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `lab_floor_scale`
  ADD UNIQUE INDEX `uk_m02_device` (`lab_id`,`device_no`,`m02_active`),
  ADD UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`);

SELECT `lab_id`,`device_no`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_peristaltic_pump` WHERE m02_active=1 GROUP BY `lab_id`,`device_no`,`m02_active` HAVING COUNT(*)>1;

SELECT `m02_asset_key`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_peristaltic_pump` WHERE m02_active=1 GROUP BY `m02_asset_key`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `lab_peristaltic_pump`
  ADD UNIQUE INDEX `uk_m02_device` (`lab_id`,`device_no`,`m02_active`),
  ADD UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`);

SELECT `lab_id`,`device_no`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_printer` WHERE m02_active=1 GROUP BY `lab_id`,`device_no`,`m02_active` HAVING COUNT(*)>1;

SELECT `m02_asset_key`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_printer` WHERE m02_active=1 GROUP BY `m02_asset_key`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `lab_printer`
  ADD UNIQUE INDEX `uk_m02_device` (`lab_id`,`device_no`,`m02_active`),
  ADD UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`);

SELECT `lab_id`,`device_no`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_relay` WHERE m02_active=1 GROUP BY `lab_id`,`device_no`,`m02_active` HAVING COUNT(*)>1;

SELECT `m02_asset_key`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_relay` WHERE m02_active=1 GROUP BY `m02_asset_key`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `lab_relay`
  ADD UNIQUE INDEX `uk_m02_device` (`lab_id`,`device_no`,`m02_active`),
  ADD UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`);

SELECT `lab_id`,`device_no`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_sound_alarm` WHERE m02_active=1 GROUP BY `lab_id`,`device_no`,`m02_active` HAVING COUNT(*)>1;

SELECT `m02_asset_key`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_sound_alarm` WHERE m02_active=1 GROUP BY `m02_asset_key`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `lab_sound_alarm`
  ADD UNIQUE INDEX `uk_m02_device` (`lab_id`,`device_no`,`m02_active`),
  ADD UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`);

SELECT `lab_id`,`container_no`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_culture_container` WHERE m02_active=1 GROUP BY `lab_id`,`container_no`,`m02_active` HAVING COUNT(*)>1;

SELECT `lab_id`,`container_name`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_culture_container` WHERE m02_active=1 GROUP BY `lab_id`,`container_name`,`m02_active` HAVING COUNT(*)>1;

SELECT `m02_asset_key`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_culture_container` WHERE m02_active=1 GROUP BY `m02_asset_key`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `lab_culture_container`
  ADD UNIQUE INDEX `uk_m02_container` (`lab_id`,`container_no`,`m02_active`),
  ADD UNIQUE INDEX `uk_m02_name` (`lab_id`,`container_name`,`m02_active`),
  ADD UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`);

SELECT `m02_asset_key`,`m02_active`,COUNT(*) AS duplicate_count FROM `lab_integrated_reactor` WHERE m02_active=1 GROUP BY `m02_asset_key`,`m02_active` HAVING COUNT(*)>1;
ALTER TABLE `lab_integrated_reactor`
  ADD UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`);

-- 新(device_kind,device_id,m02_active)唯一索引成功后才移除旧约束。
ALTER TABLE `lab_communication` DROP INDEX `uk_device_id`;

-- M05动态规则补充：仅在本版02六列已添加后执行；旧版已部署使用07补丁，不重复跑03。
ALTER TABLE `dev_detector_model`
  ADD CONSTRAINT `ck_m02_rule_object` CHECK (rule_profile IS NULL OR JSON_TYPE(rule_profile)='OBJECT'),
  ADD CONSTRAINT `ck_m02_rule_published` CHECK (rule_revision=0 OR rule_profile IS NOT NULL);
ALTER TABLE `lab_detector`
  ADD CONSTRAINT `ck_m02_rule_applied_pair` CHECK ((applied_rule_revision IS NULL AND applied_rule_snapshot IS NULL) OR (applied_rule_revision IS NOT NULL AND applied_rule_revision>0 AND applied_rule_snapshot IS NOT NULL)),
  ADD CONSTRAINT `ck_m02_rule_applied_object` CHECK (applied_rule_snapshot IS NULL OR JSON_TYPE(applied_rule_snapshot)='OBJECT'),
  ADD CONSTRAINT `ck_m02_position_object` CHECK (position_evidence IS NULL OR JSON_TYPE(position_evidence)='OBJECT');
