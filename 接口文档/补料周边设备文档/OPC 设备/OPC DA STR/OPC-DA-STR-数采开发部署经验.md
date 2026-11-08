# STR OPC DA 数采配置与开发部署经验

> BBI MFCSS OPCS 的多台 STR 反应器 OPC DA 采集配置。

**原始配置：** appsettings.str.json  
**配置版本：** 2026.06.15-wgqs-npp-str  
**说明：** 下表按原始 JSON 展开，列出每台设备在该 OPC DA Server 下的一级 OPC Tag/Item 清单。配置本身不等于现场连通性证明。

## 1. OPC DA Server 与边缘连接信息

| 字段 | 配置值 |
|---|---|
| OPC DA Server Name / ProgID | BBI.MFCSSOPCS |
| OPC DA Server IP / Host | 192.168.1.11 |
| Protocol | OpcDa |
| Driver ID | opcda-wgqs-npp-str |
| Driver Name | WGQS NPP STR OPC DA Source |
| Driver Enabled | 是 |
| Edge Device ID | edge-opcda-wgqs-npp-str |
| Edge Name | WGQS NPP STR OPC DA Edge |
| Edge Listen URL | http://+:8082/ |
| Platform URL | http://192.168.1.110:49010 |
| Platform Request Timeout | 15 秒 |
| Collection Enabled | 是 |
| Dispatch Interval | 1000 ms |

## 2. 一级 OPC 设备清单

| deviceId | deviceName | shortNo | enabled | 一级 Tag 数量 |
|---|---|---|---|---:|
| wgqs-npp-str-50-1 | WGQS-NPP-STR-50-1 | 50L_1 | 是 | 11 |
| wgqs-npp-str-50-2 | WGQS-NPP-STR-50-2 | 50L_2 | 是 | 11 |
| wgqs-npp-str-200-1 | WGQS-NPP-STR-200-1 | 200L_1 | 是 | 11 |
| wgqs-npp-str200-2 | WGQS-NPP-STR200-2 | 200L_2 | 是 | 11 |

## 3. 一级 OPC Tag List（完整 Item 清单）

以下是该配置对应的一级 OPC Tag 清单。address 是实际传给 OPC DA Server 的 Item 地址；tagCode 是上层业务标识；isHighRate 是当前配置中的业务分级标记，不代表实际采集周期。

### WGQS-NPP-STR-50-1（wgqs-npp-str-50-1，shortNo=50L_1）

| tagCode | displayName | OPC DA Item / Address | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| ph | ph | STR_50L_1.pH.Value | double | 5 | 否 | 是 |
| doValue | doValue | STR_50L_1.pO2.Value | double | 5 | 否 | 是 |
| temperature | temperature | STR_50L_1.TEMP.Value | double | 5 | 否 | 是 |
| mfc1 | mfc1 | STR_50L_1.AIR_OV.Value | double | 5 | 否 | 是 |
| mfc2 | mfc2 | STR_50L_1.CO2_OV.Value | double | 5 | 否 | 是 |
| mfc3 | mfc3 | STR_50L_1.AIR_SP.Value | double | 5 | 否 | 是 |
| mfc4 | mfc4 | STR_50L_1.O2.Value | double | 5 | 否 | 是 |
| mfc5 | mfc5 | STR_50L_1.N2.Value | double | 5 | 否 | 是 |
| mfc6 | mfc6 | STR_50L_1.CO2_SP.Value | double | 5 | 否 | 是 |
| agitation | agitation | STR_50L_1.STIRR.Value | double | 5 | 否 | 是 |
| workingWeight | workingWeight | STR_50L_1.VWEIGHT.Value | double | 5 | 是 | 是 |

### WGQS-NPP-STR-50-2（wgqs-npp-str-50-2，shortNo=50L_2）

| tagCode | displayName | OPC DA Item / Address | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| ph | ph | STR_50L_2.pH.Value | double | 5 | 否 | 是 |
| doValue | doValue | STR_50L_2.pO2.Value | double | 5 | 否 | 是 |
| temperature | temperature | STR_50L_2.TEMP.Value | double | 5 | 否 | 是 |
| mfc1 | mfc1 | STR_50L_2.AIR_OV.Value | double | 5 | 否 | 是 |
| mfc2 | mfc2 | STR_50L_2.CO2_OV.Value | double | 5 | 否 | 是 |
| mfc3 | mfc3 | STR_50L_2.AIR_SP.Value | double | 5 | 否 | 是 |
| mfc4 | mfc4 | STR_50L_2.O2.Value | double | 5 | 否 | 是 |
| mfc5 | mfc5 | STR_50L_2.N2.Value | double | 5 | 否 | 是 |
| mfc6 | mfc6 | STR_50L_2.CO2_SP.Value | double | 5 | 否 | 是 |
| agitation | agitation | STR_50L_2.STIRR.Value | double | 5 | 否 | 是 |
| workingWeight | workingWeight | STR_50L_2.VWEIGHT.Value | double | 5 | 是 | 是 |

