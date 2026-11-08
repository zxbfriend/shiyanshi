# XDR OPC DA 数采配置与开发部署经验

> Xcellerex / ArchestrA 风格的单台反应器 OPC DA 采集配置。

**原始配置：** appsettings.xdr.json  
**配置版本：** 2026.06.15-wgqs-npp-xdr  
**说明：** 下表按原始 JSON 展开，列出每台设备在该 OPC DA Server 下的一级 OPC Tag/Item 清单。配置本身不等于现场连通性证明。

## 1. OPC DA Server 与边缘连接信息

| 字段 | 配置值 |
|---|---|
| OPC DA Server Name / ProgID | ArchestrA.FSGateway |
| OPC DA Server IP / Host | 192.168.1.10 |
| Protocol | OpcDa |
| Driver ID | opcda-wgqs-npp-xdr |
| Driver Name | WGQS NPP XDR OPC DA Source |
| Driver Enabled | 是 |
| Edge Device ID | edge-opcda-wgqs-npp-xdr |
| Edge Name | WGQS NPP XDR OPC DA Edge |
| Edge Listen URL | http://+:8083/ |
| Platform URL | http://192.168.1.110:49010 |
| Platform Request Timeout | 15 秒 |
| Collection Enabled | 是 |
| Dispatch Interval | 1000 ms |

## 2. 一级 OPC 设备清单

| deviceId | deviceName | shortNo | enabled | 一级 Tag 数量 |
|---|---|---|---|---:|
| wgqs-npp-xdr-v1 | WGQS-NPP-XDR-V1 | 50L_1 | 是 | 12 |

## 3. 一级 OPC Tag List（完整 Item 清单）

以下是该配置对应的一级 OPC Tag 清单。address 是实际传给 OPC DA Server 的 Item 地址；tagCode 是上层业务标识；isHighRate 是当前配置中的业务分级标记，不代表实际采集周期。

### WGQS-NPP-XDR-V1（wgqs-npp-xdr-v1，shortNo=50L_1）

| tagCode | displayName | OPC DA Item / Address | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| ph | ph | Xcellerex.Reactors.Reactor01.Transmitters[1].PID.PV | double | 5 | 否 | 是 |
| doValue | doValue | Xcellerex.Reactors.Reactor01.Transmitters[0].PID.PV | double | 5 | 否 | 是 |
| temperature | temperature | Xcellerex.Reactors.Reactor01.Transmitters[2].PID.PV | double | 5 | 否 | 是 |
| pressure | pressure | Xcellerex.Reactors.Reactor01.BagPressures[0].PID.PV | double | 5 | 否 | 是 |
| mfc1 | mfc1 | Xcellerex.Reactors.Reactor01.MFCs[0].PID.PV | double | 5 | 否 | 是 |
| mfc2 | mfc2 | Xcellerex.Reactors.Reactor01.MFCs[1].PID.PV | double | 5 | 否 | 是 |
| mfc3 | mfc3 | Xcellerex.Reactors.Reactor01.MFCs[2].PID.PV | double | 5 | 否 | 是 |
| mfc4 | mfc4 | Xcellerex.Reactors.Reactor01.MFCs[3].PID.PV | double | 5 | 否 | 是 |
| mfc5 | mfc5 | Xcellerex.Reactors.Reactor01.MFCs[4].PID.PV | double | 5 | 否 | 是 |
| mfc6 | mfc6 | Xcellerex.Reactors.Reactor01.MFCs[5].PID.PV | double | 5 | 否 | 是 |
| agitation | agitation | Xcellerex.Reactors.Reactor01.Agitators[0].PID.PV | double | 5 | 否 | 是 |
| workingWeight | workingWeight | Xcellerex.Reactors.Reactor01.Weights[0].PID.PV | double | 5 | 是 | 是 |

## 4. 开发与部署经验

XDR 使用 ArchestrA 层级地址和数组下标，例如 Transmitters[0..2]、MFCs[0..5]；下标是现场组态语义，新增设备必须用 OPC 浏览器逐项确认。
isHighRate 只表示业务分级；当前所有点仍为 5 秒采集，不能直接当作更高采样频率。
采样结果必须保留 OPC Quality、源时间戳、边缘采集时间和错误原因；读取失败不能填充 0。
部署时在实际 Windows 服务账号下验证 ProgID、远程 DCOM、RPC/防火墙、位数兼容和服务重启后的权限。
平台请求超时 15 秒只应约束上传请求，不能阻塞 OPC 读取；断网时应本地缓存并幂等补发。

### 投运核对

1. 浏览并读取本表全部 12 个 Item。
2. 与 HMI/OPC 测试客户端比对 pH、DO、温度、压力、MFC、搅拌和重量。
3. 验证 5 秒采集、1 秒分发、OPC 断线重连和平台断线缓存。
4. 归档最终 ProgID、OPC 主机、服务账号、DCOM ACL、防火墙规则和点表。
