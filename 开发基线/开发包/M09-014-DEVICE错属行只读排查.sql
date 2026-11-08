-- ============================================================================
-- INT-30 · M09-014 DEVICE 作用域「存量错属行」只读排查包
-- ----------------------------------------------------------------------------
-- 性质：只读排查（READ-ONLY DIAGNOSTIC）。本文件整体由若干条独立的
--       SELECT / WITH（CTE）语句组成，不含任何数据写入、结构变更、
--       行移除或会话控制语句。
--
-- 与安装链的关系：本文件不属于新系统安装链，不得加入
--       docs/开发基线/01-完整建表.sql / 02-基础数据初始化.sql / 03-初始化结果核验.sql
--       的执行序列，也不是其中任何一步的前置或后置。安装链口径仍以
--       docs/开发基线/README.md 登记的入口为唯一权威。
--
-- 执行前提：
--   1. 不在共享开发库自动执行，不由本批代为执行；
--   2. 若需执行，优先本地临时库（按 01/02 装好的空库或脱敏副本），
--      或经明确授权、连接账号本身只读（建议同时置于只读事务中）；
--   3. 每一段都可单独执行，段与段之间无依赖。
--
-- 本批不修复数据：输出只是「疑似错属 / 读侧变为不可达」的行清单与计数。
--   任何处置（改属、清行、重挂作用域）都必须另开数据治理窗口，
--   并在获得总控批准后另行出脚本。
--
-- 方言：MySQL 8.0（使用 CTE 与 CTE 列别名表；与 01-完整建表.sql 的
--       utf8mb4_0900_ai_ci / CHECK / 生成列口径一致）。
--
-- 判决语义来源（全部为仓库现行实现，非推测）：
--   · 读侧接线     futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/
--                  service/impl/application/m09/AlarmMonitorPolicyApplicationApplicationServiceImpl.java
--                  :152-158（可见域读之后、仅 culture_id IS NULL 的 DEVICE 行送判）、
--                  :431-477（requireDeviceRowOwnedForRead 的失败映射）
--   · 种类值域     service/port/m02/model/DeviceKindFacts.java:25-39（冻结 9 种 + 一条探针路径）
--   · 种类→权威表  service/impl/port/m02/M02DeviceConfigurationAdapter.java:204-231（按 ID 只读路由）、
--                  :234-259（归属列取 lab_id）
--   · 可见域片段   resources/mapper/alarm/AlarmMonitorPolicyMapper.xml:monitorLabVisibleScope
--                  （非管理员按 sys_user_lab 过滤 o.lab_id；本包不复现权限判定）
-- ============================================================================


