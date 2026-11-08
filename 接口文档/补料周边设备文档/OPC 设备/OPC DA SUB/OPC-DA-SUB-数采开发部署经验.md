# SUB OPC DA 数采配置与开发部署经验

> DeltaV OPC DA 的多台 SUB 反应器 OPC DA 采集配置。

**原始配置：** appsettings.sub.json  
**配置版本：** 2026.06.15-wgqs-npp-sub  
**说明：** 下表按原始 JSON 展开，列出每台设备在该 OPC DA Server 下的一级 OPC Tag/Item 清单。配置本身不等于现场连通性证明。

## 1. OPC DA Server 与边缘连接信息

| 字段 | 配置值 |
|---|---|
| OPC DA Server Name / ProgID | OPC.DeltaV.1 |
| OPC DA Server IP / Host | 192.168.1.100 |
| Protocol | OpcDa |
| Driver ID | opcda-wgqs-npp-sub |
| Driver Name | WGQS NPP SUB OPC DA Source |
| Driver Enabled | 是 |
| Edge Device ID | edge-opcda-wgqs-npp-sub |
| Edge Name | WGQS NPP SUB OPC DA Edge |
| Edge Listen URL | http://+:8081/ |
| Platform URL | http://192.168.1.110:49010 |
| Platform Request Timeout | 15 秒 |
| Collection Enabled | 是 |
| Dispatch Interval | 1000 ms |

## 2. 一级 OPC 设备清单

| deviceId | deviceName | shortNo | enabled | 一级 Tag 数量 |
|---|---|---|---|---:|
| wgqs-npp-sub-v4 | WGQS-NPP-SUB-V4 | V4 | 是 | 33 |
| wgqs-npp-sub-v9 | WGQS-NPP-SUB-V9 | V9 | 是 | 33 |
| wgqs-npp-sub-v2 | WGQS-NPP-SUB-V2 | V2 | 是 | 33 |
| wgqs-npp-sub-v6 | WGQS-NPP-SUB-V6 | V6 | 是 | 33 |
| wgqs-npp-sub-v1 | WGQS-NPP-SUB-V1 | V1 | 是 | 33 |
| wgqs-npp-sub-v8 | WGQS-NPP-SUB-V8 | V8 | 是 | 33 |
| wgqs-npp-sub-v3 | WGQS-NPP-SUB-V3 | V3 | 是 | 33 |
| wgqs-npp-sub-v5 | WGQS-NPP-SUB-V5 | V5 | 是 | 33 |
| wgqs-npp-sub-v7 | WGQS-NPP-SUB-V7 | V7 | 是 | 33 |
| wgqs-npp-sub-v10 | WGQS-NPP-SUB-V10 | V10 | 是 | 33 |

## 3. 一级 OPC Tag List（完整 Item 清单）

以下是该配置对应的一级 OPC Tag 清单。address 是实际传给 OPC DA Server 的 Item 地址；tagCode 是上层业务标识；isHighRate 是当前配置中的业务分级标记，不代表实际采集周期。

### WGQS-NPP-SUB-V4（wgqs-npp-sub-v4，shortNo=V4）

