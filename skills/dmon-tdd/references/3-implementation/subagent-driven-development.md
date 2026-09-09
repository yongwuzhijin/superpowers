---
name: subagent-driven-development
description: 在当前会话中执行由若干相互独立任务组成的实现计划时使用
---

# Subagent-Driven Development

执行计划的方式:每个任务派一个全新的实现者子 Agent 去做,每做完一个任务就做一次任务评审(是否符合 spec + 代码质量),最后再对整条分支做一次全面评审。

**为什么用子 Agent:** 你把任务委派给上下文相互隔离的专职 Agent。通过精心设计它们的指令和上下文,你能确保它们专注并成功完成任务。它们绝不应该继承你这个会话的上下文或历史——你要精确地为它们构造出所需的一切。这样做还能把你自己的上下文留给协调工作。

**核心原则:** 每个任务一个全新的子 Agent + 任务评审(spec + 质量) + 最后的全面评审 = 高质量、快迭代

**旁白(Narration):** 工具调用之间,至多说一句简短的话——账本(ledger)和工具结果本身就是记录。

**持续执行:** 任务之间不要停下来跟你的人类搭档确认。把计划里的所有任务一口气执行完,不要停。只有下面明确列出的四种情况,或所有任务完成时才停。"要我继续吗?"这类询问和进度小结都是在浪费他们的时间——他们让你执行计划,那就执行。

**做裁决,不要停摆。** 正在执行的计划不等待人类。冲突、歧义、计划缺陷、原本需要请示才能突破的轮次上限——由你决定。spec 是约束性权威,计划是对 spec 的论证;两者都没给答案时,由你的判断定夺。把每个决定按 `Ruling: <你的决定> — <理由> — <如果错了会付出什么代价>` 记入账本,然后继续。错误裁决带来的返工对人类搭档可见、也可撤销;会话停在问题上会浪费他们一整天,却换不来任何东西。

只有四类事情会让你停下:不可逆或破坏性操作;安全敏感操作;按惯例需要先询问、且会影响此工作树之外的副作用(合并、推送到共享分支、发布);以及计划坏到每条前进路线都只能靠猜。遇到这些才停下来询问。

## 何时使用

```dot
digraph when_to_use {
    "Have implementation plan?" [shape=diamond];
    "Tasks mostly independent?" [shape=diamond];
    "Stay in this session?" [shape=diamond];
    "subagent-driven-development" [shape=box];
    "executing-plans" [shape=box];
    "Manual execution or brainstorm first" [shape=box];

    "Have implementation plan?" -> "Tasks mostly independent?" [label="yes"];
    "Have implementation plan?" -> "Manual execution or brainstorm first" [label="no"];
    "Tasks mostly independent?" -> "Stay in this session?" [label="yes"];
    "Tasks mostly independent?" -> "Manual execution or brainstorm first" [label="no - tightly coupled"];
    "Stay in this session?" -> "subagent-driven-development" [label="yes"];
    "Stay in this session?" -> "executing-plans" [label="no - parallel session"];
}
```

**对比 Executing Plans(并行会话):**
- 同一个会话(无需切换上下文)
- 每个任务一个全新的子 Agent(不污染上下文)
- 每个任务做完后评审(是否符合 spec + 代码质量),最后做一次全面评审
- 迭代更快(任务之间无需人工介入)

## 流程

