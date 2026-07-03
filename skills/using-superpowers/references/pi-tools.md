# Pi 工具映射

技能是用动作来表达的("派发一个子 Agent"、"创建一个 todo"、"读一个文件")。在 Pi 上,这些动作对应到下面这些工具。

| 技能请求的动作 | Pi 对应工具 |
| --- | --- |
| 派发一个子 Agent(`Subagent (general-purpose):` 模板) | 使用一个已安装的子 Agent 工具,比如 `pi-subagents` 里的 `subagent`(如果有的话) |
| 任务跟踪("创建一个 todo"、"标记完成") | 使用一个已安装的 todo/任务工具(如果有的话),否则就在计划里或 `TODO.md` 里跟踪任务 |

## 子 Agent

Pi 核心不自带标准的子 Agent 工具。`pi-subagents` 包是一个很好的可选搭档,它提供了一个 `subagent` 工具,支持单 Agent、链式、并行、异步、fork 上下文以及恢复/查状态等工作流。如果没有可用的子 Agent 工具,不要编造 `Task` 调用;要么在当前会话里顺序执行,要么说明这个可选的子 Agent 能力没有安装。

## 任务清单

Pi 核心不自带标准的任务清单工具。如果安装了某个 todo/任务扩展,就用它文档里说明的工具。否则就用 Superpowers 的计划文件、Markdown 清单,或者仓库本地的 `TODO.md` 来跟踪任务。较早的 Superpowers 文档可能会提到 `TodoWrite`;把它当作上面说的任务跟踪动作即可。
