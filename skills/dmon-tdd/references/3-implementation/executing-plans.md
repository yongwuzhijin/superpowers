---
name: executing-plans
description: 当你已有一份写好的实现计划、需要在独立会话中带评审检查点地执行时使用
---

# Executing Plans

## 概述

加载计划,批判性地评审,执行所有任务,完成后汇报。

**开始时先声明:** "I'm using the executing-plans skill to implement this plan."

**注意:** 告诉你的人类搭档,dmon-tdd-engineering 在能用子 Agent 时效果好得多(Cursor、Claude Code 和 Codex 都符合条件;各平台的工具参考见 `../platform/codex-tools.md`)。如果子 Agent 可用,请改用 `subagent-driven-development.md`,而不是本技能。

## 流程

### 第 1 步:加载并评审计划
1. 确保有一个隔离的工作空间:用 `../shared/using-git-worktrees.md` 新建一个,或核实已有的那个
2. 读取计划文件
3. 批判性地评审——找出对计划的任何疑问或顾虑
4. 若有顾虑:开工前先向你的人类搭档提出来
5. 若无顾虑:为计划条目建立 todos 并继续

### 第 2 步:执行任务

对每个任务:
1. 标记为 in_progress
2. 严格照每一步走(计划里的步骤都是一口大小的)
3. 按指定方式运行验证
4. 标记为 completed

### 第 3 步:收尾开发

所有任务完成并验证后:
- 声明:"I'm using the finishing-a-development-branch skill to complete this work."
- **必用子技能(REQUIRED SUB-SKILL):** 阅读并遵循 `../6-finishing/finishing-a-development-branch.md`
- 遵循该技能来验证测试、给出选项、执行所选方案

## 何时停下来求助

**遇到以下情况立即停止执行:**
- 撞上拦路石(缺依赖、测试失败、指令不清)
- 计划有致命缺口,导致根本没法开工
- 你看不懂某条指令
- 验证反复失败

**宁可去问清楚,也不要靠猜。**

## 何时回到更早的步骤

**在以下情况回到评审(第 1 步):**
- 搭档根据你的反馈更新了计划
- 根本性的思路需要重新考虑

**不要硬闯拦路石**——停下来问。

## 记住
- 先批判性地评审计划
- 严格照计划步骤走
- 别跳过验证
- 计划让你引用某个技能时就去引用
- 被挡住就停下,别猜
- 未经用户明确同意,绝不在 main/master 分支上开始实现
