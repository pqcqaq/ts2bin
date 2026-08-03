# 12. 声明文件、JavaScript 与 JSX

## `.d.ts` 的作用

声明文件描述已经存在的 JavaScript，不提供运行时实现。内容应表达 API 真实行为，而不是理想中的行为。

```ts
// globals.d.ts
declare const APP_VERSION: string;
declare function loadConfig(path: string): Promise<unknown>;

declare class HostClient {
  constructor(endpoint: string);
  request(path: string): Promise<unknown>;
}
```

环境声明通常使用 `declare`，不能写需要输出的函数体或字段初始化器。

## 模块声明

```ts
// index.d.ts
export interface Options {
  strict?: boolean;
}

export function parse(input: string, options?: Options): unknown;
export default class Parser {
  parse(input: string): unknown;
}
```

文件含顶层 `export`/`import` 时，它描述自身模块。为某个无类型包补声明时使用环境外部模块：

```ts
declare module "legacy-parser" {
  export interface Options { strict?: boolean }
  export function parse(input: string, options?: Options): unknown;
}
```

尽量返回 `unknown` 或具体结构，不要为了省事把整个模块声明成 `any`。

## 常见 JavaScript 库形状

### 导出函数并附带属性

```ts
export = build;

declare function build(input: string): build.Result;
declare namespace build {
  interface Result { code: string }
  const version: string;
}
```

### 导出类

```ts
export = Client;

declare class Client {
  constructor(url: string);
  connect(): Promise<void>;
}
```

### UMD：模块 + 全局名

```ts
export as namespace Toolkit;
export function create(): object;
```

`export =` 对应 CommonJS 单一导出，不能与普通顶层 `export` 混用。现代 ESM 库优先原生具名/默认导出声明。

## 全局与模块增强

模块文件中扩展全局：

```ts
export {};

declare global {
  interface Window {
    appVersion: string;
  }
}
```

扩展已有模块：

```ts
import "library";

declare module "library" {
  interface Client {
    trace(): void;
  }
}
```

增强只修改类型；必须另有代码真正给 `Client.prototype` 添加 `trace`。

## 声明合并

| 同名声明 | 是否可合并 | 典型用途 |
| --- | --- | --- |
| `interface` + `interface` | 可以 | 扩展对象契约 |
| `namespace` + `namespace` | 可以 | 分文件补成员 |
| `namespace` + `class` | 可以 | 给类增加静态类型成员 |
| `namespace` + `function` | 可以 | 可调用对象附加属性 |
| `namespace` + `enum` | 可以 | 枚举附加帮助成员 |
| `type` + 任意同名类型 | 不可以 | 类型别名不会合并 |
| 两个默认导出 | 不可以 | 默认导出不可按名字增强 |

接口合并时，同名非函数属性必须类型一致；函数成员会形成重载组。公共全局接口的合并会影响整个程序，应谨慎命名。

## 声明文件发布

库可通过 `package.json` 指向声明：

```json
{
  "name": "example",
  "type": "module",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "import": "./dist/index.js"
    }
  },
  "types": "./dist/index.d.ts"
}
```

发布前至少验证：导出映射、ESM/CJS 后缀、声明内相对导入、目标 Node/打包器解析，以及一个外部消费项目。

## 在 JavaScript 中使用类型

启用 `allowJs`/`checkJs`，或在单文件顶部写 `// @ts-check`：

```js
// @ts-check

/** @typedef {{ id: string, name: string }} User */

/**
 * @param {User} user
 * @returns {string}
 */
export function label(user) {
  return `${user.id}: ${user.name}`;
}
```

常用 JSDoc：

| 标签 | 用途 |
| --- | --- |
| `@type {T}` | 变量类型 |
| `@param {T} name` | 参数类型 |
| `@returns {T}` | 返回类型 |
| `@typedef` / `@callback` | 类型/函数类型别名 |
| `@template T` | 泛型参数 |
| `@satisfies {T}` | 校验表达式而保留推断 |
| `@overload` | JavaScript 函数重载 |
| `@import {T} from "mod"` | 仅类型导入 |

JSDoc 支持的类型语法接近 TypeScript，但并非所有 `.ts` 语法都有对应形式。

## JSX / TSX

`.tsx` 中 JSX 表达式由 `jsx` 编译选项决定：

```tsx
type ButtonProps = {
  label: string;
  onClick?: () => void;
};

function Button(props: ButtonProps) {
  return <button onClick={props.onClick}>{props.label}</button>;
}

const view = <Button label="Save" />;
```

### 类型检查入口

- `JSX.IntrinsicElements`：`div`、`button` 等小写固有元素的属性类型。
- 值组件：大写名字先按作用域中的函数或类查找。
- `JSX.Element`：JSX 表达式结果类型。
- `JSX.ElementClass`：类组件实例要求。
- `JSX.ElementAttributesProperty`：指定哪个属性保存 props 类型。
- `JSX.ElementChildrenAttribute`：指定 children 属性名。
- `JSX.LibraryManagedAttributes`：框架对组件 props 的二次变换入口。
- `JSX.IntrinsicAttributes` / `IntrinsicClassAttributes<T>`：框架级特殊属性。

现代 JSX 运行时通常从 `jsxImportSource` 对应包的 `JSX` 命名空间取类型；旧式/自定义运行时也可能使用全局 `JSX`。应遵循框架提供的声明，不要在应用里随意覆盖全局 JSX。

### 尖括号断言冲突

```tsx
const value = input as string; // TSX 中使用 as
```

`<string>input` 会被解析为 JSX，因此 TSX 只能使用 `as` 断言。

## 组合用法：为插件补充类型

```ts
// plugin-augmentation.d.ts
import "app-core";

declare module "app-core" {
  interface CommandMap {
    "plugin:sync": { force: boolean };
  }
}
```

核心库可以通过空接口/映射接口提供扩展点，插件通过模块增强增加键，再由 `keyof` 与索引访问派生命令 API。运行时仍需注册相应处理器。

## 常见坑

- `.d.ts` 不会加载 polyfill 或实现；类型存在不代表运行时对象存在。
- 全局环境模块 `declare module "x"` 与模块文件中的 `declare module "x"` 含义不同：后者通常是增强。
- 使用 `skipLibCheck` 可提速，但会隐藏声明文件之间的错误；发布类型包时应有不跳过的验证流程。
- JSX 类型由框架运行时模型决定，不要把 React 的假设套到所有 JSX 工具链。
