# 旧 CRUD 写端点盘点摘要（任务B 阶段1，只读）

> 盘点范围：`futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/` 下 143 个 `@RestController`，共 1002 个映射（GET 458 / POST 299 / PUT 157 / DELETE 87 / PATCH 1）。

> 写端点口径：POST/PUT/DELETE/PATCH 共 544 个；排除 76 个 `/export` 后为 468 个候选写端点（其中仍含少量查询型 POST，不影响 LEGACY 计数）。LEGACY 122 个，分布在 44 个控制器，占非导出写端点 26.1%。

> 说明：`DevReactorModelController` 的两个 PUT（PID、整型号）实际使用 `ReactorModelPidService`/`ReactorModelEditService` + `@ManagementGuardedWrite`，脚本初判为 LEGACY，已人工修正为 GUARDED，不计入本清单。


## 总体分类（非 /export 写端点 468）

| 风格 | 数量 | 说明 |
|---|---|---|
| GUARDED | 276 | 经 ApplicationService + ManagementGuardExecutor（含 4 个构造函数注入被脚本误判的 DevReactorModel 端点修正） |
| LEGACY | 122 | 直接调 I*Service + toAjax，无守卫（脚本原始 124，人工剔除 2 个误判） |
| ALREADY_DISABLED | ≥52 | 41 个经 Legacy*Guard，另 ≥11 个经 410 / EndpointDisabledException / ManagementGuardRejectException |
| OTHER | 18 | 内部 ingress、会话/敏感操作、查询型 POST、模板下载等非 CRUD 写口 |

## 建议处置统计

| 建议处置 | 数量 |
|---|---|
| DISABLE | 30 |
| ADJUST | 82 |
| 待确认 | 10 |
| **合计** | **122** |

> 处置轨迹（累计口径）：初始 68/32/22 → 泵相关 V5.1 复核后 72/39/11（4 条转 DISABLE、7 条转 ADJUST）→ DetectionRule DELETE 回原版 docx 核实后 73/39/10（1 条转 DISABLE）→ 2026-11-04 DetectionRule POST/PUT/DELETE 三项因「功能保留、下一期使用」改判 ADJUST 后 70/42/10（DISABLE −3、ADJUST +3）→ **2026-11-04 去重核查后 30/82/10**（40 条有页面实际调用改判 ADJUST，0 条已停用剔除；20 条可标注、10 条存疑仍留 DISABLE；合计 122 不变）。

## ⚠ 需求侧冲突（已解决）与缺口提示（2026-11-04）

> 泵速策略冲突与培养负责人写入口分歧均已于 2026-11-04 裁决解决（本节及「复核说明」保留演进留痕）；检测规则「业务要留、需求已删」的需求依据缺口仍待补。本次只记录，不改需求文档、不改 Java。

### 冲突（已解决 2026-11-04）：泵速策略「三阶段实现」注记 vs「本期实现」决策

- 原冲突描述（2026-11-04 记录）：`docs/需求说明书V5.1-1030_md/02-实验室设置.md:370` 写明「工艺管理－泵速策略需求在三阶段实现」，与用户「泵速策略③本期要做」（需求 1.6.7）的决策冲突。
- 处理结论（2026-11-04 用户裁决，已解决）：该句是历史表述，**本期确认实现，该句应删除**；需求主线正在处理正文与澄清记录。泵速策略正文按 `docs/需求说明书V5.1-1030_md/06-工艺设置.md:1635-1674` 执行，4 个写端点维持 ADJUST。
- 状态描述补充：4 条 ADJUST 已进入本期实施范围，需新增写端口 + 应用服务 + 守卫（见下方「泵速策略本期落地的实现缺口」）。
- 演进留痕：原处理建议（二选一）已被上述裁决取代，排期问题已关闭；保留原冲突描述以便追溯。

### 缺口：检测规则「业务要留、需求已删」

