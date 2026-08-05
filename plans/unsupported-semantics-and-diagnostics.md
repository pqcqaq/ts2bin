# 不支持语义、拒绝策略与诊断规范

本文定义 ts2bin 在不能保持 TypeScript/JavaScript 可观察语义、不能证明本机布局安全或缺少 runtime/target 能力时如何停止编译。原则是“可解释地拒绝”，而不是静默擦除、退化为 `any`、生成 LLVM `undef` 或把失败推迟到链接/运行阶段。

## 1. Profile 不是全局豁免

### 1.1 static（默认）

只接受可静态类型化、可确定布局、可闭合链接的程序：

- 禁止 `any` 值传播和隐式 DynamicValue。
- 禁止动态作用域、任意原型修改、Proxy 和运行时代码生成。
- 所有 assertion、union projection、null dereference 和 indirect call 有证明或检查。
- 所有 runtime/host API 有 capability 和匹配 ABI。
- 所有泛型实例在 MIR 前具体化或由受约束 descriptor 承载。

### 1.2 interop

只在 manifest 声明的边界允许 `DynamicValue`、host object 和 checked adapter。每个边界在 HIR/MIR、诊断统计和 artifact provenance 中可定位。开启 interop 不会让项目内任意 `any`、Proxy、eval 或 prototype mutation 自动合法。

### 1.3 unsafe

只开放显式 `bingo:unsafe` intrinsic/FFI manifest，例如受约束的 pointer conversion 或 native buffer view。unsafe 操作仍必须满足 size、alignment、lifetime、GC pointer map、calling convention 和 target 规则。普通 `as any as T` 永远不会自动解释为 unsafe intrinsic。

### 1.4 dynamic（后续独立产品）

完整 dynamic object、prototype、coercion、Proxy 等需要独立 runtime 产品和 conformance。它与 static backend 共用 snapshot/HIR 的部分设施，但不是一个“忽略错误”开关。尚未实现 dynamic runtime 时，即使配置请求也报 capability unavailable。

## 2. Subset Gate 决策算法

每个 source file 在 snapshot 后、HIR 前执行四层扫描：

```text
GateNode(node, context):
  1. SyntaxGate: 该 SyntaxKind/组合在当前阶段有 handler 吗？
  2. TypeGate: resolved/narrowed type 能规范化并选择表示吗？
  3. SemanticGate: 求值顺序、动态行为、方差和断言是否可证明？
  4. CapabilityGate: runtime/host/target 是否提供完整 ABI 闭包？
```

结果只有：

```text
AcceptDirect
AcceptErase
AcceptDesugar
AcceptWithRuntime(capability)
AcceptWithCheckedBoundary(profile, capability)
DeferByFeatureGate(feature)
Reject(diagnostic)
```

`DeferByFeatureGate` 对用户仍是编译错误，只是诊断同时指出规划的 feature 名；它不能产生半成品 MIR。

### 2.1 拒绝时机

- parser/binder/checker 诊断优先，避免用 Bingo 错误遮盖无效 TS。
- AST/snapshot 完整性错误在 facade 阶段停止。
- unsupported/unsafe/type representability 在 subset gate 停止。
- specialization/variance 依赖具体实例时可在 HIR pass 停止。
- capability/target 依赖最终闭包时最迟在 capability binding 停止。
- MIR/LLVM verifier 失败属于编译器缺陷，不归类为用户“不支持语法”。

### 2.2 不可达代码

subset gate 默认审计所有会进入 emit 的声明和表达式，包括控制流上不可达代码。只有经过显式、确定且在 artifact 中记录的 compile-time elimination 后，完全不进入 HIR 的分支才可不要求 runtime capability。不能根据 LLVM 优化可能删掉某段代码来接受 unsafe/unsupported 行为。

`.d.ts`、type-only import、interface/type alias 等真正 compile-only 节点走 `AcceptErase`，但其 value declaration 或外部调用仍须 capability。

## 3. 必须拒绝的类型行为

### 3.1 `any`

static profile 拒绝：

