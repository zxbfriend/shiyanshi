-- RM-04: existing development database only; NOT part of the empty-database installation chain.
-- Stop application writes and back up both tables before running. MySQL DDL commits implicitly;
-- schema changes may remain after an error, but rerunning is supported after fixing the reported conflict.
-- Confirm the actual target and operator explicitly, for example:
-- SET @rm_binding_database = 'confirmed_local_database';
-- SET @rm_binding_actor = 'confirmed_current_user';
-- Never infer association from controller_no, asset_no, model, connection_name or matching numeric IDs.
DROP PROCEDURE IF EXISTS rm_upgrade_controller_binding_20261024;
DELIMITER $$
CREATE PROCEDURE rm_upgrade_controller_binding_20261024()
BEGIN
  DECLARE schema_changed BOOLEAN DEFAULT FALSE;
  DECLARE row_changes BIGINT DEFAULT 0;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;
  IF DATABASE() IS NULL OR @rm_binding_database IS NULL
      OR BINARY DATABASE() <> BINARY @rm_binding_database
      OR @rm_binding_actor IS NULL OR CHAR_LENGTH(TRIM(@rm_binding_actor)) NOT BETWEEN 1 AND 64 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Explicit target database and operator required';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM sys_management_revision WHERE scope_key='SYSTEM') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SYSTEM management revision missing';
  END IF;
  IF EXISTS (
    SELECT c.reactor_id FROM lab_bench_reactor_controller c
    WHERE c.del_flag='0' AND c.reactor_id IS NOT NULL
    GROUP BY c.reactor_id HAVING COUNT(*) > 1
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ambiguous legacy reactor/controller relationship';
  END IF;
  IF EXISTS (
    SELECT 1 FROM lab_bench_reactor_controller c
    LEFT JOIN lab_bench_reactor r ON r.reactor_id=c.reactor_id AND r.del_flag='0'
    WHERE c.del_flag='0' AND c.reactor_id IS NOT NULL
      AND (r.reactor_id IS NULL OR r.lab_id<>c.lab_id)
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Legacy relationship missing active reactor or crosses laboratories';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
      WHERE table_schema=DATABASE() AND table_name='lab_bench_reactor' AND column_name='controller_id') THEN
    ALTER TABLE lab_bench_reactor ADD COLUMN controller_id bigint NULL
      COMMENT '独立控制器connection_id；一个控制器可关联多个罐体' AFTER venue_id;
    SET schema_changed=TRUE;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
      WHERE table_schema=DATABASE() AND table_name='lab_bench_reactor' AND column_name='controller_id'
        AND data_type='bigint' AND is_nullable='YES') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Existing controller_id has unexpected schema';
  END IF;
  IF EXISTS (
    SELECT 1 FROM lab_bench_reactor r LEFT JOIN lab_bench_reactor_controller c
      ON c.connection_id=r.controller_id AND c.del_flag='0'
    WHERE r.del_flag='0' AND r.controller_id IS NOT NULL
      AND (c.connection_id IS NULL OR c.lab_id<>r.lab_id)
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Existing controller binding invalid or crosses laboratories';
  END IF;
  IF EXISTS (
    SELECT 1 FROM lab_bench_reactor r JOIN lab_bench_reactor_controller c
      ON c.reactor_id=r.reactor_id AND c.del_flag='0'
    WHERE r.del_flag='0' AND r.controller_id IS NOT NULL AND r.controller_id<>c.connection_id
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'New binding conflicts with explicit legacy relationship';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.statistics
      WHERE table_schema=DATABASE() AND table_name='lab_bench_reactor'
        AND index_name='idx_bench_reactor_controller'
        AND (non_unique<>1 OR column_name<>'controller_id' OR seq_in_index<>1)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Controller binding index has unexpected schema';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.statistics
      WHERE table_schema=DATABASE() AND table_name='lab_bench_reactor' AND index_name='idx_bench_reactor_controller') THEN
    ALTER TABLE lab_bench_reactor ADD INDEX idx_bench_reactor_controller(controller_id);
    SET schema_changed=TRUE;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.statistics
      WHERE table_schema=DATABASE() AND table_name='lab_bench_reactor_controller' AND index_name='uk_m02_business') THEN
    ALTER TABLE lab_bench_reactor_controller DROP INDEX uk_m02_business;
    SET schema_changed=TRUE;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns
      WHERE table_schema=DATABASE() AND table_name='lab_bench_reactor_controller' AND column_name='reactor_id'
        AND (is_nullable<>'YES' OR column_comment<>'历史迁移关联；新关系使用lab_bench_reactor.controller_id')) THEN
    ALTER TABLE lab_bench_reactor_controller MODIFY COLUMN reactor_id bigint NULL DEFAULT NULL
      COMMENT '历史迁移关联；新关系使用lab_bench_reactor.controller_id';
    SET schema_changed=TRUE;
  END IF;

  START TRANSACTION;
  UPDATE lab_bench_reactor r JOIN lab_bench_reactor_controller c
    ON c.reactor_id=r.reactor_id AND c.lab_id=r.lab_id AND c.del_flag='0'
    SET r.controller_id=c.connection_id, r.update_by=TRIM(@rm_binding_actor), r.update_time=CURRENT_TIMESTAMP
    WHERE r.del_flag='0' AND r.controller_id IS NULL;
  SET row_changes=ROW_COUNT();
  IF schema_changed OR row_changes>0 THEN
    UPDATE sys_management_revision SET revision=revision+1, update_time=CURRENT_TIMESTAMP WHERE scope_key='SYSTEM';
  END IF;
  COMMIT;
  SELECT schema_changed AS schema_changed, row_changes AS migrated_vessel_count;
END$$
DELIMITER ;
CALL rm_upgrade_controller_binding_20261024();
DROP PROCEDURE rm_upgrade_controller_binding_20261024;

-- Must return zero rows after migration. Independent unbound controllers are legal.
SELECT r.reactor_id, r.controller_id AS invalid_binding
FROM lab_bench_reactor r LEFT JOIN lab_bench_reactor_controller c
  ON c.connection_id=r.controller_id AND c.del_flag='0' AND c.lab_id=r.lab_id
WHERE r.del_flag='0' AND r.controller_id IS NOT NULL AND c.connection_id IS NULL;
SELECT c.connection_id, c.reactor_id AS unresolved_legacy_relationship
FROM lab_bench_reactor_controller c JOIN lab_bench_reactor r
  ON r.reactor_id=c.reactor_id AND r.del_flag='0'
WHERE c.del_flag='0' AND c.reactor_id IS NOT NULL
  AND (r.controller_id IS NULL OR r.controller_id<>c.connection_id);