- 决策：用户 2026-11-04 明确「检测规则功能保留，下一期还会用」，3 个写端点由 DISABLE 改判 ADJUST。
- 事实：V5.1 原版 docx `03-资源管理` 全章（段落 1640-2006）无「检测规则②」章节；全篇仅 4 处引用（04-项目设置 段落 2132-2135），且正文均带 `w:strike`。
- 风险：下一期实现该功能时**没有需求依据**，设计评审会被判定「无需求支撑」。
- 建议（不自行决定）：在 V5.1 或后续版本把「检测规则」重新纳入正文，并明确字段、权限与审计要求；在此之前，本期只做接入守卫，不把旧 CRUD 行为当作需求基线。

### 泵速策略本期落地的实现缺口（只记录，不做设计）

- 现状：`PumpSpeedStrategyCatalogPort` 仅提供只读能力（M04 侧），没有写入端口。
- 本期要落地写操作，需要补「**写端口 + 应用服务 + `ManagementGuardExecutor` 守卫**」链路；旧 4 个 CRUD 写端点届时由新端点替代，或接入守卫后保留。
- 涉及表：`pump_speed_strategy`（沿用清单登记，未臆造其他表名）。

## 去重核查结果（2026-11-04 静态核查）

> 目标：在加 `@Deprecated` 前确认 70 条 DISABLE 是否真的还能被调用。逐条证据见[调查-旧CRUD写端点去重核查.md](调查-旧CRUD写端点去重核查.md)。

| 分类 | 条数 | 处置 |
|---|---|---|
| 已停用，须剔除 | 0 | 70 条对应方法体均未命中停用异常/守卫拒绝 |
| 有已知调用方，改判 ADJUST | 40 | 页面实际调用；接入 `ManagementGuardExecutor`，不做 `@Deprecated` |
| 可以标注 | 20 | 保留 DISABLE，待用户确认后标注 |
| 存疑 | 10 | 仅 SDK 旧封装、页面/Feign/测试未调用；暂留 DISABLE，不标注 |
| **合计** | **70** | 无剔除，条数不变 |

> 影响：全量清单 DISABLE 70 → **30**（20 可标注 + 10 存疑）；ADJUST 42 → **82**（+40）；待确认 10；合计 122。
> 限制：本轮未改 Java、未 commit/push、未执行 HTTP/浏览器/SQL/Java 测试；结论仅为静态检查。

## 阶段 2 处置方案（方案 A：纯标记）

> 用户已拍板：阶段 2 先做去重核查，再按模块分批标注；核查后统计为 **DISABLE 30 / ADJUST 82 / 待确认 10，合计 122**。本方案仅覆盖仍保留 DISABLE 的 30 条，其中 20 条可标注、10 条存疑暂不标注。

- **方案 A 定义**：对判定为 DISABLE 的写端点，只在方法上加 `@Deprecated`，并在注释/Javadoc 写明处置编号、判定依据、对应的 `需求说明书V5.1-1030_md` 章节，以及“如 V5.1 设计确认仍需保留，可直接撤除标注恢复”。
- **行为完全不变**：不抛异常、不改调用链、不改返回值、不改权限注解。
- **为什么改为方案 A**：清空方法体或抛 `EndpointDisabledException` 不可逆；V5.1 设计尚未定稿，需要保留“可撤除标注即恢复”的能力，避免阶段 2 误伤后续确认仍需保留的入口。
- **已知代价**：标记不阻止任何写入，旧 CRUD 口子仍可被调用，只靠注释挡不住；因此这批端点的写风险在阶段 2 后依然存在，需在 V5.1 设计定稿后再决定是否真正停用。
- **处置编号**：沿用 `LEGACY-<模块>-<资源>-<动作>`，逐端点唯一。CSV 列结构不变、不新增列；编号、V5.1 依据、标注状态与恢复方法逐条登记在[调查-旧CRUD写端点处置登记表.md](调查-旧CRUD写端点处置登记表.md)。
- **阶段 2 执行顺序**：按 M01 → M02 → M03 → M09 分组分批，每组跑 `mvn -pl futurefab-modules/futurefab-system -am test` 后再进下一组；前置核查已完成：70 条中 0 条已停用、40 条改判 ADJUST；标注只覆盖可标注 20 条（M01 1、M02 9、M03 0、M09 10），存疑 10 条待确认后再定。

## 按控制器分布