-- ============================================================================
-- 【S0】冻结 9 种 deviceKind → M02 权威表 / 主键 / 归属列 / 探针路径 名册
-- ----------------------------------------------------------------------------
-- provider_filters_del_flag 一列来自逐条实抽的 Mapper 语句（不是表结构推断）：
--   带软删过滤（按 ID 只读语句含 del_flag = '0'）：
--     LabBenchReactorMapper.xml:selectLabBenchReactorByReactorId
--     LabIntegratedReactorMapper.xml:selectLabIntegratedReactorByIntegratedId
--     LabDownstreamDeviceMapper.xml:selectLabDownstreamDeviceByDeviceId
--     LabBenchReactorControllerMapper.xml:selectLabBenchReactorControllerByConnectionId
--   不带软删过滤（按 ID 只读语句只按主键定位）：
--     LabCultureContainerMapper.xml / LabFloorScaleMapper.xml / LabDetectorMapper.xml /
--     LabPeristalticPumpMapper.xml / LabAirPumpMapper.xml 的对应 by-id 语句
-- 该差异直接决定 S3/S4 的原因归类，不是可选信息。
-- INT-37 复核：上述 provider_filters_del_flag 取值逐类实测仍准确（4 过滤 / 5 不过滤）。
-- 口径边界见 INT-37 §2.1：本包以 COALESCE(del_flag,'0') <> '0' 判「已软删」，而 8/9 张权威表
-- 的 del_flag 可为 NULL —— NULL 行在 4 个过滤类上被提供方隐藏（404），本包却记为 OWNER_MATCH。
-- 该差异只影响 S2/S3 的原因归类解释，不改本包语句逻辑，处置与工单面见 INT-37。
-- 探针路径只作为 requiredFields 的载体（CAP-I01 要求至少 1 条已登记路径），
-- 不参与归属判决；lab_bench_reactor_controller.controller_no 可为 NULL，
-- 提供方对此回值 NULL 且不视为失败。
-- ============================================================================
WITH frozen_kind (device_kind, authority_table, authority_pk, owner_column,
                  probe_field, provider_filters_del_flag) AS (
    -- 首分支显式定宽，避免 UNION 结果列按首行字面量长度截断后续较长种类名/表名
    SELECT CAST('BENCH_REACTOR' AS CHAR(40)), CAST('lab_bench_reactor' AS CHAR(64)),
           CAST('reactor_id' AS CHAR(32)), CAST('lab_id' AS CHAR(16)),
           CAST('asset_no' AS CHAR(32)), 1 UNION ALL
    SELECT 'INTEGRATED_REACTOR',  'lab_integrated_reactor',           'integrated_id', 'lab_id', 'reactor_name',   1 UNION ALL
    SELECT 'CONTAINER',           'lab_culture_container',            'container_id',  'lab_id', 'container_no',   0 UNION ALL
    SELECT 'FLOOR_SCALE',         'lab_floor_scale',                  'scale_id',      'lab_id', 'device_no',      0 UNION ALL
    SELECT 'DETECTOR',            'lab_detector',                     'detector_id',   'lab_id', 'device_no',      0 UNION ALL
    SELECT 'PERISTALTIC_PUMP',    'lab_peristaltic_pump',             'pump_id',       'lab_id', 'device_no',      0 UNION ALL
    SELECT 'AIR_PUMP',            'lab_air_pump',                     'air_pump_id',   'lab_id', 'device_no',      0 UNION ALL
    SELECT 'ANALYZER',            'lab_downstream_device',            'device_id',     'lab_id', 'device_no',      1 UNION ALL
    SELECT 'BENCH_CONTROLLER',    'lab_bench_reactor_controller',     'connection_id', 'lab_id', 'controller_no',  1
)
SELECT fk.device_kind,
       fk.authority_table,
       fk.authority_pk,
       fk.owner_column,
       fk.probe_field,
       CASE WHEN fk.provider_filters_del_flag = 1
            THEN 'PROVIDER_FILTERS_SOFT_REMOVED'
            ELSE 'PROVIDER_IGNORES_SOFT_REMOVED' END AS provider_del_flag_semantics,
       CASE WHEN COUNT(p.policy_id) = 0 THEN 'NO_POLICY_ROW'
            ELSE 'COVERED_BY_AUTHORITY_JOIN' END AS coverage_state
  FROM frozen_kind fk
  LEFT JOIN alarm_monitor_policy p
         ON p.device_kind = fk.device_kind
        AND p.culture_id IS NULL
 GROUP BY fk.device_kind, fk.authority_table, fk.authority_pk, fk.owner_column,
          fk.probe_field, fk.provider_filters_del_flag
 ORDER BY fk.device_kind;


