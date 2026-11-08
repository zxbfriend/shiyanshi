-- Existing development/test database only; NOT part of the empty database installation chain.
-- Requires explicit authorization, stopping writes, and a verified backup; MySQL DDL commits implicitly.
-- Set @m02_pump_channel_target_database to the confirmed DATABASE() before execution.
-- This script changes schema only: no historic binding, channel number, usage or range is inferred or rewritten.
-- If the procedure name already exists, CREATE fails without replacing it; inspect before any manual cleanup.
DELIMITER $$
CREATE PROCEDURE m02_pump_channel_upgrade_20261029()
BEGIN
  IF DATABASE() IS NULL OR @m02_pump_channel_target_database IS NULL
     OR BINARY DATABASE() <> BINARY @m02_pump_channel_target_database THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Explicit target database required';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE()
                 AND table_name='lab_integrated_reactor_pump' AND table_type='BASE TABLE') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Integrated reactor pump table missing';
  END IF;
  IF (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE()
      AND table_name='lab_integrated_reactor_pump' AND index_name='PRIMARY')<>2
     OR (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE()
         AND table_name='lab_integrated_reactor_pump' AND index_name='PRIMARY' AND non_unique=0
         AND ((seq_in_index=1 AND column_name='integrated_id') OR (seq_in_index=2 AND column_name='pump_id')))<>2 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Existing pump binding primary key is unexpected';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE()
                 AND table_name='lab_integrated_reactor_pump' AND column_name='pump_no') THEN
    ALTER TABLE lab_integrated_reactor_pump ADD COLUMN pump_no SMALLINT UNSIGNED NULL DEFAULT NULL
      COMMENT '反应器型号泵通道号；NULL表示历史关联未确认' AFTER pump_id;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE()
                 AND table_name='lab_integrated_reactor_pump' AND column_name='pump_no'
                 AND data_type='smallint' AND column_type='smallint unsigned' AND is_nullable='YES'
                 AND column_default IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Existing pump_no has unexpected schema';
  END IF;
  IF EXISTS (SELECT 1 FROM lab_integrated_reactor_pump WHERE pump_no=0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid pump channel number';
  END IF;
  IF EXISTS (SELECT integrated_id,pump_no FROM lab_integrated_reactor_pump WHERE pump_no IS NOT NULL
             GROUP BY integrated_id,pump_no HAVING COUNT(*)>1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Duplicate reactor pump channel';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE()
             AND table_name='lab_integrated_reactor_pump' AND index_name='uk_lab_integrated_reactor_pump_no')
     AND ((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE()
           AND table_name='lab_integrated_reactor_pump' AND index_name='uk_lab_integrated_reactor_pump_no')<>2
       OR (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE()
           AND table_name='lab_integrated_reactor_pump' AND index_name='uk_lab_integrated_reactor_pump_no'
           AND non_unique=0 AND index_type='BTREE' AND ((seq_in_index=1 AND column_name='integrated_id')
             OR (seq_in_index=2 AND column_name='pump_no')))<>2) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Existing pump channel index is unexpected';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE()
                 AND table_name='lab_integrated_reactor_pump' AND index_name='uk_lab_integrated_reactor_pump_no') THEN
    ALTER TABLE lab_integrated_reactor_pump
      ADD UNIQUE INDEX uk_lab_integrated_reactor_pump_no (integrated_id,pump_no);
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.table_constraints tc
             JOIN information_schema.check_constraints cc ON cc.constraint_schema=tc.constraint_schema
              AND cc.constraint_name=tc.constraint_name
             WHERE tc.constraint_schema=DATABASE() AND tc.table_name='lab_integrated_reactor_pump'
              AND tc.constraint_name='ck_lab_integrated_reactor_pump_no'
              AND (tc.constraint_type<>'CHECK' OR tc.enforced<>'YES'
                OR LOWER(REPLACE(REPLACE(REPLACE(REPLACE(cc.check_clause,'`',''),' ',''),'(',''),')',''))
                   <>'pump_noisnullorpump_no>0')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Existing pump channel check is unexpected';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_schema=DATABASE()
                 AND table_name='lab_integrated_reactor_pump' AND constraint_name='ck_lab_integrated_reactor_pump_no'
                 AND constraint_type='CHECK' AND enforced='YES') THEN
    ALTER TABLE lab_integrated_reactor_pump ADD CONSTRAINT ck_lab_integrated_reactor_pump_no
      CHECK (pump_no IS NULL OR pump_no>0);
  END IF;
END$$
DELIMITER ;
CALL m02_pump_channel_upgrade_20261029();
DROP PROCEDURE m02_pump_channel_upgrade_20261029;

-- Read-only verification; the first five result sets must be empty. NULL rows are historical, not errors.
SELECT 'pump_no' AS invalid_column WHERE NOT EXISTS (SELECT 1 FROM information_schema.columns
 WHERE table_schema=DATABASE() AND table_name='lab_integrated_reactor_pump' AND column_name='pump_no'
 AND data_type='smallint' AND column_type='smallint unsigned' AND is_nullable='YES' AND column_default IS NULL);
SELECT integrated_id,pump_no,COUNT(*) AS duplicate_count FROM lab_integrated_reactor_pump
 WHERE pump_no IS NOT NULL GROUP BY integrated_id,pump_no HAVING COUNT(*)>1;
SELECT integrated_id,pump_id,pump_no FROM lab_integrated_reactor_pump WHERE pump_no=0;
SELECT 'uk_lab_integrated_reactor_pump_no' AS invalid_index WHERE
 (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE()
  AND table_name='lab_integrated_reactor_pump' AND index_name='uk_lab_integrated_reactor_pump_no')<>2
 OR (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE()
  AND table_name='lab_integrated_reactor_pump' AND index_name='uk_lab_integrated_reactor_pump_no'
  AND non_unique=0 AND index_type='BTREE' AND ((seq_in_index=1 AND column_name='integrated_id')
    OR (seq_in_index=2 AND column_name='pump_no')))<>2;
SELECT 'ck_lab_integrated_reactor_pump_no' AS invalid_check WHERE NOT EXISTS (
 SELECT 1 FROM information_schema.table_constraints tc JOIN information_schema.check_constraints cc
  ON cc.constraint_schema=tc.constraint_schema AND cc.constraint_name=tc.constraint_name
 WHERE tc.constraint_schema=DATABASE() AND tc.table_name='lab_integrated_reactor_pump'
  AND tc.constraint_name='ck_lab_integrated_reactor_pump_no' AND tc.constraint_type='CHECK'
  AND tc.enforced='YES' AND LOWER(REPLACE(REPLACE(REPLACE(REPLACE(cc.check_clause,'`',''),' ',''),'(',''),')',''))
  ='pump_noisnullorpump_no>0');
SELECT COUNT(*) AS unmapped_historical_bindings FROM lab_integrated_reactor_pump WHERE pump_no IS NULL;
