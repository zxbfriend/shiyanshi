-- 仅适用于已经存在的新系统开发/测试库；不是空库安装链的一部分。
-- 依据：设备型号库设计.md §10.4/16.1：主数据新增不编造运行能力，未配置保持未知。
-- 执行前核对：dev_detector_model.support_stored 为 varchar(1)，send_mode 为 varchar(20)。
-- 不更新任何既有行；不设置默认暂存/发送行为；不应用实例规则。
ALTER TABLE dev_detector_model
  MODIFY COLUMN support_stored varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否支持暂存（0=否,1=是），NULL=未配置',
  MODIFY COLUMN send_mode varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发送方式（single=单发,column=列发），NULL=未配置';
