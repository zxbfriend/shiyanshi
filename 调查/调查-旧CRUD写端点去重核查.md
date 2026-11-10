# 旧 CRUD 写端点去重核查（阶段 2 前置 · 2026-11-04）

> 范围：`docs/调查/调查-旧CRUD写端点处置登记表.md` 登记的 70 条 DISABLE（原 73 条中 3 条 DetectionRule 已于 2026-11-04 改判 ADJUST 并移出）。
> 目标：在加 `@Deprecated` 之前，先确认每条是否真的还能被调用，避免给已停用端点做无效标注、也避免标注仍在前端使用的端点。
> 方法：只读检索仓库内 Controller、`sdk-smp-api`、`app-smp-*` 页面、`futurefab-api`/Feign、测试与配置；逐条比对路径、方法、SDK 函数与页面调用点。
> 限制：本轮**不改任何 Java 代码**，不 commit/push；未执行 HTTP、浏览器、SQL、Java 运行验证，结论层级为「静态检查通过」。

## 结论统计（70 条）

| 分类 | 条数 | 处置 |
|---|---|---|
| 已停用，须剔除 | 0 | 70 条对应方法体均未命中停用异常/守卫拒绝 |
| 有已知调用方，改判 ADJUST | 40 | CSV/摘要改为 ADJUST，接入 `ManagementGuardExecutor` 守卫，不做 `@Deprecated` |
| 可以标注 | 20 | 保留 DISABLE，待用户确认后加 `@Deprecated` 与 Javadoc |
| 存疑 | 10 | 暂留 DISABLE，不进入标注；待确认 SDK 旧函数是否废弃或是否有仓外调用方 |
| **合计** | **70** | 无剔除项，条数不变 |

> 全量清单口径：DISABLE 70 → **30**（20 可标注 + 10 存疑）；ADJUST 42 → **82**（+40 改判）；待确认 10；合计仍 122。
> 轨迹：68/32/22 → 72/39/11 → 73/39/10 → 70/42/10 → **30/82/10**（2026-11-04 去重核查）。

## 判定口径

1. **已停用**：方法体直接 `throw new EndpointDisabledException` / `ManagementGuardRejectException(PROTOCOL_UPGRADE_REQUIRED)`，或经 `LegacyDetectionEndpointGuard`、`LegacyResourceEndpointGuard` 拒绝，或固定 410/`PROTOCOL_UPGRADE_REQUIRED`。
2. **有已知调用方**：仓库内代码（前端 SDK 函数被页面导入并调用、页面直连 URL、Feign、测试）实际发出请求。仅 SDK 有封装但页面未调用，**不算**已知调用方，归入存疑。
3. **可以标注**：既无停用证据，也无任何可达调用方。
4. **存疑**：SDK 已定义旧写函数、但页面/测试/Feign 均未调用；无法判断是遗留死封装还是仓外调用方仍在使用，故不在本轮剔除，也不进入标注。

## 1. 已停用，须剔除（0 条）

对 70 条对应控制器方法体做 `throw new` 扫描，未命中 `EndpointDisabledException`、`ManagementGuardRejectException`、`PROTOCOL_UPGRADE_REQUIRED`；70 条均为普通 `toAjax(I*Service)` / `success(service...)` 写口。**本轮无剔除项。**

作为对照，仓库内确实存在已停用端点，但均不在本 70 条登记范围内：

