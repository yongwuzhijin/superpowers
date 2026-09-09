# dmon-tdd-engineering 改造实施计划

> **给 agent 执行者：** 必需子技能：用 `superpowers:subagent-driven-development`（推荐）或 `superpowers:executing-plans` 按任务逐个实施本计划。步骤使用复选框（`- [ ]`）语法跟踪进度。

**Goal:** 把 superpowers 汉化 fork 改造为 dmon-tdd-engineering —— 默认不生效、只注册一个 skill、由 slash command 与关键词显式触发的 TDD 开发框架。

**Architecture:** 14 个独立 skill 目录合并为单个 `skills/dmon-tdd/`，其中 `SKILL.md` 是新写的分阶段路由层，原 skill 正文原封不动地搬进 `references/` 下的 6 个阶段目录 + `shared/` + `platform/`。`hooks/session-start` 从注入 3.1KB 全文改为注入约 11 行的极简说明。7 个薄壳 slash command 作为显式入口，Cursor / Claude Code 由插件 `commands/` 提供，Codex 由安装脚本拷贝到 `~/.codex/prompts/`。

**Tech Stack:** Bash（hooks、脚本、测试）、Node（markdown 结构测试、brainstorm server 测试）、JSON manifest（三端插件声明）、Markdown（skill 与 command 正文）。零第三方依赖。

**设计依据：** `docs/dmon/specs/2026-09-09-dmon-tdd-engineering-design.md`（下称「spec」）。本计划中所有 §N 引用均指该文档。

---

## Global Constraints

- **skill 正文一个字不动。** 只允许改动：文件位置、跨文件链接、命名（`superpowers:X` 引用、产物路径）。禁止重写、精简、"温和化"任何行为约束文本。（spec §3、§4）
- **强制力不消失，只是作用域收窄。** 路由 SKILL.md 必须保留原 `using-superpowers` 的 `<EXTREMELY-IMPORTANT>` 块、危险信号表、"你没得选"、"这没有商量余地"等原文措辞。（spec §4）
- **零第三方依赖。** 不得引入任何新的 npm / pip / brew 依赖。（spec §3）
- **`references/` 下任何目录都不得包含名为 `SKILL.md` 的文件。** 这是「只注册一个 skill」的硬约束。（spec §8.3）
- **支持的 harness 只有三个：** Cursor、Claude Code、Codex。（spec §5）
- **命令文件正文只用 `$ARGUMENTS`，禁止用 `$1` 等位置参数。** 实测结论：Cursor 与 Codex 两者都支持，Claude Code 的 `$1` 返回空串，只有 `$ARGUMENTS` 三端行为一致。
- **`commands` 字段只能写在 `.cursor-plugin/plugin.json`。** 根目录 `plugin.json` 走 Agent Plugins 标准，只认 skills 与 MCP。本仓库根目录无 `plugin.json`，不要新建。
- **每个任务结束必须提交。** 提交信息用中文描述做了什么。
- **产物目录：** 文档产物 `docs/dmon/{specs,plans}`（入 git），工作区产物 `.dmon/{sdd,brainstorm}`（gitignore）。（spec §10）
- **版本号统一为 `1.0.0`。**（spec §5）
- **作者信息统一为：** name `佑平`、email `jace.cj@alibaba-inc.com`、homepage 与 repository `https://github.com/yongwuzhijin/dmon-tdd-engineering`。

## 基线状态（执行前已核实）

在 `refactor/dmon-tdd-engineering` 分支、工作区干净的前提下，下列确定性测试的当前状态：

| 测试 | 基线 |
|---|---|
| `tests/hooks/test-session-start.sh` | PASSED |
| `tests/shell-lint/test-lint-shell.sh` | PASSED |
| `tests/version-bump/test-bump-version.sh` | PASSED |
| `tests/systematic-debugging/test-find-polluter.sh` | PASSED |
| `tests/codex/test-marketplace-manifest.sh` | PASSED |
| `tests/codex-plugin-sync/test-sync-to-codex-plugin.sh` | PASS |
| `tests/claude-code/test-sdd-workspace.sh` | PASS |
| `tests/codex/test-package-codex-plugin.sh` | **FAILED（1 项，基线即红）** |

`test-package-codex-plugin.sh` 的唯一失败项是 `zip archive normalizes entry timestamps`：期望 `(1980, 1, 1, 0, 0, 0)`，实际 `(1980, 1, 1, 8, 0, 0)`。这是本机时区 UTC+8 导致的既有环境问题，与本次改造无关。**执行者不要去修它，也不要因为它而认为自己弄坏了什么**；本计划中凡要求跑该测试的地方，验收标准都是「失败项仍然只有这 1 项」。

本仓库没有 CI，测试按目录手动跑。为方便，先约定一条基线命令，后文以 `<确定性测试全集>` 指代：

```bash
for t in tests/hooks/test-session-start.sh \
         tests/shell-lint/test-lint-shell.sh \
         tests/version-bump/test-bump-version.sh \
         tests/systematic-debugging/test-find-polluter.sh \
         tests/codex/test-marketplace-manifest.sh \
         tests/codex-plugin-sync/test-sync-to-codex-plugin.sh \
         tests/claude-code/test-sdd-workspace.sh; do
  printf "\n===== %s =====\n" "$t"; bash "$t" 2>&1 | tail -3
done
```

---

### Task 1: 清场 —— 删除不支持的 harness、upstream 历史与 writing-skills

**Files:**
- Delete 目录：`.devin-plugin/`、`.hermes-plugin/`、`.kimi-plugin/`、`.opencode/`、`.pi/`、`docs/superpowers/`、`docs/plans/`、`skills/writing-skills/`
- Delete 文件：`gemini-extension.json`、`GEMINI.md`、`RELEASE-NOTES.md`、`docs/README.kimi.md`、`docs/README.opencode.md`、`docs/porting-to-a-new-harness.md`
- Delete 测试：`tests/opencode/`、`tests/hermes/`、`tests/kimi/`、`tests/pi/`、`tests/antigravity/`、`tests/devin/`、`tests/writing-skills/`、`tests/explicit-skill-requests/`
- Delete 附属文件：`skills/using-superpowers/references/{antigravity,gemini,hermes,pi}-tools.md`、`skills/systematic-debugging/{test-pressure-1,test-pressure-2,test-pressure-3,test-academic}.md`、`skills/systematic-debugging/CREATION-LOG.md`
- Modify: `package.json`、`.version-bump.json`、`docs/testing.md`

**Interfaces:**
- Produces: 一个只剩 Cursor / Claude Code / Codex 三端资产的仓库；`skills/` 下剩 13 个 skill 目录；`.version-bump.json` 的 `files` 数组只剩 5 条真实存在的 manifest。后续所有任务都假设这些路径已不存在。

**两处超出 spec 删除清单的决定（执行时照做，无需再确认）：**
- `docs/porting-to-a-new-harness.md`：全文（34 处 `superpowers`）描述如何移植到已被移除的 6 套 harness，保留会留下大片悬空引用。
- `tests/explicit-skill-requests/`：这解决了 spec §14-3 的遗留项。该套件的 9 个 prompt fixture 全部按名字点名 14 个旧 skill（`superpowers:brainstorming` 等），而单 skill 改造后这些名字不复存在，套件前提整体失效。

- [ ] **Step 1: 确认起点干净**

```bash
git status --short
git branch --show-current
```

期望：无输出（工作区干净）；当前分支 `refactor/dmon-tdd-engineering`。

- [ ] **Step 2: 删除 harness 适配层与 upstream 历史文档**

```bash
git rm -r --quiet \
  .devin-plugin .hermes-plugin .kimi-plugin .opencode .pi \
  docs/superpowers docs/plans \
  gemini-extension.json GEMINI.md RELEASE-NOTES.md \
  docs/README.kimi.md docs/README.opencode.md docs/porting-to-a-new-harness.md
```

- [ ] **Step 3: 删除 writing-skills 与失效的附属文件**

```bash
git rm -r --quiet skills/writing-skills
git rm --quiet \
  skills/using-superpowers/references/antigravity-tools.md \
  skills/using-superpowers/references/gemini-tools.md \
  skills/using-superpowers/references/hermes-tools.md \
  skills/using-superpowers/references/pi-tools.md \
  skills/systematic-debugging/test-pressure-1.md \
  skills/systematic-debugging/test-pressure-2.md \
  skills/systematic-debugging/test-pressure-3.md \
  skills/systematic-debugging/test-academic.md \
  skills/systematic-debugging/CREATION-LOG.md
```

- [ ] **Step 4: 删除对应测试套件**

```bash
git rm -r --quiet \
  tests/opencode tests/hermes tests/kimi tests/pi \
  tests/antigravity tests/devin tests/writing-skills \
  tests/explicit-skill-requests
```

- [ ] **Step 5: 验证删除没有留下悬空引用**

```bash
git grep -il -E "opencode|hermes|kimi|antigravity|devin|gemini|writing-skills" -- . ':!docs/dmon'
```

期望：只输出 `skills/using-superpowers/SKILL.md`（它的「平台适配」小节还列着 Pi / Antigravity / Hermes，该文件将在 Task 3 整体重写）和 `docs/testing.md`（下一步处理）。如果输出了别的文件，逐个打开确认是否漏删。

- [ ] **Step 6: 修正 package.json**

`main` 指向已删除的 `.opencode/plugins/superpowers.js`，`pi` 段指向已删除的 `.pi/extensions/superpowers.ts`。改为：

```json
{
  "name": "superpowers",
  "version": "6.3.0",
  "description": "Superpowers skills and runtime bootstrap for coding agents",
  "type": "module",
  "keywords": [
    "skills",
    "tdd",
    "debugging",
    "collaboration",
    "workflow"
  ]
}
```

（`name` / `version` 留到 Task 7 统一改，本步只删失效字段。同时移除 `pi-package` 关键词。）

- [ ] **Step 7: 修正 .version-bump.json**

删掉指向已删除 manifest 的 4 条（hermes / devin / kimi / gemini-extension）：

```json
{
  "files": [
    { "path": "package.json", "field": "version" },
    { "path": ".claude-plugin/plugin.json", "field": "version" },
    { "path": ".cursor-plugin/plugin.json", "field": "version" },
    { "path": ".codex-plugin/plugin.json", "field": "version" },
    { "path": ".claude-plugin/marketplace.json", "field": "plugins.0.version" }
  ],
  "audit": {
    "exclude": [
      "CHANGELOG.md",
      "node_modules",
      ".git",
      ".version-bump.json",
      "scripts/bump-version.sh"
    ]
  }
}
```

（`RELEASE-NOTES.md` 已删除，从 exclude 里一并移除。）

- [ ] **Step 8: 修正 docs/testing.md**

把「Plugin tests」小节里指向已删除套件的条目删掉，只保留真实存在的：

