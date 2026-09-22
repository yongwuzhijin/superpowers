#!/usr/bin/env bash
# Regression check: This plugin should not route new worktrees through the old
# global worktree directory.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

USING_SKILL="$REPO_ROOT/skills/dmon-tdd/references/shared/using-git-worktrees.md"
FINISHING_SKILL="$REPO_ROOT/skills/dmon-tdd/references/6-finishing/finishing-a-development-branch.md"

failures=0

assert_contains() {
    local file="$1"
    local pattern="$2"
    local label="$3"

    if grep -Fq "$pattern" "$file"; then
        echo "  [PASS] $label"
    else
        echo "  [FAIL] $label"
        echo "    Expected to find: $pattern"
        echo "    In file: $file"
        failures=$((failures + 1))
    fi
}

assert_not_contains() {
    local file="$1"
    local pattern="$2"
    local label="$3"

    if grep -Fq "$pattern" "$file"; then
        echo "  [FAIL] $label"
        echo "    Did not expect to find: $pattern"
        echo "    In file: $file"
        failures=$((failures + 1))
    else
        echo "  [PASS] $label"
    fi
}

echo "=== Worktree Path Policy Test ==="
echo ""

_retired_global="$(printf '%s%s%s' '~/.config/' 'super' 'powers/worktrees')"
assert_not_contains "$USING_SKILL" "$_retired_global" "using-git-worktrees does not mention old global path"
assert_not_contains "$USING_SKILL" "global legacy" "using-git-worktrees does not use unclear global legacy shorthand"
assert_not_contains "$USING_SKILL" "Global path" "using-git-worktrees has no global path quick-reference row"
assert_contains "$USING_SKILL" '默认用项目根目录下的 `.worktrees/`' "using-git-worktrees defaults new manual worktrees to .worktrees/"

assert_not_contains "$FINISHING_SKILL" "$_retired_global" "finishing-a-development-branch does not treat old global path as owned"
assert_contains "$FINISHING_SKILL" '`WORKTREE_PATH` 在 `.worktrees/` 或 `worktrees/` 之下' "finishing-a-development-branch keeps project-local cleanup ownership"

echo ""

if [ "$failures" -gt 0 ]; then
    echo "STATUS: FAILED ($failures failures)"
    exit 1
fi

echo "STATUS: PASSED"
