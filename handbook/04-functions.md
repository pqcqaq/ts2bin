# 04. 函数

## 声明与函数类型

```ts
function add(a: number, b: number): number {
  return a + b;
}

const subtract = (a: number, b: number): number => a - b;
const multiply: (a: number, b: number) => number = (a, b) => a * b;
```

函数类型只写参数和返回值，不写函数体。参数名必须存在，但只用于文档，可与实现中的名字不同。

调用签名可附带属性：

```ts
type Counter = {
  (step?: number): number;
  reset(): void;
  readonly value: number;
};
```

构造签名使用 `new`：

```ts
interface Constructor<T> {
  new (...args: any[]): T;
}

function create<T>(Ctor: Constructor<T>): T {
  return new Ctor();
}
```

同时可调用又可构造的值可以同时声明两种签名，这常见于旧式 JavaScript 库的 `.d.ts`。

## 可选、默认、剩余参数

```ts
function greet(name: string, title?: string): string {
  return title ? `${title} ${name}` : name;
}

function retry(task: () => void, times = 3): void {
  for (let i = 0; i < times; i++) task();
}

function sum(...values: number[]): number {
  return values.reduce((total, value) => total + value, 0);
}
```

- 可选参数必须位于必选参数之后，除非使用元组剩余参数表达更复杂的调用形式。
- 默认参数在调用方表现为可选参数。
- `...args: T[]` 收集同类型参数；`...args: [A, B?]` 可精确表达参数位置。

```ts
function request(...args:
  | [url: string]
  | [url: string, init: { method: "GET" | "POST" }]
) {
  const [url, init] = args;
  return { url, method: init?.method ?? "GET" };
}
```

## 参数解构

```ts
type Options = { timeout?: number; signal?: AbortSignal };

function load(url: string, { timeout = 1000, signal }: Options = {}) {
  return { url, timeout, signal };
}
```

默认 `{}` 让整个配置参数也可省略；这与属性自身可选是两件事。

## 泛型函数

```ts
function first<T>(items: readonly T[]): T | undefined {
  return items[0];
}

const value = first([1, 2, 3]); // number | undefined
```

类型参数建立输入与输出的关系。若一个类型参数只出现一次，通常不需要泛型。

```ts
function get<T, K extends keyof T>(object: T, key: K): T[K] {
  return object[key];
}
```

详见 [06-泛型](./06-generics.md)。

## 函数重载

```ts
function parse(value: string): Date;
function parse(value: number): Date;
function parse(value: string | number): Date {
  return new Date(value);
}
```

- 前几行是调用签名，最后一行是实现签名。
- 实现签名对调用方不可见，并且必须兼容所有重载。
- 仅返回类型不同不能区分重载。
- 能用联合参数清楚表达时，优先联合；调用方的联合值也更容易传入。

## `this` 参数

伪参数 `this` 只参与类型检查，不会出现在生成的 JavaScript 中：

```ts
interface User { name: string }

function say(this: User, prefix: string) {
  return `${prefix} ${this.name}`;
}

say.call({ name: "Ada" }, "Hello");
```

箭头函数捕获外层 `this`，普通函数的 `this` 由调用方式决定。回调不应使用 `this` 时可写 `this: void`。

## 返回类型

```ts
function log(message: string): void {
  console.log(message);
}

function fail(message: string): never {
  throw new Error(message);
}

async function fetchName(): Promise<string> {
  return "Ada";
}
```

- `void` 表示调用者不使用返回值，不等同于函数必须在运行时返回 `undefined`。
- `never` 表示正常路径永远无法返回。
- `async` 函数总返回 `Promise<T>`；`return value` 会包装成已完成的 Promise。

## 生成器与异步生成器

```ts
function* range(end: number): Generator<number, void, unknown> {
  for (let i = 0; i < end; i++) yield i;
}

async function* pages(): AsyncGenerator<string, void, unknown> {
  yield "page-1";
  yield "page-2";
}
```

`Generator<Yield, Return, Next>` 的三个参数分别表示 `yield` 出去、最终 `return`、`next(value)` 传入的类型。

## 回调兼容性

```ts
const names = ["Ada", "Lin"];
names.forEach((name) => console.log(name));
```

回调可以忽略参数，因此不必为了匹配 `forEach((value, index, array) => ...)` 写出全部参数。不要把可选参数用于“框架可能少传参数”之外的场景，否则回调实现必须处理 `undefined`。

启用 `strictFunctionTypes` 后，普通函数属性的参数按更安全的逆变方向检查；方法语法因兼容性保留更宽松的行为。设计公共 API 时要避免依赖这种差异。

## 组合用法：保留参数列表的包装器

```ts
function timed<Args extends unknown[], Result>(
  fn: (...args: Args) => Result,
  report: (milliseconds: number) => void,
): (...args: Args) => Result {
  return (...args) => {
    const start = performance.now();
    try {
      return fn(...args);
    } finally {
      report(performance.now() - start);
    }
  };
}

const join = timed((a: string, b: string) => `${a}:${b}`, console.log);
join("x", "y"); // 参数仍精确为 [string, string]
```

这里用元组泛型保留原函数的完整参数列表，用第二个泛型保留返回类型。

## 常见坑

- 不要为每种联合成员机械添加重载；联合参数通常更可组合。
- `Function` 类型几乎不提供参数和返回值安全性，优先写明确签名。
- `() => void` 的实现可以返回值；若必须禁止返回，可在 API 设计中使用其他约束并测试实际意图。
- `async` 回调传给期望 `void` 的 API 时，其 Promise 可能无人处理；事件处理器中要显式捕获错误。
