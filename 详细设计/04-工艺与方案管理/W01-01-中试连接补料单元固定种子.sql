-- 仅供新系统开发基线02合并，禁止与02重复执行；不含实验室绑定、设备参数或业务数据。
-- 不升级已有运行库，不把既有未知步骤码自动转换为本定义。
INSERT INTO workflow_subflow(subflow_id,node_id,subflow_code,subflow_name,lab_type,repeatable,sort_order,del_flag,create_by,create_time,remark)
VALUES (40041,5,'connect_feed_unit_pilot','中试连接补料单元','3',0,1,'0','INSTALL',UTC_TIMESTAMP(),'W01：固定三步；真实实验室须显式绑定补液目录');
INSERT INTO workflow_step(step_id,node_id,subflow_id,step_code,step_order,step_name,step_description,image_path,del_flag,create_by,create_time,remark)
VALUES
(40051,5,40041,'START',1,'开始','单台反应器；重新校验开始培养完成、操作权限、有效占用及完整生效补液方案',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W01'),
(40052,5,40041,'MODE_CONFIRM',2,'模式确认','只读回读泵模式及所需服务状态；全部真实就绪后才可进入下一步',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W01'),
(40053,5,40041,'PRIME_FILL',3,'手工接管与管路预填充','按核准能力确认接管及可选预填充；未停泵或UNKNOWN动作未安全收口不得跳过或完成',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W01');