```dot
digraph process {
    rankdir=TB;

    subgraph cluster_per_task {
        label="Per Task";
        "Dispatch implementer subagent (./implementer-prompt.md)" [shape=box];
        "Implementer asks questions?" [shape=diamond];
        "Answer questions, provide context" [shape=box];
        "Implementer implements, tests, commits, self-reviews" [shape=box];
        "Generate review package, dispatch task reviewer (./task-reviewer-prompt.md)" [shape=box];
        "Spec ✅ and quality approved?" [shape=diamond];
        "Finding conflicts with plan text?" [shape=diamond];
        "Rule on the conflict, ledger the ruling" [shape=box];
        "Fix round R of 5: R≤3 resume implementer; R≥4 fresh implementer, more capable model" [shape=box];
        "Dispatch scoped re-review (./re-review-prompt.md)" [shape=box];
        "All findings addressed?" [shape=diamond];
        "R = 5?" [shape=diamond];
        "Adjudicate each open finding" [shape=box];
        "Any load-bearing finding?" [shape=diamond];
        "Rule and continue; stop only if every path forward is a guess" [shape=box];
        "Park findings in ledger with rulings" [shape=box];
        "Append completion to ledger, mark todo complete" [shape=box];
    }

    "Setup: worktree, ledger check, read plan, pre-flight review" [shape=box];
    "More tasks remain?" [shape=diamond];
    "Dispatch final code reviewer (../5-review/code-reviewer.md)" [shape=box];
    "Final findings? ONE fix dispatch, one scoped re-review, adjudicate residuals" [shape=box];
    "Final review clean: delete this plan's workspace" [shape=box];
    "Use ../6-finishing/finishing-a-development-branch.md" [shape=box style=filled fillcolor=lightgreen];

    "Setup: worktree, ledger check, read plan, pre-flight review" -> "Dispatch implementer subagent (./implementer-prompt.md)";
    "Dispatch implementer subagent (./implementer-prompt.md)" -> "Implementer asks questions?";
    "Implementer asks questions?" -> "Answer questions, provide context" [label="yes"];
    "Answer questions, provide context" -> "Implementer implements, tests, commits, self-reviews";
    "Implementer asks questions?" -> "Implementer implements, tests, commits, self-reviews" [label="no"];
    "Implementer implements, tests, commits, self-reviews" -> "Generate review package, dispatch task reviewer (./task-reviewer-prompt.md)";
    "Generate review package, dispatch task reviewer (./task-reviewer-prompt.md)" -> "Spec ✅ and quality approved?";
    "Spec ✅ and quality approved?" -> "Append completion to ledger, mark todo complete" [label="yes"];
    "Spec ✅ and quality approved?" -> "Finding conflicts with plan text?" [label="no"];
    "Finding conflicts with plan text?" -> "Rule on the conflict, ledger the ruling" [label="yes"];
    "Rule on the conflict, ledger the ruling" -> "Fix round R of 5: R≤3 resume implementer; R≥4 fresh implementer, more capable model";
    "Finding conflicts with plan text?" -> "Fix round R of 5: R≤3 resume implementer; R≥4 fresh implementer, more capable model" [label="no"];
    "Fix round R of 5: R≤3 resume implementer; R≥4 fresh implementer, more capable model" -> "Dispatch scoped re-review (./re-review-prompt.md)";
    "Dispatch scoped re-review (./re-review-prompt.md)" -> "All findings addressed?";
    "All findings addressed?" -> "Append completion to ledger, mark todo complete" [label="yes"];
    "All findings addressed?" -> "R = 5?" [label="no"];
    "R = 5?" -> "Fix round R of 5: R≤3 resume implementer; R≥4 fresh implementer, more capable model" [label="no - next round"];
    "R = 5?" -> "Adjudicate each open finding" [label="yes - breaker trips"];
    "Adjudicate each open finding" -> "Any load-bearing finding?";
    "Any load-bearing finding?" -> "Rule and continue; stop only if every path forward is a guess" [label="yes"];
    "Any load-bearing finding?" -> "Park findings in ledger with rulings" [label="no"];
    "Park findings in ledger with rulings" -> "Append completion to ledger, mark todo complete";
    "Append completion to ledger, mark todo complete" -> "More tasks remain?";
    "More tasks remain?" -> "Dispatch implementer subagent (./implementer-prompt.md)" [label="yes"];
    "More tasks remain?" -> "Dispatch final code reviewer (../5-review/code-reviewer.md)" [label="no"];
    "Dispatch final code reviewer (../5-review/code-reviewer.md)" -> "Final findings? ONE fix dispatch, one scoped re-review, adjudicate residuals";
    "Final findings? ONE fix dispatch, one scoped re-review, adjudicate residuals" -> "Final review clean: delete this plan's workspace";
    "Final review clean: delete this plan's workspace" -> "Use ../6-finishing/finishing-a-development-branch.md";
}
```