-- ============================================================================
-- 【S1】DEVICE 行总量与作用域边界核对
-- ----------------------------------------------------------------------------
-- alarm_monitor_policy 上没有「DEVICE ⟺ culture_id IS NULL」的检查约束
-- （对比 alarm_online_config 的 ck_m09_close_online_scope），因此读口的
-- DEVICE/CULTURE 分支完全由 culture_id 是否为 NULL 决定。本段先把总体
-- 形状数出来，避免后续明细被误读成全表口径。
-- ============================================================================
SELECT CASE WHEN p.culture_id IS NULL THEN 'DEVICE' ELSE 'CULTURE' END AS scope_kind_on_row,
       CASE WHEN fk.device_kind IS NULL THEN 'OUT_OF_FROZEN_DOMAIN' ELSE 'IN_FROZEN_DOMAIN' END AS kind_domain_state,
       COUNT(*) AS policy_rows,
       COUNT(DISTINCT p.device_kind) AS distinct_device_kind,
       COUNT(DISTINCT p.lab_id) AS distinct_declared_lab
  FROM alarm_monitor_policy p
  LEFT JOIN (SELECT CAST('BENCH_REACTOR' AS CHAR(40)) AS device_kind UNION ALL
             SELECT 'INTEGRATED_REACTOR' UNION ALL
             SELECT 'CONTAINER' UNION ALL
             SELECT 'FLOOR_SCALE' UNION ALL
             SELECT 'DETECTOR' UNION ALL
             SELECT 'PERISTALTIC_PUMP' UNION ALL
             SELECT 'AIR_PUMP' UNION ALL
             SELECT 'ANALYZER' UNION ALL
             SELECT 'BENCH_CONTROLLER') fk
         ON fk.device_kind = p.device_kind
 GROUP BY CASE WHEN p.culture_id IS NULL THEN 'DEVICE' ELSE 'CULTURE' END,
          CASE WHEN fk.device_kind IS NULL THEN 'OUT_OF_FROZEN_DOMAIN' ELSE 'IN_FROZEN_DOMAIN' END
 ORDER BY scope_kind_on_row, kind_domain_state;


