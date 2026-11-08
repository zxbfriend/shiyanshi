-- 仅供新系统开发基线02合并，禁止与02重复执行；不含实验室绑定/业务数据。
INSERT INTO workflow_subflow(subflow_id,node_id,subflow_code,subflow_name,lab_type,repeatable,sort_order,del_flag,create_by,create_time,remark)
VALUES (16,5,'manual_feed_small','补料（手工）','1',1,8,'0','INSTALL',UTC_TIMESTAMP(),'W05：只登记已完成的人工补料事实，不驱动设备');
INSERT INTO workflow_step(step_id,node_id,subflow_id,step_code,step_order,step_name,step_description,image_path,del_flag,create_by,create_time,remark)
VALUES
(31,5,16,'step_1',1,'开始','选择有效培养和固定补料通道',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W05'),
(32,5,16,'step_2',2,'手工补料','逐通道填写已完成的正整数克补入量并确认入账',NULL,'0','INSTALL',UTC_TIMESTAMP(),'W05');
