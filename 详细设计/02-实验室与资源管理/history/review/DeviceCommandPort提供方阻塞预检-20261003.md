# DeviceCommandPort 提供方阻塞预检（work2·只读预检）

- 日期：2026-10-03
- 触发：work7 报告 M09-016 消音接口依赖 M02 DeviceCommandPort（CMD-I01/I02），接口存在但未发现提供方实现
- 性质：过程性预检记录（SUPPORTING），不修改任何现行契约、代码、SQL、登记
- 基线：分支 cloud，HEAD `b1ba83eb`（= origin/cloud），工作区干净
- 方法：直接 grep/Read 代码与权威文档（本会话无 codebase-memory 工具，未使用；全部证据为文件+行号可复核）

## 1. work7 判断核验：成立，两处细节需修正

1. **零实现确认**：`futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/port/m02/DeviceCommandPort.java`
   仅接口声明（CMD-I01 `submitCommand`、CMD-I02 `queryCommand`）。全仓 main 源码中
   `DeviceCommandPort|submitCommand|queryCommand` 除接口自身外只命中
   `src/test/java/com/futurefab/system/contract/PortSignatureSnapshotTest.java:50-51,128`（物理签名冻结门禁）。
   无任何 `implements DeviceCommandPort`、无 Bean 注册、无注入调用方。
   模型类存在：`port/m02/model/DeviceCommand.java`、`DeviceCommandQuery/Receipt/State/QueryState`。
2. **M09-016 依赖确认**：`docs/开发任务/00-全接口契约骨架清单.md:9659`（M09-016 跨模块Port
   "M09→M02:可靠设备命令/查单"）、备注 9663（"复用M02可靠设备命令/查单契约，显式OFF非toggle；
   意图与回执由M02命令契约承载；聚合引用计数能力未提供时该通道BLOCKED"）；
   `docs/详细设计/09-告警与通知管理/页面与接口契约.md:68`（API16 "复用M02可靠命令；结果未知需查单"）。
   M09-016 现为 501：`service/impl/application/m09/AlarmSoundCommandApplicationApplicationServiceImpl.java:22`。
3. **修正①**：Port 消费方冻结登记（`docs/开发任务/01-骨架文件所有权与并行任务包.md:157`）只列
   "M07 | CMD-I01—I02（2）"，M09 不在 Port 消费表中——M09 对命令通道的消费仅由接口骨架清单文字承载，
   两层登记不一致，需设计裁决/登记澄清（见 §4A②）。
4. **修正②**：提供方未分配给任何开发任务包（见 §3），阻塞根因不止"未实现"，而是"无任务包+无落库设计"。

## 2. CMD-I01/I02 契约语义（权威：docs/详细设计/07-补液运行与任务执行/设备命令契约.md，DD-20260913-R2；签名冻结：docs/开发任务/02-PKG-00公共契约与Port物理签名设计.md §6.7 行197-198）

- **submitCommand**：入参 commandId/requestId/fence/deviceRef/operation/configRevision/parameters
  （parameters 含 schemaVersion、targetGrams、speed、desiredMode、executionRef、capabilityRevision、
  resourceClaims 非空去重）。可信执行器身份取传输认证上下文，不接收浏览器 actor；未知操作按
  已核准操作注册表拒绝；ACCEPTED≠EXECUTED；同幂等键异规范化载荷拒绝且不生成新动作（§1、§2）。
- **queryCommand**：commandId 必填、deviceCommandId 可空（已知须与原回执一致）、deviceRef/fence/
  configRevision 必填；仅查原命令不重发物理动作；查询不授权以旧 fence 再写设备（§3）。
- **状态机**：命令态 PREPARED/INVOKING/ACCEPTED/EXECUTED/FAILED/UNKNOWN；查询态
  NOT_SENT/ACCEPTED/RUNNING/STOPPED/FAILED/UNKNOWN/NOT_FOUND；NOT_FOUND 仅查无网关记录，
  不证明未物理执行；来源不可用抛依赖异常，禁止伪造 NOT_FOUND/空回执（§1、§3:63）。
- **超时/失败**：TIMEOUT→state=UNKNOWN，不结算、不释放、不新建命令；FAILED 不证明已停止
  （契约 §6 夹具表 115-118）。HTTP 侧失败码（M09-016 登记）：UNAUTHENTICATED、FORBIDDEN、
  NOT_FOUND、VALIDATION_FAILED、VERSION_CONFLICT、EXTERNAL_RESULT_UNKNOWN、DEPENDENCY_UNAVAILABLE。
- **事务与设备发送边界**（契约 §5）：同事务持久化 claim/execution/PREPARED 命令 → 短事务置
  INVOKING 并提交 → 网络调用在事务外、不持 SYSTEM 锁 → 回执在新事务核对身份/版本/hash 落证据；
  失败/超时/崩溃不允许页面重生成任务补发；仅核准幂等绝对速度/STOP 可按原键重传。
- **权限与实验室范围**：M09-016 权限 `lab:soundalarm:operate`＋M02 声光操作等级；声光目标必须
  来自设备当前真实绑定，反应器 ID 不得替代声光 ID；监控/声光逐项动作资格独立校验，不因模板
  可写放行物理命令（`09-.../页面与接口契约.md:163`、`02-.../设备业务操作页与独立入口.md:22-26`）。
- **M02 侧定位**：`02-.../通讯与设备公共契约.md:104-106`——CommandRequest 仅为 M02 入口转交
  上下文，不是第二套设备线协议；submitCommand/queryCommand 与回读、停止证据统一采用 M07 设备
  命令契约；M02 不自行填 fence、不绕过固定执行器直接写设备。