## 准备工作(Setup)

确保工作发生在一个隔离的工作空间里:用 `../shared/using-git-worktrees.md` 创建一个,或核实已有的那个。没有你人类搭档的明确同意,绝不要在 main/master 分支上开始实现。

对话记忆熬不过压缩(compaction)。在真实会话里,丢失了自己进度位置的控制器(controller)曾经把整段已经完成的任务序列又重新派发了一遍——这是观测到的代价最高的失败。用一个账本(ledger)文件来追踪进度,而不是只靠 todos。

- 每个计划各自拥有一个工作空间:在技能开始时,运行本技能的 `scripts/sdd-workspace PLAN_FILE`——它会打印出该计划专属的、被 git 忽略的目录(`<repo-root>/.superpowers/sdd/<plan-basename>/`),这里存放着**这个**计划的所有产物:账本、任务简报(brief)、报告、评审包(review package)。别的计划的目录永远轮不到你去读或写。
- 到 `<workspace>/progress.md` 检查这个计划的账本。如果它的第一行写的是你的计划文件,那么带有 `Task <N>: complete` 这一行的任务就是 DONE 了——别再重新派发它们;从第一个没有这行的任务处续跑。如果一个任务的最后一行是某个修复轮次(fix round),说明它正处于循环中途:从下一轮开始接着跑这个循环。如果一个账本的第一行写的是另一个计划文件——或者在旧的扁平路径 `.superpowers/sdd/progress.md` 处有个游离的账本——那是别的计划的进度:原样留着,自己重新起一个新的。
- 创建账本时,把它的身份写在第一行:`# SDD ledger — plan: <plan file path>`。
- 账本就是你的恢复地图:它记下的那些提交(commit)确实存在于 git 里,哪怕你的上下文已经不记得创建过它们。压缩之后,相信账本和 `git log`,别信自己的记忆。
- `git clean -fdx` 会摧毁这个工作空间(它是被 git 忽略的临时草稿区);万一发生了,从 `git log` 恢复。

把计划从头到尾读一遍,记下它的上下文和 Global Constraints(全局约束),并为每个任务建一个 todo。如果计划标明了 Spec,也要读它:spec 是约束性权威,计划是对 spec 的论证,计划内部的冲突要依据 spec 解决。找不到 plan 所指向的 spec 时,在账本中注明——没有 spec 支撑的裁决都只是暂定。

在派发 Task 1 之前,先把计划整体扫一遍找冲突,边检查边写下检查结果:

- 相互矛盾的任务,或与计划的 Global Constraints 矛盾的任务
- 计划明确要求、但评审标尺(rubric)会判定为缺陷的东西(比如一个什么都不断言的测试、逐字重复的逻辑块)

扫描结果必须是一张表,而不是一句结论。任何两个共享文件或接口的任务都要有一行:列出这两个任务、一个产出了什么、另一个消费了什么,以及你的检查结果。每个任务也都要有一行:它自身的描述是否一致——指定的测试是否匹配指定的代码、创建的文件是否匹配后续要修改的文件。只说“扫描干净”却没有这些行,就等于没有真正扫描。

把表写进账本。执行开始前,对发现的每个问题作出裁决——把发现和强制它的计划原文放在一起判断——并把每条裁决记入账本。如果扫描干净,不用吭声直接往下走。对扫描发现的每个冲突都作出裁决——spec 是约束性权威,计划是其论证——把裁决记在对应行旁边,然后派发 Task 1。评审循环仍然是那些只有在实现中才会浮现的冲突的兜底网。

## 模型选择

用能胜任每个角色的最弱的模型,以节省成本、提升速度。

**机械性的实现任务**(孤立的函数、清晰的 spec、1-2 个文件):用又快又便宜的模型。当计划写得足够明确时,大多数实现任务都是机械性的。

**集成与需要判断的任务**(多文件协调、模式匹配、调试):用标准模型。

