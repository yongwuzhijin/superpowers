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
