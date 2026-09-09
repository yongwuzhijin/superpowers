# dmon-tdd-engineering 设计方案

- 日期：2026-09-09
- 状态：已确认，待编写实施计划
- 基线：obra/superpowers v6.3.0 fork（yongwuzhijin/superpowers），skill 正文已汉化
- 分支：`refactor/dmon-tdd-engineering`

---

## 1. 背景与问题

当前仓库是 superpowers 的汉化 fork。它在实际使用中暴露了三个问题：

**问题一：强制触发，无法关闭。** `hooks/session-start` 会在每次会话开始时把 `skills/using-superpowers/SKILL.md`（3.1KB）全文注入上下文，外层包 `<EXTREMELY_IMPORTANT>`，正文里写着"哪怕只有 1% 的可能某个技能适用，你就绝对必须调用"。结果是无论用户在做什么——哪怕只是问一个简单问题——框架都会介入。用户没有"这次不用它"的选项。

**问题二：污染 skill 列表。** 14 个 skill 各占一个目录，全部注册进 harness 的 skill 列表。叠加用户机器上已有的 `ddd-*`（18 个）和 `auxpc-*` 等，`~/.claude/skills/` 下已有 60+ 个 skill。列表过长既降低模型的选择准确率，也让用户无从分辨。

**问题三：命名与生态不符。** 项目要并入用户的 dmon 生态，但全仓库 100 个文件、1087 处硬编码 `superpowers`，产物目录是 `docs/superpowers/` 和 `.superpowers/`。

## 2. 目标

1. 项目更名为 **dmon-tdd-engineering**，彻底与 upstream 分家
2. 框架**默认不生效**，仅通过 slash command 或关键词显式触发
3. 14 个 skill **合并为 1 个**，harness 的 skill 列表里只出现一条
4. 产物目录统一到 dmon 命名
5. `brainstorming` 更名为语义更准确的 `requirement-specify`（需求澄清）

## 3. 非目标

- **不重写 skill 正文。** 这些文本是经过对抗性调校的行为约束内容，改动风险极高。本次只搬位置、改链接、改命名，正文一个字不动。
- **不维护 upstream 兼容。** 改造后无法再从 obra/superpowers 合并更新，`upstream` remote 移除。
- 不新增任何第三方依赖（延续零依赖设计）。

## 4. 核心设计原则

> **强制力不消失，只是作用域从"会话级"收窄到"流程级"。**

未触发时，框架完全不存在于上下文中。**一旦被触发**，路由 SKILL.md 及其 references 里仍然保留原有的强硬约束语气——HARD-GATE、危险信号（Red Flags）表、"你没得选"、"这没有商量余地"——这套纪律在本次托管流程内全程生效。

这条原则是不可妥协的。框架的全部价值都来自那些经过调校的行为约束文本；如果触发后语气也软化，剩下的只是一堆没有约束力的文档。

## 5. 决策记录

| 决策项 | 结论 | 理由 |
|---|---|---|
| 支持的 harness | Cursor + Claude Code + Codex | 用户日常使用；其余 6 套适配层维护成本高于价值 |
| 与 `ddd-*` 的关系 | 替代。装上本框架后卸载 `ddd-*` | 正是"不想装那么多 skill"要解决的痛点 |
| 合并形态 | 1 个 skill 目录 + 路由 SKILL.md + references 分阶段 | 14 份 md 共 290KB，物理上无法塞进单文件 |
| 阶段划分 | 6 阶段 + shared 横向能力 | 见 §7 |
| `writing-skills` | 删除 | 91KB 的元技能，与 TDD 开发主线无关 |
| `dispatching-parallel-agents` | 保留，归入 shared | 横向能力，多阶段可用 |
| 触发机制 | 极简 sessionStart bootstrap + `commands/` | 见 §6，受 harness 能力约束 |
| 产物目录 | `docs/dmon/{specs,plans}` + `.dmon/{sdd,brainstorm}` | 文档可见可 review，工作区隐藏且 gitignore |
| 改名范围 | 本地目录 + GitHub 仓库名 + 全部 manifest，移除 upstream remote | 彻底分家 |
| commands | 1 总入口 + 6 阶段入口 | 见 §8 |
| 版本号 | 重置为 1.0.0 | 新项目，继承 6.3.0 会误导 |
| upstream 历史文档 | 删除 `RELEASE-NOTES.md` 和 `docs/superpowers/` | git 历史可查，工作区保持干净 |