```markdown
## Plugin tests

Live in `tests/`. Currently:

- `tests/brainstorm-server/` — node test suite for the brainstorm server JS code.
- `tests/codex-plugin-sync/` — bash sync verification.
- `tests/codex/` — Codex marketplace manifest and package-archive checks.
- `tests/hooks/` — SessionStart hook output shape.
- `tests/shell-lint/`, `tests/version-bump/` — script-level checks.
- `tests/systematic-debugging/test-find-polluter.sh` — find-polluter helper.
- `tests/claude-code/test-helpers.sh`, `analyze-token-usage.py` — utilities used by remaining bash tests.
- `tests/claude-code/test-subagent-driven-development.sh` — agent-can-describe-SDD test.
- `tests/claude-code/test-subagent-driven-development-integration.sh` — extended SDD integration with token analysis.
- `tests/claude-code/test-worktree-native-preference.sh` — RED-GREEN-REFACTOR validation for the worktree skill.
- `tests/claude-code/test-sdd-workspace.sh` — plan-scoped SDD workspace helper.

Run plugin tests via the relevant directory's script or `npm test`.
```

同时把文件顶部第一段里 `OpenCode plugin loading` 的措辞改为 `codex-plugin sync`，删掉 `Gemini CLI` 的提及。

- [ ] **Step 9: 跑确定性测试全集**

运行前述 `<确定性测试全集>`。

期望：7 项全部 PASSED / PASS。删除动作不应影响任何一项。

- [ ] **Step 10: 跑 codex 打包测试确认失败面没有扩大**

```bash
bash tests/codex/test-package-codex-plugin.sh 2>&1 | tail -3
```

期望：`1 Codex package archive test(s) failed`（仍然只有基线那 1 项时区失败）。

- [ ] **Step 11: 提交**

```bash
git add -A
git commit -m "chore: 删除不支持的 harness 适配层与 upstream 历史文档

移除 devin/hermes/kimi/opencode/pi/gemini 六套适配层及其测试、
writing-skills 元技能、upstream 的 RELEASE-NOTES 与 docs/superpowers 历史文档。
同步修正 package.json、.version-bump.json、docs/testing.md 中的悬空引用。"
```

---

### Task 2: 迁移 —— 13 个 skill 并入 skills/dmon-tdd/references/

**Files:**
- Create: `skills/dmon-tdd/references/{1-requirement-specify,2-planning,3-implementation,4-debugging,5-review,6-finishing,shared,platform}/`
- Move（`git mv`）：见 Step 2–9 的完整映射
- Modify: `skills/dmon-tdd/references/3-implementation/subagent-driven-development.md`（跨阶段链接）、`skills/dmon-tdd/references/shared/writing-good-tests.md`（引用已删除的 writing-skills）、以及所有含 `superpowers:X` 的正文
- Modify: `tests/claude-code/test-worktree-path-policy.sh`、`tests/claude-code/test-sdd-workspace.sh`、`tests/systematic-debugging/test-find-polluter.sh`、`tests/codex/test-package-codex-plugin.sh`、`tests/brainstorm-server/browser-launcher.test.js`、`tests/brainstorm-server/ws-protocol.test.js`、`tests/brainstorm-server/start-server.test.sh`
- Create: `tests/structure/test-single-skill.sh`、`tests/structure/test-link-integrity.sh`、`tests/structure/run-all.sh`

**Interfaces:**
- Produces: `skills/` 下有且仅有一个 `SKILL.md`，路径 `skills/dmon-tdd/SKILL.md`（本任务里它还是 `using-superpowers` 的原文，Task 3 才重写）。8 个 references 子目录就位。阶段主文件命名：`1-requirement-specify/requirement-specify.md`、`2-planning/writing-plans.md`、`4-debugging/systematic-debugging.md`、`6-finishing/finishing-a-development-branch.md`；阶段 3、5、shared、platform 为多文件平铺。
- Produces: `tests/structure/run-all.sh` 作为后续任务反复调用的结构测试入口。

**为什么把 `using-superpowers/SKILL.md` 在本任务就搬到 `skills/dmon-tdd/SKILL.md`：** 「有且仅有一个 SKILL.md」这个不变式必须在每个任务边界上都成立。如果本任务只搬 13 个 skill 而把 bootstrap 留在原处，任务结束时 `skills/` 下会有 2 个 SKILL.md，新增的断言测试会红。所以本任务搬位置，Task 3 改内容。

- [ ] **Step 1: 建目录骨架**

```bash
mkdir -p skills/dmon-tdd/references/{3-implementation/scripts,5-review,shared,platform}
```

（阶段 1、2、4、6 由 `git mv` 整目录产生，不需预建。）

- [ ] **Step 2: 迁移阶段 1（需求澄清）**

```bash
git mv skills/brainstorming skills/dmon-tdd/references/1-requirement-specify
git mv skills/dmon-tdd/references/1-requirement-specify/SKILL.md \
       skills/dmon-tdd/references/1-requirement-specify/requirement-specify.md
```

- [ ] **Step 3: 迁移阶段 2（计划）**

```bash
git mv skills/writing-plans skills/dmon-tdd/references/2-planning
git mv skills/dmon-tdd/references/2-planning/SKILL.md \
       skills/dmon-tdd/references/2-planning/writing-plans.md
```

- [ ] **Step 4: 迁移阶段 3（实现）**

两个 skill 合并进同一目录，所以逐文件搬：

```bash
git mv skills/executing-plans/SKILL.md \
       skills/dmon-tdd/references/3-implementation/executing-plans.md
git mv skills/subagent-driven-development/SKILL.md \
       skills/dmon-tdd/references/3-implementation/subagent-driven-development.md
git mv skills/subagent-driven-development/implementer-prompt.md \
       skills/dmon-tdd/references/3-implementation/implementer-prompt.md
git mv skills/subagent-driven-development/task-reviewer-prompt.md \
       skills/dmon-tdd/references/3-implementation/task-reviewer-prompt.md
git mv skills/subagent-driven-development/re-review-prompt.md \
       skills/dmon-tdd/references/3-implementation/re-review-prompt.md
git mv skills/subagent-driven-development/scripts/sdd-workspace \
       skills/dmon-tdd/references/3-implementation/scripts/sdd-workspace
git mv skills/subagent-driven-development/scripts/task-brief \
       skills/dmon-tdd/references/3-implementation/scripts/task-brief
git mv skills/subagent-driven-development/scripts/review-package \
       skills/dmon-tdd/references/3-implementation/scripts/review-package
```

- [ ] **Step 5: 迁移阶段 4（调试）**

```bash
git mv skills/systematic-debugging skills/dmon-tdd/references/4-debugging
git mv skills/dmon-tdd/references/4-debugging/SKILL.md \
       skills/dmon-tdd/references/4-debugging/systematic-debugging.md
```

- [ ] **Step 6: 迁移阶段 5（评审）**

```bash
git mv skills/requesting-code-review/SKILL.md \
       skills/dmon-tdd/references/5-review/requesting-code-review.md
git mv skills/requesting-code-review/code-reviewer.md \
       skills/dmon-tdd/references/5-review/code-reviewer.md
git mv skills/receiving-code-review/SKILL.md \
       skills/dmon-tdd/references/5-review/receiving-code-review.md
git mv skills/verification-before-completion/SKILL.md \
       skills/dmon-tdd/references/5-review/verification-before-completion.md
```

- [ ] **Step 7: 迁移阶段 6（收尾）**

```bash
git mv skills/finishing-a-development-branch skills/dmon-tdd/references/6-finishing
git mv skills/dmon-tdd/references/6-finishing/SKILL.md \
       skills/dmon-tdd/references/6-finishing/finishing-a-development-branch.md
```

- [ ] **Step 8: 迁移 shared 与 platform**

```bash
git mv skills/test-driven-development/SKILL.md \
       skills/dmon-tdd/references/shared/test-driven-development.md
git mv skills/test-driven-development/writing-good-tests.md \
       skills/dmon-tdd/references/shared/writing-good-tests.md
git mv skills/using-git-worktrees/SKILL.md \
       skills/dmon-tdd/references/shared/using-git-worktrees.md
git mv skills/dispatching-parallel-agents/SKILL.md \
       skills/dmon-tdd/references/shared/dispatching-parallel-agents.md
git mv skills/using-superpowers/references/codex-tools.md \
       skills/dmon-tdd/references/platform/codex-tools.md
```

- [ ] **Step 9: 把 bootstrap 搬到路由位置，确认旧目录已清空**

```bash
git mv skills/using-superpowers/SKILL.md skills/dmon-tdd/SKILL.md
find skills -type d -empty -delete
ls skills/
```

期望 `ls skills/` 只输出 `dmon-tdd`。

- [ ] **Step 10: 修跨阶段相对链接**

搬迁后唯一跨目录的 markdown 链接是 SDD 引用评审员提示词。原文第 259 行 `](../requesting-code-review/code-reviewer.md)` 现在指向不存在的路径：

```bash
perl -pi -e 's{\]\(\.\./requesting-code-review/code-reviewer\.md\)}{](../5-review/code-reviewer.md)}g' \
  skills/dmon-tdd/references/3-implementation/subagent-driven-development.md
grep -n "code-reviewer.md" skills/dmon-tdd/references/3-implementation/subagent-driven-development.md
```

期望：输出的那一行是 `](../5-review/code-reviewer.md)`。

其余同目录内链接（`implementer-prompt.md`、`task-reviewer-prompt.md`、`re-review-prompt.md`、`code-reviewer.md`、`writing-good-tests.md`、`visual-companion.md`、`root-cause-tracing.md`、`defense-in-depth.md`、`condition-based-waiting.md`）搬迁后仍在同一目录，无需改动。

- [ ] **Step 11: 把 `superpowers:X` 引用改写为阶段相对路径**

这些引用原本靠 harness 的 Skill 工具按名字加载，单 skill 后必须改为文件路径。按下表逐条替换，路径相对于**引用它的文件所在目录**：

| 出现位置 | 原引用 | 改为 |
|---|---|---|
| `3-implementation/subagent-driven-development.md`（4 处） | `superpowers:finishing-a-development-branch` | `../6-finishing/finishing-a-development-branch.md` |
| `3-implementation/subagent-driven-development.md` | `superpowers:using-git-worktrees` | `../shared/using-git-worktrees.md` |
| `3-implementation/subagent-driven-development.md` | `superpowers:requesting-code-review` | `../5-review/requesting-code-review.md` |
| `3-implementation/executing-plans.md` | `superpowers:using-git-worktrees` | `../shared/using-git-worktrees.md` |
| `3-implementation/executing-plans.md` | `superpowers:subagent-driven-development` | `subagent-driven-development.md` |
| `3-implementation/executing-plans.md` | `superpowers:finishing-a-development-branch` | `../6-finishing/finishing-a-development-branch.md` |
| `2-planning/writing-plans.md`（2 处） | `superpowers:executing-plans` | `../3-implementation/executing-plans.md` |
| `2-planning/writing-plans.md` | `superpowers:using-git-worktrees` | `../shared/using-git-worktrees.md` |
| `2-planning/writing-plans.md` | `superpowers:subagent-driven-development` | `../3-implementation/subagent-driven-development.md` |
| `4-debugging/systematic-debugging.md` | `superpowers:verification-before-completion` | `../5-review/verification-before-completion.md` |
| `4-debugging/systematic-debugging.md` | `superpowers:test-driven-development` | `../shared/test-driven-development.md` |

