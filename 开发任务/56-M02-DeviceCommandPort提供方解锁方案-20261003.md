# 56 · M02 DeviceCommandPort 提供方解锁方案（work2·只读设计核查）

- 日期：2026-10-03
- 基线：分支 cloud，HEAD `5fb95624`（= origin/cloud），工作区干净；本轮零代码/SQL/登记改动
- 性质：SUPPORTING 过程文档；不替代任何现行契约；现行文档未变动
- 前序：`docs/详细设计/02-实验室与资源管理/history/review/DeviceCommandPort提供方阻塞预检-20261003.md`（commit 94182695）、`docs/开发任务/53-TP-M09-02告警记录与消音预检报告-20261003.md`（work7）
- 方法：只读检索现行权威文档与代码（grep/Read 行号可复核；本会话无 codebase-memory 工具，未使用）

## 1. 当前阻塞是否仍成立 —— 成立（HEAD 5fb95624 复核）

| 事实 | 证据 |
| --- | --- |
| DeviceCommandPort 仅接口、全仓零实现 | `service/port/m02/DeviceCommandPort.java`（CMD-I01 submitCommand / CMD-I02 queryCommand）；main 源码除接口自身外仅命中签名门禁 `PortSignatureSnapshotTest.java:50-51,128`；无 `implements DeviceCommandPort`、无 Bean、无注入调用方 |
| 提供方无任务包归属 | `37-第9步业务开发任务包总览.md` 全文无 "CMD-I0"；仅 M07 消费依赖行 5091/5231/5360-5361（TP-M07-03/04/05）与 M09 消费行 5465/5558；TP-M02-01…15 均不含提供方文件 |
| M02 模块文档未登记该端口 | `02-.../Controller请求调用时序设计.md` §3 非 Controller 内部端口共 8 条（AUTH-I01—03、ENG-I01、CAP-I01—03、OBS-I01），无 CMD 条目；`02-.../接口目录与契约定位.md` grep "命令/执行器/CMD" 零命中 |
| 消费方现状 | M09-016 仍 501（`AlarmSoundCommandApplicationApplicationServiceImpl.java:22`）；M07 全部 33 条 wired=0（skeleton-m07.json），`RunExecutorAssignmentApplicationApplicationServiceImpl` 等 4 处 501 |
| run_command 无代码承载 | 全仓无 RunCommand 实体/Mapper/XML；仅 `domain/vo/m07/CommandOperation.java:16` 枚举 SET_AUTO/START/SET_SPEED/STOP/RESTART 与 CommandState/ExecutionCommandView 视图 |

## 2. 必须由总控／产品／设计裁决的点（未裁决不可编码）

1. **声光（DEVICE 作用域）命令意图与回执的落库承载**（核心裁决）：
   `run_command`（01-完整建表.sql:3339）`culture_id BIGINT NOT NULL`＋execution/step 语义＋操作注册表无 ON/OFF，与 M09 声光"不要求 cultureId"（页面与接口契约.md:5/:163、设备业务操作页与独立入口.md:22）结构冲突；M02 无声光命令意图表。"由M02命令保存ON/OFF意图与回读"（通知投递与恢复契约.md:57、骨架清单:9663）目前无表/枚举承接。选项与风险见 §4。
2. **M09 消费方登记口径**：`01-骨架文件所有权.md:157` 的 CMD-I01—I02 消费方仅登记 M07。M09 消费 DeviceCommandPort 需补登记，或经设计确认改为"新增 M02 声光命令子 Port"（须走 `02-PKG-00` 物理签名冻结 + PortSignatureSnapshotTest 扩展，属签名设计动作）。二者只能择一，不得口头并用。
3. **"聚合引用计数"能力规格**：多条件共享声光的引用计数由 M02 适配器提供，未提供即该通道 BLOCKED（骨架清单:9663）。能力输入/输出/失败语义未定义，需设计补契约后才能进 provider 范围。
4. **M09-016 审计主体裁决＋权限种子登记**：work7 报告已列（53-报告:70）；`lab:soundalarm:operate` 的菜单/权限种子未登记前，M09 侧接线即便有 provider 也无法 HTTP_VERIFIED。
5. **立项**：总控需把"DeviceCommandPort 提供方批次"落成任务包（新增 TP-M02-xx 或扩条 TP-M02-07），定义文件范围、interface_id/端口号（如时序表 CMD-P01/P02）、验收门禁与 33§11 未接门禁口径的解除条件。
6. **M02 时序 §3 端口登记表扩容文档动作**：provider 立项后先在 M02 权威文档登记，再落码（本轮不改文档）。

注：`32-BLOCKED设计裁决清单.md` 现无任何 DeviceCommand/CMD/声光命令条目——上述 1—4 应先入册，避免口头裁决。

## 3. 裁决后 M02 可实现的文件范围（预案，不在本轮执行）

| 层 | 文件（全部新增，零共享冲突） | 内容 |
| --- | --- | --- |
| Port | `service/port/m02/DeviceCommandPort.java` | 现签名冻结不动；若裁决 2 选子 Port 则新增 `m02/SoundAlarmCommandPort` 类文件 |
| 应用服务 | `service/impl/application/m02/DeviceCommandApplicationServiceImpl.java` | 实现 submitCommand/queryCommand：意图持久化→状态机 CAS→同键异载荷 REQUEST_CONFLICT（M02错误码全集:21 已登记）→事务外调用适配器→UNKNOWN 只查不重发→依赖不可用抛 DEPENDENCY_UNAVAILABLE，禁伪回执 |
| 数据 | `domain/DeviceCommandIntent.java`＋`mapper/DeviceCommandIntentMapper.java`＋`resources/mapper/lab/DeviceCommandIntentMapper.xml`＋dto | 按裁决 §2.1 选定表 |
| 数据库 | 模块目标 DDL＋`docs/开发基线/01-完整建表.sql` 生成链＋`来源清单.json` 同步 | 属基线任务，走 AGENTS §7 流程，单独评审 |
| 测试 | `src/test/.../contract/M02WiredDeviceCommandContractTest.java` | 见 §6 |
| 不动 | M09 全部文件、skeleton-m02/m09.json、ManagementOperation/AuditPolicyRegistry、run_command 相关 | provider 为内部端口无 HTTP 写口，守卫/审计登记仅当新增 HTTP 面时才涉及 |

