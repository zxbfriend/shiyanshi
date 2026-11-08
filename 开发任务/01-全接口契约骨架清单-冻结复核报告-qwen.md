# 全接口契约骨架清单冻结复核报告（qwen 独立复核）

> 复核版本：`FREEZE-20260918-QWEN-01`
> 复核对象：`docs/开发任务/00-全接口契约骨架清单` v2.1（JSON 为唯一机器可读权威）
> 复核范围：M01—M07、M09；M08 完全排除
> 复核方式：只读解析 + 静态硬门禁脚本（UTF-8），未重新生成、未重写、未修改清单与任何业务代码
> 复核结论：**通过（11/11 项硬门禁全部满足）**

## 1. 复核依据与权威输入

本次复核仅以下列已冻结产物为输入，未从需求、现有代码或历史稿重新推导接口：

1. `docs/开发任务/00-全接口契约骨架清单.json`（v2.1，机器可读唯一权威，532 条 canonical 记录）
2. `docs/开发任务/00-全接口契约骨架问题收口决策.md`（CLOSE-20260918-04：旧路由处置、物理字段口径、生成门禁）
3. `docs/开发任务/00-全接口契约骨架清单.md`（逐接口人工复核视图，用于与 JSON 双向核对）
4. `docs/详细设计/01—07、09-*/物理接口与骨架字段设计.md`（8 份模块物理命名与 Mapper 适用性依据）

若人机读文档与 JSON 出现差异，应以停止生成为先；本复核未发现此类差异（见第 4 节 MD↔JSON 双向一致）。

## 2. 硬门禁逐项复核结果

判定口径：任一项 FAIL 即整体不通过。以下为脚本实测值，非人工估算。

| # | 门禁 | 期望 | 实测 | 判定 |
| --- | --- | --- | --- | --- |
| 1 | JSON 可解析（只读） | 可解析 | UTF-8 解析成功 | 通过 |
| 2 | canonical 接口总数 | 532 | `len(interfaces)=532` | 通过 |
| 3 | `unresolved_design_blockers` | 0 | 0 | 通过 |
| 4 | `contract_state` | `SKELETON_CONTRACT_READY` | `SKELETON_CONTRACT_READY` | 通过 |
| 5 | M08 接口数量 | 0 | 0（实际模块集合=M01,M02,M03,M04,M05,M06,M07,M09） | 通过 |
| 6 | 重复 HTTP method+path | 0 | 0（532 条 method+path 全部唯一） | 通过 |
| 7 | 每条接口 Controller / Request / Response / Service 接口+实现 / 权限 非空 | 532 条×9 项非空 | 缺失记录 0 条 | 通过 |
| 8 | Mapper 适用性仅 `REQUIRED`/`NOT_APPLICABLE` 且字段匹配 | 无违规 | `REQUIRED=494`（三项 Mapper 字段均非空）、`NOT_APPLICABLE=38`（三项均空），违规 0 | 通过 |
| 9 | 物理字段不含 `TARGET:` / `TBD-MISSING` | 0 处 | 可生成结构字段 0 处（见第 5 节说明） | 通过 |
| 10 | 不修改业务代码 / 不重推接口名 / 不覆盖现有清单 | 是 | 仅只读 + 新建本 `-qwen` 报告，未改动 JSON/MD 清单及任何业务代码 | 通过 |
| 11 | 输出本冻结复核报告 | 生成 | 本文件 | 通过 |

补充说明：第 7 项“非空”校验的 9 个字段为 `controller_class`、`controller_method`、`request_dto`、`response_vo`、`service_interface`、`service_method`、`service_impl_class`、`service_impl_method`、`permission`。`request_dto=NoBody`、`response_vo=EmptyResult`/`BinaryFileResponse` 为显式占位语义，均为非空字符串，符合收口口径，不视为缺失。

## 3. 规模与路由处置统计（实测）