改写时保留原句式，只换被引用的标识。例如原文「必需子技能：使用 `superpowers:finishing-a-development-branch`」改为「必需子技能：阅读并遵循 `../6-finishing/finishing-a-development-branch.md`」。

`shared/writing-good-tests.md` 里的 `superpowers:writing-skills` 引用指向已在 Task 1 删除的技能，把整句提及删掉（不要留下指向不存在文件的路径）。

`skills/dmon-tdd/SKILL.md` 里的 `superpowers:brainstorming` / `superpowers:systematic-debugging` 本步不用管，Task 3 整体重写该文件。

验证：

```bash
grep -rn "superpowers:" skills/
```

期望：只剩 `skills/dmon-tdd/SKILL.md` 里的若干条。

- [ ] **Step 12: 修测试脚本里的 skill 路径**

```bash
perl -pi -e 's{skills/using-git-worktrees/SKILL\.md}{skills/dmon-tdd/references/shared/using-git-worktrees.md}g;
             s{skills/finishing-a-development-branch/SKILL\.md}{skills/dmon-tdd/references/6-finishing/finishing-a-development-branch.md}g' \
  tests/claude-code/test-worktree-path-policy.sh

perl -pi -e 's{skills/subagent-driven-development/scripts}{skills/dmon-tdd/references/3-implementation/scripts}g' \
  tests/claude-code/test-sdd-workspace.sh

perl -pi -e 's{skills/systematic-debugging/find-polluter\.sh}{skills/dmon-tdd/references/4-debugging/find-polluter.sh}g' \
  tests/systematic-debugging/test-find-polluter.sh

perl -pi -e 's{skills/brainstorming/scripts}{skills/dmon-tdd/references/1-requirement-specify/scripts}g' \
  tests/brainstorm-server/browser-launcher.test.js \
  tests/brainstorm-server/ws-protocol.test.js \
  tests/brainstorm-server/start-server.test.sh
```

`tests/codex/test-package-codex-plugin.sh` 用 `skills/brainstorming/SKILL.md` 和 `skills/subagent-driven-development/scripts/task-brief` 作为「打包产物里应该有这些文件」的断言样本，手工改为新路径：

- 第 169 行：`skills/brainstorming/SKILL.md` → `skills/dmon-tdd/SKILL.md`
- 第 170 行：`skills/brainstorming/agents/openai.yaml` → `skills/dmon-tdd/agents/openai.yaml`
- 第 182、210 行：`skills/subagent-driven-development/scripts/task-brief` → `skills/dmon-tdd/references/3-implementation/scripts/task-brief`
- 第 125–126、258–260 行的 fixture 构造：把循环里的 skill 名列表改为只有 `dmon-tdd` 一个

- [ ] **Step 13: 写单 skill 断言测试**

创建 `tests/structure/test-single-skill.sh`：

```bash
#!/usr/bin/env bash
# 守住单 skill 改造的核心不变式：全仓库只有一个 SKILL.md，位于
# skills/dmon-tdd/SKILL.md。references/ 下若残留 SKILL.md，会被
# Cursor / Claude Code / Codex 递归发现并注册成第二个 skill。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FAILURES=0

pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }

echo "Single-skill registration tests"

found="$(cd "$REPO_ROOT" && find skills -name SKILL.md | sort | tr '\n' ' ')"
if [[ "$found" == "skills/dmon-tdd/SKILL.md " ]]; then
    pass "skills/ 下有且仅有 skills/dmon-tdd/SKILL.md"
else
    fail "期望只有 skills/dmon-tdd/SKILL.md，实际: $found"
fi

nested="$(cd "$REPO_ROOT" && find skills/dmon-tdd/references -name SKILL.md | sort | tr '\n' ' ')"
if [[ -z "$nested" ]]; then
    pass "references/ 下没有 SKILL.md"
else
    fail "references/ 下存在 SKILL.md: $nested"
fi

for stage in 1-requirement-specify 2-planning 3-implementation 4-debugging \
             5-review 6-finishing shared platform; do
    if [[ -d "$REPO_ROOT/skills/dmon-tdd/references/$stage" ]]; then
        pass "阶段目录存在: $stage"
    else
        fail "缺少阶段目录: $stage"
    fi
done

for main in 1-requirement-specify/requirement-specify.md \
            2-planning/writing-plans.md \
            4-debugging/systematic-debugging.md \
            6-finishing/finishing-a-development-branch.md; do
    if [[ -f "$REPO_ROOT/skills/dmon-tdd/references/$main" ]]; then
        pass "阶段主文件存在: $main"
    else
        fail "缺少阶段主文件: $main"
    fi
done

if [[ "$FAILURES" -gt 0 ]]; then
    echo "STATUS: FAILED ($FAILURES failure(s))"
    exit 1
fi

echo "STATUS: PASSED"
```

```bash
chmod +x tests/structure/test-single-skill.sh
```

- [ ] **Step 14: 跑单 skill 测试，确认通过**

```bash
bash tests/structure/test-single-skill.sh
```

期望：`STATUS: PASSED`。

- [ ] **Step 15: 写链接完整性测试**

创建 `tests/structure/test-link-integrity.sh`：

```bash
#!/usr/bin/env bash
# 搬迁 skill 会打断跨文件相对链接。本测试遍历 skills/ 与 commands/ 下
# 所有 markdown 的相对链接，断言目标文件真实存在。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Markdown relative-link integrity tests"

cd "$REPO_ROOT"
node -e '
const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

const files = execSync("git ls-files -- \"skills/*.md\" \"skills/**/*.md\" \"commands/*.md\"", { encoding: "utf8" })
  .split("\n")
  .filter(Boolean);

let failures = 0;
let checked = 0;

for (const file of files) {
  const text = fs.readFileSync(file, "utf8");
  const linkPattern = /\]\(([^)]+)\)/g;
  let match;
  while ((match = linkPattern.exec(text)) !== null) {
    const target = match[1].trim();
    if (/^(https?:|mailto:|#)/.test(target)) continue;
    const clean = target.split("#")[0];
    if (!clean) continue;
    checked++;
    const resolved = path.join(path.dirname(file), clean);
    if (!fs.existsSync(resolved)) {
      console.log(`  [FAIL] ${file} -> ${target}`);
      failures++;
    }
  }
}

if (failures > 0) {
  console.log(`STATUS: FAILED (${failures} broken link(s))`);
  process.exit(1);
}
console.log(`  [PASS] ${checked} 条相对链接全部可解析`);
console.log("STATUS: PASSED");
'
```

```bash
chmod +x tests/structure/test-link-integrity.sh
```

- [ ] **Step 16: 跑链接完整性测试**

```bash
bash tests/structure/test-link-integrity.sh
```

期望：`STATUS: PASSED`。如果报断链，回到 Step 10/11 补修，不要改测试去迁就。

- [ ] **Step 17: 写结构测试入口**

创建 `tests/structure/run-all.sh`：

```bash
#!/usr/bin/env bash
# 本次改造新增的结构断言集合。后续每个任务结束都应跑一次。
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FAILURES=0

for t in "$SCRIPT_DIR"/test-*.sh; do
    printf '\n===== %s =====\n' "$(basename "$t")"
    if ! bash "$t"; then
        FAILURES=$((FAILURES + 1))
    fi
done

printf '\n'
if [[ "$FAILURES" -gt 0 ]]; then
    echo "STRUCTURE TESTS: FAILED ($FAILURES suite(s))"
    exit 1
fi
echo "STRUCTURE TESTS: PASSED"
```

```bash
chmod +x tests/structure/run-all.sh
bash tests/structure/run-all.sh
```

期望：`STRUCTURE TESTS: PASSED`。

- [ ] **Step 18: 跑受影响的既有测试**

```bash
bash tests/systematic-debugging/test-find-polluter.sh 2>&1 | tail -3
bash tests/claude-code/test-sdd-workspace.sh 2>&1 | tail -3
bash tests/shell-lint/test-lint-shell.sh 2>&1 | tail -3
(cd tests/brainstorm-server && npm test 2>&1 | tail -5)
```

期望：前三项 PASS / passed；brainstorm-server 测试全绿。

- [ ] **Step 19: 提交**

```bash
git add -A
git commit -m "refactor: 13 个 skill 并入 skills/dmon-tdd/references/ 六阶段结构

按 spec §8 映射表搬迁，阶段主文件改名避免 references/ 下残留 SKILL.md。
修复跨阶段相对链接与 superpowers:X 引用，同步更新测试脚本里的 skill 路径。
新增 tests/structure/ 的单 skill 断言与链接完整性断言。"
```

---

### Task 3: 路由层 —— 重写 skills/dmon-tdd/SKILL.md

**Files:**
- Modify: `skills/dmon-tdd/SKILL.md`（整体重写，当前是 `using-superpowers` 原文）
- Create: `tests/structure/test-routing-integrity.sh`

**Interfaces:**
- Consumes: Task 2 建立的 `references/` 目录结构与阶段主文件名。
- Produces: 唯一注册的 skill 正文。它必须保留原 `using-superpowers` 的 `<EXTREMELY-IMPORTANT>` 块与危险信号表原文（spec §4、§13 最后一条风险），并新增 6 阶段路由表。后续 commands 全部指向本文件。

- [ ] **Step 1: 写路由 SKILL.md**

用下面的完整内容覆盖 `skills/dmon-tdd/SKILL.md`。危险信号表逐字取自原 `using-superpowers`，不得改写：

