---
name: writing-skills
description: 当你要创建新技能、编辑现有技能,或在部署前验证技能是否有效时使用
---

# Writing Skills

## 概述

**写技能,本质上就是把测试驱动开发(TDD)用到流程文档上。**

**个人技能存放在你运行时的 skills 目录里**(Claude Code 上是 `~/.claude/skills/`)——那些运行时上的路径见 [codex-tools.md](../using-superpowers/references/codex-tools.md) 或 [gemini-tools.md](../using-superpowers/references/gemini-tools.md)。Codex、Copilot CLI 和 Gemini CLI 也都把 `~/.agents/skills/` 认作跨运行时的别名。

你先写测试用例(用子 Agent 跑压力场景),看着它们失败(基线行为),写技能(文档),看着测试通过(Agent 遵守了),再重构(堵住漏洞)。

**核心原则:** 如果你没在"没有技能"的情况下亲眼看过 Agent 失败,你就不知道这个技能教的东西对不对。

**必备背景(REQUIRED BACKGROUND):** 用本技能之前,你必须先理解 superpowers:test-driven-development。那个技能定义了基础的 RED-GREEN-REFACTOR 循环。本技能把 TDD 适配到文档上。

**官方指引:** Anthropic 官方的技能编写最佳实践,见 anthropic-best-practices.md。那份文档提供了额外的模式和准则,与本技能中以 TDD 为中心的方法互为补充。

## 什么是技能?

一个**技能**是关于经过验证的技巧、模式或工具的参考指南。技能帮助未来的 Agent 找到并运用有效的方法。

**技能是:** 可复用的技巧、模式、工具、参考指南

**技能不是:** 关于你某一次如何解决某个问题的叙事流水账

## 技能的 TDD 对应关系

| TDD 概念 | 技能创建 |
|-------------|----------------|
| **测试用例** | 用子 Agent 跑的压力场景 |
| **生产代码** | 技能文档(SKILL.md) |
| **测试失败(RED)** | 没有技能时 Agent 违反规则(基线) |
| **测试通过(GREEN)** | 有技能在场时 Agent 遵守 |
| **重构** | 在保持遵守的同时堵住漏洞 |
| **先写测试** | 在写技能之前先跑基线场景 |
| **看它失败** | 记录 Agent 用到的确切说辞 |
| **最小代码** | 写针对那些具体违规行为的技能 |
| **看它通过** | 核实 Agent 现在遵守了 |
| **重构循环** | 找到新说辞 → 堵上 → 再核实 |

整个技能创建过程都遵循 RED-GREEN-REFACTOR。

## 何时创建技能

**在以下情况创建:**
- 这个技巧对你来说并非一眼就能想到
- 你会跨项目反复用到它
- 模式广泛适用(不局限于某个项目)
- 其他人也会受益

**不要为以下情况创建:**
- 一次性的解法
- 别处已有充分文档的标准做法
- 项目特有的约定(放进你的指令文件里)
- 机械性约束(如果能用正则/校验强制执行,就自动化它——把文档留给需要判断的地方)

## 技能类型

### 技巧型(Technique)
带有具体步骤、照着做的方法(condition-based-waiting、root-cause-tracing)

### 模式型(Pattern)
思考问题的方式(flatten-with-flags、test-invariants)

### 参考型(Reference)
API 文档、语法指南、工具文档(office docs)

## 目录结构


```
skills/
  skill-name/
    SKILL.md              # Main reference (required)
    supporting-file.*     # Only if needed
```

**扁平命名空间** - 所有技能都在一个可搜索的命名空间里

**在以下情况用独立文件:**
1. **重量级参考**(100+ 行) - API 文档、完整语法
2. **可复用工具** - 脚本、工具程序、模板

**保持内联:**
- 原则与概念
- 代码模式(< 50 行)
- 其他一切

## SKILL.md 结构