## 6. 触发机制

### 6.1 harness 能力边界（已核实）

| harness | 会话开始注入 | 用户发消息时确定性拦截并注入 |
|---|---|---|
| Cursor | `sessionStart` → `additional_context` ✅ | ❌ `beforeSubmitPrompt` 只能返回 `continue` / `user_message`，无注入字段 |
| Claude Code | `SessionStart` → `hookSpecificOutput.additionalContext` ✅ | ✅ `UserPromptSubmit` 支持 `additionalContext` |
| Codex | ❌ 无 hook 机制（现 manifest `hooks: {}` 即刻意关闭） | ❌ |

**结论：** 确定性关键词硬开关只有 Claude Code 做得到。为保证三端行为一致，统一采用**软触发**：sessionStart 注入一段极简说明，由模型自行判断是否命中触发条件。已明确放弃 Claude Code 上的硬开关方案（会造成三端行为不一致 + 额外维护一套逻辑）。

### 6.2 触发链路

```
会话开始
  └─ sessionStart hook 注入 ~15 行极简提示（不含任何框架内容）

用户打 /dmon-spec              用户说「用 dmon tdd 全托管开发这个需求」
       │                                      │
       └────────→ 加载 skills/dmon-tdd/SKILL.md ←────────┘
                            │
                 路由到对应阶段，Read references/<阶段>/
                            │
                 按原有强纪律执行该阶段
```

### 6.3 bootstrap 内容规格

`hooks/session-start` 不再读取任何 SKILL.md 全文，改为输出固定的极简文本，约束如下：

- 长度不超过 20 行
- 必须说明：框架已安装、**默认不生效**、触发条件（命令清单 + 关键词清单）、未触发时的行为要求
- 必须明确"不要主动提及本框架、不要询问是否启用"，避免模型在未触发时反复推销
- 三端 JSON 字段分支逻辑（`additional_context` / `hookSpecificOutput.additionalContext` / `additionalContext`）保持现有实现不变

**触发关键词清单**（初版，实施时写入 bootstrap 与 SKILL.md）：
`dmon tdd`、`dmon 开发`、`全托管开发`、`托管开发`、`tdd 全托管`

## 7. 目录结构

```
dmon-tdd-engineering/
├── skills/dmon-tdd/
│   ├── SKILL.md                       # 唯一注册的 skill：分阶段路由表（新写）
│   └── references/
│       ├── 1-requirement-specify/     # 需求澄清
│       ├── 2-planning/                # 计划
│       ├── 3-implementation/          # 实现（推进计划的执行策略）
│       ├── 4-debugging/               # 调试
│       ├── 5-review/                  # 评审
│       ├── 6-finishing/               # 收尾
│       ├── shared/                    # 横向能力，任何阶段可调
│       └── platform/                  # harness 工具名映射
├── commands/                          # 新建，7 个 slash command
├── hooks/                             # session-start（极简化）、run-hook.cmd、两份 hooks 配置
├── .claude-plugin/                    # 保留
├── .cursor-plugin/                    # 保留
├── .codex-plugin/                     # 保留
├── .agents/plugins/marketplace.json   # 保留（Codex/Agents marketplace）
├── assets/                            # 图标改名
├── scripts/                           # bump-version、lint-shell、codex 打包/同步
├── tests/                             # 精简后见 §11
└── docs/dmon/{specs,plans}
```

**删除的目录与文件：** `.devin-plugin/`、`.hermes-plugin/`、`.kimi-plugin/`、`.opencode/`、`.pi/`、`gemini-extension.json`、`GEMINI.md`、`RELEASE-NOTES.md`、`docs/superpowers/`、`docs/plans/`、`docs/README.kimi.md`、`docs/README.opencode.md`、`skills/writing-skills/`。

