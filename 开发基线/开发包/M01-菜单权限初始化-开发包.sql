-- =====================================================================================
-- INT-02｜M01 菜单/权限初始化开发包（SUPPORTING 支持型附件，2026-10-07；批次 D 于 2026-10-09 追加 M04 36 码；2026-10-14 追加 M03 培养 7 码；2026-10-26 追加 M06 审批页及既有 5 码）
--
-- 性质与边界（总控裁决 + 物理接口与骨架字段设计.md §5 门禁 #2 + 58-M09告警权限菜单种子前置清单 §1）：
--   1) 本包是部署核准时【手工执行】的开发包，不属于 01/02/03 fresh 安装链；
--      02-基础数据初始化.sql 保持对 sys_menu 零 INSERT（03-核验会把安装链外的 sys_menu 行判
--      unexpected_initial_data，实锚点：03-初始化结果核验.sql:86），来源清单.json seedTables 不含 sys_menu
--      （仅 apr_scene / sys_management_revision / sys_config）——故本包不进自动链、不改 01/02/03。
--      执行顺序必须是 01 → 02 → 03（此时 sys_menu 必须为空）→ 本包 → 本包各只读核验；
--      若在 03 之前执行本包，03 会把本包全部行报成 unexpected_initial_data，属核验口径冲突而非数据错误。
--      批次 D 追加的 M04 36 码沿用同一边界，不新增第二条安装路径。
--   2) 只写 sys_menu；绝不写 sys_role_menu，不自动给任何角色授权（不猜角色、不猜授权范围）；
--      非超管的可见性与可用性由部署期角色绑定与前端 v-hasPermi 决定。
--   3) 判权事实源说明：HTTP 注解轴（@RequiresPermissions，超管通配豁免）与 Port 判权轴
--      （M01FunctionPermissionAdapter：码不在 sys_menu 现行 perms 全集 → INPUT_INVALID 400，
--      登记校验先于 admin 豁免，见 SysMenuMapper.selectMenuPermsByUserId，仅滤 status 不滤 visible）
--      共用本表；本包落码后两轴的"码未登记 400"前置即解除。
--   4) 覆盖范围 = 总控裁决 A 类 24 个权限码 + M07-032/033 执行器归属 2 个权限码
--      + 批次 D 的 M04 工艺模板 36 个功能码（⑥ 段，六类 kindCode × 六动作，源码 functionCode 动态推导）；
--      + M03 培养管理页面实际消费的 7 个细分操作权限码（⑦ 段）；
--      + M06 通用审批操作页与既有 list/query/review/approve/withdraw 5 码（⑪ 段）；
--      M02 四码为 225 查询 + 226 的 SAVE_DRAFT/VERIFY/REVOKE 三动作（INT-56 批B-3 写口已 wired，
--      2026-10-09 总控批准随批补齐）；M02-227、M07-032~035 四码、M04-016、M05 复合权限台账口径均不在本包（见交付报告 §未处理项）。
--      M04 只登记 process:{kindCode}:{action} 36 码；process:workflow:list|query|edit 与 process:approval:*
--      不属该 36 码集合（§9.1 另轴）；M06 审批 5 码此次单独登记，不借此开放政策配置或 Q39 启用。
--
-- 幂等与 ID 策略：
--   - 幂等键：目录/菜单行 = menu_i18n_key；按钮行 = perms。全部 INSERT 带 NOT EXISTS 守卫，可重复执行。
--   - 菜单 ID 不猜固定值：每行取执行时刻 sys_menu 当前 MAX(menu_id)+1（空库=1 起步，已装库顺延）；
--     语句顺序执行保证父子引用成立；父 ID 一律按 menu_i18n_key 现查，不跨语句记忆。
--   - 菜单树权威：本包为已接入页面登记目录与 C 行；M06 本次增加可见审批目录和审批操作页，
--     完整业务菜单树属菜单设计批，锚点行可在该批整体调整（i18n key 是迁移键）。
--   - i18n 命名空间：目录/菜单 futurefab.menu.*，按钮 futurefab.permission.*；前端 sdk-language
--     尚无对应 key，落 key 属前端批（见交付报告）。
--
-- 执行方式：整包一个事务，任一语句失败即整体回滚（与 02 同风格）。
-- 执行警示：本开发包必须【单会话串行执行】，禁止并行执行，禁止使用 --force；
--   若并发执行，各会话取到的 MAX(menu_id)+1 占位 ID 会撞 sys_menu 主键并整事务 fail-closed 回滚，
--   不得忽略错误继续执行；撞键后须排查会话后重新整包执行。
-- =====================================================================================

SET NAMES utf8mb4;
SET time_zone = '+00:00';
START TRANSACTION;

-- =====================================================================================
-- ① 模块锚点目录（menu_type='M'，parent_id=0）
--    三个锚点目录一律 visible='1'（隐藏）：M02/M07 无前端页面，M05 页面虽在但菜单树未设计；
--    visible 不进入 perms 字典（selectMenuPermsByUserId 仅滤 status），隐藏不影响码登记。
-- =====================================================================================

-- M02 锚点目录：实验室与资源管理（M02-225 所在模块；完整树待菜单设计批）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '实验室与资源管理', 'futurefab.menu.m02.root', 0, 20, 'lab-resource', NULL, NULL, NULL, 1, 0, 'M', '1', '0', NULL, NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'INT-02 锚点目录（隐藏）：M02-225 工程资料查询权限的挂载父级；完整业务菜单树待菜单设计批', '0', ''
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.menu_i18n_key = 'futurefab.menu.m02.root' AND x.del_flag = '0');

-- M05 锚点目录：检测与签批（detect-result-correction / sign-workbench 前端页面所在域）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '检测与签批', 'futurefab.menu.m05.root', 0, 50, 'detection', NULL, NULL, NULL, 1, 0, 'M', '1', '0', NULL, NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'INT-02 锚点目录（隐藏）：M05 受控更正/签批工作台按钮权限的挂载父级；完整业务菜单树待菜单设计批', '0', ''
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.menu_i18n_key = 'futurefab.menu.m05.root' AND x.del_flag = '0');

-- M07 目录：运行管理（run/task/index 已接任务异常处理页；其余未有页面的功能行继续隐藏）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '运行管理', 'futurefab.menu.m07.root', 0, 70, 'run', NULL, NULL, NULL, 1, 0, 'M', '0', '0', NULL, NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M07 运行管理目录；任务异常处理页已接入，未接页面仍由各子行隐藏', '0', ''
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.menu_i18n_key = 'futurefab.menu.m07.root' AND x.del_flag = '0');

-- 兼容已执行旧版开发包的环境：仅按稳定 i18n 键升级可见性与说明。
UPDATE sys_menu
SET visible = '0', update_by = 'INSTALL', update_time = UTC_TIMESTAMP(),
    remark = 'M07 运行管理目录；任务异常处理页已接入，未接页面仍由各子行隐藏'
WHERE menu_i18n_key = 'futurefab.menu.m07.root' AND menu_type = 'M' AND del_flag = '0';

-- =====================================================================================
-- ② M05 菜单行（menu_type='C'）：两个前端页面真实存在（app-smp-data/src/views/）
-- =====================================================================================

-- C：受控更正（M05-003/004 已 wired AND 组合注解；M05-048 已登记操作码、接口仍 501）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '受控更正', 'futurefab.menu.m05.correction',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m05.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       1, 'result-correction', 'detect-result-correction/index', NULL, NULL, 1, 0, 'C', '1', '0', NULL, NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'INT-02：前端页面 app-smp-data detect-result-correction/index.vue 真实存在；component 为声明性锚点（前端走本地路由）', '0', '/detect/result-corrections'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.menu_i18n_key = 'futurefab.menu.m05.correction' AND x.del_flag = '0');

