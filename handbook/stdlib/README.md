# ECMAScript 标准库

本目录基于本地 `typescript-go/internal/bundled/libs/` 的 ES5、ES2015–ES2025 与 ESNext 声明整理，参考仓库提交 `5b1047d10`（2026-07-31）。

## 先理解 `lib`

TypeScript 的 `lib` 文件只描述运行时 API 的类型：

```jsonc
{
  "compilerOptions": {
    "target": "ES2024",
    "lib": ["ES2024"]
  }
}
```

- `target` 决定语法输出基线，并影响默认 `lib`。
- 显式 `lib` 决定编译时可见的标准 API。
- 二者都不会安装 polyfill，也不会让旧运行时凭空拥有新方法。

## 范围

收录 ECMAScript 内置对象、协议、Intl 与当前 ESNext 提案声明。以下属于宿主环境，不混入本索引：

- `lib.dom*.d.ts`：浏览器 DOM/Web API。
- `lib.webworker*.d.ts`：Worker API。
- `lib.scripthost.d.ts`：旧脚本宿主 API。

TypeScript 自身工具类型已单独放在 [13-内置工具类型](../13-utility-types.md)，但完整索引仍保留它们的真实声明。

## 分组文档

| 文档 | 内容 |
| --- | --- |
| [01-原始值与全局对象](./01-primitives-and-globals.md) | Object、Function、String、Number、BigInt、Math、Symbol、JSON、Error、全局函数 |
| [02-数组与二进制数据](./02-arrays-and-binary.md) | Array、TypedArray、ArrayBuffer、DataView、Atomics |
| [03-集合、弱引用与反射](./03-collections-and-reflection.md) | Map、Set、Weak*、Proxy、Reflect、属性描述符 |
| [04-异步、迭代与资源](./04-async-iteration-resources.md) | Promise、Iterator Helpers、Generator、DisposableStack |
| [05-正则、日期与国际化](./05-regexp-date-intl.md) | RegExp、Date、Intl 全部格式化对象 |
| [06-Temporal](./06-temporal.md) | PlainDate、Instant、ZonedDateTime、Duration 等 |
| [07-版本索引](./07-version-map.md) | 每个 ES 年份新增的内置 API |
| [99-API 完整索引](./99-api-index.md) | 314 个声明类型、103 个值签名、2173 条成员签名 |

## 稳定与前沿

- `ES2025` 及更早：按对应 ECMAScript 年份选用，仍需检查目标运行时版本。
- `ESNext`：跟随 TypeScript 更新，名称、签名或标准化年份可能变化。
- `Decorators` / `Disposable` / `Temporal` 等也可用单独 lib 分项启用。

代码发布时，以最低运行时的支持矩阵为准；类型检查通过只能证明声明存在。