## 8. 内容迁移映射

### 8.1 主体映射（14 份 skill）

| 原 skill | 目标位置 | 处理 |
|---|---|---|
| `brainstorming` | `references/1-requirement-specify/` | 保留，更名 |
| `writing-plans` | `references/2-planning/` | 保留 |
| `executing-plans` | `references/3-implementation/executing-plans.md` | 保留 |
| `subagent-driven-development` | `references/3-implementation/subagent-driven-development.md` | 保留 |
| `systematic-debugging` | `references/4-debugging/` | 保留 |
| `requesting-code-review` | `references/5-review/requesting-code-review.md` | 保留 |
| `receiving-code-review` | `references/5-review/receiving-code-review.md` | 保留 |
| `verification-before-completion` | `references/5-review/verification-before-completion.md` | 保留 |
| `finishing-a-development-branch` | `references/6-finishing/` | 保留 |
| `test-driven-development` | `references/shared/test-driven-development.md` | 保留，横向 |
| `using-git-worktrees` | `references/shared/using-git-worktrees.md` | 保留，横向 |
| `dispatching-parallel-agents` | `references/shared/dispatching-parallel-agents.md` | 保留，横向 |
| `using-superpowers` | 吸收进 `skills/dmon-tdd/SKILL.md` | 内容转化为路由层骨架 |
| `writing-skills` | 删除 | 与主线无关 |

三个横向能力独立成 `shared/` 而非塞进 `3-implementation/`，是因为它们跨阶段可用——例如 `using-git-worktrees` 应在计划确定后、动手之前就启用，放进"实现阶段"会误导路由。

### 8.2 附属文件映射

| 附属文件 | 归属 | 处理 |
|---|---|---|
| `brainstorming/spec-document-reviewer-prompt.md` | 1-requirement-specify | 保留 |
| `brainstorming/visual-companion.md` | 1-requirement-specify | 保留，内含 `.superpowers/brainstorm` 路径需改 |
| `brainstorming/scripts/*`（5 个） | 1-requirement-specify/scripts | 保留，`start-server.sh` / `stop-server.sh` 内含路径需改 |
| `writing-plans/plan-document-reviewer-prompt.md` | 2-planning | 保留 |
| `subagent-driven-development/{implementer,task-reviewer,re-review}-prompt.md` | 3-implementation | 保留 |
| `subagent-driven-development/scripts/{sdd-workspace,task-brief,review-package}` | 3-implementation/scripts | 保留，均含 `.superpowers/sdd` 路径需改 |
| `systematic-debugging/{root-cause-tracing,defense-in-depth,condition-based-waiting}.md` | 4-debugging | 保留，被 SKILL.md 正文引用 |
| `systematic-debugging/condition-based-waiting-example.ts` | 4-debugging | 保留 |
| `systematic-debugging/find-polluter.sh` | 4-debugging | 保留，有对应测试 |
| `systematic-debugging/{test-pressure-1,2,3、test-academic}.md`、`CREATION-LOG.md` | — | **删除**：skill 开发过程的测试记录与创建日志，非运行时内容，且未被 SKILL.md 引用 |
| `requesting-code-review/code-reviewer.md` | 5-review | 保留 |
| `test-driven-development/writing-good-tests.md` | shared | 保留 |
| `using-superpowers/references/codex-tools.md` | `references/platform/codex-tools.md` | 保留（Codex 在支持范围内） |
| `using-superpowers/references/{antigravity,gemini,hermes,pi}-tools.md` | — | 删除（对应 harness 已移除） |

### 8.3 文件命名约束（关键）

**`references/` 下任何目录都不得包含名为 `SKILL.md` 的文件。**

Cursor 的 skill 发现规则是"`skills/` 下每个含 `SKILL.md` 的子目录"，Claude Code 与 Codex 同理。若把 `brainstorming/SKILL.md` 原名搬到 `references/1-requirement-specify/SKILL.md`，很可能被递归发现并注册成独立 skill，直接破坏"只注册一个"的核心目标。

