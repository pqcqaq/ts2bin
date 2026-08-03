# TypeScript 语法手册

这是一套面向日常开发的中文 TypeScript 语法索引。目标不是逐句翻译官方文档，而是用最小示例说明语法，再展示它们如何组合。内容以 TypeScript 官方 Handbook、Reference、Declaration Files 和 Release Notes 为依据，并使用 TypeScript 7.0.2 校验配套示例。

> 资料基线：官方文档仓库提交 `c8170c35bda4811c9516cbb69c39241ae4beb6d9`（2026-07-06）。官方 Release Notes 当前收录到 6.0；7.0.2 编译器用于语法校验。详见 [资料来源](./SOURCES.md)。

## 怎么读

- 第一次系统学习：按 01 → 08 → 09 → 10 → 15 的顺序读。
- 已有 JavaScript 经验：从 02 开始，重点看 03、06、07、15。
- 查语法：直接使用 [17-语法速查](./17-syntax-reference.md)。
- 做库或框架：重点看 07、09、11、12、13。
- 配工程：查看 [16-编译配置](./16-tsconfig.md)。

## 目录

| 章节 | 内容 |
| --- | --- |
| [01-基础语法](./01-basics.md) | 文件、变量、解构、运算符、类型标注、断言 |
| [02-基础类型](./02-basic-types.md) | 原始类型、数组、元组、字面量、特殊类型、枚举 |
| [03-联合与收窄](./03-unions-and-narrowing.md) | 联合、交叉、类型守卫、判别联合、穷尽检查 |
| [04-函数](./04-functions.md) | 函数类型、泛型、重载、`this`、异步与生成器 |
| [05-对象类型](./05-object-types.md) | 属性、索引签名、接口、元组、`satisfies` |
| [06-泛型](./06-generics.md) | 约束、默认值、`const` 类型参数、变型 |
| [07-类型运算](./07-type-operators.md) | `keyof`、`typeof`、条件/映射/模板字面量类型 |
| [08-类](./08-classes.md) | 成员、可见性、继承、抽象类、静态块、访问器 |
| [09-模块与命名空间](./09-modules-and-namespaces.md) | ESM、类型导入、模块增强、命名空间、三斜线指令 |
| [10-运行时协议](./10-runtime-protocols.md) | `enum`、`symbol`、迭代器、生成器、mixin、资源管理 |
| [11-装饰器](./11-decorators.md) | 标准装饰器、上下文、组合、旧式装饰器差异 |
| [12-声明文件与 JSX](./12-declarations-and-jsx.md) | `.d.ts`、`declare`、声明合并、JSX、JSDoc |
| [13-内置工具类型](./13-utility-types.md) | `Partial`、`Pick`、`Awaited`、`NoInfer` 等 |
| [14-现代语法版本表](./14-modern-syntax.md) | 3.7 至 7.0 常用语法与版本基线 |
| [15-组合用法](./15-composition-patterns.md) | API、事件、状态机、配置、插件等完整组合 |
| [16-编译配置](./16-tsconfig.md) | 严格模式、模块、输出、项目引用、迁移注意项 |
| [17-语法速查](./17-syntax-reference.md) | 关键字、操作符、声明形式与选择指南 |
| [ECMAScript 标准库](./stdlib/README.md) | ES5–ES2025/ESNext 内置类型、全部方法分组与完整签名索引 |

## 示例约定

```ts
// 值层：运行时真实存在
const user = { id: 1, name: "Ada" };

// 类型层：编译后会被擦除
type User = typeof user;

// @ts-expect-error 表示下一行故意演示一个应被编译器拒绝的写法
// @ts-expect-error id 必须是 number
const invalid: User = { id: "1", name: "Ada" };
```

文中的 `...` 只表示省略，与可复制代码有差别；完整的可编译版本放在 [examples](./examples/README.md)。内置 API 的逐成员签名见 [标准库完整索引](./stdlib/99-api-index.md)。

## 校验示例

在 `handbook` 目录运行：

```powershell
npm run check
```

脚本会临时调用 `typescript@7.0.2`，不要求全局安装 TypeScript。