**架构与设计任务**:用可用的最强模型。最后那次针对整条分支的评审就属于这一类——用可用的最强模型去派发它,而不是会话的默认模型。

**评审任务**:挑一个具备同等判断力的模型,并按 diff 的规模、复杂度和风险来缩放。一个小的机械性 diff 不需要最强的模型;一个微妙的并发改动则需要。对小修复 diff 的范围受限复审(scoped re-review)用便宜到中档的模型即可。

**修复循环的升级(第 4-5 轮)**:用一个至少比卡住的那个实现者高一档的模型(按模型选择规则)。

**派发子 Agent 时永远显式指定模型。** 省略模型会继承你会话的模型——往往是最强也最贵的那个——这会悄无声息地让本节的努力落空。

**轮次数比 token 单价更要紧。** 墙钟时间和上下文成本会随着子 Agent 花的轮次数增长,而最便宜的模型在多步骤工作上动辄多花 2-3 倍的轮次——总账反而更贵。把中档模型作为评审者、以及从散文描述出发工作的实现者的下限。当任务的计划原文里已经包含了要写的完整代码时,实现就是誊写加测试:这种实现者用最便宜的档。单文件的机械性修复也用最便宜的档。

**任务复杂度信号(实现任务):**
- 触及 1-2 个文件、spec 完整 → 便宜模型
- 触及多个文件、有集成方面的顾虑 → 标准模型
- 需要设计判断或对代码库的广泛理解 → 最强模型

## 任务循环

**把同形的小任务批量派发。** 当计划列出多个彼此独立、类型相同的小改动——例如在多个文件里重复同样的一行修复、常量修改或字段添加——不要每个任务派一个子 Agent。组合成**一份**派发简报,列出每个文件及其改动,交给同一个子 Agent,并把整个 diff 作为一个单元评审。只有需要独立判断、独立测试或独立评审面的工作,才坚持一个任务一次派发。

你粘进派发提示词里的一切——以及子 Agent 打印回来的一切——都会在这次会话余下的时间里常驻你的上下文,并在之后每一轮里被重新读取。把产物以文件形式交接。

**等待已派发的子 Agent:** 绝不要用很短的超时轮询等待接口,也不要陷入一次安静且无期限的等待。只要还有本地工作——更新账本、准备下一个评审包、阅读报告——就继续做;子 Agent 的结果会自行到达。真正空闲时,用有界的长等待(平台允许时为五到十分钟),每段等待之间发一行状态,并核对活跃子 Agent:列出它们,追查任何已经完成却没有汇报的子 Agent。有界长等待保留了长等待几乎全部的效率,同时保证卡住或丢失的子 Agent 会在几分钟内被发现,而不是拖到会话末尾。

### 1. 派发实现者

派发前记下 BASE(`git rev-parse HEAD`)——评审包和修复轮次的 diff 都需要它。

- **任务简报(Task brief):** 派发实现者之前,运行本技能的 `scripts/task-brief PLAN_FILE N`——它会把该任务的完整原文抽取到一个唯一命名的文件里并打印路径。组织派发内容时,让简报保持为需求的唯一来源。你的派发应包含:(1) 一行说明这个任务在整个项目里处于什么位置;(2) 简报路径,并这样引入它——"先读这个——它就是你的需求,里面有要逐字使用的确切值";(3) 早先任务里定下的、简报无从知晓的接口和决策;(4) 你对简报里注意到的任何歧义的处理决定;(5) 报告文件路径和报告约定。确切的值(数字、magic string、签名、测试用例)只出现在简报里。永远不要让子 Agent 去读整个计划文件。
- **报告文件(Report file):** 实现者的报告文件按简报来命名(简报 `…/task-N-brief.md` → 报告 `…/task-N-report.md`),并写进派发提示词里。实现者把完整报告写在那里,只返回状态、提交、一行测试小结和顾虑。
- 一份派发提示词只描述一个任务,不是会话的历史。别把累积的前序任务小结("Tasks 1-3 之后的状态")粘进后面的派发里——真实会话里有一次派发达到了 42k 字符,其中 99% 是粘贴进去的历史。一个全新的子 Agent 需要的是它的任务、它要触及的接口,以及全局约束。别的都不要。
- 派发内容带有“不派发子 Agent”的约定(它已经写在实现者模板中):实现者绝不再派子 Agent——不派助手,更不能派评审者。评审由你在收到报告后派发。真实会话中,实现者自己派出的每个评审者都重复了控制器本来就会派发的任务评审——每个任务白白多花一个完整评审席位。
- 如果早先某个任务把一条发现停放(park)在了这个任务要触及的区域,就在派发里带上指向那条账本条目的指针。
- 从派发结果里记下实现者的 Agent 身份——修复循环的第 1-3 轮要恢复(resume)这个 Agent。
- 永远不要并行派发多个实现子 Agent(会冲突)。

