-- 仅用于本次明确授权测试库；不进入空库安装链。
-- 先经正式守卫写接口修复已核对引用的二级字典值；本脚本不更新任何字典/设备/历史数据。
-- 执行前必须核对active_dict_value生成式、确认有效键值无重复且该索引不存在。
ALTER TABLE sys_dict_data ADD UNIQUE INDEX uk_m01_dict_value(dict_type,active_dict_value);
