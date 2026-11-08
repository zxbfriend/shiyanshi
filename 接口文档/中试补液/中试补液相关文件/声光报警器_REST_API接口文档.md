# 声光报警器 API 接口规范文档

## 1. 接口概述

- **协议格式**：HTTP / JSON
- **Content-Type**：`application/json`

### 统一响应参数说明 (`BaseResponse`)

| 字段名称 | 类型 | 说明 |
| :--- | :--- | :--- |
| `IsSuccess` | `boolean` | 是否成功：`true` 成功，`false` 失败 |
| `ResultCode` | `integer` | 状态代码（成功为 `1`） |
| `ResultMessage` | `string` | 附加说明信息（成功时为 `null`） |

---

## 2. 接口列表

| 序号 | 接口名称 | HTTP 方法 | URI 路径 | 说明 |
| :---: | :--- | :---: | :--- | :--- |
| 1 | 开启声光报警 | **GET** | `/alarmService/api/open` | 触发声光报警器常开报警 |
| 2 | 开启闪烁报警 | **GET** | `/alarmService/api/flash` | 触发声光报警器闪烁报警 |
| 3 | 关闭声光报警 | **GET** | `/alarmService/api/close` | 关闭声光报警器 |

---

## 3. 接口详细定义

### 3.1 开启声光报警

- **接口名称**：`OpenAlarm`
- **请求方法**：`GET`
- **请求路径**：`/alarmService/api/open`
- **请求参数**：无
- **响应参数**：`BaseResponse`

#### 响应示例

##### 成功响应 (`200 OK`)
```json
{
  "IsSuccess": true,
  "ResultCode": 1,
  "ResultMessage": null
}
```

##### 失败响应 (`200 OK`)
```json
{
  "IsSuccess": false,
  "ResultCode": 1,
  "ResultMessage": null
}
```

---

### 3.2 开启闪烁报警

- **接口名称**：`FlashAlarm`
- **请求方法**：`GET`
- **请求路径**：`/alarmService/api/flash`
- **请求参数**：无
- **响应参数**：`BaseResponse`

#### 响应示例

##### 成功响应 (`200 OK`)
```json
{
  "IsSuccess": true,
  "ResultCode": 1,
  "ResultMessage": null
}
```

##### 失败响应 (`200 OK`)
```json
{
  "IsSuccess": false,
  "ResultCode": 1,
  "ResultMessage": null
}
```

---

### 3.3 关闭声光报警

- **接口名称**：`CloseAlarm`
- **请求方法**：`GET`
- **请求路径**：`/alarmService/api/close`
- **请求参数**：无
- **响应参数**：`BaseResponse`

#### 响应示例

##### 成功响应 (`200 OK`)
```json
{
  "IsSuccess": true,
  "ResultCode": 1,
  "ResultMessage": null
}
```

##### 失败响应 (`200 OK`)
```json
{
  "IsSuccess": false,
  "ResultCode": 1,
  "ResultMessage": null
}
```
