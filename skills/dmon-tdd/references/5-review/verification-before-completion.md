---
name: verification-before-completion
description: 当你即将声称工作已完成、已修复或已通过时,在提交或创建 PR 之前使用——要求先运行验证命令并确认输出,再作出任何成功声明;永远是先有证据再下断言
---

# Verification Before Completion

## 概述

**核心原则:** 永远先有证据,再下声明。

**违反本规则的字面表述,就是违反本规则的精神。**

## 铁律

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

如果你没有在这条消息里跑过验证命令,你就不能声称它通过了。

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

| 声明 | 需要什么 | 不足以支撑 |
|-------|----------|----------------|
| 测试通过 | 测试命令输出:0 个失败 | 上一次的运行、"应该会过吧" |
| Linter 干净 | Linter 输出:0 个错误 | 只查了一部分、靠推断 |
| 构建成功 | 构建命令:退出码 0 | Linter 过了、日志看着不错 |
| Bug 已修 | 复现原症状的测试:通过 | 改了代码、假定修好了 |
| 回归测试有效 | 验证过红-绿循环 | 测试过了一次 |
| Agent 完成了 | VCS diff 显示有改动 | Agent 报告"success" |
| 需求已满足 | 逐条对照的清单 | 测试通过 |

## 危险信号——停下

- 用了"应该"、"大概"、"看起来"
- 在验证前就表露满意("Great!"、"Perfect!"、"Done!" 等)
- 在没验证的情况下就要 commit/push/PR
- 轻信 Agent 的成功报告
- 依赖不完整的验证
- 心想"就这一次"
- 累了,只想赶紧收工
- **任何在没跑验证的情况下暗示成功的措辞**

## 防止自我合理化

| 借口 | 现实 |
|--------|---------|
| "现在应该能行了" | 去跑验证 |
| "我很有信心" | 信心 ≠ 证据 |
| "就这一次" | 没有例外 |
| "Linter 过了" | Linter ≠ 编译器 |
| "Agent 说 success" | 独立地去核实 |
| "我累了" | 疲惫 ≠ 借口 |
| "查一部分就够了" | 部分验证什么都证明不了 |
| "换个说法,规则就不适用了" | 精神重于字面 |

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

## 何时适用

**以下情况之前永远适用:**
- 任何形式的成功/完成声明
- 任何满意的表露
- 任何关于工作状态的正面陈述
- 提交、创建 PR、任务完成
- 转入下一个任务
- 委派给 Agent

**本规则适用于:**
- 原话
- 转述与同义表达
- 对成功的暗示
- 任何暗示完成/正确的沟通
