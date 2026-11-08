# 远端分支合入审计（zhangxiaobo 相关）— 2026-10-03

> 只读审计报告。本文档只做证据记录与判定，不执行任何改变远端或本地分支历史的操作。

## 0. 操作纪律声明（必须遵守）

- **本轮没有删除任何远端分支**（不执行 `git push --delete`、不在 Codeup 删除）。
- **没有 push / merge / rebase / cherry-pick** 任何分支。
- **没有清理**任何未跟踪材料；工作区其余未跟踪文件（M01/M09 复核 `.md`）按纪律未纳入、未提交。
- 所有判定命令均为只读：`git fetch`(仅刷新远端跟踪引用，不改变本地/远端分支历史)、`git rev-parse`、`git branch -r`、`git merge-base`、`git rev-list`、`git cherry`、`git log`、`git diff`、`git merge-tree`(仅计算、不改写任何对象)。
- **“创建者”字段不是 Git 原生事实**：Git 远端引用通常不保存“谁创建了分支”。除非有 Codeup API / Web 页面证据，否则只能按 **分支名线索** 或 **提交 author/committer** 推断“使用/关联”，不能断言“创建”。
- **审计基线**：本轮 `git fetch --all --prune` 之后的 `origin/cloud` = `70f608c29471033c8c38558ec158fdcb5a912d68`（与当前本地 HEAD 相同）。

---

## 1. 审计元信息

| 项 | 值 |
|---|---|
| 仓库根 | `D:/Code/zhixianweilai/yaoming-cloud` |
| 远端 | `origin` → `https://codeup.aliyun.com/6908610b79c766a0475d228d/futurefab/yaoming_shengwu.git` |
| 审计基线 `origin/cloud` | `70f608c29471033c8c38558ec158fdcb5a912d68` |
| 基线最后提交 | `docs(frontend): 勘误浏览器覆盖矩阵读口与探针口径`（author/committer: zhangxiaobo，2026-10-03 09:33:31 +0800） |
| 当前 HEAD | `70f608c29471033c8c38558ec158fdcb5a912d68`（= origin/cloud） |
| 工作区状态 | 干净；仅 4 个未跟踪的复核 `.md`（未触碰） |
| 远端引用总数 | 20（`git branch -r` 含 `origin/HEAD -> origin/master`）；实际分支 19 个 + 1 个 HEAD 符号引用 |
| 验证层级 | `STATIC_VERIFIED`（仅静态/只读判定；未执行合并、删除、push，未做浏览器/现场验收） |

---

## 2. 候选分支识别方法与结果

### 2.1 识别规则（按任务要求分层）

1. **分支名线索**：分支名含 `zhangxiaobo` / `zhangxiaob` / `zhangxb` / `zxb` → 本轮 **0 个**命中（所有远端分支名均不含这些字符串）。
2. **提交作者线索**：分支独有提交（相对 `origin/cloud` 的 right-only 提交）的 `author`/`committer` 含 `zhangxiaobo` → 命中分支见下。
3. **本项目代理临时分支**：近期对话出现的 `codex/*` 类分支 → 远端不存在，本轮 **0 个**；但 `origin/qoder2/*` 命名疑似 AI 编码代理工作分支，单独标注（见 2.3）。

### 2.2 候选分支（zhangxiaobo 关联）— 共 4 个

判定为候选的强依据：**分支 tip 提交及其全部独有提交的 author/committer 均为 `zhangxiaobo`**，即这些分支上的工作本身由 zhangxiaobo 提交/署名。

| 分支 | tip | tip author/committer | 全部独有提交作者 | 名称含 zhangxiaobo? | 关联依据 |
|---|---|---|---|---|---|
| `origin/qoder2/m02-p0-closure` | `b9d1b87b7e` | zhangxiaobo | （无独有提交，已合入） | 否（`qoder2` 疑似代理分支名） | 提交署名 zhangxiaobo（使用/操作） |
| `origin/review/cloud-m01-org-add-014-019` | `b5d6f3bd49` | zhangxiaobo | zhangxiaobo | 否 | 提交署名 zhangxiaobo（使用/操作） |
| `origin/review/cloud-m02-tp07-tp14` | `3cbcfcea8c` | zhangxiaobo | zhangxiaobo | 否 | 提交署名 zhangxiaobo（使用/操作） |
| `origin/review/cloud-m02-tp12-112` | `a0f1b20ffd` | zhangxiaobo | zhangxiaobo | 否 | 提交署名 zhangxiaobo（使用/操作） |