| 控制器 | DISABLE | ADJUST | 待确认 |
|---|---|---|---|
| AlarmNotifyReceiverController | 0 | 3 | 0 |
| AlarmNotifyRuleController | 6 | 0 | 0 |
| AlarmRecordController | 4 | 0 | 0 |
| DetWorkbenchController | 0 | 0 | 1 |
| DetectionRuleController | 0 | 3 | 0 |
| LabBenchReactorControllerChannelController | 0 | 3 | 0 |
| LabBenchReactorControllerController | 3 | 0 | 0 |
| LabDetectorItemConfigController | 2 | 0 | 1 |
| LabDownstreamDeviceController | 1 | 0 | 0 |
| LabIntegratedReactorPumpController | 3 | 0 | 0 |
| LabLabLeaderController | 3 | 0 | 0 |
| LabOfflineAlarmConfigController | 2 | 2 | 0 |
| LabPumpSpeedStrategyController | 0 | 4 | 0 |
| LabStatusAlarmConfigController | 2 | 0 | 0 |
| LabWorkflowController | 0 | 0 | 1 |
| ResBatchController | 1 | 0 | 0 |
| ResBatchLeaderController | 0 | 3 | 0 |
| ResBatchMemberController | 0 | 3 | 0 |
| ResCultureController | 1 | 2 | 0 |
| ResCultureLeaderController | 0 | 3 | 0 |
| ResCultureMemberController | 0 | 3 | 0 |
| ResProjectController | 1 | 1 | 0 |
| ResProjectLabController | 0 | 3 | 0 |
| ResProjectLeaderController | 0 | 3 | 0 |
| ResProjectMemberController | 0 | 3 | 0 |
| ResProjectTagController | 0 | 3 | 0 |
| SysConfigController | 0 | 0 | 1 |
| SysDeptController | 0 | 1 | 0 |
| SysDictDataController | 0 | 1 | 0 |
| SysDictTypeController | 0 | 1 | 1 |
| SysGroupController | 1 | 0 | 0 |
| SysGroupLeaderController | 0 | 3 | 0 |
| SysGroupMemberController | 0 | 3 | 0 |
| SysLogininforController | 0 | 1 | 2 |
| SysMenuController | 0 | 1 | 1 |
| SysNoticeController | 0 | 5 | 0 |
| SysNotificationController | 0 | 6 | 0 |
| SysOperlogController | 0 | 1 | 2 |
| SysPostController | 0 | 3 | 0 |
| SysProfileController | 0 | 1 | 0 |
| SysRoleController | 0 | 4 | 0 |
| SysUserController | 0 | 3 | 0 |
| SysUserLabController | 0 | 4 | 0 |
| WorkflowController | 0 | 2 | 0 |

## 待确认项及原因

| 控制器 | 端点 | 原因 |
|---|---|---|
| DetWorkbenchController | POST /detect/workbench/result/{resultId}/refresh | 刷新检测结果为重算动作，未见守卫版等价，是否保留待确认 |
| LabDetectorItemConfigController | DELETE /lab/detectorconfig/{detectorIds} | 未找到新版等价端点，业务是否仍需要待确认 |
| LabWorkflowController | PUT /lab/lab/{labId}/workflows | 未见新版等价端点，工作流配置归属与下线计划待确认 |
| SysConfigController | DELETE /config/refreshCache | 缓存刷新为运维动作而非数据写，且无守卫版等价；需裁决保留(REUSE)或迁移 |
| SysDictTypeController | DELETE /dict/type/refreshCache | 缓存刷新为运维动作而非数据写；需裁决保留(REUSE)或迁移 |
| SysLogininforController | DELETE /logininfor/clean | 日志清理会删除审计数据，是否保留清理入口及保留期策略待产品裁决 |
| SysLogininforController | DELETE /logininfor/{infoIds} | 日志清理会删除审计数据，是否保留清理入口及保留期策略待产品裁决 |
| SysMenuController | DELETE /menu/{menuId} | 新增/修改/状态已有守卫版，但菜单删除无守卫版等价端点，待确认 |
| SysOperlogController | DELETE /operlog/clean | 日志清理会删除审计数据，是否保留清理入口及保留期策略待产品裁决 |
| SysOperlogController | DELETE /operlog/{operIds} | 日志清理会删除审计数据，是否保留清理入口及保留期策略待产品裁决 |

