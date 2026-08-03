# 09. 模块与命名空间

## 脚本与模块

文件含顶层 `import`、`export` 或 `export {}` 时是模块，拥有独立作用域；否则可能被视为全局脚本。

```ts
export {}; // 即使没有导出，也强制当前文件成为模块
```

`moduleDetection` 可控制检测方式。现代构建通常使用 `"force"` 或由 Node/JSX 规则自动判断。

## ESM 导入导出

```ts
// math.ts
export const pi = Math.PI;
export function add(a: number, b: number) { return a + b; }
export default class Calculator {}

// app.ts
import Calculator, { add, pi as circlePi } from "./math.js";
import * as math from "./math.js";

export { add };
export { default as Calculator } from "./math.js";
export * from "./math.js";
```

常见形式：

- 命名导出/导入：`export { x }`、`import { x }`。
- 默认导出/导入：每模块最多一个 `default`，导入方可自行命名。
- 命名空间导入：`import * as ns`。
- 仅副作用导入：`import "./setup.js"`。
- 重导出：`export { x } from`、`export * from`。

Node ESM 源码中通常按运行时输出写 `.js` 后缀，即使源文件是 `.ts`；具体规则由 `module`、`moduleResolution` 和运行环境决定。

## 类型专用导入导出

```ts
import type { User } from "./contracts.js";
import { createUser, type UserOptions } from "./users.js";

export type { User } from "./contracts.js";
export type * from "./contracts.js";
```

`import type` / `export type` 明确只在类型层使用，编译后可被擦除。启用 `verbatimModuleSyntax` 后，源码写法更直接决定输出，类型必须用类型专用形式导入。

类同时是值和类型；若通过 `import type` 导入，只能把它用作类型，不能 `new` 或 `extends`。

## 动态导入与导入属性

```ts
const feature = await import("./feature.js");

// 静态 JSON 导入，支持情况取决于运行时/打包器
// import config from "./config.json" with { type: "json" };

// 动态导入属性
// const data = await import("./config.json", { with: { type: "json" } });
```

现代语法使用 `with { ... }` 导入属性。旧 `assert { type: "json" }` 形式在 TypeScript 6.0 中已弃用，应按目标运行时迁移。

类型位置也可直接导入：

```ts
type User = import("./contracts.js").User;
```

## 延迟模块求值 `import defer`

```ts
import defer * as analytics from "./analytics.js";

// 模块只在第一次读取命名空间属性时求值
analytics.track("opened");
```

`import defer` 只支持命名空间导入。依赖加载仍会发生，但模块主体求值被延后；需要目标运行时或打包器支持相应语义。

## 任意模块标识符

导入导出名称可以是字符串字面量，适合 WebAssembly 或其他语言生成的非 JavaScript 标识符：

```ts
const buildId = "2026-08-03";
export { buildId as "build-id" };

// import { "build-id" as currentBuild } from "./meta.js";
```

普通业务代码仍优先合法的 JavaScript 标识符。

## CommonJS 与兼容语法

```ts
// legacy.cts
const api = { version: 1 };
export = api;

// consumer.cts
import api = require("./legacy.cjs");
```

`export =` 和 `import x = require(...)` 用于描述/生成 CommonJS 风格模块，不能与同一模块的其他导出混用。新项目优先 ESM；CommonJS 互操作应匹配实际 Node 版本、`package.json` 的 `type` 字段及编译选项。

`require()` 本身是运行时函数，不会自动获得 Node 类型；需要相应运行环境的类型声明。

## 命名空间

```ts
namespace Validation {
  export interface Rule {
    test(value: string): boolean;
  }

  export const required: Rule = {
    test: (value) => value.length > 0,
  };
}
```

命名空间会生成运行时代码，过去用于在全局脚本中组织名称。现代应用优先 ESM。TypeScript 6.0 已弃用以 `module Name {}` 表示内部命名空间的旧形式，兼容代码改用 `namespace`。

命名空间可与类、函数、枚举合并，给运行时值附加静态成员：

```ts
function build(value: string) { return value; }
namespace build {
  export const version = 1;
}
```

这种模式常用于描述既可调用又有属性的旧 JavaScript API，不宜替代普通模块。

## 外部模块声明与增强

为无类型模块提供最小声明：

```ts
declare module "legacy-lib" {
  export function parse(input: string): unknown;
}
```

扩展已有模块：

```ts
import "./observable.js";

declare module "./observable.js" {
  interface Observable<T> {
    map<U>(fn: (value: T) => U): Observable<U>;
  }
}
```

模块增强只能补充已有声明，不能新增顶层导出，也不能增强默认导出。运行时实现仍需真实存在。

模块中的全局增强：

```ts
export {};
declare global {
  interface Window {
    appVersion: string;
  }
}
```

## 三斜线指令

必须出现在文件顶部、普通语句之前：

```ts
/// <reference types="node" />
/// <reference lib="es2024" />
/// <reference path="./legacy.d.ts" />
```

- `types` 引入类型包。
- `lib` 引入标准库声明。
- `path` 按文件依赖旧式声明；现代模块通常用 `import`。
- TypeScript 6.0 弃用了 `no-default-lib` 指令。

## 组合用法：类型契约与实现分离

```ts
// contracts.ts
export interface User { id: string; name: string }
export type CreateUser = Omit<User, "id">;

// service.ts
import type { CreateUser, User } from "./contracts.js";

export async function createUser(input: CreateUser): Promise<User> {
  return { id: crypto.randomUUID(), ...input };
}
```

契约文件只导出类型，运行时模块只保留真正需要的值依赖；这对 `verbatimModuleSyntax`、循环依赖和打包结果更清楚。

## 常见坑

- 类型导入写成普通导入可能留下无意义的运行时依赖；启用 `verbatimModuleSyntax` 并使用 `type` 修饰符。
- `paths` 主要告诉 TypeScript 如何解析，不一定重写生成代码；运行时/打包器必须有匹配配置。
- 命名空间和 ESM 不应为“多一层名字”重复嵌套。
- `.ts`、`.mts`、`.cts` 与 `package.json` 的 `type` 会共同影响 Node 模块格式，发布库时要校验实际产物。