| 控制器 | 端点 | 停用证据 |
|---|---|---|
| DetResultSignRecordController | POST/PUT/DELETE `/detect/signrecord...` | `DetResultSignRecordController.java:88/96/104` 直接 `throw new EndpointDisabledException("LEGACY-DET-SIGN-...")` |
| SysUserPasswordHistoryController | POST/PUT/DELETE `/user/pwdhistory...` | `SysUserPasswordHistoryController.java:117/134/151` 直接 `throw new EndpointDisabledException("LEGACY-SYS-PWDHIST-...")` |
| ResBatchController | `PUT /resource/batch` | `ResBatchController.java:216-217` 抛 `ManagementGuardRejectException(PROTOCOL_UPGRADE_REQUIRED)` |
| ResBatchController | `DELETE /resource/batch/{batchIds}`、`PUT /resource/batch/exit` | `ResBatchController.java:229/241` 经 `legacyResourceEndpointGuard.rejectBatchExit/rejectBatchDelete` |
| ResProjectController | `DELETE /resource/project/{projectIds}` | `ResProjectController.java:198` 经 `legacyResourceEndpointGuard.rejectProjectDelete` |
| ResCultureController | `DELETE /resource/culture/{cultureIds}`、`PUT /resource/culture/exit` | `ResCultureController.java:705/723` 经 `legacyResourceEndpointGuard.rejectCultureDelete/rejectCultureExit`（400 `PROTOCOL_UPGRADE_REQUIRED`） |

> 说明：上表这些口在阶段 1 已归入 `ALREADY_DISABLED`，未进入 70 条 DISABLE 登记；本轮不重复登记，也不对其加标注。

## 2. 有已知调用方，改判 ADJUST（40 条）

以下每条都能在仓库内找到**页面实际调用**（页面导入 SDK 函数并发请求），按用户口径改判 ADJUST；它们不应加 `@Deprecated`，应接入 `ManagementGuardExecutor` 守卫。