## 泵相关端点按 V5.1 复核结果

> 基线：`docs/需求说明书V5.1-1030_md/` 正文 + V4.0《需求澄清决策记录》（映射见 `docs/需求基线说明.md` 第 3 节）。
> 复核 16 条（泵速 4、泵通道/资源通道 3、泵配置/连接 3、集成泵 3、培养负责人 3），改判 11 条，维持 5 条。仅静态核对，未做 HTTP/浏览器验证。
> 说明：“资源通道”在本清单中对应 `/lab/pumpchannel`（`lab_bench_reactor_controller_channel`），CSV 无其他通道类写口。

| 控制器 | 端点 | 原处置 | 复核后 | V5.1 依据（文件:行） | 代码现状 |
|---|---|---|---|---|---|
| LabBenchReactorControllerChannelController | DELETE /lab/pumpchannel/{channelIds} | 待确认 | **DISABLE** | `02-实验室设置.md:301-370` | 无守卫等价；V5.1 仅要求“修改”泵默认连接，通道编码仅展示，无新增/删除通道要求 |
| LabBenchReactorControllerChannelController | POST /lab/pumpchannel/ | 待确认 | **DISABLE** | 同上 | 同上 |
| LabBenchReactorControllerChannelController | PUT /lab/pumpchannel/ | DISABLE | 维持 DISABLE | 同上 | 守卫版 `PUT /lab/pumpconnection/controller/{controllerId}` 覆盖修改 |
| LabBenchReactorControllerController | DELETE /lab/pumpconnection/{connectionIds} | 待确认 | **DISABLE** | `02-实验室设置.md:301-370` | 无新增/删除需求；守卫版按 `channelId` 差异更新已有连接 |
| LabBenchReactorControllerController | POST /lab/pumpconnection/ | 待确认 | **DISABLE** | 同上 | 同上 |
| LabBenchReactorControllerController | PUT /lab/pumpconnection/ | DISABLE | 维持 DISABLE | 同上 | 守卫版 `PUT /lab/pumpconnection/controller/{controllerId}`、`PUT /reactor/{reactorId}` |
| LabIntegratedReactorPumpController | DELETE /lab/integratedpump/{integratedIds} | DISABLE | 维持 DISABLE | `02-实验室设置.md` 集成反应器设置 | 守卫版 `PUT /lab/integratedreactor/{integratedId}` 聚合保存 `externalPumps` |
| LabIntegratedReactorPumpController | POST /lab/integratedpump/ | DISABLE | 维持 DISABLE | 同上 | 同上 |
| LabIntegratedReactorPumpController | PUT /lab/integratedpump/ | DISABLE | 维持 DISABLE | 同上 | 同上 |
| LabPumpSpeedStrategyController | DELETE /lab/pumpSpeed/{strategyIds} | 待确认 | **ADJUST** | `06-工艺设置.md:1635-1674`、`1641-1648` | 4 个写口均为旧 CRUD，仅 M04 `PumpSpeedStrategyCatalogPort` 只读；需求明确但缺守卫写实现 |
| LabPumpSpeedStrategyController | POST /lab/pumpSpeed/ | 待确认 | **ADJUST** | `06-工艺设置.md:1672-1674` | 同上 |
| LabPumpSpeedStrategyController | PUT /lab/pumpSpeed/ | 待确认 | **ADJUST** | `06-工艺设置.md:1643-1648`（操作列“修改”） | 同上 |
| LabPumpSpeedStrategyController | PUT /lab/pumpSpeed/{strategyId}/status | 待确认 | **ADJUST** | `06-工艺设置.md:1641-1648`（启用/禁用） | 同上 |
| ResCultureLeaderController | DELETE /resource/cultureleader/{cultureIds} | 待确认 | **ADJUST** | `04-项目设置①.md:598、637、659` | 新版 `CPatch`/`basic-batch` 无 leader 字段，成员接口只写成员；旧 CRUD 无守卫替代 |
| ResCultureLeaderController | POST /resource/cultureleader/ | 待确认 | **ADJUST** | 同上 | 同上 |
| ResCultureLeaderController | PUT /resource/cultureleader/ | 待确认 | **ADJUST** | 同上 | 同上 |

