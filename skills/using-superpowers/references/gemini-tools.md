# Gemini CLI 工具映射

技能是用动作来描述的("派发一个子 Agent"、"创建一条待办"、"读取一个文件")。在 Gemini CLI 上,这些动作会对应到下面这些工具。

| 技能请求的动作 | Gemini CLI 对应工具 |
|----------------------|----------------------|
| 读取一个文件 | `read_file` |
| 一次读取多个文件 | `read_many_files` |
| 创建一个新文件 | `write_file` |
| 编辑一个文件 | `replace` |
| 运行一条 shell 命令 | `run_shell_command` |
| 搜索文件内容 | `grep_search` |
| 按文件名查找文件 | `glob` |
| 列出文件和子目录 | `list_directory` |
| 拉取一个 URL | `web_fetch` |
| 搜索网络 | `google_web_search` |
| 调用一个技能 | `activate_skill` |
| 派发一个子 Agent(`Subagent (general-purpose):` 模板) | `invoke_agent`,搭配 `agent_name: "generalist"`(可通过 `@generalist` 聊天语法调用 —— 见 [子 Agent 支持](#subagent-support)) |
| 多个并行派发 | 在同一次回复中发起多个 `invoke_agent` 调用 |
| 任务追踪("创建一条待办"、"标记完成") | `write_todos`(状态:pending、in_progress、completed、cancelled、blocked) |

## 指令文件

当某个技能提到"你的指令文件"时,在 Gemini CLI 上指的就是 **`GEMINI.md`**。Gemini CLI 会分层加载 `GEMINI.md`:全局的位于 `~/.gemini/GEMINI.md`,项目级的文件位于工作空间目录及其上级目录中,而当某个工具访问某个目录下的文件时,还会加载该子目录里的 `GEMINI.md`。

## 个人技能目录

用户级技能位于 **`~/.gemini/skills/`**,并以 **`~/.agents/skills/`** 作为跨运行时别名(与 Codex 和 Copilot CLI 共享)。当同一作用域下两个目录都存在时,`.agents/skills/` 优先。每个技能是一个子目录,里面包含一个 `SKILL.md`(带有 `name` 和 `description` frontmatter)。

## 子 Agent 支持

Gemini CLI 通过 `invoke_agent` 工具派发子 Agent,它接收 `agent_name` 和 `prompt` 两个参数。同样的派发也以聊天语法快捷方式的形式暴露出来:输入 `@generalist <prompt>` 等价于用 `agent_name: "generalist"` 调用 `invoke_agent`。内置的 Agent 名称包括 `generalist`、`cli_help`、`codebase_investigator`,以及(在启用浏览器工具时的)`browser_agent`。

技能通过 `Subagent (general-purpose):` 来派发,要么引用一个 prompt 模板文件(例如 `superpowers:subagent-driven-development` 的 `./implementer-prompt.md`),要么提供一段内联 prompt。在 Gemini CLI 上:

| 技能的派发形式 | Gemini CLI 对应做法 |
|---------------------|----------------------|
| 引用了 `*-prompt.md` 模板(implementer、task-reviewer、code-reviewer 等) | 填好模板,然后用 `agent_name: "generalist"` 和填好的 prompt 调用 `invoke_agent` |
| 引用了 `superpowers:requesting-code-review` 的 `./code-reviewer.md` | 用 `agent_name: "generalist"` 和填好的评审模板调用 `invoke_agent` |
| 内联 prompt(没有引用模板) | 用 `agent_name: "generalist"` 和你的内联 prompt 调用 `invoke_agent` |

### 填写 prompt

技能提供的 prompt 模板里带有像 `{WHAT_WAS_IMPLEMENTED}` 或 `[FULL TEXT of task]` 这样的占位符。在把完整 prompt 传给 `invoke_agent` 之前,先填好所有占位符。prompt 模板本身包含了该 Agent 的角色、评审标准和期望的输出格式 —— 子 Agent 会照着它来做。

### 并行派发

Gemini CLI 支持并行派发子 Agent。在同一次回复中发起多个 `invoke_agent` 调用(或在一个 prompt 里发起多个 `@generalist` 调用),就能并行运行相互独立的子 Agent 工作。有依赖关系的任务要保持顺序执行,但不要仅仅为了保留一份更简单的历史记录,就把相互独立的子 Agent 任务串行化。

## Gemini CLI 额外工具

以下这些工具是 Gemini CLI 独有的:

| 工具 | 用途 |
|------|---------|
| `save_memory`(旧版) | 当 `experimental.memoryV2 = false` 时,跨会话持久化事实 |
| `get_internal_docs` | 查阅 Gemini CLI 自带的文档 |
| `ask_user` | 向用户提出结构化的问题(文本 / 单选 / 多选) |
| `enter_plan_mode` / `exit_plan_mode` | 切入和切出只读的计划模式 |
| `update_topic` | 更新当前对话的主题 / 战略意图元数据 |
| `complete_task` | 表示某个 Gemini 子 Agent 已完成,并把它的结果返回给父 Agent |
| `tracker_create_task`、`tracker_update_task`、`tracker_get_task`、`tracker_list_tasks`、`tracker_add_dependency`、`tracker_visualize` | 功能丰富的任务追踪器,支持依赖关系和可视化 |
| `read_mcp_resource`、`list_mcp_resources` | MCP 资源访问 |
