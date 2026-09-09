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
