# WAVE OPC DA数采配置与开发部署经验

> Wave25-01 的 UNICORN OPC DA 曲线数据采集配置。

**原始配置：** appsettings WAVE.json  
**配置版本：** 2026.06.30-wave25-01  
**说明：** 下表按原始配置完整展开，列出设备和一级 OPC Tag/Item。配置本身不等于现场连通性证明。

## 1. OPC DA Server 与边缘连接信息

| 字段 | 配置值 |
|---|---|
| OPC DA Server Name / ProgID | UNICORN_DAServer20.System1.1 |
| OPC DA Server IP / Host | 192.168.1.1 |
| Protocol | OpcDa |
| Driver ID | opcda-wave25-01 |
| Driver Name | Wave25-01 OPC DA Source |
| Driver Enabled | 是 |
| Edge Device ID | edge-opcda-wave25-01 |
| Edge Name | Wave25-01 OPC DA Edge |
| Edge Listen URL | http://10.249.11.94:49010/ |
| Platform URL | http://10.249.11.114:49010 |
| Platform Request Timeout | 15 秒 |
| Collection Enabled | 是 |
| Dispatch Interval | 30000 ms |

## 2. 一级 OPC 设备清单

| deviceId | deviceName | shortNo | enabled | 一级 Tag 数量 |
|---|---|---|---|---:|
| opcda-wave25-01 | Wave25-01 | Wave25-01 | 是 | 19 |

## 3. 一级 OPC Tag List（完整 Item 清单）

以下 19 个 Item 均为一级 OPC DA Item；地址使用反斜杠分隔的 `\Event\Curves` 路径。`isHighRate` 全部为 1，但实际采集周期为 30 秒。

### Wave25-01（opcda-wave25-01，shortNo=Wave25-01）

| tagCode | displayName | OPC Item / NodeId | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| co2sp | CO2 SP | \Event\Curves\CO2 SP | double | 30 | 是 | 是 |
| do | DO | \Event\Curves\DO | double | 30 | 是 | 是 |
| doamplitude | DO Amplitude | \Event\Curves\DO amplitude | double | 30 | 是 | 是 |
| dosp | DO SP | \Event\Curves\DO SP | double | 30 | 是 | 是 |
| gasflow | Gas Flow | \Event\Curves\Gas flow | double | 30 | 是 | 是 |
| gasflowsp | Gas Flow SP | \Event\Curves\Gas flow SP | double | 30 | 是 | 是 |
| o2 | O2 | \Event\Curves\O2 | double | 30 | 是 | 是 |
| o2sp | O2 SP | \Event\Curves\O2 SP | double | 30 | 是 | 是 |
| ph | pH | \Event\Curves\pH | double | 30 | 是 | 是 |
| phamplitude | pH Amplitude | \Event\Curves\pH amplitude | double | 30 | 是 | 是 |
| phsp | pH SP | \Event\Curves\pH SP | double | 30 | 是 | 是 |
| rockinganglesp | Rocking Angle SP | \Event\Curves\Rocking angle SP | double | 30 | 是 | 是 |
| rockingspeed | Rocking Speed | \Event\Curves\Rocking speed | double | 30 | 是 | 是 |
| temp | Temp | \Event\Curves\Temp | double | 30 | 是 | 是 |
| tempsp | Temp SP | \Event\Curves\Temp SP | double | 30 | 是 | 是 |
| weight | Weight | \Event\Curves\Weight | double | 30 | 是 | 是 |
| analoginput1 | Analog Input 1 | \Event\Curves\Analog input 1 | double | 30 | 是 | 是 |
| analoginput2 | Analog Input 2 | \Event\Curves\Analog input 2 | double | 30 | 是 | 是 |
| co2 | CO2 | \Event\Curves\CO2 | double | 30 | 是 | 是 |

## 4. 开发与部署经验

- WAVE 的 OPC DA Server Name/ProgID 为 UNICORN_DAServer20.System1.1，OPC Server 主机为 192.168.1.1。
- 该配置的边缘监听地址是 http://10.249.11.94:49010/，与其他边缘配置使用的本地监听形式不同；部署时必须确认监听 IP、端口和平台地址是否有意区分。
- 所有 19 个点均为 30 秒采集、均标记高频；高频标记不能理解为更短采集周期。
- Item 路径包含空格和反斜杠，配置读取、日志和点表导出必须保持原始地址，不得做不安全的路径规范化。
- 在实际服务账号下验证 UNICORN ProgID 浏览、远程 DCOM、RPC/防火墙、位数兼容和服务重启恢复。
- 平台请求超时为 15 秒，分发周期为 30 秒；平台不可达时不能阻塞 OPC 采集，应采用缓存和幂等补发。

### 投运核对

1. 浏览并读取完整 19 个 Item，核对 Event\Curves 下的空格和大小写。
2. 对 CO2、DO、O2、pH、温度、气流、摇摆、重量及 SP/Amplitude 点与设备 HMI/OPC 客户端比对。
3. 验证 30 秒采集、30 秒分发、OPC 断线重连、平台断线缓存和服务重启恢复。
4. 归档 ProgID、OPC IP、监听地址、服务账号、DCOM ACL、防火墙规则和最终点表。
