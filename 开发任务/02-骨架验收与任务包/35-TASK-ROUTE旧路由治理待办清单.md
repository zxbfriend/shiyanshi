# 35-TASK-ROUTE 旧路由治理待办清单

- 时间：2026-09-20
- 性质：**待办登记文档**。本任务未修改任何 Controller/Service/Mapper/XML/SQL/Vue 源码，未删除任何端点；所有处置均为"待裁决"选项登记。
- 依据：`31-第8步全量骨架验收复核审计报告.md/.json`（合并定稿版）§16 P2-2/P2-3、§19 第 6 项；`10-全接口契约骨架覆盖审计.md/.json` §九（M01 历史口径）；AGENTS.md §8。
- 关联：此前用户已就 M01 46 条旧路由登记 TASK-ROUTE 待办（尚未逐项裁决）。

## 1. 既有历史口径（M01）

- 10 号审计登记 `source_routes_not_in_inventory` = **46 条未登记旧路由**（`/system` 域 export/import/authRole/dataScope/updateSort/clean/dict 删除/operlog 写入等旧实现残留端点），**均不属于 76 条冻结入口**；76 条骨架入口已双向核对 0 缺（清单→源码 76/76 EXACT；源码→清单差集即这 46 条）。
- 该 46 条已归入 **TASK-ROUTE** 治理包，处置选项口径为四选一：`DISABLE`（禁用下线）/ `COMPAT`（保留兼容并登记映射）/ `移除`（确认无消费方后删除代码）/ `保留待裁决`。截至本清单日期未逐项裁决。
- 本清单不重复枚举 46 条明细，明细以 10 号审计 §九 为唯一登记源。

## 2. 31 审计新发现：M02–M09 同类残留尚未逐个登记（P2-3）

**已取证事实（31 审计静态实算 + 本次引用）：**

1. `controller/` 目录下仍持有 Mapper import 的存量文件恰 **1 个**：`ResCultureController`——持有 `ResCultureMapper`，并保留 `/list-by-batch/{batchId}`、`/export`、add/edit/remove 等**旧实现端点**；这些端点**不在 532 条冻结清单内**；新增骨架入口均已改走 `application.m0x`。
2. 改写后 Controller 残留**未使用的旧 `I*Service` 注入字段**（P2-2 死代码）：`BottleConfigController.bottleConfigService`、`CalibrationObjectController.calibrationObjectService`、`ConsumableMasterController.consumableMasterService`（仅剩 import + 字段、零调用）。注：`LabBalanceController`、`LabBenchReactorController` 的同名字段仍有真实调用，**不属**此项（31 审计 P2-2 括注）。
3. 除上述已点名项外，**M02–M09 全域旧路由/旧端点尚未像 M01 那样做"源码→清单"双向差集登记**，实际条数待治理包启动时程序化盘点（预期方法：以 `controller/` 全量 `@RequestMapping` 注解与 26 清单 532 条 canonical route 做差集，产出同 10 审计 §九 格式的登记表）。

## 3. 待办任务包登记（建议拆分，不改动源码）

| 待办 ID | 范围 | 动作 | 状态 |
| --- | --- | --- | --- |
| ROUTE-M01 | M01 46 条（10 审计 §九） | 逐条给出 DISABLE/COMPAT/移除/保留待裁决 四选一决策并落文档 | 已登记，**待用户裁决**（含 049 相关遗留口径） |
| ROUTE-M02-09-INVENTORY | M02–M09 存量 `controller/` | 程序化双向差集盘点，产出未登记旧路由清单（只读脚本 + 登记表，不触源码） | 待启动 |
| ROUTE-RESCULTURE | `ResCultureController`（持 Mapper + 旧端点） | 纳入 ROUTE-M02-09-INVENTORY 首案；裁决旧端点去向与 Mapper 依赖解除方案 | 已点名登记，待裁决 |
| ROUTE-DEADINJECT | P2-2 三处死 `I*Service` 注入字段 | 归入对应模块（M02 相关）**真实实现任务**顺带清理，不单独立改动提交 | 已登记，随模块开发处置 |

## 4. 第9步硬约束（写入 33 基线的引伸）

1. **第9步任何开发任务包的实现范围 = 26 清单 532 条冻结契约**（其中可分配 515 条）；**不得**把上述旧路由残留、旧端点、死注入当作"冻结接口实现"的一部分去完成或验收。
2. 旧路由在 TASK-ROUTE 裁决前**保持原样不触碰**：不删除、不改映射、不新增功能；无骨架入口与之共用方法名的，以 `SkeletonEngineShadowFixtureTest` 口径防同名遮蔽漂移。
3. 若某条旧端点被裁决为 COMPAT，其映射登记须进入对应模块契约文档并补契约测试，不允许"沉默兼容"。
4. 治理包的验证同样遵守 33 规则 12：静态盘点/编译/契约测试之外不得宣称"已下线/已验证无消费方"——消费方证据需真实 HTTP 访问日志或客户确认，当前均未取得。

## 5. 明确声明

- 本文档仅登记待办与取证事实引用，未执行任何源码修改、端点删除或路由变更。
- 明细清单生成（ROUTE-M02-09-INVENTORY）待用户批准启动后以只读脚本产出，产出物并入本文件或 36 号文档，不另立平行权威。