### 2.3 关于“创建者”的说明（关键）

- **Git 可直接证明**：上述 4 个分支的 tip 及其独有提交 `author`/`committer` 字段为 `zhangxiaobo`（提交对象内嵌事实）。
- **只能推断（不能证明）**：这 4 个分支“由 zhangxiaobo 创建”。分支名均无 zhangxiaobo 字样，`qoder2/*` 更疑似 AI 代理（Qoder）工作分支，zhangxiaobo 为代理运行的署名者/提交者。无 Codeup API 证据前，只能判定“zhangxiaobo 使用/操作过该分支”，不能判定“zhangxiaobo 创建”。
- **Git CLI 无法证明**：分支创建者身份；以及未合入内容是否“仍需要合入”（业务判断，非 Git 事实）。

### 2.4 被扫描但排除为候选的共享/系统分支

`origin/dev`、`origin/master`、`origin`(HEAD)、`origin/dev_test_20260917` 及所有 `origin/feature/*` 均被扫描。其中多个分支（dev/master/部分 feature）的独有提交历史中夹杂 zhangxiaobo 署名提交（疑似合并/评审带入），触发了“提交作者线索”启发式，但：

- 这些分支 **tip 作者均为 Song / zoujun / Evan Hou 等其他开发者**；
- 它们属于系统分支或他人功能分支，按任务规则仅作背景、不作为 zhangxiaobo 候选；
- 因此 **不计入候选集**，避免把共享分支误判为 zhangxiaobo 专属分支。

---

## 3. 合入判定总表（候选分支）

| branch | tip | last_commit_time | author/committer | zhangxiaobo 关联依据 | ahead/behind vs cloud | merge_status | 独有文件数 | 风险摘要 | 建议动作 |
|---|---|---|---|---|---|---|---|---|---|
| `origin/qoder2/m02-p0-closure` | `b9d1b87b7e` | 2026-09-30 | zhangxiaobo/zhangxiaobo | 提交署名（使用） | ahead 0 / behind 69 | `MERGED_BY_ANCESTRY` | 0 | 已完全合入 cloud 历史，无独有提交；仅落后 69 个后续提交 | 可归档；**本轮不删** |
| `origin/review/cloud-m01-org-add-014-019` | `b5d6f3bd49` | 2026-10-01 | zhangxiaobo/zhangxiaobo | 提交署名（使用） | ahead 1 / behind 63 | `NOT_MERGED` | 7 | 1 个文件存在 Git 直接证明的合并冲突（见 §4.1） | 保留；交复核人确认是否仍需合入 |
| `origin/review/cloud-m02-tp07-tp14` | `3cbcfcea8c` | 2026-10-01 | zhangxiaobo/zhangxiaobo | 提交署名（使用） | ahead 1 / behind 63 | `NOT_MERGED` | 22 | 7 个文件存在 Git 直接证明的合并冲突（见 §4.2） | 保留；**高风险**，需人工解决冲突后合入 |
| `origin/review/cloud-m02-tp12-112` | `a0f1b20ffd` | 2026-10-01 | zhangxiaobo/zhangxiaobo | 提交署名（使用） | ahead 3 / behind 63 | `NOT_MERGED` | 29 | 4 个文件存在 Git 直接证明的合并冲突（见 §4.3）；**已包含 tp07-tp14 的唯一直有提交 `3cbcfcea8c`** | 保留；**高风险**；与 tp07-tp14 二选一合入即可，避免重复合入 |

> 判定方法（按任务步骤）：
> - A. `git merge-base --is-ancestor <branch> origin/cloud` → true 即 `MERGED_BY_ANCESTRY`。
> - B. `git rev-list --left-right --count origin/cloud...<branch>` 右侧为 0 → `NO_UNIQUE_COMMITS`。
> - C. `git cherry -v origin/cloud <branch>` 全为 `-` → `MERGED_BY_PATCH_EQUIVALENCE`；存在 `+` → `NOT_MERGED`。
> 冲突证据由只读 `git merge-tree origin/cloud <branch>` 计算所得（不改写任何对象）。

---

## 4. 未合入分支影响摘要（NOT_MERGED）

### 4.1 `origin/review/cloud-m01-org-add-014-019`

