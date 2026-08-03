# 17. TypeScript 语法速查

## 声明形式

| 语法 | 例子 | 运行时是否存在 |
| --- | --- | --- |
| 变量 | `const count: number = 1` | `const` 存在，标注擦除 |
| 类型别名 | `type Id = string \| number` | 否 |
| 接口 | `interface User { id: string }` | 否，可声明合并 |
| 枚举 | `enum Status { Ready }` | 是（除 `const enum` 内联） |
| 类 | `class User {}` | 是：构造函数 + 类型 |
| 函数 | `function parse(input: string): User` | 是，参数/返回标注擦除 |
| 命名空间 | `namespace Legacy {}` | 是，生成命名空间对象 |
| 环境声明 | `declare const API: Client` | 否，描述外部值 |
| 模块 | `export`, `import` | 导出/导入关系存在，类型部分可擦除 |

## 基础类型表达式

```ts
type Primitive = string | number | boolean | bigint | symbol | null | undefined;
type Literal = "GET" | 200 | true;
type ArrayType = string[] | Array<string>;
type Tuple = [id: string, active?: boolean, ...tags: string[]];
type ReadonlyTuple = readonly [number, number];
type ObjectType = { readonly id: string; name?: string };
type FunctionType = (input: string) => Promise<number>;
type ConstructorType = abstract new (id: string) => object;
```

特殊类型：`any`（关闭检查）、`unknown`（安全未知）、`never`（不可能）、`void`（忽略返回值）、`object`（非原始值）、`{}`（非 null/undefined）。

## 联合、交叉与字面量

```ts
type Input = string | Uint8Array;
type Named = { name: string };
type Timestamped = { createdAt: Date };
type Entity = Named & Timestamped;
```

- `A | B`：值满足其中一个；使用共有成员，先收窄再访问分支成员。
- `A & B`：值同时满足两者；冲突属性可能成为 `never`。
- 字符串/数字/布尔/模板字面量可组成有限状态或键集合。

## 类型运算符

| 运算 | 例子 | 结果 |
| --- | --- | --- |
| `keyof` | `keyof User` | 属性键联合 |
| 类型查询 `typeof` | `typeof config` | 值的静态类型 |
| 索引访问 | `User["id"]`、`T[K]` | 属性/数组元素类型 |
| 条件 | `T extends U ? X : Y` | 根据兼容性选择 |
| 推断 | `T extends Promise<infer V> ? V : T` | 从结构中抽取类型 |
| 映射 | `{ [K in keyof T]?: T[K] }` | 遍历键生成类型 |
| 键重映射 | `{ [K in keyof T as NewKey<K>]: T[K] }` | 改名/过滤键 |
| 模板字面量 | `` `${Method} /${Resource}` `` | 拼接并展开字面量联合 |
| `this` 类型 | `this` | 当前类/接口的多态类型 |
| `unique symbol` | `declare const brand: unique symbol` | 某个符号的唯一类型 |

条件类型对裸类型参数的联合会分发；判断整个联合时写 `[T] extends [U]`。

## 标注、断言与谓词

```ts
const value: string = "text";
const text = input as string;
const frozen = { kind: "x" } as const;
const nonNull = maybe!;
const config = value satisfies Config;

function isString(value: unknown): value is string {
  return typeof value === "string";
}

function assertString(value: unknown): asserts value is string {
  if (typeof value !== "string") throw new Error("Expected string");
}
```

- `as` 和 `!` 不转换、不验证运行时值。
- `as const` 保留字面量并生成浅只读结构。
- `satisfies` 校验兼容性，同时尽量保留表达式推断。
- TSX 文件用 `as`，不要用 `<string>value` 尖括号断言。

## 泛型形态

```ts
function id<T>(value: T): T { return value; }
function get<T, K extends keyof T>(object: T, key: K): T[K] { return object[key]; }
interface Box<out T> { readonly value: T }
function tuple<const T extends readonly unknown[]>(...values: T): T { return values; }
type Default<T = string> = T;
```

`extends` 是约束；`const` 类型参数影响推断；`in`/`out`/`in out` 描述变型方向。泛型可用于函数、接口、类、类型别名和构造签名。

## 函数签名

```ts
function f(required: string, optional?: number, fallback = 0, ...rest: boolean[]): void {}
type Callback = (this: Context, value: string, index?: number) => boolean;
type Callable = { (value: string): number; label: string };
type Constructable = new (value: string) => object;

function parse(value: string): Date;
function parse(value: number): Date;
function parse(value: string | number): Date { return new Date(value); }
```

重载实现签名不可见；若联合参数能清楚表达调用，优先联合。`this` 伪参数只用于检查，不生成实参。

## 对象与类成员修饰符

```ts
abstract class Service extends Base implements Runnable {
  public static readonly version = 1;
  protected cache = new Map();
  private audit = "";
  #runtimePrivate = true;
  abstract prepare(): void;
  override run(): void {}
  accessor status = "ready";
}
```

常见修饰符：`public`、`protected`、`private`、`readonly`、`static`、`abstract`、`override`、`accessor`、`declare`。构造参数可写 `constructor(public id: string) {}` 生成参数属性。

