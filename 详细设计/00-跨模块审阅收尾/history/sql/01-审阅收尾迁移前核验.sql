-- COMMON 只读前置；必须逐列/索引/CHECK与原完整目标比对，不以数量相同代替一致。
SELECT DATABASE(),VERSION();
SELECT table_name,column_name,column_type,is_nullable,column_default,extra FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('__no_old_table__') ORDER BY table_name,ordinal_position;

-- 任一invalid_rows非0则停止；保留原数据，不自动清洗。备份与维护核准完成才设置本包维护/基线/备份确认变量。
