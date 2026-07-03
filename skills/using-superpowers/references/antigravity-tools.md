# Antigravity CLI(`agy`)工具映射

技能是用动作来表达的("派发一个子 Agent"、"创建一个 todo"、"读一个文件")。在 Antigravity CLI(`agy`)上,这些动作对应到下面这些工具。

| 技能请求的动作 | Antigravity CLI 对应工具 |
|----------------------|----------------------|
| 派发一个子 Agent(`Subagent (general-purpose):` 模板) | `invoke_subagent`,配一个内置的 `TypeName` —— `self` 用于完整能力的工作,`research` 用于只读(参见 [Subagent support](#subagent-support)) |
| 任务跟踪("创建一个 todo"、"标记完成") | 一个 **task artifact** —— 用 `write_to_file` 且带 `IsArtifact: true` 和 `ArtifactType: "task"`(参见 [Task tracking](#task-tracking))。**不是** `manage_task`,那个是管理后台进程的。 |

## 任务跟踪

Antigravity **没有 todo 工具**(`manage_task` 管理的是后台进程 —— `list`/`kill`/`status`/`send_input` —— 它*不是*清单)。当某个技能说要创建 todo 列表或跟踪任务时,维护一个 **task artifact**:一份 markdown 清单,用 `write_to_file` 保存(`IsArtifact: true`,`ArtifactMetadata.ArtifactType: "task"`),随做随改,用 `replace_file_content` / `multi_replace_file_content` 编辑。

在任何多步任务开始时,创建这份 task artifact,列出你计划里的每一步。每完成一步,就编辑这份 artifact 把它标记为完成(`- [x]`)。如果计划有变,更新清单。保持它是最新的 —— 它是你关于还剩什么没做的唯一可信来源;一旦对话变长,在开始每一步之前重读它。