模板:[implementer-prompt.md](implementer-prompt.md)

### 2. 处理报告

实现子 Agent 会报告四种状态之一。分别妥善处理:

**DONE:** 生成评审包(`scripts/review-package PLAN_FILE BASE HEAD`,在本技能目录下运行——它会打印它写入的那个唯一文件路径;BASE 是你在派发实现者之前记下的那个提交——绝不要用 `HEAD~1`,那会悄无声息地丢掉一个多提交任务里除最后一次以外的所有提交),然后用打印出的路径派发任务评审者。

**DONE_WITH_CONCERNS:** 实现者完成了工作但标记了疑虑。往下走之前先读这些顾虑。如果顾虑关乎正确性或范围,评审前先处理掉。如果只是观察(比如"这个文件越来越大了"),记下来然后继续去评审。

**NEEDS_CONTEXT:** 实现者需要没被提供的信息。补上缺失的上下文并重新派发。

**BLOCKED:** 实现者无法完成任务。评估这个阻塞:
1. 如果是上下文问题,提供更多上下文,用同一个模型重新派发
2. 如果任务需要更多推理,换更强的模型重新派发
3. 如果任务太大,拆成更小的块
4. 如果是计划本身错了,对修正方案作出裁决、记入账本,并把裁决带入重新派发

**绝不要**忽略一次上报,也不要在不做任何改变的情况下逼同一个模型重试。如果实现者说它卡住了,那就有什么东西必须变。

如果实现者提问——无论是开始前还是任务中途——都清楚、完整地回答,需要就补充上下文,别急着把它推去实现。

### 3. 评审任务

每个任务的评审是任务范围内的关卡(gate)。全面评审只发生一次,在最后针对整条分支的评审里。永远不要跳过任务评审,也永远不要接受一份缺了任一裁决的报告——是否符合 spec **和**任务质量,两者都是必需的。实现者的自评永远替代不了任务评审;两者都需要。

- 把 diff 以文件形式交给评审者:运行本技能的 `scripts/review-package PLAN_FILE BASE HEAD`,把它打印出的文件路径传给评审者(或者,没有 bash 时:对该范围执行 `git log --oneline`、`git diff --stat` 和 `git diff -U10`,重定向到一个唯一命名的文件里)。这些输出永远不会进入你自己的上下文,而评审者只需一次 Read 调用就能看到提交列表、stat 摘要和带上下文的完整 diff。用你在派发实现者之前记下的那个 BASE——绝不要用 `HEAD~1`,那会悄无声息地截断多提交任务。永远不要在没有 diff 文件的情况下派发任务评审者。
- **评审者的输入:** 任务评审者拿到三个路径——同一个简报文件、报告文件和评审包——外加约束这个任务的全局约束。
- 你交给评审者的那段全局约束块就是它的注意力透镜。把约束性要求从计划的 Global Constraints 章节或 spec 里逐字抄过来:确切的值、确切的格式,以及各组件之间被言明的关系("与 X 布局相同"、"和 Y 匹配")。评审者的模板本身已经带了流程规则(YAGNI、测试卫生、评审方法)——约束块是给**这个**项目的 spec 所要求的东西。
- 别加"检查所有用到的地方"或"有用的话就跑竞态测试"这类没有具体、任务专属理由的开放式指令
- 别让评审者去重跑实现者已经在同一份代码上跑过的测试——实现者的报告已经带着测试证据
- 别替评审者预判发现——永远不要指示评审者忽略或不要标记某个具体问题。如果你觉得某条发现会是误报,让评审者提出来,在评审循环里去裁决它。如果你正在写的提示词里含有"不要标记"、"别把 X 当缺陷"、"顶多算 Minor"或"计划选择了"——停:你在预判,通常是为了替自己省掉一个评审循环。

