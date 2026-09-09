# Visual Companion 指南

基于浏览器的可视化头脑风暴助手,用于展示原型图、示意图和各种选项。

## 什么时候用

要逐题决定,而不是逐次会话决定。判断标准:**用户是"看到它"更容易理解,还是"读到它"更容易理解?**

**用浏览器**——当内容本身就是可视化的:

- **UI 原型图** —— 线框图、布局、导航结构、组件设计
- **架构示意图** —— 系统组件、数据流、关系图
- **并排的视觉对比** —— 对比两种布局、两套配色、两个设计方向
- **设计打磨** —— 当问题关乎观感、间距、视觉层次
- **空间关系** —— 状态机、流程图、以示意图呈现的实体关系

**用终端**——当内容是文本或表格:

- **需求和范围类问题** —— "X 是什么意思?"、"哪些功能在范围内?"
- **概念性的 A/B/C 选择** —— 在用文字描述的几个方案之间挑选
- **取舍清单** —— 优缺点、对比表
- **技术决策** —— API 设计、数据建模、架构方案选型
- **澄清性问题** —— 任何答案是文字、而非视觉偏好的问题

一个*关于* UI 话题的问题,并不自动就是一个可视化问题。"你想要哪种向导?"是概念性的 —— 用终端。"这几个向导布局里哪个感觉对?"是可视化的 —— 用浏览器。

## 工作原理

服务会监视一个目录里的 HTML 文件,并把最新的那个提供给浏览器。你把 HTML 内容写到 `screen_dir`,用户在浏览器里看到它,并可以点击来选择选项。这些选择会被记录到 `state_dir/events`,你在下一轮读取。

**内容片段 vs 完整文档:** 如果你的 HTML 文件以 `<!DOCTYPE` 或 `<html` 开头,服务会原样提供它(只注入辅助脚本)。否则,服务会自动把你的内容包进框架模板里 —— 加上页头、CSS 主题、连接状态,以及所有交互基础设施。**默认写内容片段。** 只有当你需要对整个页面完全掌控时,才写完整文档。

## 启动一个会话

```bash
# 在用户同意使用助手之后再启动。--open 会自动把他们的浏览器打开到
# 第一个界面;--project-dir 会持久化原型图并支持同端口重启。
scripts/start-server.sh --project-dir /path/to/project --open

# 返回: {"type":"server-started","port":52341,
#           "url":"http://localhost:52341/?key=ab12…",
#           "screen_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/content",
#           "state_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/state"}
```

把返回结果里的 `screen_dir` 和 `state_dir` 存下来。用了 `--open` 后,当你推送第一个界面时浏览器会自己打开 —— 你不需要请用户去打开它,但仍然把 URL 分享给他们作为兜底(无头/远程环境不会自动打开)。

**URL 里包含一个会话密钥(`?key=…`)。** 服务会拒绝任何不带它的请求,所以务必把 `url` 字段里**完整**的 URL 给用户 —— 绝不要把查询串去掉,也绝不要甩给用户一个光秃秃的 `http://host:port`。这个密钥把守着 HTTP 和 WebSocket 访问,这样一个乱入的浏览器标签页或网络上的另一台机器就没法读取这些界面、也没法注入事件。首次加载之后,浏览器会通过 cookie 记住这个密钥,所以重新加载和 `/files/*` 资源都不用再带它。

**找连接信息:** 服务会把启动时的 JSON 写到 `$STATE_DIR/server-info`。如果你是在后台启动服务、又没捕获 stdout,读这个文件就能拿到 URL 和端口。用 `--project-dir` 时,到 `<project>/.superpowers/brainstorm/` 下找会话目录。

**注意:** 把项目根目录作为 `--project-dir` 传进去,这样原型图会持久化在 `.superpowers/brainstorm/` 里、能在服务重启后存活。不传的话,文件会进 `/tmp` 并被清理掉。如果 `.superpowers/` 还没加进 `.gitignore`,提醒用户加上。

**按平台启动服务:**

**Claude Code:**
```bash
# 默认模式即可 —— 脚本会自己把服务放到后台。
scripts/start-server.sh --project-dir /path/to/project --open
```

在 Windows 上,脚本会自动检测并切换到前台模式(这会阻塞该工具调用)。在 Bash 工具调用上用 `run_in_background: true`,好让服务在多轮对话间存活,然后下一轮读 `$STATE_DIR/server-info` 拿到 URL 和端口。

