# Inno 反应器在线参数接口文档

## 1. 接口概览

### 1.1 服务信息
- **服务名称**：Inno App Online Reactor API
- **Base URL**：`https://slms-nppwgq.wuxibiologics.com`
- **Content-Type**：`application/json`
- **请求方式**：`POST`

### 1.2 鉴权说明
接口通过请求体中的 `Request.Token` 传递认证令牌，不使用标准 `Authorization` Header。

---

## 2. 接口列表

| 接口名称 | 方法 | Path | 说明 |
|---|---|---|---|
| 通用在线参数采集 | `POST` | `/api/inno-app/capture-data` | 获取反应器在线参数 |
| STR 在线参数采集 | `POST` | `/api/inno-app/capture-data-str` | 获取 STR 在线参数，部分 MFC 累计字段固定返回 `null` |
| XDR 在线参数采集 | `POST` | `/api/inno-app/capture-data-xdr` | 获取 XDR 在线参数 |
| G3Lab 在线参数采集 | `POST` | `/api/inno-app/capture-data-g3lab` | 获取 G3Lab 在线参数 |

---

## 3. 公共请求模型

### 3.1 Request Body Schema

```yaml
type: object
required:
  - ID
  - Request
  - Params
properties:
  ID:
    type: string
    format: uuid
    description: 请求唯一标识
    example: 3FBDC13D-1519-45F4-A9C4-282F7146C6EF
  Request:
    type: object
    required:
      - ApiVer
      - Token
    properties:
      ApiVer:
        type: string
        description: 接口版本号
        example: 1.0.1
      Token:
        type: string
        description: 登录鉴权 Token
        example: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
  Params:
    type: object
    required:
      - LabKey
      - ReactorNo
      - DetalvType
    properties:
      LabKey:
        type: string
        description: 实验室标识
        example: 20211206135901InnoLab001
      ReactorNo:
        type: string
        description: 反应器编号
        example: "258212"
      DetalvType:
        type: integer
        format: int32
        description: DeltaV 数据类型枚举值，0=Actual（实际值），1=Set（设定值），2=Mode（模式值）
        example: 0
```

      ### 3.2 `DetalvType` 入参说明

      `DetalvType` 为 `int` 型，对应后端枚举 `EnumDetalVType`：

      ```csharp
      public enum EnumDetalVType
      {
          Actual = 0,
          Set = 1,
          Mode = 2
      }
      ```

      取值说明如下：

      | 参数名 | 类型 | 枚举值 | 枚举名称 | 说明 |
      |---|---|---:|---|---|
      | `DetalvType` | `int` | `0` | `Actual` | 返回实际采集值 |
      | `DetalvType` | `int` | `1` | `Set` | 返回设定值 |
      | `DetalvType` | `int` | `2` | `Mode` | 返回模式值 |

      > 建议：
      > - 常规在线监控场景传 `0`
      > - 查看控制设定参数时传 `1`
      > - 查看设备/控制模式时传 `2`

      ### 3.3 公共请求示例

```json
{
  "ID": "3FBDC13D-1519-45F4-A9C4-282F7146C6EF",
  "Request": {
    "ApiVer": "1.0.1",
    "Token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3NzUwMjM1NjQsImxhYktleSI6IjIwMjExMjA2MTM1OTAxSW5ub0xhYjAwMSIsImxhYlNlY3JldCI6Im1CRmYzaXZCdG9OK0ZneWgrbU1Da3Nxd3NqWklBYkZkNEhWdlk0YXVDNW89In0.8PNLvPY6Lt80GES1RZqsQFM520EPcHKZ8O6SzAcmdYc"
  },
  "Params": {
    "LabKey": "20211206135901InnoLab001",
    "ReactorNo": "258212",
    "DetalvType": 0
  }
}
```

---

## 4. 公共响应模型

### 4.1 Response Body Schema

