-- 仅供已存在统一型号表的测试库，经备份/停写/显式批准后单独执行。
-- 不加入新系统空库安装链；新库直接使用开发基线。
-- 执行前由操作人设置：SET @rm_pump_upgrade_database = DATABASE();
-- 必须先确认 DATABASE() 为预期测试库，不能将本语句盲目自动化。
-- MySQL DDL隐式提交；中途失败应按实际字段状态处理，禁止盲目重跑。
-- 本脚本不创建/迁移外置实物，只将此前无外置选择的型号PUMP标记为INTERNAL。
DELIMITER $$
CREATE PROCEDURE rm_upgrade_pump_source_20261020()
BEGIN
  DECLARE present_columns INT DEFAULT 0;
  IF DATABASE() IS NULL OR @rm_pump_upgrade_database IS NULL
     OR BINARY @rm_pump_upgrade_database <> BINARY DATABASE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Confirm target test database before RM pump upgrade';
  END IF;
  SELECT COUNT(*) INTO present_columns FROM information_schema.columns
    WHERE table_schema=DATABASE() AND table_name='dev_reactor_model_channel'
      AND column_name IN ('pump_type','external_pump_model_id');
  IF present_columns <> 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RM columns already exist: inspect schema; do not rerun';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM sys_management_revision WHERE scope_key='SYSTEM') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SYSTEM management revision is missing';
  END IF;

  ALTER TABLE dev_reactor_model_channel
    ADD COLUMN pump_type varchar(16) CHARACTER SET ascii COLLATE ascii_bin NULL
      COMMENT 'PUMP: INTERNAL内置/EXTERNAL外置；其他通道NULL',
    ADD COLUMN external_pump_model_id bigint NULL COMMENT '外置泵资源型号ID，不是实验室实物ID',
    ADD KEY idx_rmc_external_pump_model (external_pump_model_id, del_flag),
    ADD CONSTRAINT fk_rmc_external_pump_model FOREIGN KEY (external_pump_model_id)
      REFERENCES dev_peristaltic_pump_model (model_id) ON DELETE RESTRICT ON UPDATE RESTRICT;

  UPDATE dev_reactor_model_channel SET pump_type='INTERNAL' WHERE channel_kind='PUMP';
  ALTER TABLE dev_reactor_model_channel
    ADD CONSTRAINT ck_rmc_pump_source CHECK (
      (channel_kind='PUMP' AND pump_type IS NOT NULL AND
        ((pump_type='INTERNAL' AND external_pump_model_id IS NULL)
         OR (pump_type='EXTERNAL' AND external_pump_model_id IS NOT NULL AND external_pump_model_id>0)))
      OR (channel_kind<>'PUMP' AND pump_type IS NULL AND external_pump_model_id IS NULL)
    );
  UPDATE sys_management_revision SET revision=revision+1,update_time=CURRENT_TIMESTAMP
    WHERE scope_key='SYSTEM';
END$$
DELIMITER ;
CALL rm_upgrade_pump_source_20261020();
DROP PROCEDURE rm_upgrade_pump_source_20261020;
-- 核验：所有历史PUMP为内置；其余通道两字段NULL；通道数量/ID/量程与备份一致。
SELECT channel_kind,pump_type,COUNT(*) AS channel_count
  FROM dev_reactor_model_channel GROUP BY channel_kind,pump_type;
SELECT channel_id FROM dev_reactor_model_channel
  WHERE (channel_kind='PUMP' AND (pump_type IS NULL OR pump_type<>'INTERNAL' OR external_pump_model_id IS NOT NULL))
     OR (channel_kind<>'PUMP' AND (pump_type IS NOT NULL OR external_pump_model_id IS NOT NULL));
