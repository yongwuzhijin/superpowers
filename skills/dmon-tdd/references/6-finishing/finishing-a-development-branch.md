---
name: finishing-a-development-branch
description: 当实现已完成、所有测试通过、你需要决定如何整合这份工作时使用
---

# Finishing a Development Branch

## 概述

**核心原则:** 验证测试 → 探测环境 → 给出选项 → 执行选择 → 清理收尾。

**开场先声明:** "我正在使用 finishing-a-development-branch 技能来收尾这份工作。"

## 第 1 步:验证测试

运行项目的完整测试套件(`npm test` / `cargo test` / `pytest` / `go test ./...`)。

**如果测试失败**,报告失败项并停下来 —— 菜单要等到套件全绿之后才出现:

```
Tests failing (<N> failures). Must fix before completing:

[Show failures]
```

**如果测试通过:** 继续到第 2 步。

## 第 2 步:探测环境

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
# 趁还在工作空间内先把它捕获下来 —— 第 5 步会切换目录
# 而清理(第 6 步)需要用到这个值
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

它决定了展示哪个菜单、以及清理如何进行:

| 状态 | 菜单 | 清理 |
|-------|------|---------|
| `GIT_DIR == GIT_COMMON`(普通仓库) | 标准 3 个选项 | 没有工作树需要清理 |
| `GIT_DIR != GIT_COMMON`,有命名分支 | 标准 3 个选项 | 基于来源判定(见第 6 步) |
| `GIT_DIR != GIT_COMMON`,detached HEAD | 精简 2 个选项(无合并) | 由外部管理 —— 原地保留 |

## 第 3 步:确定基分支

基分支就是这份工作从哪儿分叉出来的 —— 通常在计划、对话或分支的上游里会标明。如果还不清楚,就问一句:"这个分支是从 <你的最佳猜测> 分出来的 —— 对吗?"合并前先确认:合并进错误的基分支,撤销起来代价很大。

## 第 4 步:给出选项

**普通仓库和有命名分支的工作树 —— 精确给出这 3 个选项:**

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)

Which option?
```

**detached HEAD —— 精确给出这 2 个选项:**

```
Implementation complete. You're on a detached HEAD (externally managed workspace).

1. Push as new branch and create a Pull Request
2. Keep as-is (I'll handle it later)

Which option?
```

原样给出这个菜单 —— 简洁,每个选项都出自上面的列表。丢弃这份工作只在你的人类搭档明确提出要求时才会发生(见下文"如果你的人类搭档要求丢弃这份工作")。等他们回答;整合的决定权在他们手上。

## 第 5 步:执行选择

### 选项 1:本地合并

```bash
# 获取主仓库根目录以保证 CWD 安全
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

# 先合并 —— 在删除任何东西之前先验证成功
git checkout <base-branch>
git pull
git merge <feature-branch>

# 在合并后的结果上验证测试
<test command>
```

如果合并结果上的测试失败:停下来,原地保留工作树和分支,然后排查 —— 什么都还没推送,所以这次合并只是本地的、可恢复的。

一旦合并结果全绿:清理工作树(第 6 步),然后删除分支:

```bash
git branch -d <feature-branch>
```

### 选项 2:推送并创建 PR

```bash
git push -u origin <feature-branch>
# 从 detached HEAD,给远端上的新分支命名:
# git push origin HEAD:refs/heads/<new-branch>
```

然后用代码托管平台的工具针对 <base-branch> 创建拉取/合并请求 —— 有 CLI 就用 CLI,或者用推送时大多数托管平台会打印出的创建 URL —— 如果仓库里有 PR 模板和约定就照着走,并把 URL 报告给你的人类搭档。

保留工作树 —— 你的人类搭档会在那里根据 PR 反馈迭代。

### 选项 3:原样保留

报告:"保留分支 <name>。工作树已保留在 <path>。"

### 如果你的人类搭档要求丢弃这份工作

这条路径只作为对"把这份工作扔掉"这一明确请求的回应而存在。先确认:

```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

等待那个确切的确认。当它到来时:

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
```

然后清理工作树(第 6 步)并强制删除分支:

```bash
git branch -D <feature-branch>
```

## 第 6 步:清理工作空间

**在选项 1 和已确认的丢弃时运行。** 选项 2 和选项 3 总是保留工作树。这两种调用方都已经切换目录到主仓库根目录 —— 移除工作树必须在工作树之外运行 —— 并使用第 2 步(那次切目录之前)捕获的 `GIT_DIR`/`GIT_COMMON`/`WORKTREE_PATH` 的值。

**如果 `GIT_DIR == GIT_COMMON`:** 普通仓库,没有工作树需要清理。完成。

**如果 `WORKTREE_PATH` 在 `.worktrees/` 或 `worktrees/` 之下:** 这个工作树是 dmon-tdd-engineering 创建的 —— 清理归我们管:

```bash
git worktree remove "$WORKTREE_PATH"
git worktree prune  # 自愈:清理掉任何过期的注册记录
```

**如果删除被拒绝**(`contains modified or untracked files`):这个工作树里有只存在于此处的文件——未提交的计划、笔记或临时工作。绝不要擅自使用 `--force`。把风险展示给你的人类搭档并询问:

```bash
git -C "$WORKTREE_PATH" status --porcelain -uall
```

```
Worktree removal refused — these files were never committed:

<file list>

1. Commit them to <branch> before cleanup
2. Move them into <main repo root>
3. Delete them (unrecoverable)

Which?
```

按选择执行,然后再删除工作树。

**否则:** 宿主环境拥有这个工作空间 —— 原地保留。如果你的平台提供了退出工作空间的工具,就用它。

## 快速参考

| 选项 | 合并 | 推送 | 保留工作树 | 清理分支 |
|--------|-------|------|---------------|----------------|
| 1. 本地合并 | 是 | - | - | 是 |
| 2. 创建 PR | - | 是 | 是 | - |
| 3. 原样保留 | - | - | 是 | - |
| 丢弃(仅在明确请求时) | - | - | - | 是(强制) |

## 常见的自我合理化

| 借口 | 现实 |
|--------|---------|
| "这次会话早些时候测试就过了" | 在你即将整合的那棵树上跑一遍套件。全绿只能证明它跑过的那棵树。 |
| "他们显然想要合并" | 整合是你的人类搭档的决定。给出菜单然后等待。 |
| "他们看起来对这个特性没别的想法了 —— 我来主动提议丢弃" | 菜单就是原样这么写的、已经完整。丢弃只在你的人类搭档明明白白开口要求时才发生。 |
| "'嗯,把它删了吧'算作确认了" | 只有键入 `discard` 这个词才授权删除。 |
| "PR 已经建好了,所以工作树现在是碍事的杂物了" | PR 反馈是在那个工作树里修的。它会一直留到工作落地为止。 |
| "另一个工作树看起来过期了 —— 我顺手也清了它" | 只清理 `.worktrees/` 或 `worktrees/` 之下的工作树。其余的都归宿主所有。 |
| "删除被拒绝了——用 `--force` 只是把清理做完" | 拒绝意味着有文件只存在于这个工作树。`--force` 会永久销毁它们。展示给你的人类搭档并询问。 |
| "合并结果的失败大概是偶发的" | 合并结果失败会让一切停下。分支和工作树原地不动,你去排查。 |
| "基分支明摆着就是 main" | 确认分叉点或者问一句。合并进错误的基分支,撤销代价很大。 |
| "推送被拒了 —— force-push 能解决" | 推送被拒意味着远端动过了。去排查;只在你的人类搭档明确请求时才 force-push。 |