- `extends`：继承实现和实例结构。
- `implements`：只检查类实例是否满足接口，不注入实现。
- `abstract`：不能直接实例化，要求派生类提供成员。
- `override`：明确覆盖基类，推荐开启 `noImplicitOverride`。

## 模块语法

```ts
export const version = "1";
export default class Client {}
export type { User } from "./contracts.js";
export type * from "./contracts.js";

import Client, { version, type User } from "./client.js";
import * as api from "./api.js";
import "./side-effect.js";
const lazy = await import("./lazy.js");
import defer * as feature from "./feature.js";
```

兼容形式：`export = value`、`import value = require("mod")`；只用于 CommonJS/旧库契约。模块增强使用：

```ts
import "library";
declare module "library" {
  interface Client { trace(): void }
}
```

全局增强放在模块文件的 `declare global { ... }` 中。导入属性写 `with { type: "json" }`。

## 环境声明与 JSX

```ts
declare const VERSION: string;
declare function fetchData(): Promise<unknown>;
declare module "legacy" {
  export function parse(text: string): unknown;
}
```

`.d.ts` 只描述类型，不提供运行时实现。`.tsx` 使用 `<Component prop={value} />`；类型断言写 `value as Type`。JSX 属性类型来自框架的 `JSX.IntrinsicElements`、组件参数及相关命名空间。

## 装饰器与资源管理

```ts
@sealed
class DecoratedService {
  @logged
  run(): void {}
}

function work() {
  using resource = open();
  resource.run();
}
```

标准装饰器上下文是 `(value, context)`；旧式参数装饰器只在 `experimentalDecorators` 下可用。`using` 依赖 `[Symbol.dispose]`，`await using` 依赖 `[Symbol.asyncDispose]`。

## JavaScript 核心写法

TypeScript 接受完整 ECMAScript 语法，常与类型功能组合：

```ts
const { id, ...rest } = object;
const merged = { ...defaults, ...overrides };
const [first, ...tail] = values;
const result = value?.nested?.() ?? fallback;
count ??= 0;
count ||= 1;
for (const item of iterable) {}
for await (const item of asyncIterable) {}
```

这些是运行时 JavaScript 语法，不应误标为 TypeScript 专属；TypeScript 只为它们提供静态类型分析和可能的降级输出。

## 类型擦除与运行时代码

### 通常擦除

类型标注、`type`、`interface`、泛型、`keyof`/条件/映射类型、`as`、`satisfies`、`declare`、`import type`。

### 通常保留或生成

变量/函数/类、`enum`、运行时 `namespace`、参数属性、装饰器转换、`using` 清理代码、导入导出、JSX 转换。

`erasableSyntaxOnly` 可用于限制会生成 TypeScript 专属运行时代码的语法，详见 [16-编译配置](./16-tsconfig.md)。

## 类型运算阅读顺序

复杂类型可按下面顺序拆读：

1. 先找泛型参数及其 `extends` 约束。
2. 再看映射键集合 `keyof`/`in` 与键重映射 `as`。
3. 再看索引访问 `T[K]`。
4. 再看条件分支与 `infer`。
5. 最后确认联合/交叉包围范围，必要时加括号。

```ts
type EventOf<
  E extends { type: string },
  K extends E["type"]
> = Extract<E, { type: K }>;
```

先读约束，再读 `E["type"]` 键集合，最后读 `Extract` 的条件过滤。

## TypeScript 专属关键字/修饰符

| 类别 | 关键字/写法 |
| --- | --- |
| 类型声明 | `type`、`interface`、`enum`、`namespace`、`declare`、`module` |
| 类型关系 | `extends`、`implements`、`keyof`、`typeof`、`infer`、`is`、`asserts`、`satisfies` |
| 泛型/映射 | `in`、`out`、`const` 类型参数、映射 `as` |
| 类成员 | `public`、`protected`、`private`、`readonly`、`abstract`、`override`、`accessor`、参数属性 |
| 断言 | `as`、`as const`、非空 `!`、确定赋值 `!:` |
| 模块 | `import type`、`export type`、`import =`、`export =` |
| 资源 | `using`、`await using` |

部分词也属于 JavaScript 语法或上下文关键字，是否生成代码取决于所在位置。

## 常见选择

| 需求 | 首选 |
| --- | --- |
| 可扩展对象契约 | `interface` |
| 联合/元组/条件/映射 | `type` |
| 输入输出有关联 | 泛型 |
| 外部未知数据 | `unknown` + 守卫 |
| 互斥状态 | 判别联合 |
| 校验配置且保留字面量 | `satisfies` + `as const` |
| 从值派生类型 | `typeof`、`keyof`、索引访问 |
| 批量改变属性 | 映射类型/内置工具 |
| 运行时值集合 | `enum` 或 `as const` 对象，按发布需求选择 |
| 公共库扩展点 | 模块增强 + 明确运行时注册 |

完整 ECMAScript 内置 API 见 [标准库目录](./stdlib/README.md)，完整声明签名见 [API 索引](./stdlib/99-api-index.md)。
