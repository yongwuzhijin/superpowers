# Hermes Agent 工具映射

技能描述的是动作(“派发子 Agent”“创建 todo”“读取文件”)。在 Hermes Agent 上,这些动作对应下列工具。

## 工具

| 技能要求的动作 | Hermes 工具 |
|---|---|
| 读取文件 | `read_file` |
| 创建新文件 | `write_file` |
| 编辑文件(定向补丁) | `patch` |
| 运行 shell 命令 | `terminal` |
| 搜索文件内容 | `search_files` |
| 按名称查找文件 | 通过 `terminal` 运行 `find` |
| 获取 URL / 读取网页 | `web_extract(urls=[...])` |
| 搜索网页 | `web_search(query=...)` |
| 派发子 Agent | `delegate_task(goal=..., context=..., toolsets=[...], role="leaf")` |
| 任务追踪 | `todo` 工具 |
| 调用技能 | `skill_view("skill-name")` |

## 指令文件

当技能提到“你的指令文件”时,在 Hermes Agent 中指项目目录里的 **`AGENTS.md`**,或全局的 **`~/.hermes/SOUL.md`**。

## 调用技能

Hermes Agent 提供带有 `skill_view` 和 `skills_list` 工具的 `skills` 工具集。调用 Superpowers 技能时使用:

```
skill_view("brainstorming")
skill_view("test-driven-development")
```

如果 `skill_view` 找不到某个 Superpowers 技能(插件完全注册之前,它可能不会出现在目录中),就退回到直接读取对应的 SKILL.md:

```
read_file(path="~/.hermes/plugins/superpowers/skills/<skill-name>/SKILL.md")
```

这个兜底机制与其他没有原生技能加载能力的运行环境相同。

## 派发子 Agent

使用 `delegate_task` 为并行或顺序工作流创建相互隔离的子 Agent:

```
delegate_task(goal="...", context="...", toolsets=[...], role="leaf")
```

如果 `delegate_task` 不可用,就在当前会话中完成工作,不要虚构工具调用。

## 任务追踪

在单个会话中使用 `todo` 工具追踪任务。多 Agent 任务看板可使用 `hermes kanban` CLI(如果可用)。把旧的 `TodoWrite` 引用理解为任务追踪动作。
