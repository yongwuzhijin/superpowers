# 范围受限复审提示词模板

在一个修复轮次之后派发复审时使用本模板。复审者核实那些发现是否被处理,并检查修复 diff 有没有新的破坏。它不是一次全新的评审——完整评审已经做过了。

**目的:** 核实上一次评审的每一条发现是否被处理,以及修复本身有没有弄坏什么。

```
Subagent (general-purpose):
  description: "Re-review Task N fix round R"
  model: [MODEL — REQUIRED: choose per subagent-driven-development.md Model Selection; an omitted
         model silently inherits the session's most expensive one]
  prompt: |
    你正在复审一个任务的一个修复轮次。此前一次评审产出了若干发现;一个实现者已尝试修复它们。你的活儿是:对每一条发现下裁决,并检视修复 diff——别的都不干。

    ## 任务

    读任务简报:[BRIEF_FILE]

    ## 待核实的发现

    [FINDINGS]

    ## 修复

    读实现者的报告(修复报告追加在末尾):
    [REPORT_FILE]

    **Fix base:** [FIX_BASE_SHA] (上一次评审看到的那个 head)
    **Head:** [HEAD_SHA]
    **Diff file:** [DIFF_FILE]

    把 diff 文件读一次——它包含修复提交、一份 stat 摘要,以及带周边上下文的修复 diff。不要重跑 git 命令。如果 diff 文件缺失,自己去取 diff:`git diff --stat [FIX_BASE_SHA]..[HEAD_SHA]` 和 `git diff [FIX_BASE_SHA]..[HEAD_SHA]`。

    你的评审在这个 checkout 上是只读的。不要以任何方式改动工作树、索引(index)、HEAD 或分支状态。

    ## 不要派发子 Agent

    这项评审全部由你自己完成。绝不要派子 Agent 去评审部分 diff,也不要另派评审者寻求第二意见。这个流程已经提供了这项工作所需的全部评审席位;你派出的评审者会以完整成本重复其中一次评审,而它的裁决在流程中不作数。如果 diff 太大,一次看不完,就自己分几轮评审,并在报告中说明。

    ## 范围(Scope)

    你的范围是发现清单和修复 diff。对每一条发现下裁决。检视修复 diff,看修复本身引入了什么新问题。**不要**去复审修复没有触及的代码:如果你注意到一个完全在修复 diff 之外的问题,把它报在 Out-of-Scope Observations 下面——它不阻塞这个任务,也不延长循环。一次针对整条分支的全面评审会在所有任务完成后进行。

    ## 测试

    实现者重跑了覆盖被改代码的测试,并把结果追加到了报告文件里。把报告当作未经验证的说辞:确认修复报告点名了覆盖用的测试并展示了它们的输出,并拿这些说辞去对照 diff 验证。不要为了确认他们的报告而重跑套件。只有当阅读代码引出一个现有的任何一次运行都回答不了的具体疑问时,才去跑测试——而且是聚焦测试,绝不是全包级套件。

    ## 输出格式

    你的最终消息就是报告本身:直接从第一条发现的裁决开始。每一行都是一个裁决、一条带 file:line 的发现,或一个你跑过的检查——没有开场白、没有流程旁白。

    ### Finding Verdicts

    对"待核实的发现"里的每一条,按顺序:
    - **[finding one-liner]** — ADDRESSED | NOT ADDRESSED,附 file:line 证据。"尝试过了"不算处理:那个具体的缺陷必须不再存在。

    ### New Breakage in the Fix Diff

    修复本身弄坏或引入的任何东西,附严重级别(Critical/Important/Minor)和 file:line。干净的话写 "None"。

    ### Out-of-Scope Observations

    你注意到的、完全在修复 diff 之外的问题。不阻塞;控制器会把这些记进账本供最终评审用。没有的话写 "None"。

    ### Verdict

    **Fix round:** [All findings addressed, no new Critical/Important
    breakage | Findings remain open] — 列出仍开放的那些。
```

**占位符:**
- `[MODEL]` — REQUIRED:按 `subagent-driven-development.md` 的模型选择规则挑选评审者模型;对小修复 diff 的范围受限复审用便宜到中档的模型即可
- `[BRIEF_FILE]` — 任务简报文件(与实现者所用的是同一个文件)
- `[FINDINGS]` — 上一次评审里的 Critical/Important 发现和 spec 缺口,逐字抄来,每条一个 bullet
- `[REPORT_FILE]` — 实现者的报告文件(修复报告已追加其中)
- `[FIX_BASE_SHA]` — 上一次评审看到的那个 head
- `[HEAD_SHA]` — 当前提交
- `[DIFF_FILE]` — `scripts/review-package PLAN_FILE FIX_BASE HEAD` 打印出的那个路径

**复审者返回:** 逐条发现的裁决(ADDRESSED / NOT ADDRESSED)、修复 diff 里的新破坏、范围之外的观察,以及一个轮次裁决。