-- ============================================================================
-- 【S2】按 device_kind × 原因 的汇总（排查主视图）
-- ----------------------------------------------------------------------------
-- 原因口径与读侧判决一一对应，见 S3 明细列 int25_read_verdict。
-- ============================================================================
WITH device_fact (device_kind, instance_id, owner_lab_id, instance_del_flag,
                  provider_filters_del_flag) AS (
    SELECT CAST('BENCH_REACTOR' AS CHAR(40)), r.reactor_id, r.lab_id, r.del_flag, 1 FROM lab_bench_reactor r UNION ALL
    SELECT 'INTEGRATED_REACTOR', ir.integrated_id,  ir.lab_id, ir.del_flag, 1 FROM lab_integrated_reactor ir UNION ALL
    SELECT 'CONTAINER',          c.container_id,    c.lab_id, c.del_flag, 0 FROM lab_culture_container c UNION ALL
    SELECT 'FLOOR_SCALE',        fs.scale_id,       fs.lab_id, fs.del_flag, 0 FROM lab_floor_scale fs UNION ALL
    SELECT 'DETECTOR',           dt.detector_id,    dt.lab_id, dt.del_flag, 0 FROM lab_detector dt UNION ALL
    SELECT 'PERISTALTIC_PUMP',   pp.pump_id,        pp.lab_id, pp.del_flag, 0 FROM lab_peristaltic_pump pp UNION ALL
    SELECT 'AIR_PUMP',           ap.air_pump_id,    ap.lab_id, ap.del_flag, 0 FROM lab_air_pump ap UNION ALL
    SELECT 'ANALYZER',           dd.device_id,      dd.lab_id, dd.del_flag, 1 FROM lab_downstream_device dd UNION ALL
    SELECT 'BENCH_CONTROLLER',   bc.connection_id,  bc.lab_id, bc.del_flag, 1 FROM lab_bench_reactor_controller bc
),
frozen_kind (device_kind) AS (
    SELECT CAST('BENCH_REACTOR' AS CHAR(40)) UNION ALL SELECT 'INTEGRATED_REACTOR' UNION ALL SELECT 'CONTAINER' UNION ALL
    SELECT 'FLOOR_SCALE'   UNION ALL SELECT 'DETECTOR'           UNION ALL SELECT 'PERISTALTIC_PUMP' UNION ALL
    SELECT 'AIR_PUMP'      UNION ALL SELECT 'ANALYZER'           UNION ALL SELECT 'BENCH_CONTROLLER'
),
policy_device AS (
    SELECT p.policy_id, p.scope_key, p.lab_id, p.device_kind, p.device_id,
           p.culture_id, p.monitor_mode, p.row_version, p.revision_id
      FROM alarm_monitor_policy p
     WHERE p.culture_id IS NULL
)
SELECT pd.device_kind,
       CASE
           WHEN fk.device_kind IS NULL                              THEN 'OUT_OF_FROZEN_DOMAIN'
           WHEN pd.device_kind IS NULL
             OR pd.device_id   IS NULL
             OR pd.lab_id      IS NULL                              THEN 'ROW_SCOPE_FACT_INCOMPLETE'
           WHEN df.instance_id IS NULL                              THEN 'DEVICE_INSTANCE_MISSING'
           WHEN df.provider_filters_del_flag = 1
             AND COALESCE(df.instance_del_flag, '0') <> '0'         THEN 'DEVICE_INSTANCE_SOFT_REMOVED_PROVIDER_MISS'
           WHEN df.owner_lab_id <> pd.lab_id                        THEN 'OWNER_LAB_MISMATCH'
           WHEN COALESCE(df.instance_del_flag, '0') <> '0'          THEN 'OWNER_MATCH_BUT_INSTANCE_SOFT_REMOVED'
           ELSE 'OWNER_MATCH'
       END AS mismatch_reason,
       CASE
           WHEN fk.device_kind IS NULL                              THEN 'NOT_FOUND'
           WHEN pd.device_kind IS NULL
             OR pd.device_id   IS NULL
             OR pd.lab_id      IS NULL                              THEN 'NOT_FOUND'
           WHEN df.instance_id IS NULL                              THEN 'NOT_FOUND'
           WHEN df.provider_filters_del_flag = 1
             AND COALESCE(df.instance_del_flag, '0') <> '0'         THEN 'NOT_FOUND'
           WHEN df.owner_lab_id <> pd.lab_id                        THEN 'NOT_FOUND'
           WHEN COALESCE(df.instance_del_flag, '0') <> '0'          THEN 'STILL_READABLE_RESIDUAL_GAP'
           ELSE 'STILL_READABLE'
       END AS int25_read_verdict,
       COUNT(*) AS rows_hit
  FROM policy_device pd
  LEFT JOIN frozen_kind fk ON fk.device_kind = pd.device_kind
  LEFT JOIN device_fact  df ON df.device_kind = pd.device_kind
                           AND df.instance_id = pd.device_id
 GROUP BY pd.device_kind,
          CASE
              WHEN fk.device_kind IS NULL                          THEN 'OUT_OF_FROZEN_DOMAIN'
              WHEN pd.device_kind IS NULL
                OR pd.device_id   IS NULL
                OR pd.lab_id      IS NULL                          THEN 'ROW_SCOPE_FACT_INCOMPLETE'
              WHEN df.instance_id IS NULL                          THEN 'DEVICE_INSTANCE_MISSING'
              WHEN df.provider_filters_del_flag = 1
                AND COALESCE(df.instance_del_flag, '0') <> '0'     THEN 'DEVICE_INSTANCE_SOFT_REMOVED_PROVIDER_MISS'
              WHEN df.owner_lab_id <> pd.lab_id                    THEN 'OWNER_LAB_MISMATCH'
              WHEN COALESCE(df.instance_del_flag, '0') <> '0'      THEN 'OWNER_MATCH_BUT_INSTANCE_SOFT_REMOVED'
              ELSE 'OWNER_MATCH'
          END,
          CASE
              WHEN fk.device_kind IS NULL                          THEN 'NOT_FOUND'
              WHEN pd.device_kind IS NULL
                OR pd.device_id   IS NULL
                OR pd.lab_id      IS NULL                          THEN 'NOT_FOUND'
              WHEN df.instance_id IS NULL                          THEN 'NOT_FOUND'
              WHEN df.provider_filters_del_flag = 1
                AND COALESCE(df.instance_del_flag, '0') <> '0'     THEN 'NOT_FOUND'
              WHEN df.owner_lab_id <> pd.lab_id                    THEN 'NOT_FOUND'
              WHEN COALESCE(df.instance_del_flag, '0') <> '0'      THEN 'STILL_READABLE_RESIDUAL_GAP'
              ELSE 'STILL_READABLE'
          END
 ORDER BY pd.device_kind, mismatch_reason;