- 变量、字段、参数、返回值或泛型实参解析为 `any`。
- 隐式 any、错误恢复 any、JS 文件产生的 any。
- any 进入 union/intersection/mapped/conditional 后影响 value layout。
- any property access、call、construct、spread、destructure、iteration、arithmetic。
- `Function`、`Object` 等过宽类型实际要求动态 call/property。

type-only 位置若 any 不影响任何 value、descriptor 或 public ABI，可以保留 tsgo 诊断策略后擦除；实现必须证明无 runtime use。

interop 只允许 manifest 边界把外部值显式表示为 DynamicValue；DynamicValue 不能隐式流回 static object/primitive。

### 3.2 未收窄 `unknown`

`unknown` 可作为安全边界输入，但以下使用前必须有 flow proof 或 checked conversion：property/element access、call/new、operator、destructure、spread、iteration、return 到具体类型。仅写 `as T` 不是 proof。

### 3.3 不可靠 assertion

以下默认拒绝：

```ts
const s = 1 as any as string;
const x = input as unknown as Concrete;
const y = obj as UnrelatedLayout;
const z = nullable!; // 没有 flow proof 或 checked assertion policy
```

实现按 [type-system-and-variance-algorithms.md](type-system-and-variance-algorithms.md) 收集完整 AssertionChain，穿过括号和 `satisfies`。允许条件只有：相同表示 proof、有定义 value conversion、真实 runtime descriptor/tag check 或显式受限 unsafe intrinsic。

`@ts-ignore`、`@ts-expect-error`、关闭 strict 选项不能把 Bingo unsafe cast 变为合法。

### 3.4 未实例化或不可表示类型

必须拒绝：

- type parameter 残留到 field layout、union payload 或 native call ABI。
- conditional/mapped/indexed/template literal residual 影响 runtime representation。
- generic recursion 产生无限增长 InstantiationKey。
- specialization/adapter 超过确定预算。
- union 没有封闭 member、稳定 tag/descriptor 或共同安全表示。
- intersection 的 property write type、private identity、class identity 或 layout 冲突。
- optional/missing/undefined 被错误压成同一无 tag 表示。
- runtime cast 目标只有 interface 结构而没有 descriptor/检查算法。

### 3.5 方差和别名安全

必须拒绝或显式转换：

- `Array<Dog>` 作为可写 `Array<Animal>` 共享。
- mutable tuple/property 使用 covariance。
- function 参数方向需要未经检查的 downcast。
- method bivariance 直接复用 ABI 不兼容函数指针。
- `out` 参数出现在写/输入位置，`in` 参数出现在读/输出位置。
- tsgo variance 为 `Unmeasurable`/`Unreliable` 却用于跨实例零成本转换。
- adapter 会改变可观察 identity/mutation，但调用点没有显式 copy/boundary。

## 4. 必须拒绝的动态语言行为

### 4.1 运行时代码和作用域

static、interop 和普通 unsafe 都拒绝：

- direct/indirect `eval`。
- `new Function`、`Function(...)` 和等价运行时代码构造。
- `with`。
- 从字符串/网络代码直接产生本机可执行函数。
- 依赖 `arguments.callee`、`caller`、函数源码字符串反射来控制行为。

这些行为改变词法作用域、module graph、调用图或安全边界，不能由单个 DynamicValue 适配。

### 4.2 Proxy 与反射 trap

static 拒绝：

- `new Proxy`、`Proxy.revocable`。
- 对 Proxy 可能到达的 property get/set/call/construct/has/delete/enumerate。
- 依赖任意 `Reflect.get/set/construct/defineProperty/deleteProperty` 的动态语义。

对固定 shape 的 `Reflect` 操作只有在 key、receiver、descriptor 和 effect 全部静态已知时可被专用 lowering；否则需要完整 dynamic object/proxy capability。

### 4.3 原型和 property descriptor

static 拒绝：

- `Object.setPrototypeOf`、`__proto__` 写入和运行时替换 class prototype。
- 向已冻结 shape 动态增删 property。
- 动态 `Object.defineProperty/defineProperties` 改 getter、setter、enumerable、configurable、writable。
- monkey patch 内置 prototype 或其他 module 导出的 class prototype。
- 依赖任意 property enumeration 顺序但对象 shape 不封闭。

