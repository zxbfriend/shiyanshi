# 生物反应器 API 接口规范文档

## 1. 接口概述

- **协议格式**：HTTP / JSON
- **Content-Type**：`application/json`

### 业务状态码说明

#### 1) 数据查询类状态码 (`BaseResponse.ResultCode`)
| 状态码 | 说明 |
| :--- | :--- |
| `200` | 查询成功 |
| `300` | 暂无有效数据 |
| `900` | 查询异常或失败 |

#### 2) 设备控制类状态码 (`IotBaseResponse.Code`)
| 状态码 | 说明 |
| :--- | :--- |
| `200` | 控制命令执行成功 |
| `300` | 参数缺失或为空 |
| `400` | 参数配置错误 |
| `500` | 控制执行失败或超时 |
| `600` | 设定值与反馈值偏差超限 |
| `900` | 执行异常 |

---

## 2. 接口列表

| 序号 | 接口名称 | HTTP 方法 | URI 路径 | 说明 |
| :---: | :--- | :---: | :--- | :--- |
| 1 | 获取指定反应器数据 | **GET** | `/opcdaReadService/api/getDeviceData?deviceId={deviceId}` | 查询单台反应器运行参数（pH、DO、泵速、重量等） |
| 2 | 实时点查反应器数据 | **POST** | `/opcdaReadService/api/getRealTimeDeviceData` | 按指定字段列表实时点查最新数据 |
| 3 | 获取所有反应器数据 | **GET** | `/opcdaReadService/api/getAllDeviceData` | 查询所有反应器当前数据列表 |
| 4 | 单泵转速控制设定 | **POST** | `/opcdaReadService/api/pumpSpeedSet` | 设定指定反应器单个泵的目标转速 |
| 5 | 批量泵转速控制设定 | **POST** | `/opcdaReadService/api/batchPumpSpeedSet` | 批量下发多台反应器多个泵的速度设定值 |
| 6 | 查询泵控制模式列表 | **GET** | `/opcdaReadService/api/getPumpModeList?reactors={reactors}` | 查询反应器各泵当前的运行模式 |
| 7 | 设置泵运行模式 | **POST** | `/opcdaReadService/api/pumpModeSet` | 批量设定反应器各泵的工作运行模式 |

---

## 3. 详细接口说明

### 3.1 获取指定反应器数据

- **接口名称**：`GetDeviceData`
- **请求方法**：`GET`
- **请求路径**：`/opcdaReadService/api/getDeviceData?deviceId={deviceId}`

#### 请求参数 (URL Query 参数)

| 参数名称 | 类型 | 必填 | 说明 | 示例值 |
| :--- | :--- | :---: | :--- | :--- |
| `deviceId` | `string` | 是 | 反应器编号 | `"1"` |

##### 请求示例
```http
GET /opcdaReadService/api/getDeviceData?deviceId=1 HTTP/1.1
Accept: application/json
```

#### 响应参数 (`BaseResponse<IotContent>`)

| 字段名称 | 类型 | 说明 |
| :--- | :--- | :--- |
| `ResultCode` | `integer` | 状态码：`200`（成功）、`300`（无数据）、`900`（失败） |
| `IsSuccess` | `boolean` | 是否成功 |
| `ResultMessage` | `string` | 附加说明信息 |
| `Data` | `object` | 数据主体 (`IotContent`) |

##### `Data` 结构 (`IotContent`)
- `baseDeviceData.devId`: `string`（设备编号）
- `bioreactors`: `array[object]`（反应器参数列表）
  - `measuringTime`: `string`（时间戳）
  - `ph` / `phset` / `phmodeactual`: pH 实时值、设定值、控制模式
  - `doValue` / `doValueset` / `domodeactual`: 溶氧 DO 实时值、设定值、控制模式
  - `temperature` / `temperatureset`: 温度实时值、设定值
  - `workingWeight` / `scale1workingWeight`: 反应器总重、地秤 1 工作重量
  - `pump1` ~ `pump8`: 泵 1 ~ 8 当前实际转速
  - `pump1set` ~ `pump8set`: 泵 1 ~ 8 当前设定转速
  - `mfc1` ~ `mfc6`: 质量流量计 1 ~ 6 气体流量
  - `agitation` / `agitationset`: 搅拌当前转速、设定转速

#### 响应示例 (`200 OK`)
```json
{
  "ResultCode": 200,
  "IsSuccess": true,
  "ResultMessage": null,
  "Data": {
    "baseDeviceData": {
      "devId": "1",
      "devModel": null
    },
    "bioreactors": [
      {
        "measuringTime": "1711785600000",
        "ph": "7.15",
        "phset": "7.20",
        "doValue": "45.2",
        "doValueset": "50.0",
        "temperature": "37.0",
        "temperatureset": "37.0",
        "workingWeight": "1250.5",
        "scale1workingWeight": "1250.5",
        "pump1": "10.0",
        "pump1set": "10.0",
        "agitation": "200.0",
        "agitationset": "200.0"
      }
    ]
  }
}
```

---

### 3.2 实时点查反应器数据

- **接口名称**：`GetRealTimeDeviceData`
- **请求方法**：`POST`
- **请求路径**：`/opcdaReadService/api/getRealTimeDeviceData`
- **请求头**：
  ```http
  Content-Type: application/json
  ```