| tagCode | displayName | OPC DA Item / Address | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| ph | ph | V4-AIC-PH/PID1/PV.CV | double | 5 | 否 | 是 |
| phset | phset | V4-AIC-PH/PID1/SP.CV | double | 5 | 否 | 是 |
| doValue | doValue | V4-AIC-DO/PID1/PV.CV | double | 5 | 否 | 是 |
| doValueset | doValueset | V4-AIC-DO/PID1/SP.CV | double | 5 | 否 | 是 |
| temperature | temperature | V4-TIC-VSL/PID1/PV.CV | double | 5 | 否 | 是 |
| temperatureset | temperatureset | V4-TIC-VSL/PID1/SP.CV | double | 5 | 否 | 是 |
| pressure | pressure | V4-PI-VSL/PV.CV | double | 5 | 否 | 是 |
| mfc1 | mfc1 | V4-FIC-1/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc2 | mfc2 | V4-FIC-2/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc3 | mfc3 | V4-FIC-3/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc4 | mfc4 | V4-FIC-4/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc5 | mfc5 | V4-FIC-5/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc6 | mfc6 | V4-FIC-6/PID1/PV.CV | double | 5 | 否 | 是 |
| pump1 | pump1 | V4-SIC-1/PID1/PV.CV | double | 5 | 是 | 是 |
| pump2 | pump2 | V4-SIC-2/PID1/PV.CV | double | 5 | 是 | 是 |
| pump3 | pump3 | V4-SIC-3/PID1/PV.CV | double | 5 | 是 | 是 |
| pump4 | pump4 | V4-SIC-4/PID1/PV.CV | double | 5 | 是 | 是 |
| pump5 | pump5 | V4-SIC-5/PID1/PV.CV | double | 5 | 是 | 是 |
| pump6 | pump6 | V4-SIC-6/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1set | pump1set | V4-SIC-1/PID1/SP.CV | double | 5 | 是 | 是 |
| pump2set | pump2set | V4-SIC-2/PID1/SP.CV | double | 5 | 是 | 是 |
| pump3set | pump3set | V4-SIC-3/PID1/SP.CV | double | 5 | 是 | 是 |
| pump4set | pump4set | V4-SIC-4/PID1/SP.CV | double | 5 | 是 | 是 |
| pump5set | pump5set | V4-SIC-5/PID1/SP.CV | double | 5 | 是 | 是 |
| pump6set | pump6set | V4-SIC-6/PID1/SP.CV | double | 5 | 是 | 是 |
| agitation | agitation | V4-SIC-AGIT/PV.CV | double | 5 | 否 | 是 |
| workingWeight | workingWeight | V4-WIC-VSL/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1Unit | pump1Unit | V4-SIC-1/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump2Unit | pump2Unit | V4-SIC-2/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump3Unit | pump3Unit | V4-SIC-3/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump4Unit | pump4Unit | V4-SIC-4/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump5Unit | pump5Unit | V4-SIC-5/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump6Unit | pump6Unit | V4-SIC-6/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |

### WGQS-NPP-SUB-V9（wgqs-npp-sub-v9，shortNo=V9）

| tagCode | displayName | OPC DA Item / Address | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| ph | ph | V9-AIC-PH/PID1/PV.CV | double | 5 | 否 | 是 |
| phset | phset | V9-AIC-PH/PID1/SP.CV | double | 5 | 否 | 是 |
| doValue | doValue | V9-AIC-DO/PID1/PV.CV | double | 5 | 否 | 是 |
| doValueset | doValueset | V9-AIC-DO/PID1/SP.CV | double | 5 | 否 | 是 |
| temperature | temperature | V9-TIC-VSL/PID1/PV.CV | double | 5 | 否 | 是 |
| temperatureset | temperatureset | V9-TIC-VSL/PID1/SP.CV | double | 5 | 否 | 是 |
| pressure | pressure | V9-PI-VSL/PV.CV | double | 5 | 否 | 是 |
| mfc1 | mfc1 | V9-FIC-1/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc2 | mfc2 | V9-FIC-2/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc3 | mfc3 | V9-FIC-3/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc4 | mfc4 | V9-FIC-4/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc5 | mfc5 | V9-FIC-5/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc6 | mfc6 | V9-FIC-6/PID1/PV.CV | double | 5 | 否 | 是 |
| pump1 | pump1 | V9-SIC-1/PID1/PV.CV | double | 5 | 是 | 是 |
| pump2 | pump2 | V9-SIC-2/PID1/PV.CV | double | 5 | 是 | 是 |
| pump3 | pump3 | V9-SIC-3/PID1/PV.CV | double | 5 | 是 | 是 |
| pump4 | pump4 | V9-SIC-4/PID1/PV.CV | double | 5 | 是 | 是 |
| pump5 | pump5 | V9-SIC-5/PID1/PV.CV | double | 5 | 是 | 是 |
| pump6 | pump6 | V9-SIC-6/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1set | pump1set | V9-SIC-1/PID1/SP.CV | double | 5 | 是 | 是 |
| pump2set | pump2set | V9-SIC-2/PID1/SP.CV | double | 5 | 是 | 是 |
| pump3set | pump3set | V9-SIC-3/PID1/SP.CV | double | 5 | 是 | 是 |
| pump4set | pump4set | V9-SIC-4/PID1/SP.CV | double | 5 | 是 | 是 |
| pump5set | pump5set | V9-SIC-5/PID1/SP.CV | double | 5 | 是 | 是 |
| pump6set | pump6set | V9-SIC-6/PID1/SP.CV | double | 5 | 是 | 是 |
| agitation | agitation | V9-SIC-AGIT/PV.CV | double | 5 | 否 | 是 |
| workingWeight | workingWeight | V9-WIC-VSL/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1Unit | pump1Unit | V9-SIC-1/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump2Unit | pump2Unit | V9-SIC-2/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump3Unit | pump3Unit | V9-SIC-3/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump4Unit | pump4Unit | V9-SIC-4/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump5Unit | pump5Unit | V9-SIC-5/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump6Unit | pump6Unit | V9-SIC-6/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |

