# SubSystem Named Pipe 接口文档

> 文档来源：`BGAService`、`CedexOrderService`、`CedexService`、`OsmoSixService`、`ViCellService`  
> 生成日期：2026-06-15

---

## 1. 通信协议总览

### 1.1 管道地址（Pipe Name）

| 子系统 | 服务类 | Pipe 名称 | 启动方法 |
|--------|--------|-----------|----------|
| BGA | `BGAService` | `BGAService` | `StartServerPipe("BGAService")` |
| Cedex 设备配置 | `CedexService` | `CedexPipe` | `StartServerPipe("CedexPipe")` |
| Cedex 订单 | `CedexOrderService` | `CedexOrderPipe` | `StartServerPipe("CedexOrderPipe")` |
| OSMO 6060 | `OsmoSixService` | `OsmoSixPipe` | `StartServerPipe("OsmoSixPipe")` |
| ViCell XR | `ViCellService` | `VicellPipe` | `StartServerPipe("VicellPipe")` |

**客户端连接方式：** 使用 Windows Named Pipe，管道名即为上表中的 Pipe 名称（本地连接）。

### 1.2 请求报文格式

```
{command}|{payload}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| command | string | 命令名称，与各 Service 中 `AddProcessor` 注册名一致 |
| payload | string | 业务参数；无参数时传空字符串，但 **必须保留分隔符 `\|`** |

**示例：**

```
log_in_check|
result|J
log_in|[{"SampleID":"S001","RackNo":"J","TubeNo":1}]
```

> 若请求不符合 `command|payload` 两段格式，返回 `SubsystemParamsError`。

### 1.3 响应报文格式

```
{CommandName}|{ErrorCode}|{ResultDataJSON}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| CommandName | string | 回显请求命令名 |
| ErrorCode | long (十六进制字符串) | 由 `ErrorCodeLevel` + `ErrorType` + `SubsystemErrorNumber` 拼接后转 16 进制 |
| ResultDataJSON | string | 成功或失败时的附加数据 JSON；无数据时为空字符串 |

**ErrorCode 组成：**

| 组成部分 | 格式 | 说明 |
|----------|------|------|
| ErrorCodeLevel | 2 位十六进制 | `SuccessLevel` = 成功；`ErrorLevel` = 失败 |
| ErrorType | 2 位十六进制 | 通常为 `SubsystemErrorType` |
| SubsystemErrorNumber | 4 位十六进制 | 具体业务错误码枚举值 |
| 后缀 | `00000000` | 固定填充 |

---

## 2. 公共响应对象 NamePipeResult

| 属性/字段 | 类型 | 说明 |
|-----------|------|------|
| CommandName | string | 命令名称（内部赋值，响应时回显） |
| ErrorLevel | ErrorCodeLevel | 错误级别（只读） |
| _errorCodeLevel | ErrorCodeLevel | 错误级别 |
| _errorType | ErrorType | 错误类型 |
| _subsystemErrorNumber | SubsystemErrorNumber | 子系统错误编号 |
| _resultData | object | 附加返回数据，序列化为 JSON 写入响应第三段 |

**构造函数：**

| 签名 | 说明 |
|------|------|
| `NamePipeResult(SubsystemErrorNumber, object resultData = null)` | 根据 errorNumber 是否为 0 自动判定 Success/Error |
| `NamePipeResult(ErrorCodeLevel, ErrorType, SubsystemErrorNumber, object resultData = null)` | 完整指定各级错误信息 |

---

## 3. BGA 子系统（Pipe: `BGAService`）

### 3.1 接口一览

| 命令 | 入参 payload | 出参 ResultData | 功能说明 |
|------|--------------|-----------------|----------|
| `log_in_check` | 无（空） | 无 / 错误码 | 登录前可用性检查（含校准、测样间隔等） |
| `log_in` | `RequestOrderModel` JSON | 无 | Core Service 自动下单（Mode=3） |
| `sendOrder` | `RequestOrderModel` JSON | 无 | UI 手动下单 |
| `cancel` | 无 | 无 | 取消当前待处理订单（Status 1→99） |
| `cancel_sample` | sampleId 字符串 | 无 | 按 SampleID 取消样品 |
| `result` | 无 | int（任务状态码） | 查询最近一次检测任务状态 |
| `refreshResult` | sampleId JSON 字符串 | 无 | 刷新指定样品检测结果 |
| `queryPortName` | 无 | `List<string>` 串口列表 | 查询可用 COM 口 |
| `saveDevice` | `TestingBGADevice` JSON | 无 / IP 字符串 | 保存/更新 BGA 设备串口配置 |

