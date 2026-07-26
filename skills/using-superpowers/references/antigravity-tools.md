# Antigravity CLI (`agy`) 工具映射

技能是用动作来描述的("派发一个子 Agent"、"创建一条待办"、"读取一个文件")。在 Antigravity CLI(`agy`)上,这些动作会对应到下面这些工具。

| 技能请求的动作 | Antigravity CLI 对应工具 |
|----------------------|----------------------|
| 派发一个子 Agent(`Subagent (general-purpose):` 模板) | `invoke_subagent`,搭配内置的 `TypeName` —— `self` 用于全能力工作,`research` 用于只读工作 |
| 任务追踪("创建一条待办"、"标记完成") | 用一个**任务工件(task artifact)** —— 即 `write_to_file` 并设置 `IsArtifact: true` 和 `ArtifactType: "task"`(见 [任务追踪](#task-tracking))。**不要**用 `manage_task`,它管理的是后台进程。 |

## 任务追踪

Antigravity **没有待办工具**(`manage_task` 管理的是后台进程 ——
`list`/`kill`/`status`/`send_input` —— 它*不是*一个清单)。当某个
技能让你创建待办清单或追踪任务时,请维护一个**任务工件(task artifact)**:一个
用 `write_to_file` 保存的 markdown 清单(`IsArtifact: true`,
`ArtifactMetadata.ArtifactType: "task"`),并随着进展用 `replace_file_content` /
`multi_replace_file_content` 来编辑它。

在任何多步骤任务开始时,创建一个任务工件,列出你计划里的每一个步骤。每完成一步,
就编辑这个工件把它标记为已完成(`- [x]`)。
如果计划有变,就更新清单。让它始终保持最新 —— 它是你判断"还剩什么没做"的事实来源;
一旦对话变长,在开始每一步之前先重新读一遍它。
