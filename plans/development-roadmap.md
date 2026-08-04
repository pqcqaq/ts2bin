# ts2bin 六阶段开发计划

本计划把 `ast2bingo` 拆成六个可独立验收的阶段。每阶段都必须增加源码样例、诊断 golden、HIR/MIR golden 和最少一组可运行测试；未通过上一阶段退出条件，不进入下一阶段扩展语法。

阶段的输入和产物必须分别对照 [tsgo-integration.md](tsgo-integration.md)、[bingo-ir-spec.md](bingo-ir-spec.md)、[stdlib-runtime-plan.md](stdlib-runtime-plan.md) 和 [testing-conformance-and-release.md](testing-conformance-and-release.md)。实际编码从 [implementation-specification.md](implementation-specification.md) 进入，并同时遵守逐语法 lowering、类型/方差、runtime/backend 和拒绝诊断四份细则。本文件只定义实施顺序，不重复定义这些契约；若路线图与 verifier、capability manifest 或 case manifest 冲突，以后者为准。需要直接拆 issue 时使用 [implementation-backlog.md](implementation-backlog.md)，其中的编号和依赖是执行层契约。

## 总体顺序

```text
阶段 1 前端锁定
  -> 阶段 2 HIR + 静态核心
  -> 阶段 3 布局/函数/对象/闭包/variance
  -> 阶段 4 模块/泛型/集合/迭代/资源
  -> 阶段 5 runtime-heavy 语义
  -> 阶段 6 LLVM 产品化与兼容性
```

## 阶段 1：前端集成、类型快照与语法闸门

### 目标

把本地 `typescript-go` 变成可稳定调用的前端，定义 ts2bin 自己的编译 profile 和诊断协议。这个阶段不生成 LLVM，不尝试“先支持全部语法”。

### 工作项

1. 固定 `typescript-go` commit、Go toolchain、标准库声明和 tsconfig 默认值；fork 只增加 `cmd/ts2bin` 与内部包。
2. 构造 `compiler.Program`，读取 source files，依次检查 syntactic、bind、semantic、global diagnostics。
3. 为 `ast.Node` 建立只读 visitor，生成 `TypedSnapshot`：NodeId、Span、Kind、SymbolId、TypeId、SignatureId、flow facts、capture set、module id。
4. 把 checker 查询集中到 `internal/ast2bingo/semantic.go`，不让后续 lowering 直接调用 checker 私有实现。
5. 根据 [typescript-support-matrix.md](typescript-support-matrix.md) 实现 subset gate：`any`、不可靠断言、dynamic object、未实现 async/EH 等输出 BINGO 诊断。
6. 建立 source span 到 HIR/MIR/LLVM metadata 的 ID 链，保证错误可以回到原始 TS 行列。
7. 实现 `internal/tsfrontend` facade 和 `ProgramSnapshot` schema；checker 按独占借用分组捕获，`done()` 后才允许并行 lowering。
8. 生成 AST Kind manifest、tsconfig/profile snapshot 和 module graph digest，并将 `typescriptGoCommit`、stdlib hash 写入 provenance。

### 交付物

- `cmd/ts2bin check`：只解析/类型检查/打印稳定诊断。
- `cmd/ts2bin dump-snapshot`：输出 JSON 或文本 snapshot。
- 语法节点覆盖报告：以 `Kind` 为全集，不能有未分类的源节点。
- 50 个以上正例和拒绝例，包含 `as any as`、unknown、variance、module、JSX、using。

### 验收门槛

- 同一 commit、同一配置下 snapshot 字节稳定。
- tsgo 报错的源程序绝不进入 HIR；tsgo 合法但矩阵 R 的程序有稳定 BINGO 诊断。
- 不修改 `typescript-go` parser/checker 行为；上游测试仍通过。
- snapshot 不保存长期有效的 AST 指针，不依赖生成文件中未承诺的私有布局。
- snapshot schema、AST Kind manifest、配置归一化结果和诊断排序均有稳定 golden；任何 checker 指针泄漏测试失败。

## 阶段 2：Bingo HIR、静态类型和控制流核心

### 目标

实现可以独立验证的 Bingo HIR，覆盖算术、布尔、字符串常量、变量、函数、基本控制流和显式转换。此阶段可用纯 Go HIR interpreter 或 `llir/llvm` 生成文本做快速反馈，生产 LLVM 绑定稍后固定。

### 工作项

1. 定义 `TsType`、`RepType`、`ValueId`、`BlockId`、`FuncId`、`SymbolId` 和 source origin。
2. 实现 HIR builder：literal、identifier、binary/unary、call、variable、return、if、while、for、switch、conditional。
3. 将 flow narrowing、literal widening、`never`/unreachable 转成 HIR facts；不在 lowering 中重新猜测类型。
4. 实现 `as`、`satisfies`、non-null、nullish/optional chain、logical assignment 的消糖。
5. 建立 HIR verifier：值类型、定义先后、CFG、phi、短路路径和不可达块。
6. 实现常量折叠和副作用序列测试，但不做跨函数激进优化。
7. 依据 [bingo-ir-spec.md](bingo-ir-spec.md) 固定 HIR -> MIR pass 顺序，建立 HIR/MIR verifier、effect 检查和 source-origin 传播。