### 3.2 命令详情

#### 3.2.1 log_in_check

| 项目 | 内容 |
|------|------|
| 请求 | `log_in_check\|` |
| 成功 | `SubsystemSuccess` |
| 失败 | 见下方常见错误码 |

**常见失败错误码：**

| SubsystemErrorNumber | 含义 |
|---------------------|------|
| BGANotRunning | 设备未配置或未运行 |
| BGADeviceException | 设备号/型号异常 |
| BGAOtherSampleTesting | 有其他样品正在检测或测样间隔不足 |
| BGATwoPointCheckDoing | 两点校准进行中或即将到期 |
| BGATwoPointCheckMissing | 缺少两点校准记录 |
| BGAOnePointCheckMissing | 缺少一点校准记录 |
| BGAOnePointCheckDoing | 一点校准进行中 |
| BGAFiveMintusTip | 5 分钟校准提示 |
| BGASampleSended | 样品已发送 |
| BGAJsonException | JSON 解析异常 |
| BGASubSystemError | 系统异常 |

#### 3.2.2 log_in

| 项目 | 内容 |
|------|------|
| 请求 | `log_in\|{RequestOrderModel JSON}` |
| 入参对象 | `RequestOrderModel`（见 3.3.1） |
| 业务逻辑 | 自动填充 BGADeviceID、Mode=3、Created_by=0；TEMP 默认 33 |
| 成功 | `SubsystemSuccess` |
| 失败 | `BGANotRunning` / `BGADeviceException` / `BGAJsonException` / CheckAvailability 相关错误 |

#### 3.2.3 sendOrder

| 项目 | 内容 |
|------|------|
| 请求 | `sendOrder\|{RequestOrderModel JSON}` |
| 入参对象 | `RequestOrderModel` |
| 与 log_in 差异 | 不强制 Mode=3，会保存 Order 信息 |
| 成功 | `SubsystemSuccess` |

#### 3.2.4 cancel

| 项目 | 内容 |
|------|------|
| 请求 | `cancel\|` |
| 成功 | `SubsystemSuccess` |
| 失败 | `BGASubSystemError` |

#### 3.2.5 cancel_sample

| 项目 | 内容 |
|------|------|
| 请求 | `cancel_sample\|{sampleId}` |
| 入参 | sampleId：样品编号字符串（非 JSON） |
| 成功 | `SubsystemSuccess` |

#### 3.2.6 result

| 项目 | 内容 |
|------|------|
| 请求 | `result\|` |
| 出参 ResultData | int：最近任务 Status；0 表示无记录；7~14 映射为 7 |
| 成功 | `SubsystemSuccess` + 状态码 |

#### 3.2.7 refreshResult

| 项目 | 内容 |
|------|------|
| 请求 | `refreshResult\|"{sampleId}"` （JSON 字符串形式的 sampleId） |
| 业务逻辑 | 任务 Status 为 3/5/7 且有 SEQNo 时发送 SMP_REQ |
| 成功 | `SubsystemSuccess` |
| 失败 | `BGAUnkownTestingTask` / `BGASubSystemError` |

#### 3.2.8 queryPortName

| 项目 | 内容 |
|------|------|
| 请求 | `queryPortName\|` |
| 出参 ResultData | `List<string>`，如 `["COM1","COM3"]` |
| 失败 | `BGAUnKownPort`（无可用串口）/ `SubsystemError` |

#### 3.2.9 saveDevice

| 项目 | 内容 |
|------|------|
| 请求 | `saveDevice\|{TestingBGADevice JSON}` |
| 入参对象 | `TestingBGADevice`（见 3.3.2） |
| 成功 | `SubsystemSuccess` |
| 失败 | `BGASubDeviceMacOrIpOrDeviceNoRepeat`（ResultData 可能为已有 SubSystemIP）/ `BGAJsonException` |