| 模块 | canonical 接口数 |
| --- | ---: |
| M01 系统管理 | 76 |
| M02 实验室与资源管理 | 255 |
| M03 项目与培养管理 | 43 |
| M04 工艺与方案管理 | 23 |
| M05 检测与数据签批 | 64 |
| M06 流程审批管理 | 15 |
| M07 补液运行与任务执行 | 35 |
| M09 告警与通知管理 | 21 |
| **合计** | **532** |

路由处置（5 态）：`ADJUST` 324、`NEW` 176、`REUSE` 7、`COMPAT` 9、`DISABLE` 16，合计 532，与清单一一对应。

Mapper 适用性：`REQUIRED` 494 条、`NOT_APPLICABLE` 38 条，合计 532，与 `00-全接口契约骨架问题收口决策.md` 第 5.6 节硬门禁口径完全一致。

## 4. 一致性支持项（非编号门禁，作为佐证）

- MD↔JSON 双向核对：MD 唯一 `interface_id` = 532，JSON = 532，MD 独有 0、JSON 独有 0，逐条一一对应。
- `consistency_problems` 共 31 条：`EXISTING_CODE_SHARED_METHOD` 30 条、`OVERLOADED_METHOD_NAME` 1 条。均为“现有代码方法被多个路由共用/同名重载”的现状记录，属实现层信息，不构成 canonical 路由重复、不构成设计未决，也不触发第 6 项重复门禁。
- `implementation_state = NOT_STARTED`：符合“设计已收口、代码尚未实现”的当前阶段，不影响第 2—9 项契约骨架门禁。

## 5. 关于 `TARGET:` / `TBD-MISSING` 的边界说明（保持透明）

- 门禁第 9 项检查的是**生成器消费的可生成结构字段**（Controller、DTO/VO、Service 接口/实现、Mapper 接口/方法/XML statement、权限），这些字段中 `TARGET:` 与 `TBD-MISSING` 出现次数均为 0。
- 全文范围内另有 3 处 `TARGET:` 字样，均出现在 `notes` 叙述字段（`M06-006`、`M06-009`、`M06-014`），内容是对“同事务经 `TARGET:AprPolicyRevisionMapper.insert…` / `TARGET:AprActionMapper.insertAction`”这类落库路径的解释说明，**不属于**任何物理命名结构字段，不影响骨架生成，也不构成未决设计。
- 全清单无 `TBD-MISSING` 残留；`unresolved_design_blockers=0` 与之自洽。

## 6. 第 3 步生成约束（承接，供执行者遵守）

1. 以 JSON 的 `interface_id`、包、类、方法、DTO/VO、权限、Mapper 字段**原样生成**，禁止按路由或契约 ID 重新猜名。
2. Controller 不直连 Mapper、不跨模块直接访问他模块 Mapper 或表；跨模块只走冻结的 Port。
3. 所有未实现业务逻辑统一显式返回开发态 `NOT_IMPLEMENTED`，不得返回空成功、`null`、0 或伪造业务数据。
4. `REQUIRED` 生成 Mapper 接口方法 + XML statement 骨架；`NOT_APPLICABLE` 不生成空 Mapper 占位。
5. `COMPAT` 仅生成协议适配入口并复用同一 canonical 应用端口，不生成第二套 Service/Mapper；`DISABLE` 只生成停用守卫，不调用旧业务 Mapper。
6. M08 不进入生成范围。
7. 每个业务包完成后重跑本报告第 2 节同一门禁；出现路由、接口 ID、物理名或 Mapper 适用性差异即停止，不得自行修订冻结契约。

## 7. 验证边界声明

本次为**设计产物只读复核 + 静态一致性检查**：未生成、未修改任何 Java/XML/Vue/SQL 业务代码，未运行编译、单元测试、契约测试、SQL、HTTP 联调或设备验收。代码生成后的正确性须在第 3 步及后续实现验收中单独证明。

## 8. 最终判定

**第2步完成，可以进入第3步全接口契约骨架生成。**

第 3 步输入（532 条 canonical 契约、物理命名、Mapper 适用性、旧路由处置、跨模块 Port）已冻结；除非需求或权威详细设计发生正式变更，无需重新生成第 2 步清单。