-- C：签批工作台（M05-039~044 已 wired）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '签批工作台', 'futurefab.menu.m05.signworkbench',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m05.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       2, 'sign-workbench', 'sign-workbench/index', NULL, NULL, 1, 0, 'C', '1', '0', NULL, NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'INT-02：前端页面 app-smp-data sign-workbench/index.vue 真实存在；component 为声明性锚点（前端走本地路由）', '0', '/detect/sign-console'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.menu_i18n_key = 'futurefab.menu.m05.signworkbench' AND x.del_flag = '0');

-- =====================================================================================
-- ③ M02 按钮权限行（menu_type='F'，4 码）
-- =====================================================================================

-- F｜M02-225｜lab:engineering:query：工程资料最小读（已接线读口 GET /system/lab/engineering/profiles；
-- Controller @RequiresPermissions("lab:engineering:query") 实测 LabEngineeringProfileController:41）。
-- 开放（读口 CONTRACT_TESTED 已接线）；前端工程资料页面未建，入口待工程资料前端批。
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '工程资料查询', 'futurefab.permission.m02.engineering.query',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m02.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       1, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'lab:engineering:query', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'INT-02｜M02-225 已接线读口，开放（超管/被授权角色可判权）；前端页面未建，无死入口', '0', '/system/lab/engineering/profiles'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'lab:engineering:query' AND x.menu_type = 'F' AND x.del_flag = '0');

-- F｜M02-226｜lab:engineering:edit：工程资料草稿保存（已接线守卫写 POST /system/lab/engineering/profiles；
-- Controller @RequiresPermissions({edit, verify, revoke}, logical=OR) 粗门禁实测 LabEngineeringProfileController:65-66，
-- "SAVE_DRAFT 要 edit、VERIFY 要 verify、REVOKE 要 revoke"的按动作精确判权由应用服务实时复核（裁决清单 E1/G-C）。
-- 开放（写口已 wired，批B-3）；三码缺一即普通角色无法调用 226，M04 补液方案保存所需工程资料将无法核准。
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '工程资料草稿保存', 'futurefab.permission.m02.engineering.edit',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m02.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       2, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'lab:engineering:edit', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'INT-56批B-3｜M02-226 SAVE_DRAFT 动作判权码；Controller 层为三码 OR 粗门禁，动作级判定在应用服务', '0', '/system/lab/engineering/profiles'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'lab:engineering:edit' AND x.menu_type = 'F' AND x.del_flag = '0');

-- F｜M02-226｜lab:engineering:verify：工程资料核准（补液方案/培养参数等工程段固定的前置事实源：
-- 只有 VERIFIED 版本可被 resolveEngineering 以 COMPLETE 返回，缺该码则 M04 模板保存必然 400 CONTENT_INVALID）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '工程资料核准', 'futurefab.permission.m02.engineering.verify',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m02.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       3, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'lab:engineering:verify', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'INT-56批B-3｜M02-226 VERIFY 动作判权码；M04 工程段固定依赖已核准版本，缺此码补液方案无法保存', '0', '/system/lab/engineering/profiles'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'lab:engineering:verify' AND x.menu_type = 'F' AND x.del_flag = '0');

-- F｜M02-226｜lab:engineering:revoke：工程资料撤销（REVOKED 为终态历史，撤销后该身份不可再用于新的保存/生效/执行）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '工程资料撤销', 'futurefab.permission.m02.engineering.revoke',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m02.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       4, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'lab:engineering:revoke', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'INT-56批B-3｜M02-226 REVOKE 动作判权码；撤销无原因落库列（裁决 D-4 口径），reason 只进幂等载荷摘要', '0', '/system/lab/engineering/profiles'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'lab:engineering:revoke' AND x.menu_type = 'F' AND x.del_flag = '0');

-- =====================================================================================
-- ④ M05 按钮权限行（menu_type='F'，4 码，全部开放——总控裁决 12：接口已 wired）
-- =====================================================================================

-- F｜M05-003/048｜detect:correction:submit：受控更正提交（M05-003 决定口已 wired，注解
-- {detect:correction:submit, detect:sign:sign} logical=AND 实测 DetResultCorrectionController:51；
-- M05-048 申请提交口已登记操作码 INT-01、接口仍 501——码开放，按钮由前端按页面实际能力挂载）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '受控更正提交', 'futurefab.permission.m05.correction.submit',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m05.correction' AND p.menu_type = 'C' AND p.del_flag = '0'),
       1, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'detect:correction:submit', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'INT-02｜M05-003 已 wired（AND detect:sign:sign）；M05-048 操作码已登记接口仍 501', '0', '/detect/result-corrections'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'detect:correction:submit' AND x.menu_type = 'F' AND x.del_flag = '0');

-- F｜M05-003｜detect:correction:review：更正决定复核（wired，注解 {review, sign:audit} AND，:59/:73）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '受控更正复核', 'futurefab.permission.m05.correction.review',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m05.correction' AND p.menu_type = 'C' AND p.del_flag = '0'),
       2, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'detect:correction:review', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'INT-02｜M05-003 决定口已 wired（AND detect:sign:audit）', '0', '/detect/result-corrections/{id}/decisions'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'detect:correction:review' AND x.menu_type = 'F' AND x.del_flag = '0');

-- F｜M05-039｜detect:sign:sign：签批台批量签名（wired；与 correction:submit 组成 AND 组合的另一半）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '签批台批量签名', 'futurefab.permission.m05.sign.sign',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m05.signworkbench' AND p.menu_type = 'C' AND p.del_flag = '0'),
       1, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'detect:sign:sign', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'INT-02｜M05-039 签名口已 wired', '0', '/detect/sign-console/sign'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'detect:sign:sign' AND x.menu_type = 'F' AND x.del_flag = '0');

-- F｜M05-040｜detect:sign:audit：签批台批量审核（wired；与 correction:review 组成 AND 组合的另一半）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '签批台批量审核', 'futurefab.permission.m05.sign.audit',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m05.signworkbench' AND p.menu_type = 'C' AND p.del_flag = '0'),
       2, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'detect:sign:audit', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'INT-02｜M05-040 审核口已 wired', '0', '/detect/sign-console/audit'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'detect:sign:audit' AND x.menu_type = 'F' AND x.del_flag = '0');