### 3.3 数据模型

#### 3.3.1 RequestOrderModel

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| TestingBGAOrderID | int | 否 | 订单 ID，0 表示新建 |
| SampleID | string | 是 | 样品编号 |
| Position | int? | 否 | 位置 |
| TEMP | decimal? | 否 | 温度，默认 33℃ |
| SaveStatus | bool? | 否 | 保存状态 |
| BGADeviceID | int | 否 | 设备 ID（服务端可自动填充） |
| BatchID | int? | 否 | 批次 ID |
| BatchOPID | int? | 否 | 批次 OP ID |
| IsDelete | bool | 否 | 删除标记 |
| Mode | int | 否 | 模式；log_in 时强制为 3 |
| Created_by | int? | 否 | 创建人 |
| Creation_time | DateTime? | 否 | 创建时间 |
| Status | int | 否 | 状态 |

#### 3.3.2 TestingBGADevice

| 字段 | 类型 | 说明 |
|------|------|------|
| BGADeviceID | int | 设备主键，>0 为更新 |
| SubSystemMAC | string | 子系统 MAC（保存时自动填充） |
| SubSystemIP | string | 子系统 IP |
| SubSystemDeviceNo | string | 子系统设备号 |
| TestingEquipmentID | int | 检测设备 ID |
| DeviceNo | string | BGA 仪器编号 |
| DeviceModel | string | BGA 仪器型号 |
| SerialPortName | string | 串口名 |
| SerialPortBaudRate | int? | 波特率 |
| SerialPortDataBits | int? | 数据位 |
| SerialPortStopBits | string | 停止位 |
| SerialPortParity | string | 校验位 |
| SerialPortFlowType | string | 流控 |
| IsDelete | bool | 删除标记 |
| Created_by | int? | 创建人 |
| Creation_time | DateTime? | 创建时间 |
| Last_updated_by | int? | 更新人 |
| Last_update_time | DateTime? | 更新时间 |

---

## 4. Cedex 设备配置子系统（Pipe: `CedexPipe`）

### 4.1 接口一览

| 命令 | 入参 payload | 出参 ResultData | 功能说明 |
|------|--------------|-----------------|----------|
| `get_port_names` | 无 | `List<string>` | 获取可用串口列表 |
| `save_subsystem_device` | `CedexPortModel` JSON | 无 / SubSystemIP | 保存/更新 Cedex 设备配置 |

### 4.2 命令详情

#### 4.2.1 get_port_names

| 项目 | 内容 |
|------|------|
| 请求 | `get_port_names\|` |
| 出参 | 串口名称列表 |
| 成功 | `SubsystemSuccess` |

#### 4.2.2 save_subsystem_device

| 项目 | 内容 |
|------|------|
| 请求 | `save_subsystem_device\|{CedexPortModel JSON}` |
| 入参对象 | `CedexPortModel`（见 4.3.1） |
| 成功 | `SubsystemSuccess` |
| 失败 | `CedexSubSystemDeviceRepeat` / `CedexSubSystemDeviceMacAddressRepeat`（ResultData=已有IP）/ `CedexSubSystemComportError` / `CedexSubSystemError` |

### 4.3 数据模型

#### 4.3.1 CedexPortModel

| 字段 | 类型 | 说明 |
|------|------|------|
| CedexDeviceID | int | 设备主键，>0 为更新 |
| SubSystemIP | string | 子系统 IP |
| DeviceIP | string | Cedex 设备 IP |
| SubSystemMAC | string | 子系统 MAC（保存时自动填充） |
| SubSystemDeviceNo | string | 子系统设备号 |
| TestingEquipmentID | int | 检测设备 ID |
| SerialPortName | string | 串口名 |
| SerialPortBaudRate | int? | 波特率 |
| SerialPortDataBits | int? | 数据位 |
| SerialPortStopBits | string | 停止位 |
| SerialPortParity | string | 校验位 |
| SerialPortFlowType | string | 流控 |
| IsDelete | bool | 删除标记 |
| Created_by | int? | 创建人 |
| Creation_time | DateTime? | 创建时间 |
| Last_updated_by | int? | 更新人 |
| Last_update_time | DateTime? | 更新时间 |

