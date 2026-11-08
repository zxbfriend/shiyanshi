-- Existing database only; NOT part of the empty database installation chain.
-- Set @bottle_target_database to the explicitly confirmed database in this session.
-- Stop relevant writes and take a verified schema/data backup before execution.
-- MySQL DDL commits implicitly: on failure stop and inspect the actual schema; do not assume rollback.
-- Schema only: no unit, pump, configuration, observation, association or layout is inserted or inferred.
-- A same-named procedure must not already exist; this script never drops an unrelated procedure.
DELIMITER $$
CREATE PROCEDURE m02_upgrade_bottle_controller_20261102()
BEGIN
  IF DATABASE() IS NULL OR @bottle_target_database IS NULL
     OR BINARY DATABASE() <> BINARY @bottle_target_database THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Explicit target database required';
  END IF;
  IF (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE()
      AND table_name IN ('bottle_config','lab_bench_reactor_controller') AND engine='InnoDB')<>2 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Expected InnoDB tables missing';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE()
      AND table_name='lab_bench_reactor_controller' AND column_name='sampling_unit_code'
      AND data_type='varchar' AND character_maximum_length=50) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Controller sampling unit schema missing';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE()
      AND table_name='bottle_config' AND column_name='reactor_id' AND data_type='bigint'
      AND column_type='bigint' AND is_nullable IN ('YES','NO'))
     OR NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE()
      AND table_name='bottle_config' AND column_name='pump_code' AND data_type='varchar'
      AND character_maximum_length=50 AND collation_name='utf8mb4_0900_ai_ci'
      AND is_nullable IN ('YES','NO'))
     OR NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE()
      AND table_name='bottle_config' AND column_name='status' AND data_type='char'
      AND character_maximum_length=1 AND collation_name='utf8mb4_0900_ai_ci'
      AND column_default='0' AND is_nullable IN ('YES','NO')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bottle identity columns unexpected';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE()
      AND table_name='bottle_config' AND column_name='controller_id')
     AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE()
      AND table_name='bottle_config' AND column_name='controller_id'
      AND column_type='bigint' AND is_nullable='YES') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Existing controller_id has unexpected schema';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE()
      AND table_name='bottle_config' AND index_name='idx_bottle_controller')
     AND ((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE()
      AND table_name='bottle_config' AND index_name='idx_bottle_controller')<>2
      OR (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE()
      AND table_name='bottle_config' AND index_name='idx_bottle_controller' AND non_unique=1
      AND ((seq_in_index=1 AND column_name='lab_id') OR (seq_in_index=2 AND column_name='controller_id')))<>2) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Existing controller index has unexpected schema';
  END IF;
  IF EXISTS (SELECT 1 FROM bottle_config WHERE unit_type='F' AND del_flag='0'
             AND (reactor_id IS NULL OR pump_code IS NULL)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Existing active feeding slot identity incomplete';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE()
                 AND table_name='bottle_config' AND column_name='controller_id') THEN
    ALTER TABLE bottle_config ADD COLUMN controller_id bigint NULL DEFAULT NULL
      COMMENT '取样单元所属控制器连接ID' AFTER reactor_id;
  END IF;
  ALTER TABLE bottle_config
    MODIFY COLUMN reactor_id bigint NULL DEFAULT NULL COMMENT '历史罐体或补料单元台式反应器ID',
    MODIFY COLUMN pump_code varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
      NULL DEFAULT NULL COMMENT '已知的真实泵通道编号；取样单元可为空',
    MODIFY COLUMN status char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
      NULL DEFAULT '0' COMMENT '历史状态：0空闲，1使用中；NULL未知';
  IF NOT EXISTS (SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE()
                 AND table_name='bottle_config' AND index_name='idx_bottle_controller') THEN
    ALTER TABLE bottle_config ADD INDEX idx_bottle_controller (lab_id,controller_id);
  END IF;
END$$
DELIMITER ;
CALL m02_upgrade_bottle_controller_20261102();
DROP PROCEDURE m02_upgrade_bottle_controller_20261102;

-- Each verification result set must be empty; this is not an application or device acceptance test.
SELECT 'bottle identity columns' AS invalid_schema WHERE (SELECT COUNT(*) FROM information_schema.columns
 WHERE table_schema=DATABASE() AND table_name='bottle_config' AND
 ((column_name IN ('controller_id','reactor_id') AND column_type='bigint' AND is_nullable='YES')
 OR (column_name='pump_code' AND data_type='varchar' AND character_maximum_length=50
 AND collation_name='utf8mb4_0900_ai_ci' AND is_nullable='YES')))<>3;
SELECT 'bottle status column' AS invalid_schema WHERE NOT EXISTS (SELECT 1 FROM information_schema.columns
 WHERE table_schema=DATABASE() AND table_name='bottle_config' AND column_name='status'
 AND data_type='char' AND character_maximum_length=1 AND is_nullable='YES'
 AND column_default='0' AND collation_name='utf8mb4_0900_ai_ci');
SELECT 'idx_bottle_controller' AS invalid_schema WHERE (SELECT COUNT(*) FROM information_schema.statistics
 WHERE table_schema=DATABASE() AND table_name='bottle_config' AND index_name='idx_bottle_controller')<>2
 OR (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE()
 AND table_name='bottle_config' AND index_name='idx_bottle_controller' AND non_unique=1
 AND ((seq_in_index=1 AND column_name='lab_id') OR (seq_in_index=2 AND column_name='controller_id')))<>2;
SELECT bottle_id FROM bottle_config WHERE unit_type='F' AND del_flag='0'
 AND (reactor_id IS NULL OR pump_code IS NULL);

-- Rollback is deliberately NOT automatic. Stop writes, restore compatible application code and
-- inspect all controller_id references and NULL reactor_id/pump_code/status rows, including deleted rows.
-- Do not drop controller_id or restore NOT NULL until no required data would be lost and an approved
-- data reconciliation/backup is available. Then remove idx_bottle_controller and controller_id,
-- restore all three NOT NULL definitions, and verify the result. DDL also commits implicitly on rollback.
