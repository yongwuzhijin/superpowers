## 派发子 Agent 需要多 Agent 支持

在你的 Codex 配置(`~/.codex/config.toml`)中加入:

```toml
[features]
multi_agent = true
```

这会启用 `dispatching-parallel-agents` 和 `subagent-driven-development` 等技能所需的多 Agent 工具。实际可用的工具取决于模型预设选用的多 Agent 版本(当前预设使用 V2,旧预设使用 V1)。当实际工具列表与任何表格——包括本文——不一致时,以实际工具列表为准。

- **派发:** 使用 `spawn_agent {fork_turns: "none"}` 给子 Agent 一个干净的上下文;默认值 `"all"` 会把完整对话复制给它。在 Codex 0.145 及以上版本中,`~/.codex/agents/` 下的角色文件可通过 `agent_type` 附加到隔离 fork。完整历史 fork 可以接受 `model` 和 `reasoning_effort` 覆盖(只有 `agent_type` 会被拒绝)——SDD 默认使用隔离 fork 是为了保持上下文整洁,不是因为只有隔离 fork 才能覆盖模型。
- **修复轮次:** 使用 `followup_task` 恢复实现者——它会传递消息、触发新一轮,并透明地重新加载被运行环境回收的子 Agent。不要因为认为已派发的 Agent 无法再次接收消息,就另派一个全新实现者;V2 始终支持继续发送。
- **生命周期:** V2 没有 `close_agent`。需要槽位时,已完成的子 Agent 会被自动回收;不手动关闭没有成本。只有 V1 会话拥有 `close_agent`——在 V1 中,评审返回后关闭评审者,每个实现者则在其任务评审通过后关闭。
- **模型名称:** 不要在未核对当前派发白名单的情况下,把技能、表格或旧会话里的模型名复制到 `spawn_agent`;V2 只接受支持 V2 的预设,其他名称会直接报错。

## 等待子 Agent

`wait_agent` 是事件订阅,不是轮询:长时间等待会在子 Agent 产生邮箱活动时立即唤醒,延迟与短等待相同。短超时轮询没有收益,却会在每次轮询时消耗一次工具调用和一次上下文重新计费。实测会话里,大约三分之二的等待调用都是最终超时的短轮询。

- 只要手头还有本地工作,就完全不要等待。子 Agent 完成后的最终答复会推送到你的邮箱,并在你的下一轮到达。
- 当你确实无事可做、但仍有子 Agent 未完成时,用有界的长等待:`wait_agent` 的 `timeout_ms` 设为 300000-600000(5-10 分钟)。每段等待结束后——无论被唤醒还是超时——发一行状态,运行 `list_agents`,并追查任何已经完成但没有汇报的子 Agent。绝不要连续使用短于五分钟的轮询;有界长等待会像短等待一样迅速地被事件唤醒。
- 完成消息无法唤醒空闲的控制器(消息会被投递,但不会触发新一轮);覆盖这段空闲窗口是 `wait_agent` 唯一的职责。一次等待在没有活动时超时,意味着你该核对状态,而不是把下一次等待缩短。

## 派发时的模型路由

你发出的每个 `spawn_agent`——包括你自己作为被派发的子 Agent 再向外扇出时——都要按照当前技能的模型选择规则显式设置 `model` **和** `reasoning_effort`。只设置 `model` 是个陷阱:子 Agent 的推理强度会静默重置为该模型的默认值,而不是继承你的值。

请你的人类搭档在 `~/.codex/config.toml` 中加入机器级兜底,让任何漏设模型的派发仍然落到经过选择的档位,而不是静默继承会话中最昂贵的模型:

```toml
[agents]
default_subagent_model = "<a mid-tier model from your spawn allowlist>"
default_subagent_reasoning_effort = "medium"
```

## 环境检测

创建 worktree 或收尾分支的技能,应该在动手之前用只读的 git 命令检测所处环境:

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

- `GIT_DIR != GIT_COMMON` → 已经在一个关联的 worktree 里(跳过创建)
- `BRANCH` 为空 → 处于分离 HEAD 状态(无法从沙箱里建分支/推送/开 PR)

关于每个技能如何使用这些信号,参见 `../shared/using-git-worktrees.md` 的 Step 0 和 `../6-finishing/finishing-a-development-branch.md` 的 Step 1。

## Codex App 收尾

当沙箱阻止建分支/推送操作时(在一个由外部管理的 worktree 中处于分离 HEAD 状态),Agent 会提交所有工作,并告知用户使用 App 原生的控制项:

- **"Create branch"** —— 给分支命名,然后通过 App UI 提交/推送/开 PR
- **"Hand off to local"** —— 把工作转交到用户的本地检出(checkout)

Agent 仍然可以运行测试、暂存文件,并输出建议的分支名称、提交信息和 PR 描述,供用户复制。