#### 请求参数 (JSON Body)

| 字段名称 | 类型 | 必填 | 说明 | 示例值 |
| :--- | :--- | :---: | :--- | :--- |
| `DeviceId` | `string` | 是 | 反应器编号 | `"1"` |
| `Fields` | `array[string]` | 是 | 需要点查的参数字段名列表 | `["ph", "doValue", "temperature", "pump1set"]` |

##### 请求示例
```json
{
  "DeviceId": "1",
  "Fields": [
    "ph",
    "doValue",
    "temperature",
    "pump1set"
  ]
}
```

#### 响应参数 (`BaseResponse<IotContent>`)
返回结构与 3.1 节一致。

---

### 3.3 获取所有反应器数据

- **接口名称**：`GetAllDeviceData`
- **请求方法**：`GET`
- **请求路径**：`/opcdaReadService/api/getAllDeviceData`
- **请求参数**：无
- **响应参数**：`BaseResponse<IotContent>`

---

### 3.4 单泵转速控制设定

- **接口名称**：`PumpSpeedSet`
- **请求方法**：`POST`
- **请求路径**：`/opcdaReadService/api/pumpSpeedSet`
- **请求头**：
  ```http
  Content-Type: application/json
  ```

#### 请求参数 (JSON Body)

| 字段名称 | 类型 | 必填 | 说明 | 示例值 |
| :--- | :--- | :---: | :--- | :--- |
| `ReactorNo` | `string` | 是 | 反应器编号 | `"1"` |
| `SetName` | `string` | 是 | 控制参数点位名称（例如 `"pump1set"` ~ `"pump6set"`） | `"pump1set"` |
| `Speed` | `number` (decimal) | 是 | 目标设定转速（单位：rpm） | `15.5` |

##### 请求示例
```json
{
  "ReactorNo": "1",
  "SetName": "pump1set",
  "Speed": 15.5
}
```

#### 响应参数 (`IotBaseResponse<object>`)

| 字段名称 | 类型 | 说明 |
| :--- | :--- | :--- |
| `Code` | `integer` | 状态码：`200`（成功）、`300`（参数为空）、`400`（参数错误）、`500`（失败/超时）、`600`（偏差超限） |
| `Data` | `object` | 异常时返回当前反馈转速值 |

#### 响应示例
```json
{
  "Code": 200,
  "Data": null
}
```

---

### 3.5 批量泵转速控制设定

- **接口名称**：`BatchPumpSpeedSet`
- **请求方法**：`POST`
- **请求路径**：`/opcdaReadService/api/batchPumpSpeedSet`
- **请求头**：
  ```http
  Content-Type: application/json
  ```

#### 请求参数 (JSON Body)

| 字段名称 | 类型 | 必填 | 说明 |
| :--- | :--- | :---: | :--- |
| `LabDeviceName` | `string` | 是 | 反应器设备标识 |
| `PumpsSpeed` | `array[object]` | 是 | 各泵速度设置列表（包含 `PumpCode` 泵编号与 `Speed` 速度数值） |

##### 请求示例
```json
[
  {
    "LabDeviceName": "1",
    "PumpsSpeed": [
      {
        "PumpCode": "1",
        "Speed": "10.0"
      },
      {
        "PumpCode": "2",
        "Speed": "0.0"
      }
    ]
  }
]
```

#### 响应参数 (`IotBaseResponse`)
```json
{
  "Code": 200
}
```

---

### 3.6 查询泵控制模式列表

- **接口名称**：`GetPumpModeList`
- **请求方法**：`GET`
- **请求路径**：`/opcdaReadService/api/getPumpModeList?reactors={reactors}`

#### 请求参数 (URL Query 参数)

| 参数名称 | 类型 | 必填 | 说明 | 示例值 |
| :--- | :--- | :---: | :--- | :--- |
| `reactors` | `string` | 是 | 反应器编号列表（多个用逗号 `,` 分隔） | `"1,2"` |

##### 请求示例
```http
GET /opcdaReadService/api/getPumpModeList?reactors=1,2 HTTP/1.1
Accept: application/json
```

#### 响应参数 (`BaseResponse<List<LabDeviceModeResponse>>`)

#### 响应示例 (`200 OK`)
```json
{
  "ResultCode": 200,
  "IsSuccess": true,
  "ResultMessage": null,
  "Data": [
    {
      "LabDeviceName": "1",
      "PumpsModel": [
        {
          "PumpCode": "1",
          "Mode": "0"
        },
        {
          "PumpCode": "2",
          "Mode": "1"
        }
      ]
    }
  ]
}
```

---

### 3.7 设置泵运行模式

- **接口名称**：`PumpModeSet`
- **请求方法**：`POST`
- **请求路径**：`/opcdaReadService/api/pumpModeSet`
- **请求头**：
  ```http
  Content-Type: application/json
  ```

#### 请求参数 (JSON Body)

##### 请求示例
```json
[
  {
    "LabDeviceName": "1",
    "PumpsModel": [
      {
        "PumpCode": "1",
        "Mode": "1"
      }
    ]
  }
]
```

#### 响应参数 (`IotBaseResponse`)
```json
{
  "Code": 200
}
```
