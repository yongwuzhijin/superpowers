---
name: using-git-worktrees
description: 当你开始一项需要与当前工作空间隔离的特性开发、或在执行实现计划之前使用——通过原生工具或 git worktree 兜底方案,确保存在一个隔离的工作空间
---

# Using Git Worktrees

## 概述

确保工作发生在一个隔离的工作空间里。优先用你的平台原生的工作树工具。只有在没有原生工具可用时,才退回到手动 git worktree。

**核心原则:** 先探测现有的隔离。然后用原生工具。再退回到 git。永远不要跟运行环境(harness)对着干。

**开场先声明:** "我正在使用 using-git-worktrees 技能来搭建一个隔离的工作空间。"

## 第 0 步:探测现有的隔离

**在创建任何东西之前,先检查你是不是已经在一个隔离的工作空间里了。**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**子模块警戒:** 在 git 子模块(submodule)内部,`GIT_DIR != GIT_COMMON` 也成立。在断定"已经在工作树里"之前,先确认你不是在子模块里:

```bash
# 如果这条命令返回了一个路径,说明你在子模块里,不是工作树 —— 当作普通仓库处理
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**如果 `GIT_DIR != GIT_COMMON`(且不是子模块):** 你已经在一个链接工作树里了。跳到第 2 步(项目设置)。不要再创建另一个工作树。

连同分支状态一起报告:
- 在某个分支上:"已在隔离的工作空间中,路径 `<path>`,分支 `<name>`。"
- detached HEAD:"已在隔离的工作空间中,路径 `<path>`(detached HEAD,由外部管理)。收尾时需要创建分支。"

**如果 `GIT_DIR == GIT_COMMON`(或在子模块里):** 你在一个普通的仓库检出里。

用户是否已在给你的指令中表明了工作树偏好?如果没有,在创建工作树前先征得同意:

> "要我搭建一个隔离的工作树吗?它能保护你当前的分支不受改动影响。"

如果已有明确声明的偏好,就照做,不必再问。如果用户拒绝同意,就原地工作并跳到第 2 步。

## 第 1 步:创建隔离的工作空间

**你有两种机制。按这个顺序尝试。**

### 1a. 原生工作树工具(优先)

用户已经要了一个隔离的工作空间(第 0 步的同意)。你手上是否已经有创建工作树的办法?它可能是一个名字类似 `EnterWorktree`、`WorktreeCreate` 的工具,一个 `/worktree` 命令,或者一个 `--worktree` 参数。如果有,就用它,然后跳到第 2 步。

原生工具会自动处理目录放置、分支创建和清理。在你有原生工具时还去用 `git worktree add`,会制造出你的运行环境看不到也管不了的幽灵状态。

只有在你没有任何原生工作树工具可用时,才继续到第 1b。

### 1b. Git 工作树兜底方案

**只有在第 1a 不适用时才用这个** —— 你没有任何原生工作树工具可用。用 git 手动创建一个工作树。

#### 目录选择

按这个优先级顺序来。用户明确的偏好永远压过观察到的文件系统状态。

1. **检查你的指令里有没有声明过工作树目录的偏好。** 如果用户已经指定了一个,就用它,不必再问。

2. **检查是否已存在一个项目本地的工作树目录:**
   ```bash
   ls -d .worktrees 2>/dev/null     # 首选(隐藏目录)
   ls -d worktrees 2>/dev/null      # 备选
   ```
   找到就用。如果两个都存在,`.worktrees` 胜出。

3. **如果没有其他可依据的指引**,默认用项目根目录下的 `.worktrees/`。

#### 安全验证(仅针对项目本地目录)

**创建工作树之前必须验证目录已被忽略:**

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**如果没有被忽略:** 加到 .gitignore,提交这个改动,然后再继续。

**为什么这很关键:** 防止意外地把工作树内容提交进仓库。

#### 创建工作树

```bash
# 根据选定的位置确定路径
path="$LOCATION/$BRANCH_NAME"

git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

**沙箱兜底:** 如果 `git worktree add` 因权限错误(沙箱拒绝)而失败,告诉用户沙箱挡住了工作树创建,你转而在当前目录里工作。然后原地运行设置和基线测试。

## 第 2 步:项目设置

自动探测并运行相应的设置:

```bash
# Node.js
if [ -f package.json ]; then npm install; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

## 第 3 步:验证干净的基线

运行测试以确保工作空间起步是干净的:

```bash
# 使用项目对应的命令
npm test / cargo test / pytest / go test ./...
```

**如果测试失败:** 报告失败项,询问是继续还是排查。

**如果测试通过:** 报告就绪。

### 报告

```
Worktree ready at <full-path>
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## 快速参考

| 情形 | 动作 |
|-----------|--------|
| 已经在链接工作树里 | 跳过创建(第 0 步) |
| 在子模块里 | 当作普通仓库处理(第 0 步警戒) |
| 有原生工作树工具可用 | 用它(第 1a) |
| 没有原生工具 | Git 工作树兜底(第 1b) |
| `.worktrees/` 存在 | 用它(验证已忽略) |
| `worktrees/` 存在 | 用它(验证已忽略) |
| 两个都存在 | 用 `.worktrees/` |
| 两个都不存在 | 检查指令文件,然后默认 `.worktrees/` |
| 目录未被忽略 | 加到 .gitignore + 提交 |
| 创建时权限错误 | 沙箱兜底,原地工作 |
| 基线阶段测试失败 | 报告失败 + 询问 |
| 没有 package.json/Cargo.toml | 跳过依赖安装 |

## 常见的自我合理化

| 借口 | 现实 |
|--------|---------|
| "我明显不在工作树里 —— 没必要检查" | 跑第 0 步。运行环境创建的隔离和子模块都能骗过肉眼;探测命令才能一锤定音。 |
| "`git worktree add` 比去找原生工具更快" | 原生工具(比如 `EnterWorktree`)掌管放置、分支和清理。绕开它是头号错误 —— 它会制造出你的运行环境看不到也管不了的幽灵状态。 |
| "那个工作树目录肯定早就被忽略了" | 跑一下 `git check-ignore`。一个未被忽略的工作树目录会把整棵树提交进仓库。 |
| "叫什么目录名都行" | 明确的指令压过已存在的项目本地目录,后者又压过 `.worktrees/` 默认值。 |
| "工作空间是全新的 —— 基线测试可以先等等" | 基线不干净会让之后每一次失败都变得含糊不清。现在就跑测试;跨过失败继续走是你的人类搭档说了算。 |
