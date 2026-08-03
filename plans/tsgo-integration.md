# typescript-go 前端集成规格

本文把 `typescript-go` 的实际 API 约束固化成 ts2bin 前端契约。目标是让 `ast2bingo` 只依赖一个小型 facade；上游 AST/checker 变化不能扩散到 HIR、runtime 和 LLVM backend。

## 1. 版本和目录策略

第一版采用薄 fork，保留模块路径 `github.com/microsoft/typescript-go`：

```text
typescript-go/
  cmd/ts2bin/
  internal/tsfrontend/       # 本文定义的 facade
  internal/ast2bingo/
  internal/bingo/...
  internal/llvmbackend/
  runtime/bingo-rt/
```

`internal/tsfrontend` 是唯一允许同时导入 `internal/ast`、`internal/checker`、`internal/compiler` 和 `internal/tsoptions` 的 ts2bin 包。其他 Bingo 包只能读取 snapshot DTO。

版本锁文件建议为 `ts2bin.lock.json`：

```json
{
  "typescriptGoCommit": "5b1047d10d32e7d5b446be4de56b126ff42f82bb",
  "typescriptSemanticBaseline": "6.0",
  "stdlibManifestVersion": 1,
  "bingoIrVersion": 1,
  "runtimeAbiVersion": 1,
  "llvmMajor": 20
}
```

上游同步时按顺序运行：tsgo 全量测试、前端 snapshot golden、AST Kind 覆盖、标准库 manifest diff、Bingo conformance。任何一步变化都要分类为“上游语义变化、适配器变化、预期新增能力或回归”。

## 2. Program 构造链

生产实现应封装以下 tsgo 调用顺序：

```text
read tsconfig text
  -> tsoptions.ParseConfigFileTextToJson
  -> tsoptions.ParseJsonSourceFileConfigFileContent
     或 ParseJsonConfigFileContent
  -> compiler.NewCompilerHost(cwd, fs, bundled.LibPath(), ...)
  -> compiler.NewProgram(compiler.ProgramOptions{Host, Config, ...})
  -> program diagnostics
  -> per-file typed snapshot
```

约束：

- `cwd`、config path、source file path 全部规范化为绝对路径。
- `SourceFile.FileName()` 作为 canonical path 输入，再由 frontend 分配稳定 `FileId`。
- `bundled.LibPath()` 只决定声明文件来源，不代表 bingo-rt 已实现对应 API。
- project references、package.json exports/imports、Node ESM/CJS 判定全部复用 Program，不在 ts2bin 重写解析器。
- watch/incremental 模式使用 `UpdateProgram`/`ReuseProgram` 前先建立单独设计；首版 batch compiler 不混入可变 Program 生命周期。

## 3. 诊断闸门

前端依次收集并排序去重：

1. tsconfig parsing diagnostics。
2. syntactic diagnostics。
3. bind diagnostics。
4. program/global diagnostics。
5. semantic diagnostics。
6. ts2bin subset/capability diagnostics。

默认行为等价于强制 `noEmitOnError`：前五类存在 error 时不创建 HIR；第六类存在 error 时可以生成 snapshot 供调试，但不能进入 LLVM backend。

`.d.ts` 和默认 lib 文件参与 type checking，却不生成用户函数。ambient value 必须由 runtime manifest 或 FFI manifest 提供实现，否则报 `BINGO3001_EXTERNAL_BODY_MISSING`。

## 4. Checker 生命周期与并发

tsgo 的 `CheckerPool.GetChecker`/`GetTypeCheckerForFile` 返回 `(checker, done)`。checker 每次获取是独占的，且不允许并发访问。

正确模型：

```go
for _, file := range program.GetSourceFiles() {
    checker, done := program.GetTypeCheckerForFile(ctx, file)
    snapshot := captureFile(program, checker, file)
    done()
    snapshots = append(snapshots, snapshot)
}

// 这里开始不再访问 checker，可安全并行 lower。
parallelLower(snapshots)
```

生产代码必须使用 `defer done()` 或等价的单出口 helper，防止 panic/诊断提前返回后锁未释放。禁止：