```markdown
---
name: dmon-tdd
description: dmon 全托管 TDD 开发框架。当用户输入 /dmon-tdd、/dmon-spec、/dmon-plan、/dmon-impl、/dmon-debug、/dmon-review、/dmon-finish 中任一命令，或说出「dmon tdd」「dmon 开发」「全托管开发」「托管开发」「tdd 全托管」时使用。覆盖需求澄清、计划、实现、调试、评审、收尾六个阶段。
---

<SUBAGENT-STOP>
如果你是作为子 Agent 被派来执行某个特定任务的,请忽略本技能。
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
本框架默认不生效。但你现在正在读它,说明它已经被触发了。

从这一刻起,直到本次流程结束:如果你觉得哪怕只有 1% 的可能某个阶段适用于你正在做的事,你就绝对必须进入那个阶段。

只要有阶段适用于你的任务,你就没得选。你必须走它的流程。

这没有商量余地。你不能靠给自己找借口来逃避。
</EXTREMELY-IMPORTANT>

## 阶段路由表

先判断用户处在哪个阶段,然后 Read 对应文件并严格照做。文件路径相对于本文件所在目录。

| 阶段 | 什么时候进 | 读这些文件 |
|---|---|---|
| 1 需求澄清 | 要做任何创造性工作之前——新建功能、搭组件、加能力、改行为 | `references/1-requirement-specify/requirement-specify.md` |
| 2 计划 | 已有 spec 或需求、还没动代码 | `references/2-planning/writing-plans.md` |
| 3 实现 | 已有写好的实施计划要落地 | `references/3-implementation/subagent-driven-development.md`(推荐)或 `references/3-implementation/executing-plans.md` |
| 4 调试 | 碰到任何 bug、测试失败或非预期行为,在提出修复方案之前 | `references/4-debugging/systematic-debugging.md` |
| 5 评审 | 完成任务、实现重要特性,或合并之前 | `references/5-review/requesting-code-review.md`、`references/5-review/receiving-code-review.md`、`references/5-review/verification-before-completion.md` |
| 6 收尾 | 实现完成、测试全过,要决定怎么整合这份工作 | `references/6-finishing/finishing-a-development-branch.md` |

## 横向能力(任何阶段都可能用到)

| 能力 | 什么时候用 | 文件 |
|---|---|---|
| TDD | 实现任何功能或修 bug 时,在写实现代码之前 | `references/shared/test-driven-development.md` |
| 隔离工作区 | 计划确定之后、动手之前 | `references/shared/using-git-worktrees.md` |
| 并行派发 | 面临 2 个以上互不依赖、不共享状态的任务 | `references/shared/dispatching-parallel-agents.md` |

## 全托管流程

用户打 `/dmon-tdd` 或说「全托管开发」时,按 1 → 2 → 3 → 5 → 6 顺序走完;中途遇到 bug 插入阶段 4。**每个阶段结束前必须停下来让你的人类搭档确认,确认过了才能进下一阶段。**

## The Rule(规则)

**在任何回应或行动之前,先进入相关阶段** —— 包括澄清性提问、探索代码库、查看文件。

然后宣布"Using dmon-tdd 阶段 N 来 [目的]",并严格遵循该阶段文件。如果它带有清单,就为每一项创建一个 todo。

## 阶段优先级

当多个阶段都适用时,流程类阶段优先 —— 它们定下方法,然后由实现去落实。

- "我们来做 X" → 先阶段 1(需求澄清),再往下走。
- "修这个 bug" → 先阶段 4(系统化调试),再谈修复。

## 危险信号

下面这些念头意味着停 —— 你在给自己找借口:

| 念头 | 现实 |
|---------|---------|
| "这只是个简单问题" | 问题就是任务。检查该进哪个阶段。 |
| "我得先了解更多背景" | 阶段判断在澄清性提问之前。 |
| "让我先探索一下代码库" | 阶段会告诉你怎么探索。先判断。 |
| "我可以快速看一下 git/文件" | 文件里没有对话背景。先判断该进哪个阶段。 |
| "让我先收集信息" | 阶段会告诉你怎么收集信息。 |
| "这用不着走正式流程" | 只要阶段适用,就走它。 |
| "这个流程我记得" | 流程会演进。读当前版本。 |
| "这算不上一个任务" | 有行动 = 有任务。检查该进哪个阶段。 |
| "这个阶段是杀鸡用牛刀" | 简单的事会变复杂。走它。 |
| "我先做这一件事就好" | 做任何事之前先判断。 |
| "这样感觉很有效率" | 无纪律的行动是浪费时间。流程能防止这一点。 |
| "我知道那是什么意思" | 懂概念 ≠ 走流程。进阶段。 |

## 平台适配

如果你的运行环境(harness)是 Codex,阅读 `references/platform/codex-tools.md` 获取工具名映射。Cursor 与 Claude Code 无需额外映射。

## 产物落盘

- 需求 spec:`docs/dmon/specs/YYYY-MM-DD-<topic>-design.md`(提交进 git)
- 实施计划:`docs/dmon/plans/YYYY-MM-DD-<feature>.md`(提交进 git)
- 执行工作区:`.dmon/sdd/<plan-basename>/`(git 忽略)
- 需求澄清临时文件:`.dmon/brainstorm/`(git 忽略)

## 用户指令

用户指令(CLAUDE.md、AGENTS.md 等,以及直接的请求)优先于本框架,而本框架又覆盖默认行为。只有当你的人类搭档明确要求时,才可以跳过流程。
```

- [ ] **Step 2: 写路由完整性测试**

创建 `tests/structure/test-routing-integrity.sh`：

```bash
#!/usr/bin/env bash
# 路由 SKILL.md 里提到的每个 references/ 路径都必须真实存在,
# 否则模型会去 Read 一个不存在的文件然后自由发挥。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Routing integrity tests"

cd "$REPO_ROOT"
node -e '
const fs = require("fs");
const path = require("path");

const skill = "skills/dmon-tdd/SKILL.md";
const text = fs.readFileSync(skill, "utf8");
const refs = [...new Set(text.match(/references\/[A-Za-z0-9._\/-]+\.md/g) || [])];

let failures = 0;

if (refs.length === 0) {
  console.log("  [FAIL] SKILL.md 没有引用任何 references/ 路径");
  failures++;
}

for (const ref of refs) {
  const resolved = path.join("skills/dmon-tdd", ref);
  if (fs.existsSync(resolved)) {
    console.log(`  [PASS] ${ref}`);
  } else {
    console.log(`  [FAIL] SKILL.md 引用了不存在的路径: ${ref}`);
    failures++;
  }
}

// 反向:六个阶段主文件都必须被路由表提到
const required = [
  "references/1-requirement-specify/requirement-specify.md",
  "references/2-planning/writing-plans.md",
  "references/3-implementation/subagent-driven-development.md",
  "references/3-implementation/executing-plans.md",
  "references/4-debugging/systematic-debugging.md",
  "references/5-review/requesting-code-review.md",
  "references/5-review/receiving-code-review.md",
  "references/5-review/verification-before-completion.md",
  "references/6-finishing/finishing-a-development-branch.md",
  "references/shared/test-driven-development.md",
  "references/shared/using-git-worktrees.md",
  "references/shared/dispatching-parallel-agents.md",
  "references/platform/codex-tools.md",
];
for (const req of required) {
  if (!refs.includes(req)) {
    console.log(`  [FAIL] 路由表漏了: ${req}`);
    failures++;
  }
}

if (failures > 0) {
  console.log(`STATUS: FAILED (${failures} failure(s))`);
  process.exit(1);
}
console.log("STATUS: PASSED");
'
```

```bash
chmod +x tests/structure/test-routing-integrity.sh
```

- [ ] **Step 3: 跑结构测试全集**

```bash
bash tests/structure/run-all.sh
```

期望：`STRUCTURE TESTS: PASSED`（三个套件全绿）。

- [ ] **Step 4: 人工核对强制力没有被削弱**

```bash
grep -c "没得选\|没有商量余地\|绝对必须" skills/dmon-tdd/SKILL.md
grep -c "^| \"" skills/dmon-tdd/SKILL.md
```

期望：第一条 ≥ 3；第二条 = 12（危险信号表 12 行全在）。这是 spec §13「路由层可能弱于原 using-superpowers」风险的机械化兜底。

- [ ] **Step 5: 提交**

```bash
git add -A
git commit -m "feat: 新写 dmon-tdd 路由层 SKILL.md

吸收原 using-superpowers 的 EXTREMELY-IMPORTANT 块与 12 行危险信号表原文,
新增 6 阶段路由表、3 项横向能力表与全托管流程说明。
新增路由完整性测试,双向断言 SKILL.md 引用与阶段主文件一一对应。"
```

---

### Task 4: 触发层 —— session-start bootstrap 极简化

**Files:**
- Modify: `hooks/session-start`
- Modify: `tests/hooks/test-session-start.sh`

**Interfaces:**
- Consumes: Task 3 完成的 `skills/dmon-tdd/SKILL.md`（bootstrap 里要提到它的路径）。
- Produces: sessionStart 注入的文本不再包含任何框架正文，只有约 11 行说明。三端 JSON 字段分支逻辑（`additional_context` / `hookSpecificOutput.additionalContext` / `additionalContext`）保持现有实现不变。

- [ ] **Step 1: 先改测试（TDD）**

`tests/hooks/test-session-start.sh` 现有的 `assert_command_output` 已经支持 `EXPECT_CONTAINS` 与 `EXPECT_NOT_CONTAINS`（以 `\037` 分隔），直接复用。把三处 harness 断言的第 3、4 个参数从空串改为实际期望。

把 Claude Code 那条改成：

```bash
claude_home="$(make_home claude-code)"
assert_command_output \
    "Claude Code emits nested SessionStart additionalContext" \
    "nested" \
    "dmon-tdd-engineering" \
    "危险信号"$'\037'"EXTREMELY-IMPORTANT"$'\037'"阶段路由表"$'\037'"没得选" \
    "$claude_home" \
    CLAUDE_PLUGIN_ROOT="$REPO_ROOT" \
    bash "$HOOK_UNDER_TEST"
```

Cursor 与 Copilot 两条同样把第 3 个参数改为 `"dmon-tdd-engineering"`、第 4 个参数改为同一串禁止文本。

再在文件末尾（`if [[ "$FAILURES" -gt 0 ]]` 之前）新增两条断言：

```bash
# bootstrap 必须短。spec §6.3 限定不超过 20 行。
bootstrap_home="$(make_home bootstrap-length)"
bootstrap_output="$(env -i PATH="${PATH:-}" HOME="$bootstrap_home" \
    CLAUDE_PLUGIN_ROOT="$REPO_ROOT" bash "$HOOK_UNDER_TEST")"
bootstrap_lines="$(printf '%s' "$bootstrap_output" | node -e '
const payload = JSON.parse(require("fs").readFileSync(0, "utf8"));
process.stdout.write(String(payload.hookSpecificOutput.additionalContext.split("\n").length));
')"
if [[ "$bootstrap_lines" -le 20 ]]; then
    pass "bootstrap is $bootstrap_lines lines (<= 20)"
else
    fail "bootstrap is $bootstrap_lines lines, expected <= 20"
fi

# bootstrap 不得再读取任何 SKILL.md 全文。
if grep -q "SKILL.md" "$HOOK_UNDER_TEST" && grep -q "cat " "$HOOK_UNDER_TEST"; then
    fail "session-start still reads a SKILL.md file"
else
    pass "session-start no longer reads any SKILL.md"
fi
```

- [ ] **Step 2: 跑测试确认它失败**

```bash
bash tests/hooks/test-session-start.sh 2>&1 | tail -12
```

期望：FAILED，且失败原因是注入内容里含有 `危险信号` / `EXTREMELY-IMPORTANT` 等禁止文本、行数超 20、以及 hook 仍在 cat SKILL.md。这证明测试确实在测新行为。

- [ ] **Step 3: 改写 hooks/session-start**

把第 10–27 行（读取 SKILL.md 并转义的那一段，以及 `session_context=` 赋值）替换为固定文本。改完后文件的前半部分应为：

