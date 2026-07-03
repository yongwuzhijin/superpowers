---
name: finishing-a-development-branch
description: 当实现已完成、所有测试通过、你需要决定如何整合这份工作时使用——本技能通过给出合并、PR 或清理这些结构化选项来指引你完成开发的收尾
---

# 收尾开发分支

## 概述

通过给出清晰的选项并处理所选的工作流,来指引你收尾开发工作。

**核心原则:** 验证测试 → 检测环境 → 给出选项 → 执行选择 → 清理。

**开始时先声明:** "我正在使用 finishing-a-development-branch 技能来收尾这份工作。"

## 流程

### 第 1 步:验证测试

**给出选项之前,先验证测试通过:**

```bash
# Run project's test suite
npm test / cargo test / pytest / go test ./...
```

**如果测试失败:**
```
Tests failing (<N> failures). Must fix before completing:

[Show failures]

Cannot proceed with merge/PR until tests pass.
```

停。不要进入第 2 步。

**如果测试通过:** 继续第 2 步。

### 第 2 步:检测环境

**给出选项之前,先判断工作空间的状态:**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
```

这决定了要展示哪个菜单、以及清理该怎么做:

| 状态 | 菜单 | 清理 |
|-------|------|------|
| `GIT_DIR == GIT_COMMON`(普通仓库) | 标准 4 选项 | 没有工作树需要清理 |
| `GIT_DIR != GIT_COMMON`,有命名分支 | 标准 4 选项 | 基于来源判定(见第 6 步) |
| `GIT_DIR != GIT_COMMON`,detached HEAD | 精简 3 选项(无合并) | 不清理(由外部管理) |

### 第 3 步:确定基础分支

```bash
# Try common base branches
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

或者直接问:"这个分支是从 main 分出来的——对吗?"

### 第 4 步:给出选项

**普通仓库和有命名分支的工作树——严格给出以下这 4 个选项:**

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

**detached HEAD——严格给出以下这 3 个选项:**

```
Implementation complete. You're on a detached HEAD (externally managed workspace).

1. Push as new branch and create a Pull Request
2. Keep as-is (I'll handle it later)
3. Discard this work

Which option?
```

**不要额外解释**——保持选项简洁。

### 第 5 步:执行选择

#### 选项 1:本地合并

```bash
# Get main repo root for CWD safety
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

# Merge first — verify success before removing anything
git checkout <base-branch>
git pull
git merge <feature-branch>

# Verify tests on merged result
<test command>

# Only after merge succeeds: cleanup worktree (Step 6), then delete branch
```

然后:清理工作树(第 6 步),再删除分支:

```bash
git branch -d <feature-branch>
```

#### 选项 2:推送并创建 PR

```bash
# Push branch
git push -u origin <feature-branch>
```

**不要清理工作树**——用户需要它继续存在,好根据 PR 反馈迭代。

#### 选项 3:原样保留

汇报:"保留分支 <name>。工作树保留在 <path>。"

**不要清理工作树。**

#### 选项 4:丢弃

**先确认:**
```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

等待用户一字不差的确认。

如已确认:
```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
```

然后:清理工作树(第 6 步),再强制删除分支:
```bash
git branch -D <feature-branch>
```

### 第 6 步:清理工作空间

**只在选项 1 和选项 4 时执行。** 选项 2 和选项 3 始终保留工作树。

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

**如果 `GIT_DIR == GIT_COMMON`:** 普通仓库,没有工作树需要清理。完成。

**如果工作树路径位于 `.worktrees/` 或 `worktrees/` 之下:** 这个工作树是 Superpowers 创建的——由我们负责清理。

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
git worktree remove "$WORKTREE_PATH"
git worktree prune  # Self-healing: clean up any stale registrations
```

**否则:** 这个工作空间归宿主环境(harness)所有。不要移除它。如果你的平台提供了退出工作空间的工具,就用那个。否则,把工作空间原样留在那里。

## 快速参考

| 选项 | 合并 | 推送 | 保留工作树 | 清理分支 |
|--------|-------|------|---------------|----------------|
| 1. 本地合并 | 是 | - | - | 是 |
| 2. 创建 PR | - | 是 | 是 | - |
| 3. 原样保留 | - | - | 是 | - |
| 4. 丢弃 | - | - | - | 是(强制) |

## 常见错误

**跳过测试验证**
- **问题:** 合并了坏掉的代码,创建出会失败的 PR
- **修正:** 给出选项之前永远先验证测试

**开放式的提问**
- **问题:** "接下来我该做什么?"太含糊
- **修正:** 严格给出 4 个结构化选项(detached HEAD 则给 3 个)

**在选项 2 时清理了工作树**
- **问题:** 把用户迭代 PR 时要用的工作树移除了
- **修正:** 只在选项 1 和选项 4 时清理

**在移除工作树之前就删除分支**
- **问题:** `git branch -d` 会失败,因为工作树仍在引用这个分支
- **修正:** 先合并,移除工作树,再删除分支

**在工作树内部运行 git worktree remove**
- **问题:** 当当前目录就在要移除的工作树里面时,命令会静默失败
- **修正:** 运行 `git worktree remove` 前永远先 `cd` 到主仓库根目录

**清理了归 harness 所有的工作树**
- **问题:** 移除 harness 创建的工作树会导致幽灵状态
- **修正:** 只清理 `.worktrees/` 或 `worktrees/` 之下的工作树

**丢弃时没有确认**
- **问题:** 意外删掉了工作成果
- **修正:** 要求输入 "discard" 来确认

## 危险信号

**绝不:**
- 在测试失败的情况下继续推进
- 不在合并结果上验证测试就合并
- 未经确认就删除工作成果
- 未经明确要求就强制推送
- 在确认合并成功之前就移除工作树
- 清理不是你创建的工作树(要做来源检查)
- 在工作树内部运行 `git worktree remove`

**永远:**
- 给出选项之前先验证测试
- 展示菜单之前先检测环境
- 严格给出 4 个选项(detached HEAD 则给 3 个)
- 选项 4 需要输入确认
- 只在选项 1 和 4 时清理工作树
- 移除工作树之前先 `cd` 到主仓库根目录
- 移除之后运行 `git worktree prune`