- **独有提交数**：1
  - `b5d6f3bd49` · zhangxiaobo/zhangxiaobo · 2026-10-01 · `feat(m01): M01-014/019 场地与部门新增收口为 ORG02/ORG07 守卫写`
- **独有文件（7）**：
  - `futurefab-modules/futurefab-system/.../controller/SysDeptController.java`
  - `futurefab-modules/futurefab-system/.../controller/SysVenueController.java`
  - `futurefab-modules/futurefab-system/.../service/impl/application/m01/DeptApplicationServiceImpl.java`
  - `futurefab-modules/futurefab-system/.../service/impl/application/m01/VenueApplicationServiceImpl.java`
  - `futurefab-modules/futurefab-system/.../test/java/.../contract/M01OrgSkeletonContractTest.java`
  - `futurefab-modules/futurefab-system/.../test/java/.../contract/M01OrgWiredWriteContractTest.java`
  - `futurefab-modules/futurefab-system/.../test/java/.../contract/M01WiredReadContracts.java`
- **敏感范围**：Java（Controller / ApplicationService）+ 测试；**未触碰** SQL / 前端 / docs / history / 配置。
- **Git 直接证明的合并冲突（1）**：`.../test/java/.../contract/M01WiredReadContracts.java`（content）。
- **潜在冲突范围**：分支落后 cloud 63 个提交；除上述 1 个已证明冲突外，其余 6 个文件是否与 cloud 近期改动冲突需人工合并验证（纪律禁止实际合并）。

### 4.2 `origin/review/cloud-m02-tp07-tp14`

- **独有提交数**：1
  - `3cbcfcea8c` · zhangxiaobo/zhangxiaobo · 2026-10-01 · `feat(m02): TP-M02-07 设备通讯与 TP-M02-14 在线观测 501 收口接线`
- **独有文件（22）**：LabCommunicationController/LabObservationController（Controller）、LabCommunication/LabObservationMapping/M02LabCommunicationScopedRow（Domain）、LabCommunicationMapper/LabObservationMappingMapper（Mapper）、ObservationApplicationService（ApplicationService 接口）、AuditObjectType/AuditPolicyRegistry/ManagementOperation（audit/guard 公共服务）、LabCommunicationApplicationServiceImpl/ObservationApplicationServiceImpl（Impl）、LabCommunicationMapper.xml/LabObservationMappingMapper.xml（XML）、若干 M02 契约测试、skeleton-m02.json（测试资源）。
- **敏感范围**：Java + XML（Mapper）+ 测试；**未触碰** SQL / 前端 / docs / 配置。
- **Git 直接证明的合并冲突（7）**：
  - `.../service/audit/AuditObjectType.java`（content）
  - `.../service/impl/application/m02/ObservationApplicationServiceImpl.java`（content）
  - `.../resources/mapper/lab/LabObservationMappingMapper.xml`（add/add）
  - `.../test/java/.../contract/M02SkeletonContractTest.java`（content）
  - `.../test/java/.../contract/M02WiredS2ReadContractTest.java`（content）
  - `.../test/java/.../service/audit/AuditPolicyRegistryTest.java`（content）
  - `.../test/java/.../service/guard/ManagementOperationTest.java`（content）
- **重要重叠提示**：该分支与上述 `tp12-112` 在 4 个核心文件（`ObservationApplicationServiceImpl.java`、`LabObservationMappingMapper.xml`、`AuditPolicyRegistryTest.java`、`ManagementOperationTest.java`）上冲突完全一致；且其唯一直有提交 `3cbcfcea8c` 已被 `tp12-112` 包含（见 §4.3）。

### 4.3 `origin/review/cloud-m02-tp12-112`

- **独有提交数**：3
  - `a0f1b20ffd` · zhangxiaobo · 2026-10-01 · `docs(m02): 登记液瓶配置占用裁决与 M02-112 收口口径（TP-M02-12）`
  - `3eb0ef992d` · zhangxiaobo · 2026-10-01 · `feat(m02): M02-112 打印排版收口为真实守卫写（TP-M02-12）`
  - `3cbcfcea8c` · zhangxiaobo · 2026-10-01 · `feat(m02): TP-M02-07 设备通讯与 TP-M02-14 在线观测 501 收口接线`
