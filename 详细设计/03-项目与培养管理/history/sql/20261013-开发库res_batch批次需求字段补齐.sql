-- HISTORICAL / DEVELOPMENT ENVIRONMENT REPAIR ONLY.
-- 适用范围：2026-10-13 经人工确认的既有开发库 res_batch 结构补齐。
-- 禁止加入 docs/开发基线 的新系统空库安装链；新系统仍只执行开发基线 01/02/03。
-- 本文件不含数据库名、地址或凭据。客户端必须预先选择目标库，并遇错停止。

-- 执行前：应返回当前库信息；missing_* 三项应均为 1，其余同名索引/约束应均为 0。
SELECT DATABASE() AS selected_database, VERSION() AS server_version;
SELECT
  SUM(column_name = 'feeding_interval_hours') = 0 AS missing_feeding_interval_hours,
  SUM(column_name = 'sampling_interval_hours') = 0 AS missing_sampling_interval_hours,
  SUM(column_name = 'upstream_batch_id') = 0 AS missing_upstream_batch_id
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name = 'res_batch';
SELECT COUNT(*) AS conflicting_index
FROM information_schema.statistics
WHERE table_schema = DATABASE()
  AND table_name = 'res_batch'
  AND index_name = 'idx_m03_batch_upstream';
SELECT COUNT(*) AS conflicting_constraint
FROM information_schema.table_constraints
WHERE constraint_schema = DATABASE()
  AND table_name = 'res_batch'
  AND constraint_name IN ('ck_m03_batch_intervals', 'ck_m03_batch_upstream');

-- 与现行权威结构 docs/开发基线/01-完整建表.sql 中 res_batch 定义一致。
ALTER TABLE `res_batch`
  ADD COLUMN `feeding_interval_hours` tinyint NULL
    COMMENT '补料间隔要求小时：8表示±8h，12表示±12h；未知不补默认值'
    AFTER `facts_status`,
  ADD COLUMN `sampling_interval_hours` tinyint NULL
    COMMENT '取测间隔要求小时：8或12；仅配置，不启动告警计时'
    AFTER `feeding_interval_hours`,
  ADD COLUMN `upstream_batch_id` bigint NULL
    COMMENT '中试下游引用同项目中试上游批次ID；稳定关联不以编号代替'
    AFTER `sampling_interval_hours`,
  MODIFY COLUMN `m03_live_code` varchar(50)
    GENERATED ALWAYS AS (
      CASE
        WHEN `del_flag` = '0' AND `upstream_batch_id` IS NULL THEN TRIM(`batch_code`)
        ELSE NULL
      END
    ) STORED
    COMMENT '独立编号项目内唯一；下游显式引用允许同号',
  ADD CONSTRAINT `ck_m03_batch_intervals`
    CHECK ((feeding_interval_hours IS NULL OR feeding_interval_hours IN (8,12))
       AND (sampling_interval_hours IS NULL OR sampling_interval_hours IN (8,12))),
  ADD CONSTRAINT `ck_m03_batch_upstream`
    CHECK (upstream_batch_id IS NULL
       OR (upstream_batch_id > 0 AND upstream_batch_id <> batch_id)),
  ADD INDEX `idx_m03_batch_upstream` (`upstream_batch_id`);

-- 执行后：三列、两项 CHECK、一个索引应各返回一行；异常结果必须为空。
SELECT column_name, column_type, is_nullable, generation_expression
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name = 'res_batch'
  AND column_name IN (
    'feeding_interval_hours',
    'sampling_interval_hours',
    'upstream_batch_id',
    'm03_live_code'
  )
ORDER BY ordinal_position;
SELECT constraint_name, check_clause
FROM information_schema.check_constraints
WHERE constraint_schema = DATABASE()
  AND constraint_name IN ('ck_m03_batch_intervals', 'ck_m03_batch_upstream')
ORDER BY constraint_name;
SELECT index_name, column_name, non_unique
FROM information_schema.statistics
WHERE table_schema = DATABASE()
  AND table_name = 'res_batch'
  AND index_name = 'idx_m03_batch_upstream';
SELECT batch_id, feeding_interval_hours, sampling_interval_hours, upstream_batch_id
FROM res_batch
WHERE (feeding_interval_hours IS NOT NULL AND feeding_interval_hours NOT IN (8,12))
   OR (sampling_interval_hours IS NOT NULL AND sampling_interval_hours NOT IN (8,12))
   OR (upstream_batch_id IS NOT NULL
       AND (upstream_batch_id <= 0 OR upstream_batch_id = batch_id));
