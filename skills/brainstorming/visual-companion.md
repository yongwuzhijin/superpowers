# 视觉辅助工具指南

一个基于浏览器的视觉头脑风暴辅助工具,用于展示原型图、示意图和各种选项。

## 何时使用

按问题来决定,而不是按会话来决定。判断标准:**用户是"看到它"比"读到它"更容易理解吗?**

当内容本身就是视觉性的,**用浏览器**:

- **UI 原型图** — 线框图、布局、导航结构、组件设计
- **架构示意图** — 系统组件、数据流、关系图
- **并排的视觉对比** — 对比两种布局、两套配色、两个设计方向
- **设计打磨** — 当问题是关于观感、间距、视觉层级时
- **空间关系** — 状态机、流程图、以图形呈现的实体关系

当内容是文字或表格,**用终端**:

- **需求和范围问题** — "X 是什么意思?"、"哪些功能在范围内?"
- **概念性的 A/B/C 选择** — 在几种用文字描述的方案里挑选
- **取舍清单** — 优缺点、对比表
- **技术决策** — API 设计、数据建模、架构方案选型
- **澄清性问题** — 任何答案是文字、而非视觉偏好的问题

一个*关于* UI 话题的问题,并不自动就是视觉问题。"你想要什么样的向导?"是概念性的——用终端。"这几种向导布局里哪个感觉对?"是视觉性的——用浏览器。

## 工作原理

服务会监视一个目录里的 HTML 文件,并把最新的那个提供给浏览器。你把 HTML 内容写到 `screen_dir`,用户就能在浏览器里看到它,还能点击来选择选项。选择结果会记录到 `state_dir/events`,你在下一轮读取它。

**内容片段 vs 完整文档:** 如果你的 HTML 文件以 `<!DOCTYPE` 或 `<html` 开头,服务会原样提供(只注入辅助脚本)。否则,服务会自动把你的内容包进框架模板里——加上页眉、CSS 主题、连接状态,以及所有交互基础设施。**默认写内容片段。** 只有在你需要完全掌控整个页面时,才写完整文档。

## 开启一个会话

```bash
# Start AFTER the user approves the companion. --open auto-opens their browser on
# the first screen; --project-dir persists mockups and enables same-port restart.
scripts/start-server.sh --project-dir /path/to/project --open

# Returns: {"type":"server-started","port":52341,
#           "url":"http://localhost:52341/?key=ab12…",
#           "screen_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/content",
#           "state_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/state"}
```

从返回结果里保存好 `screen_dir` 和 `state_dir`。加了 `--open` 后,当你推送第一屏时浏览器会自己打开——你不用叫用户去打开,不过还是把 URL 给他们作为备用(无头 / 远程环境不会自动打开)。

**URL 里包含一个会话密钥(`?key=…`)。** 服务会拒绝任何不带它的请求,所以永远要把 `url` 字段里那条**完整**的 URL 给用户——绝不要把查询串删掉,也绝不要甩给用户一个光秃秃的 `http://host:port`。这个密钥把守着 HTTP 和 WebSocket 访问,这样一个乱入的浏览器标签页、或网络上的另一台机器就没法读取这些屏幕内容、也没法注入事件。首次加载后,浏览器会用 cookie 记住这个密钥,所以刷新和 `/files/*` 资源无需再带密钥也能用。

**找到连接信息:** 服务会把它的启动 JSON 写到 `$STATE_DIR/server-info`。如果你是在后台启动服务、又没捕获 stdout,读这个文件就能拿到 URL 和端口。用了 `--project-dir` 时,去 `<project>/.superpowers/brainstorm/` 找会话目录。

**注意:** 把项目根目录作为 `--project-dir` 传进去,这样原型图会持久化在 `.superpowers/brainstorm/` 里,能扛过服务重启。不传的话,文件会进 `/tmp` 并被清掉。提醒用户,如果 `.superpowers/` 还没加进 `.gitignore`,就加一下。

**按平台启动服务:**

**Claude Code:**
```bash
# Default mode works — the script backgrounds the server itself.
scripts/start-server.sh --project-dir /path/to/project --open
```

在 Windows 上,脚本会自动检测并切到前台模式(这会阻塞工具调用)。在 Bash 工具调用上用 `run_in_background: true`,让服务能跨对话轮次存活,然后下一轮读 `$STATE_DIR/server-info` 拿到 URL 和端口。

**Codex:**
```bash
# Codex reaps background processes. The script auto-detects CODEX_CI and
# switches to foreground mode. Run it normally — no extra flags needed.
scripts/start-server.sh --project-dir /path/to/project --open
```

**Copilot CLI:**
```bash
# Use --foreground and start the server via the bash tool with mode: "async"
# so the process survives across turns. Capture the returned shellId for
# read_bash / stop_bash if you need to interact with it later.
scripts/start-server.sh --project-dir /path/to/project --open --foreground
```

**其他环境:** 服务必须跨对话轮次在后台一直运行。如果你的环境会回收(reap)脱离的进程,就用 `--foreground`,并用你所在平台的后台执行机制来启动这条命令。

如果 URL 从你的浏览器访问不到(在远程 / 容器化环境里很常见),绑定一个非回环主机:

```bash
scripts/start-server.sh \
  --project-dir /path/to/project \
  --host 0.0.0.0 \
  --url-host localhost
```

用 `--url-host` 来控制返回的 URL JSON 里打印的是哪个主机名。

## 循环流程

