-- 2026-09-10 M06设计稿，未执行。目标MySQL8.0.16+的8.x，无外键。
-- 禁止--force；DDL隐式提交，部分失败停止保留现场。
SET NAMES utf8mb4;
-- 刚迁移维护窗口核验；除场景47行外其他表应为空，不是业务启用后的数量断言。
SELECT 'apr_scene' AS table_name,COUNT(*) AS row_count FROM `apr_scene`;
SELECT COUNT(*) AS expected_columns_12 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='apr_scene';
SHOW CREATE TABLE `apr_scene`;
SELECT 'apr_lab_policy' AS table_name,COUNT(*) AS row_count FROM `apr_lab_policy`;
SELECT COUNT(*) AS expected_columns_8 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='apr_lab_policy';
SHOW CREATE TABLE `apr_lab_policy`;
SELECT 'apr_policy_revision' AS table_name,COUNT(*) AS row_count FROM `apr_policy_revision`;
SELECT COUNT(*) AS expected_columns_9 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='apr_policy_revision';
SHOW CREATE TABLE `apr_policy_revision`;
SELECT 'apr_request' AS table_name,COUNT(*) AS row_count FROM `apr_request`;
SELECT COUNT(*) AS expected_columns_36 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='apr_request';
SHOW CREATE TABLE `apr_request`;
SELECT 'apr_action' AS table_name,COUNT(*) AS row_count FROM `apr_action`;
SELECT COUNT(*) AS expected_columns_14 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='apr_action';
SHOW CREATE TABLE `apr_action`;
SELECT 'apr_delivery' AS table_name,COUNT(*) AS row_count FROM `apr_delivery`;
SELECT COUNT(*) AS expected_columns_16 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='apr_delivery';
SHOW CREATE TABLE `apr_delivery`;
SELECT source_kind,scope_state,COUNT(*) FROM apr_scene GROUP BY source_kind,scope_state;
SELECT COUNT(*) AS legacy_scope_mismatch FROM apr_scene WHERE scene_code='M06_SC031' AND scope_state<>'EXCLUDED';
SELECT table_name,constraint_name,enforced FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name IN ('apr_scene','apr_lab_policy','apr_policy_revision','apr_request','apr_action','apr_delivery') AND constraint_type='CHECK';
-- 将全部47条场景code/源行/hash/档位排除与02 VALUES核对，不仅检查总数。