| 序号 | 模块 | 控制器 | HTTP 方法与路径 | 调用方证据（文件:行） |
|---|---|---|---|---|
| 1 | M01 | SysDeptController | PUT /dept/updateSort | `dept-management/use-dept-list.ts:90` 实际调用 `deptApi.updateSort`；SDK `sdk-smp-api/src/system.ts:207-214` 发送 `PUT /system/dept/updateSort`（网关 StripPrefix=1 映射到 `/dept/updateSort`） |
| 3 | M01 | SysGroupLeaderController | DELETE /smp/labgroupleader/{groupIds} | SDK `modules/smp/labgroupleader.ts:39`；页面 `smp-labgroupleader/index.vue:294` 调用 `delLabgroupleader` |
| 4 | M01 | SysGroupLeaderController | POST /smp/labgroupleader/ | SDK `modules/smp/labgroupleader.ts:21`；页面 `smp-labgroupleader/index.vue:274` 调用 `addLabgroupleader` |
| 5 | M01 | SysGroupLeaderController | PUT /smp/labgroupleader/ | SDK `modules/smp/labgroupleader.ts:30`；页面 `smp-labgroupleader/index.vue:264` 调用 `updateLabgroupleader` |
| 6 | M01 | SysGroupMemberController | DELETE /smp/labgroupmember/{groupIds} | SDK `modules/smp/labgroupmember.ts:39`；页面 `smp-labgroupmember/index.vue:294` 调用 `delLabgroupmember` |
| 7 | M01 | SysGroupMemberController | POST /smp/labgroupmember/ | SDK `modules/smp/labgroupmember.ts:21`；页面 `smp-labgroupmember/index.vue:274` 调用 `addLabgroupmember` |
| 8 | M01 | SysGroupMemberController | PUT /smp/labgroupmember/ | SDK `modules/smp/labgroupmember.ts:30`；页面 `smp-labgroupmember/index.vue:264` 调用 `updateLabgroupmember` |
| 9 | M01 | SysMenuController | PUT /menu/updateSort | `menu-management/index.vue:557` 实际调用 `menuApi.sort`；SDK `sdk-smp-api/src/index.ts:410-417` 发送 `PUT /system/menu/updateSort`（网关映射 `/menu/updateSort`） |
| 10 | M02 | LabBenchReactorControllerChannelController | DELETE /lab/pumpchannel/{channelIds} | SDK `modules/lab/benchreactorcontrollerchannel.ts:39`（`delPumpchannel`）；页面 `lab-benchreactorcontrollerchannel/index.vue:424` 调用 |
| 11 | M02 | LabBenchReactorControllerChannelController | POST /lab/pumpchannel/ | SDK `modules/lab/benchreactorcontrollerchannel.ts:21`（`addPumpchannel`）；页面 `lab-benchreactorcontrollerchannel/index.vue:435` 调用 |
| 12 | M02 | LabBenchReactorControllerChannelController | PUT /lab/pumpchannel/ | SDK `modules/lab/benchreactorcontrollerchannel.ts:30`（`updatePumpchannel`）；页面 `lab-benchreactorcontrollerchannel/index.vue:454` 调用 |
| 26 | M03 | ResBatchLeaderController | DELETE /resource/batchleader/{batchIds} | SDK `modules/resource/batchleader.ts:39`；页面 `resource-batchleader/index.vue:292` 调用 `delBatchleader` |
| 27 | M03 | ResBatchLeaderController | POST /resource/batchleader/ | SDK `modules/resource/batchleader.ts:21`；页面 `resource-batchleader/index.vue:272` 调用 `addBatchleader` |
| 28 | M03 | ResBatchLeaderController | PUT /resource/batchleader/ | SDK `modules/resource/batchleader.ts:30`；页面 `resource-batchleader/index.vue:262` 调用 `updateBatchleader` |
| 29 | M03 | ResBatchMemberController | DELETE /resource/batchmember/{batchIds} | SDK `modules/resource/batchmember.ts:39`；页面 `resource-batchmember/index.vue:339` 调用 `delBatchmember` |
| 30 | M03 | ResBatchMemberController | POST /resource/batchmember/ | SDK `modules/resource/batchmember.ts:21`；页面 `resource-batchmember/index.vue:319` 调用 `addBatchmember` |
| 31 | M03 | ResBatchMemberController | PUT /resource/batchmember/ | SDK `modules/resource/batchmember.ts:30`；页面 `resource-batchmember/index.vue:309` 调用 `updateBatchmember` |
| 32 | M03 | ResCultureController | POST /resource/culture/ | `culture-management/culture-editor.vue:2035-2040` 新建培养调用 `cultureApi.save({cultureCode,...})`（无 cultureId）→ `sdk-smp-api/src/culture.ts:414-418` 发送 `POST /resource/culture`；后端 `ResCultureController.java:655-659` 仍为 `toAjax(insertResCulture)`，未停用 |
| 34 | M03 | ResCultureController | PUT /resource/culture/{cultureId}/members | `culture-management/index.vue:405` 组装 `cultureMemberApi`，`:1259` 成员对话框传 `:api="cultureMemberApi"`；`shared/member-dialog.vue:545` 调用 `props.api.saveMembers`；`sdk-smp-api/src/culture.ts:409-412` 发送 `PUT /resource/culture/{id}/members`；后端 `ResCultureController.java:590-595` 仍为 `toAjax(replaceCultureMembers)` |
| 35 | M03 | ResCultureMemberController | DELETE /resource/culturemember/{cultureIds} | SDK `modules/resource/culturemember.ts:39`；页面 `resource-culturemember/index.vue:339` 调用 `delCulturemember` |
| 36 | M03 | ResCultureMemberController | POST /resource/culturemember/ | SDK `modules/resource/culturemember.ts:21`；页面 `resource-culturemember/index.vue:319` 调用 `addCulturemember` |
| 37 | M03 | ResCultureMemberController | PUT /resource/culturemember/ | SDK `modules/resource/culturemember.ts:30`；页面 `resource-culturemember/index.vue:309` 调用 `updateCulturemember` |
| 39 | M03 | ResProjectController | PUT /resource/project/{projectId}/members | `project-management/index.vue:459-460` 成员对话框传 `:api="projectApi"`；`shared/member-dialog.vue:545` 调用 `props.api.saveMembers`；`sdk-smp-api/src/project.ts:134-138` 发送 `PUT /resource/project/{id}/members`；后端 `ResProjectController.java:155-159` 仍为 `toAjax(replaceProjectMembers)` |
| 40 | M03 | ResProjectLabController | DELETE /resource/projectlab/{projectIds} | SDK `modules/resource/projectlab.ts:39`；页面 `resource-projectlab/index.vue:292` 调用 `delProjectlab` |
| 41 | M03 | ResProjectLabController | POST /resource/projectlab/ | SDK `modules/resource/projectlab.ts:21`；页面 `resource-projectlab/index.vue:272` 调用 `addProjectlab` |
| 42 | M03 | ResProjectLabController | PUT /resource/projectlab/ | SDK `modules/resource/projectlab.ts:30`；页面 `resource-projectlab/index.vue:262` 调用 `updateProjectlab` |
| 43 | M03 | ResProjectLeaderController | DELETE /resource/projectleader/{projectIds} | SDK `modules/resource/projectleader.ts:39`；页面 `resource-projectleader/index.vue:292` 调用 `delProjectleader` |
| 44 | M03 | ResProjectLeaderController | POST /resource/projectleader/ | SDK `modules/resource/projectleader.ts:21`；页面 `resource-projectleader/index.vue:272` 调用 `addProjectleader` |
| 45 | M03 | ResProjectLeaderController | PUT /resource/projectleader/ | SDK `modules/resource/projectleader.ts:30`；页面 `resource-projectleader/index.vue:262` 调用 `updateProjectleader` |
| 46 | M03 | ResProjectMemberController | DELETE /resource/projectmember/{projectIds} | SDK `modules/resource/projectmember.ts:39`；页面 `resource-projectmember/index.vue:368` 调用 `delProjectmember` |
| 47 | M03 | ResProjectMemberController | POST /resource/projectmember/ | SDK `modules/resource/projectmember.ts:21`；页面 `resource-projectmember/index.vue:348` 调用 `addProjectmember` |
| 48 | M03 | ResProjectMemberController | PUT /resource/projectmember/ | SDK `modules/resource/projectmember.ts:30`；页面 `resource-projectmember/index.vue:338` 调用 `updateProjectmember` |
| 49 | M03 | ResProjectTagController | DELETE /resource/projecttag/{projectIds} | SDK `modules/resource/projecttag.ts:39`；页面 `resource-projecttag/index.vue:318` 调用 `delProjecttag` |
| 50 | M03 | ResProjectTagController | POST /resource/projecttag/ | SDK `modules/resource/projecttag.ts:21`；页面 `resource-projecttag/index.vue:298` 调用 `addProjecttag` |
| 51 | M03 | ResProjectTagController | PUT /resource/projecttag/ | SDK `modules/resource/projecttag.ts:30`；页面 `resource-projecttag/index.vue:288` 调用 `updateProjecttag` |
| 52 | M09 | AlarmNotifyReceiverController | DELETE /alarm/alarmNotifyReceiver/{receiverIds} | SDK `modules/alarm/alarmNotifyReceiver.ts:39`；页面 `alarm-alarm-notify-receiver/index.vue:371` 调用 `delAlarmNotifyReceiver` |
| 53 | M09 | AlarmNotifyReceiverController | POST /alarm/alarmNotifyReceiver/ | SDK `modules/alarm/alarmNotifyReceiver.ts:21`；页面 `alarm-alarm-notify-receiver/index.vue:351` 调用 `addAlarmNotifyReceiver` |
| 54 | M09 | AlarmNotifyReceiverController | PUT /alarm/alarmNotifyReceiver/ | SDK `modules/alarm/alarmNotifyReceiver.ts:30`；页面 `alarm-alarm-notify-receiver/index.vue:341` 调用 `updateAlarmNotifyReceiver` |
| 65 | M09 | LabOfflineAlarmConfigController | DELETE /lab/offlinealarm/{configIds} | SDK `modules/lab/offlinealarm.ts:16-21`；页面 `lab-offlinealarm/index.vue:277` 导入、`:484` 调用 `delOfflinealarm` |
| 67 | M09 | LabOfflineAlarmConfigController | POST /lab/offlinealarm/{labId}/batch-save | SDK `modules/lab/offlinealarm.ts:30-36`；页面 `lab-offlinealarm/index.vue:277` 导入、`:473` 调用 `batchSave` |

