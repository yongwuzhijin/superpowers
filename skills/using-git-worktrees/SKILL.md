---
name: using-git-worktrees
description: 当你开始一项需要与当前工作空间隔离的特性开发、或在执行实现计划之前使用——通过原生工具或 git worktree 兜底方案,确保存在一个隔离的工作空间
---

# 使用 Git 工作树

## 概述

确保工作发生在隔离的工作空间里。优先用你所在平台的原生工作树工具。只有在没有原生工具可用时,才退回到手动的 git 工作树。

**核心原则:** 先检测是否已有隔离。然后用原生工具。再退回到 git。永远不要跟 harness 对着干。

**开始时先声明:** "我正在使用 using-git-worktrees 技能来搭建一个隔离的工作空间。"

## 第 0 步:检测是否已有隔离

**在创建任何东西之前,先检查你是否已经身处一个隔离的工作空间。**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**子模块防护:** 在 git 子模块内部,`GIT_DIR != GIT_COMMON` 同样成立。在下结论"已经在工作树里"之前,先确认你不在子模块里:

```bash
# If this returns a path, you're in a submodule, not a worktree — treat as normal repo
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**如果 `GIT_DIR != GIT_COMMON`(且不是子模块):** 你已经在一个关联的工作树里了。跳到第 2 步(项目搭建)。不要再创建另一个工作树。

按分支状态汇报:
- 在某个分支上:"已在隔离工作空间 `<path>`,位于分支 `<name>`。"
- detached HEAD:"已在隔离工作空间 `<path>`(detached HEAD,由外部管理)。收尾时需要创建分支。"

**如果 `GIT_DIR == GIT_COMMON`(或身处子模块):** 你在一个普通的仓库检出里。

用户是否已经在给你的指令里表明了他对工作树的偏好?如果没有,创建工作树之前先征求同意:

> "要我搭建一个隔离的工作树吗?它能保护你当前的分支不被改动。"

如果已有明确表态的偏好,直接照办、不用再问。如果用户拒绝同意,就地工作,并跳到第 2 步。

## 第 1 步:创建隔离的工作空间

**你有两种机制。按这个顺序尝试。**

### 1a. 原生工作树工具(优先)

用户已经要求了一个隔离的工作空间(第 0 步的同意)。你手头是否已经有创建工作树的办法?它可能是个名字类似 `EnterWorktree`、`WorktreeCreate` 的工具,或一个 `/worktree` 命令,或一个 `--worktree` 标志。如果有,就用它,然后跳到第 2 步。

原生工具会自动处理目录放置、分支创建和清理。在已有原生工具的情况下还用 `git worktree add`,会造出你的 harness 看不见也管不了的幽灵状态。

只有在没有任何原生工作树工具可用时,才进入 1b。

### 1b. Git 工作树兜底

**只在 1a 不适用时使用**——你没有任何原生工作树工具可用。用 git 手动创建一个工作树。

#### 目录选择

按下面的优先级顺序来。用户的明确偏好永远压过对文件系统状态的观察。

1. **查看你的指令里有没有声明工作树目录偏好。** 如果用户已经指定了,直接用,不用问。

2. **检查是否存在项目本地的工作树目录:**
   ```bash
   ls -d .worktrees 2>/dev/null     # Preferred (hidden)
   ls -d worktrees 2>/dev/null      # Alternative
   ```
   如果找到就用它。如果两个都存在,`.worktrees` 优先。

3. **如果没有其他可依据的指引**,默认用项目根目录下的 `.worktrees/`。

#### 安全性验证(仅针对项目本地目录)

**创建工作树之前,必须先确认目录已被忽略:**

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**如果没有被忽略:** 加进 .gitignore,提交这处改动,然后再继续。

**为什么至关重要:** 防止把工作树内容意外提交进仓库。

#### 创建工作树

```bash
# Determine path based on chosen location
path="$LOCATION/$BRANCH_NAME"

git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

**沙箱兜底:** 如果 `git worktree add` 因权限错误(沙箱拒绝)而失败,告诉用户沙箱挡住了工作树创建,你改为在当前目录里工作。然后就地运行搭建和基线测试。

## 第 2 步:项目搭建

自动检测并运行相应的搭建命令:

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

## 第 3 步:验证基线干净

运行测试,确保工作空间从干净状态起步:

```bash
# Use project-appropriate command
npm test / cargo test / pytest / go test ./...
```

**如果测试失败:** 汇报失败,询问是继续还是先排查。

**如果测试通过:** 汇报就绪。

### 汇报

```
Worktree ready at <full-path>
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## 快速参考

| 情形 | 动作 |
|-----------|--------|
| 已在关联的工作树里 | 跳过创建(第 0 步) |
| 身处子模块 | 当作普通仓库(第 0 步防护) |
| 有原生工作树工具可用 | 用它(第 1a 步) |
| 没有原生工具 | git 工作树兜底(第 1b 步) |
| `.worktrees/` 存在 | 用它(确认已忽略) |
| `worktrees/` 存在 | 用它(确认已忽略) |
| 两者都存在 | 用 `.worktrees/` |
| 两者都不存在 | 查指令文件,再默认 `.worktrees/` |
| 目录未被忽略 | 加进 .gitignore + 提交 |
| 创建时遇权限错误 | 沙箱兜底,就地工作 |
| 基线测试失败 | 汇报失败 + 询问 |
| 没有 package.json/Cargo.toml | 跳过依赖安装 |

## 常见错误

### 跟 harness 对着干

- **问题:** 平台已经提供了隔离,你却还用 `git worktree add`
- **修正:** 第 0 步会检测已有隔离。第 1a 步会让位给原生工具。

### 跳过检测

- **问题:** 在已有工作树里面又嵌套创建了一个工作树
- **修正:** 创建任何东西之前永远先跑第 0 步

### 跳过忽略验证

- **问题:** 工作树内容被纳入版本跟踪,污染 git status
- **修正:** 创建项目本地工作树之前永远先用 `git check-ignore`

### 想当然地假定目录位置

- **问题:** 造成不一致,违反项目约定
- **修正:** 遵循优先级:明确指令 > 已有的项目本地目录 > 默认

### 在测试失败的情况下继续

- **问题:** 无法区分新引入的 bug 和原本就存在的问题
- **修正:** 汇报失败,取得明确许可再继续

## 危险信号

**绝不:**
- 在第 0 步已检测到有隔离时还创建工作树
- 在你有原生工作树工具(如 `EnterWorktree`)时还用 `git worktree add`。这是头号错误——有就用。
- 直接跳到第 1b 步的 git 命令,跳过第 1a 步
- 不验证是否已忽略就创建工作树(项目本地)
- 跳过基线测试验证
- 不问一声就在测试失败的情况下继续

**永远:**
- 先跑第 0 步检测
- 相比 git 兜底,优先用原生工具
- 遵循目录优先级:明确指令 > 已有的项目本地目录 > 默认
- 对项目本地目录确认其已被忽略
- 自动检测并运行项目搭建
- 验证测试基线干净