### WGQS-NPP-SUB-V2（wgqs-npp-sub-v2，shortNo=V2）

| tagCode | displayName | OPC DA Item / Address | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| ph | ph | V2-AIC-PH/PID1/PV.CV | double | 5 | 否 | 是 |
| phset | phset | V2-AIC-PH/PID1/SP.CV | double | 5 | 否 | 是 |
| doValue | doValue | V2-AIC-DO/PID1/PV.CV | double | 5 | 否 | 是 |
| doValueset | doValueset | V2-AIC-DO/PID1/SP.CV | double | 5 | 否 | 是 |
| temperature | temperature | V2-TIC-VSL/PID1/PV.CV | double | 5 | 否 | 是 |
| temperatureset | temperatureset | V2-TIC-VSL/PID1/SP.CV | double | 5 | 否 | 是 |
| pressure | pressure | V2-PI-VSL/PV.CV | double | 5 | 否 | 是 |
| mfc1 | mfc1 | V2-FIC-1/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc2 | mfc2 | V2-FIC-2/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc3 | mfc3 | V2-FIC-3/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc4 | mfc4 | V2-FIC-4/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc5 | mfc5 | V2-FIC-5/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc6 | mfc6 | V2-FIC-6/PID1/PV.CV | double | 5 | 否 | 是 |
| pump1 | pump1 | V2-SIC-1/PID1/PV.CV | double | 5 | 是 | 是 |
| pump2 | pump2 | V2-SIC-2/PID1/PV.CV | double | 5 | 是 | 是 |
| pump3 | pump3 | V2-SIC-3/PID1/PV.CV | double | 5 | 是 | 是 |
| pump4 | pump4 | V2-SIC-4/PID1/PV.CV | double | 5 | 是 | 是 |
| pump5 | pump5 | V2-SIC-5/PID1/PV.CV | double | 5 | 是 | 是 |
| pump6 | pump6 | V2-SIC-6/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1set | pump1set | V2-SIC-1/PID1/SP.CV | double | 5 | 是 | 是 |
| pump2set | pump2set | V2-SIC-2/PID1/SP.CV | double | 5 | 是 | 是 |
| pump3set | pump3set | V2-SIC-3/PID1/SP.CV | double | 5 | 是 | 是 |
| pump4set | pump4set | V2-SIC-4/PID1/SP.CV | double | 5 | 是 | 是 |
| pump5set | pump5set | V2-SIC-5/PID1/SP.CV | double | 5 | 是 | 是 |
| pump6set | pump6set | V2-SIC-6/PID1/SP.CV | double | 5 | 是 | 是 |
| agitation | agitation | V2-SIC-AGIT/PV.CV | double | 5 | 否 | 是 |
| workingWeight | workingWeight | V2-WIC-VSL/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1Unit | pump1Unit | V2-SIC-1/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump2Unit | pump2Unit | V2-SIC-2/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump3Unit | pump3Unit | V2-SIC-3/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump4Unit | pump4Unit | V2-SIC-4/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump5Unit | pump5Unit | V2-SIC-5/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump6Unit | pump6Unit | V2-SIC-6/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |

### WGQS-NPP-SUB-V6（wgqs-npp-sub-v6，shortNo=V6）

