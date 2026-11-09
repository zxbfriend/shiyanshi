# 旧 CRUD 写端点处置登记表（阶段 2 · 方案 A：纯标记）

> 本表是阶段 2 的执行依据，也是将来撤销标注时的找回依据。
> 方案 A 定义：对判定为 DISABLE 的写端点，只在方法上加 `@Deprecated`，并在注释/Javadoc 写明处置编号、判定依据、对应 V5.1 章节，以及“如 V5.1 设计确认仍需保留，可直接撤除标注恢复”。
> 行为完全不变：不抛异常、不改调用链、不改返回值、不改权限注解。
> 需求基线：`docs/需求说明书V5.1-1030_md/` 正文 + V4.0《需求澄清决策记录》（见 `docs/需求基线说明.md` 第 3 节）。
> 统计口径（2026-11-04 去重核查后）：本表登记的原 70 条 DISABLE 中，**可标注 20 / 存疑 10 / 改判 ADJUST 40**，当前保留 DISABLE **30**；全量清单为 **DISABLE 30 / ADJUST 82 / 待确认 10，合计 122**。历史轨迹：68/32/22 → 72/39/11 → 73/39/10 → 70/42/10 → **30/82/10**。核查方法、逐条调用方证据与存疑清单见 `docs/调查-旧CRUD写端点去重核查.md`。
> 验证口径：静态检查通过；另对 V5.1 原版 docx 做只读删除线解析（`word/document.xml` 的 `w:strike` / `w:dstrike`）；未执行 HTTP、浏览器、SQL 或 Java 改动。

## 1. 处置编号规则

- 格式：`LEGACY-<模块>-<资源>-<动作>`，逐端点唯一。
- 模块：M01 系统管理、M02 实验室与资源、M03 项目与培养、M09 告警与通知。
- 资源：由主表名推断，统一大写短横线；同表多入口用路径后缀区分（如 `-WITH-RECEIVER`、`-BATCH-SAVE`、`-MEMBERS`、`-UPDATE-SORT`）。
- 动作：POST / PUT / DELETE，必要时附路径语义后缀。
- 编号由本表登记，CSV 的「依据」列同步追加；CSV 列结构不变，不新增列。

## 2. 逐条登记（原 70 条 DISABLE；核查后 30 条保留、40 条改判 ADJUST）

> 核查状态：`可标注` / `存疑` / `改判 ADJUST`；40 条改判项保留在本表用于追溯，但不再进入标注阶段。
> 「V5.1 依据（docx 段落级）」列是用 `docs/需求说明书V5.1-1030.docx` 的 `word/document.xml` 只读解析所得。段落序号为 `w:p` 在文档中的顺序下标（从 0 开始），docx 无“行号”，故统一用段落号。
> 「依据状态」：`依据成立` / `章节已删除（docx 划线）` / `章节不存在` / `无法判定`。状态仅描述依据核验结果；原依据不成立的 3 条 DetectionRule 已改判 ADJUST，见 3.3 追溯记录。

