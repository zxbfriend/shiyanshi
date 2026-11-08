-- 2026-09-10 M05最终补齐包；MySQL 8.0.16+（8.x），仅设计未执行。
-- 先完成发送02、接收07、签批12及其核验；禁止--force。DDL隐式提交，失败停止逐对象核对。
SET NAMES utf8mb4;
-- 只读核验；SHOW CREATE须与前包累计目标逐字段/索引/CHECK比对；列数相同不足以证明一致。
SHOW CREATE TABLE `det_result`;
SELECT 'det_result' AS table_name,COUNT(*) AS rows_before FROM `det_result`;
SHOW CREATE TABLE `det_result_item`;
SELECT 'det_result_item' AS table_name,COUNT(*) AS rows_before FROM `det_result_item`;
SHOW CREATE TABLE `det_result_sign_record`;
SELECT 'det_result_sign_record' AS table_name,COUNT(*) AS rows_before FROM `det_result_sign_record`;
SHOW CREATE TABLE `det_print_export_log`;
SELECT 'det_print_export_log' AS table_name,COUNT(*) AS rows_before FROM `det_print_export_log`;
SELECT table_name,column_name,column_type,is_nullable,column_default FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('det_result','det_result_item','det_result_sign_record','det_print_export_log') ORDER BY table_name,ordinal_position;
SELECT s.sign_id,s.result_id FROM det_result_sign_record s LEFT JOIN det_result r ON r.result_id=s.result_id WHERE s.result_id IS NOT NULL AND r.result_id IS NULL;
SELECT i.result_item_id,i.result_id FROM det_result_item i LEFT JOIN det_result r ON r.result_id=i.result_id WHERE r.result_id IS NULL;
-- 历史上传/单项作废无准确动作指针不回填；异常待核验不等于可删除数据。