## 3. 存疑（10 条）

以下 SDK 仍保留旧写函数，但页面/Feign/测试均无实际调用。按用户要求**不剔除、不标注**，单列存疑，待确认后再决定（建议核对仓外调用方或确认旧 SDK 函数可直接废弃）。

| 序号 | 模块 | 控制器 | HTTP 方法与路径 | SDK 定义 | 页面未调用证据 |
|---|---|---|---|---|---|
| 16 | M02 | LabDetectorItemConfigController | POST /lab/detectorconfig/ | SDK `modules/lab/detectorconfig.ts:13`（`addDetectorconfig`）已定义；页面 `lab-detectorconfig/index.vue:164` 只解构 `batchSave`/`getAvailableItems`，全仓无该函数页面调用 | 全仓页面/Feign/测试未检索到实际调用 |
| 17 | M02 | LabDetectorItemConfigController | PUT /lab/detectorconfig/ | SDK `modules/lab/detectorconfig.ts:22`（`updateDetectorconfig`）已定义；页面 `lab-detectorconfig/index.vue:164` 只解构 `batchSave`/`getAvailableItems`，全仓无该函数页面调用 | 全仓页面/Feign/测试未检索到实际调用 |
| 18 | M02 | LabDownstreamDeviceController | PUT /lab/downstreamdevice/changeStatus | SDK `modules/lab/downstreamdevice.ts:85`（`changeStatus`）已定义；页面 `lab-downstreamdevice/index.vue:242-243` 只解构 `checkCanDelete`/`delLabdownstreamdevice`/`list...`，全仓无该模块 `changeStatus` 页面调用 | 全仓页面/Feign/测试未检索到实际调用 |
| 25 | M03 | ResBatchController | PUT /resource/batch/{batchId}/members | SDK `modules/resource/batch.ts:55-61`（`updateBatchMembers`）已定义；页面 `batch-management/batch-editor.vue:893` 只调用 `batchApi.save`（`PUT /resource/batch/{batchId}`），全仓无该函数页面调用，批次页未挂成员对话框 | 全仓页面/Feign/测试未检索到实际调用 |
| 33 | M03 | ResCultureController | PUT /resource/culture/ | SDK `modules/resource/culture.ts:38`（`updateCulture`）及 flat `culture.ts:414-418` 的 PUT 分支均已定义；页面仅在 `cultureId == null` 时调用 save（`culture-editor.vue:2035`），编辑走 `PATCH /resource/culture/{id}`（`:2045`），全仓无旧 PUT 页面调用 | 全仓页面/Feign/测试未检索到实际调用 |
| 38 | M03 | ResProjectController | PUT /resource/project/ | SDK `modules/resource/project.ts:30`（`updateProject`）已定义；页面 `project-editor.vue:318` 调用 `projectApi.save`，有 projectId 时发 `PUT /resource/project/{projectId}`（`src/project.ts:143-158`），不是旧 `PUT /resource/project`；全仓无 `updateProject` 页面调用 | 全仓页面/Feign/测试未检索到实际调用 |
| 59 | M09 | AlarmNotifyRuleController | PUT /alarm/alarmNotifyRule/config | SDK `modules/alarm/alarmNotifyRule.ts:34-40` 定义 `saveAlarmNotifyRuleConfig`；页面 `use-notify-rules.ts:10-11` 仅用 V2 `saveRuleConfigV2`，全仓无该函数页面调用 | 全仓页面/Feign/测试未检索到实际调用 |
| 63 | M09 | AlarmRecordController | POST /alarm/alarmRecord/handle | SDK `modules/alarm/alarmRecord.ts:22-28` 定义 `handleAlarm`；页面 `alarm-alarm-record/view.vue:213` 仅用 `handleAlarmV2`（`:340`），全仓无旧 `handleAlarm` 页面调用 | 全仓页面/Feign/测试未检索到实际调用 |
| 69 | M09 | LabStatusAlarmConfigController | POST /lab/statusalarm/batch-save | SDK `modules/lab/statusAlarm.ts:22-29`（`batchSaveAlarm`）/:36-42（`clearAlarm`）已定义；页面 `lab-statusalarm/index.vue:319` 只解构 `getStatusConfigV2/saveStatusConfigV2`，全仓无旧函数页面调用 | 全仓页面/Feign/测试未检索到实际调用 |
| 70 | M09 | LabStatusAlarmConfigController | POST /lab/statusalarm/clear | SDK `modules/lab/statusAlarm.ts:22-29`（`batchSaveAlarm`）/:36-42（`clearAlarm`）已定义；页面 `lab-statusalarm/index.vue:319` 只解构 `getStatusConfigV2/saveStatusConfigV2`，全仓无旧函数页面调用 | 全仓页面/Feign/测试未检索到实际调用 |

