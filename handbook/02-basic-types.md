# 02. 基础类型

## 原始类型

```ts
const text: string = "hello";
const count: number = 42;
const huge: bigint = 42n;
const enabled: boolean = true;
const key: symbol = Symbol("key");
const empty: null = null;
const missing: undefined = undefined;
```

类型名使用小写 `string`、`number`、`boolean`、`symbol`、`bigint`。大写 `String`、`Number` 等是包装对象类型，通常不应使用。

## 字面量类型

字面量本身也可以成为类型：

```ts
type Method = "GET" | "POST";
type Dice = 1 | 2 | 3 | 4 | 5 | 6;

let method: Method = "GET";
```

`const` 和 `as const` 能保留更窄的字面量：

```ts
const method1 = "GET";                    // "GET"
let method2 = "GET";                      // string
const request = { method: "GET" } as const; // readonly method: "GET"
```

## 数组与元组

```ts
const ids: number[] = [1, 2];
const names: Array<string> = ["Ada", "Lin"];

type Point = [x: number, y: number];
const point: Point = [3, 4];

type Command = [name: string, verbose?: boolean, ...args: string[]];
const command: Command = ["build", true, "src"];
```

- `T[]` 与 `Array<T>` 等价。
- 元组记录长度和各位置类型；具名元素只改善可读性，不改变兼容性。
- `readonly T[]` / `ReadonlyArray<T>` 禁止通过该引用修改数组。
- `readonly [A, B]` 是只读元组，常由 `as const` 产生。

严格启用 `noUncheckedIndexedAccess` 后，普通数组的 `items[0]` 是 `T | undefined`；已知位置的元组访问仍是精确类型。

## 对象、`object` 与 `{}`

```ts
let record: { id: number; name?: string } = { id: 1 };
let nonPrimitive: object = { ok: true };
```

- `object`：任何非原始值，包括数组、函数、对象。
- `{}`：任何非 `null`/`undefined` 的值，连数字和字符串也可赋值；不要把它当“普通对象”。
- `Record<PropertyKey, unknown>`：具有任意属性键的记录形状，但函数等不一定兼容。
- `unknown`：真正表示“尚不知道是什么”的安全类型。

## `type` 与 `interface`

```ts
interface User {
  readonly id: number;
  name: string;
}

type UserId = User["id"];
type WithTimestamp = User & { createdAt: Date };
```

共同点：都能描述对象、扩展/组合，也都采用结构类型检查。

差异：

- `interface` 可声明合并，适合可扩展的公共对象契约。
- `type` 可表示联合、元组、条件类型、映射类型和任意类型别名。
- 团队可保持一种默认风格，但应按表达能力选择，不必机械统一。

## 特殊类型

### `unknown`

任何值都能赋给 `unknown`，但必须收窄后才能操作：

```ts
function format(value: unknown): string {
  return typeof value === "string" ? value.trim() : String(value);
}
```

### `any`

`any` 关闭类型检查并会传播：

```ts
declare const legacy: any;
legacy.not.existing().stillAccepted;
```

它适合逐步迁移边界，不适合作为“不知道”的默认答案。

### `void`

函数返回值被忽略：

```ts
function log(message: string): void {
  console.log(message);
}
```

上下文返回类型为 `void` 的回调可以实际返回值，只是调用者不能使用该值。例如 `array.forEach(item => output.push(item))` 合法。

### `never`

表示不可能出现的值：

```ts
function fail(message: string): never {
  throw new Error(message);
}
```

常用于穷尽检查、永不返回的函数和过滤联合类型。

## 枚举与对象常量

```ts
enum Direction {
  Up = "UP",
  Down = "DOWN",
}

const DirectionObject = {
  Up: "UP",
  Down: "DOWN",
} as const;
type DirectionValue = (typeof DirectionObject)[keyof typeof DirectionObject];
```

`enum` 会生成运行时代码；对象常量更贴近 JavaScript、易于 tree-shaking。需要反向映射、声明合并或已有 API 约定时可用 `enum`。详见 [10-运行时协议](./10-runtime-protocols.md)。

## 组合用法：精确的路由表

```ts
type Handler = (input: unknown) => Promise<unknown>;

const routes = {
  "GET /users": async () => [],
  "POST /users": async (input: unknown) => input,
} satisfies Record<string, Handler>;

type Route = keyof typeof routes;
```

`satisfies` 检查所有值都是 `Handler`，同时保留具体键，因此 `Route` 会得到字面量联合而不是宽泛的 `string`。

## 常见坑

- 可选属性 `name?: string` 与 `name: string | undefined` 不完全相同：前者可以缺席；启用 `exactOptionalPropertyTypes` 后不能显式写 `name: undefined`，除非类型明确包含它。
- `readonly` 只在类型检查阶段阻止写入，并且默认是浅层的。
- `number` 同时表示整数和浮点数；精度、范围、`NaN` 仍遵守 JavaScript 规则。
- 元组可以赋给合适的数组类型，但普通数组不能反过来保证固定长度。
