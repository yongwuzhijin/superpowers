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