| tagCode | displayName | OPC DA Item / Address | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| ph | ph | V6-AIC-PH/PID1/PV.CV | double | 5 | 否 | 是 |
| phset | phset | V6-AIC-PH/PID1/SP.CV | double | 5 | 否 | 是 |
| doValue | doValue | V6-AIC-DO/PID1/PV.CV | double | 5 | 否 | 是 |
| doValueset | doValueset | V6-AIC-DO/PID1/SP.CV | double | 5 | 否 | 是 |
| temperature | temperature | V6-TIC-VSL/PID1/PV.CV | double | 5 | 否 | 是 |
| temperatureset | temperatureset | V6-TIC-VSL/PID1/SP.CV | double | 5 | 否 | 是 |
| pressure | pressure | V6-PI-VSL/PV.CV | double | 5 | 否 | 是 |
| mfc1 | mfc1 | V6-FIC-1/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc2 | mfc2 | V6-FIC-2/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc3 | mfc3 | V6-FIC-3/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc4 | mfc4 | V6-FIC-4/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc5 | mfc5 | V6-FIC-5/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc6 | mfc6 | V6-FIC-6/PID1/PV.CV | double | 5 | 否 | 是 |
| pump1 | pump1 | V6-SIC-1/PID1/PV.CV | double | 5 | 是 | 是 |
| pump2 | pump2 | V6-SIC-2/PID1/PV.CV | double | 5 | 是 | 是 |
| pump3 | pump3 | V6-SIC-3/PID1/PV.CV | double | 5 | 是 | 是 |
| pump4 | pump4 | V6-SIC-4/PID1/PV.CV | double | 5 | 是 | 是 |
| pump5 | pump5 | V6-SIC-5/PID1/PV.CV | double | 5 | 是 | 是 |
| pump6 | pump6 | V6-SIC-6/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1set | pump1set | V6-SIC-1/PID1/SP.CV | double | 5 | 是 | 是 |
| pump2set | pump2set | V6-SIC-2/PID1/SP.CV | double | 5 | 是 | 是 |
| pump3set | pump3set | V6-SIC-3/PID1/SP.CV | double | 5 | 是 | 是 |
| pump4set | pump4set | V6-SIC-4/PID1/SP.CV | double | 5 | 是 | 是 |
| pump5set | pump5set | V6-SIC-5/PID1/SP.CV | double | 5 | 是 | 是 |
| pump6set | pump6set | V6-SIC-6/PID1/SP.CV | double | 5 | 是 | 是 |
| agitation | agitation | V6-SIC-AGIT/PV.CV | double | 5 | 否 | 是 |
| workingWeight | workingWeight | V6-WIC-VSL/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1Unit | pump1Unit | V6-SIC-1/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump2Unit | pump2Unit | V6-SIC-2/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump3Unit | pump3Unit | V6-SIC-3/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump4Unit | pump4Unit | V6-SIC-4/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump5Unit | pump5Unit | V6-SIC-5/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump6Unit | pump6Unit | V6-SIC-6/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |

### WGQS-NPP-SUB-V1（wgqs-npp-sub-v1，shortNo=V1）

| tagCode | displayName | OPC DA Item / Address | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| ph | ph | V1-AIC-PH/PID1/PV.CV | double | 5 | 否 | 是 |
| phset | phset | V1-AIC-PH/PID1/SP.CV | double | 5 | 否 | 是 |
| doValue | doValue | V1-AIC-DO/PID1/PV.CV | double | 5 | 否 | 是 |
| doValueset | doValueset | V1-AIC-DO/PID1/SP.CV | double | 5 | 否 | 是 |
| temperature | temperature | V1-TIC-VSL/PID1/PV.CV | double | 5 | 否 | 是 |
| temperatureset | temperatureset | V1-TIC-VSL/PID1/SP.CV | double | 5 | 否 | 是 |
| pressure | pressure | V1-PI-VSL/PV.CV | double | 5 | 否 | 是 |
| mfc1 | mfc1 | V1-FIC-1/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc2 | mfc2 | V1-FIC-2/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc3 | mfc3 | V1-FIC-3/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc4 | mfc4 | V1-FIC-4/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc5 | mfc5 | V1-FIC-5/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc6 | mfc6 | V1-FIC-6/PID1/PV.CV | double | 5 | 否 | 是 |
| pump1 | pump1 | V1-SIC-1/PID1/PV.CV | double | 5 | 是 | 是 |
| pump2 | pump2 | V1-SIC-2/PID1/PV.CV | double | 5 | 是 | 是 |
| pump3 | pump3 | V1-SIC-3/PID1/PV.CV | double | 5 | 是 | 是 |
| pump4 | pump4 | V1-SIC-4/PID1/PV.CV | double | 5 | 是 | 是 |
| pump5 | pump5 | V1-SIC-5/PID1/PV.CV | double | 5 | 是 | 是 |
| pump6 | pump6 | V1-SIC-6/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1set | pump1set | V1-SIC-1/PID1/SP.CV | double | 5 | 是 | 是 |
| pump2set | pump2set | V1-SIC-2/PID1/SP.CV | double | 5 | 是 | 是 |
| pump3set | pump3set | V1-SIC-3/PID1/SP.CV | double | 5 | 是 | 是 |
| pump4set | pump4set | V1-SIC-4/PID1/SP.CV | double | 5 | 是 | 是 |
| pump5set | pump5set | V1-SIC-5/PID1/SP.CV | double | 5 | 是 | 是 |
| pump6set | pump6set | V1-SIC-6/PID1/SP.CV | double | 5 | 是 | 是 |
| agitation | agitation | V1-SIC-AGIT/PV.CV | double | 5 | 否 | 是 |
| workingWeight | workingWeight | V1-WIC-VSL/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1Unit | pump1Unit | V1-SIC-1/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump2Unit | pump2Unit | V1-SIC-2/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump3Unit | pump3Unit | V1-SIC-3/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump4Unit | pump4Unit | V1-SIC-4/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump5Unit | pump5Unit | V1-SIC-5/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump6Unit | pump6Unit | V1-SIC-6/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |

