# 测试反模式

**何时加载这份参考:** 在写测试或改测试、添加 mock,或者你动了念头想给生产代码加只在测试里用的方法时。

## 概述

测试必须验证真实行为,而不是 mock 的行为。mock 是用来做隔离的手段,不是被测的对象。

**核心原则:** 测代码做了什么,而不是 mock 做了什么。

**严格遵循 TDD 就能避免这些反模式。**

## 铁律

```
1. 绝不测 mock 的行为
2. 绝不给生产类加只在测试里用的方法
3. 绝不在不理解依赖关系时就 mock
```

## 反模式 1:测 mock 的行为

**这样违规:**
```typescript
// ❌ BAD: Testing that the mock exists
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
});
```

**为什么这是错的:**
- 你验证的是 mock 能用,而不是组件能用
- mock 在场时测试通过,不在场时失败
- 关于真实行为它什么都没告诉你

**你的人类搭档会纠正你:** "我们是不是在测一个 mock 的行为?"

**修正:**
```typescript
// ✅ GOOD: Test real component or don't mock it
test('renders sidebar', () => {
  render(<Page />);  // Don't mock sidebar
  expect(screen.getByRole('navigation')).toBeInTheDocument();
});

// OR if sidebar must be mocked for isolation:
// Don't assert on the mock - test Page's behavior with sidebar present
```

### 关卡判断

```
BEFORE asserting on any mock element:
  Ask: "Am I testing real component behavior or just mock existence?"

  IF testing mock existence:
    STOP - Delete the assertion or unmock the component

  Test real behavior instead
```

## 反模式 2:生产代码里只给测试用的方法

**这样违规:**
```typescript
// ❌ BAD: destroy() only used in tests
class Session {
  async destroy() {  // Looks like production API!
    await this._workspaceManager?.destroyWorkspace(this.id);
    // ... cleanup
  }
}

// In tests
afterEach(() => session.destroy());
```

**为什么这是错的:**
- 生产类被只在测试里用的代码污染了
- 万一在生产环境里被误调用会很危险
- 违反 YAGNI 和关注点分离
- 把对象的生命周期和实体的生命周期混为一谈

**修正:**
```typescript
// ✅ GOOD: Test utilities handle test cleanup
// Session has no destroy() - it's stateless in production

// In test-utils/
export async function cleanupSession(session: Session) {
  const workspace = session.getWorkspaceInfo();
  if (workspace) {
    await workspaceManager.destroyWorkspace(workspace.id);
  }
}

// In tests
afterEach(() => cleanupSession(session));
```

### 关卡判断

```
BEFORE adding any method to production class:
  Ask: "Is this only used by tests?"

  IF yes:
    STOP - Don't add it
    Put it in test utilities instead

  Ask: "Does this class own this resource's lifecycle?"

  IF no:
    STOP - Wrong class for this method
```

## 反模式 3:不理解就 mock

**这样违规:**
```typescript
// ❌ BAD: Mock breaks test logic
test('detects duplicate server', () => {
  // Mock prevents config write that test depends on!
  vi.mock('ToolCatalog', () => ({
    discoverAndCacheTools: vi.fn().mockResolvedValue(undefined)
  }));

  await addServer(config);
  await addServer(config);  // Should throw - but won't!
});
```

**为什么这是错的:**
- 被 mock 掉的方法有一个测试所依赖的副作用(写配置)
- 为了"保险"而过度 mock 破坏了真实行为
- 测试因错误的原因通过,或者莫名其妙地失败

**修正:**
```typescript
// ✅ GOOD: Mock at correct level
test('detects duplicate server', () => {
  // Mock the slow part, preserve behavior test needs
  vi.mock('MCPServerManager'); // Just mock slow server startup

  await addServer(config);  // Config written
  await addServer(config);  // Duplicate detected ✓
});
```

### 关卡判断