1. **确认服务还活着**,然后把 **HTML 写**到 `screen_dir` 里的一个新文件:
   - **必做:在引用 URL 或推送屏幕之前,先确认服务是活的。** 检查 `$STATE_DIR/server-info` 存在、且 `$STATE_DIR/server-stopped` 不存在。如果它已经关了,用**同一个 `--project-dir`** 通过 `start-server.sh` 重启它——它会复用同一个端口,所以用户已打开的标签页会自己重连(服务停着时它会显示一个"已暂停"的遮罩层),你不用再发新 URL。服务在空闲 4 小时后会自动退出(可用 `--idle-timeout-minutes` 配置)。
   - 用有语义的文件名:`platform.html`、`visual-style.html`、`layout.html`
   - **绝不复用文件名**——每一屏都用一个全新的文件
   - 用你的文件创建工具——**绝不要用 cat/heredoc**(会往终端里灌一堆噪声)
   - 服务会自动提供最新的那个文件

2. **告诉用户会看到什么,然后结束你这一轮:**
   - 提醒他们 URL(每一步都提,不只是第一次)
   - 简短用文字概括屏幕上有什么(比如"正在展示首页的 3 种布局选项")
   - 请他们在终端里回复:"看一眼,告诉我你的想法。想选的话点一下就行。"

3. **在你的下一轮**——在用户于终端里回复之后:
   - 如果 `$STATE_DIR/events` 存在就读它——它以 JSON 行的形式,包含了用户在浏览器里的交互(点击、选择)
   - 和用户的终端文字合起来看,才能得到全貌
   - 终端消息是主要反馈;`state_dir/events` 提供结构化的交互数据

4. **迭代或推进**——如果反馈要改当前这屏,就写一个新文件(比如 `layout-v2.html`)。只有当前这一步验证通过了,才推进到下一个问题。

5. **回到终端时卸载画面**——当下一步不需要浏览器时(比如一个澄清性问题、一次取舍讨论),推送一个等待屏来清掉过时的内容:

   ```html
   <!-- filename: waiting.html (or waiting-2.html, etc.) -->
   <div style="display:flex;align-items:center;justify-content:center;min-height:60vh">
     <p class="subtitle">Continuing in terminal...</p>
   </div>
   ```

   这样能避免用户盯着一个已经定了的选择、而对话其实早就往下走了。等下一个视觉问题冒出来时,照常推送一个新的内容文件。

6. 重复直到完成。

## 编写内容片段

只写放进页面里的那部分内容。服务会自动把它包进框架模板(页眉、主题 CSS、连接状态,以及所有交互基础设施)。

**最小示例:**

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

就这样。不需要 `<html>`,不需要 CSS,也不需要 `<script>` 标签。这些服务都帮你搞定了。

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

**多选:** 给容器加上 `data-multiselect`,让用户可以选多个选项。每次点击都会切换该项的选中样式。

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

### 原型图容器

```html
<div class="mockup">
  <div class="mockup-header">Preview: Dashboard Layout</div>
  <div class="mockup-body"><!-- your mockup HTML --></div>
</div>
```

### 分栏视图(并排)

```html
<div class="split">
  <div class="mockup"><!-- left --></div>
  <div class="mockup"><!-- right --></div>
</div>
```

### 优缺点

```html
<div class="pros-cons">
  <div class="pros"><h4>Pros</h4><ul><li>Benefit</li></ul></div>
  <div class="cons"><h4>Cons</h4><ul><li>Drawback</li></ul></div>
</div>
```

### Mock 元素(线框图积木块)

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

### 排版与分区

- `h2` — 页面标题
- `h3` — 分区标题
- `.subtitle` — 标题下方的次级文字
- `.section` — 带底部外边距的内容块
- `.label` — 小号大写标签文字

## 浏览器事件格式

当用户在浏览器里点击选项时,他们的交互会被记录到 `$STATE_DIR/events`(每行一个 JSON 对象)。你每推送一个新屏幕,该文件就会被自动清空。

```jsonl
{"type":"click","choice":"a","text":"Option A - Simple Layout","timestamp":1706000101}
{"type":"click","choice":"c","text":"Option C - Complex Grid","timestamp":1706000108}
{"type":"click","choice":"b","text":"Option B - Hybrid","timestamp":1706000115}
```

完整的事件流展示了用户的探索路径——他们可能在定下来之前点了好几个选项。最后一个 `choice` 事件通常就是最终选择,但点击的模式可能透露出犹豫或偏好,值得追问一下。

如果 `$STATE_DIR/events` 不存在,说明用户没跟浏览器交互——那就只用他们的终端文字。

## 设计小贴士

- **保真度按问题来定** — 布局问题用线框图,打磨问题就做得精致些
- **在每一页解释清楚问题** — 写"哪种布局更专业?"而不是光写"选一个"
- **推进前先迭代** — 如果反馈要改当前这屏,就写个新版本
- 每屏**最多 2-4 个选项**
- **该用真实内容时就用真实内容** — 做摄影作品集时,用真实图片(Unsplash)。占位内容会掩盖设计问题。
- **原型图保持简单** — 聚焦布局和结构,别追求像素级完美的设计

## 文件命名

- 用有语义的名字:`platform.html`、`visual-style.html`、`layout.html`
- 绝不复用文件名——每一屏都必须是新文件
- 迭代时:追加版本后缀,比如 `layout-v2.html`、`layout-v3.html`
- 服务按修改时间提供最新的文件

## 收尾清理

```bash
scripts/stop-server.sh $SESSION_DIR
```

如果会话用了 `--project-dir`,原型图文件会持久保留在 `.superpowers/brainstorm/` 里,供日后参考。只有 `/tmp` 里的会话会在停止时被删除。

## 参考

- 框架模板(CSS 参考):`scripts/frame-template.html`
- 辅助脚本(客户端):`scripts/helper.js`
