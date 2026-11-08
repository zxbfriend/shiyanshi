-- Existing development/test database only; NOT part of the empty database installation chain.
-- Before execution: confirm the exact database, stop relevant writes, and back up schema/data.
-- DDL commits implicitly. On any failure stop and inspect the actual schema before retrying.
-- Explicitly set @sampling_unit_target_database to the confirmed database in this session.
-- Schema only: no associations or pump data are inserted, inferred, deleted, or backfilled.
-- A same-named procedure must not already exist; do not drop an unrelated existing procedure.
DELIMITER $$
CREATE PROCEDURE m02_upgrade_sampling_unit_20261101()
BEGIN
  IF DATABASE() IS NULL OR @sampling_unit_target_database IS NULL
     OR BINARY DATABASE() <> BINARY @sampling_unit_target_database THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Explicit target database required';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE()
                 AND table_name='lab_bench_reactor_controller' AND column_name='m02_active'
                 AND extra LIKE '%STORED GENERATED%'
                 AND generation_expression LIKE '%del_flag%') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Controller active-row key missing or unexpected';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE()
                 AND table_name='lab_bench_reactor_controller' AND column_name='sampling_unit_code') THEN
    ALTER TABLE lab_bench_reactor_controller ADD COLUMN sampling_unit_code varchar(50)
      CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL
      COMMENT '当前实验室控制器对应的取样单元编码；内置唯一取样泵；NULL未配置' AFTER feed_unit_code;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE()
                 AND table_name='lab_bench_reactor_controller' AND column_name='sampling_unit_code'
                 AND data_type='varchar' AND character_maximum_length=50 AND is_nullable='YES'
                 AND collation_name='utf8mb4_0900_ai_ci') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Existing sampling_unit_code has unexpected schema';
  END IF;
  IF EXISTS (SELECT lab_id, sampling_unit_code FROM lab_bench_reactor_controller
             WHERE del_flag='0' AND sampling_unit_code IS NOT NULL
             GROUP BY lab_id, sampling_unit_code HAVING COUNT(*)>1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Duplicate active sampling unit codes';
  END IF;
  IF EXISTS (SELECT 1 FROM lab_bench_reactor_controller
             WHERE sampling_unit_code IS NOT NULL AND CHAR_LENGTH(TRIM(sampling_unit_code))=0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Blank sampling unit code';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE()
             AND table_name='lab_bench_reactor_controller' AND index_name='uk_m02_sampling_unit')
     AND ((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE()
           AND table_name='lab_bench_reactor_controller' AND index_name='uk_m02_sampling_unit')<>3
       OR (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE()
           AND table_name='lab_bench_reactor_controller' AND index_name='uk_m02_sampling_unit'
           AND non_unique=0 AND ((seq_in_index=1 AND column_name='lab_id')
             OR (seq_in_index=2 AND column_name='sampling_unit_code')
             OR (seq_in_index=3 AND column_name='m02_active')))<>3) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Existing sampling unit index has unexpected schema';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE()
                 AND table_name='lab_bench_reactor_controller' AND index_name='uk_m02_sampling_unit') THEN
    ALTER TABLE lab_bench_reactor_controller
      ADD UNIQUE INDEX uk_m02_sampling_unit (lab_id,sampling_unit_code,m02_active);
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_schema=DATABASE()
             AND table_name='lab_bench_reactor_controller' AND constraint_name='ck_m02_sampling_unit_nonblank')
     AND NOT EXISTS (SELECT 1 FROM information_schema.table_constraints tc
                     JOIN information_schema.check_constraints cc
                       ON cc.constraint_schema=tc.constraint_schema AND cc.constraint_name=tc.constraint_name
                     WHERE tc.constraint_schema=DATABASE() AND tc.table_name='lab_bench_reactor_controller'
                       AND tc.constraint_name='ck_m02_sampling_unit_nonblank'
                       AND tc.constraint_type='CHECK' AND tc.enforced='YES'
                       AND LOWER(cc.check_clause) LIKE '%sampling_unit_code%'
                       AND LOWER(cc.check_clause) LIKE '%trim%'
                       AND LOWER(cc.check_clause) LIKE '%char_length%') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Existing sampling unit check has unexpected schema';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_schema=DATABASE()
                 AND table_name='lab_bench_reactor_controller' AND constraint_name='ck_m02_sampling_unit_nonblank') THEN
    ALTER TABLE lab_bench_reactor_controller ADD CONSTRAINT ck_m02_sampling_unit_nonblank
      CHECK (sampling_unit_code IS NULL OR CHAR_LENGTH(TRIM(sampling_unit_code))>0);
  END IF;
END$$
DELIMITER ;
CALL m02_upgrade_sampling_unit_20261101();
-- Drop only the procedure created by this script after a successful call.
DROP PROCEDURE m02_upgrade_sampling_unit_20261101;

-- Verification result sets should be empty; this does not validate real device bindings.
SELECT 'sampling_unit_code' AS invalid_column WHERE NOT EXISTS (
 SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE()
  AND table_name='lab_bench_reactor_controller' AND column_name='sampling_unit_code'
  AND data_type='varchar' AND character_maximum_length=50 AND is_nullable='YES'
  AND collation_name='utf8mb4_0900_ai_ci');
SELECT lab_id,sampling_unit_code,COUNT(*) AS duplicate_count FROM lab_bench_reactor_controller
 WHERE del_flag='0' AND sampling_unit_code IS NOT NULL GROUP BY lab_id,sampling_unit_code HAVING COUNT(*)>1;
SELECT 'uk_m02_sampling_unit' AS invalid_index WHERE (SELECT COUNT(*) FROM information_schema.statistics
 WHERE table_schema=DATABASE() AND table_name='lab_bench_reactor_controller' AND index_name='uk_m02_sampling_unit')<>3
 OR (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE()
 AND table_name='lab_bench_reactor_controller' AND index_name='uk_m02_sampling_unit' AND non_unique=0
 AND ((seq_in_index=1 AND column_name='lab_id') OR (seq_in_index=2 AND column_name='sampling_unit_code')
 OR (seq_in_index=3 AND column_name='m02_active')))<>3;
SELECT 'ck_m02_sampling_unit_nonblank' AS invalid_check WHERE NOT EXISTS (
 SELECT 1 FROM information_schema.table_constraints WHERE constraint_schema=DATABASE()
 AND table_name='lab_bench_reactor_controller' AND constraint_name='ck_m02_sampling_unit_nonblank'
 AND constraint_type='CHECK' AND enforced='YES');
