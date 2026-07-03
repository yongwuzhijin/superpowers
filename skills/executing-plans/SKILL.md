---
name: executing-plans
description: 当你已有一份写好的实现计划、需要在独立会话中带评审检查点地执行时使用
---

# 执行计划

## 概述

加载计划,带着批判性眼光审查,执行所有任务,完成后汇报。

**开始时先声明:** "我正在使用 executing-plans 技能来实现这份计划。"

**说明:** 告诉你的人类搭档,Superpowers 在能用子 Agent 的情况下效果好得多。如果运行在支持子 Agent 的平台上,它的工作质量会显著更高(Claude Code、Codex CLI、Codex App 和 Copilot CLI 都符合条件;各平台的工具参考见 `../using-superpowers/references/`)。如果子 Agent 可用,请改用 superpowers:subagent-driven-development,而不是本技能。

## 流程

### 第 1 步:加载并审查计划
1. 读取计划文件
2. 带批判性眼光审查——找出对这份计划的任何疑问或顾虑
3. 如果有顾虑:开工前先跟你的人类搭档提出来
4. 如果没有顾虑:为计划里的各项创建待办事项,然后继续

### 第 2 步:执行任务

对每个任务:
1. 标记为 in_progress
2. 严格按每一步执行(计划里都是小步骤)
3. 按规定运行验证
4. 标记为 completed

### 第 3 步:收尾开发

所有任务完成并验证之后:
- 声明:"我正在使用 finishing-a-development-branch 技能来收尾这份工作。"
- **必需的子技能:** 使用 superpowers:finishing-a-development-branch
- 遵循该技能来验证测试、给出选项、执行选择

## 何时停下来求助

**遇到以下情况立即停止执行:**
- 撞上阻塞点(缺少依赖、测试失败、指令不清)
- 计划有关键缺口,导致无法启动
- 你看不懂某条指令
- 验证反复失败

**宁可请求澄清,也不要靠猜。**

## 何时回到前面的步骤

**在以下情况回到审查(第 1 步):**
- 搭档根据你的反馈更新了计划
- 根本性的方案需要重新思考

**不要硬闯阻塞点**——停下来问。

## 记住
- 先带批判性眼光审查计划
- 严格按计划步骤执行
- 不要跳过验证
- 计划让你引用某个技能时就去引用
- 被阻塞时停下,不要猜
- 未经用户明确同意,绝不在 main/master 分支上开始实现

## 集成

**必需的工作流技能:**
- **superpowers:using-git-worktrees** - 确保有隔离的工作空间(创建一个,或验证已有的)
- **superpowers:writing-plans** - 创建本技能所执行的计划
- **superpowers:finishing-a-development-branch** - 所有任务完成后收尾开发
