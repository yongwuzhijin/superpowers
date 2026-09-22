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