- 把 `*checker.Checker`、`*checker.Type`、`*checker.Signature` 保存到 snapshot。
- 在 goroutine 间共享同一次 checker acquisition。
- 在 release 之后调用 `TypeToString` 或查询 symbol/type。
- 假设两个文件一定关联同一个 checker。

优化顺序应是“按 checker/file 分组串行 snapshot -> immutable snapshot 并行 lowering”，而不是并行调用同一个 checker。

## 5. Frontend facade

建议暴露以下内部接口：

```go
type Frontend interface {
    Build(ctx context.Context, req BuildRequest) (*ProgramSnapshot, []Diagnostic)
}

type BuildRequest struct {
    ConfigPath string
    Profile    Profile
    Target     TargetSpec
    Runtime    CapabilitySet
}

type ProgramSnapshot struct {
    SchemaVersion uint32
    Config        ConfigSnapshot
    Files         []FileSnapshot
    Modules       []ModuleSnapshot
    Types         []TypeSnapshot
    Symbols       []SymbolSnapshot
    Signatures    []SignatureSnapshot
    Diagnostics   []Diagnostic
    ContentHash   Digest
}
```

具体 facade 方法仅在实现包内部使用：

```text
typeOf(node)
contextualTypeOf(node)
symbolOf(node)
resolvedSymbolOf(node)
resolvedSignatureOf(call/new/tagged-template)
propertiesOf(type)
indexInfosOf(type)
typeArgumentsOf(type)
baseTypesOf(type)
returnTypeOf(signature)
typePredicateOf(signature)
resolvedModuleOf(import)
moduleFormatOf(file)
constantValueOf(node)
```

`TypeToString` 只用于诊断显示，绝不作为 cache key、类型相等或 dispatch identity。

## 6. Snapshot 数据模型

### 6.1 稳定 ID

| ID | 构造方式 |
| --- | --- |
| `FileId` | canonical path + project identity |
| `NodeId` | FileId + Kind + source span + deterministic occurrence |
| `SymbolId` | declaration set + escaped name + parent SymbolId |
| `TypeId` | frontend build 内部 dense id；持久化另存 canonical type hash |
| `SignatureId` | declaration NodeId + overload index + instantiated TypeId 列表 |
| `ModuleId` | resolved canonical file/package identity + resolution mode |

不要直接持久化 tsgo 自己的 `Type.Id()`/`Signature.Id()`；它们可在当前 acquisition 内去重，但未承诺跨版本和跨 Program 稳定。

### 6.2 FileSnapshot

```text
FileId, CanonicalPath, ContentHash, ScriptKind
IsDeclarationFile, IsExternalModule
ImpliedModuleFormat, ResolutionMode
Pragmas, TripleSlashReferences
RootNodes[], Imports[], Exports[]
```

### 6.3 NodeSnapshot

```text
NodeId, Kind, Span, ParentId, ChildIds[]
DeclaredTypeId, NarrowedTypeId, ContextualTypeId
SymbolId, ResolvedSymbolId, SignatureId
ConstantValue, ModifierBits, EvaluationFlags
```

不序列化 tsgo 内部 `FlowNode` 图。checker 已经在 `GetTypeAtLocation` 中应用 assignment、condition、call、loop 和 mutation 等 flow facts；NodeSnapshot 保存关键表达式处的 narrowed type，MIR builder 再按源结构建立自己的 CFG。

### 6.4 TypeSnapshot

```text
TypeId, TypeFlags, ObjectFlags
Kind: intrinsic | literal | object | tuple | union | intersection |
      typeParameter | indexedAccess | conditional | mapped | template | error
SymbolId, AliasSymbolId
ElementTypes[], TypeArguments[], BaseTypes[]
Properties[], CallSignatures[], ConstructSignatures[], IndexInfos[]
ConstraintTypeId, DefaultTypeId, Variance
CanonicalHash, DebugText
```

遇到 checker error type、wildcard、未完成实例化或无法稳定枚举的 object type时，标记 `NotLowerableReason`，不要伪造成 `any`。

### 6.5 SignatureSnapshot

```text
SignatureId, DeclarationNodeId, Flags
ThisParameter, Parameters[], MinArgumentCount, HasRest
TypeParameters[], InstantiatedTypeArguments[]
ReturnTypeId, TypePredicate
SelectedOverloadIndex, CallingConventionClass
```

## 7. tsconfig 兼容契约