### WGQS-NPP-SUB-V8（wgqs-npp-sub-v8，shortNo=V8）

| tagCode | displayName | OPC DA Item / Address | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| ph | ph | V8-AIC-PH/PID1/PV.CV | double | 5 | 否 | 是 |
| phset | phset | V8-AIC-PH/PID1/SP.CV | double | 5 | 否 | 是 |
| doValue | doValue | V8-AIC-DO/PID1/PV.CV | double | 5 | 否 | 是 |
| doValueset | doValueset | V8-AIC-DO/PID1/SP.CV | double | 5 | 否 | 是 |
| temperature | temperature | V8-TIC-VSL/PID1/PV.CV | double | 5 | 否 | 是 |
| temperatureset | temperatureset | V8-TIC-VSL/PID1/SP.CV | double | 5 | 否 | 是 |
| pressure | pressure | V8-PI-VSL/PV.CV | double | 5 | 否 | 是 |
| mfc1 | mfc1 | V8-FIC-1/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc2 | mfc2 | V8-FIC-2/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc3 | mfc3 | V8-FIC-3/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc4 | mfc4 | V8-FIC-4/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc5 | mfc5 | V8-FIC-5/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc6 | mfc6 | V8-FIC-6/PID1/PV.CV | double | 5 | 否 | 是 |
| pump1 | pump1 | V8-SIC-1/PID1/PV.CV | double | 5 | 是 | 是 |
| pump2 | pump2 | V8-SIC-2/PID1/PV.CV | double | 5 | 是 | 是 |
| pump3 | pump3 | V8-SIC-3/PID1/PV.CV | double | 5 | 是 | 是 |
| pump4 | pump4 | V8-SIC-4/PID1/PV.CV | double | 5 | 是 | 是 |
| pump5 | pump5 | V8-SIC-5/PID1/PV.CV | double | 5 | 是 | 是 |
| pump6 | pump6 | V8-SIC-6/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1set | pump1set | V8-SIC-1/PID1/SP.CV | double | 5 | 是 | 是 |
| pump2set | pump2set | V8-SIC-2/PID1/SP.CV | double | 5 | 是 | 是 |
| pump3set | pump3set | V8-SIC-3/PID1/SP.CV | double | 5 | 是 | 是 |
| pump4set | pump4set | V8-SIC-4/PID1/SP.CV | double | 5 | 是 | 是 |
| pump5set | pump5set | V8-SIC-5/PID1/SP.CV | double | 5 | 是 | 是 |
| pump6set | pump6set | V8-SIC-6/PID1/SP.CV | double | 5 | 是 | 是 |
| agitation | agitation | V8-SIC-AGIT/PV.CV | double | 5 | 否 | 是 |
| workingWeight | workingWeight | V8-WIC-VSL/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1Unit | pump1Unit | V8-SIC-1/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump2Unit | pump2Unit | V8-SIC-2/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump3Unit | pump3Unit | V8-SIC-3/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump4Unit | pump4Unit | V8-SIC-4/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump5Unit | pump5Unit | V8-SIC-5/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump6Unit | pump6Unit | V8-SIC-6/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |

### WGQS-NPP-SUB-V3（wgqs-npp-sub-v3，shortNo=V3）