- **独有文件（29）**：在 `tp07-tp14` 的 22 个文件基础上，新增 `LabPrinterController.java`、`M02PrinterLayoutLockRow.java`、`LabPrinterLayoutSettingMapper.java`、`LabPrinterLayoutSettingApplicationServiceImpl.java`、`LabPrinterLayoutSettingMapper.xml`、`M02WiredPrinterLayoutSaveContractTest.java`，以及根目录文档 `M02-next-remaining-501-precheck.md`。
- **敏感范围**：Java + XML + 测试 + docs（1 个 `.md`）；**未触碰** SQL / 前端 / 配置。
- **Git 直接证明的合并冲突（4）**：
  - `.../service/impl/application/m02/ObservationApplicationServiceImpl.java`（content）
  - `.../resources/mapper/lab/LabObservationMappingMapper.xml`（add/add）
  - `.../test/java/.../service/audit/AuditPolicyRegistryTest.java`（content）
  - `.../test/java/.../service/guard/ManagementOperationTest.java`（content）
- **与 tp07-tp14 的关系（Git 直接证明）**：`tp12-112` 的独有提交列表包含 `3cbcfcea8c`，而该提交正是 `tp07-tp14` 的唯一直有提交。因此 **合并 `tp12-112` 将同时带入 `tp07-tp14` 的全部内容**。建议二选一合入，避免对相同 4 个核心文件重复解决冲突。

---

## 5. 建议动作（按任务规则）

| 分支 | merge_status | 建议动作 |
|---|---|---|
| `origin/qoder2/m02-p0-closure` | `MERGED_BY_ANCESTRY` | 可归档/删除候选；**本轮未删除，仅报告** |
| `origin/review/cloud-m01-org-add-014-019` | `NOT_MERGED` | 保留；交对应开发/复核人确认是否仍需合入（含 1 处冲突需解决） |
| `origin/review/cloud-m02-tp07-tp14` | `NOT_MERGED` | 保留；**高风险**，需人工解决 7 处冲突后合入；与 tp12-112 二选一 |
| `origin/review/cloud-m02-tp12-112` | `NOT_MERGED` | 保留；**高风险**，需人工解决 4 处冲突后合入；已覆盖 tp07-tp14，优先选此分支合入 |

- `MERGED_BY_ANCESTRY` / `MERGED_BY_PATCH_EQUIVALENCE` / `NO_UNIQUE_COMMITS`：可归档，本轮一律 **不删除**。
- `NOT_MERGED`：保留并交复核人确认。
- 本轮未出现 `UNKNOWN_NEEDS_MANUAL_CHECK`；但所有分支的“创建者”均 `UNKNOWN`（见 §2.3）。

---

## 6. 结论与回报

- **候选分支数量**：4
- **已合入数量（Git 直接证明）**：1（`qoder2/m02-p0-closure`，`MERGED_BY_ANCESTRY`）
- **未合入数量（Git 直接证明）**：3（`m01-org-add-014-019`、`tp07-tp14`、`tp12-112`，均 `NOT_MERGED`）
- **无法判定数量（UNKNOWN_NEEDS_MANUAL_CHECK）**：0
- **是否存在需人工处理的高风险分支**：**是**。3 个未合入分支均存在 Git 直接证明的合并冲突；其中 `tp07-tp14`（7 处）、`tp12-112`（4 处）为高风险，且两分支在 4 个核心文件上冲突重叠，`tp12-112` 已包含 `tp07-tp14` 内容。
- **未纳入文件**：本轮仅新增并提交本审计报告；工作区其余未跟踪复核 `.md` 按纪律未纳入、未提交；未纳入任何源码/分支改动。
- **分层口径**：`STATIC_VERIFIED` —— 未执行任何合并/删除/push；冲突为只读 `git merge-tree` 计算结果，非实际合并。
- **创建者可判定性**：全部 4 个候选分支“创建者”无法由 Git CLI 证明，仅能按提交署名推断“使用/操作”关联。

---

## 7. 证据与方法（可复现命令）

```bash
git rev-parse --show-toplevel
git status --short
git fetch --all --prune
git rev-parse origin/cloud          # 70f608c29471033c8c38558ec158fdcb5a912d68
git branch -r
# 每候选分支：
git merge-base --is-ancestor origin/<branch> origin/cloud
git rev-list --left-right --count origin/cloud...origin/<branch>
git cherry -v origin/cloud origin/<branch>
git diff --name-status origin/cloud...origin/<branch>
git merge-tree origin/cloud origin/<branch>   # 只读冲突计算
```

> 所有命令均为只读；`merge-tree` 仅计算合并结果，不写入任何对象，不改变分支历史。
