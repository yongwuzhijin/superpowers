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