```
BEFORE mocking any method:
  STOP - Don't mock yet

  1. Ask: "What side effects does the real method have?"
  2. Ask: "Does this test depend on any of those side effects?"
  3. Ask: "Do I fully understand what this test needs?"

  IF depends on side effects:
    Mock at lower level (the actual slow/external operation)
    OR use test doubles that preserve necessary behavior
    NOT the high-level method the test depends on

  IF unsure what test depends on:
    Run test with real implementation FIRST
    Observe what actually needs to happen
    THEN add minimal mocking at the right level

  Red flags:
    - "I'll mock this to be safe"
    - "This might be slow, better mock it"
    - Mocking without understanding the dependency chain
```

## 反模式 4:不完整的 mock

**这样违规:**
```typescript
// ❌ BAD: Partial mock - only fields you think you need
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' }
  // Missing: metadata that downstream code uses
};

// Later: breaks when code accesses response.metadata.requestId
```

**为什么这是错的:**
- **不完整的 mock 会掩盖结构性假设** —— 你只 mock 了你知道的字段
- **下游代码可能依赖你没包含的字段** —— 悄无声息地失败
- **测试通过但集成时失败** —— mock 不完整,真实 API 完整
- **虚假的信心** —— 测试关于真实行为什么都证明不了

**铁律:** mock 要按现实中的完整数据结构来 mock,而不是只 mock 你眼下这个测试用到的字段。

**修正:**
```typescript
// ✅ GOOD: Mirror real API completeness
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
  metadata: { requestId: 'req-789', timestamp: 1234567890 }
  // All fields real API returns
};
```

### 关卡判断

```
BEFORE creating mock responses:
  Check: "What fields does the real API response contain?"

  Actions:
    1. Examine actual API response from docs/examples
    2. Include ALL fields system might consume downstream
    3. Verify mock matches real response schema completely

  Critical:
    If you're creating a mock, you must understand the ENTIRE structure
    Partial mocks fail silently when code depends on omitted fields

  If uncertain: Include all documented fields
```

## 反模式 5:把集成测试当作事后补的东西

**这样违规:**
```
✅ Implementation complete
❌ No tests written
"Ready for testing"
```

**为什么这是错的:**
- 测试是实现的一部分,不是可选的后续步骤
- TDD 本来就能抓住这个问题
- 没有测试就不能宣称完成

**修正:**
```
TDD cycle:
1. Write failing test
2. Implement to pass
3. Refactor
4. THEN claim complete
```

## 当 mock 变得太复杂

**警告信号:**
- mock 的准备代码比测试逻辑还长
- 为了让测试通过什么都 mock
- mock 缺少真实组件才有的方法
- mock 一改测试就坏

**你的人类搭档会问:** "这里我们真的需要用 mock 吗?"

**考虑:** 用真实组件写的集成测试往往比复杂的 mock 更简单

## TDD 能避免这些反模式

**为什么 TDD 有帮助:**
1. **先写测试** → 逼你思考你到底在测什么
2. **看着它失败** → 确认测试测的是真实行为,而不是 mock
3. **最小化实现** → 不会有只给测试用的方法悄悄溜进来
4. **真实依赖** → 你在 mock 之前就看清了测试真正需要什么

**如果你在测 mock 的行为,你就违反了 TDD** —— 你在没有先让测试对着真实代码失败的情况下就加了 mock。

## 速查

| 反模式 | 修正 |
|--------------|-----|
| 对 mock 元素做断言 | 测真实组件,或者别 mock 它 |
| 生产代码里只给测试用的方法 | 挪到测试工具里 |
| 不理解就 mock | 先理解依赖,再做最小化 mock |
| 不完整的 mock | 完整还原真实 API |
| 把测试当事后补 | TDD——先写测试 |
| 过于复杂的 mock | 考虑用集成测试 |

## 危险信号

- 断言里在检查 `*-mock` 之类的 test ID
- 只在测试文件里被调用的方法
- mock 的准备代码占了测试的一半以上
- 一移除 mock 测试就失败
- 说不清为什么需要这个 mock
- "保险起见"就 mock

## 归根结底

**mock 是用来做隔离的工具,不是用来测的东西。**

如果 TDD 揭示出你在测 mock 的行为,那你就走岔了。

修正:测真实行为,或者反问自己到底为什么要 mock。