> 去重核查后（2026-11-04）：泵通道 10-12 因页面实际调用改判 ADJUST；泵连接 13-15、集成泵 19-21、实验室负责人 22-24 可标注；检测设备 16-17、其他设备 18 存疑。本节保留 V5.1 依据结论，最终处置以「去重核查结果」为准。

### 复核说明与剩余分歧

- 泵通道/泵连接 POST、DELETE：V5.1 的“泵的默认连接”只有“修改”入口，且“通道编码：仅文本展示”（`02-实验室设置.md:365`），V5.1 依据结论为 DISABLE。**去重核查补充（2026-11-04）**：泵通道 3 条页面仍实际调用，改判 ADJUST；泵连接 3 条无页面写调用，列为可标注。最终处置以「去重核查结果」为准。
- 泵速策略：V5.1 明确保留新增/修改/启停/删除（`06-工艺设置.md:1635`），故不能 DISABLE；2026-11-04 用户明确泵速策略③本期要做（需求 1.6.7），处置维持 ADJUST 并补记「已确认本期实施」；2026-11-04 已裁决该句为历史表述、本期实现，排期问题已关闭。
- 培养负责人：V5.1 保留负责人角色与展示（`04-项目设置①.md:598、637、659`），新版守卫写口未覆盖 `res_culture_leader`，故 ADJUST，不作为旧端点保留。
- 分歧（已解决 2026-11-04）：培养负责人应由培养基础守卫写口扩展，还是保留独立守卫口。
  - 原分歧描述（2026-11-04 记录）：V5.1 保留培养负责人角色与展示，但新版 `CPatch`/`basic-batch` 无 leader 字段、成员接口只写成员，3 条旧 CRUD 无守卫替代；归属方式当时待产品/设计裁决。
  - 处理结论（2026-11-04 用户裁决，已解决）：**选择 A——为培养负责人单开独立守卫写口**（应用服务 + `ManagementGuardExecutor` 模式），不把 leader 字段塞进培养基础守卫口，不与 `CPatch`/`basic-batch` 合并；旧 CRUD 3 条（DELETE/POST/PUT `/resource/cultureleader/...`）维持 ADJUST，届时由新端点替代或接入守卫。
  - 理由：负责人与成员是不同业务对象，审计语义不同；混进培养基础更新会导致 revision 粒度碎片化、审计难以溯源。
- 泵速策略的「三阶段实现」注记冲突已于 2026-11-04 裁决解决（历史注记删除、本期实现），不再列为分歧，见上方「需求侧冲突与缺口提示」。

## 培养负责人独立守卫写口（2026-11-04 裁决，供后续设计参考）

> 只描述形态，不写实现细节；落地时按现行《详细设计》与守卫写契约补齐。

- 端点形态：培养负责人单资源写口，含增/删/改（或按项目既有约定合并为批量保存）。
- 涉及表：`res_culture_leader`（沿用既有登记，不臆造其他表名）。
- 守卫要求：携带 `X-Request-Id`、`X-Management-Revision`，并做同事务审计。
- 权限：沿用既有 `resource:cultureleader:*`，不改菜单。
- 与培养基础写口的关系：独立，不并入 `CPatch`/`basic-batch`；旧 CRUD 3 条维持 ADJUST，届时由新端点替代或接入守卫。

## ADJUST 增补：DetectionRule 3 条（2026-11-04 用户裁决）

> 用户拍板：检测规则功能保留、下一期使用。三条写端点由 DISABLE 改判 ADJUST；依据事实不变（V5.1 原版 docx 无该章节、引用划线），但处置结论改为「接守卫」，不做 `@Deprecated` 标记；登记表中对应 DISABLE 行已移除。

