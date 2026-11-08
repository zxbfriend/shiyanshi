# 奥豪斯地秤 API 接口规范文档

## 1. 接口概述

- **协议格式**：HTTP / JSON
- **Content-Type**：`application/json`

### 业务状态码 (`RespondCode`)
| 状态码 | 说明 |
| :--- | :--- |
| `200` | 成功获取称重数据 |
| `300` | 暂无有效称重数据 |
| `400` | 接口调用异常 |

---

## 2. 接口列表

| 序号 | 接口名称 | HTTP 方法 | URI 路径 | 说明 |
| :---: | :--- | :---: | :--- | :--- |
| 1 | 获取地秤最新称重数据 | **GET** | `/messageService/api/getOhausScaleData` | 获取地秤最新一条称重读数与单位 |
| 2 | 获取地秤历史称重列表 | **GET** | `/messageService/api/getOhausScaleDataList` | 获取地秤历史称重数据列表 |

---

## 3. 接口详细定义

### 3.1 获取地秤最新称重数据

- **接口名称**：`GetOhausScaleData`
- **请求方法**：`GET`
- **请求路径**：`/messageService/api/getOhausScaleData`
- **请求参数**：无

#### 响应参数 (`OhausScaleResponse`)

| 字段名称 | 类型 | 说明 |
| :--- | :--- | :--- |
| `RespondCode` | `integer` | 状态码：`200`（成功）、`300`（无数据）、`400`（异常） |
| `GatherTime` | `string` | 采集时间（格式：`yyyy-MM-dd HH:mm:ss fff`） |
| `Weight` | `string` | 重量读数 |
| `WeightUnit` | `string` | 重量单位（例如：`"g"`） |

#### 响应示例

##### 成功响应 (`200 OK`)
```json
{
  "RespondCode": 200,
  "GatherTime": "2026-03-30 14:35:10 500",
  "Weight": "125.40",
  "WeightUnit": "g"
}
```

##### 无数据响应 (`300`)
```json
{
  "RespondCode": 300,
  "GatherTime": null,
  "Weight": null,
  "WeightUnit": null
}
```

---

### 3.2 获取地秤历史称重列表

- **接口名称**：`GetOhausScaleDataList`
- **请求方法**：`GET`
- **请求路径**：`/messageService/api/getOhausScaleDataList`
- **请求参数**：无

#### 响应参数 (`OhausScaleListResponse`)

| 字段名称 | 类型 | 说明 |
| :--- | :--- | :--- |
| `RespondCode` | `integer` | 状态码：`200`（成功）、`300`（无数据）、`400`（异常） |
| `Data` | `array[object]` | 称重数据明细列表 |

##### `Data` 数组项结构
| 字段名称 | 类型 | 说明 |
| :--- | :--- | :--- |
| `GatherTime` | `string` | 采集时间（格式：`yyyy-MM-dd HH:mm:ss fff`） |
| `Weight` | `string` | 重量读数 |
| `WeightUnit` | `string` | 重量单位（例如：`"g"`） |

#### 响应示例

##### 成功响应 (`200 OK`)
```json
{
  "RespondCode": 200,
  "Data": [
    {
      "GatherTime": "2026-03-30 14:34:00 120",
      "Weight": "124.80",
      "WeightUnit": "g"
    },
    {
      "GatherTime": "2026-03-30 14:35:00 120",
      "Weight": "125.40",
      "WeightUnit": "g"
    }
  ]
}
```

##### 无数据响应 (`300`)
```json
{
  "RespondCode": 300,
  "Data": null
}
```
