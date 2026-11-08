-- 仅供新系统开发基线02合并，禁止与02重复执行；不含实验室绑定、设备参数或业务数据。
-- 不升级已有运行库，不把既有未知步骤码自动转换为本定义。
INSERT INTO workflow_subflow(subflow_id,node_id,subflow_code,subflow_name,lab_type,repeatable,sort_order,del_flag,create_by,create_time,remark)
VALUES (40061,5,'replace_feed_liquid_pilot','中试更换料液','3',1,2,'0','INSTALL',UTC_TIMESTAMP(),'W02：可重复固定三步；真实实验室须显式绑定补液目录');
INSERT INTO workflow_step(step_id,node_id,subflow_id,step_code,step_order,step_name,step_description,image_path,del_flag,create_by,create_time,remark)
VALUES
(40071,5,40061,'START',1,'开始','选择同一反应器已连接培养的一个或多个泵，可选择该反应器全部泵；全量校验培养操作资格、有效占用与生效补液方案',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W02'),
(40072,5,40061,'REPLACE_BAG',2,'更换料液','核对本页所有泵的旧袋、新袋型号、皮重及补充净重；下一步仅暂存，最终完成才保存，取消放弃本次更换',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W02'),
(40073,5,40061,'PRIME_FILL',3,'管路预填充','预填充量与装袋量独立；可确认跳过，未停泵或未决动作不得完成，结束本次更换实例不重写连接完成事实',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W02');
