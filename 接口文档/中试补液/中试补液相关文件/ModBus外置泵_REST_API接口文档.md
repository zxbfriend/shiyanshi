# 外置泵 API 接口规范文档

## 1. 接口概述

- **协议格式**：HTTP / JSON
- **Content-Type**：`application/json`

### 业务状态码说明

#### 1) 读状态码 (`BaseResponse.ResultCode`)
| 状态码 | 说明 |
| :--- | :--- |
| `200` | 成功读取当前转速 |
| `900` | 读取失败或数据超时 |

#### 2) 写状态码 (`IotBaseResponse.Code`)
| 状态码 | 说明 |
| :--- | :--- |
| `200` | 转速设置成功 |
| `500` | 设置失败或未启动 |
| `600` | 转速设置偏差超出允许范围 |
| `900` | 接口调用异常 |

---

## 2. 接口列表

| 序号 | 接口名称 | HTTP 方法 | URI 路径 | 说明 |
| :---: | :--- | :---: | :--- | :--- |
| 1 | 获取外置泵当前转速 | **GET** | `/modbusPumpService/api/getDeviceData` | 读取外置泵当前运行转速 |
| 2 | 设置外置泵运行转速 | **GET** | `/modbusPumpService/api/pumpSpeedSet?speed={speed}` | 设定外置泵目标运行转速 |

---

## 3. 接口详细定义

### 3.1 获取外置泵当前转速

- **接口名称**：`GetDeviceData`
- **请求方法**：`GET`
- **请求路径**：`/modbusPumpService/api/getDeviceData`
- **请求参数**：无

#### 响应参数 (`BaseResponse<decimal>`)

| 字段名称 | 类型 | 说明 |
| :--- | :--- | :--- |
| `ResultCode` | `integer` | 状态码：`200` (成功)、`900` (数据无效或异常) |
| `IsSuccess` | `boolean` | 是否有效：`true` / `false` |
| `ResultMessage` | `string` | 附加说明信息（正常为 `null`） |
| `Data` | `number` (decimal) | 当前泵实际运行转速（单位：rpm，停止时为 `0.0`） |

#### 响应示例

##### 成功响应 (`200 OK`)
```json
{
  "ResultCode": 200,
  "IsSuccess": true,
  "ResultMessage": null,
  "Data": 25.0
}
```

##### 失败响应 (`900`)
```json
{
  "ResultCode": 900,
  "IsSuccess": false,
  "ResultMessage": null,
  "Data": 0.0
}
```

---

### 3.2 设置外置泵运行转速

- **接口名称**：`PumpSpeedSet`
- **请求方法**：`GET`
- **请求路径**：`/modbusPumpService/api/pumpSpeedSet?speed={speed}`

#### 请求参数 (URL Query 参数)

| 参数名称 | 类型 | 必填 | 说明 | 示例值 |
| :--- | :--- | :---: | :--- | :--- |
| `speed` | `decimal` | 是 | 目标转速值（设为 `0` 表示停止） | `20.5` |

##### 请求示例
```http
GET /modbusPumpService/api/pumpSpeedSet?speed=20.5 HTTP/1.1
Accept: application/json
```

#### 响应参数 (`IotBaseResponse<object>`)

| 字段名称 | 类型 | 说明 |
| :--- | :--- | :--- |
| `Code` | `integer` | 状态码：`200` (成功)、`500` (失败/超时)、`600` (转速偏差超限)、`900` (异常) |
| `Data` | `object` | 附加数据（发生偏差时返回实际达到的转速） |

#### 响应示例

##### 设置成功 (`Code = 200`)
```json
{
  "Code": 200,
  "Data": null
}
```

##### 设置失败 (`Code = 500`)
```json
{
  "Code": 500,
  "Data": null
}
```

##### 转速偏差超限 (`Code = 600`)
```json
{
  "Code": 600,
  "Data": 15.2
}
```