## 3. 所属任务包核查：提供方无任务包归属（关键缺口）

- `docs/开发任务/37-第9步业务开发任务包总览.md` 全文无 "CMD-I0"；"可靠设备命令/查单" 仅作为
  **消费方依赖**出现在 M07 包（行 5091、5231、5360-5361，属 TP-M07-03/04/05）与 M09 消费行
  （5465、5558）。TP-M02-01…15 的 interface_id 范围与文件清单均不含设备命令提供方。
- TP-M02-07（设备通讯配置，M02-193…211）只做通讯配置面，AAD/SDMS/Named Pipe 参数保持
  BLOCKED_INPUT；不含命令派发。
- `docs/开发任务/32-BLOCKED设计裁决清单.md` 无 DeviceCommand/CMD-I/声光命令条目。
- 结论：`01-骨架文件所有权` 把提供方登记为 M02，但第 9 步任务包总览未落任何 TP——
  属任务包分配缺口，需协调者补裁决/立项（本轮只读，未改）。

## 4. 结论分层

### A. 需设计裁决（不裁决则源码不可写）
1. **DEVICE 作用域声光 ON/OFF 的意图落库承载**：现有命令表 `run_command`
   （docs/开发基线/01-完整建表.sql:3339）`culture_id BIGINT NOT NULL` + execution/step 语义 +
   operation 注释 'SET_AUTO/START/SET_SPEED/STOP/RESTART'，与声光"不要求 cultureId"（M09 页面契约
   :5、:163）冲突；代码枚举 `domain/vo/m07/CommandOperation.java:16` 同样无 ON/OFF。
   M02 侧亦无声光命令意图/回执表（lab_sound_alarm:1326 为资产维护表）。
   "由M02命令保存ON/OFF意图与回读"（通知投递与恢复契约:57）目前无表结构/枚举承接。
   裁决选项（供参考，不预设）：扩 run_command+操作注册表（把 M07 域表开放给 M02 编排，需评估
   culture_id NOT NULL 语义）／新建 M02 设备命令意图表与操作注册表／M02 定义独立声光命令子契约。
2. **M09 消费方登记澄清**：把 M09 补入 Port 消费表，或规定 M09-016 经 M02 内部应用服务而非
   DeviceCommandPort 物理签名。
3. **"聚合引用计数"能力规格**：多条件共享声光的引用计数由 M02 适配器提供；未提供即该通道
   BLOCKED（骨架清单:9663）——能力接口未定义，需裁决后补契约。

### B. 缺客户输入（BLOCKED_INPUT，AGENTS §10）
- 声光设备真实网关/适配器参数：adapterInstanceId 口径、executor control_proof、设备协议、
  核准操作与单位。现有 `futurefab-sdms-client`（SDMS 文档）与 `futurefab-namedpipe-client`
  （BGA/Cedex 检测）均非声光/泵控执行通道，**无可复用命令通道**。

### C. 可实施的源码工作（裁决 A 完成后，不依赖真实设备）
- 提供方应用服务（实现 DeviceCommandPort）＋意图持久化 Mapper/XML＋状态机 CAS/幂等拒绝/
  UNKNOWN 查单语义/适配器缺失抛 DEPENDENCY_UNAVAILABLE（适配器边界以受控配置 stub，状态停
  UNKNOWN，不伪造回执）。
- 最小充分测试（内存替身契约级，沿 M02Wired* 模式）：①同键异载荷拒绝不生成新动作；
  ②INVOKING 先持久化、网络调用出事务（替身断言顺序）；③超时→UNKNOWN 不结算不释放；
  ④queryCommand 不重发；⑤来源不可用抛依赖异常而非伪 NOT_FOUND；⑥旧 fence 新写拒绝、
  同 commandId 同 hash 重放返回原证据；⑦声光目标绑定校验（反应器 ID 顶替→拒绝）。
- 无 HTTP 入口（内部 Port），不需要 ManagementOperation/AuditPolicyRegistry/skeleton 变更登记，
  直至裁决引入新 HTTP 面。

### D. 仅真实设备验收受阻
- 物理派发/回读、停止证据、现场声光确认——在 A、B 解决且 C 落地后仍需现场验收（不得以
  契约测试冒充）。

**判定**："缺设备环境"不自动等于"源码无法开发"；但本通道当前主要阻塞在 A（设计裁决缺口），
其次 B；纯 D 层描述不成立。

## 5. 与在途任务的文件冲突范围

- **TP-M02-14（在线业务观测）**：文件集 M02Observation*/Observation*（68ad4b1a 已提交），与命令
  通道零交集。
- **TP-M02-07**：仅通讯配置面；若裁决 A① 选"新建 M02 意图表"，新文件不触碰其 M02-193…211 文件。
- **M09 批次**：AlarmSoundCommandV2Controller / AlarmSoundCommandApplication(+Impl m09) 归 M09
  批次（work7 在途，存在 .worktrees/m09-batch2-010-012）；提供方实现**不得**改这些文件。
- 建议新增文件全部位于 `service/impl/application/m02/`、`service/port/m02/`（只读引用）、
  `mapper`＋`resources/mapper/lab/` 新文件、`src/test/.../contract/` 新测试类，与上述无冲突。

## 6. 验证层级声明

本轮为**只读静态证据核查**（文档/代码/DDL 行号复核）；未运行测试、未启动服务、未执行 SQL。
所有结论标注为 DOCUMENT_VERIFIED / CODE_STATIC_VERIFIED；HTTP、浏览器、MySQL、现场均
NOT_VERIFIED。
