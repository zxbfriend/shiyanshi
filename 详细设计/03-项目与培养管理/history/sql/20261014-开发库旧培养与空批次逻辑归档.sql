-- 2026-10-14 开发库旧培养与空批次逻辑归档
--
-- 适用范围：仅 ymsw_v2 当前已核对的开发测试数据。
-- 目的：不猜测回填 lifecycle_state；逻辑归档旧未知状态培养，并归档随后变空的批次，
--       释放业务编号供重新导入，同时保留检测、告警、运行事件等历史引用。
-- 注意：本文件属于开发库一次性维护记录，不属于新系统默认安装链，不得在其他库直接执行。

START TRANSACTION;

-- 执行前应返回 15；若数量或 ID 不一致，停止并 ROLLBACK。
SELECT culture_id, culture_code, batch_id, lifecycle_state, del_flag
FROM res_culture
WHERE del_flag = '0'
  AND lifecycle_state IS NULL
  AND culture_id IN (
      14001, 14002, 14003, 14004, 14005, 14006,
      1279162443460907008, 1279162443880337408,
      1283395517660925952,
      1287771021390254080, 1287771022250086400,
      1287771022975700992, 1287771023428685824,
      1297607767909076992, 1297607767997157376
  )
ORDER BY culture_id;

UPDATE res_culture
SET del_flag = '2',
    deleted_at = CURRENT_TIMESTAMP,
    deleted_by_user_id = 1,
    modifier_user_id = 1,
    object_version = object_version + 1,
    update_by = 'maintenance-20261014',
    update_time = CURRENT_TIMESTAMP
WHERE del_flag = '0'
  AND lifecycle_state IS NULL
  AND culture_id IN (
      14001, 14002, 14003, 14004, 14005, 14006,
      1279162443460907008, 1279162443880337408,
      1283395517660925952,
      1287771021390254080, 1287771022250086400,
      1287771022975700992, 1287771023428685824,
      1297607767909076992, 1297607767997157376
  );

-- 仅归档已经没有有效培养、且未被中试下游批次引用的 8 个旧批次。
UPDATE res_batch b
LEFT JOIN res_batch downstream_batch
  ON downstream_batch.upstream_batch_id = b.batch_id
 AND downstream_batch.del_flag <> '2'
SET b.del_flag = '2',
    b.deleted_at = CURRENT_TIMESTAMP,
    b.deleted_by_user_id = 1,
    b.modifier_user_id = 1,
    b.object_version = b.object_version + 1,
    b.update_by = 'maintenance-20261014',
    b.update_time = CURRENT_TIMESTAMP
WHERE b.del_flag = '0'
  AND b.batch_id IN (
      13001, 13002, 13003, 13004, 99001,
      1283395516457160704, 1287771019662200832,
      1297607767653224448
  )
  AND downstream_batch.batch_id IS NULL
  AND NOT EXISTS (
      SELECT 1
      FROM res_culture c
      WHERE c.batch_id = b.batch_id
        AND c.del_flag <> '2'
  );

-- 执行后核验：应为 unknown_active_cultures=0、archived_target_cultures=15、
-- archived_target_batches=8；其余有效培养应保持 3 条。
SELECT
    SUM(del_flag = '0' AND lifecycle_state IS NULL) AS unknown_active_cultures,
    SUM(del_flag = '2' AND culture_id IN (
        14001, 14002, 14003, 14004, 14005, 14006,
        1279162443460907008, 1279162443880337408,
        1283395517660925952,
        1287771021390254080, 1287771022250086400,
        1287771022975700992, 1287771023428685824,
        1297607767909076992, 1297607767997157376
    )) AS archived_target_cultures,
    SUM(del_flag = '0') AS remaining_active_cultures
FROM res_culture;

SELECT
    SUM(del_flag = '2' AND batch_id IN (
        13001, 13002, 13003, 13004, 99001,
        1283395516457160704, 1287771019662200832,
        1297607767653224448
    )) AS archived_target_batches,
    SUM(del_flag = '0') AS remaining_active_batches
FROM res_batch;

COMMIT;
