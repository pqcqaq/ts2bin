# 04. 异步、迭代与资源管理

## `Promise<T>`

```ts
const promise = new Promise<number>((resolve, reject) => {
  try {
    resolve(42);
  } catch (error) {
    reject(error);
  }
});
```

实例方法：

| 方法 | 返回 |
| --- | --- |
| `then(onFulfilled?, onRejected?)` | 新 Promise，回调结果会递归同化 |
| `catch(onRejected?)` | `then(undefined, onRejected)` 的语义 |
| `finally(onFinally?)` | 保留原完成值/拒绝原因，除非 finally 自身失败 |

```ts
const result = fetchValue()
  .then((value) => value.trim())
  .catch((error: unknown) => {
    console.error(error);
    return "fallback";
  })
  .finally(() => console.log("done"));

declare function fetchValue(): Promise<string>;
```

Promise executor 同步执行，但 `then` 回调进入 microtask。`async` 函数总返回 Promise，并会自动等待 thenable。

## Promise 静态方法

| 方法 | 何时完成 | 结果/失败 |
| --- | --- | --- |
| `resolve(value)` | 同化 value/thenable | `Promise<Awaited<T>>` |
| `reject(reason)` | 立即拒绝 | 拒绝原因类型在标准 Promise 中为 `any` |
| `all(items)` | 全部完成 | 保留输入元组顺序；任一拒绝即拒绝 |
| `allSettled(items)` | 全部落定 | 每项为 fulfilled/rejected 判别联合 |
| `race(items)` | 第一项落定 | 第一项的完成或拒绝 |
| `any(items)` | 第一项完成 | 全部拒绝时以 `AggregateError` 拒绝 |
| `withResolvers<T>()` | 立即创建 | `{ promise, resolve, reject }` |
| `try(fn, ...args)` | 同步调用并包装 | 捕获同步抛错，也同化返回的 Promise（ES2025） |

```ts
const [user, settings] = await Promise.all([
  loadUser(),
  loadSettings(),
] as const);

const settled = await Promise.allSettled([loadUser(), loadSettings()]);
for (const item of settled) {
  if (item.status === "fulfilled") console.log(item.value);
  else console.error(item.reason);
}

declare function loadUser(): Promise<{ id: string }>;
declare function loadSettings(): Promise<{ theme: string }>;
```

`Promise.all` 不会取消已经启动的任务。需要取消时让各任务接受 `AbortSignal`，并在业务层协调。

### `withResolvers`

```ts
const { promise, resolve, reject } = Promise.withResolvers<string>();

queueMicrotask(() => resolve("ready"));
await promise;
```

它适合把 Promise 的完成权交给事件适配层，但也容易产生永不完成的 Promise；普通流程优先 `async` 函数。

### `Promise.try`

```ts
const result = await Promise.try(JSON.parse, '{"ok":true}');
```

回调被同步调用：返回值变为已完成 Promise，抛错变为拒绝，返回 Promise 则被同化。它不是延迟调度工具。

## Promise 辅助类型

| 类型 | 形状 |
| --- | --- |
| `PromiseLike<T>` | 只要求兼容的 `then` |
| `PromiseFulfilledResult<T>` | `{ status: "fulfilled"; value: T }` |
| `PromiseRejectedResult` | `{ status: "rejected"; reason: any }` |
| `PromiseSettledResult<T>` | 上述二者联合 |
| `PromiseWithResolvers<T>` | `{ promise; resolve; reject }` |
| `Awaited<T>` | 递归模拟 `await` 的类型结果 |

对外部拒绝原因仍应按 `unknown` 处理，标准声明的 `any` 不代表错误一定是 Error。

## 迭代协议

```ts
interface Iterable<T> {
  [Symbol.iterator](): Iterator<T>;
}

type IteratorResult<T, R> =
  | { done?: false; value: T }
  | { done: true; value: R };
```

相关类型：

- `Iterator<T, TReturn, TNext>`：有 `next(value?)` 的拉取对象。
- `Iterable<T, TReturn, TNext>`：能创建 Iterator。
- `IterableIterator<T>`：两者合一，`[Symbol.iterator]()` 返回自身。
- `IteratorObject<T, TReturn, TNext>`：继承内置 Iterator 原型、拥有 helpers 的原生迭代器。
- `ArrayIterator`、`MapIterator`、`SetIterator`、`StringIterator`：对应内置对象迭代器。
- `BuiltinIteratorReturn`：在 `strictBuiltinIteratorReturn` 下让内置迭代结束值更安全。

```ts
const iterable: Iterable<number> = {
  *[Symbol.iterator]() {
    yield 1;
    yield 2;
  },
};

const iterator = iterable[Symbol.iterator]();
const first = iterator.next();
if (!first.done) console.log(first.value);
```