---

## 5. Cedex 订单子系统（Pipe: `CedexOrderPipe`）

### 5.1 接口一览

| 命令 | 入参 payload | 出参 ResultData | 功能说明 |
|------|--------------|-----------------|----------|
| `log_in_check` | 无 | 无 | 检查 Cedex 是否运行且未在处理订单 |
| `log_in` | `List<CoreTestingModel>` JSON | 无 | Core Service 自动下单 |
| `send_orders` | `List<TestingOrder>` JSON | 无 | UI 手动批量下单 |
| `result` | rack 字符串 | int | 查询指定 Rack 最近任务状态 |
| `empty_racks` | 无 | string（逗号分隔 Rack 字母） | 查询空闲 Rack 列表 |

### 5.2 命令详情

#### 5.2.1 log_in_check

| 项目 | 内容 |
|------|------|
| 请求 | `log_in_check\|` |
| 前置条件 | `CedexOrderForm.IsCedexRunning == true` 且 `SendOrderProcess != "True"` |
| 成功 | `SubsystemSuccess` |
| 失败 | `CedexNotRunning` / `SubsystemError` |

#### 5.2.2 log_in

| 项目 | 内容 |
|------|------|
| 请求 | `log_in\|[{CoreTestingModel},...]` |
| 入参 | `List<CoreTestingModel>`（见 5.3.1） |
| 校验 | Rack 不可占用；SampleID 不可重复 |
| 成功 | `SubsystemSuccess` |
| 失败 | `CedexNotRunning` / `CedexMissingDevice` / `CedexSubSystemRackNotEmpty`（ResultData=冲突Rack）/ `CedexSubSystemSampleIdRepeat` / `CedexSubSystemOrdersError` |

#### 5.2.3 send_orders

| 项目 | 内容 |
|------|------|
| 请求 | `send_orders\|[{TestingOrder},...]` |
| 入参 | `List<TestingOrder>`（见 5.3.2） |
| 校验 | Rack 不可占用；Tube 位置不可占用；SampleID 不可重复 |
| 成功 | `SubsystemSuccess` |
| 失败 | 同 log_in，另含 `CedexSubSystemTubeNotEmpty` |

#### 5.2.4 result

| 项目 | 内容 |
|------|------|
| 请求 | `result\|{rack}` |
| 入参 | rack：Rack 字母，如 `J`、`K` |
| 出参 ResultData | int：`0` 无任务；`5` 检测中；`7` 已完成 |
| 成功 | `SubsystemSuccess` + 状态码 |

#### 5.2.5 empty_racks

| 项目 | 内容 |
|------|------|
| 请求 | `empty_racks\|` |
| 出参 ResultData | string：空闲 Rack 字母，逗号分隔，如 `"J,K"` |
| Rack 范围 | 候选：J、K、L、M、N |
| 成功 | `SubsystemSuccess` |

### 5.3 数据模型

#### 5.3.1 CoreTestingModel

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| SampleID | string | 是 | 样品编号 |
| RackNo | string | 是 | Rack 字母（J/K/L/M/N） |
| TubeNo | int | 是 | 试管位置号 |
| BatchId | int? | 否 | 批次 ID |
| BatchOPId | int? | 否 | 批次 OP ID；为空时走 MSAT 检测项 |
| Code | string | 否 | OP 子步骤 Code |

#### 5.3.2 TestingOrder

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| SampleID | string | 是 | 样品编号 |
| DeviceId | int | 是 | Cedex 设备 ID |
| BatchID | int? | 否 | 批次 ID |
| BatchOPID | int? | 否 | 批次 OP ID |
| RackPostionNo | int | 是 | Rack 枚举值（对应 EnumCedexPostion） |
| TubePostionNo | int | 是 | 试管位置 |
| SampleRemake | string | 否 | 样品备注 |
| ManualDilutionFactor | int | 否 | 手动稀释因子，默认 1 |
| UpdateBy | int | 是 | 更新人 |
| testingOrderItems | List\<TestingOrderItem\> | 是 | 检测项目列表 |

