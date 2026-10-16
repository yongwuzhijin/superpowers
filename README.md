[中文文档](README.zh-CN.md)

# dmon-tdd-engineering

A fully-managed TDD development framework for coding agents. Covers six stages: requirements clarification, planning, implementation, debugging, review, and finishing.

## How it differs from other skill frameworks

**Off by default.** At session start it injects only ~11 lines explaining that the framework exists and when to load it. If you do not trigger it, it takes no context and does not interfere with ordinary questions — no pitching, no asking whether to enable it.

**One skill registered.** All six stages live under `skills/dmon-tdd/references/`. The harness skill list shows a single entry: `dmon-tdd`.

**Discipline is mandatory once triggered.** After entry, the stage files' behavioral constraints (red-flag table, "you have no choice", "this is non-negotiable") stay in force for the rest of that flow. Force is not removed; its scope shrinks from session-level to flow-level.

## Supported harnesses

Cursor, Claude Code, Codex.

## Install

### Cursor

```bash
git clone https://github.com/yongwuzhijin/dmon-tdd-engineering.git \
  ~/Documents/github/dmon-tdd-engineering
```

Load that directory as a local plugin in Cursor. `.cursor-plugin/plugin.json` registers the skill, commands, and sessionStart hook.

If `/dmon-*` commands do not appear in the `/` menu, check Cursor's **Include third-party Plugins, Skills, and configs** setting — plugin commands depend on it; skills do not.

### Claude Code

```bash
claude plugin marketplace add ~/Documents/github/dmon-tdd-engineering
claude plugin install dmon-tdd-engineering
```

Claude Code auto-discovers root `commands/` and `skills/`, and registers the SessionStart hook from `hooks/hooks.json`.

### Codex

Codex plugins can only ship `skills/` — **they cannot publish slash commands with the package** (canonical Codex plugins ship skills only; this repo's `scripts/sync-to-codex-plugin.sh` also excludes `/commands/`). After installing the plugin, copy commands into the user prompts directory:

```bash
bash scripts/install-codex-prompts.sh
```

That copies all 8 commands to `${CODEX_HOME:-$HOME/.codex}/prompts/`. Then `/dmon-tdd` and friends work in Codex, with `$ARGUMENTS` substituted normally.

Codex has no hook mechanism, so on Codex you only get command triggers — no sessionStart soft trigger.

## How to trigger

### Commands (8)

| Command | Role |
|---|---|
| `/dmon-tdd` | Full flow: clarify → system analysis → plan → implement → review → finish |
| `/dmon-spec` | Stage 1 only — requirements clarification |
| `/dmon-sys` | After requirements are confirmed — system analysis, compatibility, release, schedule |
| `/dmon-plan` | Stage 2 only — write the implementation plan |
| `/dmon-impl` | Stage 3 only — execute the plan |
| `/dmon-debug` | Stage 4 only — systematic debugging |
| `/dmon-review` | Stage 5 only — code review and pre-completion verification |
| `/dmon-finish` | Stage 6 only — branch finishing |

Text after the command is passed via `$ARGUMENTS`, e.g. `/dmon-spec add a batch export button to the settlement page`.

### Keywords (soft trigger)

On Cursor and Claude Code, any of these phrases also triggers:

`dmon tdd`, `dmon 开发`, `全托管开发`, `托管开发`, `tdd 全托管`

## Six stages

| Stage | When | Command | Files |
|---|---|---|---|
| 1 Requirements | Before any creative work | `/dmon-spec` | `references/1-requirement-specify/requirement-specify.md` |
| System analysis | Requirements confirmed, plan not started | `/dmon-sys` | `references/system-analysis/system-analysis.md` |
| 2 Planning | Spec or system analysis exists, code not started | `/dmon-plan` | `references/2-planning/writing-plans.md` |
| 3 Implementation | Plan ready to land | `/dmon-impl` | `references/3-implementation/{subagent-driven-development,executing-plans}.md` |
| 4 Debugging | Bugs, test failures, unexpected behavior | `/dmon-debug` | `references/4-debugging/systematic-debugging.md` |
| 5 Review | Before claiming done / merging | `/dmon-review` | `references/5-review/{requesting,receiving}-code-review.md`, `verification-before-completion.md` |
| 6 Finishing | Implementation done; decide how to integrate | `/dmon-finish` | `references/6-finishing/finishing-a-development-branch.md` |

Three cross-cutting capabilities may be used in any stage: TDD (`references/shared/test-driven-development.md`), isolated worktrees (`references/shared/using-git-worktrees.md`), and parallel dispatch (`references/shared/dispatching-parallel-agents.md`).

## Where artifacts land

| Artifact | Path | In git? |
|---|---|---|
| Design spec | `docs/dmon/specs/YYYY-MM-DD-<topic>-design.md` | yes |
| System analysis | `docs/dmon/sys/YYYY-MM-DD-<topic>.md` | yes |
| Implementation plan | `docs/dmon/plans/YYYY-MM-DD-<feature>.md` | yes |
| SDD workspace | `.dmon/sdd/<plan-basename>/` | no |
| Requirements temp files | `.dmon/brainstorm/` | no |

Add `.dmon/` to your project's `.gitignore`.

## Relationship to `ddd-*`

This framework replaces the `ddd-*` skill family. After installing it you can uninstall those — fewer skills on disk is part of the point.

## Development and testing

After changing this repo, run:

```bash
bash tests/structure/run-all.sh
```

Full testing notes: [docs/testing.md](docs/testing.md). Agent constraints for editing this repo: [CLAUDE.md](CLAUDE.md).

## Provenance

Based on an MIT-licensed open-source agent skills framework; skill bodies were translated to Chinese. This fork merges them into one skill, defaults to off, supports three harnesses, and adopts the dmon naming scheme. It is independent of upstream and does not merge upstream updates. Original copyright and attribution: [LICENSE](LICENSE).