## 4. 可以标注（20 条）

既未停用、也无任何可达调用方，可在用户确认后进入标注阶段。

| 序号 | 模块 | 控制器 | HTTP 方法与路径 | 无调用方证据 |
|---|---|---|---|---|
| 2 | M01 | SysGroupController | PUT /smp/labgroup/{groupId}/members | 旧口只有 GET 读取：`modules/smp/labgroup.ts:21-26`；页面 `labgroup-management/labgroup-editor.vue:393` 改用 `labgroupApi.save`（`src/labgroup.ts:144-151` → `POST/PUT /smp/labgroup`），旧 `PUT /smp/labgroup/{groupId}/members` 无写调用 |
| 13 | M02 | LabBenchReactorControllerController | DELETE /lab/pumpconnection/{connectionIds} | 泵连接旧写无 SDK 写函数：`modules/lab/benchreactorcontroller.ts` 仅有 GET 与 M02-109/M02-110 新守卫写（`PUT .../controller/{id}`、`PUT .../reactor/{id}`）；`cultureDevice.ts:131-140` 仅 GET；全仓页面未检索到旧写路径 |
| 14 | M02 | LabBenchReactorControllerController | POST /lab/pumpconnection/ | 泵连接旧写无 SDK 写函数：`modules/lab/benchreactorcontroller.ts` 仅有 GET 与 M02-109/M02-110 新守卫写（`PUT .../controller/{id}`、`PUT .../reactor/{id}`）；`cultureDevice.ts:131-140` 仅 GET；全仓页面未检索到旧写路径 |
| 15 | M02 | LabBenchReactorControllerController | PUT /lab/pumpconnection/ | 泵连接旧写无 SDK 写函数：`modules/lab/benchreactorcontroller.ts` 仅有 GET 与 M02-109/M02-110 新守卫写（`PUT .../controller/{id}`、`PUT .../reactor/{id}`）；`cultureDevice.ts:131-140` 仅 GET；全仓页面未检索到旧写路径 |
| 19 | M02 | LabIntegratedReactorPumpController | DELETE /lab/integratedpump/{integratedIds} | 全仓 SDK/页面/Feign/测试未检索到 `/lab/integratedpump` 旧写路径；守卫版为 `PUT /lab/integratedreactor/{integratedId}` 聚合保存 `externalPumps` |
| 20 | M02 | LabIntegratedReactorPumpController | POST /lab/integratedpump/ | 全仓 SDK/页面/Feign/测试未检索到 `/lab/integratedpump` 旧写路径；守卫版为 `PUT /lab/integratedreactor/{integratedId}` 聚合保存 `externalPumps` |
| 21 | M02 | LabIntegratedReactorPumpController | PUT /lab/integratedpump/ | 全仓 SDK/页面/Feign/测试未检索到 `/lab/integratedpump` 旧写路径；守卫版为 `PUT /lab/integratedreactor/{integratedId}` 聚合保存 `externalPumps` |
| 22 | M02 | LabLabLeaderController | DELETE /lab/leader/{labIds} | 全仓 SDK/页面/Feign/测试未检索到 `/lab/leader` 旧写路径；实验室负责人由实验室守卫口维护 |
| 23 | M02 | LabLabLeaderController | POST /lab/leader/ | 全仓 SDK/页面/Feign/测试未检索到 `/lab/leader` 旧写路径；实验室负责人由实验室守卫口维护 |
| 24 | M02 | LabLabLeaderController | PUT /lab/leader/ | 全仓 SDK/页面/Feign/测试未检索到 `/lab/leader` 旧写路径；实验室负责人由实验室守卫口维护 |
| 55 | M09 | AlarmNotifyRuleController | DELETE /alarm/alarmNotifyRule/{ruleIds} | SDK `modules/alarm/alarmNotifyRule.ts` 仅有 GET 与 `saveAlarmNotifyRuleConfig`（`:34`，对应第 59 条）；页面 `alarm-alarm-notify-rule/use-notify-rules.ts:10-11` 使用 V2 `getRuleConfigV2/saveRuleConfigV2`；旧 DELETE/POST/PUT/with-receiver 无调用 |
| 56 | M09 | AlarmNotifyRuleController | POST /alarm/alarmNotifyRule/ | SDK `modules/alarm/alarmNotifyRule.ts` 仅有 GET 与 `saveAlarmNotifyRuleConfig`（`:34`，对应第 59 条）；页面 `alarm-alarm-notify-rule/use-notify-rules.ts:10-11` 使用 V2 `getRuleConfigV2/saveRuleConfigV2`；旧 DELETE/POST/PUT/with-receiver 无调用 |
| 57 | M09 | AlarmNotifyRuleController | POST /alarm/alarmNotifyRule/with-receiver | SDK `modules/alarm/alarmNotifyRule.ts` 仅有 GET 与 `saveAlarmNotifyRuleConfig`（`:34`，对应第 59 条）；页面 `alarm-alarm-notify-rule/use-notify-rules.ts:10-11` 使用 V2 `getRuleConfigV2/saveRuleConfigV2`；旧 DELETE/POST/PUT/with-receiver 无调用 |
| 58 | M09 | AlarmNotifyRuleController | PUT /alarm/alarmNotifyRule/ | SDK `modules/alarm/alarmNotifyRule.ts` 仅有 GET 与 `saveAlarmNotifyRuleConfig`（`:34`，对应第 59 条）；页面 `alarm-alarm-notify-rule/use-notify-rules.ts:10-11` 使用 V2 `getRuleConfigV2/saveRuleConfigV2`；旧 DELETE/POST/PUT/with-receiver 无调用 |
| 60 | M09 | AlarmNotifyRuleController | PUT /alarm/alarmNotifyRule/with-receiver | SDK `modules/alarm/alarmNotifyRule.ts` 仅有 GET 与 `saveAlarmNotifyRuleConfig`（`:34`，对应第 59 条）；页面 `alarm-alarm-notify-rule/use-notify-rules.ts:10-11` 使用 V2 `getRuleConfigV2/saveRuleConfigV2`；旧 DELETE/POST/PUT/with-receiver 无调用 |
| 61 | M09 | AlarmRecordController | DELETE /alarm/alarmRecord/{alarmIds} | SDK `modules/alarm/alarmRecord.ts` 仅有 GET 与 `handleAlarm`（`:22`，对应第 63 条）；页面 `alarm-alarm-record/view.vue:213` 使用 V2 `getAlarmRecordV2/handleAlarmV2`；旧 DELETE/POST/PUT 无调用 |
| 62 | M09 | AlarmRecordController | POST /alarm/alarmRecord/ | SDK `modules/alarm/alarmRecord.ts` 仅有 GET 与 `handleAlarm`（`:22`，对应第 63 条）；页面 `alarm-alarm-record/view.vue:213` 使用 V2 `getAlarmRecordV2/handleAlarmV2`；旧 DELETE/POST/PUT 无调用 |
| 64 | M09 | AlarmRecordController | PUT /alarm/alarmRecord/ | SDK `modules/alarm/alarmRecord.ts` 仅有 GET 与 `handleAlarm`（`:22`，对应第 63 条）；页面 `alarm-alarm-record/view.vue:213` 使用 V2 `getAlarmRecordV2/handleAlarmV2`；旧 DELETE/POST/PUT 无调用 |
| 66 | M09 | LabOfflineAlarmConfigController | POST /lab/offlinealarm/ | SDK `modules/lab/offlinealarm.ts` 仅有 list/delete/check/batch-save（`:7/:16/:23/:30`），无 POST/PUT 写函数；页面仅调用 `batchSave`/`delOfflinealarm` |
| 68 | M09 | LabOfflineAlarmConfigController | PUT /lab/offlinealarm/ | SDK `modules/lab/offlinealarm.ts` 仅有 list/delete/check/batch-save（`:7/:16/:23/:30`），无 POST/PUT 写函数；页面仅调用 `batchSave`/`delOfflinealarm` |

