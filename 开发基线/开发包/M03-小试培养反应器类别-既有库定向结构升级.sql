-- 独立定向结构升级，不属于新空库安装链。执行前须确认目标库、停写并备份。
-- 先检查 information_schema.columns 中 res_culture.reactor_category 是否已存在；
-- 若已存在，应核对类型后停止，不得重复执行此 ALTER。
-- 历史培养保持 NULL，不根据容量或设备猜测类别。
ALTER TABLE `res_culture`
    ADD COLUMN `reactor_category` varchar(100) NULL
        COMMENT '小试培养选择的台式反应器类别字典值快照；历史记录和中试为NULL'
        AFTER `reactor_capacity_value`;

-- 执行后由操作者核对 information_schema.columns 及 SHOW CREATE TABLE。
