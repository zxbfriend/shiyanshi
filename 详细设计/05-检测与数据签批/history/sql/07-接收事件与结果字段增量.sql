-- 2026-09-10 M05接收数据库设计稿；未执行数据库。MySQL 8.0.16+ 的8.x目标。
-- 先完成发送20列包；停所有管理/采集/签批写入，核准备份与SHOW CREATE TABLE差异；禁止--force。
-- DDL隐式提交，失败即停并逐对象核对，不自动重跑或覆盖备份。
SET NAMES utf8mb4;
-- 执行者独立确认后设置@m05_rx_maintenance_confirmed=1及@m05_rx_baseline_verified=1；本脚本不自动设为1。
DELIMITER $$
CREATE PROCEDURE m05_rx_migrate_20260910()
BEGIN
  IF DATABASE() IS NULL OR COALESCE(@m05_rx_maintenance_confirmed,0)<>1 OR COALESCE(@m05_rx_baseline_verified,0)<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX: confirm explicit database, stopped writers and baseline review'; END IF;
  IF VERSION() NOT REGEXP '^8[.]' OR (SUBSTRING_INDEX(VERSION(),'.',2)='8.0' AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(VERSION(),'.',3),'.',-1) AS UNSIGNED)<16) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX: MySQL 8.0.16+ within reviewed 8.x required'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND engine='InnoDB' AND table_type='BASE TABLE' AND table_name IN ('det_sample','det_result','det_result_item','det_dispatch_log','lab_detector'))<>5 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX: required InnoDB baseline tables absent'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_sample')<>38 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX: unexpected det_sample column count'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result')<>23 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX: unexpected det_result column count'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result_item')<>17 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX: unexpected det_result_item column count'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_dispatch_log')<>21 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX: unexpected det_dispatch_log column count'; END IF;
  IF (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND ((table_name='det_sample' AND column_name IN ('occupancy_generation','current_dispatch_id','object_version')) OR (table_name='det_dispatch_log' AND column_name IN ('item_bindings','rule_snapshot')) OR (table_name='lab_detector' AND column_name='queue_revision')))<>6 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX: prerequisite send runtime package not found'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_sample' AND column_name IN ('actual_started_at','completion_observed_at','time_evidence')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX: target column present; reconcile partial migration'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result' AND column_name IN ('object_version','result_completeness','device_completion','collection_state','actual_started_at','completion_observed_at','time_evidence','collection_basis','source_progress','last_event_id','next_collect_at')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX: target column present; reconcile partial migration'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='det_result_item' AND column_name IN ('item_outcome','source_evidence','last_event_id')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX: target column present; reconcile partial migration'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name IN ('det_device_event','bak_m05_rx_20260910_det_sample','bak_m05_rx_20260910_det_result','bak_m05_rx_20260910_det_result_item')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX: target or backup exists; never overwrite'; END IF;
  IF EXISTS(SELECT 1 FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND constraint_name IN ('ck_m05_rx_s_time','ck_m05_rx_version','ck_m05_rx_complete','ck_m05_rx_device','ck_m05_rx_collect','ck_m05_rx_r_time','ck_m05_rx_basis','ck_m05_rx_progress','ck_m05_rx_closed','ck_m05_rx_expected','ck_m05_rx_outcome','ck_m05_rx_item_evidence','ck_m05_rx_e_version','ck_m05_rx_e_dedup','ck_m05_rx_e_corr','ck_m05_rx_e_receipt','ck_m05_rx_e_applied','ck_m05_rx_e_duplicate','ck_m05_rx_e_payload_meta','ck_m05_rx_e_normalized_payload','ck_m05_rx_e_kinds','ck_m05_rx_e_resolved_bindings','ck_m05_rx_e_applied_versions','ck_m05_rx_e_processing_history')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX: target constraint name exists'; END IF;
  CREATE TABLE `bak_m05_rx_20260910_det_sample` LIKE `det_sample`;
  INSERT INTO `bak_m05_rx_20260910_det_sample` SELECT * FROM `det_sample`;
  IF (SELECT COUNT(*) FROM `bak_m05_rx_20260910_det_sample`)<>(SELECT COUNT(*) FROM `det_sample`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX: backup row count mismatch'; END IF;
  CREATE TABLE `bak_m05_rx_20260910_det_result` LIKE `det_result`;
  INSERT INTO `bak_m05_rx_20260910_det_result` SELECT * FROM `det_result`;
  IF (SELECT COUNT(*) FROM `bak_m05_rx_20260910_det_result`)<>(SELECT COUNT(*) FROM `det_result`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX: backup row count mismatch'; END IF;
  CREATE TABLE `bak_m05_rx_20260910_det_result_item` LIKE `det_result_item`;
  INSERT INTO `bak_m05_rx_20260910_det_result_item` SELECT * FROM `det_result_item`;
  IF (SELECT COUNT(*) FROM `bak_m05_rx_20260910_det_result_item`)<>(SELECT COUNT(*) FROM `det_result_item`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RX: backup row count mismatch'; END IF;
  CREATE TABLE `det_device_event` (
  `event_id` BIGINT NOT NULL COMMENT '系统生成主键；每份观测独立保存',
  `observation_id` VARCHAR(128) NOT NULL COMMENT '适配器观测标识；非唯一避免同标识异载荷丢失',
  `detector_id` BIGINT NOT NULL COMMENT '认证映射设备实例；非前端自报',
  `adapter_key` VARCHAR(128) NOT NULL COMMENT '可信适配器身份',
  `contract_version` VARCHAR(64) NOT NULL COMMENT '解析及映射契约固定版本',
  `source_scope` VARCHAR(512) NOT NULL COMMENT '稳定源事件命名空间；不随应用重启改变',
  `native_event_id` VARCHAR(512) NULL COMMENT '原生事件键；未知为NULL',
  `native_revision` VARCHAR(128) NULL COMMENT '原生修订字符串；不默认可按字符串比较',
  `dedup_key` TEXT NULL COMMENT '经核准的完整规范去重键；证据不足为NULL',
  `dedup_hash` BINARY(32) NULL COMMENT '完整去重键SHA256查询索引；命中后仍比较完整键',
  `semantic_hash` BINARY(32) NOT NULL COMMENT '标准化语义摘要；冲突判断仍核对规范载荷',
  `raw_hash` BINARY(32) NOT NULL COMMENT '原始字节SHA256',
  `raw_payload` LONGBLOB NOT NULL COMMENT '实际收到的原始字节；不可被JSON规范化替代',
  `payload_meta` JSON NOT NULL COMMENT '编码媒体类型传输来源及源时间原文；不存认证密钥',
  `normalized_payload` JSON NOT NULL COMMENT '解析冻结的完整观测对象含items及事实类型',
  `event_kinds` JSON NOT NULL COMMENT '非空事实类型数组；同包兼容事实一并应用',
  `received_at` DATETIME(3) NOT NULL COMMENT '本系统耐久接收时间UTC',
  `source_observed_at` DATETIME(3) NULL COMMENT '可信源发生时间归一UTC；未知时区不得填',
  `resolved_bindings` JSON NULL COMMENT '逐成员dispatch/sample/result/代次绑定及关联证据',
  `correlation_status` VARCHAR(16) NOT NULL DEFAULT 'UNMATCHED' COMMENT 'UNMATCHED/MATCHED/AMBIGUOUS',
  `receipt_status` VARCHAR(24) NOT NULL DEFAULT 'RECEIVED' COMMENT 'RECEIVED/APPLIED/DUPLICATE/UNMATCHED/CONFLICT/RETRYABLE_ERROR',
  `receipt_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '处理回执CAS版本；重试不改原文',
  `related_event_id` BIGINT NULL COMMENT '重复指向原事件或冲突对照事件；全部同键证据可查询',
  `applied_versions` JSON NULL COMMENT '每个受影响resultId及before/afterObjectVersion；多样品包使用数组',
  `applied_at` DATETIME(3) NULL COMMENT '领域事实与APPLIED回执原子提交时间',
  `retry_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '应用重试次数；不表示设备重发次数',
  `next_retry_at` DATETIME(3) NULL COMMENT '瞬时失败退避时间',
  `error_code` VARCHAR(64) NULL COMMENT '脱敏处理问题码',
  `error_detail` VARCHAR(1000) NULL COMMENT '脱敏说明；原文证据保存在raw_payload',
  `processing_history` JSON NULL COMMENT '追加处理尝试版本与问题；不得用重试覆盖冲突历史',
  PRIMARY KEY (`event_id`),
  INDEX `idx_m05_rx_e_dedup` (detector_id,dedup_hash,event_id),
  INDEX `idx_m05_rx_e_retry` (receipt_status,next_retry_at,event_id),
  INDEX `idx_m05_rx_e_source` (detector_id,received_at,event_id),
  INDEX `idx_m05_rx_e_related` (related_event_id),
  CONSTRAINT `ck_m05_rx_e_version` CHECK (receipt_version>=1),
  CONSTRAINT `ck_m05_rx_e_dedup` CHECK ((dedup_key IS NULL AND dedup_hash IS NULL) OR (dedup_key IS NOT NULL AND dedup_hash IS NOT NULL)),
  CONSTRAINT `ck_m05_rx_e_corr` CHECK (correlation_status IN ('UNMATCHED','MATCHED','AMBIGUOUS')),
  CONSTRAINT `ck_m05_rx_e_receipt` CHECK (receipt_status IN ('RECEIVED','APPLIED','DUPLICATE','UNMATCHED','CONFLICT','RETRYABLE_ERROR')),
  CONSTRAINT `ck_m05_rx_e_applied` CHECK (receipt_status<>'APPLIED' OR (correlation_status='MATCHED' AND applied_at IS NOT NULL AND applied_versions IS NOT NULL)),
  CONSTRAINT `ck_m05_rx_e_duplicate` CHECK (receipt_status<>'DUPLICATE' OR related_event_id IS NOT NULL),
  CONSTRAINT `ck_m05_rx_e_payload_meta` CHECK (JSON_TYPE(payload_meta)='OBJECT'),
  CONSTRAINT `ck_m05_rx_e_normalized_payload` CHECK (JSON_TYPE(normalized_payload)='OBJECT'),
  CONSTRAINT `ck_m05_rx_e_kinds` CHECK (JSON_TYPE(event_kinds)='ARRAY' AND JSON_LENGTH(event_kinds)>0),
  CONSTRAINT `ck_m05_rx_e_resolved_bindings` CHECK (resolved_bindings IS NULL OR JSON_TYPE(resolved_bindings)='ARRAY'),
  CONSTRAINT `ck_m05_rx_e_applied_versions` CHECK (applied_versions IS NULL OR JSON_TYPE(applied_versions)='ARRAY'),
  CONSTRAINT `ck_m05_rx_e_processing_history` CHECK (processing_history IS NULL OR JSON_TYPE(processing_history)='ARRAY')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_bin ROW_FORMAT=DYNAMIC COMMENT='设备观测耐久收件与应用回执';

ALTER TABLE `det_sample`
  ADD COLUMN `actual_started_at` DATETIME(3) NULL COMMENT '可信实际检测开始；不是上样时间',
  ADD COLUMN `completion_observed_at` DATETIME(3) NULL COMMENT '本系统首次观测可信设备结束的时点',
  ADD COLUMN `time_evidence` JSON NULL COMMENT '每个时刻的来源时区精度及事件引用；NULL为历史未核验',
  ADD CONSTRAINT `ck_m05_rx_s_time` CHECK (time_evidence IS NULL OR JSON_TYPE(time_evidence)='OBJECT');
ALTER TABLE `det_result`
  ADD COLUMN `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '结果内容状态签批共同版本；复用主设计版本不另设result_version',
  ADD COLUMN `result_completeness` VARCHAR(16) NOT NULL DEFAULT 'UNVERIFIED' COMMENT 'NONE/PARTIAL/COMPLETE/UNVERIFIED',
  ADD COLUMN `device_completion` VARCHAR(16) NOT NULL DEFAULT 'UNKNOWN' COMMENT 'NOT_FINISHED/FINISHED/UNKNOWN；失败取消终态另见source_progress',
  ADD COLUMN `collection_state` VARCHAR(24) NOT NULL DEFAULT 'UNVERIFIED' COMMENT 'UNVERIFIED/OPEN/RECONCILING/CLOSED/CLOSED_EXCEPTION',
  ADD COLUMN `actual_started_at` DATETIME(3) NULL COMMENT '可信实际检测开始；不是上样时间',
  ADD COLUMN `completion_observed_at` DATETIME(3) NULL COMMENT '本系统首次观测可信设备结束的时点',
  ADD COLUMN `time_evidence` JSON NULL COMMENT '每个时刻的来源时区精度及事件引用；NULL为历史未核验',
  ADD COLUMN `collection_basis` JSON NULL COMMENT '本次dispatch/sample/代次及非空expectedItems不可变快照',
  ADD COLUMN `source_progress` JSON NULL COMMENT '各类事实源版本终态依据和待更正事件；不是按收到先后覆盖',
  ADD COLUMN `last_event_id` BIGINT NULL COMMENT '最近实际改变本结果的接收事件；不是全部历史',
  ADD COLUMN `next_collect_at` DATETIME(3) NULL COMMENT '下一次只读采集核对调度时间；不触发发送',
  ADD CONSTRAINT `ck_m05_rx_version` CHECK (object_version>=1),
  ADD CONSTRAINT `ck_m05_rx_complete` CHECK (result_completeness IN ('NONE','PARTIAL','COMPLETE','UNVERIFIED')),
  ADD CONSTRAINT `ck_m05_rx_device` CHECK (device_completion IN ('NOT_FINISHED','FINISHED','UNKNOWN')),
  ADD CONSTRAINT `ck_m05_rx_collect` CHECK (collection_state IN ('UNVERIFIED','OPEN','RECONCILING','CLOSED','CLOSED_EXCEPTION')),
  ADD CONSTRAINT `ck_m05_rx_r_time` CHECK (time_evidence IS NULL OR JSON_TYPE(time_evidence)='OBJECT'),
  ADD CONSTRAINT `ck_m05_rx_basis` CHECK (collection_basis IS NULL OR JSON_TYPE(collection_basis)='OBJECT'),
  ADD CONSTRAINT `ck_m05_rx_progress` CHECK (source_progress IS NULL OR JSON_TYPE(source_progress)='OBJECT'),
  ADD CONSTRAINT `ck_m05_rx_closed` CHECK (collection_state<>'CLOSED' OR (result_completeness='COMPLETE' AND device_completion='FINISHED')),
  ADD CONSTRAINT `ck_m05_rx_expected` CHECK (result_completeness='UNVERIFIED' OR (collection_basis IS NOT NULL AND COALESCE(JSON_TYPE(JSON_EXTRACT(collection_basis,'$.expectedItems')),'')='ARRAY' AND COALESCE(JSON_LENGTH(JSON_EXTRACT(collection_basis,'$.expectedItems')),0)>0)),
  ADD INDEX `idx_m05_rx_collect` (collection_state,next_collect_at,result_id),
  ADD INDEX `idx_m05_rx_result_event` (last_event_id);
ALTER TABLE `det_result_item`
  ADD COLUMN `item_outcome` VARCHAR(16) NOT NULL DEFAULT 'UNKNOWN' COMMENT 'VALUE/ERROR/NO_MEASUREMENT/UNKNOWN；历史值不自动核准',
  ADD COLUMN `source_evidence` JSON NULL COMMENT '源项目子样品修订单位与映射版本及事件ID集合',
  ADD COLUMN `last_event_id` BIGINT NULL COMMENT '最近实际改变本明细的事件；逻辑关联',
  ADD CONSTRAINT `ck_m05_rx_outcome` CHECK (item_outcome IN ('VALUE','ERROR','NO_MEASUREMENT','UNKNOWN')),
  ADD CONSTRAINT `ck_m05_rx_item_evidence` CHECK (source_evidence IS NULL OR JSON_TYPE(source_evidence)='OBJECT'),
  ADD INDEX `idx_m05_rx_item_event` (last_event_id);
END$$
DELIMITER ;
CALL m05_rx_migrate_20260910();
DROP PROCEDURE m05_rx_migrate_20260910;