```bash
#!/usr/bin/env bash
# SessionStart hook for the dmon-tdd-engineering plugin.
#
# 本框架默认不生效。这个 hook 只注入一段极简说明,让模型知道框架存在
# 以及在什么条件下才该加载它。任何框架正文都不在这里注入 —— 全部内容
# 位于 skills/dmon-tdd/,只有被显式触发后才会被读取。

set -euo pipefail

# Escape string for JSON embedding using bash parameter substitution.
escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

read -r -d '' bootstrap_text <<'BOOTSTRAP' || true
本工作区安装了 dmon-tdd-engineering 开发框架(skill 名:dmon-tdd)。它默认不生效。

仅在下列两种情况下,加载 dmon-tdd 技能并按它的流程走:
1. 用户输入了 /dmon-tdd、/dmon-spec、/dmon-plan、/dmon-impl、/dmon-debug、/dmon-review、/dmon-finish 中的任一命令
2. 用户的话里出现「dmon tdd」「dmon 开发」「全托管开发」「托管开发」「tdd 全托管」

除此之外:按你平常的方式工作。不要加载本框架,不要提及它的存在,不要询问用户是否要启用它。

一旦被触发,框架内的全部纪律在本次流程内强制生效,直到流程结束。
BOOTSTRAP

session_context=$(escape_for_json "$bootstrap_text")
```

`PLUGIN_ROOT` / `SCRIPT_DIR` 两个变量在新实现里不再被使用，一并删掉。文件后半部分（第 29 行起的三端 `printf` 分支与 `exit 0`）**原样保留**，一个字不改。

- [ ] **Step 4: 跑测试确认通过**

```bash
bash tests/hooks/test-session-start.sh
```

期望：`STATUS: PASSED`，包含新增的两条断言。

- [ ] **Step 5: 肉眼确认注入内容**

```bash
CLAUDE_PLUGIN_ROOT="$PWD" bash hooks/session-start | node -e '
const p = JSON.parse(require("fs").readFileSync(0, "utf8"));
console.log(p.hookSpecificOutput.additionalContext);
'
```

期望：输出上面那 11 行中文说明，没有任何 skill 正文。

- [ ] **Step 6: 跑 shell lint**

```bash
bash tests/shell-lint/test-lint-shell.sh 2>&1 | tail -3
```

期望：全部通过（新写的 heredoc 与 `read -r -d ''` 不应触发 shellcheck 报错；若报 SC2162 之类，按提示修正后重跑）。

- [ ] **Step 7: 提交**

```bash
git add -A
git commit -m "feat: session-start 改为注入 11 行极简 bootstrap

不再读取并注入 using-superpowers 全文。框架默认不生效,
只声明存在、触发条件与未触发时的行为要求。
三端 JSON 字段分支逻辑保持不变。
测试新增:注入内容不含框架正文、行数 <= 20、hook 不再 cat 任何 SKILL.md。"
```

---

### Task 5: 命令层 —— 7 个薄壳 command 与三端注册

**Files:**
- Create: `commands/dmon-tdd.md`、`commands/dmon-spec.md`、`commands/dmon-plan.md`、`commands/dmon-impl.md`、`commands/dmon-debug.md`、`commands/dmon-review.md`、`commands/dmon-finish.md`
- Create: `scripts/install-codex-prompts.sh`
- Create: `tests/structure/test-commands.sh`、`tests/structure/test-install-codex-prompts.sh`
- Modify: `.cursor-plugin/plugin.json`
- Modify: `scripts/sync-to-codex-plugin.sh`（`/commands/` 已在排除列表里，确认无需改动）

**Interfaces:**
- Consumes: Task 3 的路由 SKILL.md 与阶段编号。
- Produces: 7 个 slash command，slug 取文件名 stem。Cursor 经 `.cursor-plugin/plugin.json` 的 `commands` 字段注册；Claude Code 按约定自动发现 `commands/`；Codex 由 `scripts/install-codex-prompts.sh` 拷贝到 `${CODEX_HOME:-$HOME/.codex}/prompts/`。

**已实测的三端事实：** `$ARGUMENTS` 在 Cursor / Claude Code / Codex 三端都会被替换为命令后面的文字；`$1` 在 Claude Code 上返回空串，因此禁用。Codex 插件无法随包发布 `commands/`（本仓库 `scripts/sync-to-codex-plugin.sh` 已把 `/commands/` 列入不发布目录，OpenAI 官方 Codex 插件也一律只带 `skills/`），所以走安装脚本。

- [ ] **Step 1: 写全托管入口命令**

创建 `commands/dmon-tdd.md`：

```markdown
---
name: dmon-tdd
description: dmon 全托管开发 —— 需求澄清到分支收尾的完整 TDD 流程
---

加载本插件的 `skills/dmon-tdd` 技能,按**全托管流程**执行:
阶段 1 需求澄清 → 阶段 2 计划 → 阶段 3 实现 → 阶段 5 评审 → 阶段 6 收尾,
中途遇到 bug 插入阶段 4 系统化调试。

每个阶段结束前停下来让你的人类搭档确认,确认过了才能进下一阶段。

本次需求:$ARGUMENTS
```

- [ ] **Step 2: 写 6 个阶段入口命令**

每个文件都是薄壳，只负责「加载 skill 并进入第 N 阶段」，不复制任何阶段正文。

`commands/dmon-spec.md`：

```markdown
---
name: dmon-spec
description: dmon 阶段 1 —— 需求澄清,把模糊需求变成可评审的设计文档
---

加载本插件的 `skills/dmon-tdd` 技能,直接进入**阶段 1(需求澄清)**,
按 `references/1-requirement-specify/requirement-specify.md` 全程执行。

该阶段的全部纪律在流程内强制生效,不得跳过、不得简化。

本次需求:$ARGUMENTS
```

`commands/dmon-plan.md`：

```markdown
---
name: dmon-plan
description: dmon 阶段 2 —— 把 spec 拆成可逐步执行的实施计划
---

加载本插件的 `skills/dmon-tdd` 技能,直接进入**阶段 2(计划)**,
按 `references/2-planning/writing-plans.md` 全程执行。

该阶段的全部纪律在流程内强制生效,不得跳过、不得简化。

要做计划的 spec 或需求:$ARGUMENTS
```

`commands/dmon-impl.md`：

```markdown
---
name: dmon-impl
description: dmon 阶段 3 —— 按实施计划落地编码
---

加载本插件的 `skills/dmon-tdd` 技能,直接进入**阶段 3(实现)**。
默认按 `references/3-implementation/subagent-driven-development.md` 执行;
如果你的人类搭档要求在当前会话内逐步推进,改用
`references/3-implementation/executing-plans.md`。

该阶段的全部纪律在流程内强制生效,不得跳过、不得简化。

要执行的计划:$ARGUMENTS
```

`commands/dmon-debug.md`：

```markdown
---
name: dmon-debug
description: dmon 阶段 4 —— 系统化调试,先找根因再谈修复
---

加载本插件的 `skills/dmon-tdd` 技能,直接进入**阶段 4(调试)**,
按 `references/4-debugging/systematic-debugging.md` 全程执行。

在完成根因调查之前,不得提出任何修复方案。

现象:$ARGUMENTS
```

`commands/dmon-review.md`：

```markdown
---
name: dmon-review
description: dmon 阶段 5 —— 代码评审与完成前验证
---

加载本插件的 `skills/dmon-tdd` 技能,直接进入**阶段 5(评审)**,
依次执行 `references/5-review/requesting-code-review.md`、
`references/5-review/receiving-code-review.md`、
`references/5-review/verification-before-completion.md`。

在跑过验证命令并确认输出之前,不得声称任何东西通过了。

评审范围:$ARGUMENTS
```

`commands/dmon-finish.md`：

```markdown
---
name: dmon-finish
description: dmon 阶段 6 —— 开发分支收尾,决定合并 / PR / 清理
---

加载本插件的 `skills/dmon-tdd` 技能,直接进入**阶段 6(收尾)**,
按 `references/6-finishing/finishing-a-development-branch.md` 全程执行。

把结构化选项摆给你的人类搭档,由他决定,不要替他做主。

要收尾的分支或工作:$ARGUMENTS
```

- [ ] **Step 3: 在 Cursor manifest 注册 commands**

`.cursor-plugin/plugin.json` 的 `"skills": "./skills/"` 之后加一行：

```json
  "skills": "./skills/",
  "commands": "./commands/",
  "hooks": "./hooks/hooks-cursor.json"
```

（Claude Code 按约定自动发现根目录 `commands/`，`.claude-plugin/plugin.json` 无需改动。`.codex-plugin/plugin.json` 不要加 `commands` 字段 —— Codex 不认。）

- [ ] **Step 4: 写 Codex 安装脚本**

创建 `scripts/install-codex-prompts.sh`：

```bash
#!/usr/bin/env bash
# Codex 插件无法随包发布 slash command —— canonical Codex plugin 只带
# skills/。但 Codex 支持用户级自定义提示词目录,把命令拷进去就能用
# /dmon-* 调用,且 $ARGUMENTS 正常替换。
#
# 用法: bash scripts/install-codex-prompts.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEST="${CODEX_HOME:-$HOME/.codex}/prompts"

mkdir -p "$DEST"

count=0
for f in "$PLUGIN_ROOT"/commands/dmon-*.md; do
    [ -e "$f" ] || continue
    cp "$f" "$DEST/"
    count=$((count + 1))
done

if [[ "$count" -eq 0 ]]; then
    echo "error: 在 $PLUGIN_ROOT/commands/ 下没有找到任何 dmon-*.md" >&2
    exit 1
fi

echo "已安装 $count 个命令到 $DEST"
echo "在 Codex 里用 /dmon-tdd、/dmon-spec 等调用。"
```

```bash
chmod +x scripts/install-codex-prompts.sh
```

- [ ] **Step 5: 写 commands 规范测试**

创建 `tests/structure/test-commands.sh`：

