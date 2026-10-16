[English](README.md)

# dmon-tdd-engineering

给 coding agent 用的全托管 TDD 开发框架。覆盖需求澄清、计划、实现、调试、评审、收尾六个阶段。

## 它和别的 skill 框架不一样的地方

**默认不生效。** 会话开始时只注入 11 行说明,告诉模型框架存在以及什么条件下才该加载它。
不触发就完全不占上下文,也不会插手你的日常提问 —— 不会主动推销,不会问你要不要启用。

**只注册一个 skill。** 六个阶段的内容都在 `skills/dmon-tdd/references/` 下,
harness 的 skill 列表里只出现 `dmon-tdd` 一条,不污染你的命令面板。

**触发后纪律全程强制。** 一旦进入流程,阶段文件里的行为约束(危险信号表、
"你没得选"、"这没有商量余地")在本次流程内全程生效,直到流程结束。
强制力没有消失,只是作用域从"会话级"收窄到"流程级"。

## 支持的 harness

Cursor、Claude Code、Codex。

## 安装

### Cursor

```bash
git clone https://github.com/yongwuzhijin/dmon-tdd-engineering.git \
  ~/Documents/github/dmon-tdd-engineering
```

在 Cursor 里通过本地插件方式加载该目录。插件经 `.cursor-plugin/plugin.json`
注册 skill、命令与 sessionStart hook,装完即可用。

如果 `/dmon-*` 命令没出现在 `/` 菜单里,检查 Cursor 设置中
「Include third-party Plugins, Skills, and configs」开关 ——
插件提供的 command 依赖这个开关,而 skill 不依赖。

### Claude Code

```bash
claude plugin marketplace add ~/Documents/github/dmon-tdd-engineering
claude plugin install dmon-tdd-engineering
```

Claude Code 会自动发现根目录的 `commands/` 与 `skills/`,并按
`hooks/hooks.json` 注册 SessionStart hook。

### Codex

Codex 插件只能携带 `skills/`,**无法随包发布 slash command**
(canonical Codex plugin 一律只带 skills,本仓库的
`scripts/sync-to-codex-plugin.sh` 也把 `/commands/` 列在不发布目录里)。
所以装完插件后要多跑一步,把命令拷进用户级提示词目录:

```bash
bash scripts/install-codex-prompts.sh
```

它会把 8 个命令复制到 `${CODEX_HOME:-$HOME/.codex}/prompts/`。
之后 `/dmon-tdd` 等命令在 Codex 里就能用,`$ARGUMENTS` 也会正常替换。

Codex 没有 hook 机制,所以在 Codex 上只有命令触发,没有 sessionStart 软触发。

## 怎么触发

### 命令(8 个)

| 命令 | 作用 |
|---|---|
| `/dmon-tdd` | 全托管:需求澄清 → 系分 → 计划 → 实现 → 评审 → 收尾 |
| `/dmon-spec` | 只做阶段 1,需求澄清 |
| `/dmon-sys` | 需求确认后写系分:设计、兼容、发布、排期 |
| `/dmon-plan` | 只做阶段 2,编写实施计划 |
| `/dmon-impl` | 只做阶段 3,执行计划 |
| `/dmon-debug` | 只做阶段 4,系统化调试 |
| `/dmon-review` | 只做阶段 5,代码评审与完成前验证 |
| `/dmon-finish` | 只做阶段 6,分支收尾 |

命令后面跟的文字会通过 `$ARGUMENTS` 传给流程,例如
`/dmon-spec 给结算页加一个批量导出按钮`。

### 关键词(软触发)

在 Cursor 与 Claude Code 上,说出下列任一关键词也会触发:

`dmon tdd`、`dmon 开发`、`全托管开发`、`托管开发`、`tdd 全托管`

## 六个阶段

| 阶段 | 什么时候用 | 命令 | 文件 |
|---|---|---|---|
| 1 需求澄清 | 做任何创造性工作之前 | `/dmon-spec` | `references/1-requirement-specify/requirement-specify.md` |
| 系分 | 需求已确认、还没拆计划 | `/dmon-sys` | `references/system-analysis/system-analysis.md` |
| 2 计划 | 已有 spec 或系分、还没动代码 | `/dmon-plan` | `references/2-planning/writing-plans.md` |
| 3 实现 | 已有计划要落地 | `/dmon-impl` | `references/3-implementation/{subagent-driven-development,executing-plans}.md` |
| 4 调试 | 碰到 bug、测试失败、非预期行为 | `/dmon-debug` | `references/4-debugging/systematic-debugging.md` |
| 5 评审 | 完成任务、合并之前 | `/dmon-review` | `references/5-review/{requesting,receiving}-code-review.md`、`verification-before-completion.md` |
| 6 收尾 | 实现完成、要决定怎么整合 | `/dmon-finish` | `references/6-finishing/finishing-a-development-branch.md` |

三项横向能力任何阶段都可能被调用:TDD(`references/shared/test-driven-development.md`)、
隔离工作区(`references/shared/using-git-worktrees.md`)、
并行派发(`references/shared/dispatching-parallel-agents.md`)。

## 产物落在哪

| 产物 | 路径 | 是否入 git |
|---|---|---|
| 需求 spec | `docs/dmon/specs/YYYY-MM-DD-<topic>-design.md` | 是 |
| 系分 | `docs/dmon/sys/YYYY-MM-DD-<topic>.md` | 是 |
| 实施计划 | `docs/dmon/plans/YYYY-MM-DD-<feature>.md` | 是 |
| SDD 执行工作区 | `.dmon/sdd/<plan-basename>/` | 否 |
| 需求澄清临时文件 | `.dmon/brainstorm/` | 否 |

记得把 `.dmon/` 加进你项目的 `.gitignore`。

## 和 ddd-* 的关系

本框架替代 `ddd-*` 系列 skill。装上之后可以把它们卸掉 ——
少装 18 个 skill 正是本框架要解决的问题之一。

## 开发与测试

改动本仓库后跑:

```bash
bash tests/structure/run-all.sh
```

完整测试说明见 [docs/testing.md](docs/testing.md),贡献约束见 [CLAUDE.md](CLAUDE.md)。

## 来源

本项目基于一个 MIT 协议的开源 agent 技能框架改造而来,skill 正文经过汉化。
改造内容:合并为单 skill、改为默认不生效、收窄到三个 harness、并入 dmon 命名体系。
已与上游分家,不再合并上游更新。原始版权与溯源信息见 [LICENSE](LICENSE)。
