INSERT INTO workflow_subflow(subflow_id,node_id,subflow_code,subflow_name,lab_type,repeatable,sort_order,del_flag,create_by,create_time,remark)
VALUES
(40011,3,'start_culture_small','小试开始培养','1',0,3,'0','SC_TEST_20261017',UTC_TIMESTAMP(),'START_CULTURE_SMALL'),
(40012,3,'start_culture_pilot','中试开始培养','3',0,4,'0','SC_TEST_20261017',UTC_TIMESTAMP(),'START_CULTURE_PILOT');
INSERT INTO workflow_step(step_id,node_id,subflow_id,step_code,step_order,step_name,step_description,image_path,del_flag,create_by,create_time,remark)
VALUES
(40021,3,40011,'START',1,'开始','冻结选择与当天期限',NULL,'0','SC_TEST_20261017',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40022,3,40011,'INOCULATION',2,'接种信息','仅页面输入；最终完成事务保存',NULL,'0','SC_TEST_20261017',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40023,3,40011,'SAMPLE_PRIME',3,'取样管路填充','物理能力未核准时阻断，允许显式跳过',NULL,'0','SC_TEST_20261017',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40024,3,40011,'DEVICE_CONFIRM',4,'设备确认','全部可信确认后完成',NULL,'0','SC_TEST_20261017',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40031,3,40012,'START',1,'开始','中试仅单台并冻结当天期限',NULL,'0','SC_TEST_20261017',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40032,3,40012,'INOCULATION',2,'接种信息','仅页面输入；最终完成事务保存',NULL,'0','SC_TEST_20261017',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40033,3,40012,'ONLINE_ALARM_CONFIRM',3,'在线告警确认','M09纯校验；此步骤不保存配置',NULL,'0','SC_TEST_20261017',UTC_TIMESTAMP(),'SC schemaVersion=2'),
(40034,3,40012,'OPC_CONFIRM',4,'OPC确认','真实可信观测后完成；重启未核准时阻断',NULL,'0','SC_TEST_20261017',UTC_TIMESTAMP(),'SC schemaVersion=2');


