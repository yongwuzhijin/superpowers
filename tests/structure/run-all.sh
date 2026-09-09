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