因此各阶段主文件统一改用阶段名命名：

```
references/1-requirement-specify/requirement-specify.md
references/2-planning/writing-plans.md
references/4-debugging/systematic-debugging.md
references/6-finishing/finishing-a-development-branch.md
```

阶段 3、5、shared 本就是多文件平铺，天然无此问题。

实施时必须实测验证：三端加载插件后，skill 列表中确实只出现 `dmon-tdd` 一条。这是本次改造的验收硬指标之一。

### 8.4 链接完整性

搬迁会打断所有跨文件相对链接。实施时必须逐一修正，并新增一个测试断言"所有 md 内的相对链接目标文件存在"（见 §11.3-2）。

## 9. commands 设计

Cursor 的 slash command 是**全局命名空间**（不按插件隔离），因此全部文件名带 `dmon-` 前缀防冲突。命令 slug 取文件名 stem。

| 命令 | 文件 | 职责 |
|---|---|---|
| `/dmon-tdd` | `commands/dmon-tdd.md` | 全托管：需求澄清 → 计划 → 实现 → 评审 → 收尾 全流程 |
| `/dmon-spec` | `commands/dmon-spec.md` | 仅阶段 1，需求澄清 |
| `/dmon-plan` | `commands/dmon-plan.md` | 仅阶段 2，编写实施计划 |
| `/dmon-impl` | `commands/dmon-impl.md` | 仅阶段 3，执行计划 |
| `/dmon-debug` | `commands/dmon-debug.md` | 仅阶段 4，系统化调试 |
| `/dmon-review` | `commands/dmon-review.md` | 仅阶段 5，代码评审与完成前验证 |
| `/dmon-finish` | `commands/dmon-finish.md` | 仅阶段 6，分支收尾 |

**command 文件必须是薄壳**（约 10 行）：只负责"加载 `dmon-tdd` skill 并进入第 N 阶段"，不复制任何阶段正文。这样命令与 skill 内容不会漂移——这是唯一真相源原则。

每个文件需含 YAML frontmatter 的 `description`（Cursor 命令选择器展示用）。参数占位符（`$ARGUMENTS`）在三端的支持情况需在实施时实测确认。

三端注册方式：`.cursor-plugin/plugin.json` 声明 `"commands": "./commands/"`；Claude Code 按约定自动发现 `commands/`；Codex 的支持情况需实测。

## 10. 产物落盘

| 产物 | 路径 | git |
|---|---|---|
| 需求 spec | `docs/dmon/specs/YYYY-MM-DD-<topic>-design.md` | commit |
| 实施计划 | `docs/dmon/plans/YYYY-MM-DD-<feature>.md` | commit |
| SDD 执行工作区（账本 / task brief / 评审包） | `.dmon/sdd/<plan-basename>/` | ignore |
| 需求澄清可视化临时文件 | `.dmon/brainstorm/` | ignore |

`.gitignore` 需新增 `.dmon/`，并移除旧的 `.superpowers/`。

## 11. 测试策略

### 11.1 保留并改造

| 测试 | 处理 |
|---|---|
| `tests/hooks/test-session-start.sh` | **重写**：断言输出为极简 bootstrap、不含框架全文、三端 JSON 字段正确 |
| `tests/brainstorm-server/` | 保留，路径断言随 `.dmon/brainstorm` 调整 |
| `tests/codex/`、`tests/codex-plugin-sync/` | 保留，名称随改 |
| `tests/claude-code/` | 保留 SDD / worktree 相关，路径随改 |
| `tests/shell-lint/`、`tests/version-bump/` | 保留 |
| `tests/systematic-debugging/test-find-polluter.sh` | 保留，路径随改 |

### 11.2 删除

`tests/opencode/`、`tests/hermes/`、`tests/kimi/`、`tests/pi/`、`tests/antigravity/`、`tests/writing-skills/`（render-graphs 随 writing-skills 一并删除）。`tests/explicit-skill-requests/` 的存废在实施时按其实际断言内容决定。

