---
name: requesting-code-review
description: 在完成任务、实现重要功能,或合并之前使用,用来核实工作是否满足需求
---

# 请求代码评审

派出一个代码评审子 Agent,在问题连锁扩散之前把它们抓出来。这个评审者拿到的是为评估精心准备的上下文 —— 绝不是你这次会话的历史记录。

**核心原则:** 尽早评审,常常评审。

## 什么时候请求评审

**必做:**
- subagent-driven development 中每个任务之后
- 完成重要功能之后
- 合并到 main 之前

**可选但有价值:**
- 卡住的时候(换个新鲜视角)
- 重构之前(先做基线检查)
- 修完复杂 bug 之后

## 怎么请求

**1. 拿到 git SHA:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # 或 origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. 派出代码评审子 Agent:**

派出一个 `general-purpose` 子 Agent,填好 [code-reviewer.md](code-reviewer.md) 里的模板

**占位符:**
- `{DESCRIPTION}` - 你构建了什么的简要总结
- `{PLAN_OR_REQUIREMENTS}` - 它应该做什么
- `{BASE_SHA}` - 起始提交
- `{HEAD_SHA}` - 结束提交

**3. 根据反馈行动:**
- 立刻修 Critical(严重)问题
- 继续往下之前先修 Important(重要)问题
- Minor(次要)问题记下来留待以后
- 如果评审者错了就反驳(带上理由)

## 示例

```
[刚完成任务 2:新增校验函数]

你:继续往下之前,我来请求一次代码评审。

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[派出代码评审子 Agent]
  DESCRIPTION: 新增了 verifyIndex() 和 repairIndex(),含 4 种问题类型
  PLAN_OR_REQUIREMENTS: docs/dmon/plans/deployment-plan.md 中的任务 2
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[子 Agent 返回]:
  Strengths(优点): 架构清晰,测试是真的
  Issues(问题):
    Important(重要): 缺少进度提示
    Minor(次要): 上报间隔用了魔法数字(100)
  Assessment(评估): 可以继续

你:[修好进度提示]
[继续到任务 3]
```

## 常见的自我合理化

| 借口 | 现实 |
|--------|------|
| "我自己看看 diff 就行了,不用派评审者" | 你是协调者 —— 就地在会话里看 diff 会烧掉你继续推进工作所需的上下文窗口。派一个评审子 Agent:diff 和评估都待在它的上下文里,回到你这儿的只有结论。 |
| "评审者需要我整个会话历史才能理解这次改动" | 交给它精心准备的上下文,绝不是你这次会话的历史。这样评审者才会盯着工作成果,而不是你的思考过程。 |

## 危险信号

**绝不要:**
- 因为"很简单"就跳过评审
- 无视 Critical(严重)问题
- Important(重要)问题没修就往下走
- 和站得住脚的技术反馈争辩

**如果评审者错了:**
- 用技术理由反驳
- 拿出能证明它可行的代码/测试
- 请求澄清

模板见:[code-reviewer.md](code-reviewer.md)