```bash
#!/usr/bin/env bash
# Cursor 的 slash command 是全局命名空间,所以文件名必须带 dmon- 前缀防冲突。
# command 必须是薄壳:有非空 description frontmatter、有非空正文、
# 且不复制阶段正文(用行数上限兜底)。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FAILURES=0

pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }

echo "Slash command tests"

EXPECTED="dmon-tdd dmon-spec dmon-plan dmon-impl dmon-debug dmon-review dmon-finish"

actual_count="$(find "$REPO_ROOT/commands" -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')"
if [[ "$actual_count" -eq 7 ]]; then
    pass "commands/ 下正好 7 个命令文件"
else
    fail "commands/ 下有 $actual_count 个命令文件,期望 7 个"
fi

for f in "$REPO_ROOT"/commands/*.md; do
    base="$(basename "$f" .md)"

    case "$base" in
        dmon-*) pass "$base 带 dmon- 前缀" ;;
        *)      fail "$base 缺少 dmon- 前缀,会污染 Cursor 的全局命令命名空间" ;;
    esac

    desc="$(awk '/^---$/{n++; next} n==1 && /^description:/{sub(/^description:[[:space:]]*/, ""); print; exit}' "$f")"
    if [[ -n "$desc" ]]; then
        pass "$base 有非空 description"
    else
        fail "$base 缺少非空 description frontmatter"
    fi

    body_lines="$(awk '/^---$/{n++; next} n>=2 && NF' "$f" | wc -l | tr -d ' ')"
    if [[ "$body_lines" -ge 3 ]]; then
        pass "$base 正文非空($body_lines 行)"
    else
        fail "$base 正文过短($body_lines 行)"
    fi
    if [[ "$body_lines" -le 20 ]]; then
        pass "$base 是薄壳($body_lines 行 <= 20)"
    else
        fail "$base 有 $body_lines 行正文,像是复制了阶段内容"
    fi

    if grep -q '\$ARGUMENTS' "$f"; then
        pass "$base 使用 \$ARGUMENTS"
    else
        fail "$base 没有 \$ARGUMENTS 占位符"
    fi

    if grep -qE '\$[0-9]' "$f"; then
        fail "$base 使用了位置参数,Claude Code 上会拿到空串"
    else
        pass "$base 未使用位置参数"
    fi
done

for name in $EXPECTED; do
    if [[ -f "$REPO_ROOT/commands/$name.md" ]]; then
        pass "命令存在: $name"
    else
        fail "缺少命令: $name"
    fi
done

manifest="$REPO_ROOT/.cursor-plugin/plugin.json"
if node -e '
const m = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
process.exit(m.commands === "./commands/" ? 0 : 1);
' "$manifest"; then
    pass ".cursor-plugin/plugin.json 注册了 ./commands/"
else
    fail ".cursor-plugin/plugin.json 未注册 ./commands/"
fi

if node -e '
const m = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
process.exit(Object.prototype.hasOwnProperty.call(m, "commands") ? 1 : 0);
' "$REPO_ROOT/.codex-plugin/plugin.json"; then
    pass ".codex-plugin/plugin.json 没有 commands 字段(Codex 不支持)"
else
    fail ".codex-plugin/plugin.json 不该声明 commands"
fi

if [[ "$FAILURES" -gt 0 ]]; then
    echo "STATUS: FAILED ($FAILURES failure(s))"
    exit 1
fi

echo "STATUS: PASSED"
```

```bash
chmod +x tests/structure/test-commands.sh
```

- [ ] **Step 6: 写安装脚本测试**

创建 `tests/structure/test-install-codex-prompts.sh`：

```bash
#!/usr/bin/env bash
# 安装脚本必须尊重 CODEX_HOME,绝不能在测试里写到真实的 ~/.codex。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FAILURES=0

pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }

TEST_HOME="$(mktemp -d)"
cleanup() { rm -rf "$TEST_HOME"; }
trap cleanup EXIT

echo "Codex prompt install tests"

output="$(CODEX_HOME="$TEST_HOME/codex" bash "$REPO_ROOT/scripts/install-codex-prompts.sh")"

installed="$(find "$TEST_HOME/codex/prompts" -name 'dmon-*.md' | wc -l | tr -d ' ')"
if [[ "$installed" -eq 7 ]]; then
    pass "7 个命令被安装到 CODEX_HOME/prompts"
else
    fail "安装了 $installed 个命令,期望 7 个"
fi

if [[ "$output" == *"已安装 7 个命令"* ]]; then
    pass "脚本报告安装数量"
else
    fail "脚本输出未报告安装数量: $output"
fi

if diff -q "$REPO_ROOT/commands/dmon-tdd.md" "$TEST_HOME/codex/prompts/dmon-tdd.md" >/dev/null; then
    pass "安装的命令与源文件逐字一致"
else
    fail "安装的命令与源文件不一致"
fi

if [[ "$FAILURES" -gt 0 ]]; then
    echo "STATUS: FAILED ($FAILURES failure(s))"
    exit 1
fi

echo "STATUS: PASSED"
```

```bash
chmod +x tests/structure/test-install-codex-prompts.sh
```

- [ ] **Step 7: 跑结构测试全集**

```bash
bash tests/structure/run-all.sh
```

期望：`STRUCTURE TESTS: PASSED`（五个套件全绿）。

- [ ] **Step 8: 确认 codex 打包与同步不受影响**

```bash
bash tests/codex-plugin-sync/test-sync-to-codex-plugin.sh 2>&1 | tail -3
bash tests/codex/test-package-codex-plugin.sh 2>&1 | tail -3
bash tests/shell-lint/test-lint-shell.sh 2>&1 | tail -3
```

期望：sync 测试 `PASS`；package 测试仍然只有基线那 1 项时区失败；shell lint 全过。`scripts/sync-to-codex-plugin.sh` 的排除列表里本来就有 `/commands/`，无需改动 —— 如果 sync 测试因为新增 `commands/` 而报「未预期的文件」，说明排除逻辑没生效，去查该脚本第 75 行。

- [ ] **Step 9: 提交**

```bash
git add -A
git commit -m "feat: 新增 7 个 dmon- 前缀 slash command 与 Codex 安装脚本

commands/ 全部为薄壳,只负责加载 dmon-tdd 技能并进入指定阶段,
不复制任何阶段正文。参数统一用 \$ARGUMENTS(三端实测一致,\$1 在
Claude Code 上为空)。Cursor 经 .cursor-plugin/plugin.json 注册,
Claude Code 自动发现,Codex 由 scripts/install-codex-prompts.sh
拷贝到 CODEX_HOME/prompts。"
```

---

### Task 6: 产物目录迁移 —— .superpowers → .dmon，docs/superpowers → docs/dmon

**Files:**
- Modify: `skills/dmon-tdd/references/3-implementation/scripts/sdd-workspace`、`task-brief`、`review-package`
- Modify: `skills/dmon-tdd/references/1-requirement-specify/scripts/start-server.sh`、`stop-server.sh`
- Modify: `skills/dmon-tdd/references/1-requirement-specify/visual-companion.md`、`requirement-specify.md`
- Modify: `skills/dmon-tdd/references/3-implementation/subagent-driven-development.md`、`skills/dmon-tdd/references/2-planning/writing-plans.md`、`skills/dmon-tdd/references/5-review/requesting-code-review.md`
- Modify: `tests/claude-code/test-sdd-workspace.sh`、`tests/claude-code/test-helpers.sh`、`tests/claude-code/test-worktree-path-policy.sh`、`tests/claude-code/test-subagent-driven-development-integration.sh`
- Modify: `tests/brainstorm-server/start-server.test.sh`、`tests/brainstorm-server/lifecycle.test.js`
- Modify: `.gitignore`

**Interfaces:**
- Produces: 运行时工作区路径 `.dmon/sdd/<plan-basename>/` 与 `.dmon/brainstorm/`；文档产物路径 `docs/dmon/specs/`、`docs/dmon/plans/`。`sdd-workspace PLAN_FILE` 的输出契约变为打印 `<repo-root>/.dmon/sdd/<plan-basename>`，`task-brief` / `review-package` 的默认 OUTFILE 随之改变。

- [ ] **Step 1: 先改测试（TDD）**

```bash
perl -pi -e 's{\.superpowers/sdd}{.dmon/sdd}g' tests/claude-code/test-sdd-workspace.sh
perl -pi -e 's{\.superpowers/brainstorm}{.dmon/brainstorm}g' \
  tests/brainstorm-server/start-server.test.sh \
  tests/brainstorm-server/lifecycle.test.js
perl -pi -e 's{docs/superpowers/}{docs/dmon/}g' \
  tests/claude-code/test-helpers.sh \
  tests/claude-code/test-worktree-path-policy.sh \
  tests/claude-code/test-subagent-driven-development-integration.sh
```

- [ ] **Step 2: 跑测试确认它失败**

```bash
bash tests/claude-code/test-sdd-workspace.sh 2>&1 | tail -8
```

期望：FAIL，报的是路径仍然是 `.superpowers/sdd/...`。这证明测试在测真实行为。

- [ ] **Step 3: 改 SDD 脚本**

```bash
perl -pi -e 's{\.superpowers/sdd}{.dmon/sdd}g' \
  skills/dmon-tdd/references/3-implementation/scripts/sdd-workspace \
  skills/dmon-tdd/references/3-implementation/scripts/task-brief \
  skills/dmon-tdd/references/3-implementation/scripts/review-package
grep -rn "dmon/sdd\|superpowers" skills/dmon-tdd/references/3-implementation/scripts/
```

期望：三个脚本里只剩 `.dmon/sdd`，没有 `superpowers` 残留。

- [ ] **Step 4: 跑 SDD 工作区测试确认转绿**

```bash
bash tests/claude-code/test-sdd-workspace.sh 2>&1 | tail -3
```

期望：`PASS`。

- [ ] **Step 5: 改 brainstorm 脚本**

```bash
perl -pi -e 's{\.superpowers/brainstorm}{.dmon/brainstorm}g;
             s{\.superpowers\b}{.dmon}g' \
  skills/dmon-tdd/references/1-requirement-specify/scripts/start-server.sh \
  skills/dmon-tdd/references/1-requirement-specify/scripts/stop-server.sh
```

- [ ] **Step 6: 跑 brainstorm 测试确认转绿**

```bash
bash tests/brainstorm-server/start-server.test.sh 2>&1 | tail -3
(cd tests/brainstorm-server && npm test 2>&1 | tail -5)
```

期望：全绿。

- [ ] **Step 7: 改 skill 正文里的路径**

```bash
perl -pi -e 's{\.superpowers/brainstorm}{.dmon/brainstorm}g;
             s{\.superpowers/sdd}{.dmon/sdd}g;
             s{\.superpowers/}{.dmon/}g;
             s{docs/superpowers/}{docs/dmon/}g' \
  skills/dmon-tdd/references/1-requirement-specify/visual-companion.md \
  skills/dmon-tdd/references/1-requirement-specify/requirement-specify.md \
  skills/dmon-tdd/references/2-planning/writing-plans.md \
  skills/dmon-tdd/references/3-implementation/subagent-driven-development.md \
  skills/dmon-tdd/references/5-review/requesting-code-review.md
grep -rn "\.superpowers\|docs/superpowers" skills/
```

期望：无输出。

- [ ] **Step 8: 改 .gitignore**

把 `.superpowers/` 这一行改为 `.dmon/`：

```bash
perl -pi -e 's{^\.superpowers/$}{.dmon/}' .gitignore
grep -n "dmon\|superpowers" .gitignore
```

期望：只有 `.dmon/` 一行。

- [ ] **Step 9: 端到端验证工作区路径真的落在新位置**

```bash
tmp="$(mktemp -d)" && cd "$tmp" && git init -q . && \
  mkdir -p docs/dmon/plans && echo "# t" > docs/dmon/plans/2026-01-01-t.md && \
  bash "$OLDPWD/skills/dmon-tdd/references/3-implementation/scripts/sdd-workspace" docs/dmon/plans/2026-01-01-t.md && \
  find . -path ./.git -prune -o -type d -name sdd -print && cd "$OLDPWD" && rm -rf "$tmp"
```

期望：脚本打印以 `/.dmon/sdd/2026-01-01-t` 结尾的路径，`find` 也找到 `./.dmon/sdd`。

- [ ] **Step 10: 跑确定性测试全集与结构测试**

```bash
bash tests/structure/run-all.sh
```
再跑 `<确定性测试全集>`。

期望：结构测试 PASSED；确定性测试 7 项全绿。