```yaml
type: object
properties:
  ResultData:
    $ref: '#/components/schemas/EnvReactorOnlineModel'
  ID:
    type: string
    format: uuid
    description: 请求唯一标识
  ResultCode:
    type: integer
    description: 业务结果码
    example: 200
  ResultMessage:
    type: string
    description: 业务结果消息
    example: Success
  CurrentPage:
    type: integer
    example: 0
  PagesCount:
    type: integer
    example: 0
  RecordsCount:
    type: integer
    example: 0
```

> 说明：
> - 从代码看，失败时可能返回 `ResultCode = -1`，`ResultMessage = "ReactorNo not exist"`
> - 从实际返回示例看，成功时业务码为 `200`

### 4.2 `EnvReactorOnlineModel` Schema

> 以下字段基于 `capture-data-str` 的实际出参整理。

```yaml
type: object
properties:
  MeasuringTime:
    type: string
    format: date-time
    description: 数据采集时间
  PH:
    type: number
    format: double
  PUMP1:
    type: number
    nullable: true
  PUMP2:
    type: number
    nullable: true
  PUMP3:
    type: number
    nullable: true
  PUMP4:
    type: number
    nullable: true
  Pump1:
    type: number
    format: double
  Pump2:
    type: number
    format: double
  Pump3:
    type: number
    format: double
  Pump4:
    type: number
    format: double
  WorkingWeight:
    type: number
    format: double
    description: 工作重量，代码中会做 /1000 并保留 2 位小数
  Weight:
    type: number
    format: double
  Pressure:
    type: number
    format: double
  MFC1:
    type: number
    format: double
  MFC2:
    type: number
    format: double
  MFC3:
    type: number
    format: double
  MFC4:
    type: number
    format: double
  MFC5:
    type: number
    format: double
  MFC6:
    type: number
    format: double
  MFC1SET:
    type: number
    format: double
  MFC2SET:
    type: number
    format: double
  MFC3SET:
    type: number
    format: double
  MFC4SET:
    type: number
    format: double
  MFC5SET:
    type: number
    format: double
  MFC6SET:
    type: number
    format: double
  MFC1HSTOT:
    type: number
    nullable: true
  MFC2HSTOT:
    type: number
    nullable: true
  MFC3HSTOT:
    type: number
    nullable: true
  MFC4HSTOT:
    type: number
    nullable: true
  MFC5HSTOT:
    type: number
    nullable: true
  MFC6HSTOT:
    type: number
    nullable: true
  MFC1MODEACTUAL:
    type: string
    nullable: true
  MFC2MODEACTUAL:
    type: string
    nullable: true
  MFC3MODEACTUAL:
    type: string
    nullable: true
  MFC4MODEACTUAL:
    type: string
    nullable: true
  MFC5MODEACTUAL:
    type: string
    nullable: true
  MFC6MODEACTUAL:
    type: string
    nullable: true
  MFC1MODESET:
    type: string
    nullable: true
  MFC2MODESET:
    type: string
    nullable: true
  MFC3MODESET:
    type: string
    nullable: true
  MFC4MODESET:
    type: string
    nullable: true
  MFC5MODESET:
    type: string
    nullable: true
  MFC6MODESET:
    type: string
    nullable: true
  MFC1SP1TOT:
    type: number
    nullable: true
  MFC1SP2TOT:
    type: number
    nullable: true
  MFC2SP1TOT:
    type: number
    nullable: true
  MFC2SP2TOT:
    type: number
    nullable: true
  MFC3SP1TOT:
    type: number
    nullable: true
  MFC3SP2TOT:
    type: number
    nullable: true
  MFC4SP1TOT:
    type: number
    nullable: true
  MFC4SP2TOT:
    type: number
    nullable: true
  MFC5SP1TOT:
    type: number
    nullable: true
  MFC5SP2TOT:
    type: number
    nullable: true
  MFC6SP1TOT:
    type: number
    nullable: true
  MFC6SP2TOT:
    type: number
    nullable: true
  OxygenFlowRate:
    type: number
    nullable: true
  OxygenFlowRateTotal:
    type: number
    nullable: true
  CO2FlowRate:
    type: number
    nullable: true
  CO2FlowRateTotal:
    type: number
    nullable: true
  AirSpargerFlowRate:
    type: number
    nullable: true
  AirOverlayFlowRate:
    type: number
    nullable: true
  Pump1Bad:
    type: boolean
    nullable: true
  Pump2Bad:
    type: boolean
    nullable: true
  Pump3Bad:
    type: boolean
    nullable: true
  Pump4Bad:
    type: boolean
    nullable: true
  Scale1WorkingWeight:
    type: number
    format: double
  Scale2WorkingWeight:
    type: number
    format: double
  DO:
    type: number
    format: double
  Temp:
    type: number
    format: double
  DeadBandHigh:
    type: number
    format: double
  DeadBandLow:
    type: number
    format: double
  Agitation:
    type: number
    format: double
  AGITATION:
    type: number
    format: double
  Alkali:
    type: number
    format: double
  Mode:
    type: string
    nullable: true
  AgitationSet:
    type: number
    format: double
  TempSet:
    type: number
    format: double
  PHSet:
    type: number
    format: double
  DeadBandHighSet:
    type: number
    format: double
  DeadBandLowSet:
    type: number
    format: double
  DOSet:
    type: number
    format: double
  agitationmodeactual:
    type: string
    nullable: true
  agitationmodeset:
    type: string
    nullable: true
  temperaturemodeactual:
    type: string
    nullable: true
  temperaturemodeset:
    type: string
    nullable: true
  interlayertempmodeactual:
    type: string
    nullable: true
  interlayertempmodeset:
    type: string
    nullable: true
  phmodeactual:
    type: string
    nullable: true
  phmodeset:
    type: string
    nullable: true
  domodeactual:
    type: string
    nullable: true
  domodeset:
    type: string
    nullable: true
  alkalimodeactual:
    type: string
    nullable: true
  alkalimodeset:
    type: string
    nullable: true
  OxygenFlowRate2:
    type: number
    nullable: true
  OxygenFlowRateMicro:
    type: number
    nullable: true
  EnvReactor:
    type: object
    nullable: true
```

