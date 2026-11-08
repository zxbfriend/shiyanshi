-- 仅适用于已经存在的新系统开发/测试库；不是空库安装链的一部分。
-- 依据：M03 培养新增/修改需保存所选反应器容量及单位快照，并校验其来自当前实验室配置。
-- 执行前核对：res_culture 存在；以下两列和约束均不存在；既有记录允许保持容量与单位同时为 NULL。
-- 不回填或猜测既有培养记录的容量，不修改任何业务数据。
--
-- 2026-10-24 开发库执行记录：
--   数据库：ymsw_v2（MySQL 8.0.46）
--   执行前 res_culture 共 65 行，容量配对约束冲突 0 行。
--   两列及 ck_m03_culture_reactor_capacity 均已执行成功，并通过 information_schema 回查。

ALTER TABLE `res_culture`
  ADD COLUMN `reactor_capacity_value` decimal(12,3) NULL
    COMMENT '新增培养选择的反应器容量快照；培养容器为NULL'
    AFTER `container_id`,
  ADD COLUMN `reactor_capacity_unit` varchar(20) NULL
    COMMENT '反应器容量单位快照；与容量值同时为空或同时非空'
    AFTER `reactor_capacity_value`,
  ADD CONSTRAINT `ck_m03_culture_reactor_capacity`
    CHECK (
      (`reactor_capacity_value` IS NULL AND `reactor_capacity_unit` IS NULL)
      OR
      (`reactor_capacity_value` > 0
        AND `reactor_capacity_unit` IS NOT NULL
        AND CHAR_LENGTH(TRIM(`reactor_capacity_unit`)) > 0)
    );

-- 执行后核验；应返回两列及一个 CHECK 约束。
SELECT `column_name`, `column_type`, `is_nullable`, `column_comment`
FROM `information_schema`.`columns`
WHERE `table_schema` = DATABASE()
  AND `table_name` = 'res_culture'
  AND `column_name` IN ('reactor_capacity_value', 'reactor_capacity_unit')
ORDER BY `ordinal_position`;

SELECT `constraint_name`, `constraint_type`
FROM `information_schema`.`table_constraints`
WHERE `constraint_schema` = DATABASE()
  AND `table_name` = 'res_culture'
  AND `constraint_name` = 'ck_m03_culture_reactor_capacity';
