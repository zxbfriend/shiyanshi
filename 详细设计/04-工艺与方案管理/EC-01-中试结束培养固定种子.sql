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