| tagCode | displayName | OPC DA Item / Address | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| ph | ph | V3-AIC-PH/PID1/PV.CV | double | 5 | 否 | 是 |
| phset | phset | V3-AIC-PH/PID1/SP.CV | double | 5 | 否 | 是 |
| doValue | doValue | V3-AIC-DO/PID1/PV.CV | double | 5 | 否 | 是 |
| doValueset | doValueset | V3-AIC-DO/PID1/SP.CV | double | 5 | 否 | 是 |
| temperature | temperature | V3-TIC-VSL/PID1/PV.CV | double | 5 | 否 | 是 |
| temperatureset | temperatureset | V3-TIC-VSL/PID1/SP.CV | double | 5 | 否 | 是 |
| pressure | pressure | V3-PI-VSL/PV.CV | double | 5 | 否 | 是 |
| mfc1 | mfc1 | V3-FIC-1/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc2 | mfc2 | V3-FIC-2/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc3 | mfc3 | V3-FIC-3/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc4 | mfc4 | V3-FIC-4/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc5 | mfc5 | V3-FIC-5/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc6 | mfc6 | V3-FIC-6/PID1/PV.CV | double | 5 | 否 | 是 |
| pump1 | pump1 | V3-SIC-1/PID1/PV.CV | double | 5 | 是 | 是 |
| pump2 | pump2 | V3-SIC-2/PID1/PV.CV | double | 5 | 是 | 是 |
| pump3 | pump3 | V3-SIC-3/PID1/PV.CV | double | 5 | 是 | 是 |
| pump4 | pump4 | V3-SIC-4/PID1/PV.CV | double | 5 | 是 | 是 |
| pump5 | pump5 | V3-SIC-5/PID1/PV.CV | double | 5 | 是 | 是 |
| pump6 | pump6 | V3-SIC-6/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1set | pump1set | V3-SIC-1/PID1/SP.CV | double | 5 | 是 | 是 |
| pump2set | pump2set | V3-SIC-2/PID1/SP.CV | double | 5 | 是 | 是 |
| pump3set | pump3set | V3-SIC-3/PID1/SP.CV | double | 5 | 是 | 是 |
| pump4set | pump4set | V3-SIC-4/PID1/SP.CV | double | 5 | 是 | 是 |
| pump5set | pump5set | V3-SIC-5/PID1/SP.CV | double | 5 | 是 | 是 |
| pump6set | pump6set | V3-SIC-6/PID1/SP.CV | double | 5 | 是 | 是 |
| agitation | agitation | V3-SIC-AGIT/PV.CV | double | 5 | 否 | 是 |
| workingWeight | workingWeight | V3-WIC-VSL/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1Unit | pump1Unit | V3-SIC-1/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump2Unit | pump2Unit | V3-SIC-2/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump3Unit | pump3Unit | V3-SIC-3/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump4Unit | pump4Unit | V3-SIC-4/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump5Unit | pump5Unit | V3-SIC-5/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump6Unit | pump6Unit | V3-SIC-6/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |

### WGQS-NPP-SUB-V5（wgqs-npp-sub-v5，shortNo=V5）

| tagCode | displayName | OPC DA Item / Address | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| ph | ph | V5-AIC-PH/PID1/PV.CV | double | 5 | 否 | 是 |
| phset | phset | V5-AIC-PH/PID1/SP.CV | double | 5 | 否 | 是 |
| doValue | doValue | V5-AIC-DO/PID1/PV.CV | double | 5 | 否 | 是 |
| doValueset | doValueset | V5-AIC-DO/PID1/SP.CV | double | 5 | 否 | 是 |
| temperature | temperature | V5-TIC-VSL/PID1/PV.CV | double | 5 | 否 | 是 |
| temperatureset | temperatureset | V5-TIC-VSL/PID1/SP.CV | double | 5 | 否 | 是 |
| pressure | pressure | V5-PI-VSL/PV.CV | double | 5 | 否 | 是 |
| mfc1 | mfc1 | V5-FIC-1/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc2 | mfc2 | V5-FIC-2/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc3 | mfc3 | V5-FIC-3/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc4 | mfc4 | V5-FIC-4/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc5 | mfc5 | V5-FIC-5/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc6 | mfc6 | V5-FIC-6/PID1/PV.CV | double | 5 | 否 | 是 |
| pump1 | pump1 | V5-SIC-1/PID1/PV.CV | double | 5 | 是 | 是 |
| pump2 | pump2 | V5-SIC-2/PID1/PV.CV | double | 5 | 是 | 是 |
| pump3 | pump3 | V5-SIC-3/PID1/PV.CV | double | 5 | 是 | 是 |
| pump4 | pump4 | V5-SIC-4/PID1/PV.CV | double | 5 | 是 | 是 |
| pump5 | pump5 | V5-SIC-5/PID1/PV.CV | double | 5 | 是 | 是 |
| pump6 | pump6 | V5-SIC-6/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1set | pump1set | V5-SIC-1/PID1/SP.CV | double | 5 | 是 | 是 |
| pump2set | pump2set | V5-SIC-2/PID1/SP.CV | double | 5 | 是 | 是 |
| pump3set | pump3set | V5-SIC-3/PID1/SP.CV | double | 5 | 是 | 是 |
| pump4set | pump4set | V5-SIC-4/PID1/SP.CV | double | 5 | 是 | 是 |
| pump5set | pump5set | V5-SIC-5/PID1/SP.CV | double | 5 | 是 | 是 |
| pump6set | pump6set | V5-SIC-6/PID1/SP.CV | double | 5 | 是 | 是 |
| agitation | agitation | V5-SIC-AGIT/PV.CV | double | 5 | 否 | 是 |
| workingWeight | workingWeight | V5-WIC-VSL/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1Unit | pump1Unit | V5-SIC-1/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump2Unit | pump2Unit | V5-SIC-2/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump3Unit | pump3Unit | V5-SIC-3/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump4Unit | pump4Unit | V5-SIC-4/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump5Unit | pump5Unit | V5-SIC-5/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump6Unit | pump6Unit | V5-SIC-6/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |

