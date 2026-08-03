# 10. 运行时类型与协议

本章内容与纯类型语法不同：`enum`、迭代器、mixin 和显式资源管理都会影响运行时行为。完整内置对象与方法见 [ECMAScript 标准库](./stdlib/README.md)。

## `enum`

### 数字枚举

```ts
enum Status {
  Pending,      // 0
  Running,      // 1
  Done = 10,
  Failed,       // 11
}
```

数字枚举会生成正向和反向映射：`Status.Done === 10`，`Status[10] === "Done"`。

### 字符串枚举

```ts
enum Direction {
  Up = "UP",
  Down = "DOWN",
}
```

字符串枚举没有反向映射，但日志值更清楚。异构枚举可以混用数字和字符串，通常应避免。

### 常量与计算成员

```ts
enum Permission {
  Read = 1 << 0,
  Write = 1 << 1,
  ReadWrite = Read | Write,
  Random = Math.random(),
}
```

计算成员后的无初始化成员不能依赖自动递增。所有成员为字面量枚举成员时，枚举本身也表现为成员类型的联合。

枚举键：

```ts
type DirectionName = keyof typeof Direction; // "Up" | "Down"
```

### `const enum` 与环境枚举

```ts
const enum TokenKind {
  Word,
  Number,
}

declare enum HostStatus {
  Ready,
  Busy,
}
```

- `const enum` 的成员通常内联，不保留运行时对象。
- 跨包发布 `const enum` 可能造成编译版本与运行版本不一致，并与某些隔离编译流程冲突；公共库通常避免导出它。
- `declare enum` 只描述外部已有值，不生成实现。

### 对象常量替代

```ts
const DirectionValue = {
  Up: "UP",
  Down: "DOWN",
} as const;

type DirectionValue = (typeof DirectionValue)[keyof typeof DirectionValue];
```

对象常量是普通 JavaScript，适合 ESM、tree-shaking 和 `erasableSyntaxOnly`。是否使用枚举应由运行时 API 需求决定。

## `symbol` 与 `unique symbol`

```ts
const id = Symbol("id");
const object = { [id]: 1 };

declare const brand: unique symbol;
type UserId = string & { readonly [brand]: "UserId" };
```

- 每次 `Symbol()` 都创建不同值。
- `Symbol.for(key)` 使用全局符号注册表，`Symbol.keyFor` 可取回键。
- `unique symbol` 表示某一个确定符号的唯一类型，只能用于 `const` 或 `readonly static` 属性。

常用 well-known symbols：

| 符号 | 控制的协议 |
| --- | --- |
| `Symbol.iterator` / `asyncIterator` | 同步/异步迭代 |
| `Symbol.dispose` / `asyncDispose` | 同步/异步资源释放 |
| `Symbol.hasInstance` | `instanceof` |
| `Symbol.toPrimitive` | 对象转原始值 |
| `Symbol.toStringTag` | `Object.prototype.toString` 标签 |
| `Symbol.match` / `matchAll` / `replace` / `search` / `split` | 字符串与模式对象的协议 |
| `Symbol.species` | 派生对象的构造器选择 |
| `Symbol.isConcatSpreadable` | `Array#concat` 是否展开对象 |
| `Symbol.unscopables` | `with` 语句排除属性，现代代码不直接使用 |
| `Symbol.metadata` | 标准装饰器元数据容器（ESNext） |

## 可迭代与迭代器

协议的核心形状：

```ts
interface Iterable<T> {
  [Symbol.iterator](): Iterator<T>;
}

interface Iterator<T, TReturn = any, TNext = any> {
  next(...args: [] | [TNext]): IteratorResult<T, TReturn>;
}
```

实现最小可迭代对象：

```ts
const countdown: Iterable<number> = {
  *[Symbol.iterator]() {
    yield 3;
    yield 2;
    yield 1;
  },
};

for (const value of countdown) console.log(value);
const values = [...countdown];
```

- `for...of`、展开、数组解构、`Array.from` 使用迭代协议。
- `for...in` 遍历对象键，不使用迭代协议。
- 迭代器的 `next()` 返回 `{ done, value }` 联合。

异步可迭代对象使用 `[Symbol.asyncIterator]()`，由 `for await...of` 消费。

## 生成器

```ts
function* ids(): Generator<number, string, boolean> {
  const accepted = yield 1;
  if (accepted) yield 2;
  return "done";
}

const iterator = ids();
iterator.next();      // yield 1
iterator.next(true);  // 把 true 传回生成器
```

- `yield* iterable` 委托给另一个可迭代对象。
- `return()` 提前结束，`throw()` 向生成器内部抛错。
- `AsyncGenerator<Y, R, N>` 的 `next()` 返回 Promise。

ES2025 Iterator Helpers 为 `Iterator` 增加惰性的 `map`、`filter`、`take` 等；详见 [标准库异步与迭代](./stdlib/04-async-iteration-resources.md)。

## mixin

mixin 用“接收基类，返回派生类”的类表达式组合能力：

```ts
type Constructor<T = object> = new (...args: any[]) => T;

function Timestamped<TBase extends Constructor>(Base: TBase) {
  return class extends Base {
    readonly createdAt = new Date();
  };
}

class Model { constructor(public id: string) {} }
class TimedModel extends Timestamped(Model) {}
```

若要接受抽象基类，构造签名使用 `abstract new`，返回类也通常需要保持抽象。私有字段应使用 ES `#private`；TypeScript `private` 在 mixin 的声明组合中容易受限制。

## 显式资源管理

资源实现释放协议：

```ts
class Connection implements Disposable {
  [Symbol.dispose](): void {
    console.log("closed");
  }
}

function run() {
  using connection = new Connection();
  // 离开当前作用域时自动调用 connection[Symbol.dispose]()
}
```

异步资源：

```ts
class AsyncConnection implements AsyncDisposable {
  async [Symbol.asyncDispose](): Promise<void> {}
}

async function runAsync() {
  await using connection = new AsyncConnection();
}
```

- 资源按声明的逆序释放。
- 即使抛错或提前返回也会释放。
- `using` 接受 `Disposable | null | undefined`；`await using` 也支持 `AsyncDisposable`。
- 主体和释放同时抛错时，可产生 `SuppressedError`，保留两个错误。
- `DisposableStack` / `AsyncDisposableStack` 可动态登记多个资源、回调或外部对象。

## 组合用法：迭代 + 自动释放

```ts
class Lines implements Iterable<string>, Disposable {
  #closed = false;

  constructor(private readonly values: readonly string[]) {}

  *[Symbol.iterator](): Iterator<string> {
    if (this.#closed) throw new Error("Already closed");
    yield* this.values;
  }

  [Symbol.dispose](): void {
    this.#closed = true;
  }
}

function readAll() {
  using lines = new Lines(["a", "b"]);
  return [...lines];
}
```

## 常见坑

- TypeScript 声明存在不代表目标运行时已经实现某个 ESNext API；要核对运行环境或提供 polyfill。
- `const enum` 跨包发布风险高；对象常量通常更稳妥。
- 返回 `Iterable<T>` 表示可重复获取迭代器，但具体实现不一定能重复遍历，API 文档要说明。
- `using` 只管理离开词法作用域的释放，不替代业务层的事务提交/回滚语义。
