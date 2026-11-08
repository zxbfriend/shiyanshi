-- 2026-09-10 M05接收数据库设计稿；未执行数据库。MySQL 8.0.16+ 的8.x目标。
-- 先完成发送20列包；停所有管理/采集/签批写入，核准备份与SHOW CREATE TABLE差异；禁止--force。
-- DDL隐式提交，失败即停并逐对象核对，不自动重跑或覆盖备份。
SET NAMES utf8mb4;
-- 只读报告；字段数量相同仍须逐列/键/约束比对当前基线和发送目标DDL。
SELECT DATABASE(),VERSION();
SELECT table_name,engine,table_type FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name IN ('det_sample','det_result','det_result_item','det_dispatch_log','lab_detector','det_device_event');
SHOW CREATE TABLE `det_sample`;
SELECT COUNT(*) AS det_sample_rows FROM `det_sample`;
SHOW CREATE TABLE `det_result`;
SELECT COUNT(*) AS det_result_rows FROM `det_result`;
SHOW CREATE TABLE `det_result_item`;
SELECT COUNT(*) AS det_result_item_rows FROM `det_result_item`;
SELECT result_status,COUNT(*) FROM det_result GROUP BY result_status;
SELECT sample_id,COUNT(*) FROM det_result GROUP BY sample_id HAVING COUNT(*)>1;
-- 多结果不是自动清理对象；迁移不合并、不删除。