**Codex:**
```bash
# Codex 会回收后台进程。脚本会自动检测 CODEX_CI 并
# 切换到前台模式。正常运行即可 —— 不需要额外的 flag。
scripts/start-server.sh --project-dir /path/to/project --open
```

**Gemini CLI:**
```bash
# 用 --foreground,并在你的 shell 工具调用上设 is_background: true
# 好让进程在多轮之间存活
scripts/start-server.sh --project-dir /path/to/project --open --foreground
```

**Copilot CLI:**
```bash
# 使用 Copilot CLI 的非阻塞/后台 shell 机制启动,让服务在多轮之间存活。
# 保留 --foreground,由运行环境而不是脚本负责后台运行。启动器是 .sh 文件,
# 所以要通过 bash 调用(Windows 上则从 PowerShell 工具调用 Git Bash 的 bash.exe)。
bash scripts/start-server.sh --project-dir /path/to/project --open --foreground
```

**其他环境:** 服务必须在多轮对话之间保持在后台运行。如果你的环境会回收脱离终端的进程,就用 `--foreground`,并用你所在平台的后台执行机制来启动这个命令。

如果这个 URL 从你的浏览器访问不到(在远程/容器化环境里很常见),绑定一个非回环的 host:

```bash
scripts/start-server.sh \
  --project-dir /path/to/project \
  --host 0.0.0.0 \
  --url-host localhost
```

用 `--url-host` 来控制返回的 URL JSON 里打印出的主机名。

## 循环

1. **确认服务还活着**,然后把 **HTML 写**到 `screen_dir` 里一个新文件:
   - **必做:在提及 URL 或推送界面之前,先确认服务还活着。** 检查 `$STATE_DIR/server-info` 存在、且 `$STATE_DIR/server-stopped` 不存在。如果它已经关了,用 `start-server.sh` 并带上**相同的 `--project-dir`** 重启 —— 它会复用同一个端口,所以用户已打开的标签页会自己重新连上(服务下线期间它会显示一个"已暂停"的遮罩层),你也不用发新 URL。服务空闲 4 小时后会自动退出(可用 `--idle-timeout-minutes` 配置)。
   - 用语义化的文件名:`platform.html`、`visual-style.html`、`layout.html`
   - **绝不要复用文件名** —— 每个界面都用一个全新的文件
   - 用你的文件创建工具 —— **绝不要用 cat/heredoc**(会往终端里灌一堆噪音)
   - 服务会自动提供最新的那个文件

2. **告诉用户可以期待什么,然后结束你这一轮:**
   - 提醒他们 URL(每一步都要提,不只是第一次)
   - 简短用文字总结屏幕上是什么(比如"展示了首页的 3 个布局选项")
   - 请他们在终端里回复:"看一看,告诉我你的想法。想选的话点一下就行。"

3. **在你的下一轮** —— 等用户在终端里回复之后:
   - 如果 `$STATE_DIR/events` 存在就读它 —— 里面以 JSON 行的形式记录了用户在浏览器里的交互(点击、选择)
   - 和用户的终端文字合起来看,才能拼出完整画面
   - 终端消息是主要反馈;`state_dir/events` 提供结构化的交互数据

4. **迭代或推进** —— 如果反馈改变了当前界面,写一个新文件(比如 `layout-v2.html`)。只有当前这一步被校验通过后,才推进到下一个问题。

5. **回到终端时卸载界面** —— 当下一步用不着浏览器时(比如一个澄清性问题、一段取舍讨论),推送一个等待界面,把陈旧的内容清掉:

   ```html
   <!-- filename: waiting.html (or waiting-2.html, etc.) -->
   <div style="display:flex;align-items:center;justify-content:center;min-height:60vh">
     <p class="subtitle">Continuing in terminal...</p>
   </div>
   ```

   这样能避免用户盯着一个已经定下来的选择、而对话其实早已往前走了。等下一个可视化问题出现时,照常推送一个新的内容文件。

6. 重复直到结束。

## 编写内容片段

只写页面里边的那部分内容。服务会自动把它包进框架模板(页头、主题 CSS、连接状态,以及所有交互基础设施)。

**最简示例:**

```html
<h2>Which layout works better?</h2>
<p class="subtitle">Consider readability and visual hierarchy</p>

<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Single Column</h3>
      <p>Clean, focused reading experience</p>
    </div>
  </div>
  <div class="option" data-choice="b" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>Two Column</h3>
      <p>Sidebar navigation with main content</p>
    </div>
  </div>
</div>
```