固定 class inheritance、静态 method override 和编译期可知 descriptor 可支持，它们不是动态 prototype mutation。

### 4.4 动态 property 和 index signature

以下在 static shape 上拒绝：

- 未能常量化的 computed property name。
- 任意 string/symbol index signature 的读写。
- `delete obj[key]` 或固定 required field 的 delete。
- object spread/rest 来源 shape 不封闭或可能调用 Proxy/accessor 而没有 runtime capability。
- `for-in` 需要完整 prototype/enumeration 语义但对象不是受限 static object。

interop 中只有 dynamic object 类型能走 runtime dictionary；不能让一个 static object 在首次动态写入时偷偷改变 representation。

### 4.5 隐式 coercion

static profile 不模拟任意 `ToPrimitive`、`valueOf`、`toString` 和抽象相等：

- 对象参与 `+`、关系比较、模板/string conversion，除非静态选择了明确 capability。
- `==`/`!=` 的跨类型 coercion。
- symbol/string/number 的隐式互转。
- bigint 与 number 混算。
- 动态 truthiness 需要 DynamicValue。

TypeScript checker 通常会阻止一部分行为，subset gate 仍须覆盖 JS 输入、宽类型和 assertion 绕过路径。

## 5. 语法与声明的阶段性拒绝

### 5.1 Decorator

标准 decorator 只有在 metadata、initializer order、class replacement、access context 和 runtime capability 全部实现后支持。legacy decorator 与标准 decorator 是不同 feature，不能混用 emitter 语义。缺能力时在 decorator 节点拒绝；不能直接擦除，因为它有运行时副作用。

### 5.2 JSX

JSX 只有 factory/fragment/import source 已解析、props/children 求值顺序可保持且 factory capability 可链接时支持。namespaced JSX、动态 spread 到开放 props 或依赖框架专用 transform 的行为没有 manifest 时拒绝。

### 5.3 Enum/namespace/parameter property

这些会产生运行时代码：

- heterogeneous enum、computed member、反向映射需对应 lowering/runtime；不能一律擦除。
- namespace merging 需要稳定 init order；跨 module/global mutation 不明确时拒绝。
- parameter property 必须按 constructor/super/field init 顺序赋值。
- `const enum` 只有所有使用可在锁定 module graph 中安全内联时支持；preserve/isolated 外部边界不匹配时拒绝。

### 5.4 Import/export

static ESM 拒绝：

- 非字面量或无法解析闭包的 dynamic `import()`。
- dynamic `require`、运行时拼接 module path。
- CommonJS `export =` / `import = require`，除非显式 CJS interop loader。
- 未实现的 `import defer`、resource import attributes 或 top-level await。
- ambient/external module 只有声明而无 capability implementation。
- 模块解析结果依赖运行时搜索路径且未纳入 artifact manifest。

### 5.5 Generator/async/resource

缺少对应 runtime 时必须拒绝 `yield`、`yield*`、async generator、`await`、for-await、top-level await、`using`、`await using`。不能把 await 编译成阻塞等待，不能省略 IteratorClose 或 dispose/finally。

### 5.6 Delete、debugger 和特殊 meta

- `delete` 固定 required property、dynamic property、prototype property：static 拒绝。
- debugger 可在 release profile 擦除，在 debug profile 映射 trap；其存在不改变值语义。
- `new.target` 只在真实 construct ABI 上支持。
- `import.meta` 只暴露 manifest 声明字段；未知 host 字段拒绝。

## 6. Runtime 与标准库能力拒绝

`.d.ts` 是类型契约，不是实现。每个值调用都要找到 capability；以下缺失时拒绝：

