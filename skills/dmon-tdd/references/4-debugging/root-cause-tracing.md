# 根因追溯

## 概述

Bug 常常在调用栈深处暴露出来(git init 跑错了目录、文件建在了错误的位置、数据库用错了路径打开)。你的本能是在报错的地方修,但那是在处理症状。

**核心原则:** 沿着调用链反向追踪,直到找到最初的触发点,然后在源头修。

## 何时使用

```dot
digraph when_to_use {
    "Bug appears deep in stack?" [shape=diamond];
    "Can trace backwards?" [shape=diamond];
    "Fix at symptom point" [shape=box];
    "Trace to original trigger" [shape=box];
    "BETTER: Also add defense-in-depth" [shape=box];

    "Bug appears deep in stack?" -> "Can trace backwards?" [label="yes"];
    "Can trace backwards?" -> "Trace to original trigger" [label="yes"];
    "Can trace backwards?" -> "Fix at symptom point" [label="no - dead end"];
    "Trace to original trigger" -> "BETTER: Also add defense-in-depth";
}
```

**在以下情况使用:**
- 错误发生在执行深处(不在入口点)
- 堆栈跟踪显示出很长的调用链
- 不清楚无效数据是从哪产生的
- 需要找出是哪个测试/代码触发了问题

## 追溯流程

### 1. 观察症状
```
Error: git init failed in ~/project/packages/core
```

### 2. 找到直接原因
**是哪段代码直接导致了这个?**
```typescript
await execFileAsync('git', ['init'], { cwd: projectDir });
```

### 3. 追问:是谁调用了这里?
```typescript
WorktreeManager.createSessionWorktree(projectDir, sessionId)
  → called by Session.initializeWorkspace()
  → called by Session.create()
  → called by test at Project.create()
```

### 4. 一直往上追
**传进来的是什么值?**
- `projectDir = ''`(空字符串!)
- 空字符串作为 `cwd` 会解析成 `process.cwd()`
- 那正是源码目录!

### 5. 找到最初的触发点
**空字符串是从哪来的?**
```typescript
const context = setupCoreTest(); // Returns { tempDir: '' }
Project.create('name', context.tempDir); // Accessed before beforeEach!
```

## 加上堆栈跟踪

当你没法手动追踪时,加上埋点:

```typescript
// Before the problematic operation
async function gitInit(directory: string) {
  const stack = new Error().stack;
  console.error('DEBUG git init:', {
    directory,
    cwd: process.cwd(),
    nodeEnv: process.env.NODE_ENV,
    stack,
  });

  await execFileAsync('git', ['init'], { cwd: directory });
}
```

**关键:** 在测试里用 `console.error()`(别用 logger —— 它可能不显示)

**运行并捕获:**
```bash
npm test 2>&1 | grep 'DEBUG git init'
```

**分析堆栈跟踪:**
- 找测试文件名
- 找到触发这次调用的行号
- 识别出规律(是同一个测试?同一个参数?)

## 找出是哪个测试造成了污染

如果某个东西在测试期间出现,但你不知道是哪个测试:

用本目录下的二分脚本 `find-polluter.sh`:

```bash
./find-polluter.sh '.git' 'src/**/*.test.ts'
```

它会一个一个跑测试,在第一个"污染者"处停下。用法见脚本。

## 真实案例:空的 projectDir

**症状:** `.git` 被建在了 `packages/core/`(源码)里

**追溯链:**
1. `git init` 跑在了 `process.cwd()` 里 ← cwd 参数为空
2. WorktreeManager 被传入了空的 projectDir
3. Session.create() 传入了空字符串
4. 测试在 beforeEach 之前就访问了 `context.tempDir`
5. setupCoreTest() 初始返回 `{ tempDir: '' }`

**根因:** 顶层变量初始化时访问了空值

**修复:** 把 tempDir 改成一个 getter,若在 beforeEach 之前被访问就抛错

**同时加了纵深防御:**
- 第 1 层:Project.create() 校验目录
- 第 2 层:WorkspaceManager 校验非空
- 第 3 层:NODE_ENV 守卫拒绝在 tmpdir 之外做 git init
- 第 4 层:git init 之前记录堆栈跟踪

## 关键原则

```dot
digraph principle {
    "Found immediate cause" [shape=ellipse];
    "Can trace one level up?" [shape=diamond];
    "Trace backwards" [shape=box];
    "Is this the source?" [shape=diamond];
    "Fix at source" [shape=box];
    "Add validation at each layer" [shape=box];
    "Bug impossible" [shape=doublecircle];
    "NEVER fix just the symptom" [shape=octagon, style=filled, fillcolor=red, fontcolor=white];

    "Found immediate cause" -> "Can trace one level up?";
    "Can trace one level up?" -> "Trace backwards" [label="yes"];
    "Can trace one level up?" -> "NEVER fix just the symptom" [label="no"];
    "Trace backwards" -> "Is this the source?";
    "Is this the source?" -> "Trace backwards" [label="no - keeps going"];
    "Is this the source?" -> "Fix at source" [label="yes"];
    "Fix at source" -> "Add validation at each layer";
    "Add validation at each layer" -> "Bug impossible";
}
```

**绝不要只在报错的地方修。** 反向追溯,找到最初的触发点。

## 堆栈跟踪小贴士

**在测试里:** 用 `console.error()` 而不是 logger —— logger 可能被抑制掉
**在操作之前:** 在危险操作之前记录,而不是等它失败之后
**带上上下文:** 目录、cwd、环境变量、时间戳
**捕获堆栈:** `new Error().stack` 能显示完整的调用链

## 实战效果

来自调试会话(2025-10-03):
- 通过 5 层追溯找到了根因
- 在源头修复(getter 校验)
- 加了 4 层防御
- 1847 个测试通过,零污染
