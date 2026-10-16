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
if [[ "$installed" -eq 8 ]]; then
    pass "8 个命令被安装到 CODEX_HOME/prompts"
else
    fail "安装了 $installed 个命令,期望 8 个"
fi

if [[ "$output" == *"已安装 8 个命令"* ]]; then
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