- UTF-16 string、BigInt、Symbol、RegExp、Date、Intl/Temporal 实现。
- Array/Map/Set/iterator 的具体方法和 equality/order 语义。
- Promise/microtask/async iterator。
- WeakRef/FinalizationRegistry 和匹配 GC。
- TypedArray/DataView/SharedArrayBuffer/Atomics 及 target memory model。
- Disposable/SuppressedError。
- host DOM、Node、Deno、Bun API 和 native extension。
- Error stack、locale、timezone 等用户实际使用的可观察能力。

不能用同名 C/C++/OS 函数猜测兼容性。版本、签名、effects、encoding 和 ABI hash 任一不匹配都拒绝。

## 7. 对象与集合的特殊限制

### 7.1 Sparse Array

首版 dense static Array 拒绝会产生 hole 或依赖 hole 语义的操作：越过 length 写入、delete element、稀疏 literal、依赖 `map` 跳过 hole。若 runtime capability 实现 sparse array，可作为独立 representation；不能用 undefined 填充冒充 hole。

### 7.2 Equality 与 key

Map/Set 需要 SameValueZero；object key 使用 identity，string 使用 UTF-16 内容，number 正确处理 NaN 和负零。若 generic key 缺少合法 hash/equality descriptor，拒绝实例化，不能按地址或字节随意 hash。

### 7.3 Iterator mutation

集合迭代期间 mutation 的可观察顺序必须由 runtime 定义并测试。只有已知 dense array 且没有方法覆写/Proxy 时才优化成 index loop；否则缺 iterator capability 就拒绝。

## 8. Exception、GC 和 lifetime 拒绝

必须拒绝或视为 compiler defect：

- target 没有选定的 unwind/status exception model。
- throw value 不能装入 exception carrier。
- finally/cleanup edge 不完整，return/break/continue 绕过 cleanup。
- FFI call 的 ownership、callback lifetime、pin/handle 或 error contract 不明确。
- 活跃 GcRef 跨 safepoint 未进入 root map。
- object layout/descriptor 的 pointer bitmap 不一致。
- `gc=arc` profile 无法证明无环，或程序使用 WeakRef/finalization/dynamic Proxy。
- `gc=arena` 值逃逸 arena lifetime。
- external pointer 被当作 GC ref，或反之。

后五类若来自用户显式 unsafe/FFI 配置，给配置诊断；若由编译器正常 lowering 产生，标为 internal verifier failure 并停止产物发布。

## 9. Target 与 LLVM 拒绝

配置阶段拒绝：

- target triple/CPU/features 与已构建 runtime 不匹配。
- pointer width/endian/data layout 不受 runtime layout manifest 支持。
- target EH、TLS、atomic width、shared memory 或 object format 不满足所用能力。
- 外部 library/calling convention/struct ABI 无 manifest。
- 混链不同 runtime ABI、exception model、GC mode 或 public layout hash。
- LTO/optimization 配置会违反 JS f64、signed zero、NaN 或 unwind/root contract。

LLVM verifier、object emitter 或 linker 失败若不是明确的环境/缺失库问题，应报告 backend/internal 类，不改写成“该 TS 语法不支持”。

## 10. Profile 边界检查

每个 interop/dynamic/unsafe 边界都生成：

```text
BoundaryRecord {
  id
  sourceSpan
  kind          DynamicImport | HostCall | DynamicValue | UnsafeIntrinsic | FFI
  sourceType
  targetType
  conversion
  capability
  failureMode
  provenance
}
```

规则：

- opt-in 必须精确到 package/module/symbol 或 source construct，不能仅有全局 `allowUnsafe=true`。
- boundary input/output 都执行 ConversionPlan。
- checked failure 明确为 throw、Result/status 或 rejected Promise。
- artifact 汇总 boundary 数和位置，可被 CI 设置上限。
- boundary 不能跨 module public ABI 后失去标记。
- optimizer 不能消除仍有审计意义的 provenance metadata。

## 11. 诊断分类与编号

### 11.1 编号族

