## 派发子 Agent 需要多 Agent 支持

在你的 Codex 配置(`~/.codex/config.toml`)里加上:

```toml
[features]
multi_agent = true
```

这会启用 `spawn_agent`、`wait_agent` 和 `close_agent`,供 `dispatching-parallel-agents` 和 `subagent-driven-development` 这类技能使用。使用 subagent-driven-development 时,当实现者和评审者子 Agent 完成全部工作后,你应当始终关闭它们。

## 环境检测

创建 worktree 或收尾分支的技能,应当在动手之前用只读的 git 命令检测自己所处的环境:

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

- `GIT_DIR != GIT_COMMON` → 已经在一个链接的 worktree 里(跳过创建)
- `BRANCH` 为空 → 分离头指针(detached HEAD)状态(无法从沙箱里建分支/推送/开 PR)

关于每个技能如何使用这些信号,参见 `using-git-worktrees` 的 Step 0 和 `finishing-a-development-branch` 的 Step 1。

## Codex App 收尾

当沙箱阻止建分支/推送操作时(在外部托管的 worktree 里处于分离头指针状态),Agent 会提交所有工作,并告知用户改用 App 的原生控件:

- **"Create branch"** —— 命名分支,然后通过 App UI 提交/推送/开 PR
- **"Hand off to local"** —— 把工作转交到用户的本地检出

Agent 仍然可以运行测试、暂存文件,并输出建议的分支名、提交信息和 PR 描述,供用户复制。