### 首批必须可运行样例

```ts
export function add(a: number, b: number): number { return a + b; }
export function classify(x: string | number): string {
  if (typeof x === "string") return x;
  return String(x);
}
```

### 验收门槛

- HIR verifier 对所有正例通过，对篡改 golden 的非法 IR 必须报错。
- `f64` number、bool、UTF-16 string、null/undefined 的表示固定并有 ABI 测试。
- optional chain、nullish、短路、条件表达式的副作用次数与 TypeScript/JavaScript oracle 一致。
- 误用 dynamic、跨域隐式转换和 disjoint assertion 在 HIR 入口被拒绝。
- verifier 能拒绝未定义值、非法 phi、effect 不匹配和未处理 cleanup；任何 malformed golden 都不能到达 LLVM backend。

## 阶段 3：表示布局、函数、对象、类、闭包与 variance

### 目标

从“表达式可以算”扩展到“值可以安全存储、传递、调用和捕获”。这是协变/逆变、结构化类型和 runtime layout 的核心阶段。

### 工作项

1. 固定对象 shape、class layout、method table、field offset、array/tuple layout 和 nullable representation。
2. 实现 function value、closure environment、lexical `this`、recursive function 和 indirect call。
3. 实现 class extends、constructor/super、field initializer、getter/setter、private/protected、static block。
4. 建立 Bingo variance checker：函数参数逆变、返回协变、可写字段/数组不变、只读集合协变。
5. 读取 checker 的 variance/assignability/inference 结果，但对 unmeasurable/unreliable 做二次拒绝或生成 adapter thunk。
6. 支持 object literal、property access、computed constant key、destructuring；动态 property 仍为 R/S2。
7. 实现显式 `checked_cast`、layout adapter 和可审计的 `unsafeCast` intrinsic。

### 验收门槛

- `ReadonlyArray<Dog>` 到 `ReadonlyArray<Animal>` 可通过；`Array<Dog>` 到 `Array<Animal>` 默认拒绝或显式复制。
- `(Animal) => void` 与 `(Dog) => void` 的参数方向测试正确；方法 bivariance 不直接穿过静态 ABI。
- 闭包捕获变量、class private slot、getter 副作用、super 调用都有运行测试。
- 不能生成同一 `TypeScript` 类型却使用不兼容 LLVM 表示的函数签名。

## 阶段 4：模块、泛型、枚举、集合、迭代与资源清理

### 目标

形成可组织的大型程序：模块图、初始化顺序、跨模块符号、可控泛型实例化和常用集合协议。

### 工作项

1. 使用 Program 的模块解析结果建立 ModuleGraph、import/export slots、default export 和循环依赖初始化。
2. 擦除 `import type`、纯类型导出和声明文件；为外部实现建立 FFI declaration contract。
3. 实现按表示分组的泛型单态化；加入递归深度、实例数量和代码尺寸上限。
4. 支持 generic constraint、default/const type parameter、in/out variance、泛型函数/类/接口的 HIR 实例化。
5. 实现 enum/const enum、tuple、array、readonly view、Map/Set 基础 runtime ABI。
6. 将 `for...of`、迭代器、array fast path、object/array spread 和解构连入 runtime。
7. 实现 `using`/`await using` 的 cleanup stack、`Disposable`/`AsyncDisposable` ABI。
8. 为每个标准库调用查询 [stdlib-runtime-plan.md](stdlib-runtime-plan.md) 的 capability manifest；声明存在但 runtime 未实现时在编译期报错。

### 验收门槛

- 多文件 ESM 样例（含循环依赖）初始化顺序稳定，重复导入只执行一次。
- 泛型实例化不会把 unresolved type parameter 留到 MIR；超限有可定位诊断。
- `for...of`、spread、using 在正常返回、break/continue、throw、finally 路径都正确清理。
- `const enum` 只在可证明常量和边界安全时内联。
- `core-es2020` 等 manifest 的 capability 闭包、ABI hash 和缺失项报告可在 `ts2bin doctor` 中复现。

## 阶段 5：runtime-heavy 语义与兼容层

### 目标

处理需要运行时协议或状态机的语法，同时把 dynamic/interop 与 static 核心隔离。这个阶段不应因为“能调用 runtime”就放宽 static 的拒绝规则。

### 工作项

1. 实现异常 ABI：throw、try/catch/finally、invoke/unwind、cleanup 和目标平台 personality。
2. 实现 `Promise<T>`、async/await 状态机、错误 continuation、top-level await（若模块 profile 开启）。
3. 实现 generator/`yield`/`yield*` frame；如果目标 runtime 不完整，保持默认 R。
4. 实现 BigInt、RegExp、Symbol、动态属性、`instanceof`、abstract equality 等独立 runtime 模块。
5. 标准 decorator 与 legacy decorator 分开，固定 metadata、initializer 和执行顺序。
6. JSX 先按 checker 解析 factory/fragment，再走普通调用；建立最小 JSX runtime。
7. dynamic profile：`DynamicValue`、属性字典、外部 JS/Node/FFI boundary、显式 checked cast 和诊断统计。
8. general static profile 默认接入非移动 tracing GC；ARC/arena 只实现为带无环证明和 capability 限制的受限 profile。

