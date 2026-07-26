# Superpowers

Superpowers 是一套面向你的编码 Agent 的完整软件开发方法论,它建立在一组可组合的技能之上,再加上一些初始指令,确保你的 Agent 真的会去用这些技能。


## 我们在招人!

我们正在招一位全职伙伴,帮忙打理 Superpowers 的社区和代码工作。
职位详情可以看这里:https://primeradiant.com/jobs/superpowers-community-engineer/
如果你觉得身边有合适的人,一定记得把他们推荐给我们。

## 快速开始

给你的 Agent 装上 Superpowers:[Claude Code](#claude-code)、[Antigravity](#antigravity)、[Codex App](#codex-app)、[Codex CLI](#codex-cli)、[Cursor](#cursor)、[Factory Droid](#factory-droid)、[Gemini CLI](#gemini-cli)、[GitHub Copilot CLI](#github-copilot-cli)、[Kimi Code](#kimi-code)、[OpenCode](#opencode)、[Pi](#pi)。

## 它是怎么运作的

一切从你启动编码 Agent 的那一刻就开始了。一旦它发现你要动手做点东西,它*不会*直接冲上去写代码,而是先退一步,问问你到底想要做什么。

等它从对话里把一份需求规格/spec 慢慢捋清楚之后,它会把这份 spec 拆成足够短、你能真正读进去消化的小块给你看。

在你确认了设计之后,你的 Agent 会整理出一份实现计划,清楚到什么程度呢——清楚到一个热情有余、但品味很差、没有判断力、不了解项目背景、还讨厌写测试的初级工程师,都能照着做下去。这份计划强调真正的红/绿测试驱动开发(TDD)、YAGNI(你根本用不上)和 DRY(不要重复自己)。

接下来,一旦你说"开干",它就会启动一个 *subagent-driven-development*(子 Agent 驱动开发)流程,让一个个 Agent 逐个啃下每项工程任务,检查并评审它们的成果,然后继续往前推进。你的 Agent 一次自主工作个把小时、丝毫不偏离你们一起定下的计划,这种情况并不罕见。

它还有很多其他内容,但这就是整个系统的核心。而且因为这些技能是自动触发的,你不需要做任何特别的事情。你的编码 Agent 就这么拥有了 Superpowers。

## 商业服务

如果你在企业环境中使用 Superpowers,并且需要商业支持、额外的工具,或是托管式的开销管理,欢迎随时联系我们:sales@primeradiant.com。

## 安装

安装方式因运行环境(harness)而异。如果你用了不止一个,就为每个分别安装 Superpowers。

### Claude Code

Superpowers 可通过 [Claude 官方插件市场](https://claude.com/plugins/superpowers)获取。

#### 官方插件市场

- 从 Anthropic 的官方插件市场安装该插件:

  ```bash
  /plugin install superpowers@claude-plugins-official
  ```

#### Superpowers 插件市场

Superpowers 插件市场为 Claude Code 提供了 Superpowers 以及一些其他相关插件。

- 注册这个插件市场:

  ```bash
  /plugin marketplace add obra/superpowers-marketplace
  ```

- 从这个插件市场安装该插件:

  ```bash
  /plugin install superpowers@superpowers-marketplace
  ```

### Antigravity

从本仓库以插件形式安装 Superpowers:

```bash
agy plugin install https://github.com/obra/superpowers
```

Antigravity 会运行该插件的 session-start 钩子,所以从第一条消息起 Superpowers
就已经生效了。用同样的命令重新安装即可更新。

### Codex App

Superpowers 可通过 [Codex 官方插件市场](https://github.com/openai/plugins)获取。

- 在 Codex app 中,点击侧边栏里的 Plugins。
- 你应该能在 Coding 分类里看到 `Superpowers`。
- 点击 Superpowers 旁边的 `+`,然后按提示操作。

### Codex CLI

Superpowers 可通过 [Codex 官方插件市场](https://github.com/openai/plugins)获取。

- 打开插件搜索界面:

  ```bash
  /plugins
  ```

- 搜索 Superpowers:

  ```bash
  superpowers
  ```

- 选择 `Install Plugin`。

### Cursor

- 在 Cursor Agent 聊天中,从插件市场安装:

  ```text
  /add-plugin superpowers
  ```

- 或者在插件市场里搜索 "superpowers"。

### Factory Droid

- 注册这个插件市场:

  ```bash
  droid plugin marketplace add https://github.com/obra/superpowers
  ```

- 安装该插件:

  ```bash
  droid plugin install superpowers@superpowers
  ```

### Gemini CLI

- 安装扩展:

  ```bash
  gemini extensions install https://github.com/obra/superpowers
  ```

- 之后更新:

  ```bash
  gemini extensions update superpowers
  ```

### GitHub Copilot CLI

- 注册这个插件市场:

  ```bash
  copilot plugin marketplace add obra/superpowers-marketplace
  ```

- 安装该插件:

  ```bash
  copilot plugin install superpowers@superpowers-marketplace
  ```

### Kimi Code

Superpowers 可在 Kimi Code 的插件市场中获取。

- 打开 Kimi Code 的插件管理器:

  ```text
  /plugins
  ```

- 进入 `Marketplace` > `Superpowers` 并安装它。

- 或者直接从本仓库安装:

  ```text
  /plugins install https://github.com/obra/superpowers
  ```

- 详细文档:[docs/README.kimi.md](docs/README.kimi.md)

### OpenCode

OpenCode 使用它自己的插件安装方式;即使你已经在别的运行环境(harness)里用过 Superpowers,
也要单独为它安装。

- 告诉 OpenCode:

  ```
  Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md
  ```

- 详细文档:[docs/README.opencode.md](docs/README.opencode.md)

### Pi

从本仓库以 Pi 包的形式安装 Superpowers:

```bash
pi install git:github.com/obra/superpowers
```

如果要做本地开发,可以把这个检出(checkout)作为临时包加载来运行 Pi:

```bash
pi -e /path/to/superpowers
```

这个 Pi 包会加载 Superpowers 的各项技能,以及一个小扩展——它会在会话启动时、以及每次压缩(compaction)之后,把 `using-superpowers` 引导程序注入进来。Pi 原生支持技能,所以不需要兼容用的 `Skill` 工具。子 Agent 和任务清单相关的工具仍然是可选的 Pi 配套包。

## 基础工作流

1. **brainstorming** —— 在写代码之前激活。通过提问打磨粗糙的想法,探索各种备选方案,分小节呈现设计供你确认。保存设计文档。

2. **using-git-worktrees** —— 在设计通过之后激活。在新分支上创建隔离的工作空间,运行项目初始化,并验证测试基线是干净的。

3. **writing-plans** —— 在设计通过后激活。把工作拆成一口能吃下的小任务(每个 2-5 分钟)。每个任务都有确切的文件路径、完整的代码和验证步骤。

4. **subagent-driven-development** 或 **executing-plans** —— 有了计划后激活。为每个任务派发一个全新的子 Agent,配以两阶段评审(先看是否符合 spec,再看代码质量),或者分批执行并带上人工检查点。

5. **test-driven-development** —— 在实现过程中激活。强制执行 RED-GREEN-REFACTOR(红-绿-重构):写一个会失败的测试,看着它失败,写出最小可用的代码,看着它通过,然后提交。会删掉在测试之前写下的代码。

6. **requesting-code-review** —— 在任务之间激活。对照计划做评审,按严重程度报告问题。关键问题会阻断后续进展。

7. **finishing-a-development-branch** —— 在任务完成时激活。验证测试,呈现各种选项(合并/PR/保留/丢弃),并清理 worktree。

**Agent 在做任何任务之前,都会检查有没有相关的技能。** 这些是强制性的工作流,不是建议。

## 里面都有什么

### 技能库

**测试**
- **test-driven-development** —— RED-GREEN-REFACTOR(红-绿-重构)循环(包含测试反模式参考)

**调试**
- **systematic-debugging** —— 4 阶段根因分析流程(包含 root-cause-tracing、defense-in-depth、condition-based-waiting 等技巧)
- **verification-before-completion** —— 确认它是真的修好了

**协作**
- **brainstorming** —— 苏格拉底式的设计打磨
- **writing-plans** —— 详尽的实现计划
- **executing-plans** —— 带检查点的分批执行
- **dispatching-parallel-agents** —— 并发的子 Agent 工作流
- **requesting-code-review** —— 评审前检查清单
- **receiving-code-review** —— 回应反馈
- **using-git-worktrees** —— 并行的开发分支
- **finishing-a-development-branch** —— 合并/PR 的决策工作流
- **subagent-driven-development** —— 配以两阶段评审的快速迭代(先看是否符合 spec,再看代码质量)

**元(Meta)**
- **writing-skills** —— 按最佳实践创建新技能(包含测试方法论)
- **using-superpowers** —— 技能系统入门介绍

## 理念

- **测试驱动开发(TDD)** —— 永远先写测试
- **系统化胜过临时凑合** —— 靠流程,而不是靠猜
- **降低复杂度** —— 把简单当作首要目标
- **证据胜过口头声称** —— 在宣布成功之前先做验证

阅读[最初的发布公告](https://blog.fsck.com/2025/10/09/superpowers/)。

## 参与贡献

Superpowers 的一般贡献流程如下。请记住,我们通常不接受新增技能的贡献,而且对技能的任何更新都必须在我们支持的所有编码 Agent 上都能正常工作。

1. Fork 本仓库
2. 切换到 'dev' 分支
3. 为你的工作创建一个分支
4. 遵循 `writing-skills` 技能来创建和测试新技能或修改后的技能
5. 提交一个 PR,记得填好 pull request 模板。

技能行为测试使用来自 [superpowers-evals](https://github.com/prime-radiant-inc/superpowers-evals/) 的 drill 评估工具,它被克隆到 `evals/` 目录 —— 关于如何配置,参见 `evals/README.md`。插件基础设施的测试位于 `tests/`,通过相应的 `run-*.sh` 或 `npm test` 运行。

完整指南参见 `skills/writing-skills/SKILL.md`。

## 更新

Superpowers 的更新方式在一定程度上取决于所用的编码 Agent,不过通常是自动的。

## 许可证

MIT License —— 详见 LICENSE 文件。

## 可视化伴随功能的遥测(telemetry)

因为技能和插件不会给创作者提供任何反馈,我们完全不知道你们当中有多少人在用 Superpowers。默认情况下,brainstorming 那个可选的可视化伴随功能上的 Prime Radiant logo 是从我们网站加载的。它会带上正在使用的 Superpowers 版本。它不会包含任何关于你的项目、prompt 或编码 Agent 的细节。我们看不到你的点击,也看不到任何关于你在做什么东西的信息。这能帮我们对有多少人在用 Superpowers、以及他们用的是哪个版本,有个大致的了解。它 100% 是可选的。要关闭它,把环境变量 `SUPERPOWERS_DISABLE_TELEMETRY` 设为任意为真的值即可。Superpowers 同样也尊重 Claude Code 的 `DISABLE_TELEMETRY` 和 `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` 这两个退出选项。

## 社区

Superpowers 由 [Jesse Vincent](https://blog.fsck.com) 以及 [Prime Radiant](https://primeradiant.com) 的其他伙伴们打造。

- **Discord**:[加入我们](https://discord.gg/35wsABTejz),获取社区支持、提问,并分享你正在用 Superpowers 做的东西
- **Issues**:https://github.com/obra/superpowers/issues
- **发布公告**:[订阅](https://primeradiant.com/superpowers/)以便在有新版本时收到通知
