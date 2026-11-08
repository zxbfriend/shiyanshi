-- 2026-09-10 M05接收数据库设计稿；未执行数据库。MySQL 8.0.16+ 的8.x目标。
-- 先完成发送20列包；停所有管理/采集/签批写入，核准备份与SHOW CREATE TABLE差异；禁止--force。
-- DDL隐式提交，失败即停并逐对象核对，不自动重跑或覆盖备份。
SET NAMES utf8mb4;
-- 只适用完整迁移成功但从未启用的新接收功能；先审08，再显式设置@m05_rx_never_enabled_confirmed=1。
-- 使用过即走保留证据恢复方案；本脚本不回灌旧业务值，不删除备份，不回退发送20列包。
DELIMITER $$
CREATE PROCEDURE m05_rx_rollback_20260910()
BEGIN
  IF DATABASE() IS NULL OR COALESCE(@m05_rx_maintenance_confirmed,0)<>1 OR COALESCE(@m05_rx_never_enabled_confirmed,0)<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX rollback: stopped writers and never-enabled proof required'; END IF;
  IF EXISTS(SELECT 1 FROM det_device_event) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX rollback: receipt evidence exists; do not drop'; END IF;
  IF EXISTS(SELECT 1 FROM `det_sample` WHERE NOT (`actual_started_at` <=> NULL) OR NOT (`completion_observed_at` <=> NULL) OR NOT (`time_evidence` <=> NULL)) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX rollback: runtime fields used; evidence-preserving recovery required'; END IF;
  IF EXISTS(SELECT 1 FROM `det_result` WHERE NOT (`object_version` <=> 1) OR NOT (`result_completeness` <=> 'UNVERIFIED') OR NOT (`device_completion` <=> 'UNKNOWN') OR NOT (`collection_state` <=> 'UNVERIFIED') OR NOT (`actual_started_at` <=> NULL) OR NOT (`completion_observed_at` <=> NULL) OR NOT (`time_evidence` <=> NULL) OR NOT (`collection_basis` <=> NULL) OR NOT (`source_progress` <=> NULL) OR NOT (`last_event_id` <=> NULL) OR NOT (`next_collect_at` <=> NULL)) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX rollback: runtime fields used; evidence-preserving recovery required'; END IF;
  IF EXISTS(SELECT 1 FROM `det_result_item` WHERE NOT (`item_outcome` <=> 'UNKNOWN') OR NOT (`source_evidence` <=> NULL) OR NOT (`last_event_id` <=> NULL)) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX rollback: runtime fields used; evidence-preserving recovery required'; END IF;
ALTER TABLE `det_sample`
  DROP CHECK `ck_m05_rx_s_time`,
  DROP COLUMN `actual_started_at`,
  DROP COLUMN `completion_observed_at`,
  DROP COLUMN `time_evidence`;
ALTER TABLE `det_result`
  DROP CHECK `ck_m05_rx_version`,
  DROP CHECK `ck_m05_rx_complete`,
  DROP CHECK `ck_m05_rx_device`,
  DROP CHECK `ck_m05_rx_collect`,
  DROP CHECK `ck_m05_rx_r_time`,
  DROP CHECK `ck_m05_rx_basis`,
  DROP CHECK `ck_m05_rx_progress`,
  DROP CHECK `ck_m05_rx_closed`,
  DROP CHECK `ck_m05_rx_expected`,
  DROP INDEX `idx_m05_rx_collect`,
  DROP INDEX `idx_m05_rx_result_event`,
  DROP COLUMN `object_version`,
  DROP COLUMN `result_completeness`,
  DROP COLUMN `device_completion`,
  DROP COLUMN `collection_state`,
  DROP COLUMN `actual_started_at`,
  DROP COLUMN `completion_observed_at`,
  DROP COLUMN `time_evidence`,
  DROP COLUMN `collection_basis`,
  DROP COLUMN `source_progress`,
  DROP COLUMN `last_event_id`,
  DROP COLUMN `next_collect_at`;
ALTER TABLE `det_result_item`
  DROP CHECK `ck_m05_rx_outcome`,
  DROP CHECK `ck_m05_rx_item_evidence`,
  DROP INDEX `idx_m05_rx_item_event`,
  DROP COLUMN `item_outcome`,
  DROP COLUMN `source_evidence`,
  DROP COLUMN `last_event_id`;
DROP TABLE `det_device_event`;
END$$
DELIMITER ;
CALL m05_rx_rollback_20260910();
DROP PROCEDURE m05_rx_rollback_20260910;