任务评审者可能会报告"⚠️ 无法从 diff 验证"的条目——那些活在未改动代码里、或跨任务的需求。这些不阻塞评审的其余部分,但你必须在标记任务完成前逐条自己解决:你手里有计划和跨任务上下文,而评审者没有。如果你确认某条确实是真的缺口,就当成一次失败的 spec 评审——它和其他发现一起进入修复循环。

模板:[task-reviewer-prompt.md](task-reviewer-prompt.md)

### 4. 修复循环

当评审报告 spec ❌、任何 Critical 或 Important 发现,或一条你已确认为真实缺口的 ⚠️ 条目时,循环触发。

在循环开始前,有两条路径能让它立刻离开:

- 边走边把 Minor 发现记进进度账本里(`Task <N>: minor (deferred): <one-liner>`),并让最后的全面评审指向那份清单,好让它分诊(triage)出哪些必须在合并前修掉。一份没人读的汇总就是一次无声的丢弃。Minor 发现永远不进入循环。
- 一条被标为 plan-mandated(计划强制)的发现——或者任何与计划原文所要求的东西相冲突的发现——由你裁决:依据作为约束性权威的 spec,权衡发现和计划原文,在行动前作出决定并记入账本。别因为计划强制就把这条发现打发掉,也别在没有已记录裁决的情况下派发一个与计划相冲突的修复。

其他所有东西都进入循环。一个修复轮次 = 一次修复派发加一次范围受限的复审。每个任务最多五轮:

**第 1-3 轮——恢复原来的实现者。** 把开放的发现逐字发给它。它的上下文是完整的:它知道任务、代码,以及自己做过的选择。如果你的运行环境没法给一个活着的子 Agent 再发一条消息,那就派发一个全新的实现者,带上简报路径、报告文件路径和这些发现——无论哪种方式,报告文件都是那份持久记忆。

**第 4-5 轮——在更强的模型上派发一个全新的实现者**(按模型选择规则),带上简报路径、报告文件路径、开放的发现,以及这样一段框定:"此前有个实现者尝试了这个任务 [N] 次;现在它归你了。读报告文件了解都试过什么。" 一个能扛过三次恢复的循环,通常意味着实现者看不见自己的问题——一步到位地换新视角加提升能力。

**每一轮,无论哪种方式:** 实现者做修复、重跑覆盖被改代码的测试、把它的修复报告追加到同一个报告文件里,并返回那份简短约定。在重新派发评审者之前,确认修复报告里含有覆盖用的测试、跑的命令和输出;三样都齐了才派发复审。在修复消息里点名覆盖用的测试文件——一个单行修复不需要跑整个测试套件。

**复审是范围受限的。** 运行 `scripts/review-package PLAN_FILE FIX_BASE HEAD`,其中 FIX_BASE 是上一次评审看到的那个 head,并用 [re-review-prompt.md](re-review-prompt.md) 派发,附上发现清单、简报、报告文件和打印出的 diff 路径。复审者对每条发现给出 ADDRESSED 或 NOT ADDRESSED 的裁决,并只在修复 diff 里标记新的破坏。修复 diff 里新出现的 Critical/Important 破坏加入开放发现清单。范围之外的观察作为延后的 minor 进入账本——它们永远不延长循环。

**每一轮之后**,追加到账本:
`Task <N>: fix round <R>/5 (<X> addressed, <Y> open — <finding one-liners>; commits <a7>..<b7>)`