#### 5.3.3 TestingOrderItem

| 字段 | 类型 | 说明 |
|------|------|------|
| TestingNo | string | 检测项编号 |
| SpecticFactor | int | 系数，默认 1 |
| Code | string | OP Code |

#### 5.3.4 TestingOrderDefItem

| 字段 | 类型 | 说明 |
|------|------|------|
| IsCheck | bool | 是否选中 |
| TestingNo | string | 检测项编号 |
| TestingName | string | 检测项名称 |
| SpecticFactor | int | 系数，默认 1 |

#### 5.3.5 EnumCedexPostion（Rack 位置）

| 枚举名 | 字母 |
|--------|------|
| J | J |
| K | K |
| L | L |
| M | M |
| N | N |

---

## 6. OSMO 6060 子系统（Pipe: `OsmoSixPipe`）

### 6.1 接口一览

| 命令 | 入参 payload | 出参 ResultData | 功能说明 |
|------|--------------|-----------------|----------|
| `log_in_check` | 无 | 无 | 登录前检查设备与连接状态 |
| `log_in` | `List<OsmoPROResult>` JSON | 无 | Core Service 自动登录样品（Mode=3） |
| `order` | `List<OsmoPROResult>` JSON | 无 | UI 手动下单并启动检测 |
| `cancel` | 无 | 无 | 取消当前任务 |
| `start` | 无 | 无 | 启动检测（DB 状态更新） |
| `result` | 无 | int | 查询最近任务状态 |
| `del_order` | sampleID 字符串 | 无 | 删除指定样品订单 |
| `queryPortName` | 无 | `List<string>` | 查询可用串口 |
| `saveDevice` | `OSMODevice` JSON | 无 / SubSystemIP | 保存设备配置 |

### 6.2 命令详情

#### 6.2.1 log_in_check

| 项目 | 内容 |
|------|------|
| 请求 | `log_in_check\|` |
| 前置条件 | 设备已配置、`ConnectStatus=true`、`IsFinish=true` |
| 成功 | `SubsystemSuccess` |
| 失败 | `OSMONotRunning` / `OSMOSubSystemConnectError` / `OSMOSubSystemNotFinish` |

#### 6.2.2 log_in

| 项目 | 内容 |
|------|------|
| 请求 | `log_in\|[{OsmoPROResult},...]` |
| 入参 | `List<OsmoPROResult>` |
| 业务 | Mode=3，Created_by=0，自动填充 OSMODeviceID |
| 成功 | `SubsystemSuccess` |
| 失败 | `OSMOSubSystemRepeatSampleId`（ResultData=重复SampleID）/ `OSMOSubSystemPositionNo` |

#### 6.2.3 order

| 项目 | 内容 |
|------|------|
| 请求 | `order\|[{OsmoPROResult},...]` |
| 与 log_in 差异 | 会插入 Order、创建 Task、调用 Start、更新 LabDevice 状态为 2 |
| 成功 | `SubsystemSuccess` |
| 失败 | 同 log_in |

#### 6.2.4 cancel

| 项目 | 内容 |
|------|------|
| 请求 | `cancel\|` |
| 成功 | `SubsystemSuccess` |

#### 6.2.5 start

| 项目 | 内容 |
|------|------|
| 请求 | `start\|` |
| 成功 | `SubsystemSuccess` |

#### 6.2.6 result

| 项目 | 内容 |
|------|------|
| 请求 | `result\|` |
| 出参 ResultData | int：映射后状态（0~5 映射为 3；IsFinish 且 Status=5 时为 5） |
| 成功 | `SubsystemSuccess` |

#### 6.2.7 del_order

| 项目 | 内容 |
|------|------|
| 请求 | `del_order\|{sampleID}` |
| 入参 | sampleID：样品编号字符串 |
| 成功 | `SubsystemSuccess` |

#### 6.2.8 queryPortName

| 项目 | 内容 |
|------|------|
| 请求 | `queryPortName\|` |
| 出参 | `List<string>` 串口列表 |
| 失败 | `BGAUnKownPort`（无串口） |

#### 6.2.9 saveDevice

