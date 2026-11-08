-- 仅用于本次已授权测试库的定向约束落实，不属于空库安装链。
-- 前置核验：sys_dict_data 已有 active_dict_label；无 dict_label_scope 和 uk_m01_dict_label；
-- 按新规则分组无重复标签；其他索引/业务行/键值保持原样。
ALTER TABLE sys_dict_data
  ADD COLUMN dict_label_scope bigint GENERATED ALWAYS AS
    (CASE WHEN dict_type='smp_detect_class' THEN COALESCE(parent_code,0) ELSE 0 END) STORED
    COMMENT '标签唯一范围：检测字典按父节点，其他字典固定0',
  ADD UNIQUE INDEX uk_m01_dict_label(dict_type,dict_label_scope,active_dict_label);
