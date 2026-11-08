# 继电器 API 接口规范文档

## 1. 接口概述

- **协议格式**：HTTP / JSON
- **Content-Type**：`application/json`

### 统一响应参数说明 (`BaseResponse`)

| 字段名称 | 类型 | 说明 |
| :--- | :--- | :--- |
| `IsSuccess` | `boolean` | 是否控制成功：`true` 成功，`false` 失败 |
| `ResultCode` | `integer` | 状态代码（默认 `1`） |
| `ResultMessage` | `string` | 附加说明或失败提示（成功时为 `null`） |

---

## 2. 接口列表

| 序号 | 接口名称 | HTTP 方法 | URI 路径 | 说明 |
| :---: | :--- | :---: | :--- | :--- |
| 1 | 继电器通道开关控制 | **POST** | `/relayService/api/relaySwitch` | 控制指定继电器设备通道开启或关闭 |

---

## 3. 接口详细定义

### 3.1 继电器通道开关控制

- **接口名称**：`SendData`
- **请求方法**：`POST`
- **请求路径**：`/relayService/api/relaySwitch`
- **请求头**：
  ```http
  Content-Type: application/json
  ```

#### 请求参数 (JSON Body)

| 字段名称 | 类型 | 必填 | 说明 | 示例值 |
| :--- | :--- | :---: | :--- | :--- |
| `Ip` | `string` | 是 | 继电器设备 IP 地址 | `"192.168.1.200"` |
| `Port` | `string` | 是 | 继电器设备端口 | `"5000"` |
| `Type` | `integer` | 是 | 控制动作类型：<br>• `1`：开启<br>• `2`：关闭 | `1` |
| `DeviceName` | `string` | 否 | 继电器设备名称（辅助标识） | `"进样继电器1"` |

##### 请求示例（开启）
```json
{
  "Ip": "192.168.1.200",
  "Port": "5000",
  "Type": 1,
  "DeviceName": "进样继电器1"
}
```

##### 请求示例（关闭）
```json
{
  "Ip": "192.168.1.200",
  "Port": "5000",
  "Type": 2,
  "DeviceName": "进样继电器1"
}
```

#### 响应参数 (`BaseResponse`)

| 字段名称 | 类型 | 说明 |
| :--- | :--- | :--- |
| `IsSuccess` | `boolean` | 是否控制成功：`true` 成功，`false` 失败 |
| `ResultCode` | `integer` | 状态代码，默认 `1` |
| `ResultMessage` | `string` | 附加说明或错误原因（如 `"设备未连接"`、`"请传入必要参数"`） |

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
  "ResultMessage": "设备未连接"
}
```