| TypeScript 选项 | ts2bin 处理 |
| --- | --- |
| `strict` | 必须开启；关闭时报配置错误 |
| `strictNullChecks` | 必须开启，null/undefined 表示依赖它 |
| `strictFunctionTypes` | 必须开启；Bingo 还会执行更严格 variance 检查 |
| `noImplicitAny` | 必须开启；显式 any 也由 static profile 拒绝 |
| `target` | 影响 parser/default lib；不直接决定 LLVM CPU/ISA |
| `lib` | 决定可见声明；随后必须与 runtime capability manifest 求交集 |
| `module`/`moduleResolution` | 完全复用 Program 解析；Bingo 统一生成自身 ModuleGraph |
| `verbatimModuleSyntax` | 保留 type/value import 意图，建议开启 |
| `useDefineForClassFields` | 属于可观察 class field 语义，必须写入 snapshot 并遵守 |
| `experimentalDecorators` | 选择 legacy decorator；与标准 decorator runtime 分离 |
| `emitDecoratorMetadata` | 只有 runtime 支持 metadata capability 时允许 |
| `jsx`, `jsxFactory`, `jsxImportSource` | 决定 JSX lowering；对应 runtime 必须在 capability manifest 中 |
| `isolatedModules` | 不作为完整 Program 的必要条件；可用于单文件模式限制 |
| `sourceMap`/`inlineSourceMap` | 映射到 LLVM debug/source map 配置 |
| `declaration`/`emitDeclarationOnly` | 可委托 tsgo declaration emitter；与二进制生成分别控制 |
| `incremental`/`composite` | 后续映射到 snapshot/HIR cache；首版只读项目图 |
| `noEmit`/`noEmitOnError` | ts2bin CLI 自己控制；错误时永不生成 binary |

新增 `bingoOptions`：

```jsonc
{
  "bingoOptions": {
    "profile": "static",
    "runtime": "core-es2020",
    "llvmMajor": 20,
    "targetTriple": "x86_64-unknown-linux-gnu",
    "cpu": "generic",
    "features": [],
    "gc": "tracing",
    "exceptions": "llvm-eh",
    "overflow": "js-number",
    "boundsCheck": "on",
    "emit": ["hir", "mir", "llvm", "obj"]
  }
}
```

`gc=tracing` 是 general static profile 的默认值，因为普通对象、闭包和集合允许形成循环引用。`gc=arc` 只能由受限 profile 显式开启，并且必须经过无环、无弱引用、无 dynamic Proxy 的可证明性检查；无法证明时在 subset gate 报错，不得静默退化为泄漏语义。

## 8. AST Kind 与能力闸门

在 CI 中从 `kind_generated.go` 生成清单：

```text
source Kind -> SyntaxGroup -> SupportLevel -> LoweringHandler -> TestCase
```

规则：

- 新 Kind 没有 manifest 行：构建失败。
- S0/S1/S2 没有 handler 或正例：构建失败。
- R 没有拒绝诊断测试：构建失败。
- C 节点进入 MIR：verifier 失败。
- synthetic/error-recovery 节点进入用户 HIR：frontend bug。

## 9. ModuleGraph 构造

每条 import/export edge 保存：

```text
Importer ModuleId
Specifier text
ResolutionMode
Resolved canonical path/package
TypeOnly / Value / SideEffectOnly
ESM / CJS / JSON / external FFI
ImportAttributes
DeferredEvaluation
```

使用 `Program.GetResolvedModuleFromModuleSpecifier`、`GetModeForUsageLocation`、`GetEmitModuleFormatOfFile`、`GetImpliedNodeFormatForEmit`。文件扩展名、package.json `type`、exports/imports 和 Node 模式均以 Program 结果为准。

## 10. 上游隔离测试

最低测试集：

1. 每个 AST Kind 至少一个分类测试。
2. 每类 TypeFlags/ObjectFlags 至少一个 snapshot fixture。
3. overload、generic instantiation、type predicate、narrowing、module mode snapshot。
4. checker acquisition 泄漏测试：所有路径都调用 release。
5. 并发测试：release 后 snapshot 并行处理，不并发访问 checker。
6. tsgo commit 升级时 snapshot schema 和 canonical hash 差分。