| 序号 | 控制器 | HTTP 方法 与路径 | 权限码 | 涉及表 | 处置编号 | V5.1 依据（docx 段落级） | 依据状态 | 标注状态 | 恢复方法 |
|---|---|---|---|---|---|---|---|---|---|
| 1 | SysDeptController | PUT /dept/updateSort | system:dept:edit | sys_dept | LEGACY-M01-DEPT-PUT-UPDATE-SORT | 01-基本设置.md 段落 296「部门管理①」；标题删除线 run=0；正文段落 297-343 共 39 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 2 | SysGroupController | PUT /smp/labgroup/{groupId}/members | system:labgroup:edit | sys_group | LEGACY-M01-LAB-GROUP-PUT-MEMBERS | 01-基本设置.md 段落 344「实验组①」；标题删除线 run=0；正文段落 345-381 共 32 段，其中 0 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 3 | SysGroupLeaderController | DELETE /smp/labgroupleader/{groupIds} | system:labgroupleader:remove | sys_group_leader | LEGACY-M01-LAB-GROUP-LEADER-DELETE | 01-基本设置.md 段落 344「实验组①」；标题删除线 run=0；正文段落 345-381 共 32 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 4 | SysGroupLeaderController | POST /smp/labgroupleader/ | system:labgroupleader:add | sys_group_leader | LEGACY-M01-LAB-GROUP-LEADER-POST | 01-基本设置.md 段落 344「实验组①」；标题删除线 run=0；正文段落 345-381 共 32 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 5 | SysGroupLeaderController | PUT /smp/labgroupleader/ | system:labgroupleader:edit | sys_group_leader | LEGACY-M01-LAB-GROUP-LEADER-PUT | 01-基本设置.md 段落 344「实验组①」；标题删除线 run=0；正文段落 345-381 共 32 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 6 | SysGroupMemberController | DELETE /smp/labgroupmember/{groupIds} | system:labgroupmember:remove | sys_group_member | LEGACY-M01-LAB-GROUP-MEMBER-DELETE | 01-基本设置.md 段落 344「实验组①」；标题删除线 run=0；正文段落 345-381 共 32 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 7 | SysGroupMemberController | POST /smp/labgroupmember/ | system:labgroupmember:add | sys_group_member | LEGACY-M01-LAB-GROUP-MEMBER-POST | 01-基本设置.md 段落 344「实验组①」；标题删除线 run=0；正文段落 345-381 共 32 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 8 | SysGroupMemberController | PUT /smp/labgroupmember/ | system:labgroupmember:edit | sys_group_member | LEGACY-M01-LAB-GROUP-MEMBER-PUT | 01-基本设置.md 段落 344「实验组①」；标题删除线 run=0；正文段落 345-381 共 32 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 9 | SysMenuController | PUT /menu/updateSort | system:menu:edit | sys_menu | LEGACY-M01-MENU-PUT-UPDATE-SORT | 01-基本设置.md 段落 382「功能管理①」；标题删除线 run=0；正文段落 383-439 共 53 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 10 | LabBenchReactorControllerChannelController | DELETE /lab/pumpchannel/{channelIds} | lab:pumpchannel:remove | lab_bench_reactor_controller_channel | LEGACY-M02-PUMP-CHANNEL-DELETE | 02-实验室设置.md 段落 841「泵的默认连接①」；标题删除线 run=0；正文段落 842-873 共 30 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 11 | LabBenchReactorControllerChannelController | POST /lab/pumpchannel/ | lab:pumpchannel:add | lab_bench_reactor_controller_channel | LEGACY-M02-PUMP-CHANNEL-POST | 02-实验室设置.md 段落 841「泵的默认连接①」；标题删除线 run=0；正文段落 842-873 共 30 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 12 | LabBenchReactorControllerChannelController | PUT /lab/pumpchannel/ | lab:pumpchannel:edit | lab_bench_reactor_controller_channel | LEGACY-M02-PUMP-CHANNEL-PUT | 02-实验室设置.md 段落 841「泵的默认连接①」；标题删除线 run=0；正文段落 842-873 共 30 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 13 | LabBenchReactorControllerController | DELETE /lab/pumpconnection/{connectionIds} | lab:pumpconnection:remove | lab_bench_reactor_controller | LEGACY-M02-PUMP-CONNECTION-DELETE | 02-实验室设置.md 段落 841「泵的默认连接①」；标题删除线 run=0；正文段落 842-873 共 30 段，其中 0 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 14 | LabBenchReactorControllerController | POST /lab/pumpconnection/ | lab:pumpconnection:add | lab_bench_reactor_controller | LEGACY-M02-PUMP-CONNECTION-POST | 02-实验室设置.md 段落 841「泵的默认连接①」；标题删除线 run=0；正文段落 842-873 共 30 段，其中 0 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 15 | LabBenchReactorControllerController | PUT /lab/pumpconnection/ | lab:pumpconnection:edit | lab_bench_reactor_controller | LEGACY-M02-PUMP-CONNECTION-PUT | 02-实验室设置.md 段落 841「泵的默认连接①」；标题删除线 run=0；正文段落 842-873 共 30 段，其中 0 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 16 | LabDetectorItemConfigController | POST /lab/detectorconfig/ | lab:detectorconfig:add | lab_detector_item_config | LEGACY-M02-DETECTOR-ITEM-CONFIG-POST | 02-实验室设置.md 段落 1028「检测设备①」；标题删除线 run=0；正文段落 1029-1083 共 45 段，其中 0 段带删除线 | 依据成立 | 存疑（暂不标注） | 暂不标注；确认 SDK 旧函数与仓外调用方后再定 |
| 17 | LabDetectorItemConfigController | PUT /lab/detectorconfig/ | lab:labdetector:config lab:detectorconfig:edit | lab_detector_item_config | LEGACY-M02-DETECTOR-ITEM-CONFIG-PUT | 02-实验室设置.md 段落 1028「检测设备①」；标题删除线 run=0；正文段落 1029-1083 共 45 段，其中 0 段带删除线 | 依据成立 | 存疑（暂不标注） | 暂不标注；确认 SDK 旧函数与仓外调用方后再定 |
| 18 | LabDownstreamDeviceController | PUT /lab/downstreamdevice/changeStatus | lab:downstreamDevice:edit | lab_downstream_device | LEGACY-M02-DOWNSTREAM-DEVICE-PUT-CHANGE-STATUS | 02-实验室设置.md 段落 1248「其他设备」；标题删除线 run=0；正文段落 1249-1372 共 94 段，其中 2 段带删除线 | 依据成立 | 存疑（暂不标注） | 暂不标注；确认 SDK 旧函数与仓外调用方后再定 |
| 19 | LabIntegratedReactorPumpController | DELETE /lab/integratedpump/{integratedIds} | lab:integratedpump:remove | lab_integrated_reactor_pump | LEGACY-M02-INTEGRATED-PUMP-DELETE | 02-实验室设置.md 段落 1084「集成反应器①」；标题删除线 run=0；正文段落 1085-1150 共 53 段，其中 2 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 20 | LabIntegratedReactorPumpController | POST /lab/integratedpump/ | lab:integratedpump:add | lab_integrated_reactor_pump | LEGACY-M02-INTEGRATED-PUMP-POST | 02-实验室设置.md 段落 1084「集成反应器①」；标题删除线 run=0；正文段落 1085-1150 共 53 段，其中 2 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 21 | LabIntegratedReactorPumpController | PUT /lab/integratedpump/ | lab:integratedpump:edit | lab_integrated_reactor_pump | LEGACY-M02-INTEGRATED-PUMP-PUT | 02-实验室设置.md 段落 1084「集成反应器①」；标题删除线 run=0；正文段落 1085-1150 共 53 段，其中 2 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 22 | LabLabLeaderController | DELETE /lab/leader/{labIds} | lab:leader:remove | lab_lab_leader | LEGACY-M02-LAB-LEADER-DELETE | 02-实验室设置.md 段落 717「实验室管理①（3.1）（3.3）」；标题删除线 run=0；正文段落 718-794 共 66 段，其中 1 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 23 | LabLabLeaderController | POST /lab/leader/ | lab:leader:add | lab_lab_leader | LEGACY-M02-LAB-LEADER-POST | 02-实验室设置.md 段落 717「实验室管理①（3.1）（3.3）」；标题删除线 run=0；正文段落 718-794 共 66 段，其中 1 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 24 | LabLabLeaderController | PUT /lab/leader/ | lab:leader:edit | lab_lab_leader | LEGACY-M02-LAB-LEADER-PUT | 02-实验室设置.md 段落 717「实验室管理①（3.1）（3.3）」；标题删除线 run=0；正文段落 718-794 共 66 段，其中 1 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 25 | ResBatchController | PUT /resource/batch/{batchId}/members | resource:batch:edit | res_batch_member | LEGACY-M03-BATCH-MEMBER-PUT-MEMBERS | 04-项目设置①.md 段落 2066「批次管理①（3.2）（4.1调整）（4.2调整）」；标题删除线 run=0；正文段落 2067-2207 共 110 段，其中 9 段带删除线 | 依据成立 | 存疑（暂不标注） | 暂不标注；确认 SDK 旧函数与仓外调用方后再定 |
| 26 | ResBatchLeaderController | DELETE /resource/batchleader/{batchIds} | resource:batchleader:remove | res_batch_leader | LEGACY-M03-BATCH-LEADER-DELETE | 04-项目设置①.md 段落 2066「批次管理①（3.2）（4.1调整）（4.2调整）」；标题删除线 run=0；正文段落 2067-2207 共 110 段，其中 9 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 27 | ResBatchLeaderController | POST /resource/batchleader/ | resource:batchleader:add | res_batch_leader | LEGACY-M03-BATCH-LEADER-POST | 04-项目设置①.md 段落 2066「批次管理①（3.2）（4.1调整）（4.2调整）」；标题删除线 run=0；正文段落 2067-2207 共 110 段，其中 9 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 28 | ResBatchLeaderController | PUT /resource/batchleader/ | resource:batchleader:edit | res_batch_leader | LEGACY-M03-BATCH-LEADER-PUT | 04-项目设置①.md 段落 2066「批次管理①（3.2）（4.1调整）（4.2调整）」；标题删除线 run=0；正文段落 2067-2207 共 110 段，其中 9 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 29 | ResBatchMemberController | DELETE /resource/batchmember/{batchIds} | resource:batchmember:remove | res_batch_member | LEGACY-M03-BATCH-MEMBER-DELETE | 04-项目设置①.md 段落 2066「批次管理①（3.2）（4.1调整）（4.2调整）」；标题删除线 run=0；正文段落 2067-2207 共 110 段，其中 9 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 30 | ResBatchMemberController | POST /resource/batchmember/ | resource:batchmember:add | res_batch_member | LEGACY-M03-BATCH-MEMBER-POST | 04-项目设置①.md 段落 2066「批次管理①（3.2）（4.1调整）（4.2调整）」；标题删除线 run=0；正文段落 2067-2207 共 110 段，其中 9 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 31 | ResBatchMemberController | PUT /resource/batchmember/ | resource:batchmember:edit | res_batch_member | LEGACY-M03-BATCH-MEMBER-PUT | 04-项目设置①.md 段落 2066「批次管理①（3.2）（4.1调整）（4.2调整）」；标题删除线 run=0；正文段落 2067-2207 共 110 段，其中 9 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 32 | ResCultureController | POST /resource/culture/ | resource:culture:add | res_culture | LEGACY-M03-CULTURE-POST | 04-项目设置①.md 段落 2209「培养基础管理①（3.2）（3.3）（5.0调整）」；标题删除线 run=0；正文段落 2210-2317 共 87 段，其中 10 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 33 | ResCultureController | PUT /resource/culture/ | resource:culture:edit | res_culture | LEGACY-M03-CULTURE-PUT | 04-项目设置①.md 段落 2209「培养基础管理①（3.2）（3.3）（5.0调整）」；标题删除线 run=0；正文段落 2210-2317 共 87 段，其中 10 段带删除线 | 依据成立 | 存疑（暂不标注） | 暂不标注；确认 SDK 旧函数与仓外调用方后再定 |
| 34 | ResCultureController | PUT /resource/culture/{cultureId}/members | resource:culture:edit | res_culture_member | LEGACY-M03-CULTURE-MEMBER-PUT-MEMBERS | 04-项目设置①.md 段落 2209「培养基础管理①（3.2）（3.3）（5.0调整）」；标题删除线 run=0；正文段落 2210-2317 共 87 段，其中 10 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 35 | ResCultureMemberController | DELETE /resource/culturemember/{cultureIds} | resource:culturemember:remove | res_culture_member | LEGACY-M03-CULTURE-MEMBER-DELETE | 04-项目设置①.md 段落 2209「培养基础管理①（3.2）（3.3）（5.0调整）」；标题删除线 run=0；正文段落 2210-2317 共 87 段，其中 10 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 36 | ResCultureMemberController | POST /resource/culturemember/ | resource:culturemember:add | res_culture_member | LEGACY-M03-CULTURE-MEMBER-POST | 04-项目设置①.md 段落 2209「培养基础管理①（3.2）（3.3）（5.0调整）」；标题删除线 run=0；正文段落 2210-2317 共 87 段，其中 10 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 37 | ResCultureMemberController | PUT /resource/culturemember/ | resource:culturemember:edit | res_culture_member | LEGACY-M03-CULTURE-MEMBER-PUT | 04-项目设置①.md 段落 2209「培养基础管理①（3.2）（3.3）（5.0调整）」；标题删除线 run=0；正文段落 2210-2317 共 87 段，其中 10 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 38 | ResProjectController | PUT /resource/project/ | resource:project:edit | res_project | LEGACY-M03-PROJECT-PUT | 04-项目设置①.md 段落 2008「项目管理①」；标题删除线 run=0；正文段落 2009-2065 共 42 段，其中 0 段带删除线 | 依据成立 | 存疑（暂不标注） | 暂不标注；确认 SDK 旧函数与仓外调用方后再定 |
| 39 | ResProjectController | PUT /resource/project/{projectId}/members | resource:project:edit | res_project_member | LEGACY-M03-PROJECT-MEMBER-PUT-MEMBERS | 04-项目设置①.md 段落 2008「项目管理①」；标题删除线 run=0；正文段落 2009-2065 共 42 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 40 | ResProjectLabController | DELETE /resource/projectlab/{projectIds} | resource:projectlab:remove | res_project_lab | LEGACY-M03-PROJECT-LAB-DELETE | 04-项目设置①.md 段落 2008「项目管理①」；标题删除线 run=0；正文段落 2009-2065 共 42 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 41 | ResProjectLabController | POST /resource/projectlab/ | resource:projectlab:add | res_project_lab | LEGACY-M03-PROJECT-LAB-POST | 04-项目设置①.md 段落 2008「项目管理①」；标题删除线 run=0；正文段落 2009-2065 共 42 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 42 | ResProjectLabController | PUT /resource/projectlab/ | resource:projectlab:edit | res_project_lab | LEGACY-M03-PROJECT-LAB-PUT | 04-项目设置①.md 段落 2008「项目管理①」；标题删除线 run=0；正文段落 2009-2065 共 42 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 43 | ResProjectLeaderController | DELETE /resource/projectleader/{projectIds} | resource:projectleader:remove | res_project_leader | LEGACY-M03-PROJECT-LEADER-DELETE | 04-项目设置①.md 段落 2008「项目管理①」；标题删除线 run=0；正文段落 2009-2065 共 42 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 44 | ResProjectLeaderController | POST /resource/projectleader/ | resource:projectleader:add | res_project_leader | LEGACY-M03-PROJECT-LEADER-POST | 04-项目设置①.md 段落 2008「项目管理①」；标题删除线 run=0；正文段落 2009-2065 共 42 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 45 | ResProjectLeaderController | PUT /resource/projectleader/ | resource:projectleader:edit | res_project_leader | LEGACY-M03-PROJECT-LEADER-PUT | 04-项目设置①.md 段落 2008「项目管理①」；标题删除线 run=0；正文段落 2009-2065 共 42 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 46 | ResProjectMemberController | DELETE /resource/projectmember/{projectIds} | resource:projectmember:remove | res_project_member | LEGACY-M03-PROJECT-MEMBER-DELETE | 04-项目设置①.md 段落 2008「项目管理①」；标题删除线 run=0；正文段落 2009-2065 共 42 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 47 | ResProjectMemberController | POST /resource/projectmember/ | resource:projectmember:add | res_project_member | LEGACY-M03-PROJECT-MEMBER-POST | 04-项目设置①.md 段落 2008「项目管理①」；标题删除线 run=0；正文段落 2009-2065 共 42 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 48 | ResProjectMemberController | PUT /resource/projectmember/ | resource:projectmember:edit | res_project_member | LEGACY-M03-PROJECT-MEMBER-PUT | 04-项目设置①.md 段落 2008「项目管理①」；标题删除线 run=0；正文段落 2009-2065 共 42 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 49 | ResProjectTagController | DELETE /resource/projecttag/{projectIds} | resource:projecttag:remove | res_project_tag | LEGACY-M03-PROJECT-TAG-DELETE | 04-项目设置①.md 段落 2008「项目管理①」；标题删除线 run=0；正文段落 2009-2065 共 42 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 50 | ResProjectTagController | POST /resource/projecttag/ | resource:projecttag:add | res_project_tag | LEGACY-M03-PROJECT-TAG-POST | 04-项目设置①.md 段落 2008「项目管理①」；标题删除线 run=0；正文段落 2009-2065 共 42 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 51 | ResProjectTagController | PUT /resource/projecttag/ | resource:projecttag:edit | res_project_tag | LEGACY-M03-PROJECT-TAG-PUT | 04-项目设置①.md 段落 2008「项目管理①」；标题删除线 run=0；正文段落 2009-2065 共 42 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 52 | AlarmNotifyReceiverController | DELETE /alarm/alarmNotifyReceiver/{receiverIds} | alarm:alarmNotifyReceiver:remove | alarm_notify_receiver | LEGACY-M09-ALARM-NOTIFY-RECEIVER-DELETE | 02-实验室设置.md 段落 1606「告警设置②（4.1调整）」；标题删除线 run=0；正文段落 1607-1639 共 31 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 53 | AlarmNotifyReceiverController | POST /alarm/alarmNotifyReceiver/ | alarm:alarmNotifyReceiver:add | alarm_notify_receiver | LEGACY-M09-ALARM-NOTIFY-RECEIVER-POST | 02-实验室设置.md 段落 1606「告警设置②（4.1调整）」；标题删除线 run=0；正文段落 1607-1639 共 31 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 54 | AlarmNotifyReceiverController | PUT /alarm/alarmNotifyReceiver/ | alarm:alarmNotifyReceiver:edit | alarm_notify_receiver | LEGACY-M09-ALARM-NOTIFY-RECEIVER-PUT | 02-实验室设置.md 段落 1606「告警设置②（4.1调整）」；标题删除线 run=0；正文段落 1607-1639 共 31 段，其中 0 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 55 | AlarmNotifyRuleController | DELETE /alarm/alarmNotifyRule/{ruleIds} | alarm:alarmNotifyRule:remove | alarm_notify_rule | LEGACY-M09-ALARM-NOTIFY-RULE-DELETE | 02-实验室设置.md 段落 1606「告警设置②（4.1调整）」；标题删除线 run=0；正文段落 1607-1639 共 31 段，其中 0 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 56 | AlarmNotifyRuleController | POST /alarm/alarmNotifyRule/ | alarm:alarmNotifyRule:add | alarm_notify_rule | LEGACY-M09-ALARM-NOTIFY-RULE-POST | 02-实验室设置.md 段落 1606「告警设置②（4.1调整）」；标题删除线 run=0；正文段落 1607-1639 共 31 段，其中 0 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 57 | AlarmNotifyRuleController | POST /alarm/alarmNotifyRule/with-receiver | alarm:alarmNotifyRule:add | alarm_notify_rule | LEGACY-M09-ALARM-NOTIFY-RULE-POST-WITH-RECEIVER | 02-实验室设置.md 段落 1606「告警设置②（4.1调整）」；标题删除线 run=0；正文段落 1607-1639 共 31 段，其中 0 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 58 | AlarmNotifyRuleController | PUT /alarm/alarmNotifyRule/ | alarm:alarmNotifyRule:edit | alarm_notify_rule | LEGACY-M09-ALARM-NOTIFY-RULE-PUT | 02-实验室设置.md 段落 1606「告警设置②（4.1调整）」；标题删除线 run=0；正文段落 1607-1639 共 31 段，其中 0 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 59 | AlarmNotifyRuleController | PUT /alarm/alarmNotifyRule/config | alarm:alarmNotifyRule:edit | alarm_notify_rule | LEGACY-M09-ALARM-NOTIFY-RULE-PUT-CONFIG | 02-实验室设置.md 段落 1606「告警设置②（4.1调整）」；标题删除线 run=0；正文段落 1607-1639 共 31 段，其中 0 段带删除线 | 依据成立 | 存疑（暂不标注） | 暂不标注；确认 SDK 旧函数与仓外调用方后再定 |
| 60 | AlarmNotifyRuleController | PUT /alarm/alarmNotifyRule/with-receiver | alarm:alarmNotifyRule:edit | alarm_notify_rule | LEGACY-M09-ALARM-NOTIFY-RULE-PUT-WITH-RECEIVER | 02-实验室设置.md 段落 1606「告警设置②（4.1调整）」；标题删除线 run=0；正文段落 1607-1639 共 31 段，其中 0 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 61 | AlarmRecordController | DELETE /alarm/alarmRecord/{alarmIds} | alarm:alarmRecord:remove | alarm_record | LEGACY-M09-ALARM-RECORD-DELETE | 02-实验室设置.md 段落 1606「告警设置②（4.1调整）」；标题删除线 run=0；正文段落 1607-1639 共 31 段，其中 0 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 62 | AlarmRecordController | POST /alarm/alarmRecord/ | alarm:alarmRecord:add | alarm_record | LEGACY-M09-ALARM-RECORD-POST | 02-实验室设置.md 段落 1606「告警设置②（4.1调整）」；标题删除线 run=0；正文段落 1607-1639 共 31 段，其中 0 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 63 | AlarmRecordController | POST /alarm/alarmRecord/handle | alarm:alarmRecord:handle | alarm_record | LEGACY-M09-ALARM-RECORD-POST-HANDLE | 02-实验室设置.md 段落 1606「告警设置②（4.1调整）」；标题删除线 run=0；正文段落 1607-1639 共 31 段，其中 0 段带删除线 | 依据成立 | 存疑（暂不标注） | 暂不标注；确认 SDK 旧函数与仓外调用方后再定 |
| 64 | AlarmRecordController | PUT /alarm/alarmRecord/ | alarm:alarmRecord:edit | alarm_record | LEGACY-M09-ALARM-RECORD-PUT | 02-实验室设置.md 段落 1606「告警设置②（4.1调整）」；标题删除线 run=0；正文段落 1607-1639 共 31 段，其中 0 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 65 | LabOfflineAlarmConfigController | DELETE /lab/offlinealarm/{configIds} | lab:offlinealarm:remove | lab_offline_alarm_config | LEGACY-M09-LAB-OFFLINE-ALARM-CONFIG-DELETE | 02-实验室设置.md 段落 1373「离线告警设置   ①（搁置）（在反应器详情页面实现）」；标题删除线 run=0；正文段落 1374-1392 共 17 段，其中 1 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 66 | LabOfflineAlarmConfigController | POST /lab/offlinealarm/ | lab:offlinealarm:add | lab_offline_alarm_config | LEGACY-M09-LAB-OFFLINE-ALARM-CONFIG-POST | 02-实验室设置.md 段落 1373「离线告警设置   ①（搁置）（在反应器详情页面实现）」；标题删除线 run=0；正文段落 1374-1392 共 17 段，其中 1 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 67 | LabOfflineAlarmConfigController | POST /lab/offlinealarm/{labId}/batch-save | lab:offlinealarm:edit | lab_offline_alarm_config | LEGACY-M09-LAB-OFFLINE-ALARM-CONFIG-POST-BATCH-SAVE | 02-实验室设置.md 段落 1373「离线告警设置   ①（搁置）（在反应器详情页面实现）」；标题删除线 run=0；正文段落 1374-1392 共 17 段，其中 1 段带删除线 | 依据成立 | 改判 ADJUST（不标注） | 不适用（改判 ADJUST，按守卫写接入；不再加 @Deprecated） |
| 68 | LabOfflineAlarmConfigController | PUT /lab/offlinealarm/ | lab:offlinealarm:edit | lab_offline_alarm_config | LEGACY-M09-LAB-OFFLINE-ALARM-CONFIG-PUT | 02-实验室设置.md 段落 1373「离线告警设置   ①（搁置）（在反应器详情页面实现）」；标题删除线 run=0；正文段落 1374-1392 共 17 段，其中 1 段带删除线 | 依据成立 | 可标注（待确认） | 撤除 @Deprecated 与处置注释即可恢复（标注阶段执行） |
| 69 | LabStatusAlarmConfigController | POST /lab/statusalarm/batch-save | lab:statusalarm:edit | lab_status_alarm_config | LEGACY-M09-LAB-STATUS-ALARM-CONFIG-POST-BATCH-SAVE | 02-实验室设置.md 段落 1606「告警设置②（4.1调整）」；标题删除线 run=0；正文段落 1607-1639 共 31 段，其中 0 段带删除线 | 依据成立 | 存疑（暂不标注） | 暂不标注；确认 SDK 旧函数与仓外调用方后再定 |
| 70 | LabStatusAlarmConfigController | POST /lab/statusalarm/clear | lab:statusalarm:edit | lab_status_alarm_config | LEGACY-M09-LAB-STATUS-ALARM-CONFIG-POST-CLEAR | 02-实验室设置.md 段落 1606「告警设置②（4.1调整）」；标题删除线 run=0；正文段落 1607-1639 共 31 段，其中 0 段带删除线 | 依据成立 | 存疑（暂不标注） | 暂不标注；确认 SDK 旧函数与仓外调用方后再定 |