| 范围 | 分类 |
| --- | --- |
| `BINGO1000-1099` | snapshot/AST/subset handler |
| `BINGO1100-1199` | source type/flow |
| `BINGO1200-1299` | representation/layout/variance |
| `BINGO1300-1399` | assertion/dynamic/unsafe |
| `BINGO1400-1499` | generic/specialization |
| `BINGO2000-2099` | unsupported JavaScript semantics |
| `BINGO2100-2199` | module/decorator/JSX/modern syntax feature |
| `BINGO3000-3099` | runtime/stdlib capability |
| `BINGO3100-3199` | host/FFI/ownership |
| `BINGO3200-3299` | GC/EH/async/resource |
| `BINGO4000-4099` | target/LLVM/link/ABI |
| `BINGO9000-9099` | internal invariant/verifier failure |

已有稳定示例 `BINGO3003_HOST_API_UNBOUND` 保留在 3000 runtime/host 能力族；后续编号一旦发布不得换义。

### 11.2 Diagnostic schema

```text
Diagnostic {
  code
  severity
  category
  primarySpan
  messageKey
  arguments
  relatedSpans
  sourceType / targetType
  sourceRep / targetRep
  profile
  requiredCapability
  proofPath
  remediationKind
}
```

message 使用稳定 key + 参数生成本地化文本；golden 主要断言 code、span、key 和结构化字段，不依赖整段中文/英文字符串。

### 11.3 Severity

- `error`：无法生成语义正确产物；所有 Reject 都是 error。
- `warning`：显式 interop/unsafe boundary 的风险或成本，但只有配置已允许时使用。
- `note`：proof path、相关声明、需要 capability 和可行修改。

不允许把 unsupported/unsafe error 在 release profile 自动降为 warning。

### 11.4 推荐修复

诊断只给语义可靠的建议：

- 收窄 unknown、增加真实 predicate/check。
- 改用 ReadonlyArray/readonly property。
- 显式 copy/map 成目标可变容器。
- 为 FFI/host/runtime 添加 capability manifest。
- 改成静态 module path 或启用具体 loader。
- 避免 prototype/Proxy/eval，改用封闭接口。
- 为 generic 增加约束或减少递归实例化。

绝不建议“加 `as any`”“关闭 strict”“忽略诊断”。

## 12. 诊断稳定排序与去重

同一次构建先按诊断层排序：tsgo diagnostics、Bingo/BINGO-UNSAFE diagnostics、LLVM diagnostics；tsgo 层内再按 configuration/syntax/binding/program/global/semantic 阶段排序。每个层和阶段内按 canonical file path、start offset、end offset、diagnostic code、stable entity ID 排序。并行 worker 只提交结构化诊断，主线程排序。

去重规则：同一 code、primary span、entity/proof path 相同才去重。根因诊断可抑制直接派生的噪声，例如 unresolved capability 后不再为同一 call 报 LLVM symbol 缺失；但不能吞掉不同位置的 boundary。

tsgo diagnostic 先输出，随后 Bingo diagnostics；若 tsgo 已使节点无法形成可靠 snapshot，该节点只补一条 facade failure，不连锁产生 representation 错误。

## 13. 抑制与配置

- 普通 `@ts-ignore`/`@ts-expect-error` 只影响 tsgo 既有规则，不抑制 Bingo 安全/能力诊断。
- Bingo diagnostic 抑制必须使用项目配置中精确 code + path/symbol scope + 原因 + 过期条件。
- `BINGO9000` internal failure、GC/root、ABI mismatch、unsafe cast 和运行时代码生成类错误不可抑制。
- suppression 记录进入 artifact provenance 和 CI audit report。
- expired、未命中或范围过宽的 suppression 自身产生配置诊断。

首版可以完全不实现 source pragma suppression，以保持语义入口单一。

## 14. 代表性决策表

