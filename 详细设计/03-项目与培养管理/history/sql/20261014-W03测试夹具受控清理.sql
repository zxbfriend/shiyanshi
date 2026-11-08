-- 2026-10-14 W03 测试夹具受控清理
--
-- 仅适用于 ymsw_v2 中下列固定测试身份：
-- project 900000000000002001 / batch 900000000000002002 /
-- culture 900000000000002003 / command 1306740509976432640。
--
-- 处理原则：命令从未调用设备，因此固定 NOT_SENT 证据并关闭派发资格；
-- 工作流、步骤和资源守卫收口为终态；M03 主对象逻辑归档；运行事件保留。
-- 本文件不是新系统安装链或通用迁移脚本，不得在其他库直接执行。

START TRANSACTION;

-- 必须恰好返回一行 PREPARED，且 device_command_id/invoked_at 为空、attempt_count=0。
SELECT command_id, state, device_command_id, invoked_at, attempt_count, object_version
FROM run_command
WHERE command_id = 1306740509976432640
FOR UPDATE;

-- 未调用设备的测试命令退出派发集合；FAILED 在命令值域内，证据明确为 NOT_SENT。
UPDATE run_command
SET state = 'FAILED',
    object_version = object_version + 1,
    result_evidence = JSON_OBJECT(
        'queryState', 'NOT_SENT',
        'reason', 'TEST_FIXTURE_RETIRED',
        'maintenanceDate', '2026-10-14'
    ),
    last_error = 'W03 test fixture retired before device invocation',
    resolved_at = CURRENT_TIMESTAMP(3),
    next_query_at = NULL
WHERE command_id = 1306740509976432640
  AND culture_id = 900000000000002003
  AND state = 'PREPARED'
  AND device_command_id IS NULL
  AND invoked_at IS NULL
  AND attempt_count = 0;

-- 只取消尚未结束的步骤；已经完成的步骤保持原始历史事实。
UPDATE run_workflow_step
SET state = 'CANCELLED',
    object_version = object_version + 1,
    ended_at = COALESCE(ended_at, CURRENT_TIMESTAMP(3))
WHERE workflow_id IN (
    1306736114282926080,
    1307049462694285312,
    1307054580735021056
)
  AND state IN ('PENDING', 'IN_PROGRESS');

UPDATE run_workflow_instance
SET state = 'CANCELLED',
    application_state = 'NONE',
    object_version = object_version + 1,
    ended_at = COALESCE(ended_at, CURRENT_TIMESTAMP(3))
WHERE culture_id = 900000000000002003
  AND workflow_id IN (
      1306736114282926080,
      1307049462694285312,
      1307054580735021056
  )
  AND state IN ('OPEN', 'IN_PROGRESS', 'NEEDS_RECONCILIATION');

-- 命令已证明未调用，释放该测试工作流持有的两个资源守卫；保留 fence 单调值。
UPDATE run_resource_guard
SET physical_state = 'FREE',
    owner_kind = NULL,
    owner_id = NULL,
    worker_id = NULL,
    lease_until = NULL,
    release_evidence = JSON_OBJECT(
        'kind', 'TEST_FIXTURE_REMOVAL',
        'commandId', '1306740509976432640',
        'queryState', 'NOT_SENT',
        'maintenanceDate', '2026-10-14'
    ),
    object_version = object_version + 1,
    updated_at = CURRENT_TIMESTAMP(3)
WHERE owner_kind = 'WORKFLOW'
  AND owner_id = 1306736114282926080
  AND resource_key IN (
      'BENCH_CONTROLLER:900000000000001001',
      'PUMP:1301187534977634304:PUMP1'
  )
  AND physical_state = 'STOPPING';

UPDATE res_culture
SET del_flag = '2',
    deleted_at = CURRENT_TIMESTAMP,
    deleted_by_user_id = 1,
    modifier_user_id = 1,
    object_version = object_version + 1,
    update_by = 'maintenance-20261014',
    update_time = CURRENT_TIMESTAMP
WHERE culture_id = 900000000000002003
  AND batch_id = 900000000000002002
  AND del_flag = '0';

UPDATE res_batch b
SET b.del_flag = '2',
    b.deleted_at = CURRENT_TIMESTAMP,
    b.deleted_by_user_id = 1,
    b.modifier_user_id = 1,
    b.object_version = b.object_version + 1,
    b.update_by = 'maintenance-20261014',
    b.update_time = CURRENT_TIMESTAMP
WHERE b.batch_id = 900000000000002002
  AND b.project_id = 900000000000002001
  AND b.del_flag = '0'
  AND NOT EXISTS (
      SELECT 1
      FROM res_culture c
      WHERE c.batch_id = b.batch_id
        AND c.del_flag <> '2'
  );

UPDATE res_project p
SET p.del_flag = '2',
    p.deleted_at = CURRENT_TIMESTAMP,
    p.deleted_by_user_id = 1,
    p.modifier_user_id = 1,
    p.object_version = p.object_version + 1,
    p.update_by = 'maintenance-20261014',
    p.update_time = CURRENT_TIMESTAMP
WHERE p.project_id = 900000000000002001
  AND p.del_flag = '0'
  AND NOT EXISTS (
      SELECT 1
      FROM res_batch b
      WHERE b.project_id = p.project_id
        AND b.del_flag <> '2'
  );

-- 预期：command=FAILED；active_workflows=0；active_guards=0；三个墓碑均为2。
SELECT state, device_command_id, invoked_at, attempt_count, result_evidence
FROM run_command
WHERE command_id = 1306740509976432640;

SELECT
    SUM(state NOT IN ('COMPLETED', 'CANCELLED')) AS active_workflows,
    SUM(state = 'CANCELLED') AS cancelled_workflows
FROM run_workflow_instance
WHERE culture_id = 900000000000002003;

SELECT COUNT(*) AS active_guards
FROM run_resource_guard
WHERE owner_kind = 'WORKFLOW'
  AND owner_id IN (
      1306736114282926080,
      1307049462694285312,
      1307054580735021056
  )
  AND physical_state <> 'FREE';

SELECT
    (SELECT del_flag FROM res_project WHERE project_id = 900000000000002001) AS project_del_flag,
    (SELECT del_flag FROM res_batch WHERE batch_id = 900000000000002002) AS batch_del_flag,
    (SELECT del_flag FROM res_culture WHERE culture_id = 900000000000002003) AS culture_del_flag;

COMMIT;