## 3. 按模块分布

| 模块 | 原 DISABLE | 改判 ADJUST | 可标注 | 存疑 | 核查后 DISABLE |
|---|---|---|---|---|---|
| M01 | 9 | 8 | 1 | 0 | 1 |
| M02 | 15 | 3 | 9 | 3 | 12 |
| M03 | 27 | 24 | 0 | 3 | 3 |
| M09 | 19 | 5 | 10 | 4 | 14 |
| **合计** | **70** | **40** | **20** | **10** | **30** |

## 3.1 依据核对结果（70 条回原版 docx）

| 依据状态 | 条数 |
|---|---|
| 依据成立 | 70 |
| 章节已删除（docx 划线） | 0 |
| 章节不存在 | 0 |
| 无法判定 | 0 |
| **合计** | **70** |

## 3.2 「依据已补全」覆盖率

| 证据粒度 | 条数 | 说明 |
|---|---|---|
| 已给到段落级证据 | 70 | 全部条目均含 docx 段落号（章节标题段落号 + 正文区间/划线统计，或引用段落号） |
| 仍只能章节级 | 0 | 无 |
| 无法判定 | 0 | 无 |

> 覆盖率结论：70/70 已从“纯章节级引用”升级为“章节名 + docx 段落号（+ 标题/正文划线统计）”；剩余全部依据成立。

