# 下游 Dashboard 设备逻辑文档

本文档集整理 `NPPGUI/views/downBio/dashboard` 页面中设备数据的采集、计算、保存和撤销逻辑，并结合 `Backed/INNOVEL.NPP.Business.Implement/Dashboard/DashboardService.cs` 及相关服务说明后端处理规则。

如果需要从产品经理、测试或实施角度阅读业务规则、案例规范和待确认项，请优先阅读 [product-view/README.md](product-view/README.md)。当前目录下的 `01` 到 `05` 文档偏技术实现和字段链路。

## 阅读路径

| 视角 | 入口 | 适合对象 |
| --- | --- | --- |
| 产品视角 | [product-view/README.md](product-view/README.md) | 产品经理、测试、实施、业务负责人 |
| 技术实现视角 | 本文档下方文档范围 | 前后端开发、排障人员 |

## 文档范围

| 设备类型 | 文档 | 前端设备类型 | 主要后端入口 |
| --- | --- | ---: | --- |
| 称重 | [01-称重逻辑.md](01-称重逻辑.md) | 1 | `DashboardService.InsertPreBatchTestingDtl` |
| 多参数仪 pH / Cond. | [02-多参数仪逻辑.md](02-多参数仪逻辑.md) | 5 | `MultiParamterService.PhOrCondTest` |
| 密度计 | [03-密度逻辑.md](03-密度逻辑.md) | 3 | `DashboardService.DensityCapture` |
| 浓度 | [04-浓度逻辑.md](04-浓度逻辑.md) | 7、11 | `DashboardService.QuerryConc` / `SaveConcResult` / `SoloVPEQuerry` |
| 完整性测试仪 | [05-完整性测试仪逻辑.md](05-完整性测试仪逻辑.md) | 9 | `Sartocheck4plusOrderSend` / `RefreshSartocheck4plusResult` |

## 共同页面入口

- 页面控制器：`NPPGUI/views/downBio/dashboard/dashboardController.js`
- 页面模板：`NPPGUI/views/downBio/dashboard/dashboard.html`
- 后端服务：`Backed/INNOVEL.NPP.Business.Implement/Dashboard/DashboardService.cs`
- 设备列表接口：`downDashboardRes.getDeviceQuerryList({ type })`

页面初始化时加载设备类型：

| 页面变量 | type | 含义 |
| --- | ---: | --- |
| `scaleList` | 1 | 秤 |
| `DensityEqus` | 3 | 密度计 |
| `PHEqus` | 5 | 多参数仪 pH |
| `CONDEqus` | 5 | 多参数仪电导 |
| `CONCEqus` | 7 + 11 | 光度计 / SoloVPE 浓度设备 |
| `FilterEqus` | 9 | 完整性测试仪 |

## 通用操作类型

| OperationType | 含义 | 常见来源 |
| ---: | --- | --- |
| 1 | Capture / 采集 | 设备直接采集 |
| 3 | Save / 保存 | 浓度保存等 |
| 5 | Cancel / 撤销 | 清除当前测试结果并记录撤销原因 |
| 7 | CALC / 计算 | 称重净重计算 |

## 通用测试项

`EnumTestItem` 定义了 Dashboard 中主要测试项：

| TestItem | 名称 |
| ---: | --- |
| 1 | Tare Weight(g) |
| 3 | Gross Weight(g) |
| 5 | Net Weight(g) |
| 7 | Gross Weight(g)(After sampling) |
| 9 | Net Weight(g)(After sampling) |
| 11 | pH |
| 13 | Cond. |
| 15 | Conc.(ug/mL) |
| 21 | Density |
| 23 | FilterIntegrityTest |

## 通用规则比较

`DashboardService.CheckDensityValue(symbol, value, actual)` 被多个模块复用为通用规则比较函数，支持：

- `<`
- `<=`
- `>`
- `>=`
- `=`
- `!=`
- `≤`
- `≥`

虽然函数名包含 Density，但实际也用于浓度 RSD、Blank 浓度、SoloVPE RSD/RSqr 等规则判断。
