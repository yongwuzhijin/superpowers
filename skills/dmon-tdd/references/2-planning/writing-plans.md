---
name: writing-plans
description: 当你手上已有一份需求规格/spec 或多步骤任务的需求、还没动代码时使用
---

# Writing Plans

## 概述

写实现计划时,要假设接手的工程师对我们的代码库毫无了解、品味也堪忧,把计划写得面面俱到。把他们需要知道的一切都写清楚:每个任务要动哪些文件、代码、测试、可能要查的文档、怎么测。把整份计划拆成一口大小的小任务交给他们。DRY(不要重复自己)。YAGNI(你根本用不上)。TDD。频繁提交。

假设他们是熟练的开发者,但对我们的工具链和问题域几乎一无所知。假设他们不太懂如何设计好的测试。

**开始时先声明:** "I'm using the writing-plans skill to create the implementation plan."

**上下文:** 如果在隔离的 worktree 中工作,它应该已经在执行时通过 `../shared/using-git-worktrees.md` 技能创建好了。

**计划保存到:** `docs/dmon/plans/YYYY-MM-DD-<feature-name>.md`
- (用户对计划存放位置的偏好可覆盖此默认值)

## 范围检查

如果 spec 覆盖多个相互独立的子系统,那它本应在头脑风暴阶段就被拆成子项目 spec。如果没拆,就建议把它拆成多份计划——每个子系统一份。每份计划都应能独立产出可运行、可测试的软件。

## 文件结构

在定义任务之前,先理清楚哪些文件会被创建或修改,以及每个文件各自负责什么。分解决策就在这一步敲定。

- 设计边界清晰、接口定义明确的单元。每个文件应有一个清晰的职责。
- 你对一次就能装进上下文的代码推理得最好,而且当文件聚焦时你的改动更可靠。宁可要小而聚焦的文件,也别要一个大包大揽的大文件。
- 会一起变的文件应放在一起。按职责拆分,而不是按技术分层拆分。
- 在已有代码库里,遵循既定的模式。如果代码库用的是大文件,别擅自重构——但如果你正在改的某个文件已经臃肿到难以驾驭,在计划里包含一次拆分是合理的。

这个结构会指导任务分解。每个任务都应产出可独立说得通的、自包含的改动。

## 任务大小的把控

一个任务是"能自带一个测试循环、且值得让一位新评审者过一道关"的最小单元。划任务边界时:把配置、搭脚手架、写文档这类步骤,并进那个交付物需要它们的任务里;只在"评审者可能有理由否掉一个任务却批准它旁边那个"的地方才拆开。每个任务都以一个可独立测试的交付物收尾。

## 一口大小的任务粒度

**每一步都是一个动作(2-5 分钟):**
- "写会失败的测试" - 一步
- "跑一下,确认它确实失败" - 一步
- "写最小的实现让测试通过" - 一步
- "跑测试,确认它们通过" - 一步
- "提交" - 一步

## 计划文档头部

**每份计划都必须以这个头部开头:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `skills/dmon-tdd/references/3-implementation/subagent-driven-development.md` (recommended) or `skills/dmon-tdd/references/3-implementation/executing-plans.md` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

**Spec:** [本计划所实现的 spec/设计文档路径——计划以 spec 为依据,因此 spec 必须随计划一起传递;执行者两者都要阅读]

## Global Constraints

[The spec's project-wide requirements — version floors, dependency limits,
naming and copy rules, platform requirements — one line each, with exact
values copied verbatim from the spec. Every task's requirements implicitly
include this section.]

---
```

## 任务结构

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Interfaces:**
- Consumes: [what this task uses from earlier tasks — exact signatures]
- Produces: [what later tasks rely on — exact function names, parameter
  and return types. A task's implementer sees only their own task; this
  block is how they learn the names and types neighboring tasks use.]

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## 不要留占位符

每一步都必须包含工程师真正需要的实际内容。以下都是**计划的失败**——永远别这么写:
- "TBD"、"TODO"、"稍后实现"、"细节待填"
- "加上适当的错误处理" / "加校验" / "处理边界情况"
- "为上面的内容写测试"(却不给出实际测试代码)
- "与 Task N 类似"(把代码重复写出来——工程师可能不按顺序读任务)
- 只描述做什么、却不展示怎么做的步骤(代码类步骤必须给代码块)
- 引用了任何任务里都没定义的类型、函数或方法

## 自我评审

写完整份计划后,用全新的眼光重看 spec,拿计划对照它检查。这是一份你自己跑的清单——不是派发子 Agent。

**1. Spec 覆盖度:** 快速扫一遍 spec 的每个章节/需求。你能指出实现它的那个任务吗?列出任何缺口。

**2. 占位符扫查:** 在你的计划里搜危险信号——上面"不要留占位符"一节里的任何模式。修掉它们。

**3. 类型一致性:** 你在后面任务里用的类型、方法签名和属性名,是否和你在前面任务里定义的一致?一个函数在 Task 3 叫 `clearLayers()`、到 Task 7 却叫 `clearFullLayers()`,就是个 bug。

如果发现问题,就地修掉。不用再重审一遍——修完继续往前走。如果发现某条 spec 需求没有对应任务,补上那个任务。

## 执行交接

保存计划后,给出执行方式的选择:

**"计划已完成并保存到 `docs/dmon/plans/<filename>.md`。两种执行方式:**

**1. 子 Agent 驱动(推荐)** - 我为每个任务派发一个全新的子 Agent,任务之间做评审,快速迭代

**2. 内联执行** - 在本会话中用 `../3-implementation/executing-plans.md` 执行任务,带检查点的批量执行

**选哪种?"**

**若选择子 Agent 驱动:**
- **必用子技能(REQUIRED SUB-SKILL):** 阅读并遵循 `../3-implementation/subagent-driven-development.md`
- 每个任务一个全新子 Agent + 两阶段评审

**若选择内联执行:**
- **必用子技能(REQUIRED SUB-SKILL):** 阅读并遵循 `../3-implementation/executing-plans.md`
- 带检查点的批量执行以便评审
