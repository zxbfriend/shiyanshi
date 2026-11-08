-- 2026-09-10 M05签批数据库设计稿；仅静态设计，未执行。MySQL 8.0.16+（8.x）。
-- 前置发送20列包及接收17列/事件表包。停全部写入口并完成原生一致性备份。
-- DDL隐式提交，禁止--force；部分失败保留现场，不能自动重跑。
SET NAMES utf8mb4;
-- 只读；实际SHOW CREATE逐项对照10接收目标及原签批表，不以计数代替。
SELECT DATABASE(),VERSION();
SHOW CREATE TABLE `det_result`;
SELECT COUNT(*) AS det_result_rows FROM `det_result`;
SHOW CREATE TABLE `det_result_sign_record`;
SELECT COUNT(*) AS det_result_sign_record_rows FROM `det_result_sign_record`;
SELECT result_status,COUNT(*) FROM det_result GROUP BY result_status;
SELECT sign_id,result_id,action_type,signer_user_id,is_voided FROM det_result_sign_record WHERE signer_user_id IS NULL OR result_id IS NULL;
SELECT result_id,action_type,COUNT(*) AS active_candidates FROM det_result_sign_record WHERE is_voided='0' AND action_result='1' GROUP BY result_id,action_type HAVING COUNT(*)>1;
SELECT a.sign_id,a.result_id FROM det_result_sign_record a LEFT JOIN det_result r ON r.result_id=a.result_id WHERE a.result_id IS NOT NULL AND r.result_id IS NULL;
-- 上述仅异常候选，不是已核验活动签名；action_type历史含义须读取旧实现/审计核准。
