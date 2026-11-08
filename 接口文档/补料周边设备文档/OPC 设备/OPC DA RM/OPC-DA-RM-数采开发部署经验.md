# RM OPC DA 数采配置与开发部署经验

> BBI MFCSS OPCS 的 PU/RM 设备 OPC DA 采集配置。

**原始配置：** appsettings_rm.json  
**配置版本：** 2026.06.10-bbi-mfcssopcs  
**说明：** 下表按原始 JSON 展开，列出每台设备在该 OPC DA Server 下的一级 OPC Tag/Item 清单。配置本身不等于现场连通性证明。

## 1. OPC DA Server 与边缘连接信息

| 字段 | 配置值 |
|---|---|
| OPC DA Server Name / ProgID | BBI.MFCSSOPCS |
| OPC DA Server IP / Host | 192.168.1.11 |
| Protocol | OpcDa |
| Driver ID | opcda-bbi-mfcssopcs |
| Driver Name | BBI MFCSS OPC DA Source |
| Driver Enabled | 是 |
| Edge Device ID | edge-opcda-bbi-mfcssopcs |
| Edge Name | BBI MFCSS OPC DA Edge |
| Edge Listen URL | http://+:8080/ |
| Platform URL | http://192.168.1.110:49010 |
| Platform Request Timeout | 15 秒 |
| Collection Enabled | 是 |
| Dispatch Interval | 1000 ms |

## 2. 一级 OPC 设备清单

| deviceId | deviceName | shortNo | enabled | 一级 Tag 数量 |
|---|---|---|---|---:|
| opcda-bbi-pu3 | BBI-PU3 | PU3 | 是 | 6 |
| opcda-bbi-pu5 | BBI-PU5 | PU5 | 是 | 6 |
| opcda-bbi-pu4 | BBI-PU4 | PU4 | 是 | 6 |

## 3. 一级 OPC Tag List（完整 Item 清单）

以下是该配置对应的一级 OPC Tag 清单。address 是实际传给 OPC DA Server 的 Item 地址；tagCode 是上层业务标识；isHighRate 是当前配置中的业务分级标记，不代表实际采集周期。

### BBI-PU3（opcda-bbi-pu3，shortNo=PU3）

| tagCode | displayName | OPC DA Item / Address | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| angle | Angle | PU3.RM.Angle.Value | double | 5 | 是 | 是 |
| co2 | CO2 | PU3.RM.CO2.Value | double | 5 | 是 | 是 |
| gasflow | Gasflow | PU3.RM.Gasflow1.Value | double | 5 | 是 | 是 |
| speed | Speed | PU3.RM.Speed.Value | double | 5 | 是 | 是 |
| temp | Temp | PU3.RM.Temp1.Value | double | 5 | 是 | 是 |
| weight | Weight | PU3.RM.GrossWeight.Value | double | 5 | 是 | 是 |

### BBI-PU5（opcda-bbi-pu5，shortNo=PU5）

| tagCode | displayName | OPC DA Item / Address | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| angle | Angle | PU5.RM.Angle.Value | double | 5 | 是 | 是 |
| co2 | CO2 | PU5.RM.CO2.Value | double | 5 | 是 | 是 |
| gasflow | Gasflow | PU5.RM.Gasflow1.Value | double | 5 | 是 | 是 |
| speed | Speed | PU5.RM.Speed.Value | double | 5 | 是 | 是 |
| temp | Temp | PU5.RM.Temp1.Value | double | 5 | 是 | 是 |
| weight | Weight | PU5.RM.GrossWeight.Value | double | 5 | 是 | 是 |

### BBI-PU4（opcda-bbi-pu4，shortNo=PU4）

| tagCode | displayName | OPC DA Item / Address | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| angle | Angle | PU4.RM.Angle.Value | double | 5 | 是 | 是 |
| co2 | CO2 | PU4.RM.CO2.Value | double | 5 | 是 | 是 |
| gasflow | Gasflow | PU4.RM.Gasflow1.Value | double | 5 | 是 | 是 |
| speed | Speed | PU4.RM.Speed.Value | double | 5 | 是 | 是 |
| temp | Temp | PU4.RM.Temp1.Value | double | 5 | 是 | 是 |
| weight | Weight | PU4.RM.GrossWeight.Value | double | 5 | 是 | 是 |

## 4. 开发与部署经验

三台 PU 结构一致，可用 PU{n}.RM.<field>.Value 模板生成；展开后必须保存最终 18 个 Item 清单。
RM 的 6 个点全部标记高频，但实际轮询仍为 5 秒；若补料闭环需要更快数据，应单独设计周期和负载评估。
Angle、CO2、Gasflow1、Speed、Temp1、GrossWeight 的单位、量程和质量策略未写在当前配置中，新点表必须补齐。
RM 与 STR 共用 BBI.MFCSSOPCS @ 192.168.1.11，但边缘端口、edge ID、driver ID、缓存和监控必须隔离。
在实际服务账号下验证远程 DCOM、ProgID 浏览、RPC/防火墙、位数兼容和服务重启后的连接能力。

### 投运核对

1. 在 PU3、PU5、PU4 下逐项浏览本表 6 个 Item。
2. 与 HMI/OPC 测试客户端确认变量值和工程单位。
3. 验证 5 秒采集、1 秒分发、全量高频业务路由和断线补发。
4. 归档单位、质量码样本、服务账号、DCOM ACL、端口和最终点表。