| 项目 | 内容 |
|------|------|
| 请求 | `saveDevice\|{OSMODevice JSON}` |
| 入参对象 | `OSMODevice`（见 6.3.2） |
| 失败 | `OSMOSubSystemDeviceNoRepeat` / `OSMOSubSystemDeviceMacAddressRepeat` |

### 6.3 数据模型

#### 6.3.1 OsmoPROResult

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| TestingOSMOTaskID | ulong | 否 | 任务 ID（服务端填充） |
| ItemID | int? | 否 | 项目 ID |
| BatchID | int? | 否 | 批次 ID |
| BatchOPID | int? | 否 | 批次 OP ID |
| OSMODeviceID | int | 是 | OSMO 设备 ID |
| SampleID | string | 是 | 样品编号 |
| PositionNo | int | 是 | 位置号 |
| ResultValue | decimal? | 否 | 检测结果值 |
| ResultUOM | string | 否 | 结果单位 |
| ResultTime | DateTime? | 否 | 结果时间 |
| LogInTime | DateTime? | 否 | 登录时间 |
| Status | string | 否 | 状态字符串 |
| Created_by | int? | 否 | 创建人 |
| Mode | int | 否 | 模式（log_in 时为 3） |
| DeviceNo | string | 否 | 设备号 |

#### 6.3.2 OSMODevice

| 字段 | 类型 | 说明 |
|------|------|------|
| OSMODeviceID | int | 设备主键，>0 为更新 |
| SubSystemDeviceNo | string | 子系统设备号 |
| SubSystemMAC | string | 子系统 MAC |
| TestingEquipmentID | int | 检测设备 ID |
| SubSystemIP | string | 子系统 IP |
| OSMOIP | string | OSMO 设备 IP |
| OSMOPort | int? | OSMO 端口 |
| IsDelete | bool | 删除标记 |
| Created_by | int? | 创建人 |
| Creation_time | DateTime? | 创建时间 |
| Last_updated_by | int? | 更新人 |
| Last_update_time | DateTime? | 更新时间 |
| OSMOType | int | 设备类型，固定 3（6060） |
| SerialPortName | string | 串口名 |
| SerialPortBaudRate | int | 波特率 |
| SerialPortDataBits | int | 数据位 |
| SerialPortStopBits | string | 停止位 |
| SerialPortParity | string | 校验位 |
| SerialPortFlowType | string | 流控 |

---

## 7. ViCell XR 子系统（Pipe: `VicellPipe`）

### 7.1 接口一览

| 命令 | 入参 payload | 出参 ResultData | 功能说明 |
|------|--------------|-----------------|----------|
| `save_subsysytem_setting` | `ViCellDevice` JSON | int(1) | 保存 ViCell 设备配置 |
| `log_in_check` | 无 | 无 / ResutData | 登录前检查 |
| `log_in` | `List<SampleInfo>` JSON | 无 / string / ResutData | 自动登录样品 |
| `log_in_manual` | `List<SampleInfo>` JSON | 无 / string / List\<int\> | 手动登录样品 |
| `clear` | deviceId 字符串 | 无 | 清空设备未完成订单 |
| `cancel` | 无 | 无 | 取消当前检测任务 |
| `result` | 无 | int | 查询最近任务状态 |
| `refresh` | `SampleInfo` JSON | 无 | 刷新单个样品 |
| `del_order` | sampleID 字符串 | 无 | 删除订单 |
| `reset` | 无 | 无 | 重置/重启队列 |

### 7.2 命令详情

#### 7.2.1 save_subsysytem_setting

| 项目 | 内容 |
|------|------|
| 请求 | `save_subsysytem_setting\|{ViCellDevice JSON}` |
| 入参对象 | `ViCellDevice`（见 7.3.2） |
| 前置条件 | `ViCellToolFrm.IsFinish == true`；ExcelPath 目录必须存在 |
| 出参 ResultData | 成功时返回 `1` |
| 失败 | `ViCellSubSystemNotFinish` / `ViCellExcellPathNotExist` / `ViCellIPAdressAlreadyExists` / `ViCellDeviceNoAlreadyExists` / `ViCellDeviceIsInitialization` |

