# Superpowers

Superpowers 是一套为你的编码 Agent 打造的完整软件开发方法论。它由一组可自由组合的技能(skills)构成，再配上一些初始指令，确保你的 Agent 真的会去用它们。

## 我们在招人！

我们正在招募一位全职伙伴，帮我们打理 Superpowers 的社区运营和代码开发。
职位详情请看：https://primeradiant.com/jobs/superpowers-community-engineer/
如果你身边有合适的人选，欢迎把他们介绍给我们。

## 快速上手

给你的 Agent 装上 Superpowers：[Claude Code](#claude-code)、[Antigravity](#antigravity)、[Codex App](#codex-app)、[Codex CLI](#codex-cli)、[Cursor](#cursor)、[Factory Droid](#factory-droid)、[GitHub Copilot CLI](#github-copilot-cli)、[Kimi Code](#kimi-code)、[OpenCode](#opencode)、[Pi](#pi)。

## 它是怎么工作的

从你启动编码 Agent 的那一刻起，一切就开始了。一旦它发现你想做点东西，它*不会*一头扎进去写代码，而是先退一步，问你到底想解决什么问题。

等它从对话里把需求规格(spec)一点点理出来之后，会把内容拆成足够短、你真能读进去的小段，逐段给你看。

你确认设计之后，Agent 会整理出一份实现计划——清晰到即便是一个热情有余、品味欠佳、毫无判断力、不了解项目背景、还讨厌写测试的初级工程师也能照着做。这份计划强调真正的红/绿 TDD、YAGNI(你根本用不上)以及 DRY(不要重复自己)。

接下来，只要你说一声"开始"，它就会启动一套 *subagent-driven-development*(子 Agent 驱动开发)流程：让各个 Agent 逐个攻克工程任务，检查并评审它们的产出，然后继续往前推进。你的 Agent 连续自主工作好几个小时、丝毫不偏离你们一起定下的计划，这种情况并不少见。

系统里还有很多其他内容，但这就是它的核心。而且由于这些技能会自动触发，你不需要做任何特别的操作——你的编码 Agent 天生就自带 Superpowers。

## 商业服务

如果你在企业环境中使用 Superpowers，需要商业支持、额外工具，或是托管式的费用管理，欢迎随时来信 sales@primeradiant.com。

## 安装

不同的运行环境(harness)安装方式各异。如果你同时使用多个环境，请为每一个单独安装 Superpowers。

### Claude Code

Superpowers 可通过 [Claude 官方插件市场](https://claude.com/plugins/superpowers)获取。

#### 官方市场

- 从 Anthropic 官方市场安装插件：

  ```bash
  /plugin install superpowers@claude-plugins-official
  ```

#### Superpowers 市场

Superpowers 市场为 Claude Code 提供 Superpowers 以及其他一些相关插件。

- 注册市场：

  ```bash
  /plugin marketplace add obra/superpowers-marketplace
  ```

- 从该市场安装插件：

  ```bash
  /plugin install superpowers@superpowers-marketplace
  ```

### Antigravity

从本仓库以插件形式安装 Superpowers：

```bash
agy plugin install https://github.com/obra/superpowers
```

Antigravity 会运行插件的 session-start 钩子，因此从第一条消息起 Superpowers 就已生效。想更新时，用同一条命令重新安装即可。

### Codex App

Superpowers 可通过 [Codex 官方插件市场](https://github.com/openai/plugins)获取。

- 在 Codex 应用中，点击侧边栏的 Plugins。
- 你应该能在 Coding 分类下看到 `Superpowers`。
- 点击 Superpowers 旁边的 `+`，按提示操作即可。

### Codex CLI

Superpowers 可通过 [Codex 官方插件市场](https://github.com/openai/plugins)获取。

- 打开插件搜索界面：

  ```bash
  /plugins
  ```

- 搜索 Superpowers：

  ```bash
  superpowers
  ```

- 选择 `Install Plugin`。

### Cursor

- 在 Cursor Agent 聊天中，从市场安装：

  ```text
  /add-plugin superpowers
  ```

- 或者在插件市场中搜索 "superpowers"。

### Factory Droid

- 注册市场：

  ```bash
  droid plugin marketplace add https://github.com/obra/superpowers
  ```

- 安装插件：

  ```bash
  droid plugin install superpowers@superpowers
  ```

### GitHub Copilot CLI

- 注册市场：

  ```bash
  copilot plugin marketplace add obra/superpowers-marketplace
  ```

- 安装插件：

  ```bash
  copilot plugin install superpowers@superpowers-marketplace
  ```

### Kimi Code

Superpowers 已上架 Kimi Code 的插件市场。

- 打开 Kimi Code 的插件管理器：

  ```text
  /plugins
  ```

- 进入 `Marketplace` > `Superpowers` 并安装。

- 或者直接从本仓库安装：

  ```text
  /plugins install https://github.com/obra/superpowers
  ```

- 详细文档：[docs/README.kimi.md](docs/README.kimi.md)

### OpenCode

OpenCode 使用它自己的插件安装机制；即便你已在其他环境里用了 Superpowers，也需要在这里单独安装。

- 告诉 OpenCode：

  ```
  Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md
  ```

- 详细文档：[docs/README.opencode.md](docs/README.opencode.md)

### Pi

从本仓库以 Pi 包的形式安装 Superpowers：

```bash
pi install git:github.com/obra/superpowers
```

若要进行本地开发，可以把这份检出的代码作为临时包加载来运行 Pi：

```bash
pi -e /path/to/superpowers
```

Pi 包会加载 Superpowers 的技能，以及一个小型扩展——它会在会话启动时、以及每次上下文压缩(compaction)之后重新注入 `using-superpowers` 引导程序。Pi 原生支持技能，所以不需要兼容用的 `Skill` 工具。子 Agent 和任务清单工具则是可选的 Pi 配套包。

## 基本工作流

1. **brainstorming(头脑风暴)** —— 在写代码前先激活。通过提问打磨粗糙的想法，探索不同方案，把设计分段呈现供你确认，并保存设计文档。

2. **using-git-worktrees(使用 git 工作树)** —— 设计通过后激活。在新分支上创建隔离的工作区，执行项目初始化，验证测试基线是否干净。

3. **writing-plans(编写计划)** —— 拿到已批准的设计后激活。把工作拆成一口大小的小任务(每个 2–5 分钟)。每个任务都有精确的文件路径、完整的代码和验证步骤。

4. **subagent-driven-development(子 Agent 驱动开发)** 或 **executing-plans(执行计划)** —— 拿到计划后激活。为每个任务派发全新的子 Agent，配合两阶段评审(先看是否符合 spec，再看代码质量)；或者分批执行并设置人工检查点。

5. **test-driven-development(测试驱动开发)** —— 在实现阶段激活。强制执行"红-绿-重构"：先写一个失败的测试，看着它失败，写最少量的代码，看着它通过，然后提交。测试之前写的代码会被删掉。

6. **requesting-code-review(请求代码评审)** —— 在任务之间激活。对照计划进行评审，按严重程度报告问题。严重问题会阻断后续进展。

7. **finishing-a-development-branch(收尾开发分支)** —— 任务完成时激活。验证测试，给出选项(合并 / 提 PR / 保留 / 丢弃)，并清理工作树。

**Agent 在执行任何任务前都会先检查是否有相关技能。** 这些是强制性的工作流，而非建议。

## 里面都有什么

### 技能库

**测试**
- **test-driven-development** —— 红-绿-重构循环(含测试反模式参考)

**调试**
- **systematic-debugging** —— 四阶段根因分析流程(含 root-cause-tracing、defense-in-depth、condition-based-waiting 等技巧)
- **verification-before-completion** —— 确保问题真的被修好了

**协作**
- **brainstorming** —— 苏格拉底式的设计打磨
- **writing-plans** —— 详尽的实现计划
- **executing-plans** —— 带检查点的分批执行
- **dispatching-parallel-agents** —— 并发子 Agent 工作流
- **requesting-code-review** —— 评审前检查清单
- **receiving-code-review** —— 回应评审反馈
- **using-git-worktrees** —— 并行开发分支
- **finishing-a-development-branch** —— 合并/PR 决策工作流
- **subagent-driven-development** —— 配合两阶段评审(先 spec 合规、再代码质量)的快速迭代

**元(Meta)**
- **writing-skills** —— 遵循最佳实践创建新技能(含测试方法论)
- **using-superpowers** —— 技能系统入门介绍

## 理念

- **测试驱动开发** —— 永远先写测试
- **系统化优于临时起意** —— 用流程，别靠猜
- **降低复杂度** —— 把简洁作为首要目标
- **证据优于口头断言** —— 宣布成功前先验证

阅读[最初的发布公告](https://blog.fsck.com/2025/10/09/superpowers/)。

## 参与贡献

Superpowers 的一般贡献流程如下。请注意，我们通常不接受新增技能的贡献，而且对技能的任何改动都必须在我们支持的所有编码 Agent 上都能正常工作。

1. Fork 本仓库
2. 切换到 'dev' 分支
3. 为你的工作创建一个分支
4. 遵循 `writing-skills` 技能来创建和测试新增或修改的技能
5. 提交 PR，务必填写好 PR 模板。

技能行为测试使用来自 [superpowers-evals](https://github.com/prime-radiant-inc/superpowers-evals/) 的 drill 评测框架，克隆到 `evals/` 目录——搭建方法见 `evals/README.md`。插件基础设施测试位于 `tests/`，通过对应的 `run-*.sh` 或 `npm test` 运行。

完整指南见 `skills/writing-skills/SKILL.md`。

## 更新

Superpowers 的更新在一定程度上取决于具体的编码 Agent，但通常是自动完成的。

## 许可证

MIT 许可证 —— 详见 LICENSE 文件。

## 可视化伴侣的遥测(telemetry)

由于技能和插件并不会给创作者任何反馈，我们其实并不知道你们当中有多少人在使用 Superpowers。默认情况下，brainstorming 那个可选的可视化伴侣功能上的 Prime Radiant logo 会从我们的网站加载，其中包含正在使用的 Superpowers 版本号。它*不会*包含任何关于你项目、提示词或编码 Agent 的信息。我们看不到你的点击，也看不到你在构建什么。这只是帮我们大致了解有多少人在用 Superpowers、用的是哪个版本。这项功能 100% 可选。想关闭它，把环境变量 `SUPERPOWERS_DISABLE_TELEMETRY` 设为任意为真的值即可。Superpowers 同样尊重 Claude Code 的 `DISABLE_TELEMETRY` 和 `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` 退出选项。

## 社区

Superpowers 由 [Jesse Vincent](https://blog.fsck.com) 以及 [Prime Radiant](https://primeradiant.com) 的其他伙伴共同打造。

- **Discord**：[加入我们](https://discord.gg/35wsABTejz)，获取社区支持、提问，并分享你用 Superpowers 做的东西
- **Issues**：https://github.com/obra/superpowers/issues
- **发布通知**：[订阅](https://primeradiant.com/superpowers/)以获取新版本通知