## 3.3 依据不成立清单（本次为空，3 条已改判移出）

> 原 3 条 `DetectionRuleController` 因依据状态为「章节不存在」，已按 2026-11-04 用户决策「检测规则功能保留、下一期使用」改判 ADJUST 并移出本表，不再属于 DISABLE 登记范围。为保留追溯，事实记录如下；处置编号已作废，不回收。

| 控制器与端点 | 原处置 | 现处置 | 依据状态 | 移出原因 |
|---|---|---|---|---|
| DetectionRuleController DELETE /detect/detectionRule/{ruleIds} | DISABLE | ADJUST | 章节不存在 | 2026-11-04 决策功能保留、下一期使用；旧路由无守卫等价，改接 `ManagementGuardExecutor` |
| DetectionRuleController POST /detect/detectionRule/ | DISABLE | ADJUST | 章节不存在 | 同上；M02-216 逐项保存只承接新增/修改 |
| DetectionRuleController PUT /detect/detectionRule/ | DISABLE | ADJUST | 章节不存在 | 同上；M02-216 逐项保存只承接新增/修改 |

> 依据事实：docx `03-资源管理` 全章（段落 1640-2006）无「检测规则②」章节；全局仅 04-项目设置段落 2132-2135 引用该节，且 4 处正文均带 `w:strike`。该缺口已写入摘要「需求侧冲突与缺口提示」。

## 3.4 去重核查结果（2026-11-04，静态检查）

