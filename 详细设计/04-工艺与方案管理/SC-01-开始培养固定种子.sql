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