### 11.3 新增

1. **路由完整性**：`SKILL.md` 中引用的每个 `references/` 路径都真实存在
2. **链接完整性**：所有 md 内的相对链接目标文件存在（覆盖 §8.3 的搬迁风险）
3. **commands 规范**：7 个文件齐全、文件名带 `dmon-` 前缀、均有非空 `description` frontmatter 与非空正文
4. **单 skill 断言**：`skills/` 下有且仅有一个 `SKILL.md`，路径为 `skills/dmon-tdd/SKILL.md`；`references/` 递归查找 `SKILL.md` 结果必须为空（守住 §8.3 的约束）
5. **命名残留**：全仓库无 `superpowers` 字样（`.git` 与本 spec 除外）

## 12. 命名变更清单

| 项 | 原 | 新 |
|---|---|---|
| 插件名 / 包名 | `superpowers` | `dmon-tdd-engineering` |
| marketplace 名 | `superpowers-dev` | `dmon-tdd-engineering-dev` |
| skill 名 | 14 个 | `dmon-tdd`（单个） |
| bootstrap skill | `using-superpowers` | 无（吸收进路由层） |
| 版本 | 6.3.0 | 1.0.0 |
| 本地目录 | `~/Documents/github/superpowers` | `~/Documents/github/dmon-tdd-engineering` |
| GitHub 仓库 | `yongwuzhijin/superpowers` | `yongwuzhijin/dmon-tdd-engineering` |
| `upstream` remote | `obra/superpowers` | 移除 |
| 图标 | `assets/superpowers-small.svg` | `assets/dmon-tdd-small.svg` |
| 产物目录 | `docs/superpowers/`、`.superpowers/` | `docs/dmon/`、`.dmon/` |
| skill 引用前缀 | `superpowers:brainstorming` | 阶段路径引用 |

`.version-bump.json` 的文件清单需同步（移除已删除的 manifest 条目）。

`README.md` / `README.zh-CN.md`（各 12KB）需重写：安装方式、命令清单、触发机制、与 `ddd-*` 的替代关系。`CLAUDE.md` / `AGENTS.md` 当前是 upstream 的贡献者指南（含"94% PR 拒绝率"等 obra 项目专属内容），需重写为本项目的指南。

## 13. 风险

| 风险 | 影响 | 缓解 |
|---|---|---|
| 软触发不可靠：模型可能在未命中关键词时误触发，或命中了却不加载 | 中 | bootstrap 措辞需明确排他；实施后在三端各做一轮实测（含正例与反例） |
| 搬迁打断相对链接 | 高 | 新增链接完整性测试（§11.3-2），CI 前必跑 |
| `references/` 下残留 `SKILL.md` 导致被递归发现成多个 skill，"只注册一个"目标失效 | 高 | §8.3 命名约束 + §11.3-4 断言 + 三端实测 skill 列表 |
| 脚本内硬编码路径遗漏（`sdd-workspace`、`start-server.sh` 等） | 中 | 命名残留测试（§11.3-5）+ 对脚本单独 grep 复核 |
| 路由层是新写的，可能弱于原 `using-superpowers` 的约束力 | 高 | 遵循 §4 原则，直接复用原文的 Red Flags 表与强制语气，不做"温和化"改写 |
| Codex 对 `commands/` 的支持未经证实 | 低 | 实施时实测；若不支持，Codex 端退化为纯关键词触发 |
| 一次性改动面过大（100 文件 / 1087 处） | 高 | 实施计划需拆成可独立验证的小步，每步跑测试 |

## 14. 遗留待定

1. `$ARGUMENTS` 参数占位符在 Cursor / Claude Code / Codex 三端的实际语法——实施时实测
2. Codex 是否支持 `commands/` 目录——实施时实测
3. `tests/explicit-skill-requests/` 的存废
4. `ddd-*` 的卸载动作由用户自行决定时机，不在本次实施范围内
