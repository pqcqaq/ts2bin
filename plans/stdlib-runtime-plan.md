# ECMAScript 标准库与 Bingo Runtime 规划

`handbook/stdlib/` 已按本地 `typescript-go/internal/bundled/libs/` 整理 ES5、ES2015–ES2025、ESNext 的声明和完整成员索引。本文件把这些“编译期可见 API”映射成 ts2bin 可执行的 runtime 能力，避免把 `.d.ts` 当作实现。

## 1. 三个独立版本面

```text
TypeScript lib declaration
  ∩ bingo language/profile
  ∩ runtime capability manifest
  -> callable API
```

三者含义不同：

- `lib`：checker 是否允许名字、类型和方法签名。
- `bingo profile`：该 API 是否符合 static/interop 的对象、异常、异步和内存语义。
- `runtime manifest`：目标产物中是否存在匹配版本的实现符号。

类型检查通过但 runtime capability 缺失，必须报 `BINGO3002_RUNTIME_CAPABILITY_MISSING`，不能生成一个链接时才失败的二进制。

## 2. Capability manifest

建议维护 `runtime/capabilities/<profile>.json`：

```json
{
  "manifestVersion": 1,
  "runtimeAbi": 1,
  "name": "core-es2020",
  "esVersion": "ES2020",
  "symbols": {
    "global.String.prototype.replaceAll": {
      "status": "implemented",
      "signatureHash": "...",
      "requires": ["utf16-string"]
    },
    "global.Proxy": {
      "status": "dynamic-only",
      "requires": ["dynamic-object"]
    }
  }
}
```

每个 capability 保存：声明全名、签名 hash、最低 lib、实现状态、依赖、异常/分配 effect、target 限制和测试 fixture。manifest 由标准库索引脚本和 runtime 导出表交叉生成，CI 不允许只改一边。

状态：

```text
implemented       可在 static profile 调用
runtime-only      需要对象/异步/GC runtime，但语义稳定
dynamic-only      只允许 interop/dynamic profile
external-ffi      由用户 manifest 提供
planned           有设计但不能编译
unsupported       诊断拒绝
```

## 3. 分阶段标准库矩阵

### 3.1 Core ES5：S0/S2

来源：[01-原始值与全局对象](../handbook/stdlib/01-primitives-and-globals.md)。

| API 组 | 初始状态 | 实现方式 |
| --- | --- | --- |
| `Object`, `Function`, `Boolean` | S0/S2 | 已知 shape、FuncRef 和 bool；宽 `Object`/`Function` 进入 dynamic |
| `String`, `StringConstructor` | S0/S2 | UTF-16 string ABI、常量驻留、builder/比较 helper |
| `Number`, `Math` | S0/S2 | f64 基础运算；libm/softfloat 对齐 NaN、Infinity、-0 |
| `JSON` | S2 | parser/stringifier runtime；对象 shape 与 dynamic 边界明确 |
| `Error` 家族 | S2 | exception object layout、stack/source metadata |
| `parseInt`, `parseFloat`, URI 函数 | S2 | runtime；失败结果/异常行为锁定 golden |

`Object.keys/values/entries`、property descriptor 和 `Object.assign` 涉及枚举顺序/动态属性；静态已知 shape 可优化，通用版本属于 runtime-only。

### 3.2 ES2015–ES2022：S2

来源：[02-数组与二进制数据](../handbook/stdlib/02-arrays-and-binary.md)、[03-集合、弱引用与反射](../handbook/stdlib/03-collections-and-reflection.md)、[04-异步、迭代与资源](../handbook/stdlib/04-async-iteration-resources.md)。

| API 组 | 状态 | 关键前置 |
| --- | --- | --- |
| `Array`, `ReadonlyArray`, `ArrayIterator` | runtime-only | 长度/稀疏元素/边界/iterator close |
| `Map`, `Set` | runtime-only | hash/equality、插入顺序、迭代器失效规则 |
| `WeakMap`, `WeakSet`, `WeakRef`, `FinalizationRegistry` | planned/runtime-only | tracing GC、弱引用和终结队列 |
| `Symbol`, well-known symbols | runtime-only | identity table、iterator/dispose protocol keys |
| `Reflect` | runtime-only | 已知 shape 只开放安全子集 |
| `Proxy` | dynamic-only | 动态 trap、代理不变量，static 默认拒绝 |
| `Promise`, `PromiseLike`, `Promise.all/race/allSettled/any` | runtime-only | scheduler、microtask、异常传播 |
| `Iterator`/`AsyncIterator`/Generator | runtime-only/planned | iterator result layout、close/throw/return |
| `ArrayBuffer`, `SharedArrayBuffer`, `DataView`, TypedArray | runtime-only | endian、bounds、detachment、atomicity |
| `Atomics` | planned/runtime-only | SharedArrayBuffer、内存模型、线程调度 |
| `Disposable`, `AsyncDisposable`, `DisposableStack` | runtime-only | cleanup stack、SuppressedError、异常合并 |

### 3.3 ES2023–ES2025：S2/Planned

| 新 API | 状态 | 计划 |
| --- | --- | --- |
| `Array.prototype.findLast/findLastIndex`, `toReversed/toSorted/toSpliced/with` | runtime-only | 纯数组 helper，可在无副作用时优化 |
| `Array.fromAsync` | planned | 复用 AsyncIterator/Promise 状态机 |
| Set composition：`union`, `intersection`, `difference`, `symmetricDifference`, `isSubsetOf`, `isSupersetOf`, `isDisjointFrom` | runtime-only | 维护插入顺序和 SameValueZero 语义 |
| Iterator Helpers：`map/filter/take/drop/flatMap/reduce/toArray/forEach/some/every/find`、`Iterator.from` | runtime-only | lazy iterator object + close protocol |
| `Promise.withResolvers`, `Promise.try` | runtime-only | resolver object 和同步异常转 rejection |
| `RegExp.escape`、现代 RegExp flags/indices | runtime-only | 版本化 regex engine，Unicode 行为列入 conformance |
| `Float16Array`, `Math.f16round`, DataView float16 | planned | 明确 half conversion，不能用 f32 截断冒充 |
| `Intl.DurationFormat` | planned/external-ffi | ICU capability；静态 core 不内置完整 locale 数据 |

