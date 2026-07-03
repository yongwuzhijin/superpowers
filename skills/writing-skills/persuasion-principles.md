# 技能设计中的说服原则

## 概述

大语言模型对说服原则的反应,和人类一样。理解这套心理学能帮你设计出更有效的技能——不是为了操纵,而是为了确保关键做法即便在压力下也被遵循。

**研究基础:** Meincke 等人(2025)用 N=28,000 次 AI 对话测试了 7 条说服原则。说服技巧让遵守率增长了一倍多(33% → 72%,p < .001)。

## 七条原则

### 1. 权威(Authority)
**它是什么:** 对专业、资历或官方来源的服从。

**它在技能里如何起作用:**
- 祈使语气:"YOU MUST"、"Never"、"Always"
- 不容商量的表述:"No exceptions"
- 消除决策疲劳和说辞

**何时使用:**
- 强制纪律的技能(TDD、验证要求)
- 安全关键的做法
- 已确立的最佳实践

**示例:**
```markdown
✅ Write code before test? Delete it. Start over. No exceptions.
❌ Consider writing tests first when feasible.
```

### 2. 承诺(Commitment)
**它是什么:** 与先前的行动、陈述或公开声明保持一致。

**它在技能里如何起作用:**
- 要求宣告:"Announce skill usage"
- 强制明确选择:"Choose A, B, or C"
- 使用跟踪:用 todo 管理检查清单

**何时使用:**
- 确保技能真的被遵循
- 多步骤流程
- 问责机制

**示例:**
```markdown
✅ When you find a skill, you MUST announce: "I'm using [Skill Name]"
❌ Consider letting your partner know which skill you're using.
```

### 3. 稀缺(Scarcity)
**它是什么:** 来自时间限制或有限供给的紧迫感。

**它在技能里如何起作用:**
- 带时限的要求:"Before proceeding"
- 顺序依赖:"Immediately after X"
- 防止拖延

**何时使用:**
- 即时验证要求
- 时效敏感的工作流
- 防止"我待会儿再做"

**示例:**
```markdown
✅ After completing a task, IMMEDIATELY request code review before proceeding.
❌ You can review code when convenient.
```

### 4. 社会认同(Social Proof)
**它是什么:** 从众于别人的做法或被视为常态的东西。

**它在技能里如何起作用:**
- 普适模式:"Every time"、"Always"
- 失败模式:"X without Y = failure"
- 确立规范

**何时使用:**
- 记录普适的做法
- 警示常见的失败
- 强化标准

**示例:**
```markdown
✅ Checklists without todo tracking = steps get skipped. Every time.
❌ Some people find a todo list helpful for checklists.
```

### 5. 归属(Unity)
**它是什么:** 共同的身份、"我们感"、圈内归属。

**它在技能里如何起作用:**
- 协作性语言:"our codebase"、"we're colleagues"
- 共同目标:"we both want quality"

**何时使用:**
- 协作型工作流
- 建立团队文化
- 非等级制的做法

**示例:**
```markdown
✅ We're colleagues working together. I need your honest technical judgment.
❌ You should probably tell me if I'm wrong.
```

### 6. 互惠(Reciprocity)
**它是什么:** 回报所受恩惠的义务感。

**它如何起作用:**
- 少用——可能让人觉得是操纵
- 在技能里很少用得上

**何时避免:**
- 几乎总是避免(其他原则更有效)

### 7. 喜好(Liking)
**它是什么:** 更愿意与我们喜欢的人合作。

**它如何起作用:**
- **别用它来求遵守**
- 与诚实反馈的文化相冲突
- 会制造谄媚

**何时避免:**
- 强制纪律时,永远避免

## 按技能类型搭配原则

| 技能类型 | 使用 | 避免 |
|------------|-----|-------|
| 强制纪律型 | 权威 + 承诺 + 社会认同 | 喜好、互惠 |
| 指引/技巧型 | 适度权威 + 归属 | 重度权威 |
| 协作型 | 归属 + 承诺 | 权威、喜好 |
| 参考型 | 只要清晰 | 一切说服手段 |

## 为什么有效:心理学

**明确的红线规则减少说辞:**
- "YOU MUST" 消除决策疲劳
- 绝对化的措辞消除"这算例外吗?"的疑问
- 明确的反说辞逐条堵住具体漏洞

**实施意图催生自动行为:**
- 清晰触发点 + 必需动作 = 自动执行
- "When X, do Y" 比 "generally do Y" 更有效
- 减轻遵守时的认知负担

**大语言模型是类人的(parahuman):**
- 在含有这些模式的人类文本上训练
- 在训练数据里,权威性语言先于遵守出现
- 承诺序列(陈述 → 行动)被频繁建模
- 社会认同模式(大家都做 X)确立规范

## 合乎伦理的使用

**正当的:**
- 确保关键做法被遵循
- 制作有效的文档
- 防止可预见的失败

**不正当的:**
- 为私利操纵
- 制造虚假的紧迫感
- 基于内疚的遵守

**检验标准:** 如果用户完全理解了这个技巧,它还会服务于用户的真实利益吗?

## 研究引用

**Cialdini, R. B. (2021).** *Influence: The Psychology of Persuasion (New and Expanded).* Harper Business.
- 七条说服原则
- 影响力研究的实证基础

**Meincke, L., Shapiro, D., Duckworth, A. L., Mollick, E., Mollick, L., & Cialdini, R. (2025).** Call Me A Jerk: Persuading AI to Comply with Objectionable Requests. University of Pennsylvania.
- 用 N=28,000 次 LLM 对话测试了 7 条原则
- 遵守率随说服技巧从 33% 增至 72%
- 权威、承诺、稀缺最有效
- 验证了 LLM 行为的类人模型

## 快速参考

设计技能时,自问:

1. **它是哪种类型?**(纪律 vs 指引 vs 参考)
2. **我想改变什么行为?**
3. **哪条(些)原则适用?**(纪律通常用权威 + 承诺)
4. **我是不是搭配了太多?**(别七条全上)
5. **这合乎伦理吗?**(服务于用户的真实利益吗?)
