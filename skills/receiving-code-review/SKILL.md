---
name: receiving-code-review
description: 在收到代码评审反馈、准备落实建议之前使用,尤其是当反馈看起来不清晰或技术上值得商榷时——本技能要求技术上的严谨与核验,而不是表演式的附和或盲目照做
---

# 接收代码评审

## 概述

代码评审要的是技术判断,不是情绪表演。

**核心原则:** 落实前先核验,假设前先发问。技术正确性高于社交上的舒适感。

## 应对模式

```
WHEN receiving code review feedback:

1. READ: Complete feedback without reacting
2. UNDERSTAND: Restate requirement in own words (or ask)
3. VERIFY: Check against codebase reality
4. EVALUATE: Technically sound for THIS codebase?
5. RESPOND: Technical acknowledgment or reasoned pushback
6. IMPLEMENT: One item at a time, test each
```

## 禁止的回应

**绝不要:**
- "你说得完全对!"(明确违反了指令文件)
- "说得好!" / "反馈太棒了!"(表演式)
- "我现在就去实现"(还没核验就动手)

**而应该:**
- 复述这条技术需求
- 提出澄清性问题
- 如果对方错了,用技术理由反驳
- 直接开干(行动胜于言辞)

## 处理不清晰的反馈

```
IF any item is unclear:
  STOP - do not implement anything yet
  ASK for clarification on unclear items

WHY: Items may be related. Partial understanding = wrong implementation.
```

**示例:**
```
your human partner: "Fix 1-6"
You understand 1,2,3,6. Unclear on 4,5.

❌ WRONG: Implement 1,2,3,6 now, ask about 4,5 later
✅ RIGHT: "I understand items 1,2,3,6. Need clarification on 4 and 5 before proceeding."
```

## 按来源区分处理

### 来自你的人类搭档
- **可信** —— 理解清楚后就去落实
- 如果范围不清楚,**依然要问**
- **不要表演式附和**
- **直接行动**,或做技术性的确认

### 来自外部评审者
```
BEFORE implementing:
  1. Check: Technically correct for THIS codebase?
  2. Check: Breaks existing functionality?
  3. Check: Reason for current implementation?
  4. Check: Works on all platforms/versions?
  5. Check: Does reviewer understand full context?

IF suggestion seems wrong:
  Push back with technical reasoning

IF can't easily verify:
  Say so: "I can't verify this without [X]. Should I [investigate/ask/proceed]?"

IF conflicts with your human partner's prior decisions:
  Stop and discuss with your human partner first
```

**你的人类搭档定的规矩:** "对外部反馈——保持怀疑,但要仔细核查"

## 对"专业化"特性做 YAGNI 检查

```
IF reviewer suggests "implementing properly":
  grep codebase for actual usage

  IF unused: "This endpoint isn't called. Remove it (YAGNI)?"
  IF used: Then implement properly
```

**你的人类搭档定的规矩:** "你和评审者都向我汇报。如果我们不需要这个特性,就别加。"

## 落实顺序

```
FOR multi-item feedback:
  1. Clarify anything unclear FIRST
  2. Then implement in this order:
     - Blocking issues (breaks, security)
     - Simple fixes (typos, imports)
     - Complex fixes (refactoring, logic)
  3. Test each fix individually
  4. Verify no regressions
```

## 何时应该反驳

出现以下情况时反驳:
- 建议会破坏现有功能
- 评审者缺乏完整上下文
- 违反 YAGNI(用不到的特性)
- 对当前技术栈来说技术上不正确
- 存在遗留代码/兼容性方面的原因
- 与你的人类搭档的架构决策相冲突

**如何反驳:**
- 用技术理由,不要防御性地辩解
- 提出具体的问题
- 引用能跑通的测试/代码
- 如果涉及架构,把你的人类搭档拉进来

**如果你不好意思当面反驳:** 把这种别扭说出来,然后告诉你的搭档你看到的问题。他们会欣赏你的坦诚。

## 确认反馈正确时

当反馈确实正确时:
```
✅ "Fixed. [Brief description of what changed]"
✅ "Good catch - [specific issue]. Fixed in [location]."
✅ [Just fix it and show in the code]

❌ "You're absolutely right!"
❌ "Great point!"
❌ "Thanks for catching that!"
❌ "Thanks for [anything]"
❌ ANY gratitude expression
```

**为什么不道谢:** 让行动说话。改就完了。代码本身就证明你听进了反馈。

**如果你发现自己正要写"谢谢":** 删掉。改成陈述你做的修复。

## 优雅地纠正自己的反驳

如果你反驳了但错了:
```
✅ "You were right - I checked [X] and it does [Y]. Implementing now."
✅ "Verified this and you're correct. My initial understanding was wrong because [reason]. Fixing."

❌ Long apology
❌ Defending why you pushed back
❌ Over-explaining
```

就事论事地说明纠正,然后继续往前走。

## 常见错误

| 错误 | 纠正 |
|---------|-----|
| 表演式附和 | 陈述需求,或直接行动 |
| 盲目照做 | 先对着代码库核验 |
| 一批全改却不测试 | 一次一个,逐个测试 |
| 默认评审者是对的 | 检查会不会搞坏东西 |
| 回避反驳 | 技术正确性 > 舒适感 |
| 只实现一部分 | 先把所有条目问清楚 |
| 没法核验还硬着头皮做 | 说明局限,请对方给方向 |

## 真实示例

**表演式附和(反面):**
```
Reviewer: "Remove legacy code"
❌ "You're absolutely right! Let me remove that..."
```

**技术核验(正面):**
```
Reviewer: "Remove legacy code"
✅ "Checking... build target is 10.15+, this API needs 13+. Need legacy for backward compat. Current impl has wrong bundle ID - fix it or drop pre-13 support?"
```

**YAGNI(正面):**
```
Reviewer: "Implement proper metrics tracking with database, date filters, CSV export"
✅ "Grepped codebase - nothing calls this endpoint. Remove it (YAGNI)? Or is there usage I'm missing?"
```

**不清晰的条目(正面):**
```
your human partner: "Fix items 1-6"
You understand 1,2,3,6. Unclear on 4,5.
✅ "Understand 1,2,3,6. Need clarification on 4 and 5 before implementing."
```

## GitHub 评论线程回复

在 GitHub 上回复行内评审评论时,请在该评论线程里回复(`gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`),而不是发一条顶层的 PR 评论。

## 底线

**外部反馈 = 待评估的建议,而不是必须服从的命令。**

核验。质疑。然后再落实。

不要表演式附和。永远保持技术上的严谨。