### WGQS-NPP-SUB-V7（wgqs-npp-sub-v7，shortNo=V7）

| tagCode | displayName | OPC DA Item / Address | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| ph | ph | V7-AIC-PH/PID1/PV.CV | double | 5 | 否 | 是 |
| phset | phset | V7-AIC-PH/PID1/SP.CV | double | 5 | 否 | 是 |
| doValue | doValue | V7-AIC-DO/PID1/PV.CV | double | 5 | 否 | 是 |
| doValueset | doValueset | V7-AIC-DO/PID1/SP.CV | double | 5 | 否 | 是 |
| temperature | temperature | V7-TIC-VSL/PID1/PV.CV | double | 5 | 否 | 是 |
| temperatureset | temperatureset | V7-TIC-VSL/PID1/SP.CV | double | 5 | 否 | 是 |
| pressure | pressure | V7-PI-VSL/PV.CV | double | 5 | 否 | 是 |
| mfc1 | mfc1 | V7-FIC-1/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc2 | mfc2 | V7-FIC-2/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc3 | mfc3 | V7-FIC-3/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc4 | mfc4 | V7-FIC-4/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc5 | mfc5 | V7-FIC-5/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc6 | mfc6 | V7-FIC-6/PID1/PV.CV | double | 5 | 否 | 是 |
| pump1 | pump1 | V7-SIC-1/PID1/PV.CV | double | 5 | 是 | 是 |
| pump2 | pump2 | V7-SIC-2/PID1/PV.CV | double | 5 | 是 | 是 |
| pump3 | pump3 | V7-SIC-3/PID1/PV.CV | double | 5 | 是 | 是 |
| pump4 | pump4 | V7-SIC-4/PID1/PV.CV | double | 5 | 是 | 是 |
| pump5 | pump5 | V7-SIC-5/PID1/PV.CV | double | 5 | 是 | 是 |
| pump6 | pump6 | V7-SIC-6/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1set | pump1set | V7-SIC-1/PID1/SP.CV | double | 5 | 是 | 是 |
| pump2set | pump2set | V7-SIC-2/PID1/SP.CV | double | 5 | 是 | 是 |
| pump3set | pump3set | V7-SIC-3/PID1/SP.CV | double | 5 | 是 | 是 |
| pump4set | pump4set | V7-SIC-4/PID1/SP.CV | double | 5 | 是 | 是 |
| pump5set | pump5set | V7-SIC-5/PID1/SP.CV | double | 5 | 是 | 是 |
| pump6set | pump6set | V7-SIC-6/PID1/SP.CV | double | 5 | 是 | 是 |
| agitation | agitation | V7-SIC-AGIT/PV.CV | double | 5 | 否 | 是 |
| workingWeight | workingWeight | V7-WIC-VSL/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1Unit | pump1Unit | V7-SIC-1/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump2Unit | pump2Unit | V7-SIC-2/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump3Unit | pump3Unit | V7-SIC-3/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump4Unit | pump4Unit | V7-SIC-4/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump5Unit | pump5Unit | V7-SIC-5/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump6Unit | pump6Unit | V7-SIC-6/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |

### WGQS-NPP-SUB-V10（wgqs-npp-sub-v10，shortNo=V10）

