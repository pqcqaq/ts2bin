# 07. ECMAScript 标准库版本索引

本表按本地 `typescript-go/internal/bundled/libs/` 的分项声明归类。某 API 被 TypeScript 声明为某年版本，不保证你的 Node/浏览器已经实现。

## ES5 基线

`lib.es5.d.ts` 提供：

- 全局常量/函数：Infinity、NaN、undefined、eval、parseInt/parseFloat、isNaN/isFinite、URI 编解码。
- Object、Function、Boolean、Number、Math、Date、String、RegExp、Error 家族、JSON。
- Array、ReadonlyArray、ArrayLike、IArguments、PropertyDescriptor。
- TypedArray、ArrayBuffer、DataView 的基础声明。
- TypeScript 工具类型：Partial、Required、Readonly、Pick、Record、Exclude、Extract、Omit、NonNullable、Parameters、ReturnType、InstanceType、Awaited、NoInfer 等（随编译器版本回填到基线文件，不代表 ES5 语言功能）。

## ES2015

分项：`Core`、`Collection`、`Generator`、`Iterable`、`Promise`、`Proxy`、`Reflect`、`Symbol`、`Symbol.WellKnown`。

主要新增：

- Map、Set、WeakMap、WeakSet。
- Promise。
- Proxy 与 Reflect。
- Symbol 和 well-known symbols。
- Iterable/Iterator、Generator。
- Object.assign/is/setPrototypeOf/getOwnPropertySymbols。
- Array.from/of、copyWithin/fill/find/findIndex、数组迭代器。
- String.fromCodePoint/raw、codePointAt/includes/startsWith/endsWith/repeat/normalize、字符串迭代器。
- Number.isFinite/isInteger/isNaN/isSafeInteger、安全整数常量。
- Math 的双曲、立方根、32 位整数、精确对数等方法。

## ES2016

- `Array#includes` / TypedArray `includes`。
- Intl 声明增补（例如 `Intl.getCanonicalLocales` 所在分项随实现基线提供）。

## ES2017

- Object.values、Object.entries、Object.getOwnPropertyDescriptors。
- String.padStart、String.padEnd。
- SharedArrayBuffer、Atomics。
- ArrayBuffer/DataView/TypedArray 与共享内存相关补充。
- Date 与 Intl 格式化签名增补。

## ES2018

- AsyncIterable、AsyncIterator、AsyncGenerator。
- Promise#finally。
- RegExp `dotAll`、命名捕获组等声明。
- Intl.PluralRules。

## ES2019

- Array#flat、Array#flatMap。
- Object.fromEntries。
- String.trimStart/trimEnd（以及 trimLeft/trimRight 别名）。
- Symbol#description。
- Intl 选项与格式化结果增补。

## ES2020

- BigInt、BigInt64Array、BigUint64Array。
- Promise.allSettled 与 settled result 类型。
- String#matchAll。
- Date/Number/SharedMemory/Symbol well-known 声明增补。
- Intl.Locale、Intl.RelativeTimeFormat、Intl.DisplayNames 及更完整 locale 类型。

## ES2021

- Promise.any、AggregateError。
- String#replaceAll。
- WeakRef、FinalizationRegistry。
- Intl.ListFormat 等国际化增补。

## ES2022

- Array#at、String#at、TypedArray `at`。
- Error `cause` 与 `ErrorOptions`。
- Object.hasOwn。
- RegExp `hasIndices`、匹配 indices。
- Intl.Segmenter、Intl.supportedValuesOf 及相关类型。

## ES2023

- Array/TypedArray：findLast、findLastIndex。
- Array：toReversed、toSorted、toSpliced、with。
- TypedArray：toReversed、toSorted、with。
- WeakMap/WeakSet 的弱键类型扩展到符合要求的 symbol。
- Intl 格式化选项继续增补。

## ES2024

- ArrayBuffer：resizable、maxByteLength、resize、detached、transfer、transferToFixedLength。
- SharedArrayBuffer：growable、maxByteLength、grow。
- Object.groupBy、Map.groupBy。
- Promise.withResolvers。
- RegExp `unicodeSets`（`v` flag 相关声明）。
- String#isWellFormed、String#toWellFormed。
- Atomics.waitAsync 及共享内存增补。

## ES2025

- Set/ReadonlySet：union、intersection、difference、symmetricDifference、isSubsetOf、isSupersetOf、isDisjointFrom。
- Iterator Helpers：Iterator.from、map、filter、take、drop、flatMap、reduce、toArray、forEach、some、every、find。
- Float16Array、Math.f16round、DataView#getFloat16/#setFloat16。
- Promise.try。
- RegExp.escape。
- Intl.DurationFormat。

## ESNext

ESNext 会随 TypeScript/标准进展变化，本地基线包含：

| 分项 | API |
| --- | --- |
| `ESNext.Array` | `Array.fromAsync` |
| `ESNext.Collection` | Map/WeakMap `getOrInsert`、`getOrInsertComputed` |
| `ESNext.Date` | `Date#toTemporalInstant` |
| `ESNext.Decorators` | `Symbol.metadata`、Function metadata |
| `ESNext.Disposable` | Disposable、AsyncDisposable、SuppressedError、DisposableStack、AsyncDisposableStack、迭代器释放协议 |
| `ESNext.Error` | `Error.isError` |
| `ESNext.Intl` | Temporal 格式化、Locale 信息方法/属性增补 |
| `ESNext.SharedMemory` | `Atomics.pause` |
| `ESNext.Temporal` | Temporal 八类对象与 Now |
| `ESNext.TypedArrays` | Uint8Array Base64/Hex 编解码 |

## 选 `lib` 的方法

### 稳定应用

选最低部署环境已完整支持的年份：

```jsonc
{
  "target": "ES2022",
  "lib": ["ES2022", "DOM"]
}
```

### 新 API + polyfill

可以保持较低 `target`，单独加入需要的声明，但必须保证运行时实现：

```jsonc
{
  "target": "ES2022",
  "lib": ["ES2022", "ESNext.Disposable", "DOM"]
}
```

### 试验 ESNext

```jsonc
{
  "target": "ES2025",
  "lib": ["ESNext"]
}
```

ESNext 适合应用与试验；公共库的导出类型若直接引用 ESNext 类型，会把相同 `lib` 要求传给消费者。

## 排查缺失 API

1. 用 `tsc --showConfig` 确认最终 `target`/`lib`。
2. 在 [99-API 完整索引](./99-api-index.md) 搜索类型/方法，查看来源分项。
3. 检查真实运行时的版本支持。
4. 需要时加入 polyfill 和对应类型，而不是只扩大 `lib`。
