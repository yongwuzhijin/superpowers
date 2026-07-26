## 派发子 Agent 需要多 Agent 支持

在你的 Codex 配置(`~/.codex/config.toml`)中加入:

```toml
[features]
multi_agent = true
```

这会启用 `spawn_agent`、`wait_agent` 和 `close_agent`,供 `dispatching-parallel-agents` 和 `subagent-driven-development` 这类技能使用。使用 subagent-driven-development 时,评审子 Agent 的评审结果一返回就关闭它。每个实现者子 Agent 要一直开着,直到它对应任务的评审通过为止 —— 修复循环会复用这个实现者 —— 之后再关闭它。如果你的运行环境(harness)无法给一个已派发的 Agent 再发消息,那就把每一轮修复当作一个全新的实现者来派发,并附带任务简报、报告文件和评审发现。

## 环境检测

创建 worktree 或收尾分支的技能,应该在动手之前用只读的 git 命令
检测所处环境:

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

- `GIT_DIR != GIT_COMMON` → 已经在一个关联的 worktree 里(跳过创建)
- `BRANCH` 为空 → 处于分离 HEAD 状态(无法从沙箱里建分支/推送/开 PR)

关于每个技能如何使用这些信号,参见 `using-git-worktrees` 的 Step 0
和 `finishing-a-development-branch` 的 Step 1。

## Codex App 收尾

当沙箱阻止建分支/推送操作时(在一个由外部管理的 worktree 中处于分离 HEAD
状态),Agent 会提交所有工作,并告知
用户使用 App 原生的控制项:

- **"Create branch"** —— 给分支命名,然后通过 App UI 提交/推送/开 PR
- **"Hand off to local"** —— 把工作转交到用户的本地检出(checkout)

Agent 仍然可以运行测试、暂存文件,并输出建议的分支
名称、提交信息和 PR 描述,供用户复制。
