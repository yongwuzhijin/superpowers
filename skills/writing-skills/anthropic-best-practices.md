# 技能编写最佳实践

> 学习如何编写 Agent 能发现并成功使用的高效技能。

好的技能简洁、结构良好,并经过真实使用的测试。本指南提供实用的编写决策,帮你写出 Agent 能有效发现并使用的技能。

关于技能如何工作的概念背景,见 [Skills overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)。

## 核心原则

### 简洁是关键

[上下文窗口](https://platform.claude.com/docs/en/build-with-claude/context-windows)是一种公共资源。你的技能和 Agent 需要知道的其他一切共享同一个上下文窗口,包括:

* 系统提示
* 对话历史
* 其他技能的元数据
* 你的实际请求

并非你技能里的每个 token 都有即时成本。启动时,只有所有技能的元数据(name 和 description)会被预加载。Agent 只在技能变得相关时才读 SKILL.md,并只在需要时才读额外文件。不过,SKILL.md 里保持简洁依然重要:一旦 Agent 加载了它,每个 token 都在跟对话历史和其他上下文抢地盘。

**默认假设**:Agent 本来就很聪明

只补充 Agent 还没有的上下文。对每一条信息都要质疑:

* "Agent 真的需要这个解释吗?"
* "我能假设 Agent 已经知道这个吗?"
* "这一段配得上它的 token 成本吗?"

**好例子:简洁**(约 50 个 token):

````markdown  theme={null}
## Extract PDF text

Use pdfplumber for text extraction:

```python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````

**坏例子:太啰嗦**(约 150 个 token):

```markdown  theme={null}
## Extract PDF text

PDF (Portable Document Format) files are a common file format that contains
text, images, and other content. To extract text from a PDF, you'll need to
use a library. There are many libraries available for PDF processing, but we
recommend pdfplumber because it's easy to use and handles most cases well.
First, you'll need to install it using pip. Then you can use the code below...
```

简洁版假设 Agent 知道 PDF 是什么、库是怎么用的。

### 设定恰当的自由度

让具体程度匹配任务的脆弱性和可变性。

**高自由度**(基于文本的指令):

在以下情况使用:

* 多种做法都有效
* 决策取决于上下文
* 靠启发式来引导做法

示例:

```markdown  theme={null}
## Code review process

1. Analyze the code structure and organization
2. Check for potential bugs or edge cases
3. Suggest improvements for readability and maintainability
4. Verify adherence to project conventions
```

**中自由度**(带参数的伪代码或脚本):

在以下情况使用:

* 存在一个首选模式
* 可以接受一些变化
* 配置会影响行为

示例:

````markdown  theme={null}
## Generate report

Use this template and customize as needed:

```python
def generate_report(data, format="markdown", include_charts=True):
    # Process data
    # Generate output in specified format
    # Optionally include visualizations
```
````

**低自由度**(具体脚本,很少或没有参数):

在以下情况使用:

* 操作脆弱且容易出错
* 一致性至关重要
* 必须遵循特定的顺序

示例:

````markdown  theme={null}
## Database migration

Run exactly this script:

```bash
python scripts/migrate.py --verify --backup
```

Do not modify the command or add additional flags.
````

**类比**:把 Agent 想象成一个在路径上探索的机器人:

* **两侧是悬崖的窄桥**:只有一条安全的路可走。提供具体的护栏和精确的指令(低自由度)。例如:必须严格按顺序运行的数据库迁移。
* **没有危险的开阔地**:很多路都通向成功。给个大方向,信任 Agent 找到最佳路线(高自由度)。例如:由上下文决定最佳做法的代码评审。

### 用你打算使用的所有模型测试

技能是对模型的补充,所以其效果取决于底层模型。用你打算使用的所有模型测试你的技能。

**按模型分的测试考量**:

* **Claude Haiku**(快、经济):技能提供的指引够吗?
* **Claude Sonnet**(均衡):技能清晰、高效吗?
* **Claude Opus**(强推理):技能有没有过度解释?

对 Opus 完美的东西,对 Haiku 可能需要更多细节。如果你打算跨多个模型使用你的技能,力求指令对它们全都好用。

## 技能结构

<Note>
  **YAML Frontmatter**:SKILL.md 的 frontmatter 需要两个字段:

  * `name` - 技能的可读名称(最多 64 字符)
  * `description` - 一句话描述技能做什么以及何时使用(最多 1024 字符)

  完整的技能结构细节见 [Skills overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#skill-structure)。
</Note>

### 命名约定

使用一致的命名模式,让技能更容易被引用和讨论。我们推荐技能名用**动名词形式**(动词 + -ing),因为这能清楚描述该技能提供的活动或能力。

**好的命名示例(动名词形式)**:

* "Processing PDFs"
* "Analyzing spreadsheets"
* "Managing databases"
* "Testing code"
* "Writing documentation"

**可接受的替代**:

* 名词短语:"PDF Processing"、"Spreadsheet Analysis"
* 动作导向:"Process PDFs"、"Analyze Spreadsheets"

**避免**:

* 含糊的名字:"Helper"、"Utils"、"Tools"
* 过于笼统:"Documents"、"Data"、"Files"
* 你的技能集合内部前后不一致的模式

一致的命名让以下事情更容易:

* 在文档和对话中引用技能
* 一眼看懂某个技能是做什么的
* 组织和搜索多个技能
* 维护一个专业、连贯的技能库

### 编写高效的 description

`description` 字段决定了技能能否被发现,它应当同时包含技能做什么以及何时使用。

<Warning>
  **永远用第三人称写**。description 会被注入系统提示,视角不一致会导致发现问题。

  * **好:** "Processes Excel files and generates reports"
  * **避免:** "I can help you process Excel files"
  * **避免:** "You can use this to process Excel files"
</Warning>

**要具体,并包含关键词**。同时写清技能做什么、以及何时使用它的具体触发点/上下文。

每个技能都恰好有一个 description 字段。description 对技能选择至关重要:Agent 会用它从可能上百个可用技能里挑出正确的那个。你的 description 必须提供足够的细节,让 Agent 知道何时选这个技能,而 SKILL.md 的其余部分提供实现细节。

有效的示例:

**PDF Processing 技能:**

```yaml  theme={null}
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

**Excel Analysis 技能:**

```yaml  theme={null}
description: Analyze Excel spreadsheets, create pivot tables, generate charts. Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files.
```

**Git Commit Helper 技能:**

```yaml  theme={null}
description: Generate descriptive commit messages by analyzing git diffs. Use when the user asks for help writing commit messages or reviewing staged changes.
```

避免像这样含糊的 description:

```yaml  theme={null}
description: Helps with documents
```

```yaml  theme={null}
description: Processes data
```

```yaml  theme={null}
description: Does stuff with files
```

### 渐进式披露的模式

SKILL.md 充当一份概述,按需把 Agent 指向详细材料,就像入职指南里的目录。关于渐进式披露如何工作的解释,见概述里的 [How Skills work](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#how-skills-work)。

**实用指引:**

* 为获得最佳性能,把 SKILL.md 正文保持在 500 行以内
* 接近这个上限时,把内容拆成单独的文件
* 用下面的模式来有效组织指令、代码和资源

#### 可视化概览:从简单到复杂

一个基础技能一开始只有一个 SKILL.md 文件,里面包含元数据和指令:

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=87782ff239b297d9a9e8e1b72ed72db9" alt="Simple SKILL.md file showing YAML frontmatter and markdown body" data-og-width="2048" width="2048" data-og-height="1153" height="1153" data-path="images/agent-skills-simple-file.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=c61cc33b6f5855809907f7fda94cd80e 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=90d2c0c1c76b36e8d485f49e0810dbfd 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=ad17d231ac7b0bea7e5b4d58fb4aeabb 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=f5d0a7a3c668435bb0aee9a3a8f8c329 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=0e927c1af9de5799cfe557d12249f6e6 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=46bbb1a51dd4c8202a470ac8c80a893d 2500w" />

随着技能变大,你可以捆绑额外内容,Agent 只在需要时才加载:

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=a5e0aa41e3d53985a7e3e43668a33ea3" alt="Bundling additional reference files like reference.md and forms.md." data-og-width="2048" width="2048" data-og-height="1327" height="1327" data-path="images/agent-skills-bundling-content.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=f8a0e73783e99b4a643d79eac86b70a2 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=dc510a2a9d3f14359416b706f067904a 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=82cd6286c966303f7dd914c28170e385 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=56f3be36c77e4fe4b523df209a6824c6 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=d22b5161b2075656417d56f41a74f3dd 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=3dd4bdd6850ffcc96c6c45fcb0acd6eb 2500w" />

完整的技能目录结构可能长这样:

```
pdf/
├── SKILL.md              # Main instructions (loaded when triggered)
├── FORMS.md              # Form-filling guide (loaded as needed)
├── reference.md          # API reference (loaded as needed)
├── examples.md           # Usage examples (loaded as needed)
└── scripts/
    ├── analyze_form.py   # Utility script (executed, not loaded)
    ├── fill_form.py      # Form filling script
    └── validate.py       # Validation script
```

#### 模式 1:高层指南 + 参考

````markdown  theme={null}
---
name: PDF Processing
description: Extracts text and tables from PDF files, fills forms, and merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---

# PDF Processing

## Quick start

Extract text with pdfplumber:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

## Advanced features

**Form filling**: See [FORMS.md](FORMS.md) for complete guide
**API reference**: See [REFERENCE.md](REFERENCE.md) for all methods
**Examples**: See [EXAMPLES.md](EXAMPLES.md) for common patterns
````

Agent 只在需要时才加载 FORMS.md、REFERENCE.md 或 EXAMPLES.md。

#### 模式 2:按领域组织

对于横跨多个领域的技能,按领域组织内容,以避免加载无关的上下文。当用户问销售指标时,Agent 只需读跟销售相关的 schema,而不用读财务或市场的数据。这让 token 用量保持在低位、上下文保持聚焦。

```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── reference/
    ├── finance.md (revenue, billing metrics)
    ├── sales.md (opportunities, pipeline)
    ├── product.md (API usage, features)
    └── marketing.md (campaigns, attribution)
```

````markdown SKILL.md theme={null}
# BigQuery Data Analysis

## Available datasets

**Finance**: Revenue, ARR, billing → See [reference/finance.md](reference/finance.md)
**Sales**: Opportunities, pipeline, accounts → See [reference/sales.md](reference/sales.md)
**Product**: API usage, features, adoption → See [reference/product.md](reference/product.md)
**Marketing**: Campaigns, attribution, email → See [reference/marketing.md](reference/marketing.md)

## Quick search

Find specific metrics using grep:

```bash
grep -i "revenue" reference/finance.md
grep -i "pipeline" reference/sales.md
grep -i "api usage" reference/product.md
```
````

#### 模式 3:条件式细节

展示基础内容,链接到进阶内容:

```markdown  theme={null}
# DOCX Processing

## Creating documents

Use docx-js for new documents. See [DOCX-JS.md](DOCX-JS.md).

## Editing documents

For simple edits, modify the XML directly.

**For tracked changes**: See [REDLINING.md](REDLINING.md)
**For OOXML details**: See [OOXML.md](OOXML.md)
```

Agent 只在用户需要那些功能时才读 REDLINING.md 或 OOXML.md。

### 避免深层嵌套的引用

当文件是从其他被引用的文件里引用出来时,Agent 可能只会部分读取它们。遇到嵌套引用时,Agent 可能会用 `head -100` 之类的命令预览内容、而不是读整个文件,结果得到不完整的信息。

**让引用从 SKILL.md 起只有一层深**。所有参考文件都应直接从 SKILL.md 链接,以确保 Agent 在需要时能读到完整文件。

**坏例子:太深**:

```markdown  theme={null}
# SKILL.md
See [advanced.md](advanced.md)...

# advanced.md
See [details.md](details.md)...

# details.md
Here's the actual information...
```

**好例子:一层深**:

```markdown  theme={null}
# SKILL.md

**Basic usage**: [instructions in SKILL.md]
**Advanced features**: See [advanced.md](advanced.md)
**API reference**: See [reference.md](reference.md)
**Examples**: See [examples.md](examples.md)
```

### 给较长的参考文件加目录

对于超过 100 行的参考文件,在顶部放一个目录。这确保即便 Agent 用部分读取来预览,也能看到可用信息的完整范围。

**示例**:

```markdown  theme={null}
# API Reference

## Contents
- Authentication and setup
- Core methods (create, read, update, delete)
- Advanced features (batch operations, webhooks)
- Error handling patterns
- Code examples

## Authentication and setup
...

## Core methods
...
```

Agent 于是能读整个文件,或按需跳到具体章节。

关于这种基于文件系统的架构如何实现渐进式披露的细节,见下面进阶章节里的 [Runtime environment](#runtime-environment)。

## 工作流与反馈回路

### 用工作流处理复杂任务

把复杂操作拆成清晰、有序的步骤。对于特别复杂的工作流,提供一份 Agent 可以复制到回复里、随进度打勾的检查清单。

**示例 1:研究综述工作流**(适用于没有代码的技能):

````markdown  theme={null}
## Research synthesis workflow

Copy this checklist and track your progress:

```
Research Progress:
- [ ] Step 1: Read all source documents
- [ ] Step 2: Identify key themes
- [ ] Step 3: Cross-reference claims
- [ ] Step 4: Create structured summary
- [ ] Step 5: Verify citations
```

**Step 1: Read all source documents**

Review each document in the `sources/` directory. Note the main arguments and supporting evidence.

**Step 2: Identify key themes**

Look for patterns across sources. What themes appear repeatedly? Where do sources agree or disagree?

**Step 3: Cross-reference claims**

For each major claim, verify it appears in the source material. Note which source supports each point.

**Step 4: Create structured summary**

Organize findings by theme. Include:
- Main claim
- Supporting evidence from sources
- Conflicting viewpoints (if any)

**Step 5: Verify citations**

Check that every claim references the correct source document. If citations are incomplete, return to Step 3.
````

这个示例展示了工作流如何适用于不需要代码的分析任务。检查清单模式适用于任何复杂的多步骤流程。

**示例 2:PDF 表单填充工作流**(适用于有代码的技能):

````markdown  theme={null}
## PDF form filling workflow

Copy this checklist and check off items as you complete them:

```
Task Progress:
- [ ] Step 1: Analyze the form (run analyze_form.py)
- [ ] Step 2: Create field mapping (edit fields.json)
- [ ] Step 3: Validate mapping (run validate_fields.py)
- [ ] Step 4: Fill the form (run fill_form.py)
- [ ] Step 5: Verify output (run verify_output.py)
```

**Step 1: Analyze the form**

Run: `python scripts/analyze_form.py input.pdf`

This extracts form fields and their locations, saving to `fields.json`.

**Step 2: Create field mapping**

Edit `fields.json` to add values for each field.

**Step 3: Validate mapping**

Run: `python scripts/validate_fields.py fields.json`

Fix any validation errors before continuing.

**Step 4: Fill the form**

Run: `python scripts/fill_form.py input.pdf fields.json output.pdf`

**Step 5: Verify output**

Run: `python scripts/verify_output.py output.pdf`

If verification fails, return to Step 2.
````

清晰的步骤能防止 Agent 跳过关键的校验。检查清单帮你和 Agent 一起在多步骤工作流中跟踪进度。

### 实现反馈回路

**常见模式**:跑校验器 → 修错误 → 重复

这个模式能大幅提升输出质量。

**示例 1:风格指南合规**(适用于没有代码的技能):

```markdown  theme={null}
## Content review process

1. Draft your content following the guidelines in STYLE_GUIDE.md
2. Review against the checklist:
   - Check terminology consistency
   - Verify examples follow the standard format
   - Confirm all required sections are present
3. If issues found:
   - Note each issue with specific section reference
   - Revise the content
   - Review the checklist again
4. Only proceed when all requirements are met
5. Finalize and save the document
```

这展示了用参考文档(而非脚本)实现的校验回路模式。"校验器"是 STYLE\_GUIDE.md,Agent 通过阅读和比对来执行检查。

**示例 2:文档编辑流程**(适用于有代码的技能):

```markdown  theme={null}
## Document editing process

1. Make your edits to `word/document.xml`
2. **Validate immediately**: `python ooxml/scripts/validate.py unpacked_dir/`
3. If validation fails:
   - Review the error message carefully
   - Fix the issues in the XML
   - Run validation again
4. **Only proceed when validation passes**
5. Rebuild: `python ooxml/scripts/pack.py unpacked_dir/ output.docx`
6. Test the output document
```

校验回路能尽早捕获错误。

## 内容准则

### 避免时效性信息

不要包含会过时的信息:

**坏例子:时效性**(会变得不对):

```markdown  theme={null}
If you're doing this before August 2025, use the old API.
After August 2025, use the new API.
```

**好例子**(用"旧模式"一节):

```markdown  theme={null}
## Current method

Use the v2 API endpoint: `api.example.com/v2/messages`

## Old patterns

<details>
<summary>Legacy v1 API (deprecated 2025-08)</summary>

The v1 API used: `api.example.com/v1/messages`

This endpoint is no longer supported.
</details>
```

"旧模式"一节提供历史背景,又不会把主要内容搞乱。

### 使用一致的术语

选定一个词,在整个技能里贯穿使用:

**好 - 一致**:

* 始终用 "API endpoint"
* 始终用 "field"
* 始终用 "extract"

**坏 - 不一致**:

* 混用 "API endpoint"、"URL"、"API route"、"path"
* 混用 "field"、"box"、"element"、"control"
* 混用 "extract"、"pull"、"get"、"retrieve"

一致性帮 Agent 理解并遵循指令。

## 常见模式

### 模板模式

为输出格式提供模板。让严格程度匹配你的需要。

**对于严格要求**(比如 API 响应或数据格式):

````markdown  theme={null}
## Report structure

ALWAYS use this exact template structure:

```markdown
# [Analysis Title]

## Executive summary
[One-paragraph overview of key findings]

## Key findings
- Finding 1 with supporting data
- Finding 2 with supporting data
- Finding 3 with supporting data

## Recommendations
1. Specific actionable recommendation
2. Specific actionable recommendation
```
````

**对于灵活指引**(当适应变化有用时):

````markdown  theme={null}
## Report structure

Here is a sensible default format, but use your best judgment based on the analysis:

```markdown
# [Analysis Title]

## Executive summary
[Overview]

## Key findings
[Adapt sections based on what you discover]

## Recommendations
[Tailor to the specific context]
```

Adjust sections as needed for the specific analysis type.
````

### 示例模式

对于输出质量取决于看到示例的技能,像常规提示那样提供输入/输出对:

````markdown  theme={null}
## Commit message format

Generate commit messages following these examples:

**Example 1:**
Input: Added user authentication with JWT tokens
Output:
```
feat(auth): implement JWT-based authentication

Add login endpoint and token validation middleware
```

**Example 2:**
Input: Fixed bug where dates displayed incorrectly in reports
Output:
```
fix(reports): correct date formatting in timezone conversion

Use UTC timestamps consistently across report generation
```

**Example 3:**
Input: Updated dependencies and refactored error handling
Output:
```
chore: update dependencies and refactor error handling

- Upgrade lodash to 4.17.21
- Standardize error response format across endpoints
```

Follow this style: type(scope): brief description, then detailed explanation.
````

示例比单纯的描述更能帮 Agent 清晰地理解想要的风格和细节程度。

### 条件式工作流模式

引导 Agent 走过决策点:

```markdown  theme={null}
## Document modification workflow

1. Determine the modification type:

   **Creating new content?** → Follow "Creation workflow" below
   **Editing existing content?** → Follow "Editing workflow" below

2. Creation workflow:
   - Use docx-js library
   - Build document from scratch
   - Export to .docx format

3. Editing workflow:
   - Unpack existing document
   - Modify XML directly
   - Validate after each change
   - Repack when complete
```

<Tip>
  如果工作流变得庞大或步骤繁多而复杂,考虑把它们推到单独的文件里,并告诉 Agent 根据手头任务去读相应的文件。
</Tip>

## 评估与迭代

### 先建评估

**在写大量文档之前先建评估。** 这确保你的技能解决的是真实问题,而不是在给臆想出来的问题写文档。

**评估驱动的开发:**

1. **找出缺口**:在没有技能的情况下,让 Agent 跑一些有代表性的任务。记录具体的失败或缺失的上下文
2. **创建评估**:构建三个测试这些缺口的场景
3. **建立基线**:测量 Agent 在没有技能时的表现
4. **写最小指令**:只写刚好够弥补缺口、通过评估的内容
5. **迭代**:执行评估,对照基线比较,再打磨

这种做法确保你解决的是实际问题,而不是在预判可能永远不会出现的需求。

**评估结构**:

```json  theme={null}
{
  "skills": ["pdf-processing"],
  "query": "Extract all text from this PDF file and save it to output.txt",
  "files": ["test-files/document.pdf"],
  "expected_behavior": [
    "Successfully reads the PDF file using an appropriate PDF processing library or command-line tool",
    "Extracts text content from all pages in the document without missing any pages",
    "Saves the extracted text to a file named output.txt in a clear, readable format"
  ]
}
```

<Note>
  这个示例演示了带简单测试评分表的数据驱动评估。我们目前没有提供内置的方式来运行这些评估。用户可以创建自己的评估系统。评估是你衡量技能效果的真实依据。
</Note>

### 与 Agent 一起迭代开发技能

最有效的技能开发流程要让 Agent 自己参与进来。用一个实例("Agent A")来创建一个将由其他实例("Agent B")使用的技能。Agent A 帮你设计和打磨指令,而 Agent B 在真实任务里测试它们。这行得通,是因为底层模型既懂如何写出有效的 Agent 指令,也懂 Agent 需要什么信息。

**创建一个新技能:**

1. **不带技能完成一个任务**:用普通的提示,和 Agent A 一起把一个问题走一遍。在过程中,你自然会提供上下文、解释偏好、分享操作知识。留意你反复提供的信息。

2. **找出可复用的模式**:任务完成后,找出你提供的、对将来类似任务有用的上下文。

   **示例**:如果你做过一次 BigQuery 分析,你可能提供了表名、字段定义、过滤规则(比如"始终排除测试账号")以及常见的查询模式。

3. **让 Agent A 创建一个技能**:"创建一个技能,把我们刚用的这套 BigQuery 分析模式捕捉下来。包含表 schema、命名约定,以及关于过滤测试账号的规则。"

   <Tip>
     现代 Agent 原生就懂技能的格式和结构。你不需要特殊的系统提示或"写技能"的技能就能获得创建技能的帮助。只要让 Agent 创建一个技能,它就会生成结构正确、带合适 frontmatter 和正文的 SKILL.md 内容。
   </Tip>

4. **审查简洁度**:检查 Agent A 有没有加了不必要的解释。可以说:"删掉关于胜率是什么意思的解释——Agent 本来就知道那个。"

5. **改进信息架构**:让 Agent A 把内容组织得更有效。例如:"把这个组织一下,让表 schema 放在单独的参考文件里。我们以后可能会加更多表。"

6. **在类似任务上测试**:在相关用例上,用 Agent B(一个加载了该技能的全新实例)使用这个技能。观察 Agent B 是否找到了正确的信息、是否正确应用了规则、是否成功处理了任务。

7. **基于观察迭代**:如果 Agent B 卡住或漏了什么,带着具体情况回到 Agent A:"当 Agent 用这个技能时,它忘了给 Q4 按日期过滤。我们要不要加一节关于按日期过滤模式的内容?"

**迭代现有技能:**

改进技能时,同样的层级模式继续适用。你在以下之间来回切换:

* **与 Agent A 协作**(帮你打磨技能的专家)
* **与 Agent B 测试**(使用技能干真活的 Agent)
* **观察 Agent B 的行为**,把洞见带回给 Agent A

1. **在真实工作流中使用技能**:给 Agent B(已加载技能)真实的任务,而不是测试场景

2. **观察 Agent B 的行为**:留意它在哪里卡住、成功,或做出意料之外的选择

   **示例观察**:"当我让 Agent B 出一份区域销售报告时,它写了查询,但忘了过滤掉测试账号,尽管技能里提到了这条规则。"

3. **回到 Agent A 求改进**:分享当前的 SKILL.md,描述你观察到的情况。可以问:"我注意到当我让 Agent B 出区域报告时,它忘了过滤测试账号。技能里提到了过滤,但也许不够醒目?"

4. **审查 Agent A 的建议**:Agent A 可能会建议重新组织让规则更醒目、用更强的措辞(比如把 "always filter" 改成 "MUST filter"),或重构工作流那一节。

5. **应用并测试改动**:用 Agent A 的打磨更新技能,然后在类似请求上再次与 Agent B 测试

6. **基于使用反复**:随着遇到新场景,持续这个观察-打磨-测试的循环。每次迭代都基于真实的 Agent 行为、而非假设来改进技能。

**收集团队反馈:**

1. 把技能分享给队友并观察他们的使用
2. 问:技能会在预期的时候激活吗?指令清晰吗?缺了什么?
3. 吸收反馈,补上你自己使用模式里的盲点

**为什么这种做法有效**:Agent A 懂 Agent 的需要,你提供领域专长,Agent B 通过真实使用暴露缺口,而迭代打磨基于观察到的行为(而非假设)来改进技能。

### 观察 Agent 如何在技能中导航

在你迭代技能时,注意 Agent 实际上是怎么在实践中使用它们的。留意:

* **意料之外的探索路径**:Agent 是否以你没预料的顺序读文件?这可能说明你的结构没你想的那么直观
* **错过的连接**:Agent 是否没跟着引用去读重要文件?你的链接可能需要更明确或更醒目
* **过度依赖某些章节**:如果 Agent 反复读同一个文件,考虑那部分内容是不是应该放进主 SKILL.md
* **被忽略的内容**:如果 Agent 从不访问某个捆绑文件,它可能是多余的,或在主指令里没被好好提示

基于这些观察(而非假设)来迭代。你技能元数据里的 'name' 和 'description' 尤其关键。Agent 会在决定是否针对当前任务触发技能时用到它们。确保它们清楚地描述了技能做什么、以及何时该用它。

## 应避免的反模式

### 避免 Windows 风格的路径

文件路径里始终用正斜杠,即便在 Windows 上:

* ✓ **好**:`scripts/helper.py`、`reference/guide.md`
* ✗ **避免**:`scripts\helper.py`、`reference\guide.md`

Unix 风格的路径在所有平台上都能用,而 Windows 风格的路径在 Unix 系统上会导致错误。

### 避免给出太多选项

除非必要,不要给出多种做法:

````markdown  theme={null}
**Bad example: Too many choices** (confusing):
"You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image, or..."

**Good example: Provide a default** (with escape hatch):
"Use pdfplumber for text extraction:
```python
import pdfplumber
```

For scanned PDFs requiring OCR, use pdf2image with pytesseract instead."
````

## 进阶:带可执行代码的技能

下面的章节聚焦于包含可执行脚本的技能。如果你的技能只用 markdown 指令,直接跳到 [Checklist for effective Skills](#checklist-for-effective-skills)。

### 解决它,别甩锅

给技能写脚本时,自己处理错误情况,别把它甩给 Agent。

**好例子:显式处理错误**:

```python  theme={null}
def process_file(path):
    """Process a file, creating it if it doesn't exist."""
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        # Create file with default content instead of failing
        print(f"File {path} not found, creating default")
        with open(path, 'w') as f:
            f.write('')
        return ''
    except PermissionError:
        # Provide alternative instead of failing
        print(f"Cannot access {path}, using default")
        return ''
```

**坏例子:甩锅给 Agent**:

```python  theme={null}
def process_file(path):
    # Just fail and let the agent figure it out
    return open(path).read()
```

配置参数也应当有理有据并有文档,以避免"巫毒常量"(Ousterhout 定律)。如果你都不知道正确的值,Agent 又怎么可能确定它?

**好例子:自解释**:

```python  theme={null}
# HTTP requests typically complete within 30 seconds
# Longer timeout accounts for slow connections
REQUEST_TIMEOUT = 30

# Three retries balances reliability vs speed
# Most intermittent failures resolve by the second retry
MAX_RETRIES = 3
```

**坏例子:魔法数字**:

```python  theme={null}
TIMEOUT = 47  # Why 47?
RETRIES = 5   # Why 5?
```

### 提供工具脚本

即便你的 Agent 能自己写脚本,预制脚本也有好处:

**工具脚本的好处**:

* 比生成的代码更可靠
* 省 token(不用把代码塞进上下文)
* 省时间(不用生成代码)
* 保证多次使用间的一致性

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=4bbc45f2c2e0bee9f2f0d5da669bad00" alt="Bundling executable scripts alongside instruction files" data-og-width="2048" width="2048" data-og-height="1154" height="1154" data-path="images/agent-skills-executable-scripts.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=9a04e6535a8467bfeea492e517de389f 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=e49333ad90141af17c0d7651cca7216b 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=954265a5df52223d6572b6214168c428 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=2ff7a2d8f2a83ee8af132b29f10150fd 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=48ab96245e04077f4d15e9170e081cfb 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=0301a6c8b3ee879497cc5b5483177c90 2500w" />

上面的图展示了可执行脚本如何与指令文件协同工作。指令文件(forms.md)引用脚本,而 Agent 可以执行它,无需把它的内容加载进上下文。

**重要区分**:在你的指令里讲清楚 Agent 应该:

* **执行脚本**(最常见):"Run `analyze_form.py` to extract fields"
* **把它当参考来读**(针对复杂逻辑):"See `analyze_form.py` for the field extraction algorithm"

对大多数工具脚本,执行是首选,因为它更可靠、更高效。脚本执行如何工作的细节见下面的 [Runtime environment](#runtime-environment) 一节。

**示例**:

````markdown  theme={null}
## Utility scripts

**analyze_form.py**: Extract all form fields from PDF

```bash
python scripts/analyze_form.py input.pdf > fields.json
```

Output format:
```json
{
  "field_name": {"type": "text", "x": 100, "y": 200},
  "signature": {"type": "sig", "x": 150, "y": 500}
}
```

**validate_boxes.py**: Check for overlapping bounding boxes

```bash
python scripts/validate_boxes.py fields.json
# Returns: "OK" or lists conflicts
```

**fill_form.py**: Apply field values to PDF

```bash
python scripts/fill_form.py input.pdf fields.json output.pdf
```
````

### 使用视觉分析

当输入可以被渲染成图像时,让 Agent 去分析它们:

````markdown  theme={null}
## Form layout analysis

1. Convert PDF to images:
   ```bash
   python scripts/pdf_to_images.py form.pdf
   ```

2. Analyze each page image to identify form fields
3. The agent can see field locations and types visually
````

<Note>
  在这个示例里,你需要自己写 `pdf_to_images.py` 脚本。
</Note>

Agent 的视觉能力有助于理解布局和结构。

### 创建可验证的中间输出

当 Agent 执行复杂、开放式的任务时,它们会犯错。"计划-校验-执行"模式通过让 Agent 先以结构化格式创建一个计划、再用脚本校验它、然后才执行,来尽早捕获错误。

**示例**:设想让 Agent 根据一份电子表格更新 PDF 里的 50 个表单字段。没有校验的话,它可能引用不存在的字段、产生冲突的值、漏掉必填字段,或错误地应用更新。

**解决方案**:用上面展示的工作流模式(PDF 表单填充),但加一个中间的 `changes.json` 文件,在应用改动前先校验它。工作流变成:分析 → **创建计划文件** → **校验计划** → 执行 → 验证。

**为什么这个模式有效:**

* **尽早捕获错误**:校验在改动被应用前就发现问题
* **机器可验证**:脚本提供客观的验证
* **可回退的计划**:Agent 可以在计划上反复,而不动原件
* **清晰的调试**:错误信息指向具体问题

**何时使用**:批量操作、破坏性改动、复杂的校验规则、高风险操作。

**实现提示**:让校验脚本详尽,给出具体的错误信息,比如 "Field 'signature\_date' not found. Available fields: customer\_name, order\_total, signature\_date\_signed",帮 Agent 修复问题。

### 包依赖

技能在代码执行环境里运行,有平台特定的限制:

* **claude.ai**:能从 npm 和 PyPI 安装包,并能从 GitHub 仓库拉取
* **Anthropic API**:没有网络访问,也没有运行时包安装

在你的 SKILL.md 里列出所需的包,并在 [code execution tool documentation](https://platform.claude.com/docs/en/agents-and-tools/tool-use/code-execution-tool) 里核实它们是否可用。

### 运行时环境

技能在一个具备文件系统访问、bash 命令和代码执行能力的代码执行环境里运行。关于这一架构的概念解释,见概述里的 [The Skills architecture](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#the-skills-architecture)。

**这如何影响你的编写:**

**Agent 如何访问技能:**

1. **元数据预加载**:启动时,所有技能 YAML frontmatter 里的 name 和 description 被加载进系统提示
2. **文件按需读取**:Agent 用其读文件工具,在需要时从文件系统访问 SKILL.md 和其他文件
3. **脚本高效执行**:工具脚本可以通过 bash 执行,而无需把完整内容加载进上下文。只有脚本的输出消耗 token
4. **大文件无上下文代价**:参考文件、数据或文档在真正被读取之前不消耗上下文 token

* **文件路径很重要**:Agent 像浏览文件系统一样在你的技能目录里导航。用正斜杠(`reference/guide.md`),不用反斜杠
* **给文件起有描述性的名字**:用能表明内容的名字:`form_validation_rules.md`,而不是 `doc2.md`
* **为发现而组织**:按领域或功能来组织目录结构
  * 好:`reference/finance.md`、`reference/sales.md`
  * 坏:`docs/file1.md`、`docs/file2.md`
* **捆绑详尽的资源**:纳入完整的 API 文档、大量示例、大数据集;在被访问前没有上下文代价
* **确定性操作优先用脚本**:写 `validate_form.py`,而不是让 Agent 生成校验代码
* **讲清执行意图**:
  * "Run `analyze_form.py` to extract fields"(执行)
  * "See `analyze_form.py` for the extraction algorithm"(当参考来读)
* **测试文件访问模式**:用真实请求测试,核实 Agent 能在你的目录结构里导航

**示例:**

```
bigquery-skill/
├── SKILL.md (overview, points to reference files)
└── reference/
    ├── finance.md (revenue metrics)
    ├── sales.md (pipeline data)
    └── product.md (usage analytics)
```

当用户问收入时,Agent 读 SKILL.md,看到对 `reference/finance.md` 的引用,然后调用 bash 只读那一个文件。sales.md 和 product.md 依然留在文件系统上,在需要之前消耗零上下文 token。正是这个基于文件系统的模型让渐进式披露成为可能。Agent 能导航并选择性地精确加载每个任务所需的东西。

技术架构的完整细节见技能概述里的 [How Skills work](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#how-skills-work)。

### MCP 工具引用

如果你的技能用到 MCP(Model Context Protocol)工具,始终用完全限定的工具名,以避免 "tool not found" 错误。

**格式**:`ServerName:tool_name`

**示例**:

```markdown  theme={null}
Use the BigQuery:bigquery_schema tool to retrieve table schemas.
Use the GitHub:create_issue tool to create issues.
```

其中:

* `BigQuery` 和 `GitHub` 是 MCP 服务器名
* `bigquery_schema` 和 `create_issue` 是这些服务器内的工具名

没有服务器前缀,Agent 可能定位不到工具,尤其在有多个 MCP 服务器可用时。

### 不要假设工具已安装

不要假设包是可用的:

````markdown  theme={null}
**Bad example: Assumes installation**:
"Use the pdf library to process the file."

**Good example: Explicit about dependencies**:
"Install required package: `pip install pypdf`

Then use it:
```python
from pypdf import PdfReader
reader = PdfReader("file.pdf")
```"
````

## 技术说明

### YAML frontmatter 要求

SKILL.md 的 frontmatter 需要 `name`(最多 64 字符)和 `description`(最多 1024 字符)字段。完整的结构细节见 [Skills overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#skill-structure)。

### Token 预算

为获得最佳性能,把 SKILL.md 正文保持在 500 行以内。如果内容超出,用前面描述的渐进式披露模式把它拆成单独的文件。架构细节见 [Skills overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#how-skills-work)。

## 高效技能检查清单

在分享技能之前,核实:

### 核心质量

* [ ] description 具体,并包含关键词
* [ ] description 同时写清技能做什么和何时使用
* [ ] SKILL.md 正文在 500 行以内
* [ ] 额外细节放在单独文件里(如需要)
* [ ] 没有时效性信息(或放在"旧模式"一节)
* [ ] 通篇术语一致
* [ ] 示例具体,而非抽象
* [ ] 文件引用只有一层深
* [ ] 恰当地使用了渐进式披露
* [ ] 工作流步骤清晰

### 代码与脚本

* [ ] 脚本自己解决问题,而不是甩锅给 Agent
* [ ] 错误处理显式且有帮助
* [ ] 没有"巫毒常量"(所有值都有理有据)
* [ ] 所需的包已在指令里列出并核实可用
* [ ] 脚本有清晰的文档
* [ ] 没有 Windows 风格的路径(全用正斜杠)
* [ ] 关键操作有校验/验证步骤
* [ ] 质量关键的任务包含反馈回路

### 测试

* [ ] 至少创建了三个评估
* [ ] 用 Haiku、Sonnet 和 Opus 都测试过
* [ ] 用真实使用场景测试过
* [ ] 已吸收团队反馈(如适用)

## 下一步

<CardGroup cols={2}>
  <Card title="Get started with Agent Skills" icon="rocket" href="https://platform.claude.com/docs/en/agents-and-tools/agent-skills/quickstart">
    Create your first Skill
  </Card>

  <Card title="Use Skills in Claude Code" icon="terminal" href="https://code.claude.com/docs/en/skills">
    Create and manage Skills in Claude Code
  </Card>

  <Card title="Use Skills with the API" icon="code" href="https://platform.claude.com/docs/en/build-with-claude/skills-guide">
    Upload and use Skills programmatically
  </Card>
</CardGroup>
