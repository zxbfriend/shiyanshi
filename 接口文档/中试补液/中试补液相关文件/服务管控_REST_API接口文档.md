# 服务管控 API 接口规范文档

## 1. 接口概述

- **协议格式**：HTTP / JSON
- **Content-Type**：`application/json`

### 统一响应参数说明

#### 1) 单服务操作响应 (`BaseResponse`)
| 字段名称 | 类型 | 说明 |
| :--- | :--- | :--- |
| `IsSuccess` | `boolean` | 是否成功：`true` / `false` |
| `ResultCode` | `integer` | 状态代码（默认 `200`） |
| `ResultMessage` | `string` | 执行结果信息（查询状态时返回状态名称，如 `"Running"`、`"Stopped"`） |

#### 2) 批量查询响应 (`BaseResponse<List<ServiceExecResult>>`)
| 字段名称 | 类型 | 说明 |
| :--- | :--- | :--- |
| `ResultCode` | `integer` | 状态码，成功返回 `200` |
| `IsSuccess` | `boolean` | 是否成功 |
| `Data` | `array[object]` | 各服务状态列表 |

##### `Data` 数组项结构 (`ServiceExecResult`)
| 字段名称 | 类型 | 说明 |
| :--- | :--- | :--- |
| `ServiceName` | `string` | 服务名称 |
| `IsSuccess` | `boolean` | 状态获取是否成功 |
| `Msg` | `string` | 服务当前状态（`"Running"` / `"Stopped"` / `"Paused"` 等） |

---

## 2. 接口列表

| 序号 | 接口名称 | HTTP 方法 | URI 路径 | 说明 |
| :---: | :--- | :---: | :--- | :--- |
| 1 | 查询单个服务状态 | **GET** | `/controlService/api/getservicestatus?serviceName={serviceName}` | 查询指定后台服务的当前运行状态 |
| 2 | 批量查询服务状态 | **GET** | `/controlService/api/getbatchservicestatus?serviceNames={serviceNames}` | 批量查询多个后台服务的当前状态列表 |
| 3 | 停止指定服务 | **GET** | `/controlService/api/stopservice?serviceName={serviceName}` | 停止指定的后台服务 |
| 4 | 启动/重启指定服务 | **GET** | `/controlService/api/resumeservice?serviceName={serviceName}` | 启动服务（若已运行则执行重启） |

---

## 3. 接口详细定义

### 3.1 查询单个服务状态

- **接口名称**：`GetServiceStatus`
- **请求方法**：`GET`
- **请求路径**：`/controlService/api/getservicestatus?serviceName={serviceName}`

#### 请求参数 (URL Query 参数)

| 参数名称 | 类型 | 必填 | 说明 | 示例值 |
| :--- | :--- | :---: | :--- | :--- |
| `serviceName` | `string` | 是 | 服务注册名称 | `"AlarmService"` |

##### 请求示例
```http
GET /controlService/api/getservicestatus?serviceName=AlarmService HTTP/1.1
Accept: application/json
```

#### 响应参数 (`BaseResponse`)

#### 响应示例

##### 服务正在运行 (`Running`)
```json
{
  "IsSuccess": true,
  "ResultCode": 200,
  "ResultMessage": "Running"
}
```

##### 服务已停止 (`Stopped`)
```json
{
  "IsSuccess": true,
  "ResultCode": 200,
  "ResultMessage": "Stopped"
}
```

---

### 3.2 批量查询服务状态

- **接口名称**：`GetBatchServiceStatus`
- **请求方法**：`GET`
- **请求路径**：`/controlService/api/getbatchservicestatus?serviceNames={serviceNames}`

#### 请求参数 (URL Query 参数)

| 参数名称 | 类型 | 必填 | 说明 | 示例值 |
| :--- | :--- | :---: | :--- | :--- |
| `serviceNames` | `string` | 是 | 多个服务名称，使用英文逗号 `,` 分隔 | `"AlarmService,OPCDAReadService,ModBusPumpService"` |

##### 请求示例
```http
GET /controlService/api/getbatchservicestatus?serviceNames=AlarmService,OPCDAReadService,ModBusPumpService HTTP/1.1
Accept: application/json
```

#### 响应参数 (`BaseResponse<List<ServiceExecResult>>`)

#### 响应示例 (`200 OK`)
```json
{
  "ResultCode": 200,
  "IsSuccess": true,
  "ResultMessage": null,
  "Data": [
    {
      "ServiceName": "AlarmService",
      "IsSuccess": true,
      "Msg": "Running"
    },
    {
      "ServiceName": "OPCDAReadService",
      "IsSuccess": true,
      "Msg": "Running"
    },
    {
      "ServiceName": "ModBusPumpService",
      "IsSuccess": true,
      "Msg": "Stopped"
    }
  ]
}
```

---

### 3.3 停止指定服务

- **接口名称**：`StopService`
- **请求方法**：`GET`
- **请求路径**：`/controlService/api/stopservice?serviceName={serviceName}`

#### 请求参数 (URL Query 参数)

| 参数名称 | 类型 | 必填 | 说明 | 示例值 |
| :--- | :--- | :---: | :--- | :--- |
| `serviceName` | `string` | 是 | 服务名称 | `"AlarmService"` |

##### 请求示例
```http
GET /controlService/api/stopservice?serviceName=AlarmService HTTP/1.1
Accept: application/json
```

#### 响应参数 (`BaseResponse`)

#### 响应示例

##### 停止命令成功
```json
{
  "IsSuccess": true,
  "ResultCode": 200,
  "ResultMessage": null
}
```

##### 停止失败
```json
{
  "IsSuccess": false,
  "ResultCode": 200,
  "ResultMessage": "服务未响应或权限不足"
}
```

---

### 3.4 启动/重启指定服务

- **接口名称**：`ResumeService`
- **请求方法**：`GET`
- **请求路径**：`/controlService/api/resumeservice?serviceName={serviceName}`

#### 请求参数 (URL Query 参数)

| 参数名称 | 类型 | 必填 | 说明 | 示例值 |
| :--- | :--- | :---: | :--- | :--- |
| `serviceName` | `string` | 是 | 服务名称 | `"AlarmService"` |

##### 请求示例
```http
GET /controlService/api/resumeservice?serviceName=AlarmService HTTP/1.1
Accept: application/json
```

#### 响应参数 (`BaseResponse`)

#### 响应示例

##### 启动/重启成功
```json
{
  "IsSuccess": true,
  "ResultCode": 200,
  "ResultMessage": null
}
```

##### 启动/重启失败
```json
{
  "IsSuccess": false,
  "ResultCode": 200,
  "ResultMessage": "服务启动超时或未找到服务"
}
```