> 对原 70 条 DISABLE 逐条核查停用证据与可达调用方。结论：已停用须剔除 **0 条**；可标注 **20 条**；改判 ADJUST **40 条**；存疑 **10 条**。逐条证据与统计见 `docs/调查-旧CRUD写端点去重核查.md`。
> 判定口径：方法体直接/经守卫抛 `EndpointDisabledException`、`ManagementGuardRejectException(PROTOCOL_UPGRADE_REQUIRED)` 或固定 410 的记为已停用；页面/SDK 实际发出请求的记为有调用方；仅 SDK 有封装但页面/测试/Feign 未调用的记为存疑。

| 序号 | 模块 | 控制器与端点 | 核查状态 | 核查证据 | 处置变更 |
|---|---|---|---|---|---|
| 1 | M01 | SysDeptController PUT /dept/updateSort | ADJUST | `dept-management/use-dept-list.ts:90` 实际调用 `deptApi.updateSort`；SDK `sdk-smp-api/src/system.ts:207-214` 发送 `PUT /system/dept/updateSort`（网关 StripPrefix=1 映射到 `/dept/updateSort`） | DISABLE → ADJUST |
| 2 | M01 | SysGroupController PUT /smp/labgroup/{groupId}/members | 可标注 | 旧口只有 GET 读取：`modules/smp/labgroup.ts:21-26`；页面 `labgroup-management/labgroup-editor.vue:393` 改用 `labgroupApi.save`（`src/labgroup.ts:144-151` → `POST/PUT /smp/labgroup`），旧 `PUT /smp/labgroup/{groupId}/members` 无写调用 | 保留 DISABLE |
| 3 | M01 | SysGroupLeaderController DELETE /smp/labgroupleader/{groupIds} | ADJUST | SDK `modules/smp/labgroupleader.ts:39`；页面 `smp-labgroupleader/index.vue:294` 调用 `delLabgroupleader` | DISABLE → ADJUST |
| 4 | M01 | SysGroupLeaderController POST /smp/labgroupleader/ | ADJUST | SDK `modules/smp/labgroupleader.ts:21`；页面 `smp-labgroupleader/index.vue:274` 调用 `addLabgroupleader` | DISABLE → ADJUST |
| 5 | M01 | SysGroupLeaderController PUT /smp/labgroupleader/ | ADJUST | SDK `modules/smp/labgroupleader.ts:30`；页面 `smp-labgroupleader/index.vue:264` 调用 `updateLabgroupleader` | DISABLE → ADJUST |
| 6 | M01 | SysGroupMemberController DELETE /smp/labgroupmember/{groupIds} | ADJUST | SDK `modules/smp/labgroupmember.ts:39`；页面 `smp-labgroupmember/index.vue:294` 调用 `delLabgroupmember` | DISABLE → ADJUST |
| 7 | M01 | SysGroupMemberController POST /smp/labgroupmember/ | ADJUST | SDK `modules/smp/labgroupmember.ts:21`；页面 `smp-labgroupmember/index.vue:274` 调用 `addLabgroupmember` | DISABLE → ADJUST |
| 8 | M01 | SysGroupMemberController PUT /smp/labgroupmember/ | ADJUST | SDK `modules/smp/labgroupmember.ts:30`；页面 `smp-labgroupmember/index.vue:264` 调用 `updateLabgroupmember` | DISABLE → ADJUST |
| 9 | M01 | SysMenuController PUT /menu/updateSort | ADJUST | `menu-management/index.vue:557` 实际调用 `menuApi.sort`；SDK `sdk-smp-api/src/index.ts:410-417` 发送 `PUT /system/menu/updateSort`（网关映射 `/menu/updateSort`） | DISABLE → ADJUST |
| 10 | M02 | LabBenchReactorControllerChannelController DELETE /lab/pumpchannel/{channelIds} | ADJUST | SDK `modules/lab/benchreactorcontrollerchannel.ts:39`（`delPumpchannel`）；页面 `lab-benchreactorcontrollerchannel/index.vue:424` 调用 | DISABLE → ADJUST |
| 11 | M02 | LabBenchReactorControllerChannelController POST /lab/pumpchannel/ | ADJUST | SDK `modules/lab/benchreactorcontrollerchannel.ts:21`（`addPumpchannel`）；页面 `lab-benchreactorcontrollerchannel/index.vue:435` 调用 | DISABLE → ADJUST |
| 12 | M02 | LabBenchReactorControllerChannelController PUT /lab/pumpchannel/ | ADJUST | SDK `modules/lab/benchreactorcontrollerchannel.ts:30`（`updatePumpchannel`）；页面 `lab-benchreactorcontrollerchannel/index.vue:454` 调用 | DISABLE → ADJUST |
| 13 | M02 | LabBenchReactorControllerController DELETE /lab/pumpconnection/{connectionIds} | 可标注 | 泵连接旧写无 SDK 写函数：`modules/lab/benchreactorcontroller.ts` 仅有 GET 与 M02-109/M02-110 新守卫写（`PUT .../controller/{id}`、`PUT .../reactor/{id}`）；`cultureDevice.ts:131-140` 仅 GET；全仓页面未检索到旧写路径 | 保留 DISABLE |
| 14 | M02 | LabBenchReactorControllerController POST /lab/pumpconnection/ | 可标注 | 泵连接旧写无 SDK 写函数：`modules/lab/benchreactorcontroller.ts` 仅有 GET 与 M02-109/M02-110 新守卫写（`PUT .../controller/{id}`、`PUT .../reactor/{id}`）；`cultureDevice.ts:131-140` 仅 GET；全仓页面未检索到旧写路径 | 保留 DISABLE |
| 15 | M02 | LabBenchReactorControllerController PUT /lab/pumpconnection/ | 可标注 | 泵连接旧写无 SDK 写函数：`modules/lab/benchreactorcontroller.ts` 仅有 GET 与 M02-109/M02-110 新守卫写（`PUT .../controller/{id}`、`PUT .../reactor/{id}`）；`cultureDevice.ts:131-140` 仅 GET；全仓页面未检索到旧写路径 | 保留 DISABLE |
| 16 | M02 | LabDetectorItemConfigController POST /lab/detectorconfig/ | 存疑 | SDK `modules/lab/detectorconfig.ts:13`（`addDetectorconfig`）已定义；页面 `lab-detectorconfig/index.vue:164` 只解构 `batchSave`/`getAvailableItems`，全仓无该函数页面调用 | 保留 DISABLE（存疑） |
| 17 | M02 | LabDetectorItemConfigController PUT /lab/detectorconfig/ | 存疑 | SDK `modules/lab/detectorconfig.ts:22`（`updateDetectorconfig`）已定义；页面 `lab-detectorconfig/index.vue:164` 只解构 `batchSave`/`getAvailableItems`，全仓无该函数页面调用 | 保留 DISABLE（存疑） |
| 18 | M02 | LabDownstreamDeviceController PUT /lab/downstreamdevice/changeStatus | 存疑 | SDK `modules/lab/downstreamdevice.ts:85`（`changeStatus`）已定义；页面 `lab-downstreamdevice/index.vue:242-243` 只解构 `checkCanDelete`/`delLabdownstreamdevice`/`list...`，全仓无该模块 `changeStatus` 页面调用 | 保留 DISABLE（存疑） |
| 19 | M02 | LabIntegratedReactorPumpController DELETE /lab/integratedpump/{integratedIds} | 可标注 | 全仓 SDK/页面/Feign/测试未检索到 `/lab/integratedpump` 旧写路径；守卫版为 `PUT /lab/integratedreactor/{integratedId}` 聚合保存 `externalPumps` | 保留 DISABLE |
| 20 | M02 | LabIntegratedReactorPumpController POST /lab/integratedpump/ | 可标注 | 全仓 SDK/页面/Feign/测试未检索到 `/lab/integratedpump` 旧写路径；守卫版为 `PUT /lab/integratedreactor/{integratedId}` 聚合保存 `externalPumps` | 保留 DISABLE |
| 21 | M02 | LabIntegratedReactorPumpController PUT /lab/integratedpump/ | 可标注 | 全仓 SDK/页面/Feign/测试未检索到 `/lab/integratedpump` 旧写路径；守卫版为 `PUT /lab/integratedreactor/{integratedId}` 聚合保存 `externalPumps` | 保留 DISABLE |
| 22 | M02 | LabLabLeaderController DELETE /lab/leader/{labIds} | 可标注 | 全仓 SDK/页面/Feign/测试未检索到 `/lab/leader` 旧写路径；实验室负责人由实验室守卫口维护 | 保留 DISABLE |
| 23 | M02 | LabLabLeaderController POST /lab/leader/ | 可标注 | 全仓 SDK/页面/Feign/测试未检索到 `/lab/leader` 旧写路径；实验室负责人由实验室守卫口维护 | 保留 DISABLE |
| 24 | M02 | LabLabLeaderController PUT /lab/leader/ | 可标注 | 全仓 SDK/页面/Feign/测试未检索到 `/lab/leader` 旧写路径；实验室负责人由实验室守卫口维护 | 保留 DISABLE |
| 25 | M03 | ResBatchController PUT /resource/batch/{batchId}/members | 存疑 | SDK `modules/resource/batch.ts:55-61`（`updateBatchMembers`）已定义；页面 `batch-management/batch-editor.vue:893` 只调用 `batchApi.save`（`PUT /resource/batch/{batchId}`），全仓无该函数页面调用，批次页未挂成员对话框 | 保留 DISABLE（存疑） |
| 26 | M03 | ResBatchLeaderController DELETE /resource/batchleader/{batchIds} | ADJUST | SDK `modules/resource/batchleader.ts:39`；页面 `resource-batchleader/index.vue:292` 调用 `delBatchleader` | DISABLE → ADJUST |
| 27 | M03 | ResBatchLeaderController POST /resource/batchleader/ | ADJUST | SDK `modules/resource/batchleader.ts:21`；页面 `resource-batchleader/index.vue:272` 调用 `addBatchleader` | DISABLE → ADJUST |
| 28 | M03 | ResBatchLeaderController PUT /resource/batchleader/ | ADJUST | SDK `modules/resource/batchleader.ts:30`；页面 `resource-batchleader/index.vue:262` 调用 `updateBatchleader` | DISABLE → ADJUST |
| 29 | M03 | ResBatchMemberController DELETE /resource/batchmember/{batchIds} | ADJUST | SDK `modules/resource/batchmember.ts:39`；页面 `resource-batchmember/index.vue:339` 调用 `delBatchmember` | DISABLE → ADJUST |
| 30 | M03 | ResBatchMemberController POST /resource/batchmember/ | ADJUST | SDK `modules/resource/batchmember.ts:21`；页面 `resource-batchmember/index.vue:319` 调用 `addBatchmember` | DISABLE → ADJUST |
| 31 | M03 | ResBatchMemberController PUT /resource/batchmember/ | ADJUST | SDK `modules/resource/batchmember.ts:30`；页面 `resource-batchmember/index.vue:309` 调用 `updateBatchmember` | DISABLE → ADJUST |
| 32 | M03 | ResCultureController POST /resource/culture/ | ADJUST | `culture-management/culture-editor.vue:2035-2040` 新建培养调用 `cultureApi.save({cultureCode,...})`（无 cultureId）→ `sdk-smp-api/src/culture.ts:414-418` 发送 `POST /resource/culture`；后端 `ResCultureController.java:655-659` 仍为 `toAjax(insertResCulture)`，未停用 | DISABLE → ADJUST |
| 33 | M03 | ResCultureController PUT /resource/culture/ | 存疑 | SDK `modules/resource/culture.ts:38`（`updateCulture`）及 flat `culture.ts:414-418` 的 PUT 分支均已定义；页面仅在 `cultureId == null` 时调用 save（`culture-editor.vue:2035`），编辑走 `PATCH /resource/culture/{id}`（`:2045`），全仓无旧 PUT 页面调用 | 保留 DISABLE（存疑） |
| 34 | M03 | ResCultureController PUT /resource/culture/{cultureId}/members | ADJUST | `culture-management/index.vue:405` 组装 `cultureMemberApi`，`:1259` 成员对话框传 `:api="cultureMemberApi"`；`shared/member-dialog.vue:545` 调用 `props.api.saveMembers`；`sdk-smp-api/src/culture.ts:409-412` 发送 `PUT /resource/culture/{id}/members`；后端 `ResCultureController.java:590-595` 仍为 `toAjax(replaceCultureMembers)` | DISABLE → ADJUST |
| 35 | M03 | ResCultureMemberController DELETE /resource/culturemember/{cultureIds} | ADJUST | SDK `modules/resource/culturemember.ts:39`；页面 `resource-culturemember/index.vue:339` 调用 `delCulturemember` | DISABLE → ADJUST |
| 36 | M03 | ResCultureMemberController POST /resource/culturemember/ | ADJUST | SDK `modules/resource/culturemember.ts:21`；页面 `resource-culturemember/index.vue:319` 调用 `addCulturemember` | DISABLE → ADJUST |
| 37 | M03 | ResCultureMemberController PUT /resource/culturemember/ | ADJUST | SDK `modules/resource/culturemember.ts:30`；页面 `resource-culturemember/index.vue:309` 调用 `updateCulturemember` | DISABLE → ADJUST |
| 38 | M03 | ResProjectController PUT /resource/project/ | 存疑 | SDK `modules/resource/project.ts:30`（`updateProject`）已定义；页面 `project-editor.vue:318` 调用 `projectApi.save`，有 projectId 时发 `PUT /resource/project/{projectId}`（`src/project.ts:143-158`），不是旧 `PUT /resource/project`；全仓无 `updateProject` 页面调用 | 保留 DISABLE（存疑） |
| 39 | M03 | ResProjectController PUT /resource/project/{projectId}/members | ADJUST | `project-management/index.vue:459-460` 成员对话框传 `:api="projectApi"`；`shared/member-dialog.vue:545` 调用 `props.api.saveMembers`；`sdk-smp-api/src/project.ts:134-138` 发送 `PUT /resource/project/{id}/members`；后端 `ResProjectController.java:155-159` 仍为 `toAjax(replaceProjectMembers)` | DISABLE → ADJUST |
| 40 | M03 | ResProjectLabController DELETE /resource/projectlab/{projectIds} | ADJUST | SDK `modules/resource/projectlab.ts:39`；页面 `resource-projectlab/index.vue:292` 调用 `delProjectlab` | DISABLE → ADJUST |
| 41 | M03 | ResProjectLabController POST /resource/projectlab/ | ADJUST | SDK `modules/resource/projectlab.ts:21`；页面 `resource-projectlab/index.vue:272` 调用 `addProjectlab` | DISABLE → ADJUST |
| 42 | M03 | ResProjectLabController PUT /resource/projectlab/ | ADJUST | SDK `modules/resource/projectlab.ts:30`；页面 `resource-projectlab/index.vue:262` 调用 `updateProjectlab` | DISABLE → ADJUST |
| 43 | M03 | ResProjectLeaderController DELETE /resource/projectleader/{projectIds} | ADJUST | SDK `modules/resource/projectleader.ts:39`；页面 `resource-projectleader/index.vue:292` 调用 `delProjectleader` | DISABLE → ADJUST |
| 44 | M03 | ResProjectLeaderController POST /resource/projectleader/ | ADJUST | SDK `modules/resource/projectleader.ts:21`；页面 `resource-projectleader/index.vue:272` 调用 `addProjectleader` | DISABLE → ADJUST |
| 45 | M03 | ResProjectLeaderController PUT /resource/projectleader/ | ADJUST | SDK `modules/resource/projectleader.ts:30`；页面 `resource-projectleader/index.vue:262` 调用 `updateProjectleader` | DISABLE → ADJUST |
| 46 | M03 | ResProjectMemberController DELETE /resource/projectmember/{projectIds} | ADJUST | SDK `modules/resource/projectmember.ts:39`；页面 `resource-projectmember/index.vue:368` 调用 `delProjectmember` | DISABLE → ADJUST |
| 47 | M03 | ResProjectMemberController POST /resource/projectmember/ | ADJUST | SDK `modules/resource/projectmember.ts:21`；页面 `resource-projectmember/index.vue:348` 调用 `addProjectmember` | DISABLE → ADJUST |
| 48 | M03 | ResProjectMemberController PUT /resource/projectmember/ | ADJUST | SDK `modules/resource/projectmember.ts:30`；页面 `resource-projectmember/index.vue:338` 调用 `updateProjectmember` | DISABLE → ADJUST |
| 49 | M03 | ResProjectTagController DELETE /resource/projecttag/{projectIds} | ADJUST | SDK `modules/resource/projecttag.ts:39`；页面 `resource-projecttag/index.vue:318` 调用 `delProjecttag` | DISABLE → ADJUST |
| 50 | M03 | ResProjectTagController POST /resource/projecttag/ | ADJUST | SDK `modules/resource/projecttag.ts:21`；页面 `resource-projecttag/index.vue:298` 调用 `addProjecttag` | DISABLE → ADJUST |
| 51 | M03 | ResProjectTagController PUT /resource/projecttag/ | ADJUST | SDK `modules/resource/projecttag.ts:30`；页面 `resource-projecttag/index.vue:288` 调用 `updateProjecttag` | DISABLE → ADJUST |
| 52 | M09 | AlarmNotifyReceiverController DELETE /alarm/alarmNotifyReceiver/{receiverIds} | ADJUST | SDK `modules/alarm/alarmNotifyReceiver.ts:39`；页面 `alarm-alarm-notify-receiver/index.vue:371` 调用 `delAlarmNotifyReceiver` | DISABLE → ADJUST |
| 53 | M09 | AlarmNotifyReceiverController POST /alarm/alarmNotifyReceiver/ | ADJUST | SDK `modules/alarm/alarmNotifyReceiver.ts:21`；页面 `alarm-alarm-notify-receiver/index.vue:351` 调用 `addAlarmNotifyReceiver` | DISABLE → ADJUST |
| 54 | M09 | AlarmNotifyReceiverController PUT /alarm/alarmNotifyReceiver/ | ADJUST | SDK `modules/alarm/alarmNotifyReceiver.ts:30`；页面 `alarm-alarm-notify-receiver/index.vue:341` 调用 `updateAlarmNotifyReceiver` | DISABLE → ADJUST |
| 55 | M09 | AlarmNotifyRuleController DELETE /alarm/alarmNotifyRule/{ruleIds} | 可标注 | SDK `modules/alarm/alarmNotifyRule.ts` 仅有 GET 与 `saveAlarmNotifyRuleConfig`（`:34`，对应第 59 条）；页面 `alarm-alarm-notify-rule/use-notify-rules.ts:10-11` 使用 V2 `getRuleConfigV2/saveRuleConfigV2`；旧 DELETE/POST/PUT/with-receiver 无调用 | 保留 DISABLE |
| 56 | M09 | AlarmNotifyRuleController POST /alarm/alarmNotifyRule/ | 可标注 | SDK `modules/alarm/alarmNotifyRule.ts` 仅有 GET 与 `saveAlarmNotifyRuleConfig`（`:34`，对应第 59 条）；页面 `alarm-alarm-notify-rule/use-notify-rules.ts:10-11` 使用 V2 `getRuleConfigV2/saveRuleConfigV2`；旧 DELETE/POST/PUT/with-receiver 无调用 | 保留 DISABLE |
| 57 | M09 | AlarmNotifyRuleController POST /alarm/alarmNotifyRule/with-receiver | 可标注 | SDK `modules/alarm/alarmNotifyRule.ts` 仅有 GET 与 `saveAlarmNotifyRuleConfig`（`:34`，对应第 59 条）；页面 `alarm-alarm-notify-rule/use-notify-rules.ts:10-11` 使用 V2 `getRuleConfigV2/saveRuleConfigV2`；旧 DELETE/POST/PUT/with-receiver 无调用 | 保留 DISABLE |
| 58 | M09 | AlarmNotifyRuleController PUT /alarm/alarmNotifyRule/ | 可标注 | SDK `modules/alarm/alarmNotifyRule.ts` 仅有 GET 与 `saveAlarmNotifyRuleConfig`（`:34`，对应第 59 条）；页面 `alarm-alarm-notify-rule/use-notify-rules.ts:10-11` 使用 V2 `getRuleConfigV2/saveRuleConfigV2`；旧 DELETE/POST/PUT/with-receiver 无调用 | 保留 DISABLE |
| 59 | M09 | AlarmNotifyRuleController PUT /alarm/alarmNotifyRule/config | 存疑 | SDK `modules/alarm/alarmNotifyRule.ts:34-40` 定义 `saveAlarmNotifyRuleConfig`；页面 `use-notify-rules.ts:10-11` 仅用 V2 `saveRuleConfigV2`，全仓无该函数页面调用 | 保留 DISABLE（存疑） |
| 60 | M09 | AlarmNotifyRuleController PUT /alarm/alarmNotifyRule/with-receiver | 可标注 | SDK `modules/alarm/alarmNotifyRule.ts` 仅有 GET 与 `saveAlarmNotifyRuleConfig`（`:34`，对应第 59 条）；页面 `alarm-alarm-notify-rule/use-notify-rules.ts:10-11` 使用 V2 `getRuleConfigV2/saveRuleConfigV2`；旧 DELETE/POST/PUT/with-receiver 无调用 | 保留 DISABLE |
| 61 | M09 | AlarmRecordController DELETE /alarm/alarmRecord/{alarmIds} | 可标注 | SDK `modules/alarm/alarmRecord.ts` 仅有 GET 与 `handleAlarm`（`:22`，对应第 63 条）；页面 `alarm-alarm-record/view.vue:213` 使用 V2 `getAlarmRecordV2/handleAlarmV2`；旧 DELETE/POST/PUT 无调用 | 保留 DISABLE |
| 62 | M09 | AlarmRecordController POST /alarm/alarmRecord/ | 可标注 | SDK `modules/alarm/alarmRecord.ts` 仅有 GET 与 `handleAlarm`（`:22`，对应第 63 条）；页面 `alarm-alarm-record/view.vue:213` 使用 V2 `getAlarmRecordV2/handleAlarmV2`；旧 DELETE/POST/PUT 无调用 | 保留 DISABLE |
| 63 | M09 | AlarmRecordController POST /alarm/alarmRecord/handle | 存疑 | SDK `modules/alarm/alarmRecord.ts:22-28` 定义 `handleAlarm`；页面 `alarm-alarm-record/view.vue:213` 仅用 `handleAlarmV2`（`:340`），全仓无旧 `handleAlarm` 页面调用 | 保留 DISABLE（存疑） |
| 64 | M09 | AlarmRecordController PUT /alarm/alarmRecord/ | 可标注 | SDK `modules/alarm/alarmRecord.ts` 仅有 GET 与 `handleAlarm`（`:22`，对应第 63 条）；页面 `alarm-alarm-record/view.vue:213` 使用 V2 `getAlarmRecordV2/handleAlarmV2`；旧 DELETE/POST/PUT 无调用 | 保留 DISABLE |
| 65 | M09 | LabOfflineAlarmConfigController DELETE /lab/offlinealarm/{configIds} | ADJUST | SDK `modules/lab/offlinealarm.ts:16-21`；页面 `lab-offlinealarm/index.vue:277` 导入、`:484` 调用 `delOfflinealarm` | DISABLE → ADJUST |
| 66 | M09 | LabOfflineAlarmConfigController POST /lab/offlinealarm/ | 可标注 | SDK `modules/lab/offlinealarm.ts` 仅有 list/delete/check/batch-save（`:7/:16/:23/:30`），无 POST/PUT 写函数；页面仅调用 `batchSave`/`delOfflinealarm` | 保留 DISABLE |
| 67 | M09 | LabOfflineAlarmConfigController POST /lab/offlinealarm/{labId}/batch-save | ADJUST | SDK `modules/lab/offlinealarm.ts:30-36`；页面 `lab-offlinealarm/index.vue:277` 导入、`:473` 调用 `batchSave` | DISABLE → ADJUST |
| 68 | M09 | LabOfflineAlarmConfigController PUT /lab/offlinealarm/ | 可标注 | SDK `modules/lab/offlinealarm.ts` 仅有 list/delete/check/batch-save（`:7/:16/:23/:30`），无 POST/PUT 写函数；页面仅调用 `batchSave`/`delOfflinealarm` | 保留 DISABLE |
| 69 | M09 | LabStatusAlarmConfigController POST /lab/statusalarm/batch-save | 存疑 | SDK `modules/lab/statusAlarm.ts:22-29`（`batchSaveAlarm`）/:36-42（`clearAlarm`）已定义；页面 `lab-statusalarm/index.vue:319` 只解构 `getStatusConfigV2/saveStatusConfigV2`，全仓无旧函数页面调用 | 保留 DISABLE（存疑） |
| 70 | M09 | LabStatusAlarmConfigController POST /lab/statusalarm/clear | 存疑 | SDK `modules/lab/statusAlarm.ts:22-29`（`batchSaveAlarm`）/:36-42（`clearAlarm`）已定义；页面 `lab-statusalarm/index.vue:319` 只解构 `getStatusConfigV2/saveStatusConfigV2`，全仓无旧函数页面调用 | 保留 DISABLE（存疑） |