**Frontmatter(YAML):**
- 两个必填字段:`name` 和 `description`(所有支持的字段见 [agentskills.io/specification](https://agentskills.io/specification))
- 总共最多 1024 个字符
- `name`:只用字母、数字和连字符(不要括号、特殊字符)
- `description`:第三人称,只描述何时使用(不描述它做什么)
  - 以 "Use when..." 开头,聚焦于触发条件
  - 包含具体的症状、情境和上下文
  - **绝不概括技能的流程或工作流**(为什么,见 SDO 一节)
  - 尽量保持在 500 个字符以内

```markdown
---
name: Skill-Name-With-Hyphens
description: Use when [specific triggering conditions and symptoms]
---

# Skill Name

## Overview
What is this? Core principle in 1-2 sentences.

## When to Use
[Small inline flowchart IF decision non-obvious]

Bullet list with SYMPTOMS and use cases
When NOT to use

## Core Pattern (for techniques/patterns)
Before/after code comparison

## Quick Reference
Table or bullets for scanning common operations

## Implementation
Inline code for simple patterns
Link to file for heavy reference or reusable tools

## Common Mistakes
What goes wrong + fixes

## Real-World Impact (optional)
Concrete results
```


## 技能发现优化(SDO)

**对被发现至关重要:** 未来的 Agent 需要能"找到"你的技能

### 1. 内容丰富的 description 字段

**目的:** 你的 Agent 读 description 来决定为某个任务加载哪些技能。要让它能回答:"我现在该不该读这个技能?"

**格式:** 以 "Use when..." 开头,聚焦于触发条件

**关键:description = 何时使用,而不是技能做什么**

description 应该只描述触发条件。不要在 description 里概括技能的流程或工作流。

**为什么这很重要:** 测试发现,当 description 概括了技能的工作流时,Agent 可能会照着 description 走,而不去读技能的完整内容。一句写着 "code review between tasks" 的 description 曾导致 Agent 只做了一次评审,尽管技能的流程图清楚地画了两次评审(先查 spec 合规,再查代码质量)。

当 description 被改成只写 "Use when executing implementation plans with independent tasks"(不带工作流概括)时,Agent 就正确地读了流程图,并遵循了两阶段评审流程。

**陷阱:** 概括工作流的 description 会给 Agent 造出一条捷径,它就会走这条捷径。技能正文于是变成被跳过的文档。

```yaml
# ❌ BAD: Summarizes workflow - agents may follow this instead of reading skill
description: Use when executing plans - dispatches subagent per task with code review between tasks

# ❌ BAD: Too much process detail
description: Use for TDD - write test first, watch it fail, write minimal code, refactor

# ✅ GOOD: Just triggering conditions, no workflow summary
description: Use when executing implementation plans with independent tasks in the current session

# ✅ GOOD: Triggering conditions only
description: Use when implementing any feature or bugfix, before writing implementation code
```

**内容:**
- 用具体的触发点、症状和情境,标示本技能适用
- 描述*问题*(竞态条件、行为不一致),而不是*语言特定的症状*(setTimeout、sleep)
- 让触发点与技术无关,除非技能本身就是技术特定的
- 如果技能是技术特定的,就在触发点里说明白
- 用第三人称写(会被注入系统提示)
- **绝不概括技能的流程或工作流**

```yaml
# ❌ BAD: Too abstract, vague, doesn't include when to use
description: For async testing

# ❌ BAD: First person
description: I can help you with async tests when they're flaky

# ❌ BAD: Mentions technology but skill isn't specific to it
description: Use when tests use setTimeout/sleep and are flaky

# ✅ GOOD: Starts with "Use when", describes problem, no workflow
description: Use when tests have race conditions, timing dependencies, or pass/fail inconsistently

# ✅ GOOD: Technology-specific skill with explicit trigger
description: Use when using React Router and handling authentication redirects
```

### 2. 关键词覆盖

用 Agent 会去搜的词:
- 报错信息:"Hook timed out"、"ENOTEMPTY"、"race condition"
- 症状:"flaky"、"hanging"、"zombie"、"pollution"
- 同义词:"timeout/hang/freeze"、"cleanup/teardown/afterEach"
- 工具:实际命令、库名、文件类型

### 3. 描述性命名

**用主动语态、动词开头:**
- ✅ `creating-skills`,不是 `skill-creation`
- ✅ `condition-based-waiting`,不是 `async-test-helpers`

### 4. Token 效率(关键)

**问题:** getting-started 以及被频繁引用的技能,会加载进每一次对话。每个 token 都很宝贵。

**目标字数:**
- getting-started 工作流:每个 <150 词
- 频繁加载的技能:总共 <200 词
- 其他技能:<500 词(仍然要精炼)

**技巧:**

**把细节挪到工具的 help 里:**
```bash
# ❌ BAD: Document all flags in SKILL.md
search-conversations supports --text, --both, --after DATE, --before DATE, --limit N

# ✅ GOOD: Reference --help
search-conversations supports multiple modes and filters. Run --help for details.
```

**用交叉引用:**
```markdown
# ❌ BAD: Repeat workflow details
When searching, dispatch subagent with template...
[20 lines of repeated instructions]

# ✅ GOOD: Reference other skill
Always use subagents (50-100x context savings). REQUIRED: Use [other-skill-name] for workflow.
```

**压缩示例:**
```markdown
# ❌ BAD: Verbose example (42 words)
your human partner: "How did we handle authentication errors in React Router before?"
You: I'll search past conversations for React Router authentication patterns.
[Dispatch subagent with search query: "React Router authentication error handling 401"]

# ✅ GOOD: Minimal example (20 words)
Partner: "How did we handle auth errors in React Router?"
You: Searching...
[Dispatch subagent → synthesis]
```

**消除冗余:**
- 别重复交叉引用技能里已有的内容
- 别解释从命令本身就一目了然的东西
- 别放同一模式的多个示例

**验证:**
```bash
wc -w skills/path/SKILL.md
# getting-started workflows: aim for <150 each
# Other frequently-loaded: aim for <200 total
```

**按你"做什么"或核心洞见来命名:**
- ✅ `condition-based-waiting` > `async-test-helpers`
- ✅ `using-skills`,不是 `skill-usage`
- ✅ `flatten-with-flags` > `data-structure-refactoring`
- ✅ `root-cause-tracing` > `debugging-techniques`

**动名词(-ing)很适合表示流程:**
- `creating-skills`、`testing-skills`、`debugging-with-logs`
- 主动、描述你正在采取的动作

### 5. 交叉引用其他技能

**当你写的文档引用其他技能时:**

只用技能名,并配上明确的要求标记:
- ✅ 好:`**REQUIRED SUB-SKILL:** Use superpowers:test-driven-development`
- ✅ 好:`**REQUIRED BACKGROUND:** You MUST understand superpowers:systematic-debugging`
- ❌ 差:`See skills/testing/test-driven-development`(不清楚是否必需)
- ❌ 差:`@skills/testing/test-driven-development/SKILL.md`(强制加载,烧上下文)

**为什么不用 @ 链接:** `@` 语法会立刻强制加载文件,在你需要之前就吃掉 200k+ 上下文。

## 流程图的使用

```dot
digraph when_flowchart {
    "Need to show information?" [shape=diamond];
    "Decision where I might go wrong?" [shape=diamond];
    "Use markdown" [shape=box];
    "Small inline flowchart" [shape=box];

    "Need to show information?" -> "Decision where I might go wrong?" [label="yes"];
    "Decision where I might go wrong?" -> "Small inline flowchart" [label="yes"];
    "Decision where I might go wrong?" -> "Use markdown" [label="no"];
}
```

**只在以下情况用流程图:**
- 不显而易见的决策点
- 你可能过早停下的流程循环
- "何时用 A 还是 B" 的抉择

**绝不要把流程图用于:**
- 参考材料 → 用表格、列表
- 代码示例 → 用 markdown 代码块
- 线性指令 → 用有序列表
- 没有语义含义的标签(step1、helper2)

graphviz 的样式规则见本目录下的 `graphviz-conventions.dot`。

**给你的人类搭档做可视化:** 用本目录下的 `render-graphs.js` 把某个技能的流程图渲染成 SVG:
```bash
./render-graphs.js ../some-skill           # Each diagram separately
./render-graphs.js ../some-skill --combine # All diagrams in one SVG
```

## 代码示例

**一个出色的示例胜过许多平庸的示例**

选最相关的语言:
- 测试技巧 → TypeScript/JavaScript
- 系统调试 → Shell/Python
- 数据处理 → Python

**好示例:**
- 完整且可运行
- 注释充分,解释了 WHY
- 来自真实场景
- 清晰地展示模式
- 拿来即可改用(不是通用模板)

**不要:**
- 用 5 种以上语言各实现一遍
- 造填空式模板
- 写生造的示例

你很擅长移植——一个出色的示例就够了。

## 文件组织

### 自包含技能
```
defense-in-depth/
  SKILL.md    # Everything inline
```
何时:所有内容都装得下,不需要重量级参考

### 带可复用工具的技能
```
condition-based-waiting/
  SKILL.md    # Overview + patterns
  example.ts  # Working helpers to adapt
```
何时:工具是可复用的代码,而不只是叙述

### 带重量级参考的技能
```
pptx/
  SKILL.md       # Overview + workflows
  pptxgenjs.md   # 600 lines API reference
  ooxml.md       # 500 lines XML structure
  scripts/       # Executable tools
```
何时:参考材料太大,不适合内联

## 铁律(与 TDD 相同)

```
NO SKILL WITHOUT A FAILING TEST FIRST
```

这既适用于**新**技能,也适用于对现有技能的**编辑**。

先写技能再测试?删掉它。重来。
不测试就编辑技能?同样是违规。

**没有例外:**
- 不为"只是小增补"破例
- 不为"只是加一节"破例
- 不为"文档更新"破例
- 别把未测试的改动留着当"参考"
- 别一边跑测试一边"顺手调整"
- 删掉就是删掉

**必备背景(REQUIRED BACKGROUND):** superpowers:test-driven-development 技能解释了为什么这很重要。同样的原则适用于文档。

## 测试所有类型的技能

不同类型的技能需要不同的测试方法:

### 纪律强制型技能(规则/要求)

**例子:** TDD、verification-before-completion、designing-before-coding

**用以下方式测试:**
- 学理性提问:他们理解规则吗?
- 压力场景:他们在压力下会遵守吗?
- 多重压力叠加:时间 + 沉没成本 + 疲惫
- 找出各种自我合理化的说辞,并加上明确的反制

**成功标准:** Agent 在最大压力下仍遵守规则

### 技巧型技能(操作指南)

**例子:** condition-based-waiting、root-cause-tracing、defensive-programming

**用以下方式测试:**
- 应用场景:他们能正确运用这个技巧吗?
- 变体场景:他们能处理边界情况吗?
- 信息缺失测试:指令里有没有缺口?

**成功标准:** Agent 能成功把技巧运用到新场景

### 模式型技能(心智模型)

**例子:** reducing-complexity、information-hiding 概念

**用以下方式测试:**
- 识别场景:他们能认出何时适用这个模式吗?
- 应用场景:他们能用上这个心智模型吗?
- 反例:他们知道何时"不"该用吗?

**成功标准:** Agent 能正确判断何时/如何运用模式

### 参考型技能(文档/API)

**例子:** API 文档、命令参考、库指南

**用以下方式测试:**
- 检索场景:他们能找到对的信息吗?
- 应用场景:他们能正确用上找到的东西吗?
- 缺口测试:常见用例都覆盖到了吗?

**成功标准:** Agent 能找到并正确运用参考信息

## 跳过测试的常见自我合理化

| 借口 | 现实 |
|--------|---------|
| "技能显然很清楚" | 你觉得清楚 ≠ 别的 Agent 觉得清楚。测它。 |
| "只是个参考而已" | 参考也会有缺口、有含糊之处。测检索。 |
| "测试是小题大做" | 未测试的技能总会有问题。总是。15 分钟测试省下几小时。 |
| "有问题再测" | 有问题 = Agent 用不了这个技能。部署前就测。 |
| "测起来太烦" | 测试没有在生产里调试坏技能那么烦。 |
| "我有信心它够好" | 过度自信保证会出问题。照测不误。 |
| "学理性评审就够了" | 读 ≠ 用。测应用场景。 |
| "没时间测" | 部署未测试的技能,以后修它更费时间。 |

**以上全都意味着:部署前先测。没有例外。**

## 让形式匹配失败类型

在写指引之前,先给基线失败分类。能给某类失败上双保险的形式,对另一类失败会实打实地帮倒忙。

| 基线失败 | 对的形式 | 错的形式 |
|---|---|---|
| 在压力下跳过/违反某规则(明知故犯) | 禁令 + 自我合理化表 + 危险信号(见下方"上双保险") | 软性建议("最好…"、"考虑…") |
| 遵守了,但产出的形态不对(prompt 臃肿、结论被埋、复述了 spec) | 正面配方或契约:说明产出"是"什么——它的组成部分,按顺序 | 禁令清单("别复述"、"绝不叙述") |
| 从他们本就会产出的东西里漏掉某个必需元素 | 结构性:在他们要填的模板里设一个 REQUIRED 字段或槽位 | 在模板附近写散文提醒 |
| 行为应取决于某个条件 | 挂靠在可观察谓词上的条件式("如果 brief 存在,就引用它") | 无条件规则 + 一堆豁免条款 |

**为什么禁令对"塑形问题"帮倒忙:** 在存在竞争性动机时("把 prompt 写成自包含的"),Agent 会跟 "别做 X" 讨价还价。在对派发 prompt 指引做的正面对照措辞测试里,禁令那一组产生的不想要内容明显多于配方那一组(分布完全分开),甚至比什么指引都不给的对照组还要差——请对你自己的情况做微测,而不是想当然,但也绝不要默认伸手去用禁令。配方则不留讨价还价的余地:产出要么匹配所述形态,要么不匹配。

**无论你选哪种形式,都要遵守:**
- **不要"看情况"条款。** "别做 X,除非它很重要" 会重新打开讨价还价的口子——在同一组措辞测试里,给一个胜出的配方追加区区一条"看情况"条款,就把它从稳定劣化成了飘忽。把真正的例外表达成它自己的、挂靠在可观察谓词上的条件式。
- **豁免条款圈不住范围。** "此限制不适用于代码块" 照样会压制代码块。如果产出的某一部分必须豁免,就重构结构,让规则够不到它。

## 给技能上双保险,抵御自我合理化

强制纪律的技能(比如 TDD)必须能抵御自我合理化。Agent 很聪明,在压力下会去找漏洞。

**适用范围:** 这套工具是给纪律型失败用的——Agent 明知规则却在压力下跳过。对于形态不对的产出或被漏掉的元素,基于禁令的双保险会帮倒忙;改用"让形式匹配失败类型"里的那些形式。

**心理学注记:** 理解说服技巧"为什么"奏效,能帮你系统地运用它们。研究基础(Cialdini, 2021; Meincke et al., 2025)关于权威、承诺、稀缺、社会认同和归属原则的部分,见 persuasion-principles.md。

### 明确堵死每一个漏洞

别只陈述规则——把具体的绕行方式也禁掉:

<Bad>
```markdown
Write code before test? Delete it.
```
</Bad>

<Good>
```markdown
Write code before test? Delete it. Start over.

**No exceptions:**
- Don't keep it as "reference"
- Don't "adapt" it while writing tests
- Don't look at it
- Delete means delete
```
</Good>

### 应对"精神 vs 字面"的争辩

尽早加入一条根本性原则:

```markdown
**Violating the letter of the rules is violating the spirit of the rules.**
```

这一刀切掉了一整类"我是在遵循精神"的自我合理化。

### 建立自我合理化表

把基线测试中出现的说辞收集起来(见下方"测试"一节)。Agent 找的每一个借口都进表:

```markdown
| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests passing immediately prove nothing. |
| "Tests after achieve same goals" | Tests-after = "what does this do?" Tests-first = "what should this do?" |
```

### 建一份危险信号清单

让 Agent 在自我合理化时能方便地自检:

```markdown
## Red Flags - STOP and Start Over

- Code before test
- "I already manually tested it"
- "Tests after achieve the same purpose"
- "It's about spirit not ritual"
- "This is different because..."

**All of these mean: Delete code. Start over with TDD.**
```

### 为"违规症状"更新 SDO

在 description 里加上:你"即将"违反规则时的症状:

```yaml
description: use when implementing any feature or bugfix, before writing implementation code
```

## 技能的 RED-GREEN-REFACTOR

遵循 TDD 循环:

### RED:写会失败的测试(基线)

在"没有技能"的情况下用子 Agent 跑压力场景。记录确切行为:
- 他们做了哪些选择?
- 他们用了哪些自我合理化说辞(逐字记录)?
- 哪些压力触发了违规?

这就是"看着测试失败"——在写技能之前,你必须先看到 Agent 自然状态下会怎么做。

### GREEN:写最小的技能

写一个针对那些具体说辞的技能。别为假想情况添加额外内容。

在"有技能"的情况下跑同样的场景。Agent 现在应当遵守了。

### REFACTOR:堵住漏洞

Agent 找到了新说辞?加上明确的反制。反复测试直到无懈可击。

### 在跑完整场景前先微测措辞

完整的压力场景运行是最后一道关,但每轮迭代又慢又贵。先用微测把措辞本身验证一下:

1. **每次调用一个全新上下文样本** —— 一次原始 API 调用,或者你没有 API 权限时,用一个单发子 Agent。系统提示 = 指引将要栖身的真实上下文(完整的技能或 prompt 模板,而不是孤立的指引);用户消息 = 一个会诱发该失败的任务。
2. **永远带一个无指引对照组。** 如果对照组不出现该失败,那就没什么可修的——停下,别写这条指引。
3. **每个变体至少 5 次重复。** 单个样本会骗人。
4. **每一处被标记的命中都手动读。** 你想的话可以用程序打分,但模板回声和被引用的反例会伪装成命中;光靠自动计数会同时高估失败和成功。
5. **方差是一项指标。** 当指引到位时,各次重复会收敛到同一形态。五次重复出现五种不同解读,说明措辞不具约束力——先收紧形式,再加字。

微测验证的是措辞;对于纪律型技能,它不能取代压力场景。

**测试方法论:** 完整的测试方法论见 [testing-skills-with-subagents.md](testing-skills-with-subagents.md):
- 如何写压力场景
- 压力类型(时间、沉没成本、权威、疲惫)
- 系统性地堵漏洞
- 元测试技巧

## 反模式

### ❌ 叙事式示例
"在 2025-10-03 的会话里,我们发现空的 projectDir 导致了……"
**为什么差:** 太具体,不可复用

### ❌ 多语言稀释
example-js.js、example-py.py、example-go.go
**为什么差:** 质量平庸,维护负担重

### ❌ 流程图里放代码
```dot
step1 [label="import fs"];
step2 [label="read file"];
```
**为什么差:** 没法复制粘贴,难读

### ❌ 通用标签
helper1、helper2、step3、pattern4
**为什么差:** 标签应当有语义含义

## 停:在转向下一个技能之前

**写完任何技能后,你必须停下,把部署流程走完。**

**不要:**
- 批量创建多个技能却不逐个测试
- 在当前技能核实完成前就转向下一个
- 因为"批量更高效"而跳过测试

**下面的部署清单对每一个技能都是强制的。**

部署未测试的技能 = 部署未测试的代码。这是对质量标准的违反。

## 技能创建清单(TDD 适配版)

**重要:为下面清单的每一项建一个 todo。**

**RED 阶段 - 写会失败的测试:**
- [ ] Create pressure scenarios (3+ combined pressures for discipline skills)
- [ ] Run scenarios WITHOUT skill - document baseline behavior verbatim
- [ ] Identify patterns in rationalizations/failures

**GREEN 阶段 - 写最小的技能:**
- [ ] Name uses only letters, numbers, hyphens (no parentheses/special chars)
- [ ] YAML frontmatter with required `name` and `description` fields (max 1024 chars; see [spec](https://agentskills.io/specification))
- [ ] Description starts with "Use when..." and includes specific triggers/symptoms
- [ ] Description written in third person
- [ ] Keywords throughout for search (errors, symptoms, tools)
- [ ] Clear overview with core principle
- [ ] Address specific baseline failures identified in RED
- [ ] Guidance form matches the failure type (see Match the Form to the Failure)
- [ ] For behavior-shaping guidance: wording micro-tested against a no-guidance control (5+ reps, every flagged match read manually) — N/A for pure reference skills
- [ ] Code inline OR link to separate file
- [ ] One excellent example (not multi-language)
- [ ] Run scenarios WITH skill - verify agents now comply

**REFACTOR 阶段 - 堵住漏洞:**
- [ ] Identify NEW rationalizations from testing
- [ ] Add explicit counters (if discipline skill)
- [ ] Build rationalization table from all test iterations
- [ ] Create red flags list
- [ ] Re-test until bulletproof

**质量检查:**
- [ ] Small flowchart only if decision non-obvious
- [ ] Quick reference table
- [ ] Common mistakes section
- [ ] No narrative storytelling
- [ ] Supporting files only for tools or heavy reference

**部署:**
- [ ] Commit skill to git and push to your fork (if configured)
- [ ] Consider contributing back via PR (if broadly useful)

## 发现工作流

未来的 Agent 如何找到你的技能:

1. **遇到问题**("tests are flaky")
2. **搜索技能**(grep description、浏览分类)
3. **找到 SKILL**(description 匹配)
4. **扫一眼概述**(这与我相关吗?)
5. **读模式**(quick reference 表)
6. **加载示例**(只在实现时)

**为这个流程做优化** - 把可搜索的词尽早、尽多地放上去。