| 源行为 | static | interop | unsafe | 必要实现 |
| --- | --- | --- | --- | --- |
| `1 as any as string` | 拒绝 | 拒绝 | 拒绝 | 没有合法普通转换 |
| unknown + predicate | 支持 | 支持 | 支持 | flow/runtime proof |
| `Dog[] -> Animal[]` writable | 拒绝/显式 copy | checked dynamic array | 仍不直接允许 | invariance |
| `Dog[] -> readonly Animal[]` | 支持 | 支持 | 支持 | covariance proof |
| method bivariance | thunk 或拒绝 | checked thunk | ABI 仍校验 | function adapter |
| nonliteral dynamic import | 拒绝 | manifest loader | manifest loader | loader capability |
| host function | 拒绝（无 manifest） | checked FFI | explicit unsafe FFI | ABI/ownership manifest |
| Proxy/eval/with | 拒绝 | 当前仍拒绝 | 当前仍拒绝 | 独立 dynamic runtime |
| computed fixed key | 支持 | 支持 | 支持 | constant key proof |
| arbitrary property key | 拒绝 | DynamicObject only | DynamicObject only | dynamic object capability |
| standard decorator | feature/capability 决定 | 同左 | 同左 | decorator runtime |
| await | capability 决定 | 同左 | 同左 | Promise/scheduler/state machine |
| sparse array | 拒绝 | capability 决定 | 同左 | sparse array runtime |
| unsupported target atomics | 拒绝 | 拒绝 | 拒绝 | target/runtime support |

## 15. 审计输出

每次构建可生成 `support-report.json`：

```text
{
  profile,
  sourceHash,
  tsgoCommit,
  snapshotSchema,
  runtimeManifestHash,
  target,
  acceptedByKind,
  erasedByKind,
  desugaredByKind,
  capabilities,
  boundaries,
  suppressions,
  rejectedDiagnostics
}
```

release gate 要求 rejected 为空、所有 boundary 有 owner/manifest、suppression 符合策略、capability closure 和 ABI hash 完整。支持率不能只按 AST node 数统计；还要按语义专题、type feature、runtime capability 和 target 统计。

## 16. 测试规范

每个 Reject 分支至少有：

1. 最小 source case，单独执行只产生预期结构化诊断。
2. 相邻可支持正例，证明规则没有过度拒绝。
3. profile 变体；不允许的 profile 不能误放行。
4. 诊断 code/span/key/proof path golden。
5. 无 HIR/MIR/object/cache artifact 发布的断言。
6. 多文件/并发时稳定排序测试。

高风险专题必须做变形测试：给 assertion 加括号/`satisfies`、通过 alias/泛型隐藏 any、把 mutable container 嵌套多层、通过 method/closure/union 传播不安全类型，诊断仍必须命中根因。

capability negative test 使用独立 manifest，不能依赖开发机恰好安装的系统库。target negative test 使用显式 TargetContext fixture。所有测试遵守 [test-authoring-standards.md](test-authoring-standards.md)。

## 17. 新语法/能力进入支持集的门禁

一个原本 Reject/P 的能力只有同时完成以下事项才能改为支持：

1. 在 [typescript-support-matrix.md](typescript-support-matrix.md) 更新状态和 profile。
2. snapshot schema 能表达所需 tsgo 语义且有上游兼容测试。
3. HIR/MIR node、lowering 和 verifier 规则完成。
4. 求值顺序、异常、GC、variance 和 dynamic 边界完成设计审计。
5. 所需 capability/ABI 有实现、版本和 target closure。
6. positive/negative/golden/differential/fuzz 按风险完成。
7. 文档、diagnostic registry、support report 和 release manifest 同步。
8. 按 [compiler-development-process.md](compiler-development-process.md) 达到对应 A2/A3/A4 审计等级。

不得先把 gate 改成 Accept 再补 runtime 或 verifier。

## 18. 编译器内部失败

以下必须报告 `BINGO900x` 并停止：

- snapshot 引用了已 release checker 对象或未知 ID。
- handler 声称支持节点却返回空/未类型化 HIR。
- ConversionPlan 与实际 RepType 不一致。
- CFG dominance、phi、cleanup、root map、barrier 或 ABI verifier 失败。
- LLVM pre/post verifier 失败。
- 并发构建相同输入产生不一致 stable ID/layout/hash。

internal diagnostic 包含 crash stage、entity ID、artifact hash 和最小安全上下文；默认不输出用户源码全文、环境 secret 或绝对路径。编译器缺陷不能伪装成用户的 unsupported error，也不能发布目标文件。
