---
name: dmon-tdd
description: dmon 全托管 TDD 开发框架。当用户输入 /dmon-tdd、/dmon-spec、/dmon-plan、/dmon-impl、/dmon-debug、/dmon-review、/dmon-finish 中任一命令，或说出「dmon tdd」「dmon 开发」「全托管开发」「托管开发」「tdd 全托管」时使用。覆盖需求澄清、计划、实现、调试、评审、收尾六个阶段。
---

<SUBAGENT-STOP>
如果你是作为子 Agent 被派来执行某个特定任务的,请忽略本技能。
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
本框架默认不生效。但你现在正在读它,说明它已经被触发了。

从这一刻起,直到本次流程结束:如果你觉得哪怕只有 1% 的可能某个阶段适用于你正在做的事,你就绝对必须进入那个阶段。

只要有阶段适用于你的任务,你就没得选。你必须走它的流程。

这没有商量余地。你不能靠给自己找借口来逃避。
</EXTREMELY-IMPORTANT>

## 阶段路由表

先判断用户处在哪个阶段,然后 Read 对应文件并严格照做。文件路径相对于本文件所在目录。

| 阶段 | 什么时候进 | 读这些文件 |
|---|---|---|
| 1 需求澄清 | 要做任何创造性工作之前——新建功能、搭组件、加能力、改行为 | `references/1-requirement-specify/requirement-specify.md` |
| 2 计划 | 已有 spec 或需求、还没动代码 | `references/2-planning/writing-plans.md` |
| 3 实现 | 已有写好的实施计划要落地 | `references/3-implementation/subagent-driven-development.md`(推荐)或 `references/3-implementation/executing-plans.md` |
| 4 调试 | 碰到任何 bug、测试失败或非预期行为,在提出修复方案之前 | `references/4-debugging/systematic-debugging.md` |
| 5 评审 | 完成任务、实现重要特性,或合并之前 | `references/5-review/requesting-code-review.md`、`references/5-review/receiving-code-review.md`、`references/5-review/verification-before-completion.md` |
| 6 收尾 | 实现完成、测试全过,要决定怎么整合这份工作 | `references/6-finishing/finishing-a-development-branch.md` |

## 横向能力(任何阶段都可能用到)

| 能力 | 什么时候用 | 文件 |
|---|---|---|
| TDD | 实现任何功能或修 bug 时,在写实现代码之前 | `references/shared/test-driven-development.md` |
| 隔离工作区 | 计划确定之后、动手之前 | `references/shared/using-git-worktrees.md` |
| 并行派发 | 面临 2 个以上互不依赖、不共享状态的任务 | `references/shared/dispatching-parallel-agents.md` |

## 全托管流程

用户打 `/dmon-tdd` 或说「全托管开发」时,按 1 → 2 → 3 → 5 → 6 顺序走完;中途遇到 bug 插入阶段 4。**每个阶段结束前必须停下来让你的人类搭档确认,确认过了才能进下一阶段。**

## The Rule(规则)

**在任何回应或行动之前,先进入相关阶段** —— 包括澄清性提问、探索代码库、查看文件。

然后宣布"Using dmon-tdd 阶段 N 来 [目的]",并严格遵循该阶段文件。如果它带有清单,就为每一项创建一个 todo。

## 阶段优先级

当多个阶段都适用时,流程类阶段优先 —— 它们定下方法,然后由实现去落实。

- "我们来做 X" → 先阶段 1(需求澄清),再往下走。
- "修这个 bug" → 先阶段 4(系统化调试),再谈修复。

## 危险信号

下面这些念头意味着停 —— 你在给自己找借口:

| 念头 | 现实 |
|---------|---------|
| "这只是个简单问题" | 问题就是任务。检查该进哪个阶段。 |
| "我得先了解更多背景" | 阶段判断在澄清性提问之前。 |
| "让我先探索一下代码库" | 阶段会告诉你怎么探索。先判断。 |
| "我可以快速看一下 git/文件" | 文件里没有对话背景。先判断该进哪个阶段。 |
| "让我先收集信息" | 阶段会告诉你怎么收集信息。 |
| "这用不着走正式流程" | 只要阶段适用,就走它。 |
| "这个流程我记得" | 流程会演进。读当前版本。 |
| "这算不上一个任务" | 有行动 = 有任务。检查该进哪个阶段。 |
| "这个阶段是杀鸡用牛刀" | 简单的事会变复杂。走它。 |
| "我先做这一件事就好" | 做任何事之前先判断。 |
| "这样感觉很有效率" | 无纪律的行动是浪费时间。流程能防止这一点。 |
| "我知道那是什么意思" | 懂概念 ≠ 走流程。进阶段。 |

## 平台适配

如果你的运行环境(harness)是 Codex,阅读 `references/platform/codex-tools.md` 获取工具名映射。Cursor 与 Claude Code 无需额外映射。

## 产物落盘

- 需求 spec:`docs/dmon/specs/YYYY-MM-DD-<topic>-design.md`(提交进 git)
- 实施计划:`docs/dmon/plans/YYYY-MM-DD-<feature>.md`(提交进 git)
- 执行工作区:`.dmon/sdd/<plan-basename>/`(git 忽略)
- 需求澄清临时文件:`.dmon/brainstorm/`(git 忽略)

## 用户指令

用户指令(CLAUDE.md、AGENTS.md 等,以及直接的请求)优先于本框架,而本框架又覆盖默认行为。只有当你的人类搭档明确要求时,才可以跳过流程。