-- ============================================================================
-- 【S3】明细：INT-25 读侧判决后对声明实验室返回 NOT_FOUND 的行清单
-- ----------------------------------------------------------------------------
-- 输出列含 policy_id / scope_key / device_kind / device_id / culture_id /
-- 行上 lab_id / 权威行真实归属 lab_id / 原因 / 判决。
-- 注意：判决发生在可见域之后，因此本段只证明「归属一致性问题」，
--       不代表这些行当前一定对某个用户可见（可见性另由 sys_user_lab 决定）。
-- ============================================================================
WITH device_fact (device_kind, instance_id, owner_lab_id, instance_del_flag,
                  provider_filters_del_flag) AS (
    SELECT CAST('BENCH_REACTOR' AS CHAR(40)), r.reactor_id, r.lab_id, r.del_flag, 1 FROM lab_bench_reactor r UNION ALL
    SELECT 'INTEGRATED_REACTOR', ir.integrated_id,  ir.lab_id, ir.del_flag, 1 FROM lab_integrated_reactor ir UNION ALL
    SELECT 'CONTAINER',          c.container_id,    c.lab_id, c.del_flag, 0 FROM lab_culture_container c UNION ALL
    SELECT 'FLOOR_SCALE',        fs.scale_id,       fs.lab_id, fs.del_flag, 0 FROM lab_floor_scale fs UNION ALL
    SELECT 'DETECTOR',           dt.detector_id,    dt.lab_id, dt.del_flag, 0 FROM lab_detector dt UNION ALL
    SELECT 'PERISTALTIC_PUMP',   pp.pump_id,        pp.lab_id, pp.del_flag, 0 FROM lab_peristaltic_pump pp UNION ALL
    SELECT 'AIR_PUMP',           ap.air_pump_id,    ap.lab_id, ap.del_flag, 0 FROM lab_air_pump ap UNION ALL
    SELECT 'ANALYZER',           dd.device_id,      dd.lab_id, dd.del_flag, 1 FROM lab_downstream_device dd UNION ALL
    SELECT 'BENCH_CONTROLLER',   bc.connection_id,  bc.lab_id, bc.del_flag, 1 FROM lab_bench_reactor_controller bc
),
frozen_kind (device_kind) AS (
    SELECT CAST('BENCH_REACTOR' AS CHAR(40)) UNION ALL SELECT 'INTEGRATED_REACTOR' UNION ALL SELECT 'CONTAINER' UNION ALL
    SELECT 'FLOOR_SCALE'   UNION ALL SELECT 'DETECTOR'           UNION ALL SELECT 'PERISTALTIC_PUMP' UNION ALL
    SELECT 'AIR_PUMP'      UNION ALL SELECT 'ANALYZER'           UNION ALL SELECT 'BENCH_CONTROLLER'
),
judged AS (
    SELECT p.policy_id, p.scope_key, p.device_kind, p.device_id, p.culture_id,
           p.lab_id AS policy_lab_id,
           p.monitor_mode, p.row_version, p.revision_id,
           df.instance_id,
           df.owner_lab_id,
           df.instance_del_flag,
           df.provider_filters_del_flag,
           CASE
               WHEN fk.device_kind IS NULL                      THEN 'OUT_OF_FROZEN_DOMAIN'
               WHEN p.device_kind IS NULL
                 OR p.device_id   IS NULL
                 OR p.lab_id      IS NULL                       THEN 'ROW_SCOPE_FACT_INCOMPLETE'
               WHEN df.instance_id IS NULL                      THEN 'DEVICE_INSTANCE_MISSING'
               WHEN df.provider_filters_del_flag = 1
                 AND COALESCE(df.instance_del_flag, '0') <> '0' THEN 'DEVICE_INSTANCE_SOFT_REMOVED_PROVIDER_MISS'
               WHEN df.owner_lab_id <> p.lab_id                 THEN 'OWNER_LAB_MISMATCH'
               WHEN COALESCE(df.instance_del_flag, '0') <> '0'  THEN 'OWNER_MATCH_BUT_INSTANCE_SOFT_REMOVED'
               ELSE 'OWNER_MATCH'
           END AS mismatch_reason,
           CASE
               WHEN fk.device_kind IS NULL                      THEN 'NOT_FOUND'
               WHEN p.device_kind IS NULL
                 OR p.device_id   IS NULL
                 OR p.lab_id      IS NULL                       THEN 'NOT_FOUND'
               WHEN df.instance_id IS NULL                      THEN 'NOT_FOUND'
               WHEN df.provider_filters_del_flag = 1
                 AND COALESCE(df.instance_del_flag, '0') <> '0' THEN 'NOT_FOUND'
               WHEN df.owner_lab_id <> p.lab_id                 THEN 'NOT_FOUND'
               WHEN COALESCE(df.instance_del_flag, '0') <> '0'  THEN 'STILL_READABLE_RESIDUAL_GAP'
               ELSE 'STILL_READABLE'
           END AS int25_read_verdict
      FROM alarm_monitor_policy p
      LEFT JOIN frozen_kind fk ON fk.device_kind = p.device_kind
      LEFT JOIN device_fact  df ON df.device_kind = p.device_kind
                               AND df.instance_id = p.device_id
     WHERE p.culture_id IS NULL
)
SELECT j.policy_id,
       j.scope_key,
       j.device_kind,
       j.device_id,
       j.culture_id,
       j.policy_lab_id,
       j.owner_lab_id,
       j.mismatch_reason,
       j.int25_read_verdict,
       CASE WHEN j.mismatch_reason = 'OWNER_LAB_MISMATCH'
            THEN '行声明归属与设备真实归属不符；真实归属方 lab 可识别'
            WHEN j.mismatch_reason = 'DEVICE_INSTANCE_MISSING'
            THEN '权威表无该主键行（悬挂作用域）'
            WHEN j.mismatch_reason = 'DEVICE_INSTANCE_SOFT_REMOVED_PROVIDER_MISS'
            THEN '设备行已软删，且该类按 ID 只读语句带软删过滤 ⇒ 提供方 404'
            WHEN j.mismatch_reason = 'OUT_OF_FROZEN_DOMAIN'
            THEN 'deviceKind 越出冻结 9 种 ⇒ 进提供方前即关闭'
            ELSE '行上作用域事实不完整 ⇒ 送判前关闭' END AS reason_detail,
       CASE WHEN j.owner_lab_id IS NULL THEN 'N/A'
            WHEN ol.lab_id IS NULL THEN 'OWNER_LAB_MISSING'
            WHEN COALESCE(ol.del_flag, '0') <> '0' THEN 'OWNER_LAB_SOFT_REMOVED'
            ELSE 'OWNER_LAB_LIVE' END AS owner_lab_state,
       CASE WHEN dl.lab_id IS NULL THEN 'DECLARED_LAB_MISSING'
            WHEN COALESCE(dl.del_flag, '0') <> '0' THEN 'DECLARED_LAB_SOFT_REMOVED'
            ELSE 'DECLARED_LAB_LIVE' END AS declared_lab_state
  FROM judged j
  LEFT JOIN lab_lab ol ON ol.lab_id = j.owner_lab_id
  LEFT JOIN lab_lab dl ON dl.lab_id = j.policy_lab_id
 WHERE j.int25_read_verdict = 'NOT_FOUND'
 ORDER BY j.mismatch_reason, j.device_kind, j.policy_id;


