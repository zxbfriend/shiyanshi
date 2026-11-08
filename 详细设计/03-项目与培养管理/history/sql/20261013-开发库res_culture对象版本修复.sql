-- HISTORICAL / DEVELOPMENT ENVIRONMENT REPAIR ONLY.
-- 适用范围：2026-10-13 开发库中已存在、但 object_version 为空或小于1的 res_culture 历史行。
-- 禁止加入 docs/开发基线 的新系统空库安装链；新系统仍只执行开发基线 01/02/03。
-- 本文件不含数据库名、地址或凭据。客户端必须预先选择目标库，并遇错停止。

-- 执行前：确认目标库、字段定义和待修复数量。invalid_version_count 应等于本次将更新的行数。
SELECT DATABASE() AS selected_database, VERSION() AS server_version;
SELECT column_name, column_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name = 'res_culture'
  AND column_name = 'object_version';
SELECT COUNT(*) AS invalid_version_count
FROM res_culture
WHERE object_version IS NULL OR object_version < 1;

-- 历史行没有可重演的领域变更序列，只建立迁移基线1；不修改业务字段、审计时间或操作者。
START TRANSACTION;
UPDATE res_culture
SET object_version = 1
WHERE object_version IS NULL OR object_version < 1;
COMMIT;

-- 与 docs/开发基线/01-完整建表.sql 的现行目标定义一致，阻止后续再次写入空版本。
ALTER TABLE res_culture
  MODIFY COLUMN object_version bigint NOT NULL DEFAULT 1
    COMMENT '对象并发版本；迁移基线1，每次领域变更递增';

-- 执行后：invalid_version_count 应为0，字段应为 NOT NULL / DEFAULT 1。
SELECT COUNT(*) AS invalid_version_count
FROM res_culture
WHERE object_version IS NULL OR object_version < 1;
SELECT column_name, column_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name = 'res_culture'
  AND column_name = 'object_version';