### 验收门槛

- 每个 runtime helper 都有明确 ABI、错误策略和版本号；没有隐式调用未声明 helper。
- async/exception/using 的所有退出边都有状态机/cleanup 测试。
- static 与 interop 的输出和诊断可区分；开启 dynamic 不改变静态模块中未触达代码的行为。
- `eval`、`with`、任意 Proxy、原型改写等仍按矩阵拒绝，除非专门实现并单独命名 profile。
- GC root、写屏障、异常、async frame 和 cleanup 的 ABI 都有 runtime contract 与行为测试，不能只通过链接检查。

## 阶段 6：LLVM 后端、优化、目标平台与产品化

### 目标

把经过 MIR verifier 的程序稳定生成 LLVM IR、目标文件和可执行产物，建立版本固定、差分测试、性能和发布流程。

### 工作项

1. 使用 `tinygo.org/x/go-llvm` 建立 backend context/module/builder wrapper；固定 LLVM 大版本，首版优先 LLVM 20。
2. 将 MIR 类型、block、phi、call/invoke、global、debug/source metadata 映射为 LLVM IR；每个函数生成后立即局部检查。
3. 运行 `VerifyModule`、PassBuilder/`default<O2>`，再用 TargetMachine 输出 bitcode/object/assembly。
4. 接入 `bingo-rt`，固定跨平台 calling convention、data layout、allocator、GC/写屏障、异常和线程模型。
5. 实现 incremental cache：source/config/frontend snapshot hash -> HIR/MIR/LLVM artifact；cache key 必须含 LLVM/runtime ABI 版本。
6. 做 TypeScript/JavaScript oracle 差分、LLVM verifier、fuzz、compile-fail、性能和二进制可复现测试。
7. 设计 Windows/WSL2、Linux、macOS 的构建矩阵；原生 Windows 的 cgo 绑定失败应给出明确环境诊断。
8. 按 [testing-conformance-and-release.md](testing-conformance-and-release.md) 接入 case manifest、Node/规范差分、fuzz、cache provenance 和可复现构建门禁。

### 验收门槛

- 所有发布样例 LLVM verifier 通过，`opt`、`llc`、linker 产生可运行文件。
- 同一输入、工具链和 runtime commit 可复现相同 LLVM/目标文件摘要。
- 失败分类清晰：TS 诊断、Bingo 子集拒绝、runtime ABI 缺失、LLVM/backend bug。
- 至少覆盖 x86-64 Linux 和一个第二目标；平台差异不能改变 TypeScript observable semantics。
- 发布 profile 的 handbook 交叉覆盖、标准库声明/成员 manifest、LLVM verifier、runtime ABI hash 和 artifact digest 全部可由 CI 报告追溯。

## 跨阶段测试策略

### 测试层次

1. parser/checker oracle：确认输入与 tsgo 诊断一致。
2. snapshot golden：确认符号、类型、flow 和 selected overload 稳定。
3. HIR/MIR golden：确认消糖、CFG、布局、variance 和 cleanup。
4. interpreter/runtime：快速测试字符串、容器、异常、Promise 和 iterator。
5. LLVM verifier/backend：确认 IR 合法、passes 不破坏 ABI、目标代码可运行。
6. differential：与 Node/TypeScript 发射结果比较允许的语义子集。

### 质量门禁

- 每个 R 规则都要有反例测试，防止后续“为了通过样例”误放开。
- 每次更新 tsgo commit 先运行 snapshot compatibility；Kind 增加或字段变化必须更新适配层。
- golden 变化需要说明源语义变化、上游变化还是编译器 bug 修复。
- fuzz 输入只允许进入 parser/snapshot 和显式 dynamic harness；不把任意 fuzz 程序直接当作可执行产物。

## 风险与应对

| 风险 | 影响 | 应对 |
| --- | --- | --- |
| tsgo `internal` API 变动 | 适配层频繁破坏 | 薄 fork、snapshot DTO、单一 facade、固定 commit |
| TS 动态语义过宽 | LLVM 代码错误但难定位 | static 默认拒绝，dynamic 显式边界并计数 |
| LLVM 版本/opaque pointer 差异 | 构建或 verifier 失败 | 固定大版本，backend contract tests，CI 多平台 |
| TypeScript 类型与运行时脱节 | 不安全布局/调用 | TsType/RepType 分层、MIR verifier、checked cast |
| 泛型代码爆炸 | 编译时间/二进制膨胀 | 按表示单态化、实例上限、共享引用版本 |
| 异常/async/GC 跨平台差异 | 运行时崩溃 | runtime ABI versioning、平台 feature gate、阶段性 R |
| 直接复用 JS emitter | 隐式 coercion 和动态对象泄漏 | emitter 只作 oracle，独立 HIR/MIR lowering |