-- ============================================================================
-- 【S4】残留缺口专表：归属相符但设备已软删、且该类提供方不过滤软删
-- ----------------------------------------------------------------------------
-- 这 5 类（CONTAINER / FLOOR_SCALE / DETECTOR / PERISTALTIC_PUMP / AIR_PUMP）
-- 的按 ID 只读语句不带软删条件，因此设备已软删时 CAP-I01 仍按 lab_id 比对
-- 并通过 ⇒ 读侧照常回行内容。INT-25 没有闭这条口，属提供方语义差异，
-- 本包只登记，不判定为业务缺陷，也不宣称已治理。
-- ============================================================================
WITH device_fact (device_kind, instance_id, owner_lab_id, instance_del_flag,
                  provider_filters_del_flag) AS (
    SELECT CAST('CONTAINER' AS CHAR(40)), c.container_id, c.lab_id, c.del_flag, 0 FROM lab_culture_container c UNION ALL
    SELECT 'FLOOR_SCALE',      fs.scale_id,      fs.lab_id, fs.del_flag, 0 FROM lab_floor_scale fs UNION ALL
    SELECT 'DETECTOR',         dt.detector_id,   dt.lab_id, dt.del_flag, 0 FROM lab_detector dt UNION ALL
    SELECT 'PERISTALTIC_PUMP', pp.pump_id,       pp.lab_id, pp.del_flag, 0 FROM lab_peristaltic_pump pp UNION ALL
    SELECT 'AIR_PUMP',         ap.air_pump_id,   ap.lab_id, ap.del_flag, 0 FROM lab_air_pump ap
)
SELECT p.policy_id,
       p.scope_key,
       p.device_kind,
       p.device_id,
       p.culture_id,
       p.lab_id AS policy_lab_id,
       df.owner_lab_id,
       df.instance_del_flag,
       'OWNER_MATCH_BUT_INSTANCE_SOFT_REMOVED' AS mismatch_reason,
       'STILL_READABLE_RESIDUAL_GAP' AS int25_read_verdict
  FROM alarm_monitor_policy p
  JOIN device_fact df ON df.device_kind = p.device_kind
                    AND df.instance_id = p.device_id
 WHERE p.culture_id IS NULL
   AND COALESCE(df.instance_del_flag, '0') <> '0'
   AND df.owner_lab_id = p.lab_id
 ORDER BY p.device_kind, p.policy_id;