#### 7.2.2 log_in_check

| 项目 | 内容 |
|------|------|
| 请求 | `log_in_check\|` |
| 前置条件 | ViCell 运行中；未完成时会尝试 Clear |
| 失败 ResultData | `ResutData`：`dataType=InitialTime`，`message=剩余秒数` |
| 失败码 | `ViCellNotRunning` / `ViCellSubSystemNotFinish` / `ViCellDeviceIsInitialization` |

#### 7.2.3 log_in

| 项目 | 内容 |
|------|------|
| 请求 | `log_in\|[{SampleInfo},...]` |
| 入参 | 1~12 个 `SampleInfo` |
| 校验 | 位置 1~12 不重复；SampleID/CellType/DilutionFactor 必填；SampleID 不重复 |
| 失败 ResultData | `ResutData`（SampleID 冲突）或位置冲突字符串 |
| 成功 | `SubsystemSuccess` |

#### 7.2.4 log_in_manual

| 项目 | 内容 |
|------|------|
| 请求 | `log_in_manual\|[{SampleInfo},...]` |
| 与 log_in 差异 | 自动模式需 BatchID+BatchOPID；检查废液上限；使用 LogInManualSampleEvent |
| 失败 | `ViCellBatchIDandBatchOPIDAreNeeded` / `ViCellWasteCountExceedLimit` / `ViCellPositionNoUsed`（ResultData=位置列表） |

#### 7.2.5 clear

| 项目 | 内容 |
|------|------|
| 请求 | `clear\|{deviceId}` |
| 入参 | deviceId：ViCell 设备 ID（整数转字符串） |
| 失败 | `ViCellNotRunning` / `ViCellSubSystemNotFinish`（仍有未完成样品） |

#### 7.2.6 cancel

| 项目 | 内容 |
|------|------|
| 请求 | `cancel\|` |
| 失败 | `ViCellNoTestingTask` |

#### 7.2.7 result

| 项目 | 内容 |
|------|------|
| 请求 | `result\|` |
| 出参 ResultData | int：任务状态映射值（常见 5=检测中，7=完成） |
| 逻辑 | Status 0~6 映射为 5；初始化中映射为 5；Status=7 且 IsFinish 时为 7 |

#### 7.2.8 refresh

| 项目 | 内容 |
|------|------|
| 请求 | `refresh\|{SampleInfo JSON}` |
| 入参对象 | `SampleInfo`（至少含 SampleID 等刷新所需字段） |
| 成功 | `SubsystemSuccess` |

#### 7.2.9 del_order

| 项目 | 内容 |
|------|------|
| 请求 | `del_order\|{sampleID}` |
| 入参 | sampleID：样品编号 |
| 成功 | `SubsystemSuccess` |

#### 7.2.10 reset

| 项目 | 内容 |
|------|------|
| 请求 | `reset\|` |
| 前置条件 | ViCell 运行且 IsFinish |
| 业务 | 异步调用 `ControlHelper.Btn_StartQueue()` |
| 成功 | `SubsystemSuccess` |

### 7.3 数据模型

#### 7.3.1 SampleInfo

| 字段 | 类型 | 必填(log_in) | 说明 |
|------|------|--------------|------|
| UnknowSampleId | string | 否 | 未知样品 ID |
| TestingVicellTaskDtlID | ulong? | 否 | 任务明细 ID |
| TestingVicellTaskID | ulong? | 否 | 任务 ID |
| PositionNo | int | 是 | 位置号 1~12 |
| SampleID | string | 是 | 样品编号 |
| CellType | string | 是 | 细胞类型 |
| DilutionFactor | decimal | 是 | 稀释因子，>0 |
| Mode | int? | 否 | 1=Manual，3=Automatic |
| ItemID | int? | 否 | 项目 ID |
| BatchID | int? | 否 | 批次 ID |
| BatchOPID | int? | 否 | 批次 OP ID |
| Comment | string | 否 | 备注 |
| Time | DateTime? | 否 | 登录时间（服务端填充） |
| ResultTime | DateTime? | 否 | 结果时间 |
| Status | string | 否 | 状态字符串 |
| DtlStatus | int | 否 | 明细状态 |
| ViCellDeviceNo | string | 否 | 设备编号 |
| ViCellDeviceID | int | 否 | 设备 ID |
| TestingEquipmentID | int | 否 | 检测设备 ID |
| VCD | decimal? | 否 | 细胞密度 |
| Viability | decimal? | 否 | 活率 |
| AvgDiam | decimal? | 否 | 平均直径 |
| ExcelFileLocation | string | 否 | Excel 文件路径 |
| Created_by | int? | 否 | 创建人 |

