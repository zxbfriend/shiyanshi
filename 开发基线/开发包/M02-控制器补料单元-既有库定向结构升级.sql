-- Existing development/test database only; NOT part of the empty database installation chain.
-- Stop application writes and back up schema/data first. DDL commits implicitly.
-- Explicitly set @feed_unit_target_database to the confirmed current database before execution.
-- This changes schema only: no associations are inferred, inserted, or backfilled.
DROP PROCEDURE IF EXISTS m02_upgrade_feed_unit_20261028;
DELIMITER $$
CREATE PROCEDURE m02_upgrade_feed_unit_20261028()
BEGIN
  IF DATABASE() IS NULL OR @feed_unit_target_database IS NULL
     OR BINARY DATABASE() <> BINARY @feed_unit_target_database THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Explicit target database required';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE()
                 AND table_name='lab_bench_reactor_controller' AND column_name='m02_active') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Controller active-row key missing';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE()
                 AND table_name='lab_bench_reactor_controller' AND column_name='feed_unit_code') THEN
    ALTER TABLE lab_bench_reactor_controller ADD COLUMN feed_unit_code varchar(50)
      CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL
      COMMENT '当前实验室控制器对应的补料单元编码；NULL未配置' AFTER controller_no;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE()
                 AND table_name='lab_bench_reactor_controller' AND column_name='feed_unit_code'
                 AND data_type='varchar' AND character_maximum_length=50 AND is_nullable='YES'
                 AND collation_name='utf8mb4_0900_ai_ci') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Existing feed_unit_code has unexpected schema';
  END IF;
  IF EXISTS (SELECT lab_id, feed_unit_code FROM lab_bench_reactor_controller
             WHERE del_flag='0' AND feed_unit_code IS NOT NULL
             GROUP BY lab_id, feed_unit_code HAVING COUNT(*)>1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Duplicate active feed unit codes';
  END IF;
  IF EXISTS (SELECT 1 FROM lab_bench_reactor_controller
             WHERE feed_unit_code IS NOT NULL AND CHAR_LENGTH(TRIM(feed_unit_code))=0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Blank feed unit code';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE()
             AND table_name='lab_bench_reactor_controller' AND index_name='uk_m02_feed_unit')
     AND ((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE()
           AND table_name='lab_bench_reactor_controller' AND index_name='uk_m02_feed_unit')<>3
       OR (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE()
           AND table_name='lab_bench_reactor_controller' AND index_name='uk_m02_feed_unit'
           AND non_unique=0 AND ((seq_in_index=1 AND column_name='lab_id')
             OR (seq_in_index=2 AND column_name='feed_unit_code')
             OR (seq_in_index=3 AND column_name='m02_active')))<>3) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Existing feed unit index has unexpected schema';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE()
                 AND table_name='lab_bench_reactor_controller' AND index_name='uk_m02_feed_unit') THEN
    ALTER TABLE lab_bench_reactor_controller
      ADD UNIQUE INDEX uk_m02_feed_unit (lab_id,feed_unit_code,m02_active);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_schema=DATABASE()
                 AND table_name='lab_bench_reactor_controller' AND constraint_name='ck_m02_feed_unit_nonblank'
                 AND constraint_type='CHECK') THEN
    ALTER TABLE lab_bench_reactor_controller ADD CONSTRAINT ck_m02_feed_unit_nonblank
      CHECK (feed_unit_code IS NULL OR CHAR_LENGTH(TRIM(feed_unit_code))>0);
  END IF;
END$$
DELIMITER ;
CALL m02_upgrade_feed_unit_20261028();
DROP PROCEDURE m02_upgrade_feed_unit_20261028;

-- Structural and duplicate verification; empty result sets expected.
SELECT 'feed_unit_code' AS invalid_column WHERE NOT EXISTS (
 SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE()
  AND table_name='lab_bench_reactor_controller' AND column_name='feed_unit_code'
  AND data_type='varchar' AND character_maximum_length=50 AND is_nullable='YES'
  AND collation_name='utf8mb4_0900_ai_ci');
SELECT lab_id,feed_unit_code,COUNT(*) AS duplicate_count FROM lab_bench_reactor_controller
 WHERE del_flag='0' AND feed_unit_code IS NOT NULL GROUP BY lab_id,feed_unit_code HAVING COUNT(*)>1;