永远不要在控制器会话里自己修复发现——你的上下文要保持干净以做协调,而且控制器的修复会跳过评审。

**断路器(The breaker)。** 当第 5 轮的复审仍留有开放发现时,停止派发。逐条自己裁决每一条开放发现——你手里有计划和跨任务上下文,而评审者没有:

- **评审者错了,或者这一点可争议:** 停放它——`Task <N>: parked — <finding> — Ruling: <why the code stands>`。最后的评审能看到双方。
- **是真的,但下游没有东西建立在它之上:** 同样停放它,附一条裁决说明它是真的但已延后。
- **是真的且承重(load-bearing)**——后面某个任务建立在它之上,或者它暴露了一个计划缺陷:裁定能解除下游阻塞的最小改动,并按 `Task <N>: Ruling: <finding> — <what you decided and why>` 记入账本,再把它带进下一个任务的派发。静默停放一个结构性失败,会让每一个依赖它的任务都建立在它之上。只有当该缺陷让每条前进路线都只能靠猜时才停下。

只在达到上限时才裁决。为了结束一个循环而提早裁决,只是换了个名字的预判。每一次裁决都是一条账本条目——无声的丢弃是被禁止的。

### 5. 完成任务

当评审干净地回来时——或者在上限处每一条开放发现都已停放并附裁决时——把完成行和你其他的记账一起,在同一条消息里追加到账本:

- `Task <N>: complete (commits <base7>..<head7>, review clean)`
- 断路器跳闸之后:`Task <N>: complete (commits <base7>..<head7>, <K> parked)`

然后把这个 todo 标记完成,继续下一个。当评审还有既没被修复、也没在上限处停放并附裁决的开放 Critical/Important 问题时,永远不要转去下一个任务。

## 最终评审

最后那次针对整条分支的评审也拿到一个包:运行 `scripts/review-package PLAN_FILE MERGE_BASE HEAD`(MERGE_BASE = 分支起始的那个提交,例如 `git merge-base main HEAD`),并把打印出的路径包含进最终评审的派发里,这样最终评审者读一个文件就好,而不用再用 git 命令重新推导分支 diff。在可用的最强模型上派发(见模型选择),使用 `../5-review/requesting-code-review.md` 的 [code-reviewer.md](../5-review/code-reviewer.md)。让它指向账本里的 deferred-minor 和 parked 这些行,好让它分诊出哪些必须在合并前修掉。

如果最后针对整条分支的评审返回了发现,用完整的发现清单派发**一个**修复子 Agent——不是每条发现派一个修复者。逐条发现的修复者各自都要重建上下文、重跑套件;真实会话里一次最终评审的修复浪潮,花费超过了它所有任务的总和。然后只跑一次范围受限的复审来审这波修复(对修复范围跑 `scripts/review-package PLAN_FILE FIX_BASE HEAD`,用 [re-review-prompt.md](re-review-prompt.md))。像任务循环的断路器那样裁决任何残留的发现:停放并附裁决,或者对承重发现作出裁决并把决定记入账本。这里只有前述四类情况才会停下。没有第二波修复——残留的承重发现会在 finishing-a-development-branch 呈现选项时浮现给你的人类搭档。

## 收尾(Finish)

删除任何东西之前,收集账本里所有包含 `Ruling:` 的行——执行前裁决、停放发现、断路器裁决,全部都要——并按发生顺序放进最终消息的“我作出的裁决”部分,每条都要说明如果判断错误会付出什么代价。这个清单必须完整:账本里有的裁决,清单里都要有。它是你代替人类搭档所做决定能够传达到他们那里的唯一渠道——他们会阅读并返工任何错误决定。随工作空间一起消失的裁决,就是秘密作出的决定。

当最后针对整条分支的评审干净、且它的修复已合并时,删除这个计划的工作空间(`rm -rf <workspace>`)——现在 git 历史就是记录了。同级目录属于别的计划;别去动它们。

阅读并遵循 `../6-finishing/finishing-a-development-branch.md`。

## 常见的自我合理化