## 5. 标注阶段分批建议（M01 → M02 → M03 → M09）

| 模块 | 可标注 | 存疑 | 改判 ADJUST | 核查后 DISABLE | 风险点 |
|---|---|---|---|---|---|
| M01 | 1 | 0 | 8 | 1 | 实验组成员旧 members PUT 无写调用，但实验组保存已走新版 `/smp/labgroup`；标注需确认没有仓外脚本 |
| M02 | 9 | 3 | 3 | 12 | 检测设备旧 add/update、其他设备 changeStatus 仅剩 SDK 死封装；泵连接/集成泵/实验室负责人旧写无调用，但泵相关需求当前仍在变更，标注后需防止被误当成"已废弃功能" |
| M03 | 0 | 3 | 24 | 3 | 本模块改判 24 条，只剩 3 条存疑；项目/批次/培养页面大量仍调用旧成员/负责人/标签写口，标注阶段必须逐条避开这些 ADJUST 项 |
| M09 | 10 | 4 | 5 | 14 | 告警接收人 3 条仍有页面调用（已改判），旧告警规则/记录多数仅剩 SDK 死封装；离线告警本身在需求中"搁置"，标注措辞需与搁置状态一致 |

> 标注批次建议按「可标注」条数执行：M01 1 条 → M02 9 条 → M03 0 条（本模块无可标注项，跳过）→ M09 10 条，共 20 条。
> 若存疑 10 条在标注前被确认为无调用方，可追加到对应模块批次；若确认仍需保留，则改判 ADJUST 或 REUSE，不得直接标注。
> 每批完成后执行 `mvn -pl futurefab-modules/futurefab-system -am test`，并核对 `git diff` 仅含 `@Deprecated` 与注释；本轮尚未执行任何标注。

## 6. 验证口径与未验证事项

- 已做：静态源码检索（Controller 方法体、SDK 函数定义、页面导入/调用点、Feign/测试/配置路径）；CSV/摘要/登记表统计同步。
- 未做：HTTP 请求、浏览器操作、SQL 执行、Java 编译/测试、外部系统联调。
- 因此本轮结论仅支持「静态检查通过」，不能表述为接口已停用、已改判生效或已标注完成。
- 本轮未修改任何 Java 代码、未 commit/push，也未触碰 M07 文档、`tools/` 与设备接口清单相关文件。