#### 7.3.2 ViCellDevice

| 字段 | 类型 | 说明 |
|------|------|------|
| VicellDeviceID | int | 设备主键，>0 为更新 |
| TestingEquipmentID | int | 检测设备 ID |
| SubSystemMAC | string | 子系统 MAC |
| SubSystemIP | string | 子系统 IP |
| ExcelPath | string | Excel 导出目录（必须存在） |
| WasteUpperLimit | int | 废液上限 |
| CurrentWasteCount | int | 当前废液计数 |
| IsDelete | bool | 删除标记 |
| Created_by | int? | 创建人 |
| Creation_time | DateTime? | 创建时间 |
| Last_updated_by | int? | 更新人 |
| Last_update_time | DateTime? | 更新时间 |

#### 7.3.3 ResutData

| 字段 | 类型 | 说明 |
|------|------|------|
| dataType | string | 数据类型：`SampleID` / `DeviceIP` / `InitialTime` |
| message | string | 具体消息内容 |

#### 7.3.4 LogInSampleInfo（内部回调，非 Pipe 直接传输）

| 字段 | 类型 | 说明 |
|------|------|------|
| RepeatSampleId | string | 重复样品 ID 或位置冲突描述 |
| SampleList | List\<SampleInfo\> | 样品列表 |

---

## 8. 任务状态码参考（result 接口通用）

各子系统 `result` 命令返回的 int 值来源于数据库任务 `Status` 字段，经各 Service 映射后返回。常见含义：

| Status | 含义（通用） |
|--------|--------------|
| 0 | 无任务 / 无记录 |
| 1 | 已创建 / 待开始 |
| 3 | 检测中 |
| 5 | 进行中 / 等待完成 |
| 7 | 已完成 |
| 99 | 已取消 |

> 各子系统对 Status 有额外映射逻辑，详见各 `result` 命令说明。

---

## 9. 调用示例

### 9.1 BGA 查询状态

**请求：**
```
result|
```

**响应：**
```
result|0|5
```
（ErrorCode 为 0 表示成功，ResultData 为 5 表示检测中）

### 9.2 Cedex 自动下单

**请求：**
```
log_in|[{"SampleID":"S001","RackNo":"J","TubeNo":1,"BatchId":100,"BatchOPId":200,"Code":"OP01"}]
```

**响应（成功）：**
```
log_in|0|
```

### 9.3 ViCell 手动登录

**请求：**
```
log_in_manual|[{"PositionNo":1,"SampleID":"S001","CellType":"CHO","DilutionFactor":2,"Mode":3,"BatchID":1,"BatchOPID":2,"ViCellDeviceID":1}]
```

---

## 10. 附录：源文件索引

| 子系统 | 源文件路径 |
|--------|-----------|
| BGA | `BGA/SubDeviceService.BGA/SubDeviceService.BGA.Core/BGAService.cs` |
| Cedex 配置 | `CedexHT/SubsystemService.Cedex/SubsystemService.Cedex.Core/CedexService.cs` |
| Cedex 订单 | `CedexHT/CedexOrder/SubsystemService.CedexOrder/SubsystemService.CedexOrder.Core/CedexOrderService.cs` |
| OSMO | `OSMO/OSMO6060/SubDeviceService.OsmoSix/SubDeviceService.OsmoSix.Core/OsmoSixService.cs` |
| ViCell | `Vicell/ViCellXR/Core/ViCellService.cs` |
| 协议基类 | `CedexBio/SubDeviceService.Core/BaseServices.cs` |
| 响应对象 | `CedexBio/SubDeviceService.Core/NamePipeResult.cs` |
