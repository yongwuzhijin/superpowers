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