| tagCode | displayName | OPC DA Item / Address | dataType | scanIntervalSeconds | isHighRate | enabled |
|---|---|---|---|---:|---|---|
| ph | ph | V10-AIC-PH/PID1/PV.CV | double | 5 | 否 | 是 |
| phset | phset | V10-AIC-PH/PID1/SP.CV | double | 5 | 否 | 是 |
| doValue | doValue | V10-AIC-DO/PID1/PV.CV | double | 5 | 否 | 是 |
| doValueset | doValueset | V10-AIC-DO/PID1/SP.CV | double | 5 | 否 | 是 |
| temperature | temperature | V10-TIC-VSL/PID1/PV.CV | double | 5 | 否 | 是 |
| temperatureset | temperatureset | V10-TIC-VSL/PID1/SP.CV | double | 5 | 否 | 是 |
| pressure | pressure | V10-PI-VSL/PV.CV | double | 5 | 否 | 是 |
| mfc1 | mfc1 | V10-FIC-1/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc2 | mfc2 | V10-FIC-2/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc3 | mfc3 | V10-FIC-3/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc4 | mfc4 | V10-FIC-4/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc5 | mfc5 | V10-FIC-5/PID1/PV.CV | double | 5 | 否 | 是 |
| mfc6 | mfc6 | V10-FIC-6/PID1/PV.CV | double | 5 | 否 | 是 |
| pump1 | pump1 | V10-SIC-1/PID1/PV.CV | double | 5 | 是 | 是 |
| pump2 | pump2 | V10-SIC-2/PID1/PV.CV | double | 5 | 是 | 是 |
| pump3 | pump3 | V10-SIC-3/PID1/PV.CV | double | 5 | 是 | 是 |
| pump4 | pump4 | V10-SIC-4/PID1/PV.CV | double | 5 | 是 | 是 |
| pump5 | pump5 | V10-SIC-5/PID1/PV.CV | double | 5 | 是 | 是 |
| pump6 | pump6 | V10-SIC-6/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1set | pump1set | V10-SIC-1/PID1/SP.CV | double | 5 | 是 | 是 |
| pump2set | pump2set | V10-SIC-2/PID1/SP.CV | double | 5 | 是 | 是 |
| pump3set | pump3set | V10-SIC-3/PID1/SP.CV | double | 5 | 是 | 是 |
| pump4set | pump4set | V10-SIC-4/PID1/SP.CV | double | 5 | 是 | 是 |
| pump5set | pump5set | V10-SIC-5/PID1/SP.CV | double | 5 | 是 | 是 |
| pump6set | pump6set | V10-SIC-6/PID1/SP.CV | double | 5 | 是 | 是 |
| agitation | agitation | V10-SIC-AGIT/PV.CV | double | 5 | 否 | 是 |
| workingWeight | workingWeight | V10-WIC-VSL/PID1/PV.CV | double | 5 | 是 | 是 |
| pump1Unit | pump1Unit | V10-SIC-1/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump2Unit | pump2Unit | V10-SIC-2/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump3Unit | pump3Unit | V10-SIC-3/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump4Unit | pump4Unit | V10-SIC-4/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump5Unit | pump5Unit | V10-SIC-5/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |
| pump6Unit | pump6Unit | V10-SIC-6/FS_CTRL1/SPEED_FLOW.CV | double | 5 | 否 | 是 |

## 4. 开发与部署经验

SUB 是最大配置，共 10 台、330 个 Item；应采用批量 AddItems、异步订阅或有界并发，不能为每个点建立独立连接。
PID1/PV.CV、PID1/SP.CV、FS_CTRL1/SPEED_FLOW.CV 代表不同语义；存在 SP 不表示边缘服务具有写权限。
13 个点标记为高频，但全部仍为 5 秒采集；应把采样周期、上传批次、实时缓存和告警优先级拆开设计。
设备配置顺序不是 V1～V10 顺序，必须按显式 deviceId/shortNo 处理，不能依赖数组下标。
在实际服务账号下验证 DeltaV ProgID、远程 DCOM、RPC/防火墙、位数兼容、重连和服务重启恢复。
平台请求超时 15 秒不能阻塞 OPC 采集；330 点必须有界缓存、背压、磁盘落盘和幂等补发。

### 投运核对

1. 按本表对 V1～V10 逐台浏览 33 个 Item，共 330 个。
2. 验证 PV/SP、泵速、单位/流量、压力、搅拌和重量语义。
3. 演练 OPC 断线、单点坏质量、平台断线、服务重启和配置版本切换。
4. 控制类写入另行完成权限、联锁、回读、审计和紧急停机验收。