-- ============================================================================
-- 【S5】越域 deviceKind 名册：数据中实际出现、但不在冻结 9 种之内的种类
-- ----------------------------------------------------------------------------
-- 读侧对这类行在调用提供方之前即以 NOT_FOUND 关闭，因此它们对任何用户
-- 都不再可读；本段用于确认是否需要另开种类登记窗口。
-- ============================================================================
SELECT p.device_kind,
       COUNT(*) AS policy_rows,
       MIN(p.lab_id) AS sample_declared_lab_id,
       MIN(p.device_id) AS sample_device_id,
       'OUT_OF_FROZEN_DOMAIN' AS mismatch_reason,
       'NOT_FOUND' AS int25_read_verdict,
       '越出 DeviceKindFacts.KIND_VALUES，未进入提供方' AS reason_detail
  FROM alarm_monitor_policy p
 WHERE p.culture_id IS NULL
   AND p.device_kind NOT IN ('BENCH_REACTOR', 'INTEGRATED_REACTOR', 'CONTAINER',
                             'FLOOR_SCALE', 'DETECTOR', 'PERISTALTIC_PUMP',
                             'AIR_PUMP', 'ANALYZER', 'BENCH_CONTROLLER')
 GROUP BY p.device_kind
 ORDER BY p.device_kind;