## 4. 本阶段的写风险

- **标记不等于关闭**：`@Deprecated` 与注释不阻止任何写入，旧 CRUD 口子仍可被调用，权限注解、调用链和返回值均不变。
- 只靠注释挡不住误用：前端 SDK、历史脚本或外部调用方不会因为 Java 注解而停止请求。
- 因此这批端点的写风险在阶段 2 后**依然存在**，需在 V5.1 设计定稿后再决定是否真正停用（清空方法体、抛 EndpointDisabledException 或删除入口）。
- 恢复成本是本方案的主要收益：撤除标注即可回到现状，不需要回滚代码逻辑或数据。

## 4.1 口径差异记录（docx 删除线判定）

> 判定口径：V5.1 原版 `需求说明书V5.1-1030.docx` 为需求原件；段落/文本是否删除以 run 级 `w:strike` / `w:dstrike`（含段落级 rPr）为准；md 转写稿“搜不到”不作为删除依据。
> 解析方式：解压 `word/document.xml`，按段落顺序扫描 `w:p`，逐 `w:r` 检查 `w:rPr/w:strike|w:dstrike`（`val` 非 `0/false/off/none` 视为删除线）。

- **DetectionRule 改判痕迹（2026-11-04）**：POST / PUT / DELETE 三个写端点由 DISABLE 改为 ADJUST；原处置编号 `LEGACY-M02-DETECTION-RULE-POST` / `-PUT` / `-DELETE`（按动作记法即 ADD / EDIT / DELETE）已作废，不回收给其他端点；清单与摘要同步为 DISABLE 70 / ADJUST 42 / 待确认 10。
- **去重核查改判痕迹（2026-11-04）**：原 70 条 DISABLE 中 40 条有页面实际调用，改判 ADJUST 并接入 `ManagementGuardExecutor` 守卫，不做 `@Deprecated`；20 条可标注、10 条存疑（仅剩 SDK 封装、页面未调用）。原处置编号保留在本表用于追溯，不回收；CSV/摘要同步为 DISABLE 30 / ADJUST 82 / 待确认 10。
- **检测规则②**：原版 docx `03-资源管理` 全章（段落 1640-2006）的标题清单为：设备库①、台式反应器罐①、集成反应器①、培养容器①、称重设备①、检测设备①、设备检测项①、蠕动泵①、空气泵①、液袋管理②、补液培养基管理②、耗材管理②；**无「检测规则②」章节**。全局仅 4 处「检测规则」文字（段落 2132-2135，位于 04-项目设置 批次检测规则），且全部带 `w:strike`。结论：V5.1 已删除/未纳入该子节；据此原判 DISABLE，2026-11-04 用户决策功能保留后改判 ADJUST 并移出本表。
- **md 截图 OCR 仍含「检测规则」导航文字**：`03-资源管理.md` 第 668、820 行的「检测规则」是截图 OCR 的左侧导航栏文字（image195/image205），不是章节标题；docx 中对应为图片，无法用文本删除线判定。不作为章节依据，也不构成 md 有而 docx 删除的正文差异。
- **设备库-集成反应器①**：docx 段落 1678（03-资源管理-设备库）标题带 `w:strike`，目录段落 117 同带删除线；说明 V5.1 md 的 `03-资源管理.md` 未收录该节属正确。登记表中 `LabIntegratedReactorPump*` 依据指向 `02-实验室设置.md / 设备配置① / 集成反应器`，该标题 docx 段落 1084 未带删除线，依据有效。
- **标题未删但正文局部划线（md 未体现删除线）**：`其他设备` 段落 1249-1372 有 2 段带 `w:strike`（1355「设备IP地址」、1356「设备端口号」），而 `02-实验室设置.md` 第 1443-1444 行仍以正常正文保留；`集成反应器①` 正文 1085-1150 有 2 段划线（1106「是否需要外置泵」、1139「告警设置不在当前阶段优先级内」）、`实验室管理①` 718-794 有 1 段（769「布局：预留入口」）、`离线告警设置①` 1374-1392 有 1 段（1379「删除此区分开关」）。这些局部划线均不涉及上述端点所在章节的标题，依据判定仍为「依据成立」；但 md 未同步删除线，属于 md/docx 口径差异。
- **批次管理与培养基础管理的正文划线**：`批次管理①`（段落 2066）标题未划线，正文 2067-2207 有 9 段划线，含 2092「特殊培养」、2132-2135「检测规则」、2193-2199「结束」流程；`培养基础管理①`（段落 2209）标题未划线，正文 2210-2317 有 10 段划线，含 2219-2222「设置成员」批量段、2241「别名」、2290/2294-2297「成员/基本信息/成员选择/期限设置/移除」、2310「查看」。md 稿中这些行多数未被删除线标记；其中「设置成员」在 md 第 647 行以「分享」批量操作保留，措辞与 docx 不一致。局部划线不影响登记表依据状态（标题均未划线）。
- **未逐条复核的旧表述已作废**：本次已对 73 条全部回查 docx，不再保留“其余依据尚未逐条复核”的旧说明。