- [ ] **Step 11: 提交**

```bash
git add -A
git commit -m "refactor: 产物目录迁移到 dmon 命名

运行时工作区 .superpowers/{sdd,brainstorm} 改为 .dmon/{sdd,brainstorm},
文档产物 docs/superpowers/ 改为 docs/dmon/。同步更新 SDD 三个脚本、
brainstorm 启停脚本、相关 skill 正文、测试断言与 .gitignore。"
```

---

### Task 7: 全局改名 —— superpowers → dmon-tdd-engineering，版本重置 1.0.0

**Files:**
- Modify: `.claude-plugin/plugin.json`、`.cursor-plugin/plugin.json`、`.codex-plugin/plugin.json`、`.claude-plugin/marketplace.json`、`.agents/plugins/marketplace.json`、`package.json`、`.version-bump.json`
- Move: `assets/superpowers-small.svg` → `assets/dmon-tdd-small.svg`
- Modify: `hooks/session-start`（注释）、`scripts/sync-to-codex-plugin.sh`、`scripts/package-codex-plugin.sh`、`tests/codex-plugin-sync/test-sync-to-codex-plugin.sh`、`tests/codex/test-marketplace-manifest.sh`、`tests/codex/test-package-codex-plugin.sh`
- Create: `tests/structure/test-no-superpowers.sh`
- Remove git remote: `upstream`

**Interfaces:**
- Consumes: 前 6 个任务完成后的目录结构。
- Produces: 全仓库（除 `.git/` 与 `docs/dmon/` 下本 spec 与本计划外）无 `superpowers` 字样；三端 manifest 版本一致为 `1.0.0`。

- [ ] **Step 1: 先写命名残留测试（TDD）**

创建 `tests/structure/test-no-superpowers.sh`：

```bash
#!/usr/bin/env bash
# 改造后全仓库不应再出现 superpowers 字样。设计方案与实施计划本身要
# 描述这次改名,所以永久豁免;git 历史不在检查范围。
#
# README 与 agent 指南的重写属于计划的 Task 8,在那之前临时豁免。
# Task 8 完成时必须删掉下面标了 TASK-8 的四行豁免。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Naming residue tests"

cd "$REPO_ROOT"

excludes=(
    ':!docs/dmon/specs/2026-09-09-dmon-tdd-engineering-design.md'
    ':!docs/dmon/plans/2026-09-09-dmon-tdd-engineering.md'
    # TASK-8: 文档重写完成后删掉下面这四行
    ':!README.md'
    ':!README.zh-CN.md'
    ':!CLAUDE.md'
    ':!AGENTS.md'
)

matches="$(git grep -il "superpowers" -- . "${excludes[@]}" || true)"

if [[ -z "$matches" ]]; then
    echo "  [PASS] 全仓库无 superpowers 残留"
    echo "STATUS: PASSED"
    exit 0
fi

echo "  [FAIL] 下列文件仍含 superpowers:"
printf '%s\n' "$matches" | sed 's/^/      /'
echo "STATUS: FAILED"
exit 1
```

```bash
chmod +x tests/structure/test-no-superpowers.sh
bash tests/structure/test-no-superpowers.sh
```

期望：FAILED，并列出所有待改文件。这份清单就是本任务的工作清单。

- [ ] **Step 2: 改三端 plugin manifest**

`.cursor-plugin/plugin.json`：

```json
{
  "name": "dmon-tdd-engineering",
  "displayName": "dmon TDD Engineering",
  "description": "dmon 全托管 TDD 开发框架:需求澄清、计划、实现、调试、评审、收尾",
  "version": "1.0.0",
  "author": {
    "name": "佑平",
    "email": "jace.cj@alibaba-inc.com"
  },
  "homepage": "https://github.com/yongwuzhijin/dmon-tdd-engineering",
  "repository": "https://github.com/yongwuzhijin/dmon-tdd-engineering",
  "license": "MIT",
  "keywords": [
    "dmon",
    "tdd",
    "planning",
    "debugging",
    "code-review",
    "workflow"
  ],
  "skills": "./skills/",
  "commands": "./commands/",
  "hooks": "./hooks/hooks-cursor.json"
}
```

`.claude-plugin/plugin.json` 同样改 `name` / `description` / `version` / `author` / `homepage` / `repository` / `keywords`（该文件没有 `skills` / `hooks` / `commands` 字段，保持不变）。

`.codex-plugin/plugin.json` 除同样的字段外，还要改 `interface` 段：`displayName` 改为 `dmon TDD Engineering`，`shortDescription` / `longDescription` / `developerName` 相应改写，`defaultPrompt` 改为 `["用 dmon tdd 全托管开发这个需求", "帮我做需求澄清"]`，`composerIcon` 改为 `./assets/dmon-tdd-small.svg`。**不要给它加 `commands` 字段。**

- [ ] **Step 3: 改两个 marketplace manifest**

`.claude-plugin/marketplace.json`：`name` → `dmon-tdd-engineering-dev`，`description` → `dmon TDD 开发框架的开发用 marketplace`，`owner` 改为上述作者，`plugins[0].name` → `dmon-tdd-engineering`，`plugins[0].version` → `1.0.0`，`plugins[0].description` 与 plugin.json 一致，`plugins[0].author` 同步。

`.agents/plugins/marketplace.json`：`name` → `dmon-tdd-engineering-dev`，`interface.displayName` → `dmon TDD Engineering Dev`，`plugins[0].name` → `dmon-tdd-engineering`。

- [ ] **Step 4: 改 package.json**

```json
{
  "name": "dmon-tdd-engineering",
  "version": "1.0.0",
  "description": "dmon 全托管 TDD 开发框架,供 coding agent 使用",
  "type": "module",
  "keywords": [
    "dmon",
    "tdd",
    "planning",
    "debugging",
    "workflow"
  ]
}
```

- [ ] **Step 5: 换图标**

```bash
git mv assets/superpowers-small.svg assets/dmon-tdd-small.svg
grep -rn "superpowers-small" . --exclude-dir=.git
```

期望：无输出（Step 2 已把 `composerIcon` 改好；若有残留，就地修正）。

- [ ] **Step 6: 改脚本与 hook 注释里的字样**

```bash
perl -pi -e 's{\bsuperpowers\b}{dmon-tdd-engineering}g' \
  scripts/sync-to-codex-plugin.sh \
  scripts/package-codex-plugin.sh
perl -pi -e 's{Superpowers}{dmon-tdd-engineering}g' hooks/session-start
grep -rn "superpowers" scripts/ hooks/ --ignore-case
```

期望：无输出。改完注意人工过一遍这两个脚本 —— 它们里面有些 `superpowers` 是路径片段（如 `plugins/superpowers/`），确认替换后语义仍然正确。

- [ ] **Step 7: 改测试 fixture 里的字样**

`tests/codex-plugin-sync/test-sync-to-codex-plugin.sh` 有 59 处，绝大多数是 `plugins/superpowers/...` 形式的 fixture 路径；`tests/codex/` 两个文件各有若干处。统一替换：

```bash
perl -pi -e 's{\bsuperpowers\b}{dmon-tdd-engineering}g' \
  tests/codex-plugin-sync/test-sync-to-codex-plugin.sh \
  tests/codex/test-marketplace-manifest.sh \
  tests/codex/test-package-codex-plugin.sh
```

- [ ] **Step 8: 跑命名残留测试**

```bash
bash tests/structure/test-no-superpowers.sh
```

期望：`STATUS: PASSED`。

README 与两份 agent 指南暂时在豁免列表里（Task 8 才重写），所以它们不计入。**如果这里报红，说明本任务有漏改的文件**，回到 Step 2–7 按输出补上再重跑。

- [ ] **Step 9: 校验版本一致性**

```bash
bash scripts/bump-version.sh check
bash tests/version-bump/test-bump-version.sh 2>&1 | tail -3
```

期望：5 个 manifest 全部显示 `1.0.0`，无 drift；version-bump 测试通过。

- [ ] **Step 10: 移除 upstream remote**

```bash
git remote -v
git remote remove upstream
git remote -v
```

期望：移除后只剩 `origin`。

- [ ] **Step 11: 跑全部测试**

```bash
bash tests/structure/run-all.sh
```
再跑 `<确定性测试全集>` 与：
```bash
bash tests/codex/test-package-codex-plugin.sh 2>&1 | tail -3
(cd tests/brainstorm-server && npm test 2>&1 | tail -5)
```

期望：`STRUCTURE TESTS: PASSED`（六个套件全绿）；确定性测试 7 项全绿；
package 测试仍然只有基线那 1 项时区失败；brainstorm-server 全绿。

- [ ] **Step 12: 提交**

```bash
git add -A
git commit -m "refactor: 全局改名为 dmon-tdd-engineering,版本重置 1.0.0

三端 plugin manifest、两个 marketplace manifest、package.json、
图标文件名、打包与同步脚本、测试 fixture 全部改名。
移除 upstream remote,与 obra/superpowers 彻底分家。
新增命名残留测试守住这条线。"
```

---

### Task 8: 文档重写 —— README、CLAUDE.md、AGENTS.md

**Files:**
- Rewrite: `README.md`、`README.zh-CN.md`、`CLAUDE.md`、`AGENTS.md`
- Modify: `LICENSE`（追加 upstream 溯源）、`docs/testing.md`（补上 `tests/structure/`）、`tests/structure/test-no-superpowers.sh`（取消临时豁免）

**Interfaces:**
- Consumes: 前 7 个任务的最终结构、命令清单、触发机制。
- Produces: 三端安装说明与命令清单；`CLAUDE.md` / `AGENTS.md` 从 upstream 的贡献者指南改为本项目指南。

**为什么必须重写而不是改几个词：** 现有 `CLAUDE.md` / `AGENTS.md` 是 obra 项目专属的贡献者指南，内容包括「94% PR 拒绝率」「PR 必须 target dev 分支」「不接受第三方依赖」等，全部只对 upstream 有意义。本仓库已移除 upstream remote，这些内容留着会误导任何在此仓库工作的 agent。

- [ ] **Step 1: 重写 README.zh-CN.md**

用下面的完整内容覆盖该文件：

````markdown
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

它会把 7 个命令复制到 `${CODEX_HOME:-$HOME/.codex}/prompts/`。
之后 `/dmon-tdd` 等命令在 Codex 里就能用,`$ARGUMENTS` 也会正常替换。

Codex 没有 hook 机制,所以在 Codex 上只有命令触发,没有 sessionStart 软触发。

## 怎么触发

### 命令(7 个)

| 命令 | 作用 |
|---|---|
| `/dmon-tdd` | 全托管:需求澄清 → 计划 → 实现 → 评审 → 收尾 |
| `/dmon-spec` | 只做阶段 1,需求澄清 |
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
| 2 计划 | 已有 spec、还没动代码 | `/dmon-plan` | `references/2-planning/writing-plans.md` |
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
````

- [ ] **Step 2: 重写 README.md**

