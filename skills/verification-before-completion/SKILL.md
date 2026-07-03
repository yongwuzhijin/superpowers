---
name: verification-before-completion
description: 当你正要宣称工作已完成、已修复或已通过时,在提交或创建 PR 之前使用——要求先运行验证命令并确认输出,然后才能做出任何成功的断言;永远是证据先行、断言在后
---

# 完成之前先验证

## 概述

不做验证就宣称工作完成,那是不诚实,不是效率。

**核心原则:** 永远证据先于断言。

**违背这条规则的字面意思,就是违背这条规则的精神。**

## 铁律

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

如果你没在这条消息里运行过验证命令,你就不能宣称它通过。

## 关卡函数

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

## 常见的翻车

| 断言 | 需要什么 | 不够格的 |
|-------|----------|----------------|
| 测试通过 | 测试命令输出:0 个失败 | 上一次运行、"应该会过" |
| Linter 干净 | Linter 输出:0 个错误 | 只查了一部分、靠推断 |
| 构建成功 | 构建命令:exit 0 | Linter 过了、日志看着还行 |
| Bug 已修 | 测试原始症状:通过 | 改了代码、就假定修好了 |
| 回归测试有效 | 验证过红-绿循环 | 测试过了一次 |
| Agent 已完成 | 版本控制 diff 显示有改动 | Agent 汇报"成功" |
| 需求已满足 | 逐行核对清单 | 测试通过 |

## 危险信号——停

- 用了 "应该"、"大概"、"看起来"
- 验证之前就表达满意("太好了!"、"完美!"、"搞定!"等等)
- 没验证就要去 commit/push/PR
- 相信 Agent 的成功汇报
- 依赖不完整的验证
- 想着"就这一次"
- 累了,想赶紧收工
- **任何在没运行验证的情况下暗示成功的措辞**

## 防止自我合理化

| 借口 | 现实 |
|--------|---------|
| "现在应该能行了" | 去运行验证 |
| "我很有把握" | 把握 ≠ 证据 |
| "就这一次" | 没有例外 |
| "Linter 过了" | Linter ≠ 编译器 |
| "Agent 说成功了" | 独立地去验证 |
| "我累了" | 疲惫 ≠ 借口 |
| "查一部分就够了" | 部分证明不了任何事 |
| "换了个说法,所以规则不适用" | 精神重于字面 |

## 关键套路

**测试:**
```
✅ [Run test command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**回归测试(TDD 红-绿):**
```
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
❌ "I've written a regression test" (without red-green verification)
```

**构建:**
```
✅ [Run build] [See: exit 0] "Build passes"
❌ "Linter passed" (linter doesn't check compilation)
```

**需求:**
```
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent 委派:**
```
✅ Agent reports success → Check VCS diff → Verify changes → Report actual state
❌ Trust agent report
```

## 为什么这很重要

来自 24 条失败的记忆:
- 你的人类搭档说"我不信你"——信任崩了
- 发布了未定义的函数——本会崩溃
- 发布时缺了需求——功能不完整
- 因假完成而浪费时间 → 被打回 → 返工
- 违反了:"诚实是核心价值。如果你撒谎,你会被替换掉。"

## 何时适用

**永远在以下之前:**
- 任何形式的成功/完成断言
- 任何满意的表达
- 任何关于工作状态的正面陈述
- commit、创建 PR、任务完成
- 转向下一个任务
- 委派给 Agent

**这条规则适用于:**
- 原话
- 换个说法和同义词
- 对成功的暗示
- 任何暗示完成/正确的沟通

## 归根结底

**验证没有捷径。**

运行命令。读输出。然后再宣称结果。

这一条没得商量。
