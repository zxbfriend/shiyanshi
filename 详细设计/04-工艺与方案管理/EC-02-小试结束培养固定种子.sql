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