英文版，与 Step 1 的中文版逐节对应（同样的章节顺序、同样的表格、同样的安装命令）。开头加一行 `[中文文档](README.zh-CN.md)`，中文版开头加一行 `[English](README.md)`。

- [ ] **Step 3: 重写 CLAUDE.md**

用下面的完整内容覆盖该文件：

````markdown
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
│       ├── 2-planning/             # 计划
│       ├── 3-implementation/       # 实现(SDD / 逐步执行 + 三个提示词 + 三个脚本)
│       ├── 4-debugging/            # 调试
│       ├── 5-review/               # 评审(请求 / 接收 / 完成前验证)
│       ├── 6-finishing/            # 收尾
│       ├── shared/                 # TDD、worktree、并行派发
│       └── platform/               # Codex 工具名映射
├── commands/                       # 7 个 dmon- 前缀薄壳命令
├── hooks/                          # session-start(11 行 bootstrap)+ 三端配置
├── scripts/                        # 版本、lint、codex 打包 / 同步 / 命令安装
├── tests/structure/                # 本次改造新增的结构断言
└── docs/dmon/{specs,plans}         # 本项目自己的设计与计划文档
```

## 测试

见 [docs/testing.md](docs/testing.md)。主入口 `bash tests/structure/run-all.sh`。
````

- [ ] **Step 4: 让 AGENTS.md 与 CLAUDE.md 保持一致**

```bash
cp CLAUDE.md AGENTS.md
```

（两份文件在改造前就是逐字相同的，保持这个约定。）

- [ ] **Step 5: 补 docs/testing.md**

在 Plugin tests 清单顶部加一条：

```markdown
- `tests/structure/` — 本框架的结构断言:单 skill、链接完整性、路由完整性、
  commands 规范、Codex 安装脚本、命名残留。入口 `bash tests/structure/run-all.sh`。
```

同时把文件开头对 `evals/` 的描述保留（eval 仓库仍然适用），但把 `Gemini CLI` 的提及删掉。

- [ ] **Step 6: 把 upstream 溯源写进 LICENSE**

MIT 协议要求保留原始版权声明，所以对 `obra/superpowers` 的溯源必须留在仓库里某处。放 `LICENSE` 是它本来就该在的位置，也让命名残留测试只需豁免一个文件而不是四个。

在 `LICENSE` 现有版权行下方追加：

```
This project is derived from obra/superpowers v6.3.0
(https://github.com/obra/superpowers), MIT licensed, Copyright (c) Jesse Vincent.
Skill content has been translated to Chinese and restructured; see
docs/dmon/specs/2026-09-09-dmon-tdd-engineering-design.md for what changed.
```

- [ ] **Step 7: 取消临时豁免，跑命名残留测试**

把 `tests/structure/test-no-superpowers.sh` 的 `excludes` 数组改为最终形态 —— 删掉四行 `# TASK-8:` 临时豁免，加上 `LICENSE`：

```bash
excludes=(
    ':!docs/dmon/specs/2026-09-09-dmon-tdd-engineering-design.md'
    ':!docs/dmon/plans/2026-09-09-dmon-tdd-engineering.md'
    ':!LICENSE'
)
```

```bash
bash tests/structure/test-no-superpowers.sh
```

期望：`STATUS: PASSED`。这一步才是该测试真正生效的时刻 —— 如果报红，说明 Step 1–4 重写的文档里还留着旧名字。

- [ ] **Step 8: 跑结构测试全集**

```bash
bash tests/structure/run-all.sh
```

期望：`STRUCTURE TESTS: PASSED`（六个套件全绿）。

- [ ] **Step 9: 提交**

```bash
git add -A
git commit -m "docs: 重写 README 与 agent 指南

README 中英双语按新的安装方式、命令清单、触发机制、六阶段结构重写。
CLAUDE.md / AGENTS.md 从 upstream 贡献者指南改为本项目 agent 指南,
写明 skill 正文不得改动、references 下不得有 SKILL.md 等硬约束,
并记录 UTC+8 机器上的已知基线红点。
upstream 溯源与 MIT 版权声明移入 LICENSE,
命名残留测试取消四个文档文件的临时豁免。"
```

---

### Task 9: 三端验收实测

**Files:**
- 无代码改动。本任务产出一份实测记录，追加到 `docs/dmon/specs/2026-09-09-dmon-tdd-engineering-design.md` 末尾。

**Interfaces:**
- Consumes: Task 1–8 的全部产出。
- Produces: spec §13 三条高风险项（软触发不可靠、references 残留 SKILL.md、路由层强制力）的实测证据，以及 §14 遗留项的最终结论。

**这是本次改造的验收硬指标（spec §8.3）：三端加载插件后，skill 列表中确实只出现 `dmon-tdd` 一条。**

- [ ] **Step 1: 静态确认单 skill**

```bash
bash tests/structure/run-all.sh
find skills -name SKILL.md
```

期望：结构测试全绿；`find` 只输出 `skills/dmon-tdd/SKILL.md`。

- [ ] **Step 2: 反例测试 —— 未触发时框架不得介入**

在三端各开一个干净会话，发送与开发无关的一句话：

> 帮我看一下这个仓库的 README 讲了什么

期望：模型直接回答，**不加载 dmon-tdd，不提及框架存在，不询问是否启用**。把三端的实际回复摘录记下来。

如果任何一端主动提了框架，说明 bootstrap 措辞的排他性不够，回到 Task 4 加强「不要提及、不要询问」那两句，然后重跑本步。

- [ ] **Step 3: 正例测试 —— 关键词软触发**

三端各开干净会话，发送：

> 用 dmon tdd 全托管开发一个待办清单

期望：模型加载 `dmon-tdd` 技能，宣布进入阶段 1，并开始需求澄清 —— **不得直接写代码**。记录三端结果。

- [ ] **Step 4: 正例测试 —— 命令触发**

Cursor 与 Claude Code 直接测；Codex 先跑安装脚本：

```bash
bash scripts/install-codex-prompts.sh
```

三端各发送：

```
/dmon-spec 一个待办清单
```

期望：命令被识别，`$ARGUMENTS` 被替换为「一个待办清单」，模型进入阶段 1。记录三端结果。

若 Cursor 端命令不出现在 `/` 菜单里，检查 Cursor 设置中「Include third-party Plugins, Skills, and configs」开关 —— 插件提供的 commands 依赖它，而 skills 不依赖。

- [ ] **Step 5: 确认 skill 列表只有一条**

在三端分别查看可用 skill 列表（Cursor 与 Claude Code 输入 `/` 查看，Codex 查看插件详情）。

期望：本插件只贡献 `dmon-tdd` 一条。截图或摘录记下来。

- [ ] **Step 6: 把实测结果追加进 spec**

在 `docs/dmon/specs/2026-09-09-dmon-tdd-engineering-design.md` 末尾追加一节：

```markdown
## 15. 实施后实测记录（YYYY-MM-DD）

### §14 遗留项结论

1. `$ARGUMENTS`:Cursor / Claude Code / Codex 三端均支持。`$1` 在 Claude Code 上
   返回空串,故统一只用 `$ARGUMENTS`。
2. Codex 不支持插件随包发布 `commands/`,改由 `scripts/install-codex-prompts.sh`
   拷贝到 `${CODEX_HOME:-$HOME/.codex}/prompts/`。
3. `tests/explicit-skill-requests/` 已删除:9 个 prompt fixture 全部点名旧 skill 名,
   单 skill 改造后前提失效。
4. `ddd-*` 卸载由用户自行决定时机,不在本次范围。

### 三端验收结果

（填入 Step 2–5 的实际记录:反例是否安静、正例是否触发、命令是否识别、
skill 列表是否只有一条）
```

把 spec 顶部的「状态」从「已确认，待编写实施计划」改为「已实施，已验收」。

- [ ] **Step 7: 提交**

```bash
git add -A
git commit -m "docs: 追加三端验收实测记录,结清 spec §14 遗留项"
```

---

## 收尾：本地目录与 GitHub 仓库改名（由人类手动执行）

按你的决定，这一步**不由 agent 执行**，避免中途 Cursor 工作区路径失联。全部任务完成、验收通过之后，你自己按下面的顺序做：

1. 关闭所有打开该仓库的编辑器窗口与终端。
2. 在 GitHub 网页上把 `yongwuzhijin/superpowers` 改名为 `yongwuzhijin/dmon-tdd-engineering`（Settings → General → Repository name）。
3. 本地重命名并更新 remote：

```bash
cd ~/Documents/github
mv superpowers dmon-tdd-engineering
cd dmon-tdd-engineering
git remote set-url origin git@github.com:yongwuzhijin/dmon-tdd-engineering.git
git remote -v
```

4. 重新用新路径打开工作区，确认插件在三端仍能加载。
5. 卸载不再需要的 `ddd-*` skill（时机由你决定，本计划不涉及）。

---

## 自查记录

**spec 覆盖度：** §2 五个目标分别由 Task 7（更名）、Task 4（默认不生效）、Task 2+3（14→1）、Task 6（产物目录）、Task 2（brainstorming → requirement-specify）覆盖。§7 目录结构由 Task 1+2 落地。§8 迁移映射逐条对应 Task 2 的 Step 2–8。§9 commands 由 Task 5 覆盖。§10 产物落盘由 Task 6 覆盖。§11 测试策略：11.1 保留改造散在各任务，11.2 删除在 Task 1，11.3 五项新增分别是 Task 3（路由完整性）、Task 2（链接完整性、单 skill）、Task 5（commands 规范）、Task 7（命名残留）。§12 命名清单由 Task 7 + 收尾节覆盖。§13 六条风险分别由 Task 9 Step 2–4（软触发）、Task 2 链接测试（断链）、Task 2+9（SKILL.md 残留）、Task 6 Step 3/7 的 grep 复核（脚本硬编码）、Task 3 Step 4（路由层强制力）、九任务拆分（改动面过大）缓解。§14 四个遗留项在 Task 5（1、2）、Task 1（3）、收尾节（4）结清。

**与 spec 的两处偏离，已在正文标注理由：** Task 1 额外删除 `docs/porting-to-a-new-harness.md` 与 `tests/explicit-skill-requests/`。

**未在 spec 中但必须做的事：** Task 1 修 `package.json` 的 `main` / `pi` 悬空字段（删 `.opencode/` 与 `.pi/` 的直接后果）；Task 1 与 Task 8 修 `docs/testing.md`；Task 2 修 6 个测试脚本里的 skill 路径硬编码；Task 8 把 upstream 溯源写进 `LICENSE`（MIT 协议要求保留原始版权声明，spec §12 只说了改名没说溯源往哪放）。

**占位符自查：** 全文无 TBD / TODO / "类似 Task N" / "添加适当的错误处理"。唯一的填空是 Task 9 Step 6 的实测记录模板，那是运行时才产生的观测数据，不是可以提前写死的内容。

**命名一致性自查：** 8 个阶段目录名、6 个新增测试文件名、7 个命令 slug、13 条路由表条目在全文中拼写一致；Task 3 写进 SKILL.md 的 13 条引用与 Task 3 路由测试 `required` 数组逐条对应。
