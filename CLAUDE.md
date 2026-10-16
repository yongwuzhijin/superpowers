# dmon-tdd-engineering — Agent 指南

## 这是什么

给 coding agent 用的全托管 TDD 开发框架,六个阶段,默认不生效,只注册一个 skill。
面向使用者的说明见 [README.zh-CN.md](README.zh-CN.md)。本文件面向**修改本仓库**的 agent。

## 改动本仓库时的硬约束

- **skill 正文一个字不动。** `skills/dmon-tdd/references/` 下的内容是经过对抗性调校的
  行为约束文本,只允许改位置、链接、命名。要改正文必须先拿出 eval 证据证明是改进。
  尤其不要动危险信号表、"你没得选"、"人类搭档"这类措辞 —— 它们是刻意如此的。
- **`references/` 下不得出现 `SKILL.md`。** 三端都按"含 SKILL.md 的子目录"发现 skill,
  一旦残留就会被注册成第二个 skill,直接破坏"只注册一个"的核心目标。
  阶段主文件用阶段名命名(`requirement-specify.md`、`writing-plans.md` 等)。
  `tests/structure/test-single-skill.sh` 守着这条线。
- **command 必须是薄壳。** 只负责加载 skill 并进入指定阶段,不复制任何阶段正文。
  唯一真相源是 `skills/dmon-tdd/`,命令与 skill 内容漂移是必须避免的。
- **参数占位符只用 `$ARGUMENTS`。** 实测:Cursor 与 Codex 支持 `$1`,
  但 Claude Code 上 `$1` 返回空串。只有 `$ARGUMENTS` 三端一致。
- **`commands` 字段只能写在 `.cursor-plugin/plugin.json`。**
  根目录 `plugin.json` 走 Agent Plugins 标准,只认 skills 与 MCP。
  `.codex-plugin/plugin.json` 不要加 `commands` —— Codex 不认,
  它的命令走 `scripts/install-codex-prompts.sh`。
- **零第三方依赖。** 不引入任何 npm / pip / brew 依赖。
- **动过任何东西之后跑 `bash tests/structure/run-all.sh`。**

## 已知的基线红点

`tests/codex/test-package-codex-plugin.sh` 里的
`zip archive normalizes entry timestamps` 在 UTC+8 机器上必然失败
(期望 `(1980,1,1,0,0,0)`,实际 `(1980,1,1,8,0,0)`)。
这是既有的时区环境问题,与本框架无关,**不要去修它**。
该套件的验收标准是"失败项仍然只有这 1 项"。

## 目录结构

```
dmon-tdd-engineering/
├── skills/dmon-tdd/
│   ├── SKILL.md                    # 唯一注册的 skill:分阶段路由表
│   └── references/
│       ├── 1-requirement-specify/  # 需求澄清(含可视化伴侣与其脚本)
│       ├── system-analysis/        # 系分(需求确认后、计划之前)
│       ├── 2-planning/             # 计划
│       ├── 3-implementation/       # 实现(SDD / 逐步执行 + 三个提示词 + 三个脚本)
│       ├── 4-debugging/            # 调试
│       ├── 5-review/               # 评审(请求 / 接收 / 完成前验证)
│       ├── 6-finishing/            # 收尾
│       ├── shared/                 # TDD、worktree、并行派发
│       └── platform/               # Codex 工具名映射
├── commands/                       # 8 个 dmon- 前缀薄壳命令
├── hooks/                          # session-start(11 行 bootstrap)+ 三端配置
├── scripts/                        # 版本、lint、codex 打包 / 同步 / 命令安装
├── tests/structure/                # 本次改造新增的结构断言
└── docs/dmon/{specs,sys,plans}     # spec、系分、实施计划
```

## 测试

见 [docs/testing.md](docs/testing.md)。主入口 `bash tests/structure/run-all.sh`。