---

## 5. 接口明细

## 5.1 通用在线参数采集

### Summary
获取反应器在线参数。

### Path
`POST /api/inno-app/capture-data`

### Full URL
`https://slms-nppwgq.wuxibiologics.com/api/inno-app/capture-data`

### Request Body
参见：[公共请求模型](#3-公共请求模型)

### Response
参见：[公共响应模型](#4-公共响应模型)

### Success Response Example
```json
{
  "ResultData": {
    "MeasuringTime": "2026-04-01T14:10:18.682+08:00",
    "PH": 7.04833,
    "WorkingWeight": 163,
    "Weight": 163,
    "Pressure": 0,
    "MFC1": 0.799999,
    "MFC2": 0.01059273,
    "MFC3": -0.003151749,
    "MFC4": -0.006893881,
    "MFC5": 1.000246,
    "MFC6": 6.797998,
    "DO": 39.78238,
    "Temp": 33.006,
    "Agitation": 109.9001,
    "AGITATION": 109.9001
  },
  "ID": "3FBDC13D-1519-45F4-A9C4-282F7146C6EF",
  "ResultCode": 200,
  "ResultMessage": "Success",
  "CurrentPage": 0,
  "PagesCount": 0,
  "RecordsCount": 0
}
```

### Error Response Example
```json
{
  "ResultData": null,
  "ID": "3FBDC13D-1519-45F4-A9C4-282F7146C6EF",
  "ResultCode": -1,
  "ResultMessage": "ReactorNo not exist",
  "CurrentPage": 0,
  "PagesCount": 0,
  "RecordsCount": 0
}
```

---

## 5.2 STR 在线参数采集

### Summary
获取 STR 反应器在线参数。

### Path
`POST /api/inno-app/capture-data-str`

### Full URL
`https://slms-nppwgq.wuxibiologics.com/api/inno-app/capture-data-str`

### Description
该接口与 `capture-data` 基本一致，但会将以下字段强制置空：

- `MFC1HSTOT` ~ `MFC6HSTOT`
- `MFC1SP1TOT` ~ `MFC6SP2TOT`

### Request Body
```json
{
  "ID": "3FBDC13D-1519-45F4-A9C4-282F7146C6EF",
  "Request": {
    "ApiVer": "1.0.1",
    "Token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3NzUwMjM1NjQsImxhYktleSI6IjIwMjExMjA2MTM1OTAxSW5ub0xhYjAwMSIsImxhYlNlY3JldCI6Im1CRmYzaXZCdG9OK0ZneWgrbU1Da3Nxd3NqWklBYkZkNEhWdlk0YXVDNW89In0.8PNLvPY6Lt80GES1RZqsQFM520EPcHKZ8O6SzAcmdYc"
  },
  "Params": {
    "LabKey": "20211206135901InnoLab001",
    "ReactorNo": "258212",
    "DetalvType": 0
  }
}
```

### Success Response Example
```json
{
  "ResultData": {
    "MeasuringTime": "2026-04-01T14:10:18.682+08:00",
    "PH": 7.04833,
    "PUMP1": null,
    "PUMP2": null,
    "PUMP3": null,
    "PUMP4": null,
    "Pump1": 0,
    "Pump2": 0,
    "Pump3": 0,
    "Pump4": 0,
    "WorkingWeight": 163,
    "Weight": 163,
    "Pressure": 0,
    "MFC1": 0.799999,
    "MFC2": 0.01059273,
    "MFC3": -0.003151749,
    "MFC4": -0.006893881,
    "MFC5": 1.000246,
    "MFC6": 6.797998,
    "MFC1SET": 0,
    "MFC2SET": 0,
    "MFC3SET": 0,
    "MFC4SET": 0,
    "MFC5SET": 0,
    "MFC6SET": 0,
    "MFC1HSTOT": null,
    "MFC2HSTOT": null,
    "MFC3HSTOT": null,
    "MFC4HSTOT": null,
    "MFC5HSTOT": null,
    "MFC6HSTOT": null,
    "MFC1MODEACTUAL": null,
    "MFC2MODEACTUAL": null,
    "MFC3MODEACTUAL": null,
    "MFC4MODEACTUAL": null,
    "MFC5MODEACTUAL": null,
    "MFC6MODEACTUAL": null,
    "MFC1MODESET": null,
    "MFC2MODESET": null,
    "MFC3MODESET": null,
    "MFC4MODESET": null,
    "MFC5MODESET": null,
    "MFC6MODESET": null,
    "MFC1SP1TOT": null,
    "MFC1SP2TOT": null,
    "MFC2SP1TOT": null,
    "MFC2SP2TOT": null,
    "MFC3SP1TOT": null,
    "MFC3SP2TOT": null,
    "MFC4SP1TOT": null,
    "MFC4SP2TOT": null,
    "MFC5SP1TOT": null,
    "MFC5SP2TOT": null,
    "MFC6SP1TOT": null,
    "MFC6SP2TOT": null,
    "OxygenFlowRate": null,
    "OxygenFlowRateTotal": null,
    "CO2FlowRate": null,
    "CO2FlowRateTotal": null,
    "AirSpargerFlowRate": null,
    "AirOverlayFlowRate": null,
    "Pump1Bad": null,
    "Pump2Bad": null,
    "Pump3Bad": null,
    "Pump4Bad": null,
    "Scale1WorkingWeight": 0,
    "Scale2WorkingWeight": 0,
    "DO": 39.78238,
    "Temp": 33.006,
    "DeadBandHigh": 0.2,
    "DeadBandLow": 0.2,
    "Agitation": 109.9001,
    "AGITATION": 109.9001,
    "Alkali": 0,
    "Mode": null,
    "AgitationSet": 0,
    "TempSet": 0,
    "PHSet": 0,
    "DeadBandHighSet": 0,
    "DeadBandLowSet": 0,
    "DOSet": 0,
    "agitationmodeactual": null,
    "agitationmodeset": null,
    "temperaturemodeactual": null,
    "temperaturemodeset": null,
    "interlayertempmodeactual": null,
    "interlayertempmodeset": null,
    "phmodeactual": null,
    "phmodeset": null,
    "domodeactual": null,
    "domodeset": null,
    "alkalimodeactual": null,
    "alkalimodeset": null,
    "OxygenFlowRate2": null,
    "OxygenFlowRateMicro": null,
    "EnvReactor": null
  },
  "ID": "3FBDC13D-1519-45F4-A9C4-282F7146C6EF",
  "ResultCode": 200,
  "ResultMessage": "Success",
  "CurrentPage": 0,
  "PagesCount": 0,
  "RecordsCount": 0
}
```

### Error Response Example
```json
{
  "ResultData": null,
  "ID": "3FBDC13D-1519-45F4-A9C4-282F7146C6EF",
  "ResultCode": -1,
  "ResultMessage": "ReactorNo not exist",
  "CurrentPage": 0,
  "PagesCount": 0,
  "RecordsCount": 0
}
```

---

## 5.3 XDR 在线参数采集

### Summary
获取 XDR 反应器在线参数。

### Path
`POST /api/inno-app/capture-data-xdr`

### Full URL
`https://slms-nppwgq.wuxibiologics.com/api/inno-app/capture-data-xdr`

### Request Body
参见：[公共请求模型](#3-公共请求模型)

### Response
参见：[公共响应模型](#4-公共响应模型)

### Description
逻辑与 `capture-data` 基本一致，返回 `EnvReactorOnlineModel`。

---

## 5.4 G3Lab 在线参数采集

### Summary
获取 G3Lab 反应器在线参数。

### Path
`POST /api/inno-app/capture-data-g3lab`

### Full URL
`https://slms-nppwgq.wuxibiologics.com/api/inno-app/capture-data-g3lab`

### Request Body
参见：[公共请求模型](#3-公共请求模型)

### Response
参见：[公共响应模型](#4-公共响应模型)

### Description
逻辑与 `capture-data` 基本一致，返回 `EnvReactorOnlineModel`。

---

## 6. 状态码说明

### 6.1 HTTP 状态码
| HTTP Code | 说明 |
|---|---|
| `200` | 请求成功，业务结果需结合 `ResultCode` 判断 |

### 6.2 业务状态码
| ResultCode | ResultMessage | 说明 |
|---|---|---|
| `200` | `Success` | 成功 |
| `-1` | `ReactorNo not exist` | 反应器编号不存在 |

---

## 7. 备注

1. `WorkingWeight` 在接口内部会做单位换算：
   - 代码逻辑：`WorkingWeight / 1000`，并保留 2 位小数
2. `capture-data-str` 会主动清空一组 MFC 累计字段，因此与其他三个接口相比，部分字段固定为 `null`
3. `DetalvType` 在代码中会转换为 `EnumDetalVType`：`0=Actual`、`1=Set`、`2=Mode`
4. `Request.Token` 为必填，否则鉴权会失败
5. `LabKey` 虽然当前控制器方法未直接使用，但根据实际请求样例应作为标准入参保留
6. 若请求体缺失或 `Params.ReactorNo` 为空，当前代码未显式返回参数错误信息，建议后续统一补充参数校验响应

---

## 8. 附录：STR 接口真实示例地址

- `https://slms-nppwgq.wuxibiologics.com/api/inno-app/capture-data-str`