| 借口 | 现实 |
|--------|---------|
| "spec 符合度上差不多够了" | 评审者发现了 spec 缺口 = 没完成。修掉,或者撞到上限去裁决——这是仅有的两个出口。 |
| "我自己修算了,派发太费事" | 控制器的修复会污染你的上下文并跳过评审。恢复实现者。 |
| "再来一轮就收敛了" | 过了上限,轮次不会收敛——这个失败是结构性的。裁决并分流。 |
| "评审者反正总能挑出新毛病" | 范围受限的复审只验证修复;它们没法乱逛。未改动代码上的新发现进账本,不进循环。 |
| "这条发现明显是错的,我把它丢掉" | 你只在上限处裁决,而且每一条裁决都是账本条目。无声的丢弃是被禁止的。 |
| "这个修复很小,跳过复审吧" | 未经评审的修复正是回归缺陷溜进来的方式。每一轮都以一次范围受限的复审结束。 |
| "评审拖慢了循环" | 没有评审的循环只是未经验证的空转。评审是这个循环的刹车和方向盘。 |
| "记账本是额外负担" | 账本才是熬过压缩活下来的东西。没有账本的控制器曾把整段已完成的任务序列重新派发了一遍。 |
| "实现者自己派了评审者——免费多一重保障" | 那是在重复评审同一份 diff;任务评审才是关卡。工作者自行派发评审者是一项需要指出的缺陷,不是严谨。 |

## 工作流示例

```
You: I'm using Subagent-Driven Development to execute this plan.

[Setup: worktree verified]
[Read plan file once: docs/superpowers/plans/feature-plan.md]
[Resolve workspace: scripts/sdd-workspace docs/superpowers/plans/feature-plan.md — no ledger inside, fresh start]
[Create todos for all tasks]

Task 1: Hook installation script

[Run task-brief for Task 1; dispatch implementer with brief + report paths + context]

Implementer: "Before I begin - should the hook be installed at user or system level?"

You: "User level (~/.config/superpowers/hooks/)"

Implementer: [Later]
  - Implemented install-hook command
  - Added tests, 5/5 passing
  - Self-review: Found I missed --force flag, added it
  - Committed

[Run review-package PLAN_FILE BASE HEAD; dispatch task reviewer with the printed path]
Task reviewer: Spec ✅ - all requirements met, nothing extra.
  Strengths: Good test coverage, clean. Issues: None. Task quality: Approved.

[Ledger: Task 1: complete (commits a1b2c3d..d4e5f6a, review clean)]

Task 2: Recovery modes

[Run task-brief for Task 2; dispatch implementer with brief + report paths + context]

Implementer: [No questions]
  - Added verify/repair modes
  - 8/8 tests passing
  - Committed

[Run review-package PLAN_FILE BASE HEAD; dispatch task reviewer with the printed path]
Task reviewer: Spec ❌:
  - Missing: Progress reporting (spec says "report every 100 items")
  Issues (Important): Magic number (100)

[Fix round 1: resume the implementer with both findings]
Implementer: Added progress reporting, extracted PROGRESS_INTERVAL constant.
  Re-ran test/recovery.test.js — 10/10 passing. Fix report appended.

[Run review-package PLAN_FILE FIX_BASE HEAD; dispatch scoped re-review]
Re-reviewer: Missing progress reporting — ADDRESSED (src/recovery.js:41).
  Magic number — ADDRESSED (src/recovery.js:7). New breakage: none.
  Verdict: all findings addressed.

[Ledger: Task 2: fix round 1/5 (2 addressed, 0 open; commits d4e5f6a..b7c8d9e)]
[Ledger: Task 2: complete (commits d4e5f6a..b7c8d9e, review clean)]

...

[After all tasks]
[Run review-package PLAN_FILE MERGE_BASE HEAD; dispatch final code-reviewer, most capable model]
Final reviewer: All requirements met. Deferred minors triaged: none block merge.

[Delete this plan's workspace — the record now lives in git]

Done! Using ../6-finishing/finishing-a-development-branch.md.
```