-- =====================================================================================
-- ⑤ M07 按钮权限行（menu_type='F'，16 码；已接页面的任务按钮挂任务页，其余挂 M07 隐藏锚点目录）
--    api_path 全部取自 controller/run/* 实测注解映射；运行依赖未到货不等于接口仍为 501。
-- =====================================================================================

-- F｜M07-005｜run:task:add：创建任务（POST /run/tasks，后端已接线）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '补液任务新增', 'futurefab.permission.m07.task.add',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m07.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       1, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'run:task:add', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M07-005 后端创建/未知结果恢复链已接线；HTTP/浏览器/实库另验', '0', '/run/tasks'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'run:task:add' AND x.menu_type = 'F' AND x.del_flag = '0');

-- F｜M07-006｜run:task:edit：任务变更（POST /run/tasks/{id}/changes，后端已接线）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '补液任务变更', 'futurefab.permission.m07.task.edit',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m07.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       2, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'run:task:edit', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M07-006 后端候选/直接变更链已接线；HTTP/浏览器/实库另验', '0', '/run/tasks/{id}/changes'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'run:task:edit' AND x.menu_type = 'F' AND x.del_flag = '0');

-- F｜M07-007｜run:task:cancel：任务取消请求（POST /run/tasks/{id}/cancel-requests，后端已接线）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '补液任务取消', 'futurefab.permission.m07.task.cancel',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m07.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       3, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'run:task:cancel', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M07-007 后端候选/直接取消链已接线；HTTP/浏览器/实库另验', '0', '/run/tasks/{id}/cancel-requests'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'run:task:cancel' AND x.menu_type = 'F' AND x.del_flag = '0');

-- F｜M07-008｜run:task:pause：任务暂停（POST /run/tasks/{id}/pause，后端意图链已接线）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '补液任务暂停', 'futurefab.permission.m07.task.pause',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m07.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       4, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'run:task:pause', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M07-008 暂停意图链已接线；真实设备适配与安全暂停闭环仍受部署/外部能力阻塞', '0', '/run/tasks/{id}/pause'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'run:task:pause' AND x.menu_type = 'F' AND x.del_flag = '0');

-- F｜M07-009｜run:task:resume：任务恢复（POST /run/tasks/{id}/resume，后端意图链已接线）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '补液任务恢复', 'futurefab.permission.m07.task.resume',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m07.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       5, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'run:task:resume', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M07-009 恢复分段/命令意图链已接线；真实设备适配仍受部署/外部能力阻塞', '0', '/run/tasks/{id}/resume'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'run:task:resume' AND x.menu_type = 'F' AND x.del_flag = '0');

-- F｜M07-010｜run:task:handle：任务异常处理（POST /run/tasks/{id}/exception-handling，前后端已接线）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '补液任务异常处理', 'futurefab.permission.m07.task.handle',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m07.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       6, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'run:task:handle', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M07-010 异常处理前后端已接线；HTTP/浏览器/实库/设备另验', '0', '/run/tasks/{id}/exception-handling'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'run:task:handle' AND x.menu_type = 'F' AND x.del_flag = '0');

-- C｜run:task:list：运行任务/异常处理页（GET /run/tasks，component 对应 app-smp-lab 路由）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '运行任务', 'futurefab.menu.m07.task',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m07.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       1, 'run-tasks', 'run/task/index', NULL, NULL, 1, 0, 'C', '0', '0', 'run:task:list', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M07 运行任务页；ERROR 任务通过 HANDLE_EXCEPTION 动作投影开放异常处理', '0', '/run/tasks'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE (x.menu_i18n_key = 'futurefab.menu.m07.task' OR x.perms = 'run:task:list') AND x.del_flag = '0');

-- 兼容旧包中 run:task:list 仅为 F 行的环境：原位转为页面菜单，保留 menu_id/角色授权关系。
UPDATE sys_menu
SET menu_name = '运行任务', menu_i18n_key = 'futurefab.menu.m07.task',
    parent_id = (SELECT p.menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_i18n_key = 'futurefab.menu.m07.root' AND menu_type = 'M' AND del_flag = '0' LIMIT 1) p),
    order_num = 1, path = 'run-tasks', component = 'run/task/index', menu_type = 'C', visible = '0',
    update_by = 'INSTALL', update_time = UTC_TIMESTAMP(),
    remark = 'M07 运行任务页；ERROR 任务通过 HANDLE_EXCEPTION 动作投影开放异常处理'
WHERE perms = 'run:task:list' AND del_flag = '0';

-- F｜run:task:query：任务详情（GET /run/tasks/{id}，读口已接线）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '补液任务详情', 'futurefab.permission.m07.task.query',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m07.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       8, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'run:task:query', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'INT-02｜任务详情读口已接线（GET /run/tasks/{id}）', '0', '/run/tasks/{id}'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'run:task:query' AND x.menu_type = 'F' AND x.del_flag = '0');

-- 任务页按钮挂到页面菜单；只改动 run:task:* 功能行，不展开其他 M07 入口。
UPDATE sys_menu
SET parent_id = (SELECT p.menu_id FROM (SELECT menu_id FROM sys_menu WHERE menu_i18n_key = 'futurefab.menu.m07.task' AND menu_type = 'C' AND del_flag = '0' LIMIT 1) p),
    update_by = 'INSTALL', update_time = UTC_TIMESTAMP()
WHERE menu_type = 'F' AND perms IN ('run:task:add','run:task:edit','run:task:cancel','run:task:pause','run:task:resume','run:task:handle','run:task:query') AND del_flag = '0';

-- C｜M07-032｜run:executorAssignment:list：执行器归属列表（GET /run/executor-assignments）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '执行器归属', 'futurefab.menu.m07.executorAssignment',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m07.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       2, 'executor-assignments', 'run/executor-assignment/index', NULL, NULL, 1, 0, 'C', '0', '0', 'run:executorAssignment:list', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M07-032 执行器归属只读页已接线；HTTP/浏览器/实库另验', '0', '/run/executor-assignments'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE (x.menu_i18n_key = 'futurefab.menu.m07.executorAssignment' OR x.perms = 'run:executorAssignment:list') AND x.del_flag = '0');

-- F｜M07-033｜run:executorAssignment:transfer：执行器归属移交（POST /run/executor-assignments/{resourceKey}/transfers）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '执行器归属移交', 'futurefab.permission.m07.executorAssignment.transfer',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m07.executorAssignment' AND p.menu_type = 'C' AND p.del_flag = '0'),
       1, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'run:executorAssignment:transfer', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M07-033 前后端守卫写与本地 CAS 已接线；M02 权威资格端口缺生产实现时失败关闭', '0', '/run/executor-assignments/{resourceKey}/transfers'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'run:executorAssignment:transfer' AND x.menu_type = 'F' AND x.del_flag = '0');

-- F｜M07-022｜run:workflow:query：工作流候选（GET /run/workflows/candidates，已接线）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '工作流候选查询', 'futurefab.permission.m07.workflow.query',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m07.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       9, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'run:workflow:query', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M07-022 W03 候选只读预检已接线；HTTP/浏览器/实库另验', '0', '/run/workflows/candidates'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'run:workflow:query' AND x.menu_type = 'F' AND x.del_flag = '0');

-- F｜M07-023｜run:workflow:start：发起工作流（POST /run/workflows，已接线）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '工作流发起', 'futurefab.permission.m07.workflow.start',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m07.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       10, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'run:workflow:start', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M07-023 受管启动写已接线；HTTP/浏览器/实库另验', '0', '/run/workflows'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'run:workflow:start' AND x.menu_type = 'F' AND x.del_flag = '0');

-- F｜M07-025/026/027｜run:workflow:operate：工作流步骤/操作/取消（本地事务链已接线）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '工作流操作', 'futurefab.permission.m07.workflow.operate',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m07.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       11, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'run:workflow:operate', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M07-025/026/027 工作流步骤、命令意图与安全取消本地事务链已接线；真实设备/HTTP/浏览器另验', '0', '/run/workflows/{id}/steps/{stepId}'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'run:workflow:operate' AND x.menu_type = 'F' AND x.del_flag = '0');

-- F｜M07-028｜run:service:restart：服务重启（POST /run/services/{id}/restart，入口已接且依赖缺失时失败关闭）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '服务重启', 'futurefab.permission.m07.service.restart',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m07.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       12, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'run:service:restart', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M07-028 请求校验入口已接；重启协议、服务身份绑定与外部执行通道未交付时返回依赖不可用', '0', '/run/services/{id}/restart'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'run:service:restart' AND x.menu_type = 'F' AND x.del_flag = '0');

-- F｜M07-015｜run:balance:query：培养称量平衡（GET /run/cultures/{id}/balance，接口 501）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '培养称量平衡查询', 'futurefab.permission.m07.balance.query',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m07.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       13, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'run:balance:query', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'INT-02｜M07-015 已注解未接线（501），仅登记不开放', '0', '/run/cultures/{id}/balance'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'run:balance:query' AND x.menu_type = 'F' AND x.del_flag = '0');

-- F｜M07-018｜run:glucose:add：残糖手工候选登记（POST /run/manual-results，已接线）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '残糖手工候选登记', 'futurefab.permission.m07.glucose.add',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m07.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       14, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'run:glucose:add', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'INT-02｜M07-018 已接线（守卫写 M07_018）；run 前端页面未建，目录隐藏', '0', '/run/manual-results'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'run:glucose:add' AND x.menu_type = 'F' AND x.del_flag = '0');

-- F｜M07-019/020｜run:glucose:confirm：残糖确认发起/取消（POST /run/confirmations，已接线）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '残糖确认', 'futurefab.permission.m07.glucose.confirm',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m07.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       15, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'run:glucose:confirm', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'INT-02｜M07-019/020 已接线（守卫写 M07_019/020）；run 前端页面未建，目录隐藏', '0', '/run/confirmations'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'run:glucose:confirm' AND x.menu_type = 'F' AND x.del_flag = '0');

-- F｜run:glucose:query：残糖确认详情（GET /run/confirmations/{id}，读口已接线）
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '残糖确认查询', 'futurefab.permission.m07.glucose.query',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m07.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       16, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'run:glucose:query', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'INT-02｜确认详情读口已接线（GET /run/confirmations/{id}）', '0', '/run/confirmations/{id}'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'run:glucose:query' AND x.menu_type = 'F' AND x.del_flag = '0');

-- =====================================================================================
-- ⑥ M04 工艺模板 36 个功能码（批次 D·W1，2026-10-09）
--    集合来源（逐条源码取证，不凭注释）：ProcessTemplateApplicationApplicationServiceImpl
--    functionCode(kind, action) = "process:" + kindCode(kind) + ":" + action；
--    kindCode 六值 switch（config/perfusion/sampling/autoControl/feeding/pumpSpeed，:222-233）；
--    action 六值在 requireFunction 调用面逐字出现：list(:601) query(:367/:379/:406/:445/:811/:827/:1965)
--    add(:354/:431/:657/:986/:1966) edit(:442/:668/:1032，另 editingAction(:737/:894/:950) 动态取 add|edit)
--    changeStatus(:1073) remove(:1102)。6×6=36，与 详细设计.md §9.1 取值表逐字一致。
--    判权轴说明：M04 功能码只走 M01 功能位判权（Controller 零 @RequiresPermissions；写死任一码
--    或取六类并集都等于放宽权限，明令禁止）。未登记码在 M01FunctionPermissionAdapter
--    verifyCodeRegistered(:137) 失败关闭为 400 INPUT_INVALID，且该检查在超管短路(:138) 之前，
--    故本段落库前 M04 读写口对任何账号都走不通——这正是 §9.1「不能假设数据库已有这些码」。
--    开放口径：feeding 六码挂在真实存在的前端页面 C 行下；其余五类 30 码仅登记不开放（同 M07 法，
--    无页面即无 501 按钮）。全部 36 码都不写 sys_role_menu，不自动给任何角色授权。
--    冲突面登记：sql/20260929_process_feeding_menu.sql（旧菜单式、固定 menu_id 12900000000000000xx、
--    空 i18n_key、父级指向旧库 menu_id）已种过 process:feeding:list|add|edit|changeStatus|remove 五码，
--    缺 :query。该脚本不属 01/02/03 安装链；同库执行时本段按 perms 幂等跳过既有行（不产生重复行），
--    并由核验 8 单独暴露该面，须按交付报告收敛为单一种子源，不得叠第三套。
-- =====================================================================================

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '工艺模板管理', 'futurefab.menu.m04.root',
       0,
       40, 'process-template', NULL, NULL, NULL, 1, 0, 'M', '1', '0', NULL, NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D 锚点目录（隐藏）：M04 六类模板 36 个功能码的挂载父级；完整业务菜单树待菜单设计批', '0', NULL
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_i18n_key = 'futurefab.menu.m04.root' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '补液方案模板', 'futurefab.menu.m04.feeding.template',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       1, 'feeding-template', 'process/feeding/index', NULL, NULL, 1, 0, 'C', '1', '0', NULL, NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D：前端页面 app-smp-settings views/feeding-template-management/index.vue 真实存在（本地路由，component 声明沿 04 模块 UI 登记）；visible 不进入 perms 字典，隐藏不影响判权', '0', '/process/templates/list'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_i18n_key = 'futurefab.menu.m04.feeding.template' AND del_flag = '0');

-- ---- 配置模板（TemplateKind.CONFIG）：process:config:* ----
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '配置模板列表', 'futurefab.permission.m04.config.list',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       1, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:config:list', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝GET /process/templates/list（定位011）', '0', '/process/templates/list'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:config:list' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '配置模板查询', 'futurefab.permission.m04.config.query',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       2, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:config:query', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝GET /process/templates/{templateId} 及版本/候选/下拉读口（定位002~005、未编号泵数泵速口）', '0', '/process/templates/{templateId}'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:config:query' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '配置模板新增', 'futurefab.permission.m04.config.add',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       3, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:config:add', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝POST /process/templates、/process/templates/{id}/copies（定位006）', '0', '/process/templates'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:config:add' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '配置模板修改', 'futurefab.permission.m04.config.edit',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       4, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:config:edit', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝PUT /process/templates/{templateId} 与带 templateId 的事实读口（定位007）', '0', '/process/templates/{templateId}'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:config:edit' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '配置模板启停', 'futurefab.permission.m04.config.changeStatus',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       5, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:config:changeStatus', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝PUT /process/templates/{templateId}/status（定位009）', '0', '/process/templates/{templateId}/status'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:config:changeStatus' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '配置模板删除', 'futurefab.permission.m04.config.remove',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       6, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:config:remove', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝POST /process/templates/{templateId}/delete（定位010）', '0', '/process/templates/{templateId}/delete'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:config:remove' AND menu_type = 'F' AND del_flag = '0');

-- ---- 灌注培养基方案（TemplateKind.PERFUSION）：process:perfusion:* ----
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '灌注培养基方案列表', 'futurefab.permission.m04.perfusion.list',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       1, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:perfusion:list', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝GET /process/templates/list（定位011）', '0', '/process/templates/list'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:perfusion:list' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '灌注培养基方案查询', 'futurefab.permission.m04.perfusion.query',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       2, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:perfusion:query', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝GET /process/templates/{templateId} 及版本/候选/下拉读口（定位002~005、未编号泵数泵速口）', '0', '/process/templates/{templateId}'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:perfusion:query' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '灌注培养基方案新增', 'futurefab.permission.m04.perfusion.add',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       3, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:perfusion:add', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝POST /process/templates、/process/templates/{id}/copies（定位006）', '0', '/process/templates'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:perfusion:add' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '灌注培养基方案修改', 'futurefab.permission.m04.perfusion.edit',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       4, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:perfusion:edit', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝PUT /process/templates/{templateId} 与带 templateId 的事实读口（定位007）', '0', '/process/templates/{templateId}'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:perfusion:edit' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '灌注培养基方案启停', 'futurefab.permission.m04.perfusion.changeStatus',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       5, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:perfusion:changeStatus', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝PUT /process/templates/{templateId}/status（定位009）', '0', '/process/templates/{templateId}/status'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:perfusion:changeStatus' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '灌注培养基方案删除', 'futurefab.permission.m04.perfusion.remove',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       6, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:perfusion:remove', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝POST /process/templates/{templateId}/delete（定位010）', '0', '/process/templates/{templateId}/delete'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:perfusion:remove' AND menu_type = 'F' AND del_flag = '0');

-- ---- 取样测样方案（TemplateKind.SAMPLING）：process:sampling:* ----
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '取样测样方案列表', 'futurefab.permission.m04.sampling.list',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       1, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:sampling:list', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝GET /process/templates/list（定位011）', '0', '/process/templates/list'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:sampling:list' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '取样测样方案查询', 'futurefab.permission.m04.sampling.query',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       2, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:sampling:query', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝GET /process/templates/{templateId} 及版本/候选/下拉读口（定位002~005、未编号泵数泵速口）', '0', '/process/templates/{templateId}'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:sampling:query' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '取样测样方案新增', 'futurefab.permission.m04.sampling.add',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       3, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:sampling:add', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝POST /process/templates、/process/templates/{id}/copies（定位006）', '0', '/process/templates'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:sampling:add' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '取样测样方案修改', 'futurefab.permission.m04.sampling.edit',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       4, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:sampling:edit', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝PUT /process/templates/{templateId} 与带 templateId 的事实读口（定位007）', '0', '/process/templates/{templateId}'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:sampling:edit' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '取样测样方案启停', 'futurefab.permission.m04.sampling.changeStatus',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       5, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:sampling:changeStatus', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝PUT /process/templates/{templateId}/status（定位009）', '0', '/process/templates/{templateId}/status'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:sampling:changeStatus' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '取样测样方案删除', 'futurefab.permission.m04.sampling.remove',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       6, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:sampling:remove', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝POST /process/templates/{templateId}/delete（定位010）', '0', '/process/templates/{templateId}/delete'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:sampling:remove' AND menu_type = 'F' AND del_flag = '0');

-- ---- 自动控制方案（TemplateKind.AUTO_CONTROL）：process:autoControl:* ----
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '自动控制方案列表', 'futurefab.permission.m04.autoControl.list',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       1, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:autoControl:list', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝GET /process/templates/list（定位011）', '0', '/process/templates/list'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:autoControl:list' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '自动控制方案查询', 'futurefab.permission.m04.autoControl.query',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       2, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:autoControl:query', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝GET /process/templates/{templateId} 及版本/候选/下拉读口（定位002~005、未编号泵数泵速口）', '0', '/process/templates/{templateId}'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:autoControl:query' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '自动控制方案新增', 'futurefab.permission.m04.autoControl.add',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       3, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:autoControl:add', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝POST /process/templates、/process/templates/{id}/copies（定位006）', '0', '/process/templates'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:autoControl:add' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '自动控制方案修改', 'futurefab.permission.m04.autoControl.edit',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       4, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:autoControl:edit', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝PUT /process/templates/{templateId} 与带 templateId 的事实读口（定位007）', '0', '/process/templates/{templateId}'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:autoControl:edit' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '自动控制方案启停', 'futurefab.permission.m04.autoControl.changeStatus',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       5, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:autoControl:changeStatus', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝PUT /process/templates/{templateId}/status（定位009）', '0', '/process/templates/{templateId}/status'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:autoControl:changeStatus' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '自动控制方案删除', 'futurefab.permission.m04.autoControl.remove',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       6, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:autoControl:remove', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝POST /process/templates/{templateId}/delete（定位010）', '0', '/process/templates/{templateId}/delete'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:autoControl:remove' AND menu_type = 'F' AND del_flag = '0');

-- ---- 补液方案（TemplateKind.FEEDING）：process:feeding:* ----
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '补液方案列表', 'futurefab.permission.m04.feeding.list',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.feeding.template' AND p.menu_type = 'C' AND p.del_flag = '0'),
       1, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:feeding:list', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜feeding 有前端页面，按钮入口由页面按能力挂载（v-hasPermi/session.has）；判权点＝GET /process/templates/list（定位011）', '0', '/process/templates/list'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:feeding:list' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '补液方案查询', 'futurefab.permission.m04.feeding.query',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.feeding.template' AND p.menu_type = 'C' AND p.del_flag = '0'),
       2, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:feeding:query', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜feeding 有前端页面，按钮入口由页面按能力挂载（v-hasPermi/session.has）；判权点＝GET /process/templates/{templateId} 及版本/候选/下拉读口（定位002~005、未编号泵数泵速口）', '0', '/process/templates/{templateId}'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:feeding:query' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '补液方案新增', 'futurefab.permission.m04.feeding.add',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.feeding.template' AND p.menu_type = 'C' AND p.del_flag = '0'),
       3, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:feeding:add', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜feeding 有前端页面，按钮入口由页面按能力挂载（v-hasPermi/session.has）；判权点＝POST /process/templates、/process/templates/{id}/copies（定位006）', '0', '/process/templates'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:feeding:add' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '补液方案修改', 'futurefab.permission.m04.feeding.edit',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.feeding.template' AND p.menu_type = 'C' AND p.del_flag = '0'),
       4, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:feeding:edit', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜feeding 有前端页面，按钮入口由页面按能力挂载（v-hasPermi/session.has）；判权点＝PUT /process/templates/{templateId} 与带 templateId 的事实读口（定位007）', '0', '/process/templates/{templateId}'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:feeding:edit' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '补液方案启停', 'futurefab.permission.m04.feeding.changeStatus',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.feeding.template' AND p.menu_type = 'C' AND p.del_flag = '0'),
       5, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:feeding:changeStatus', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜feeding 有前端页面，按钮入口由页面按能力挂载（v-hasPermi/session.has）；判权点＝PUT /process/templates/{templateId}/status（定位009）', '0', '/process/templates/{templateId}/status'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:feeding:changeStatus' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '补液方案删除', 'futurefab.permission.m04.feeding.remove',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.feeding.template' AND p.menu_type = 'C' AND p.del_flag = '0'),
       6, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:feeding:remove', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜feeding 有前端页面，按钮入口由页面按能力挂载（v-hasPermi/session.has）；判权点＝POST /process/templates/{templateId}/delete（定位010）', '0', '/process/templates/{templateId}/delete'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:feeding:remove' AND menu_type = 'F' AND del_flag = '0');

-- ---- 泵速策略（模板）（TemplateKind.PUMP_SPEED）：process:pumpSpeed:* ----
INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '泵速策略（模板）列表', 'futurefab.permission.m04.pumpSpeed.list',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       1, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:pumpSpeed:list', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝GET /process/templates/list（定位011）', '0', '/process/templates/list'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:pumpSpeed:list' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '泵速策略（模板）查询', 'futurefab.permission.m04.pumpSpeed.query',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       2, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:pumpSpeed:query', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝GET /process/templates/{templateId} 及版本/候选/下拉读口（定位002~005、未编号泵数泵速口）', '0', '/process/templates/{templateId}'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:pumpSpeed:query' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '泵速策略（模板）新增', 'futurefab.permission.m04.pumpSpeed.add',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       3, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:pumpSpeed:add', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝POST /process/templates、/process/templates/{id}/copies（定位006）', '0', '/process/templates'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:pumpSpeed:add' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '泵速策略（模板）修改', 'futurefab.permission.m04.pumpSpeed.edit',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       4, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:pumpSpeed:edit', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝PUT /process/templates/{templateId} 与带 templateId 的事实读口（定位007）', '0', '/process/templates/{templateId}'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:pumpSpeed:edit' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '泵速策略（模板）启停', 'futurefab.permission.m04.pumpSpeed.changeStatus',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       5, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:pumpSpeed:changeStatus', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝PUT /process/templates/{templateId}/status（定位009）', '0', '/process/templates/{templateId}/status'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:pumpSpeed:changeStatus' AND menu_type = 'F' AND del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '泵速策略（模板）删除', 'futurefab.permission.m04.pumpSpeed.remove',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m04.root' AND p.menu_type = 'M' AND p.del_flag = '0'),
       6, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:pumpSpeed:remove', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       '批次D｜仅登记不开放：该类型无前端页面（NO_UI），登记只解除 400 未登记前置，不产生死按钮；判权点＝POST /process/templates/{templateId}/delete（定位010）', '0', '/process/templates/{templateId}/delete'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'process:pumpSpeed:remove' AND menu_type = 'F' AND del_flag = '0');

-- =====================================================================================
-- ⑦ M03 培养管理页面与细分操作权限（7 码）
--    页面真实存在：app-smp-settings/src/views/culture-management/index.vue。
--    只登记权限，不写 sys_role_menu；部署期须按产品批准的角色范围显式授权。
-- =====================================================================================

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '培养ID管理', 'futurefab.menu.m03.culture', 0, 30, 'culture', 'resource/culture/index', NULL, NULL, 1, 0, 'C', '1', '0', NULL, NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M03 培养管理页面权限挂载锚点（隐藏）；真实菜单树由菜单设计与部署授权决定', '0', '/resource/culture/list'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.menu_i18n_key = 'futurefab.menu.m03.culture' AND x.del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1, '培养成员管理', 'futurefab.permission.m03.culture.members',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m03.culture' AND p.menu_type = 'C' AND p.del_flag = '0'),
       1, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'resource:culture:members', NULL, 'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M03：培养成员管理；业务对象权限仍由应用服务复核', '0', '/resource/grants/save'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'resource:culture:members' AND x.menu_type = 'F' AND x.del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1, '培养分享管理', 'futurefab.permission.m03.culture.share',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m03.culture' AND p.menu_type = 'C' AND p.del_flag = '0'),
       2, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'resource:culture:share', NULL, 'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M03：培养分享授权；业务对象权限仍由应用服务复核', '0', '/resource/grants/save'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'resource:culture:share' AND x.menu_type = 'F' AND x.del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1, '培养成员退出', 'futurefab.permission.m03.culture.exit',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m03.culture' AND p.menu_type = 'C' AND p.del_flag = '0'),
       3, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'resource:culture:exit', NULL, 'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M03：仅直接且未过期的培养成员可退出；应用服务继续复核成员事实', '0', '/resource/{type}/{id}/exit'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'resource:culture:exit' AND x.menu_type = 'F' AND x.del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1, '培养撤回草稿', 'futurefab.permission.m03.culture.withdraw',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m03.culture' AND p.menu_type = 'C' AND p.del_flag = '0'),
       4, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'resource:culture:withdraw', NULL, 'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M03：培养撤回草稿；状态机与对象权限由应用服务复核', '0', '/resource/culture/{cultureId}/withdraw'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'resource:culture:withdraw' AND x.menu_type = 'F' AND x.del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1, '培养重新预约', 'futurefab.permission.m03.culture.rebook',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m03.culture' AND p.menu_type = 'C' AND p.del_flag = '0'),
       5, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'resource:culture:rebook', NULL, 'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M03：已过期培养重新预约；状态机、版本与资源占用由应用服务复核', '0', '/resource/culture/{cultureId}/rebook'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'resource:culture:rebook' AND x.menu_type = 'F' AND x.del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1, '培养模式变更', 'futurefab.permission.m03.culture.mode',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m03.culture' AND p.menu_type = 'C' AND p.del_flag = '0'),
       6, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'resource:culture:mode', NULL, 'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M03：培养模式变更；培养状态与切换时间记录由应用服务复核', '0', '/resource/culture/{cultureId}/mode'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'resource:culture:mode' AND x.menu_type = 'F' AND x.del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1, '培养N阶段标记', 'futurefab.permission.m03.culture.nMark',
       (SELECT p.menu_id FROM sys_menu p WHERE p.menu_i18n_key = 'futurefab.menu.m03.culture' AND p.menu_type = 'C' AND p.del_flag = '0'),
       7, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'resource:culture:nMark', NULL, 'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M03：培养 N 阶段标记；业务对象权限由应用服务复核', '0', '/resource/culture/{cultureId}/n-mark'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'resource:culture:nMark' AND x.menu_type = 'F' AND x.del_flag = '0');


-- =====================================================================================
-- ⑪ M06 通用审批操作页（既有 5 码；不授权角色、不初始化政策）
--    设置子应用路径 approval-requests，由门户按 process/approval/index 解析。
--    数据可见范围由 M06/M02 复核；按钮码不能替代实验室、对象、阶段及人员分离资格。
-- =====================================================================================

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '审批管理', 'futurefab.menu.m06.root', 0, 60, 'process', NULL, NULL, NULL, 1, 0, 'M', '0', '0', NULL, NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M06 通用审批目录；不开放政策编辑、核准导入或 Q39 启用', '0', ''
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.menu_i18n_key = 'futurefab.menu.m06.root' AND x.del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '审批操作', 'futurefab.menu.m06.approval', p.menu_id, 1, 'approval-requests', 'process/approval/index', NULL, NULL, 1, 0, 'C', '0', '0', 'process:approval:list', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M06 审批列表；只登记既有功能码，数据范围仍由 M06/M02 按当前身份核验', '0', '/process/approval/requests'
FROM sys_menu p
WHERE p.menu_i18n_key = 'futurefab.menu.m06.root' AND p.menu_type = 'M' AND p.del_flag = '0'
  AND NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.menu_i18n_key = 'futurefab.menu.m06.approval' AND x.del_flag = '0')
  AND NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'process:approval:list' AND x.del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '审批详情与记录', 'futurefab.permission.m06.approval.query', p.menu_id, 1, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:approval:query', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M06 详情与动作日志读取；不产生写权限', '0', '/process/approval/requests/{approvalId}'
FROM sys_menu p
WHERE p.menu_i18n_key = 'futurefab.menu.m06.approval' AND p.menu_type = 'C' AND p.del_flag = '0'
  AND NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'process:approval:query' AND x.del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '审核及当前审核阶段驳回', 'futurefab.permission.m06.approval.review', p.menu_id, 2, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:approval:review', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M06 REVIEW_PASS/审核阶段 REJECT；服务继续核验当前阶段、指定人及人员分离', '0', '/process/approval/requests/{approvalId}/actions'
FROM sys_menu p
WHERE p.menu_i18n_key = 'futurefab.menu.m06.approval' AND p.menu_type = 'C' AND p.del_flag = '0'
  AND NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'process:approval:review' AND x.del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '批准及当前批准阶段驳回', 'futurefab.permission.m06.approval.approve', p.menu_id, 3, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:approval:approve', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M06 APPROVE_PASS/批准阶段 REJECT；服务继续核验当前阶段、指定人及人员分离', '0', '/process/approval/requests/{approvalId}/actions'
FROM sys_menu p
WHERE p.menu_i18n_key = 'futurefab.menu.m06.approval' AND p.menu_type = 'C' AND p.del_flag = '0'
  AND NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'process:approval:approve' AND x.del_flag = '0');

INSERT INTO sys_menu (menu_id, menu_name, menu_i18n_key, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark, del_flag, api_path)
SELECT (SELECT COALESCE(MAX(menu_id), 0) FROM sys_menu) + 1,
       '撤回本人审批申请', 'futurefab.permission.m06.approval.withdraw', p.menu_id, 4, NULL, NULL, NULL, NULL, 1, 0, 'F', '0', '0', 'process:approval:withdraw', NULL,
       'INSTALL', UTC_TIMESTAMP(), NULL, NULL,
       'M06 WITHDRAW；仍须申请人身份、当前状态及版本一致', '0', '/process/approval/requests/{approvalId}/actions'
FROM sys_menu p
WHERE p.menu_i18n_key = 'futurefab.menu.m06.approval' AND p.menu_type = 'C' AND p.del_flag = '0'
  AND NOT EXISTS (SELECT 1 FROM sys_menu x WHERE x.perms = 'process:approval:withdraw' AND x.del_flag = '0');

COMMIT;

-- =====================================================================================
-- ⑧ 包内核验（手工执行后核对；全部期望 0 行 / 指定行数；核验 1~5 覆盖 INT-02 原 24 码及 M07-032/033 两码，M04 见 ⑨，M03 见 ⑩）
-- =====================================================================================

-- 核验 1：本包 26 个权限码必须全部在册（期望恰好 26 行，status='0'、del_flag='0'）
SELECT m.perms, m.menu_name, m.menu_type, m.status
FROM sys_menu m
WHERE m.perms IN (
        'lab:engineering:query',
        'lab:engineering:edit', 'lab:engineering:verify', 'lab:engineering:revoke',
        'detect:correction:submit', 'detect:correction:review', 'detect:sign:sign', 'detect:sign:audit',
        'run:task:add', 'run:task:edit', 'run:task:cancel', 'run:task:pause', 'run:task:resume',
        'run:task:handle', 'run:task:list', 'run:task:query',
        'run:workflow:query', 'run:workflow:start', 'run:workflow:operate',
        'run:service:restart', 'run:balance:query',
        'run:glucose:add', 'run:glucose:confirm', 'run:glucose:query',
        'run:executorAssignment:list', 'run:executorAssignment:transfer'
      ) AND m.menu_type IN ('C', 'F') AND m.del_flag = '0'
ORDER BY m.perms;
-- 期望：26 行

-- 核验 2：本包权限码不得重复登记（期望 0 行）
SELECT perms, COUNT(*) AS dup
FROM sys_menu
WHERE perms IN (
        'lab:engineering:query',
        'lab:engineering:edit', 'lab:engineering:verify', 'lab:engineering:revoke',
        'detect:correction:submit', 'detect:correction:review', 'detect:sign:sign', 'detect:sign:audit',
        'run:task:add', 'run:task:edit', 'run:task:cancel', 'run:task:pause', 'run:task:resume',
        'run:task:handle', 'run:task:list', 'run:task:query',
        'run:workflow:query', 'run:workflow:start', 'run:workflow:operate',
        'run:service:restart', 'run:balance:query',
        'run:glucose:add', 'run:glucose:confirm', 'run:glucose:query',
        'run:executorAssignment:list', 'run:executorAssignment:transfer'
      ) AND del_flag = '0'
GROUP BY perms HAVING COUNT(*) > 1;
-- 期望：0 行

-- 核验 3：本包不得产生任何角色绑定（期望 0 行；sys_role_menu 播种属部署核准职责）
SELECT 'unexpected_role_menu_binding' AS finding, m.menu_i18n_key, m.perms
FROM sys_role_menu rm
JOIN sys_menu m ON m.menu_id = rm.menu_id
WHERE m.menu_i18n_key LIKE 'futurefab.menu.%' OR m.menu_i18n_key LIKE 'futurefab.permission.%'
LIMIT 1;
-- 期望：0 行

-- 核验 4：本包目录/菜单/按钮类型面（M06 新增 M=1、C=1、F=4；期望恰 83 行且父链完整）
SELECT m.menu_type, COUNT(*) AS cnt
FROM sys_menu m
WHERE (m.menu_i18n_key LIKE 'futurefab.menu.%' OR m.menu_i18n_key LIKE 'futurefab.permission.%')
  AND m.del_flag = '0'
GROUP BY m.menu_type;
-- 期望：M=5、C=7、F=71（含 M07 executorAssignment 与 M06 审批操作页）
-- 例外口径：若核验 8 返回非 0 行（该库先执行过 sql/20260929_process_feeding_menu.sql），
--           本项 F 计数会是 66 而非 71——那 5 码已被 legacy 行占用 perms 幂等键，本包按 NOT EXISTS 跳过，
--           不是丢行。此时登记是否齐备一律以核验 6 的 perms 轴为准，i18n 轴须按核验 8 处置单收敛后复跑本项。

-- 核验 5：本包所有 F 行父链必须存在且可见性/状态合规（期望 0 行异常）
SELECT 'orphan_or_bad_state' AS finding, m.perms
FROM sys_menu m
WHERE m.menu_type = 'F' AND m.menu_i18n_key LIKE 'futurefab.permission.%' AND m.del_flag = '0'
  AND (
        NOT EXISTS (SELECT 1 FROM sys_menu p WHERE p.menu_id = m.parent_id AND p.del_flag = '0')
     OR m.status <> '0'
      );
-- 期望：0 行

-- =====================================================================================
-- ⑨ M04 包内核验（批次 D；全部只读查询，接在 ⑧ 之后执行；核验 6~9）
-- =====================================================================================

-- 核验 6：M04 36 码在现行登记面必须齐备（perms 轴，与 i18n 轴无关；legacy 先行时同样成立）
SELECT c.perm AS missing_m04_function_code
FROM (
     SELECT 'process:config:list' AS perm UNION ALL SELECT 'process:config:query' AS perm UNION ALL SELECT 'process:config:add' AS perm UNION ALL SELECT 'process:config:edit' AS perm UNION ALL SELECT 'process:config:changeStatus' AS perm UNION ALL SELECT 'process:config:remove' AS perm UNION ALL SELECT 'process:perfusion:list' AS perm UNION ALL SELECT 'process:perfusion:query' AS perm UNION ALL SELECT 'process:perfusion:add' AS perm UNION ALL SELECT 'process:perfusion:edit' AS perm UNION ALL SELECT 'process:perfusion:changeStatus' AS perm UNION ALL SELECT 'process:perfusion:remove' AS perm UNION ALL SELECT 'process:sampling:list' AS perm UNION ALL SELECT 'process:sampling:query' AS perm UNION ALL SELECT 'process:sampling:add' AS perm UNION ALL SELECT 'process:sampling:edit' AS perm UNION ALL SELECT 'process:sampling:changeStatus' AS perm UNION ALL SELECT 'process:sampling:remove' AS perm UNION ALL SELECT 'process:autoControl:list' AS perm UNION ALL SELECT 'process:autoControl:query' AS perm UNION ALL SELECT 'process:autoControl:add' AS perm UNION ALL SELECT 'process:autoControl:edit' AS perm UNION ALL SELECT 'process:autoControl:changeStatus' AS perm UNION ALL SELECT 'process:autoControl:remove' AS perm UNION ALL SELECT 'process:feeding:list' AS perm UNION ALL SELECT 'process:feeding:query' AS perm UNION ALL SELECT 'process:feeding:add' AS perm UNION ALL SELECT 'process:feeding:edit' AS perm UNION ALL SELECT 'process:feeding:changeStatus' AS perm UNION ALL SELECT 'process:feeding:remove' AS perm UNION ALL SELECT 'process:pumpSpeed:list' AS perm UNION ALL SELECT 'process:pumpSpeed:query' AS perm UNION ALL SELECT 'process:pumpSpeed:add' AS perm UNION ALL SELECT 'process:pumpSpeed:edit' AS perm UNION ALL SELECT 'process:pumpSpeed:changeStatus' AS perm UNION ALL SELECT 'process:pumpSpeed:remove' AS perm
     ) c
WHERE NOT EXISTS (SELECT 1 FROM sys_menu m WHERE m.perms = c.perm AND m.menu_type = 'F' AND m.del_flag = '0');
-- 期望：0 行。非 0 行＝该码在 M04 判权调用面仍 400 INPUT_INVALID（含超管），不得宣称权限面可用

-- 核验 7：M04 36 码不得重复登记（同码多 F 行会让权限字典出现歧义行）
SELECT m.perms, COUNT(*) AS dup, GROUP_CONCAT(m.menu_id) AS menu_ids
FROM sys_menu m
WHERE m.menu_type = 'F' AND m.del_flag = '0'
  AND m.perms IN (
     'process:config:list', 'process:config:query', 'process:config:add', 'process:config:edit', 'process:config:changeStatus', 'process:config:remove', 'process:perfusion:list', 'process:perfusion:query', 'process:perfusion:add', 'process:perfusion:edit', 'process:perfusion:changeStatus', 'process:perfusion:remove', 'process:sampling:list', 'process:sampling:query', 'process:sampling:add', 'process:sampling:edit', 'process:sampling:changeStatus', 'process:sampling:remove', 'process:autoControl:list', 'process:autoControl:query', 'process:autoControl:add', 'process:autoControl:edit', 'process:autoControl:changeStatus', 'process:autoControl:remove', 'process:feeding:list', 'process:feeding:query', 'process:feeding:add', 'process:feeding:edit', 'process:feeding:changeStatus', 'process:feeding:remove', 'process:pumpSpeed:list', 'process:pumpSpeed:query', 'process:pumpSpeed:add', 'process:pumpSpeed:edit', 'process:pumpSpeed:changeStatus', 'process:pumpSpeed:remove'
   )
GROUP BY m.perms HAVING COUNT(*) > 1;
-- 期望：0 行

-- 核验 8：legacy 旧菜单面与本包同码共存时如实暴露（固定 menu_id 段 / 空 i18n_key / 旧父级）
SELECT m.menu_id, m.perms, m.menu_i18n_key, m.parent_id,
       (SELECT COUNT(*) FROM sys_menu p WHERE p.menu_id = m.parent_id AND p.del_flag = '0') AS parent_rows
FROM sys_menu m
WHERE m.perms LIKE 'process:%' AND m.del_flag = '0'
  AND (m.menu_i18n_key IS NULL OR m.menu_i18n_key = '' OR m.menu_id BETWEEN 1290000000000000001 AND 1290000000000000005)
ORDER BY m.menu_id;
-- 期望：0 行。非 0 行＝该库同时执行过 sql/20260929_process_feeding_menu.sql（旧菜单导出面）：
--       这些行无 i18n 迁移键、父级 menu_id 在新系统不存在（parent_rows=0 即孤行）。
--       处置单选其一并在同一批次改核验，不得在两套种子上叠第三套：
--       (A) 新系统空库只执行本包，不执行该 legacy 脚本；
--       (B) 已执行过 legacy 的开发库，按 menu_id 1290000000000000001~05 逐行补齐 i18n_key 并重挂到
--           futurefab.menu.m04.* 父链（补齐前先确认 parent_rows），或 (C) 逻辑删除 legacy 行后重跑本包。

-- 核验 9：区分「功能码已登记」与「普通用户已获授权」——本包不得产生任何角色绑定
SELECT m.perms, rm.role_id
FROM sys_role_menu rm
JOIN sys_menu m ON m.menu_id = rm.menu_id
WHERE m.perms LIKE 'process:%' AND m.del_flag = '0';
-- 期望：0 行（本包只登记功能码；sys_role_menu 播种属部署核准职责，不猜角色、不自动授权）。
--       非 0 行须逐条核绑定来源与批准记录；核验 6 通过仅证明“码已登记”，不证明普通用户可用。

-- =====================================================================================
-- ⑩ M03 培养权限包内核验（全部只读查询）
-- =====================================================================================

SELECT c.perm AS missing_m03_culture_permission
FROM (
     SELECT 'resource:culture:members' AS perm UNION ALL SELECT 'resource:culture:share' UNION ALL
     SELECT 'resource:culture:exit' UNION ALL SELECT 'resource:culture:withdraw' UNION ALL
     SELECT 'resource:culture:rebook' UNION ALL SELECT 'resource:culture:mode' UNION ALL
     SELECT 'resource:culture:nMark'
     ) c
WHERE NOT EXISTS (SELECT 1 FROM sys_menu m WHERE m.perms = c.perm AND m.menu_type = 'F' AND m.del_flag = '0');
-- 期望：0 行

SELECT m.perms, COUNT(*) AS dup, GROUP_CONCAT(m.menu_id) AS menu_ids
FROM sys_menu m
WHERE m.menu_type = 'F' AND m.del_flag = '0'
  AND m.perms IN ('resource:culture:members', 'resource:culture:share', 'resource:culture:exit',
                  'resource:culture:withdraw', 'resource:culture:rebook', 'resource:culture:mode',
                  'resource:culture:nMark')
GROUP BY m.perms HAVING COUNT(*) > 1;
-- 期望：0 行

SELECT m.perms, rm.role_id
FROM sys_role_menu rm
JOIN sys_menu m ON m.menu_id = rm.menu_id
WHERE m.perms IN ('resource:culture:members', 'resource:culture:share', 'resource:culture:exit',
                  'resource:culture:withdraw', 'resource:culture:rebook', 'resource:culture:mode',
                  'resource:culture:nMark') AND m.del_flag = '0';
-- 期望：0 行；本包不自动给任何角色授权。

-- =====================================================================================
-- ⑫ M06 包内核验（全部只读；安装后与重复执行后都必须核对）
-- =====================================================================================

-- 根/页面必须唯一、可见、有效，且组件路径与门户约定一致（期望 0 行）。
SELECT 'm06_approval_navigation_mismatch' AS finding
WHERE (SELECT COUNT(*) FROM sys_menu m
       WHERE m.menu_i18n_key = 'futurefab.menu.m06.root' AND m.parent_id = 0
         AND m.path = 'process' AND m.menu_type = 'M' AND m.visible = '0' AND m.status = '0' AND m.del_flag = '0') <> 1
   OR (SELECT COUNT(*) FROM sys_menu m JOIN sys_menu p ON p.menu_id = m.parent_id
       WHERE m.menu_i18n_key = 'futurefab.menu.m06.approval' AND p.menu_i18n_key = 'futurefab.menu.m06.root'
         AND p.del_flag = '0' AND m.path = 'approval-requests' AND m.component = 'process/approval/index'
         AND m.perms = 'process:approval:list' AND m.menu_type = 'C'
         AND m.visible = '0' AND m.status = '0' AND m.del_flag = '0') <> 1;

-- 五个既有功能码必须各登记一次；动作码只挂载审批 C 行（期望 0 行）。
SELECT c.perm AS missing_duplicate_or_misparented_m06_permission
FROM (
     SELECT 'process:approval:list' AS perm, 'C' AS expected_type UNION ALL
     SELECT 'process:approval:query', 'F' UNION ALL SELECT 'process:approval:review', 'F' UNION ALL
     SELECT 'process:approval:approve', 'F' UNION ALL SELECT 'process:approval:withdraw', 'F'
     ) c
WHERE (SELECT COUNT(*) FROM sys_menu m WHERE m.perms = c.perm AND m.del_flag = '0') <> 1
   OR NOT EXISTS (SELECT 1 FROM sys_menu m
                  WHERE m.perms = c.perm AND m.menu_type = c.expected_type AND m.status = '0' AND m.del_flag = '0'
                    AND (c.expected_type = 'C' OR EXISTS
                         (SELECT 1 FROM sys_menu p WHERE p.menu_id = m.parent_id
                            AND p.menu_i18n_key = 'futurefab.menu.m06.approval' AND p.menu_type = 'C' AND p.del_flag = '0')));

-- 不扩出第六个动作码；驳回按当前审核/批准阶段复用既有权限（期望 0 行）。
SELECT m.perms AS unexpected_m06_approval_permission
FROM sys_menu m
WHERE m.perms LIKE 'process:approval:%' AND m.del_flag = '0'
  AND m.perms NOT IN ('process:approval:list', 'process:approval:query', 'process:approval:review',
                     'process:approval:approve', 'process:approval:withdraw');

-- 本包不自动授权角色。已有部署绑定须单独出示批准记录，不把登记成功当作授权（空库期望 0 行）。
SELECT m.menu_i18n_key, m.perms, rm.role_id
FROM sys_role_menu rm JOIN sys_menu m ON m.menu_id = rm.menu_id
WHERE m.del_flag = '0' AND (m.menu_i18n_key IN ('futurefab.menu.m06.root', 'futurefab.menu.m06.approval')
      OR m.perms IN ('process:approval:list', 'process:approval:query', 'process:approval:review',
                    'process:approval:approve', 'process:approval:withdraw'));
