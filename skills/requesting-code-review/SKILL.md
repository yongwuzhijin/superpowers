---
name: requesting-code-review
description: 在完成任务、实现重要特性,或合并之前使用,用来核验工作是否达到要求
---

# 请求代码评审

派出一个代码评审子 Agent,趁问题还没连锁扩散时把它们揪出来。这个评审者拿到的是为评估精心准备的上下文——绝不是你这次会话的历史记录。这样能让评审者专注于工作成果本身,而不是你的思考过程,同时也为你自己保留上下文以便继续工作。

**核心原则:** 尽早评审,勤加评审。

## 何时请求评审

**必须:**
- 子 Agent 驱动开发中每完成一个任务后
- 完成一个重要特性后
- 合并到 main 之前

**可选但很有价值:**
- 卡住的时候(换个新视角)
- 重构之前(先摸清基线)
- 修完复杂 bug 之后

## 如何请求

**1. 拿到 git SHA:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. 派出代码评审子 Agent:**

派出一个 `general-purpose` 子 Agent,填写 [code-reviewer.md](code-reviewer.md) 里的模板

**占位符:**
- `{DESCRIPTION}` —— 你构建了什么的简要总结
- `{PLAN_OR_REQUIREMENTS}` —— 它应该做什么
- `{BASE_SHA}` —— 起始提交
- `{HEAD_SHA}` —— 结束提交

**3. 根据反馈行动:**
- 立即修复 Critical(严重)问题
- 继续之前先修复 Important(重要)问题
- 记下 Minor(次要)问题留待以后
- 如果评审者错了,反驳(带上理由)

## 示例

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch code reviewer subagent]
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
  PLAN_OR_REQUIREMENTS: Task 2 from docs/superpowers/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## 与工作流的衔接

**子 Agent 驱动开发:**
- 每个任务后都评审
- 趁问题还没叠加时揪出来
- 修完再进入下一个任务

**执行计划:**
- 每个任务后,或在自然的检查点评审
- 拿到反馈,应用,继续

**临时开发:**
- 合并前评审
- 卡住时评审

## 危险信号

**绝不要:**
- 因为"这很简单"就跳过评审
- 忽视 Critical(严重)问题
- 带着没修的 Important(重要)问题继续
- 和站得住脚的技术反馈争辩

**如果评审者错了:**
- 用技术理由反驳
- 拿出能证明它可行的代码/测试
- 请求澄清

模板见:[code-reviewer.md](code-reviewer.md)
