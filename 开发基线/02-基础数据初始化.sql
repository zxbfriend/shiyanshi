-- Fresh baseline only; stop on first error. No historical users, passwords, equipment or business data.
SET NAMES utf8mb4;
SET time_zone = '+00:00';
START TRANSACTION;
INSERT INTO apr_scene (scene_code,source_kind,module_level1,module_level2,operation_code,owner_module,scope_state,source_reference,source_hash,schema_version,sort_order,scope_reason) VALUES
('M06_SC001','TASK','任务审批','补料任务','MODIFY','M07','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r3',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,1,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC002','TASK','任务审批','补料任务','MANUAL_CREATE','M07','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r4',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,2,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC003','TASK','任务审批','补料任务','SYSTEM_CREATE','M07','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r5',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,3,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC004','TASK','任务审批','补糖任务','SYSTEM_CREATE','M07','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r6',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,4,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC005','TASK','任务审批','补糖任务','MODIFY','M07','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r7',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,5,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC006','TASK','任务审批','补糖任务','MANUAL_CREATE','M07','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r8',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,6,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC007','TASK','任务审批','补料任务','CANCEL','M07','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r9',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,7,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC008','TASK','任务审批','补糖任务','CANCEL','M07','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r10',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,8,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC049','TASK','任务审批','补液任务跨天间隔时间过短','ALARM_BLOCK','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r11',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,9,'执行前发现前8/12小时内已执行过同类型补液任务'),
('M06_SC050','TASK','任务审批','一天多次重复补液告警','ALARM_BLOCK','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r12',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,10,'执行前发现同一天已执行过同类型补液任务'),
('M06_SC009','TASK','任务审批','执行出错修复','CREATE','M07','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r13',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,11,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC010','TASK','任务审批','PH校准','CREATE','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r14',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,12,'现行范围已纳入；仅配置档位，不据目录恢复业务入口或跳过拥有方校验'),
('M06_SC011','TASK','任务审批','PH校准','MODIFY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r15',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,13,'现行范围已纳入；仅配置档位，不据目录恢复业务入口或跳过拥有方校验'),
('M06_SC012','TASK','任务审批','PH校准','CANCEL','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r16',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,14,'现行范围已纳入；仅配置档位，不据目录恢复业务入口或跳过拥有方校验'),
('M06_SC013','TASK','任务审批','取样检测','CREATE','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r17',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,15,'现行范围已纳入；仅配置档位，不据目录恢复业务入口或跳过拥有方校验'),
('M06_SC014','TASK','任务审批','取样检测','MODIFY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r18',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,16,'现行范围已纳入；仅配置档位，不据目录恢复业务入口或跳过拥有方校验'),
('M06_SC015','TASK','任务审批','取样检测','CANCEL','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r19',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,17,'现行范围已纳入；仅配置档位，不据目录恢复业务入口或跳过拥有方校验'),
('M06_SC051','TASK','任务审批','取样检测','CANCEL_COPY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r20',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,18,'仅登记审批配置场景；业务来源、候选及生效由拥有模块校验'),
('M06_SC016','PLAN_INITIALIZATION','工艺方案初始化','培养执行的工作流','INIT','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r21',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,19,'初始化候选契约保留；不恢复Q33排除编辑页，来源入口及固定包具备后方可申请'),
('M06_SC017','PLAN_INITIALIZATION','工艺方案初始化','config关联设置方案','INIT','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r22',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,20,'初始化候选契约保留；不恢复Q33排除编辑页，来源入口及固定包具备后方可申请'),
('M06_SC018','PLAN_INITIALIZATION','工艺方案初始化','灌注培养基方案','INIT','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r23',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,21,'初始化候选契约保留；不恢复Q33排除编辑页，来源入口及固定包具备后方可申请'),
('M06_SC019','PLAN_INITIALIZATION','工艺方案初始化','补液方案','INIT','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r24',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,22,'2026-10-24仅开放补液方案初始化入口；独立核准INIT政策，其他配置入口保持原范围'),
('M06_SC020','PLAN_INITIALIZATION','工艺方案初始化','自动控制方案','INIT','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r25',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,23,'初始化候选契约保留；不恢复Q33排除编辑页，来源入口及固定包具备后方可申请'),
('M06_SC021','PLAN_INITIALIZATION','工艺方案初始化','取样方案','INIT','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r26',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,24,'初始化候选契约保留；不恢复Q33排除编辑页，来源入口及固定包具备后方可申请'),
('M06_SC022','PLAN_INITIALIZATION','工艺方案初始化','测样方案','INIT','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r27',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,25,'初始化候选契约保留；不恢复Q33排除编辑页，来源入口及固定包具备后方可申请'),
('M06_SC023','PLAN_INITIALIZATION','工艺方案初始化','澄清方案','INIT','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r28',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,26,'初始化候选契约保留；不恢复Q33排除编辑页，来源入口及固定包具备后方可申请'),
('M06_SC024','PLAN_INITIALIZATION','工艺方案初始化','结束策略','INIT','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r29',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,27,'初始化候选契约保留；不恢复Q33排除编辑页，来源入口及固定包具备后方可申请'),
('M06_SC025','CULTURE_OPERATION','设备信息','更换设备','MODIFY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r30',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,28,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC026','CULTURE_OPERATION','设备信息','默认连接','MODIFY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r31',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,29,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC027','CULTURE_OPERATION','培养基本信息','培养ID','MODIFY','M03','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r32',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,30,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC028','CULTURE_OPERATION','培养基本信息','培养时间（开始时间/结束时间/培养天数）','MODIFY','M03','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r33',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,31,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC029','CULTURE_OPERATION','培养基本信息','培养模式','MODIFY','M03','SUPPORTED','审批场景统计.xlsx/Sheet1 (2)/r34',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,32,'通过已开放来源操作触发；仍须资源与候选校验'),
('M06_SC030','CULTURE_OPERATION','重量信息','初始体积','MODIFY','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r35',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,33,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效；沿Q7当前初始培养重量口径，旧体积标签不推导g/mL换算'),
('M06_SC031','CULTURE_OPERATION','重量信息','接种体积','MODIFY','M03','EXCLUDED','审批场景统计.xlsx/Sheet1 (2)/r36',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,34,'Q34：接种体积旧入口本阶段排除，不与初始培养重量并建字段'),
('M06_SC032','CULTURE_OPERATION','重量信息','取测减少总体积','MODIFY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r37',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,35,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC033','CULTURE_OPERATION','残糖确认','补液计算规则','MODIFY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r38',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,36,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC034','CULTURE_OPERATION','残糖确认','残糖确认','MODIFY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r39',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,37,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC035','CULTURE_OPERATION','工艺设置','培养执行的工作流','MODIFY','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r40',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,38,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC036','CULTURE_OPERATION','工艺设置','config关联设置方案','MODIFY','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r41',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,39,'现行范围已纳入；仅配置档位，不据目录恢复业务入口或跳过拥有方校验'),
('M06_SC037','CULTURE_OPERATION','工艺设置','灌注培养基方案','MODIFY','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r42',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,40,'现行范围已纳入；仅配置档位，不据目录恢复业务入口或跳过拥有方校验'),
('M06_SC038','CULTURE_OPERATION','工艺设置','补料任务','MODIFY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r43',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,41,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC039','CULTURE_OPERATION','工艺设置','补糖规则','MODIFY','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r44',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,42,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC040','CULTURE_OPERATION','工艺设置','自动控制方案','MODIFY','M03','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r45',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,43,'现行范围已纳入；仅配置档位，不据目录恢复业务入口或跳过拥有方校验'),
('M06_SC041','CULTURE_OPERATION','工艺设置','取样方案','MODIFY','M03','EXCLUDED','审批场景统计.xlsx/Sheet1 (2)/r46',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,44,'Q33：培养方案修改七配置页本阶段排除'),
('M06_SC042','CULTURE_OPERATION','工艺设置','测样方案','MODIFY','M03','EXCLUDED','审批场景统计.xlsx/Sheet1 (2)/r47',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,45,'Q33：培养方案修改七配置页本阶段排除'),
('M06_SC043','CULTURE_OPERATION','工艺设置','澄清方案','MODIFY','M03','EXCLUDED','审批场景统计.xlsx/Sheet1 (2)/r48',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,46,'Q33：培养方案修改七配置页本阶段排除'),
('M06_SC044','CULTURE_OPERATION','工艺设置','结束策略','MODIFY','M03','EXCLUDED','审批场景统计.xlsx/Sheet1 (2)/r49',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,47,'Q33：培养方案修改七配置页本阶段排除'),
('M06_SC045','CULTURE_OPERATION','在线数据','在线告警设置','MODIFY','M09','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r50',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,48,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC046','CULTURE_OPERATION','离线数据','离线告警设置','MODIFY','M09','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r51',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,49,'来源模块负责字段/方案/安全条件；M06不自建修改页面或默认可生效'),
('M06_SC047','CULTURE_OPERATION','结束培养','取消培养','CANCEL','M07','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r52',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,50,'Q36：不实现真实结束培养工作流；只消费拥有方本期合法候选/模拟事实，不新增停机入口'),
('M06_SC052','DATA_MANAGEMENT','样本作废','样本作废','VOID','M05','OWNER_GATED','审批场景统计.xlsx/Sheet1 (2)/r53',UNHEX('90b1951c1df89b9a3eb922a1aa9b1622a833ec21d7ab88ff1d944d3d237ce533'),2,51,'仅登记审批配置场景；业务来源、候选及生效由拥有模块校验'),
('M06_SC048','CULTURE_OPERATION','工艺设置','补液方案','MODIFY','M03','OWNER_GATED','用户确认/2026-10-24/补液方案入口',UNHEX('38b7f45162b2a67f64aeb6c1fcb8dc530c6dc269da1b3a91ba572da5a1b2272d'),1,52,'仅开放补液方案替换；独立核准MODIFY政策，不复用INIT或补料任务政策；原任务安全屏障仍适用');
INSERT INTO sys_management_revision(scope_key,revision) VALUES ('SYSTEM',0);
INSERT INTO sys_config(config_id,config_name,config_key,config_value,config_type,create_by,create_time) VALUES
(1,'密码有效期','sys.account.passwordValidateDays','90','Y','INSTALL',UTC_TIMESTAMP()),
(2,'密码到期提醒','sys.account.passwordRemindDays','5','Y','INSTALL',UTC_TIMESTAMP()),
(3,'密码策略版本','sys.account.passwordPolicyVersion','1','Y','INSTALL',UTC_TIMESTAMP()),
(4,'初始密码','sys.account.initPassword','123456','Y','INSTALL',UTC_TIMESTAMP()),
(5,'初始密码强制修改','sys.account.initPasswordModify','1','Y','INSTALL',UTC_TIMESTAMP()),
(6,'用户登录-是否开启验证码功能','sys.account.captchaEnabled','true','Y','INSTALL',UTC_TIMESTAMP()),
(7,'登录失败锁定阈值','sys.account.loginLockThreshold','6','Y','INSTALL',UTC_TIMESTAMP());
-- 2026-10-10 用户确认：灌注培养基类型从“初始培养基”字典选择；暂不预置业务选项。
INSERT INTO sys_dict_type(dict_id,dict_name,dict_type,status,create_by,create_time,remark,del_flag,is_editable)
VALUES (40001,'初始培养基','smp_initial_medium','0','INSTALL',UTC_TIMESTAMP(),'灌注培养基方案必选类型；字典项由管理员维护','0','N');
-- M04/M07 固定目录：W06 只定义全局流程，真实实验室须由管理员建立 lab_workflow_node 绑定后才可运行。
INSERT INTO workflow_node(node_id,node_name,node_code,icon_path,lab_type,status,description,sort_order,del_flag,create_by,create_time,remark)
VALUES (5,'补液','feeding','icons/image/bag.png','1','0','小试补液工作流目录',5,'0','INSTALL',UTC_TIMESTAMP(),'固定工作流目录');
INSERT INTO workflow_subflow(subflow_id,node_id,subflow_code,subflow_name,lab_type,repeatable,sort_order,del_flag,create_by,create_time,remark)
VALUES (14,5,'liquid_supply_sampling_unit_small','液体补充（取样单元）','1',0,6,'0','INSTALL',UTC_TIMESTAMP(),'W06：实验室级取样单元液体补充');
INSERT INTO workflow_step(step_id,node_id,subflow_id,step_code,step_order,step_name,step_description,image_path,del_flag,create_by,create_time,remark)
VALUES
(27,5,14,'step_1',1,'开始','1.1 选择取样单元；1.2 选择更换的 Water 或 Alcohol 液瓶',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W06'),
(28,5,14,'step_2',2,'更换液瓶','2.1 卸下原液桶；2.2 连接新鲜液桶并现场确认',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W06');
-- W07 依赖既有 W03 连接事实；每次换瓶均可重复执行。
INSERT INTO workflow_subflow(subflow_id,node_id,subflow_code,subflow_name,lab_type,repeatable,sort_order,del_flag,create_by,create_time,remark)
VALUES (13,5,'liquid_supply_feed_unit_small','液体补充（补料单元）','1',0,5,'0','INSTALL',UTC_TIMESTAMP(),'W07：小试补料单元液体补充');
INSERT INTO workflow_step(step_id,node_id,subflow_id,step_code,step_order,step_name,step_description,image_path,del_flag,create_by,create_time,remark)
VALUES
(24,5,13,'step_1',1,'开始','选择已连接的补料泵位',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W07'),
(25,5,13,'step_2',2,'更换液瓶','填写新瓶实际装载量并现场确认',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W07'),
(26,5,13,'step_3',3,'补料管路预填充','按 W03 预填充规则提交启停命令',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W07');
-- W08 依赖已完成 W03 连接；Waste 清理仅记录换空瓶并将新当前量确认成 0。
INSERT INTO workflow_subflow(subflow_id,node_id,subflow_code,subflow_name,lab_type,repeatable,sort_order,del_flag,create_by,create_time,remark)
VALUES (15,5,'waste_clear_small','废液清理','1',0,7,'0','INSTALL',UTC_TIMESTAMP(),'W08：小试取样单元Waste废液清理');
INSERT INTO workflow_step(step_id,node_id,subflow_id,step_code,step_order,step_name,step_description,image_path,del_flag,create_by,create_time,remark)
VALUES
(29,5,15,'step_1',1,'开始','选择已连接培养的Waste槽位',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W08'),
(30,5,15,'step_2',2,'更换液瓶','确认废液瓶已清理并固定新当前量为0',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W08');
-- Source fragment for fresh 开发基线/02 only, never run alongside that installer.
-- Raw smp_lab_type: 1 small upstream, 3 pilot upstream. No lab bindings or business data.
INSERT INTO workflow_node(node_id,node_name,node_code,icon_path,lab_type,status,description,sort_order,del_flag,create_by,create_time,remark)
VALUES
(40010,'开始培养','start_culture','icons/image/bag.png','1','0','小试及中试开始培养；适用类型由二级流程决定',10,'0','INSTALL',UTC_TIMESTAMP(),'SC-20261017：真实实验室须显式绑定；节点类型仅目录分类');
INSERT INTO workflow_subflow(subflow_id,node_id,subflow_code,subflow_name,lab_type,repeatable,sort_order,del_flag,create_by,create_time,remark)
VALUES
(40011,40010,'start_culture_small','小试开始培养','1',0,1,'0','INSTALL',UTC_TIMESTAMP(),'START_CULTURE_SMALL'),
(40012,40010,'start_culture_pilot','中试开始培养','3',0,2,'0','INSTALL',UTC_TIMESTAMP(),'START_CULTURE_PILOT');
INSERT INTO workflow_step(step_id,node_id,subflow_id,step_code,step_order,step_name,step_description,image_path,del_flag,create_by,create_time,remark)
VALUES
(40021,40010,40011,'START',1,'开始','冻结选择与当天期限',NULL,'0','INSTALL',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40022,40010,40011,'INOCULATION',2,'接种信息','仅页面输入；最终完成事务保存',NULL,'0','INSTALL',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40023,40010,40011,'SAMPLE_PRIME',3,'取样管路填充','物理能力未核准时阻断，允许显式跳过',NULL,'0','INSTALL',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40024,40010,40011,'DEVICE_CONFIRM',4,'设备确认','全部可信确认后完成',NULL,'0','INSTALL',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40031,40010,40012,'START',1,'开始','中试仅单台并冻结当天期限',NULL,'0','INSTALL',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40032,40010,40012,'INOCULATION',2,'接种信息','仅页面输入；最终完成事务保存',NULL,'0','INSTALL',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40033,40010,40012,'ONLINE_ALARM_CONFIRM',3,'在线告警确认','M09纯校验；此步骤不保存配置',NULL,'0','INSTALL',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40034,40010,40012,'OPC_CONFIRM',4,'OPC确认','真实可信观测后完成；重启未核准时阻断',NULL,'0','INSTALL',UTC_TIMESTAMP(),'SC schemaVersion=2');


-- Source: docs/详细设计/04-工艺与方案管理/W05-01-手工补料固定种子.sql
-- 仅供新系统开发基线02合并，禁止与02重复执行；不含实验室绑定/业务数据。
INSERT INTO workflow_subflow(subflow_id,node_id,subflow_code,subflow_name,lab_type,repeatable,sort_order,del_flag,create_by,create_time,remark)
VALUES (16,5,'manual_feed_small','补料（手工）','1',1,8,'0','INSTALL',UTC_TIMESTAMP(),'W05：只登记已完成的人工补料事实，不驱动设备');
INSERT INTO workflow_step(step_id,node_id,subflow_id,step_code,step_order,step_name,step_description,image_path,del_flag,create_by,create_time,remark)
VALUES
(31,5,16,'step_1',1,'开始','选择有效培养和固定补料通道',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W05'),
(32,5,16,'step_2',2,'手工补料','逐通道填写已完成的正整数克补入量并确认入账',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W05');

-- Source: docs/详细设计/04-工艺与方案管理/W01-01-中试连接补料单元固定种子.sql
-- 仅供新系统开发基线02合并，禁止与02重复执行；不含实验室绑定、设备参数或业务数据。
-- 不升级已有运行库，不把既有未知步骤码自动转换为本定义。
INSERT INTO workflow_subflow(subflow_id,node_id,subflow_code,subflow_name,lab_type,repeatable,sort_order,del_flag,create_by,create_time,remark)
VALUES (40041,5,'connect_feed_unit_pilot','中试连接补料单元','3',0,1,'0','INSTALL',UTC_TIMESTAMP(),'W01：固定三步；真实实验室须显式绑定补液目录');
INSERT INTO workflow_step(step_id,node_id,subflow_id,step_code,step_order,step_name,step_description,image_path,del_flag,create_by,create_time,remark)
VALUES
(40051,5,40041,'START',1,'开始','单台反应器；重新校验开始培养完成、操作权限、有效占用及完整生效补液方案',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W01'),
(40052,5,40041,'MODE_CONFIRM',2,'模式确认','只读回读泵模式及所需服务状态；全部真实就绪后才可进入下一步',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W01'),
(40053,5,40041,'PRIME_FILL',3,'手工接管与管路预填充','按核准能力确认接管及可选预填充；未停泵或UNKNOWN动作未安全收口不得跳过或完成',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W01');

-- Source: docs/详细设计/04-工艺与方案管理/W02-01-中试更换料液固定种子.sql
-- 仅供新系统开发基线02合并，禁止与02重复执行；不含实验室绑定、设备参数或业务数据。
-- 不升级已有运行库，不把既有未知步骤码自动转换为本定义。
INSERT INTO workflow_subflow(subflow_id,node_id,subflow_code,subflow_name,lab_type,repeatable,sort_order,del_flag,create_by,create_time,remark)
VALUES (40061,5,'replace_feed_liquid_pilot','中试更换料液','3',1,2,'0','INSTALL',UTC_TIMESTAMP(),'W02：可重复固定三步；真实实验室须显式绑定补液目录');
INSERT INTO workflow_step(step_id,node_id,subflow_id,step_code,step_order,step_name,step_description,image_path,del_flag,create_by,create_time,remark)
VALUES
(40071,5,40061,'START',1,'开始','选择同一反应器已连接培养的一个或多个泵，可选择该反应器全部泵；全量校验培养操作资格、有效占用与生效补液方案',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W02'),
(40072,5,40061,'REPLACE_BAG',2,'更换料液','核对本页所有泵的旧袋、新袋型号、皮重及补充净重；下一步仅暂存，最终完成才保存，取消放弃本次更换',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W02'),
(40073,5,40061,'PRIME_FILL',3,'管路预填充','预填充量与装袋量独立；可确认跳过，未停泵或未决动作不得完成，结束本次更换实例不重写连接完成事实',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W02');

-- Source: docs/详细设计/04-工艺与方案管理/EC-01-中试结束培养固定种子.sql
-- 仅供新系统空库开发基线02合并；不得在已有数据库重跑初始化脚本。
-- 正常与异常共用结束培养目录，分别保存三步与两步定义；不预置实验室绑定。
INSERT INTO workflow_node(node_id,node_name,node_code,icon_path,lab_type,status,description,sort_order,del_flag,create_by,create_time,remark)
VALUES (40080,'结束培养','end_culture','','3','0','小试及中试结束培养工作流目录；适用类型由二级流程决定',11,'0','INSTALL',UTC_TIMESTAMP(),'EC-01：真实实验室须显式绑定');
INSERT INTO workflow_subflow(subflow_id,node_id,subflow_code,subflow_name,lab_type,repeatable,sort_order,del_flag,create_by,create_time,remark)
VALUES
(40081,40080,'end_culture_pilot_normal','中试正常结束培养','3',0,1,'0','INSTALL',UTC_TIMESTAMP(),'EC-01：计划结束日为服务器业务日'),
(40082,40080,'end_culture_pilot_abnormal','中试异常结束培养','3',0,2,'0','INSTALL',UTC_TIMESTAMP(),'EC-01：计划结束日不是服务器业务日');
INSERT INTO workflow_step(step_id,node_id,subflow_id,step_code,step_order,step_name,step_description,image_path,del_flag,create_by,create_time,remark)
VALUES
(40083,40080,40081,'START',1,'开始','选择一台有权操作且满足前置条件的中试反应器',NULL,'0','INSTALL',UTC_TIMESTAMP(),'EC-01'),
(40084,40080,40081,'MODE_CONFIRM',2,'模式确认','读取全部相关泵的真实模式，确认均为手动后进入下一步',NULL,'0','INSTALL',UTC_TIMESTAMP(),'EC-01'),
(40085,40080,40081,'COMPLETE_CULTURE',3,'完成培养','复核安全状态并二次确认后记录实际结束时间',NULL,'0','INSTALL',UTC_TIMESTAMP(),'EC-01'),
(40086,40080,40082,'START',1,'开始','选择一台有权操作且满足前置条件的中试反应器',NULL,'0','INSTALL',UTC_TIMESTAMP(),'EC-01'),
(40087,40080,40082,'COMPLETE_CULTURE',2,'完成培养','填写异常结束原因；按实验室审批政策及现场安全状态完成',NULL,'0','INSTALL',UTC_TIMESTAMP(),'EC-01');

-- Source: docs/详细设计/04-工艺与方案管理/EC-02-小试结束培养固定种子.sql
-- 仅供新系统空库开发基线02合并；已有运行库不得重跑初始化脚本。
-- 小试二期正常三步、异常两步；只预置固定定义，不预置实验室绑定。
-- 复用 EC-01 的 end_culture 一级节点 40080；按二级流程实验室类型区分。
INSERT INTO workflow_subflow(subflow_id,node_id,subflow_code,subflow_name,lab_type,repeatable,sort_order,del_flag,create_by,create_time,remark)
VALUES
(40091,40080,'end_cell_culture_small_normal','小试正常结束细胞培养','1',0,3,'0','INSTALL',UTC_TIMESTAMP(),'EC-02：计划结束日为服务器业务日'),
(40092,40080,'end_cell_culture_small_abnormal','小试异常结束细胞培养','1',0,4,'0','INSTALL',UTC_TIMESTAMP(),'EC-02：计划结束日不是服务器业务日');
INSERT INTO workflow_step(step_id,node_id,subflow_id,step_code,step_order,step_name,step_description,image_path,del_flag,create_by,create_time,remark)
VALUES
(40093,40080,40091,'START',1,'开始','选择有权操作、已开始培养且无进行中流程的小试控制器；正常结束可同日多选',NULL,'0','INSTALL',UTC_TIMESTAMP(),'EC-02'),
(40094,40080,40091,'COMPLETE_CULTURE',2,'完成培养','确认本次正常结束的控制器；最终关闭设备或确认跳过后统一更新培养状态',NULL,'0','INSTALL',UTC_TIMESTAMP(),'EC-02'),
(40095,40080,40091,'SHUTDOWN_DEVICE',3,'关闭设备','二次确认归零后结束培养；跳过则培养已结束、控制器占用待释放，确认停稳后释放',NULL,'0','INSTALL',UTC_TIMESTAMP(),'EC-02'),
(40096,40080,40092,'START',1,'开始','异常结束仅选择一台有权操作的小试控制器',NULL,'0','INSTALL',UTC_TIMESTAMP(),'EC-02'),
(40097,40080,40092,'COMPLETE_CULTURE',2,'完成培养','填写异常原因，免审批或审批通过后取消培养、占用待释放，人员确认停稳后释放',NULL,'0','INSTALL',UTC_TIMESTAMP(),'EC-02');

COMMIT;