## Iterator Helpers（ES2025）

```ts
const values = Iterator.from([1, 2, 3, 4])
  .filter((value) => value % 2 === 0)
  .map((value) => value * 10)
  .take(2)
  .toArray();
```

完整方法：

| 类型 | 方法 | 行为 |
| --- | --- | --- |
| 惰性 | `map`、`filter`、`flatMap`、`take`、`drop` | 返回新的 IteratorObject，消费时才计算 |
| 终结 | `reduce`、`toArray`、`forEach`、`some`、`every`、`find` | 立即消费迭代器 |
| 构造 | `Iterator.from` | 把 iterable/iterator 包装成原生 IteratorObject |

迭代器通常是一次性的。调用终结方法或短路方法后，原迭代器已被部分/全部消费；需要重复遍历时保留 iterable 工厂或先 `toArray()`。

## 生成器

```ts
function* counter(): Generator<number, string, boolean> {
  const continueAfterOne = yield 1;
  if (continueAfterOne) yield 2;
  return "done";
}

const generator = counter();
generator.next();
generator.next(true);
generator.return("stopped");
```

`Generator<T, TReturn, TNext>` / `GeneratorFunction` 提供：`next`、`return`、`throw`、`[Symbol.iterator]`。`yield*` 委托给另一个 iterable。

## 异步迭代

```ts
async function* pages(): AsyncGenerator<string, void, unknown> {
  yield await Promise.resolve("page-1");
  yield "page-2";
}

for await (const page of pages()) {
  console.log(page);
}
```

类型族：`AsyncIterable<T>`、`AsyncIterator<T, TReturn, TNext>`、`AsyncIterableIterator<T>`、`AsyncIteratorObject<T, TReturn, TNext>`、`AsyncGenerator<T, TReturn, TNext>`、`AsyncGeneratorFunction`。

`for await...of` 也能消费同步 iterable，并等待其中的值；若只需要同步值，普通 `for...of` 更直接。

## 释放协议

```ts
interface Disposable {
  [Symbol.dispose](): void;
}

interface AsyncDisposable {
  [Symbol.asyncDispose](): PromiseLike<void>;
}
```

`using` 与 `await using` 在离开词法作用域时按逆序释放，异常路径同样执行。

```ts
function work() {
  using resource = openResource();
  resource.run();
}

declare function openResource(): Disposable & { run(): void };
```

主体错误与释放错误同时发生时，`SuppressedError` 用 `error` 和 `suppressed` 保留两者。

## `DisposableStack`

```ts
function openAll() {
  using stack = new DisposableStack();

  const connection = stack.use(openConnection());
  stack.defer(() => console.log("custom cleanup"));
  stack.adopt("temp-id", (id) => console.log("release", id));

  return stack.move(); // 转移责任，原 stack 变为 disposed
}

declare function openConnection(): Disposable;
```

完整 API：

| 成员 | 作用 |
| --- | --- |
| `disposed` | 是否已经释放/移动 |
| `use(value)` | 登记 Disposable，原样返回 |
| `adopt(value, onDispose)` | 登记任意值及其清理回调 |
| `defer(onDispose)` | 登记无参数清理回调 |
| `move()` | 把责任转到新 stack |
| `dispose()` / `[Symbol.dispose]()` | 立即按 LIFO 清理 |

## `AsyncDisposableStack`

异步版本 API 对应为：`disposed`、`use`（可登记同步或异步资源）、`adopt`、`defer`、`move`、`disposeAsync`、`[Symbol.asyncDispose]`。清理回调可返回 PromiseLike。

```ts
await using stack = new AsyncDisposableStack();
stack.defer(async () => flushLogs());

declare function flushLogs(): Promise<void>;
```

## 组合用法：流式读取并确定释放

```ts
interface LineReader extends AsyncIterable<string>, AsyncDisposable {}

async function firstMatching(reader: LineReader, pattern: RegExp) {
  await using managed = reader;
  for await (const line of managed) {
    if (pattern.test(line)) return line;
  }
  return undefined;
}
```

提前 `return` 仍会等待异步释放；类型同时表达消费协议和生命周期协议。

## 常见坑

- Promise 不等于任务取消；取消需额外协议。
- `forEach(async () => ...)` 不等待回调 Promise，改用 `for...of` 或 `Promise.all(map(...))`。
- Iterator Helpers 是惰性且通常一次性，不能像数组那样随意重复使用。
- FinalizationRegistry 不可替代 Disposable。
- `await using` 的清理也可能失败，调用边界仍需错误策略。
