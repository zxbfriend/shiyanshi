# STR-50-3 OPC UA数采配置与开发部署经验

> WGQS NPP STR 50-3 的 OPC UA 采集配置（不是 OPC DA）。

**原始配置：** edgesettings.opcua-wgqs-npp-str-50-3.json  
**配置版本：** 2026.03.31-wgqs-npp-str-50-3  
**说明：** 下表按原始配置完整展开，列出设备和一级 OPC Tag/Item。配置本身不等于现场连通性证明。

## 1. OPC UA Server 与边缘连接信息

| 字段 | 配置值 |
|---|---|
| OPC UA Server Name / ProgID | WGQS NPP STR 50-3 OPC UA Source |
| OPC UA Server Endpoint URL | opc.tcp://192.168.1.41:4840 |
| OPC UA Server IP / Host | 192.168.1.41 |
| OPC UA Server Port | 4840 |
| Connect Type | Anonymous |
| Use Security | false |
| Protocol | OpcUa |
| Driver ID | opcua-wgqs-npp-str-50-3 |
| Driver Name | WGQS NPP STR 50-3 OPC UA Source |
| Driver Enabled | 是 |
| Edge Device ID | edge-wgqs-npp-str-50-3 |
| Edge Name | WGQS NPP STR 50-3 OPC UA Edge |
| Edge Listen URL | 未配置 |
| Platform URL | http://192.168.1.110:49010 |
| Platform Request Timeout | 15 秒 |
| Collection Enabled | 是 |
| Dispatch Interval | 1000 ms |

## 2. 一级 OPC UA 设备清单

| deviceId | deviceName | shortNo | enabled | 一级 Tag 数量 |
|---|---|---|---|---:|
| wgqs-npp-str-50-3 | WGQS-NPP-STR-50-3 | V4 | 是 | 12 |

## 3. 一级 OPC UA Tag List（配置原值 NodeId）

以下 12 个值是原始配置 `tags[].address` 的完整原值，属于 OPC UA NodeId，不是 OPC UA Browse Path（浏览路径）。原始 JSON 没有提供 `browsePath`、父节点 NodeId 或 BrowseName 层级，因此不能仅凭这份配置还原服务器地址空间中的完整浏览路径。重新开发时应使用 OPC UA 客户端按 NodeId 读取或订阅；如需浏览路径，必须从现场 OPC UA Server 浏览器/导出点表取得。

### WGQS-NPP-STR-50-3（wgqs-npp-str-50-3，shortNo=V4）

| tagCode | displayName | OPC UA NodeId（address 原值） | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| ph | pH | ns=2;s=CM_CPV.CM_ContinuousProcessValue_0040.Value | double | 180 | 否 | 是 |
| do-value | doValue | ns=2;s=CM_CPV.CM_ContinuousProcessValue_0043.Value | double | 180 | 否 | 是 |
| temperature | temperature | ns=2;s=CM_CPV.CM_ContinuousProcessValue_0002.Value | double | 180 | 否 | 是 |
| mfc1 | mfc1 | ns=2;s=CM_CPV.CM_ContinuousProcessValue_0029.Value | double | 180 | 否 | 是 |
| mfc2 | mfc2 | ns=2;s=CM_CPV.CM_ContinuousProcessValue_0114.Value | double | 180 | 否 | 是 |
| mfc3 | mfc3 | ns=2;s=CM_CPV.CM_ContinuousProcessValue_0033.Value | double | 180 | 否 | 是 |
| mfc4 | mfc4 | ns=2;s=CM_CPV.CM_ContinuousProcessValue_0032.Value | double | 180 | 否 | 是 |
| mfc5 | mfc5 | ns=2;s=CM_CPV.CM_ContinuousProcessValue_0031.Value | double | 180 | 否 | 是 |
| mfc6 | mfc6 | ns=2;s=CM_CPV.CM_ContinuousProcessValue_0030.Value | double | 180 | 否 | 是 |
| agitation | agitation | ns=2;s=CM_CPV.CM_ContinuousProcessValue_0007.Value | double | 180 | 否 | 是 |
| pressure | pressure | ns=2;s=CM_CPV.CM_ContinuousProcessValue_0049.Value | double | 180 | 否 | 是 |
| working-weight | workingWeight | ns=2;s=CM_CPV.CM_ContinuousProcessValue_0004.Value | double | 180 | 否 | 是 |

## 4. 开发与部署经验

- 这份 STR 50-3 配置的 protocolType 是 OpcUa，不是 OpcDa；Server Endpoint 为 opc.tcp://192.168.1.41:4840，连接方式 Anonymous，useSecurity=false。
- 不能把它并入 OPC DA STR 文档的 BBI.MFCSSOPCS/192.168.1.11 连接池；协议、连接对象、重连策略、质量码和安全配置必须独立。
- 12 个 NodeId 均为 double，采集周期为 180 秒；原始配置没有 isHighRate 标记。
- NodeId 均使用 `ns=2;s=CM_CPV.CM_ContinuousProcessValue_XXXX.Value` 格式，其中 `XXXX` 为每个点位的实际四位编号；部署时必须逐项保留完整 NodeId，不能使用省略号替代实际地址，并验证 namespace index、NodeId 字符串和服务器 NamespaceTable。
- Anonymous 且未启用安全只应视为当前配置基线；生产部署应评估证书、加密、签名、用户认证和最小权限。
- 平台请求超时为 15 秒、分发周期为 1 秒；平台不可达时不能阻塞 OPC UA 订阅，应使用有界缓存、断点/幂等补发和重连状态。

### 投运核对

1. 连接 opc.tcp://192.168.1.41:4840，确认 Anonymous/useSecurity=false 与现场服务器策略一致。
2. 逐项读取 12 个 NodeId，核对 namespace index、标识符、数据类型和源时间戳。
3. 验证 180 秒采集、1 秒分发、断线重连、NodeId 不存在、质量异常和服务重启恢复。
4. 若改为安全连接，必须重新导出证书、Endpoint、SecurityPolicy、MessageSecurityMode 和账号权限，不得只改 useSecurity 字段。
