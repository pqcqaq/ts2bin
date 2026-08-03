# 05. 对象类型

## 属性与方法

```ts
interface User {
  readonly id: number;
  name: string;
  nickname?: string;
  rename(name: string): void;
}
```

- `readonly` 禁止通过该类型修改属性，不保证运行时不可变。
- `?` 表示属性可以缺席。
- `method(): R` 是方法语法；`method: () => R` 是函数属性语法，在参数变型检查上有细微差异。

启用 `exactOptionalPropertyTypes` 后：

```ts
interface Options {
  color?: "dark" | "light";
}

const a: Options = {}; // 可以缺席
// const b: Options = { color: undefined }; // 不可以，除非类型包含 undefined
```

## 索引签名

```ts
interface Scores {
  [name: string]: number;
}

const scores: Scores = { Ada: 100, Lin: 98 };
```

索引签名规定未知属性的值类型。显式属性也必须兼容它：

```ts
interface Dictionary {
  readonly [key: string]: string | undefined;
  language: string;
}
```

启用 `noUncheckedIndexedAccess` 后，`scores[name]` 是 `number | undefined`，更符合键可能不存在的运行时事实。

属性键类型是 `string | number | symbol`，可用别名 `PropertyKey`。数字键在普通对象中会转成字符串，但数组和元组对数字索引有专门类型规则。

## 结构类型与多余属性检查

TypeScript 主要按结构判断兼容性：

```ts
type Point = { x: number; y: number };
const point3d = { x: 1, y: 2, z: 3 };
const point: Point = point3d; // 有所需属性即可
```

对象字面量直接赋给目标类型时会额外检查拼写错误：

```ts
// const bad: Point = { x: 1, y: 2, z: 3 }; // 多余属性 z
```

不要用断言绕过有意义的检查。需要保留额外属性或精确推断时使用 `satisfies`：

```ts
const palette = {
  primary: "#00f",
  danger: "#f00",
} satisfies Record<string, `#${string}`>;
```

## 扩展与交叉

```ts
interface Entity { id: number }
interface Timestamped { createdAt: Date }
interface User extends Entity, Timestamped { name: string }

type Admin = User & { permissions: string[] };
```

- `extends` 会在声明处检查属性覆盖是否兼容，错误通常更清楚。
- `&` 可组合任意类型，但冲突属性可能得到 `never`。
- 接口只能扩展静态已知的对象类型，不能直接扩展联合类型。

## 泛型对象

```ts
interface Box<T> {
  value: T;
  map<U>(fn: (value: T) => U): Box<U>;
}

type ApiResponse<T, Meta = undefined> = {
  data: T;
  meta: Meta;
};
```

默认类型参数适合高频情况，调用方仍可覆盖。

## 元组的对象模型

```ts
type Pair<T> = readonly [first: T, second: T];
type AtLeastOne<T> = [first: T, ...rest: T[]];
type MaybeNamed = [id: number, name?: string];
```

元组支持：

- 具名元素：`[x: number, y: number]`。
- 可选元素：`[value: string, radix?: number]`。
- 剩余元素位于开头、中间或结尾：`[head: string, ...middle: number[], tail: boolean]`。
- `readonly` 元组：能接收 `as const` 产生的值。

泛型函数若只读数组，参数应写 `readonly T[]`，这样可同时接受可变数组和只读数组。

## `as const` 与 `satisfies`

```ts
const routes = {
  home: "/",
  user: "/users/:id",
} as const satisfies Record<string, `/${string}`>;

type RouteName = keyof typeof routes;
type RoutePath = (typeof routes)[RouteName];
```

- `as const` 缩窄值并添加浅层只读。
- `satisfies` 检查表达式兼容目标类型，但不把变量整体改成目标类型。
- 两者组合适合“键和值都要保留为字面量，同时检查统一契约”的配置表。

## 递归对象与只读

```ts
type Json =
  | null
  | boolean
  | number
  | string
  | Json[]
  | { [key: string]: Json };

type DeepReadonly<T> =
  T extends (...args: any[]) => any ? T :
  T extends readonly unknown[] ? { readonly [K in keyof T]: DeepReadonly<T[K]> } :
  T extends object ? { readonly [K in keyof T]: DeepReadonly<T[K]> } :
  T;
```

递归类型要考虑函数、数组和元组，实际项目还可能需要排除 `Date`、`Map` 等特殊对象。

## 组合用法：配置表驱动 API

```ts
const endpoints = {
  getUser: { method: "GET", path: "/users/:id" },
  createUser: { method: "POST", path: "/users" },
} as const satisfies Record<
  string,
  { method: "GET" | "POST"; path: `/${string}` }
>;

type EndpointName = keyof typeof endpoints;
type Endpoint<N extends EndpointName> = (typeof endpoints)[N];
```

这个模式让配置成为唯一事实源：运行时代码读取对象，类型代码用 `typeof` 和索引访问派生精确类型。

## 常见坑

- 对象字面量的多余属性检查不是“精确对象类型”；变量之间仍按结构兼容。
- `readonly` 和 `Readonly<T>` 默认只处理一层。
- 宽泛的 `[key: string]: any` 会吞掉属性拼写错误，优先具体键联合、映射类型或 `unknown`。
- 对交叉类型中的同名属性要格外小心，冲突可能直到使用处才表现为 `never`。