-- ============================================================================
-- 【S6】主数据完整性旁证：声明 lab / 真实归属 lab 在 lab_lab 的落地状态
-- ----------------------------------------------------------------------------
-- CAP-I01 只做 lab_id 的数值相等比对，lab 行缺失或被软删都不会改变判决结果，
-- 因此本段列出的行不会因 lab 状态变 NOT_FOUND；它们的意义是治理排序时
-- 判断「真实归属方是否仍可识别」。
-- ============================================================================
WITH device_fact (device_kind, instance_id, owner_lab_id, instance_del_flag,
                  provider_filters_del_flag) AS (
    SELECT CAST('BENCH_REACTOR' AS CHAR(40)), r.reactor_id, r.lab_id, r.del_flag, 1 FROM lab_bench_reactor r UNION ALL
    SELECT 'INTEGRATED_REACTOR', ir.integrated_id,  ir.lab_id, ir.del_flag, 1 FROM lab_integrated_reactor ir UNION ALL
    SELECT 'CONTAINER',          c.container_id,    c.lab_id, c.del_flag, 0 FROM lab_culture_container c UNION ALL
    SELECT 'FLOOR_SCALE',        fs.scale_id,       fs.lab_id, fs.del_flag, 0 FROM lab_floor_scale fs UNION ALL
    SELECT 'DETECTOR',           dt.detector_id,    dt.lab_id, dt.del_flag, 0 FROM lab_detector dt UNION ALL
    SELECT 'PERISTALTIC_PUMP',   pp.pump_id,        pp.lab_id, pp.del_flag, 0 FROM lab_peristaltic_pump pp UNION ALL
    SELECT 'AIR_PUMP',           ap.air_pump_id,    ap.lab_id, ap.del_flag, 0 FROM lab_air_pump ap UNION ALL
    SELECT 'ANALYZER',           dd.device_id,      dd.lab_id, dd.del_flag, 1 FROM lab_downstream_device dd UNION ALL
    SELECT 'BENCH_CONTROLLER',   bc.connection_id,  bc.lab_id, bc.del_flag, 1 FROM lab_bench_reactor_controller bc
)
SELECT CASE WHEN dl.lab_id IS NULL THEN 'DECLARED_LAB_MISSING'
            WHEN COALESCE(dl.del_flag, '0') <> '0' THEN 'DECLARED_LAB_SOFT_REMOVED'
            ELSE 'DECLARED_LAB_LIVE' END AS declared_lab_state,
       CASE WHEN df.instance_id IS NULL THEN 'NO_INSTANCE_ROW'
            WHEN ol.lab_id IS NULL THEN 'OWNER_LAB_MISSING'
            WHEN COALESCE(ol.del_flag, '0') <> '0' THEN 'OWNER_LAB_SOFT_REMOVED'
            ELSE 'OWNER_LAB_LIVE' END AS owner_lab_state,
       CASE WHEN df.instance_id IS NULL THEN 'N/A'
            WHEN df.owner_lab_id = p.lab_id THEN 'OWNER_MATCH'
            ELSE 'OWNER_LAB_MISMATCH' END AS ownership_state,
       COUNT(*) AS policy_rows
  FROM alarm_monitor_policy p
  LEFT JOIN device_fact df ON df.device_kind = p.device_kind
                          AND df.instance_id = p.device_id
  LEFT JOIN lab_lab dl ON dl.lab_id = p.lab_id
  LEFT JOIN lab_lab ol ON ol.lab_id = df.owner_lab_id
 WHERE p.culture_id IS NULL
 GROUP BY CASE WHEN dl.lab_id IS NULL THEN 'DECLARED_LAB_MISSING'
               WHEN COALESCE(dl.del_flag, '0') <> '0' THEN 'DECLARED_LAB_SOFT_REMOVED'
               ELSE 'DECLARED_LAB_LIVE' END,
          CASE WHEN df.instance_id IS NULL THEN 'NO_INSTANCE_ROW'
               WHEN ol.lab_id IS NULL THEN 'OWNER_LAB_MISSING'
               WHEN COALESCE(ol.del_flag, '0') <> '0' THEN 'OWNER_LAB_SOFT_REMOVED'
               ELSE 'OWNER_LAB_LIVE' END,
          CASE WHEN df.instance_id IS NULL THEN 'N/A'
               WHEN df.owner_lab_id = p.lab_id THEN 'OWNER_MATCH'
               ELSE 'OWNER_LAB_MISMATCH' END
 ORDER BY declared_lab_state, owner_lab_state, ownership_state;

-- ============================================================================
-- 包尾说明
-- ----------------------------------------------------------------------------
-- 1. 本包每一段都是独立可执行的只读查询；全文件不含数据写入、结构变更
--    或行移除语句，也不使用临时视图、临时表、存储过程与游标。
-- 2. S2/S3 的 NOT_FOUND 口径只覆盖「归属与设备存在性」这一层。读口还有
--    两类 NOT_FOUND 出口无法由本包判定：
--      · actorUserId 为空的失败关闭（取决于发起请求的会话是否已登录）；
--      · 可见域片段判不可见（取决于 sys_user_lab 与该用户的关系）。
--    提供方缺失或事实源异常导致的 503 不属本包统计面。
-- 3. 本包在空库上应返回 0 行，这既不是失败也不是「存量已治理」的证据。
-- ============================================================================
