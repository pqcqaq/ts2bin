# 14. 现代语法与版本基线

这张表关注会改变源码写法的功能。类型推断改善不一定引入新语法，编译配置变化也不等于语言新增。

## TypeScript 3.7–4.9

| 版本 | 主要语法/行为 | 最小写法 |
| --- | --- | --- |
| 3.7 | 可选链、空值合并、断言函数 | `x?.y ?? fallback`、`asserts x is T` |
| 3.8 | 类型专用导入导出、私有字段支持 | `import type { T }`、`#value` |
| 3.9 | 推断/性能与 `@ts-expect-error` | `// @ts-expect-error` |
| 4.0 | 可变元组、具名元组 | `[head: H, ...tail: T]` |
| 4.1 | 模板字面量类型、键重映射、递归条件类型 | `` `${A}-${B}` ``、`[K in X as Y]` |
| 4.2 | 元组中间/开头剩余、抽象构造签名 | `[...A, end: E]`、`abstract new()` |
| 4.3 | `override`、getter/setter 不同读写类型 | `override method()` |
| 4.4 | 类静态块、`unknown` catch、精确可选属性 | `static {}`、`catch (e: unknown)` |
| 4.5 | `Awaited`、单条导入内的 `type` 修饰符 | `import { fn, type T }` |
| 4.6 | 控制流/析构/参数相关性改善 | 通常无需新语法 |
| 4.7 | 实例化表达式、`infer extends`、变型标注 | `fn<string>`、`infer S extends string`、`in/out T` |
| 4.8 | 交叉/联合与模板字符串推断改善 | 通常无需新语法 |
| 4.9 | `satisfies`、自动访问器 | `value satisfies T`、`accessor x` |

## TypeScript 5.0–6.0

| 版本 | 主要语法/行为 | 最小写法 |
| --- | --- | --- |
| 5.0 | 标准装饰器、`const` 类型参数、类型星号重导出 | `@dec`、`<const T>`、`export type *` |
| 5.1 | getter/setter 可声明无关类型、JSX 返回类型放宽 | `get x(): T` / `set x(v: U)` |
| 5.2 | `using` / `await using`、装饰器元数据、元组标签放宽 | `using x = resource` |
| 5.3 | 导入属性、`switch (true)` 收窄 | `with { type: "json" }` |
| 5.4 | `NoInfer`、闭包中的收窄保留改善 | `NoInfer<T>` |
| 5.5 | 推断类型谓词、常量索引访问收窄 | `array.filter(x => x !== undefined)` |
| 5.6 | 任意模块标识符、迭代器类型加强 | `export { x as "build-id" }` |
| 5.7 | ES2024 目标/库、未初始化变量检查加强 | 主要为检查与配置变化 |
| 5.8 | `erasableSyntaxOnly`、Node ESM 检查改善 | 配置项，不是表达式语法 |
| 5.9 | 延迟模块求值 | `import defer * as ns from "mod"` |
| 6.0 | 默认值现代化、大量旧选项弃用、为 7.0 迁移 | 主要为配置/兼容性变化 |

## TypeScript 7 原生端

本地 `typescript-go` 基准提交的 README 明确：解析/扫描应与 TypeScript 6.0 给出相同语法错误，类型解析应与 6.0 相同。7.0 的核心变化是编译器原生移植与旧选项移除，不应凭实现版本号推断出一套不存在的“7.0 新语法”。

项目迁移应先在 TypeScript 6.0 中处理弃用警告，再切换原生编译器。原生端仓库仍可能更新实现完整度，具体状态以项目 README 和发布说明为准。

## 几个现代组合

### 精确配置

```ts
const colors = {
  success: "#0a0",
  danger: "#a00",
} as const satisfies Record<string, `#${string}`>;
```

### 保留字面量的 API

```ts
function defineRoutes<const T extends Record<string, `/${string}`>>(routes: T): T {
  return routes;
}
```

### 自动释放

```ts
function useConnection() {
  using connection = openConnection();
  return connection.query();
}

declare function openConnection(): Disposable & { query(): unknown };
```

### 延迟求值

```ts
import defer * as feature from "./feature.js";
feature.start();
```

## 兼容性策略

1. `target` 决定 TypeScript 对语法的降级输出和默认库集合，但不自动为新 API 提供 polyfill。
2. `lib` 只提供类型声明，不改变运行时能力。
3. `module`/`moduleResolution` 必须匹配 Node、浏览器或打包器的真实加载规则。
4. ESNext 类型可用于试验，但升级 TypeScript 时可能变化；库的公共类型优先稳定 ES 年份。
5. 用 CI 中的最低 TypeScript/运行时版本验证，不只在本机最新版本上通过。