## 5. 阶段 2 执行顺序建议

1. 前置核查（2026-11-04 已完成，每组开始前复核增量即可）：
   - 70 条中**已停用须剔除 0 条**；`Legacy*Guard` / 410 / `EndpointDisabledException` / `ManagementGuardRejectException` 命中的端点均不在本表范围。
   - 有页面实际调用的 **40 条已改判 ADJUST**，不做标记。
   - **可标注 20 条**进入标注；**存疑 10 条**暂不标注，待确认 SDK 旧函数与仓外调用方。
   - 复核 HEAD 与工作区，确认没有其他会话正在修改同一控制器。
2. 分批顺序：**M01 → M02 → M03 → M09**，每批按控制器小组执行（建议每组 3—6 个端点）。
3. 每组完成后：
   - 执行 `mvn -pl futurefab-modules/futurefab-system -am test`；
   - 核对 `git diff` 仅包含 `@Deprecated` 与注释，无逻辑、权限、SQL、配置改动；
   - 更新本表「标注状态」为「已标注」并记录执行人与日期。
4. 全部完成后统一复核一次，再在摘要中更新进度；仍不 commit / push，除非用户另行要求。

## 6. 撤销与找回

- 撤销单条：按「处置编号」在本表定位，撤除方法上的 `@Deprecated` 与处置注释段。
- 撤销整批：按模块分组回退对应控制器的注释改动；不要使用 `git reset --hard` 或批量删除。
- 若 V5.1 设计确认仍需保留某端点，直接撤除标注即可，无需恢复逻辑（本方案从未改动逻辑）。