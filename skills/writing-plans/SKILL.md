---
name: writing-plans
description: 当你手上已有一份需求规格/spec 或多步骤任务的需求、还没动代码时使用
---

# 编写计划

## 概述

写实现计划时，就假设接手的工程师对我们的代码库毫无了解，品味也未必靠谱。把他们需要知道的一切都写清楚：每个任务要改哪些文件、代码、测试、可能要查的文档、以及怎么测。把整份计划拆成一口大小的小任务交给他们。DRY(不要重复自己)。YAGNI(你根本用不上)。TDD。频繁提交。

假设他们是个熟练的开发者，但对我们的工具链和问题领域几乎一无所知。也假设他们不太懂好的测试设计。

**开场先声明:** "I'm using the writing-plans skill to create the implementation plan."

**上下文:** 如果是在隔离的 worktree 里工作，它应该在执行时通过 `superpowers:using-git-worktrees` skill 创建好了。

**计划保存到:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
- (如果用户对计划存放位置有偏好，以用户偏好为准，覆盖这个默认值)

## 范围检查

如果这份 spec 覆盖了多个相互独立的子系统，那它本应在头脑风暴阶段就被拆成若干子项目 spec。如果没拆,建议把它拆成多份独立计划——每个子系统一份。每份计划都应该能独立产出可运行、可测试的软件。

## 文件结构

在定义任务之前，先梳理清楚要创建或修改哪些文件、每个文件各自负责什么。分解决策就是在这里定下来的。

- 设计边界清晰、接口定义明确的单元。每个文件应该只有一个明确的职责。
- 你对能一次性装进上下文里的代码推理得最好，而且当文件聚焦时你的改动也更可靠。宁可要小而聚焦的文件,也别要一个包揽太多的大文件。
- 一起改动的文件应该放在一起。按职责拆分，而不是按技术分层拆分。
- 在既有代码库里,遵循已有的模式。如果代码库用的是大文件,别擅自重构——但如果你正在改的某个文件已经膨胀到难以驾驭,在计划里加入一次拆分是合理的。

这套结构会指导任务分解。每个任务都应该产出自成一体、单独看也说得通的改动。

## 任务大小的把握

一个任务是能自带一轮测试周期、且值得一位全新评审者把关的最小单元。画任务边界时:把搭建、配置、脚手架、文档这些步骤,折叠进那个真正需要它们的交付任务里;只有在评审者能有意义地否决其中一个任务、同时批准它相邻任务的地方,才拆开。每个任务都以一个可独立测试的交付物收尾。

## 一口大小的任务粒度

**每一步就是一个动作(2-5 分钟):**
- "写会失败的测试" - 一步
- "运行它,确认它失败" - 一步
- "写出让测试通过的最小实现代码" - 一步
- "运行测试,确认它们通过" - 一步
- "提交" - 一步

## 计划文档头部

**每份计划都必须以这个头部开头:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

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

## 不许留占位符

每一步都必须包含工程师实际需要的真材实料。以下这些都是**计划的失败**——永远别这么写:
- "TBD"、"TODO"、"稍后实现"、"细节待补"
- "加上适当的错误处理" / "加上校验" / "处理边界情况"
- "为上面写测试"(却没有真正的测试代码)
- "与 Task N 类似"(把代码重复写一遍——工程师可能是乱序读任务的)
- 只描述做什么、却不展示怎么做的步骤(代码步骤必须给出代码块)
- 引用了任何任务里都没定义过的类型、函数或方法

## 记住
- 永远给出确切的文件路径
- 每一步都给出完整代码——如果某步要改代码,就把代码展示出来
- 给出确切的命令和预期输出
- DRY、YAGNI、TDD、频繁提交

## 自我评审

写完整份计划后,用全新的眼光看一遍 spec,把计划对照着检查一遍。这是一份你自己跑的检查清单——不是派发子 Agent。

**1. spec 覆盖度:** 快速扫一遍 spec 里的每个章节/需求。你能指出哪个任务在实现它吗?列出所有缺口。

**2. 占位符扫描:** 在你的计划里搜索危险信号——上面"不许留占位符"一节里的任何一种模式。修掉它们。

**3. 类型一致性:** 你在后面任务里用到的类型、方法签名、属性名,和你在前面任务里定义的对得上吗?一个函数在 Task 3 里叫 `clearLayers()`、在 Task 7 里却叫 `clearFullLayers()`,这就是个 bug。

如果发现问题,就地修掉。不用再重新评审——修完继续就行。如果发现某个 spec 需求没有对应任务,就把任务补上。

## 执行交接

保存计划后,给出执行方式的选择:

**"计划已完成并保存到 `docs/superpowers/plans/<filename>.md`。有两种执行方式:**

**1. 子 Agent 驱动(推荐)** - 我为每个任务派发一个全新的子 Agent,任务之间做评审,快速迭代

**2. 内联执行** - 在当前会话里用 executing-plans 执行任务,带检查点的批量执行

**选哪种?"**

**如果选了子 Agent 驱动:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- 每个任务一个全新子 Agent + 两阶段评审

**如果选了内联执行:**
- **REQUIRED SUB-SKILL:** Use superpowers:executing-plans
- 带检查点的批量执行,便于评审