### WGQS-NPP-STR-200-1（wgqs-npp-str-200-1，shortNo=200L_1）

| tagCode | displayName | OPC DA Item / Address | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| ph | ph | STR_200L_1.pH.Value | double | 5 | 否 | 是 |
| doValue | doValue | STR_200L_1.pO2.Value | double | 5 | 否 | 是 |
| temperature | temperature | STR_200L_1.TEMP.Value | double | 5 | 否 | 是 |
| mfc1 | mfc1 | STR_200L_1.AIR_OV.Value | double | 5 | 否 | 是 |
| mfc2 | mfc2 | STR_200L_1.CO2_OV.Value | double | 5 | 否 | 是 |
| mfc3 | mfc3 | STR_200L_1.AIR_SP.Value | double | 5 | 否 | 是 |
| mfc4 | mfc4 | STR_200L_1.O2.Value | double | 5 | 否 | 是 |
| mfc5 | mfc5 | STR_200L_1.N2.Value | double | 5 | 否 | 是 |
| mfc6 | mfc6 | STR_200L_1.CO2_SP.Value | double | 5 | 否 | 是 |
| agitation | agitation | STR_200L_1.STIRR.Value | double | 5 | 否 | 是 |
| workingWeight | workingWeight | STR_200L_1.VWEIGHT.Value | double | 5 | 是 | 是 |

### WGQS-NPP-STR200-2（wgqs-npp-str200-2，shortNo=200L_2）

| tagCode | displayName | OPC DA Item / Address | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| ph | ph | STR_200L_2.pH.Value | double | 5 | 否 | 是 |
| doValue | doValue | STR_200L_2.pO2.Value | double | 5 | 否 | 是 |
| temperature | temperature | STR_200L_2.TEMP.Value | double | 5 | 否 | 是 |
| mfc1 | mfc1 | STR_200L_2.AIR_OV.Value | double | 5 | 否 | 是 |
| mfc2 | mfc2 | STR_200L_2.CO2_OV.Value | double | 5 | 否 | 是 |
| mfc3 | mfc3 | STR_200L_2.AIR_SP.Value | double | 5 | 否 | 是 |
| mfc4 | mfc4 | STR_200L_2.O2.Value | double | 5 | 否 | 是 |
| mfc5 | mfc5 | STR_200L_2.N2.Value | double | 5 | 否 | 是 |
| mfc6 | mfc6 | STR_200L_2.CO2_SP.Value | double | 5 | 否 | 是 |
| agitation | agitation | STR_200L_2.STIRR.Value | double | 5 | 否 | 是 |
| workingWeight | workingWeight | STR_200L_2.VWEIGHT.Value | double | 5 | 是 | 是 |

## 4. 开发与部署经验

四台 STR 设备点位结构一致，适合采用“点位模板 + 设备前缀”生成，但必须保存展开后的最终 Item 清单。
mfc1～mfc6 是业务别名，实际对应 AIR_OV、CO2_OV、AIR_SP、O2、N2、CO2_SP；新系统应另存 PV/SP、单位和权限。
当前所有点均为 5 秒采集，只有 workingWeight 标记高频；高频标记不能自动等价为更短轮询。
STR 与 RM 共用 OPC DA Server BBI.MFCSSOPCS @ 192.168.1.11，但必须使用独立 edge/driver/端口、缓存和监控维度。
在实际服务账号下验证远程 DCOM、ProgID 浏览、RPC/防火墙、位数兼容和重启恢复。

### 投运核对

1. 按本表逐台浏览 11 个 Item，共 44 个。
2. 比对 pH、DO、温度、MFC、搅拌和工作重量。
3. 验证 5 秒采集、1 秒分发、单点坏质量隔离、断线重连和缓存补发。
4. 重点检查 wgqs-npp-str200-2 的命名格式与设备属性映射。