就这些。不需要 `<html>`,不需要 CSS,也不需要 `<script>` 标签。这些服务都提供了。

## 可用的 CSS 类

框架模板为你的内容提供了这些 CSS 类:

### Options(A/B/C 选择)

```html
<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Title</h3>
      <p>Description</p>
    </div>
  </div>
</div>
```

**多选:** 在容器上加 `data-multiselect`,让用户可以选多个选项。每次点击都会切换该项的选中样式。

```html
<div class="options" data-multiselect>
  <!-- same option markup — users can select/deselect multiple -->
</div>
```

### Cards(视觉设计)

```html
<div class="cards">
  <div class="card" data-choice="design1" onclick="toggleSelect(this)">
    <div class="card-image"><!-- mockup content --></div>
    <div class="card-body">
      <h3>Name</h3>
      <p>Description</p>
    </div>
  </div>
</div>
```

### Mockup 容器

```html
<div class="mockup">
  <div class="mockup-header">Preview: Dashboard Layout</div>
  <div class="mockup-body"><!-- your mockup HTML --></div>
</div>
```

### Split view(并排)

```html
<div class="split">
  <div class="mockup"><!-- left --></div>
  <div class="mockup"><!-- right --></div>
</div>
```

### Pros/Cons(优点/缺点)

```html
<div class="pros-cons">
  <div class="pros"><h4>Pros</h4><ul><li>Benefit</li></ul></div>
  <div class="cons"><h4>Cons</h4><ul><li>Drawback</li></ul></div>
</div>
```

### Mock 元素(线框图积木)

```html
<div class="mock-nav">Logo | Home | About | Contact</div>
<div style="display: flex;">
  <div class="mock-sidebar">Navigation</div>
  <div class="mock-content">Main content area</div>
</div>
<button class="mock-button">Action Button</button>
<input class="mock-input" placeholder="Input field">
<div class="placeholder">Placeholder area</div>
```

### 排版与分节

- `h2` —— 页面标题
- `h3` —— 分节标题
- `.subtitle` —— 标题下方的次级文字
- `.section` —— 带下边距的内容块
- `.label` —— 小号大写标签文字

## 浏览器事件格式

当用户在浏览器里点击选项时,他们的交互会被记录到 `$STATE_DIR/events`(每行一个 JSON 对象)。当你推送一个新界面时,该文件会被自动清空。

```jsonl
{"type":"click","choice":"a","text":"Option A - Simple Layout","timestamp":1706000101}
{"type":"click","choice":"c","text":"Option C - Complex Grid","timestamp":1706000108}
{"type":"click","choice":"b","text":"Option B - Hybrid","timestamp":1706000115}
```

完整的事件流展现了用户的探索路径 —— 他们可能在定下来之前点了多个选项。最后一个 `choice` 事件通常是最终选择,但这一连串的点击可能透露出犹豫或偏好,值得就此发问。

如果 `$STATE_DIR/events` 不存在,说明用户没有和浏览器交互 —— 那就只用他们的终端文字。

## 设计小贴士

- **让保真度与问题相称** —— 布局问题用线框图,打磨问题就做打磨
- **在每个页面上解释清楚这个问题** —— 用"哪个布局感觉更专业?"而不是光说"选一个"
- **推进前先迭代** —— 如果反馈改变了当前界面,写一个新版本
- 每个界面**最多 2-4 个选项**
- **该用真实内容时就用** —— 对一个摄影作品集,用真实图片(Unsplash)。占位内容会掩盖设计问题。
- **原型图保持简单** —— 聚焦布局和结构,而不是像素级完美的设计

## 文件命名

- 用语义化的名字:`platform.html`、`visual-style.html`、`layout.html`
- 绝不要复用文件名 —— 每个界面都必须是一个新文件
- 迭代时:追加版本后缀,比如 `layout-v2.html`、`layout-v3.html`
- 服务按修改时间提供最新的那个文件

## 收尾清理

```bash
scripts/stop-server.sh $SESSION_DIR
```

如果这次会话用了 `--project-dir`,原型图文件会持久化在 `.superpowers/brainstorm/` 里供日后参考。只有 `/tmp` 会话会在停止时被删除。

## 参考

- 框架模板(CSS 参考):`scripts/frame-template.html`
- 辅助脚本(客户端):`scripts/helper.js`