| 控制器 | 端点 | 原处置 | 现处置 | 依据 | 说明 |
|---|---|---|---|---|---|
| DetectionRuleController | DELETE /detect/detectionRule/{ruleIds} | DISABLE | **ADJUST** | docx 03-资源管理 全章（段落 1640-2006）无「检测规则②」章节；仅 04-项目设置 段落 2132-2135 引用且正文带 `w:strike`；2026-11-04 决策「功能保留、下一期使用」 | 旧删除路由无守卫版等价，接 `ManagementGuardExecutor`；原编号 `LEGACY-M02-DETECTION-RULE-DELETE` 作废，不回收 |
| DetectionRuleController | POST /detect/detectionRule/ | DISABLE | **ADJUST** | 同上 | M02-216 逐项保存只承接新增/修改，旧整行 CRUD 无守卫；原编号 `LEGACY-M02-DETECTION-RULE-POST` 作废，不回收 |
| DetectionRuleController | PUT /detect/detectionRule/ | DISABLE | **ADJUST** | 同上 | 同上；原编号 `LEGACY-M02-DETECTION-RULE-PUT` 作废，不回收 |

## 原 70 条 DISABLE 回 V5.1 原版 docx 依据核对

> 方法：解压 `docs/需求说明书V5.1-1030.docx` 的 `word/document.xml`，按 `w:p` 顺序解析，逐 `w:r` 检查 `w:rPr/w:strike`、`w:dstrike`，并检查段落级 `w:pPr/w:rPr`；`val` 为 `0/false/off/none` 视为未划线。段落号为 `w:p` 顺序下标（从 0 开始），docx 无行号。
> 范围：原登记表 70 条 DISABLE（含 2026-11-04 去重核查后改判 ADJUST 的 40 条；3 条 DetectionRule 已按同日决策改判并移出）。逐条核章节标题是否存在、标题与关键正文是否划线；本节只补段落级依据，最终处置以「去重核查结果」为准。验证层级仍为静态检查，无 HTTP/浏览器验证。

| 依据状态 | 条数 |
|---|---|
| 依据成立 | 70 |
| 章节已删除（docx 划线） | 0 |
| 章节不存在 | 0 |
| 无法判定 | 0 |
| **合计** | **70** |

- **依据已补全覆盖率**：70/70 已给到段落级证据（章节名 + 标题段落号 + 正文区间与划线段数，或引用段落号）；0 条仍只能章节级；0 条无法判定。
- **原 3 条依据不成立条目已改判 ADJUST**：`DetectionRuleController` DELETE / POST / PUT 在 2026-11-04 决策后由 DISABLE 改为 ADJUST，移出本 DISABLE 核对集；其「章节不存在 / 引用划线」的事实保留在上方 ADJUST 增补节与登记表 4.1，不再计入本表状态统计。
- **标题已划线但依据仍成立**：docx 03-资源管理「集成反应器①」段落 1678 带删除线（目录段落 117 同）；对应端点依据指向 02-实验室设置段落 1084「集成反应器①」，该标题未划线。
- **正文局部划线但不影响依据**：其他设备 2 段、集成反应器 2 段、实验室管理 1 段、离线告警 1 段、批次管理 9 段、培养基础管理 10 段；相关章节标题均未划线，故状态仍为「依据成立」，md/docx 差异已记入登记表 4.1。

## 关键不确定性

- 现有代码并非“完全没有 DISABLE”：M05 检测类控制器、M03 项目/批次/培养部分旧口已使用 LegacyDetectionEndpointGuard / LegacyResourceEndpointGuard 拒绝（41 个）；另有 ≥11 个旧口固定返回 410 或抛 EndpointDisabledException / ManagementGuardRejectException（如 AlarmMailConfig、DetResultSignRecord、SysUserPasswordHistory、PUT /resource/batch/）。任务前提需按此修正。
- 表名由 Service→Mapper→XML 推断；XML 中取首个主表。LabBenchReactorControllerController 的 XML 含多张关联表，主表为 lab_bench_reactor_controller。
- “已知调用方”以仓库内前端 SDK 封装、Feign 客户端、页面/测试引用为证据；SDK 有封装不等于页面一定在调用，页面实际使用未逐页核对。
- 未做任何 HTTP/浏览器验证，全部为静态源码盘点，验证层级为“静态检查通过”。
- 阶段 2 已确认采用方案 A（纯标记），但尚未执行任何 `@Deprecated` 标注；本次仅更新文档与登记表，未修改任何 Java 代码与 Git 状态。