INSERT INTO res_project (project_id,project_code,project_name,creator_user_id,facts_status,create_by,create_time,remark) VALUES (861017001,'SC-20261017','开始培养页面测试-20261017',1,'READY','SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO res_project_lab (project_id,lab_id) VALUES (861017001,11001);

INSERT INTO res_batch (batch_id,project_id,lab_id,batch_code,batch_name,creator_user_id,facts_status,create_by,create_time,remark) VALUES (861017011,861017001,11001,'SC-20261017-SMALL','开始培养测试-SMALL',1,'READY','SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO res_project_lab (project_id,lab_id) VALUES (861017001,11002);

INSERT INTO res_batch (batch_id,project_id,lab_id,batch_code,batch_name,creator_user_id,facts_status,create_by,create_time,remark) VALUES (861017012,861017001,11002,'SC-20261017-PILOT','开始培养测试-PILOT',1,'READY','SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO dev_bench_reactor (model_id,brand,category,capacity,capacity_unit,create_by,create_time,remark) VALUES (861017021,'SC页面测试','15L',15,'L','SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO dev_bench_reactor (model_id,brand,category,capacity,capacity_unit,create_by,create_time,remark) VALUES (861017022,'SC页面测试','50L',50,'L','SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO dev_integrated_reactor (model_id,model_name,spec,capacity,create_by,create_time,remark) VALUES (861017023,'SC页面测试-20L','20 L',20000,'SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO lab_bench_reactor (reactor_id,lab_id,model_id,device_no,asset_no,reactor_name,vessel_no,controller_no,volume_ml,capacity_unit,create_by,create_time,remark) VALUES (861017101,11001,861017021,'SC-1017-S15','SC-1017-S15','开始培养测试-S15','SC-1017-S15','SC-CTRL-1',15000,'mL','SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO lab_bench_reactor_controller (connection_id,lab_id,reactor_id,controller_no,connection_name,create_by,create_time,remark) VALUES (861017601,11001,861017101,'SC-CTRL-1','开始培养测试-S15','SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO res_culture (culture_id,project_id,batch_id,lab_id,culture_code,culture_name,creator_user_id,facts_status,lifecycle_state,mode_code,device_kind,device_id,planned_start_date,planned_end_date,planned_duration_days,workflow_selection_json,plan_version,runtime_version,n_marked,member_setup_state,create_by,create_time,remark) VALUES (861017201,861017001,861017011,11001,'SC-1017-S15','开始培养测试-S15',1,'READY','NOT_STARTED','NORMAL','BENCH_CONTROLLER',861017101,'2026-10-17','2026-10-23',7,'["3"]',1,0,0,'NEVER','SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO res_culture_occupancy (occupancy_id,culture_id,device_kind,device_id,lab_id,occupancy_state,acquired_at,created_request_id,object_version) VALUES (861017301,861017201,'BENCH_CONTROLLER',861017101,11001,'RESERVED',UTC_TIMESTAMP(3),'SC-FIXTURE-20261017-1',1);

INSERT INTO lab_bench_reactor (reactor_id,lab_id,model_id,device_no,asset_no,reactor_name,vessel_no,controller_no,volume_ml,capacity_unit,create_by,create_time,remark) VALUES (861017102,11001,861017022,'SC-1017-S50','SC-1017-S50','开始培养测试-S50','SC-1017-S50','SC-CTRL-2',50000,'mL','SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO lab_bench_reactor_controller (connection_id,lab_id,reactor_id,controller_no,connection_name,create_by,create_time,remark) VALUES (861017602,11001,861017102,'SC-CTRL-2','开始培养测试-S50','SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO res_culture (culture_id,project_id,batch_id,lab_id,culture_code,culture_name,creator_user_id,facts_status,lifecycle_state,mode_code,device_kind,device_id,planned_start_date,planned_end_date,planned_duration_days,workflow_selection_json,plan_version,runtime_version,n_marked,member_setup_state,create_by,create_time,remark) VALUES (861017202,861017001,861017011,11001,'SC-1017-S50','开始培养测试-S50',1,'READY','NOT_STARTED','NORMAL','BENCH_CONTROLLER',861017102,'2026-10-17','2026-10-23',7,'["3"]',1,0,0,'NEVER','SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO res_culture_occupancy (occupancy_id,culture_id,device_kind,device_id,lab_id,occupancy_state,acquired_at,created_request_id,object_version) VALUES (861017302,861017202,'BENCH_CONTROLLER',861017102,11001,'RESERVED',UTC_TIMESTAMP(3),'SC-FIXTURE-20261017-2',1);

INSERT INTO lab_floor_scale (scale_id,lab_id,device_no,asset_no,spec,is_feed_scale,owner_user_id,create_by,create_time,remark) VALUES (861017403,11002,'SC-SCALE-861017403','SC-ASSET-861017403','20kg','0',1,'SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO lab_floor_scale (scale_id,lab_id,device_no,asset_no,spec,is_feed_scale,owner_user_id,create_by,create_time,remark) VALUES (861017503,11002,'SC-SCALE-861017503','SC-ASSET-861017503','20kg','1',1,'SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO lab_integrated_reactor (integrated_id,lab_id,model_id,device_no,asset_no,reactor_name,volume_ml,floor_scale_id,floor_scale_low_limit,floor_scale_high_limit,feed_scale_id,owner_user_id,create_by,create_time,remark) VALUES (861017103,11002,861017023,'SC-1017-P20','SC-1017-P20','开始培养测试-P20',20000,861017403,0,20000,861017503,1,'SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO res_culture (culture_id,project_id,batch_id,lab_id,culture_code,culture_name,creator_user_id,facts_status,lifecycle_state,mode_code,device_kind,device_id,planned_start_date,planned_end_date,planned_duration_days,workflow_selection_json,plan_version,runtime_version,n_marked,member_setup_state,create_by,create_time,remark) VALUES (861017203,861017001,861017012,11002,'SC-1017-P20','开始培养测试-P20',1,'READY','NOT_STARTED','REACTOR','INTEGRATED_REACTOR',861017103,'2026-10-17','2026-10-23',7,'["3"]',1,0,0,'NEVER','SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO res_culture_occupancy (occupancy_id,culture_id,device_kind,device_id,lab_id,occupancy_state,acquired_at,created_request_id,object_version) VALUES (861017303,861017203,'INTEGRATED_REACTOR',861017103,11002,'RESERVED',UTC_TIMESTAMP(3),'SC-FIXTURE-20261017-3',1);

INSERT INTO lab_bench_reactor (reactor_id,lab_id,model_id,device_no,asset_no,reactor_name,vessel_no,controller_no,volume_ml,capacity_unit,create_by,create_time,remark) VALUES (861017104,11001,861017021,'SC-1017-S15-SMOKE','SC-1017-S15-SMOKE','开始培养测试-S15-SMOKE','SC-1017-S15-SMOKE','SC-CTRL-4',15000,'mL','SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO lab_bench_reactor_controller (connection_id,lab_id,reactor_id,controller_no,connection_name,create_by,create_time,remark) VALUES (861017604,11001,861017104,'SC-CTRL-4','开始培养测试-S15-SMOKE','SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO res_culture (culture_id,project_id,batch_id,lab_id,culture_code,culture_name,creator_user_id,facts_status,lifecycle_state,mode_code,device_kind,device_id,planned_start_date,planned_end_date,planned_duration_days,workflow_selection_json,plan_version,runtime_version,n_marked,member_setup_state,create_by,create_time,remark) VALUES (861017204,861017001,861017011,11001,'SC-1017-S15-SMOKE','开始培养测试-S15-SMOKE',1,'READY','NOT_STARTED','NORMAL','BENCH_CONTROLLER',861017104,'2026-10-17','2026-10-23',7,'["3"]',1,0,0,'NEVER','SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO res_culture_occupancy (occupancy_id,culture_id,device_kind,device_id,lab_id,occupancy_state,acquired_at,created_request_id,object_version) VALUES (861017304,861017204,'BENCH_CONTROLLER',861017104,11001,'RESERVED',UTC_TIMESTAMP(3),'SC-FIXTURE-20261017-4',1);

INSERT INTO lab_bench_reactor (reactor_id,lab_id,model_id,device_no,asset_no,reactor_name,vessel_no,controller_no,volume_ml,capacity_unit,create_by,create_time,remark) VALUES (861017105,11001,861017022,'SC-1017-S50-SMOKE','SC-1017-S50-SMOKE','开始培养测试-S50-SMOKE','SC-1017-S50-SMOKE','SC-CTRL-5',50000,'mL','SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO lab_bench_reactor_controller (connection_id,lab_id,reactor_id,controller_no,connection_name,create_by,create_time,remark) VALUES (861017605,11001,861017105,'SC-CTRL-5','开始培养测试-S50-SMOKE','SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO res_culture (culture_id,project_id,batch_id,lab_id,culture_code,culture_name,creator_user_id,facts_status,lifecycle_state,mode_code,device_kind,device_id,planned_start_date,planned_end_date,planned_duration_days,workflow_selection_json,plan_version,runtime_version,n_marked,member_setup_state,create_by,create_time,remark) VALUES (861017205,861017001,861017011,11001,'SC-1017-S50-SMOKE','开始培养测试-S50-SMOKE',1,'READY','NOT_STARTED','NORMAL','BENCH_CONTROLLER',861017105,'2026-10-17','2026-10-23',7,'["3"]',1,0,0,'NEVER','SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO res_culture_occupancy (occupancy_id,culture_id,device_kind,device_id,lab_id,occupancy_state,acquired_at,created_request_id,object_version) VALUES (861017305,861017205,'BENCH_CONTROLLER',861017105,11001,'RESERVED',UTC_TIMESTAMP(3),'SC-FIXTURE-20261017-5',1);

INSERT INTO lab_floor_scale (scale_id,lab_id,device_no,asset_no,spec,is_feed_scale,owner_user_id,create_by,create_time,remark) VALUES (861017406,11002,'SC-SCALE-861017406','SC-ASSET-861017406','20kg','0',1,'SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO lab_floor_scale (scale_id,lab_id,device_no,asset_no,spec,is_feed_scale,owner_user_id,create_by,create_time,remark) VALUES (861017506,11002,'SC-SCALE-861017506','SC-ASSET-861017506','20kg','1',1,'SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO lab_integrated_reactor (integrated_id,lab_id,model_id,device_no,asset_no,reactor_name,volume_ml,floor_scale_id,floor_scale_low_limit,floor_scale_high_limit,feed_scale_id,owner_user_id,create_by,create_time,remark) VALUES (861017106,11002,861017023,'SC-1017-P20-SMOKE','SC-1017-P20-SMOKE','开始培养测试-P20-SMOKE',20000,861017406,0,20000,861017506,1,'SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO res_culture (culture_id,project_id,batch_id,lab_id,culture_code,culture_name,creator_user_id,facts_status,lifecycle_state,mode_code,device_kind,device_id,planned_start_date,planned_end_date,planned_duration_days,workflow_selection_json,plan_version,runtime_version,n_marked,member_setup_state,create_by,create_time,remark) VALUES (861017206,861017001,861017012,11002,'SC-1017-P20-SMOKE','开始培养测试-P20-SMOKE',1,'READY','NOT_STARTED','REACTOR','INTEGRATED_REACTOR',861017106,'2026-10-17','2026-10-23',7,'["3"]',1,0,0,'NEVER','SC_TEST_20261017',UTC_TIMESTAMP(3),'开始培养页面测试专用，无设备端点、无真实执行凭据；非现场设备');

INSERT INTO res_culture_occupancy (occupancy_id,culture_id,device_kind,device_id,lab_id,occupancy_state,acquired_at,created_request_id,object_version) VALUES (861017306,861017206,'INTEGRATED_REACTOR',861017106,11002,'RESERVED',UTC_TIMESTAMP(3),'SC-FIXTURE-20261017-6',1);