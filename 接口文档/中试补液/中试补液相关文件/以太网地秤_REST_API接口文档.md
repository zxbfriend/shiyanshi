# 以太网地秤 API 接口规范文档

## 1. 接口概述

- **协议格式**：HTTP / JSON
- **Content-Type**：`application/json`

### 业务状态码 (`ResultCode`)
| 状态码 | 说明 |
| :--- | :--- |
| `200` | 操作成功 / 成功获取称重数据 |
| `900` | 操作失败 / 数据超时或连接异常 |

---

## 2. 接口列表

| 序号 | 接口名称 | HTTP 方法 | URI 路径 | 说明 |
| :---: | :--- | :---: | :--- | :--- |
| 1 | 获取地秤实时称重数据 | **GET** | `/messageService/api/getScaleData` | 读取地秤当前实时称重读数与单位 |
| 2 | 测试地秤网络连接 | **POST** | `/messageService/api/testScaleConnect` | 测试指定 IP 与端口的地秤网络连通状态 |

---

## 3. 接口详细定义

### 3.1 获取地秤实时称重数据

- **接口名称**：`GetScaleData`
- **请求方法**：`GET`
- **请求路径**：`/messageService/api/getScaleData`
- **请求参数**：无

#### 响应参数 (`BaseResponse<DeviceResultModel>`)

| 字段名称 | 类型 | 说明 |
| :--- | :--- | :--- |
| `ResultCode` | `integer` | 状态码：`200` (成功)、`900` (数据无效或失败) |
| `IsSuccess` | `boolean` | 是否成功：`true` / `false` |
| `ResultMessage` | `string` | 附加提示信息（成功时为 `null`） |
| `Data` | `object` | 称重数据对象（失败或超时时为 `null`） |

##### `Data` 结构 (`DeviceResultModel`)
| 字段名称 | 类型 | 说明 |
| :--- | :--- | :--- |
| `Time` | `string` (DateTime) | 采集时间戳（ISO 格式字符串） |
| `Weight` | `string` | 当前称重重量数值 |
| `WeightUnit` | `string` | 重量单位（例如：`"g"`） |

#### 响应示例

##### 成功响应 (`200 OK`)
```json
{
  "ResultCode": 200,
  "IsSuccess": true,
  "ResultMessage": null,
  "Data": {
    "Time": "2026-03-30T15:20:00.123",
    "Weight": "128.60",
    "WeightUnit": "g"
  }
}
```

##### 失败响应 (`900`)
```json
{
  "ResultCode": 900,
  "IsSuccess": true,
  "ResultMessage": null,
  "Data": null
}
```

---

### 3.2 测试地秤网络连接

- **接口名称**：`TestScaleConnect`
- **请求方法**：`POST`
- **请求路径**：`/messageService/api/testScaleConnect`
- **请求头**：
  ```http
  Content-Type: application/json
  ```

#### 请求参数 (JSON Body)

| 字段名称 | 类型 | 必填 | 说明 | 示例值 |
| :--- | :--- | :---: | :--- | :--- |
| `NetIp` | `string` | 是 | 地秤设备 IP 地址 | `"192.168.1.120"` |
| `NetIPPort` | `string` | 是 | 地秤设备端口 | `"8080"` |

##### 请求示例
```json
{
  "NetIp": "192.168.1.120",
  "NetIPPort": "8080"
}
```

#### 响应参数 (`BaseResponse`)

| 字段名称 | 类型 | 说明 |
| :--- | :--- | :--- |
| `ResultCode` | `integer` | 状态码：`200` (连接成功)、`900` (连接失败) |
| `IsSuccess` | `boolean` | 是否成功：`true` / `false` |
| `ResultMessage` | `string` | 附加说明信息 |
| `Data` | `object` | 响应数据对象 |

#### 响应示例

##### 连接成功 (`200 OK`)
```json
{
  "ResultCode": 200,
  "IsSuccess": true,
  "ResultMessage": null,
  "Data": null
}
```

##### 连接失败 (`900`)
```json
{
  "ResultCode": 900,
  "IsSuccess": false,
  "ResultMessage": null,
  "Data": null
}
```