### 3.4 ESNext：单独 profile

来源：[06-Temporal](../handbook/stdlib/06-temporal.md)、[07-版本索引](../handbook/stdlib/07-version-map.md) 和 [99-API 完整索引](../handbook/stdlib/99-api-index.md)。

默认 `static` 不接受 ESNext capability，必须显式选择 `runtime=esnext-experimental`：

- `Temporal.Now`、PlainDate、PlainTime、PlainDateTime、ZonedDateTime、Duration、Instant、PlainYearMonth、PlainMonthDay：external-ffi 或独立 runtime，所有 timezone/calendar 数据版本化。
- `Map/WeakMap.getOrInsert*`：runtime-only，要求 map key/equality ABI。
- `Date.toTemporalInstant`、`Error.isError`、`Atomics.pause`：按 runtime/target 单独开启。
- `Uint8Array` base64/hex 编解码：runtime-only，可作为无分配 fast path。

ESNext 声明可能变化；snapshot/cache 必须包含 `typescriptGoCommit` 和 stdlib manifest hash。

## 4. 宿主 API 边界

`lib.dom*`、`lib.webworker*`、`lib.scripthost.d.ts` 不属于 ECMAScript 标准库。Node.js、Deno、Bun、浏览器 API 通过 FFI manifest 接入：

```text
typed declaration (.d.ts)
  -> external symbol contract
  -> ABI adapter (pointer/string/exception/async)
  -> host implementation
```

没有 ABI adapter 的 DOM/Node 类型即使 checker 能解析，也报 `BINGO3003_HOST_API_UNBOUND`。不能把 DOM object 当作 Bingo `Struct`，也不能把 Node `Buffer` 自动当 `Uint8Array`。

## 5. GC、内存和对象生命周期

### 5.1 默认选择：非移动 tracing GC

普通 TypeScript 对象可以构成环，纯 ARC 会泄漏；因此 `gc=tracing` 是 general static profile 的默认正确选择：

- runtime 分配 non-moving heap object，header 保存 mark/shape/size。
- 每个 native frame 和 async/generator frame 注册 root map。
- 进入 runtime、调用可能分配的 extern、suspend、异常边都成为 safepoint。
- 指针字段写入使用 `gc.write_barrier`；数组/object 扩容更新 shape/size metadata。
- collector 先实现 stop-the-world mark-sweep，再按 target 增加并发标记/压缩。

### 5.2 ARC/arena 仅作受限 profile

- `gc=arc` 只允许没有潜在环、没有 WeakRef/FinalizationRegistry、没有 dynamic Proxy 的受限程序；无法证明时编译拒绝，而不是静默泄漏。
- `gc=arena` 只适合模块初始化/编译器生成临时对象，不能作为全局 JS object 语义。
- `Ref` 生命周期由 MIR retain/release 或 root registration 统一管理；LLVM backend 不直接生成裸 `free`。

### 5.3 字符串和二进制数据

- JS string 使用 UTF-16 code unit；`length`, `at`, index access 不能按 Unicode scalar/UTF-8 字节数实现。
- `Uint8Array`/DataView 使用独立 byte buffer；共享 buffer 需要 atomic/memory-order ABI。
- string/byte conversion 明确 alloc、encoding error 和 replacement policy。

## 6. Runtime ABI 分层

```text
abi/core.h       primitive, string, object header, allocation, error
abi/collections  array, map, set, iterator
abi/async        promise, scheduler, async iterator
abi/resource     dispose, suppressed error
abi/reflect      symbol, proxy, property descriptor
abi/intl         ICU/locale/temporal external boundary
abi/host         Node/browser/FFI adapters
```

每层单独有 ABI version 和 feature flag。`rt.*` intrinsic 只能引用声明中存在的层；链接器在最终阶段检查完整闭包。

## 7. 标准库 lowering 规则

1. **纯函数/数值**：优先 intrinsic/LLVM instruction，必须证明 NaN、Infinity、-0 和 rounding 一致。
2. **已知 shape 的对象方法**：静态 direct call 或 vtable slot；保存 getter/override 语义。
3. **通用对象/集合**：runtime call，参数为 RepType/descriptor，不接受裸 `i8*`。
4. **协议对象**：iterator/promise/disposable 通过标准 symbol slot 或显式 vtable，不能用名称字符串猜测。
5. **dynamic/Proxy/Reflect**：进入 DynamicValue，保留 property key 和 trap effect；static 直接拒绝。
6. **compile-only 工具类型**：`Partial`、`Pick`、`Omit`、`Awaited`、`NoInfer` 等由 checker 求值，零 runtime 成本。

## 8. Capability 测试

每个 runtime symbol 至少有：

- declaration fixture：来自 `handbook/stdlib/99-api-index.md` 的签名。
- positive compile：checker + subset gate 通过。
- negative compile：缺 capability 或错误 profile 报稳定 BINGO 诊断。
- runtime behavior：Node/标准测试 oracle 或规范化输入输出。
- LLVM link：intrinsic 符号存在、ABI hash 一致。
- memory/effect：alloc、throw、suspend、GC root、write barrier 检查。