## 4. 表承载三选项与风险（供裁决，不预设结论）

| 选项 | 说明 | 主要风险 |
| --- | --- | --- |
| A. 扩 run_command＋操作注册表 | 加声光操作枚举、放宽 culture_id/execution 语义 | `culture_id NOT NULL`、`ck_m07_*` 约束与 M07 域（fence/claim/停止证据）深绑；改 M07 权威表冲击 TP-M07 全线验收与基线生成链；"泵执行归M07、声光是 M02 资产"（详细设计.md:24）的域边界被打破。**风险高，不推荐** |
| B. 复用 lab_sound_alarm 加命令列 | 意图/回执写进资产表（1326：仅资产/绑定/status 列） | 资产维护与命令生命周期混行，破坏唯一约束（m02_asset_key/m02_active 生成列）、审计快照口径与 M09-016 备注"现有 LabSoundAlarmController 为设备资产维护，非声光控制链路"的定位。**风险高** |
| C. 新建 M02 设备命令意图＋回执表 | 独立表承载 ON/OFF 意图、requestId/requestHash 唯一回执、状态机（可映射 ACCEPTED/EXECUTED/UNKNOWN 子集）、adapterInstanceId；不动 M07 域 | 与 M07 命令契约形成两套命令生命周期，须由裁决 2/6 明确各自权威范围（泵/执行域命令=M07 run_command；DEVICE 资产类命令=M02 新表），并要求 M02 表同样满足时序 §4 命令端口约束（同键异载荷 409、不降级空成功）。**结构性风险最低，推荐方向，待总控确认** |

## 5. M07／M09 消费方等待的 provider 能力

- **M09-016（消音）** 与 **M09 sound 投递通道**（alarm_delivery channel='sound'，建表:3885 表、:3918 ck_m09_close_channel）等待：
  1. submitCommand 显式 ON/OFF（非 toggle）＋意图持久化与回读；
  2. queryCommand 按原 commandId 查单（UNKNOWN→"结果待核实"，不重发）；
  3. 目标设备真实绑定校验（反应器 ID 不得顶替声光 ID）；
  4. 裁决 3 的聚合引用计数（未提供前该子通道保持 BLOCKED，不得先行发送）；
  5. provider 接线前，33§11 未接门禁口径维持（跨模块 Port 契约测试不得转真实断言）。
- **M07（TP-M07-03/04/05）** 等待：
  1. 固定执行器派发通道（SET_AUTO/START/SET_SPEED/STOP/RESTART 五操作注册表内），fence/configRevision/capabilityRevision 校验语义（设备命令契约 §1/§2）；
  2. 与 `run_executor_assignment`（建表:3495，control_proof/epoch/ISOLATED 状态）配套的接管与旧代次拒绝；
  3. 回执新事务落证据（payloadHash 核对）、TIMEOUT→UNKNOWN 不结算。
  M07 侧契约已裁决完备（设备命令契约.md 为权威），缺的只是提供方源码＋任务包立项＋外部适配器参数。

## 6. 裁决后最小充分测试（M02 侧契约级）

1. 同 requestId 异规范化载荷 → REQUEST_CONFLICT，保留原回执、不生成新动作；
2. 意图先持久化后调用：替身断言调用序（网络调用不处于本地事务持锁段）；
3. 适配器缺席/失败 → 状态 UNKNOWN/依赖异常，禁伪 NOT_FOUND、禁空回执、不标 EXECUTED；
4. queryCommand 仅查原 commandId：不重发物理动作；旧 fence 新写拒绝、同键同 hash 重放返回原证据；
5. 声光目标校验：以反应器 ID 顶替声光 ID → 拒绝；未绑定 → 阻断不发送；
6. 状态机列 CAS：并发双写仅一方生效，另一方版本冲突。
真实派发回执（ACCEPTED/EXECUTED/停止证据）不在内存替身可证范围——源码+契约测试只能到 CONTRACT_TESTED；现场声光闭环=BLOCKED_EXTERNAL，不得写成源码全完成。

## 7. 验证层级

本轮：DOCUMENT_VERIFIED + CODE_STATIC_VERIFIED（只读行号复核，未运行测试/服务/SQL）。
M09-016、M07 命令链路：维持 BLOCKED（裁决前置）；provider 源码工作：待裁决，未开始；真实设备：BLOCKED_EXTERNAL（缺网关参数、executor control_proof、声光协议核准资料，AGENTS §10）。

## 8. 建议总控动作顺序

1. 入册 32-BLOCKED 裁决清单（§2.1—2.4）→ 2. 裁决落库选项（§4）与消费登记（§2.2）→ 3. 立项提供方任务包（§2.5/2.6）并同步 M02 时序 §3 文档 → 4. 数据库基线任务（新表，走生成链）→ 5. M02 provider 编码＋契约测试（§3/§6）→ 6. M09-016 接线批次（work7 窗口，先后序：provider→wiring）→ 7. 外部联调窗口（声光真机＋短信等同批）。
