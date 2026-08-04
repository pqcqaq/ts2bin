# Bingo 类型系统、泛型与方差算法

本文规定 `typescript-go` 类型结果进入 Bingo HIR/MIR 后的实现算法。它不重新实现 TypeScript checker，也不把 checker 的“可赋值”结论等同于本机布局安全。所有类型转换必须依次回答两个问题：源语言是否允许，以及目标表示是否真的能安全读写和调用。

## 1. 边界与强制不变量

类型流水线固定为：

```text
tsgo Type/Signature
  -> immutable TypeSnapshot
  -> TsType canonicalization
  -> source assignability result
  -> RepType selection
  -> layout/call compatibility
  -> ConversionPlan
  -> HIR verifier
  -> specialization / adapter materialization
  -> MIR verifier
```

实现必须保持以下不变量：

1. `TsType` 描述 TypeScript 语义，`RepType` 描述运行时布局；二者使用不同 ID、不同 interner 和不同 verifier。
2. snapshot 完成后不得再次调用 checker 修补类型，不得保存 `checker.Type`、`Signature` 或内部 type data 指针。
3. checker 的 assignability 是必要条件，不是零成本 ABI 转换的充分条件。
4. 每个运行时值在进入 MIR 前都有唯一 `RepType`；只存在于类型层的实体没有伪造的 LLVM 值。
5. 可写容器和可写属性默认不变；只读输出位置才可协变，函数输入位置才可逆变。
6. `Bivariant`、`Unmeasurable`、`Unreliable` 不能作为直接复用本机函数指针或对象布局的证明。
7. `as`、non-null assertion 和泛型擦除不能改变位表示；改变表示必须产生显式转换、检查、复制、装箱或拒绝。
8. 类型规范化和实例化必须可终止，且输出由 source hash、tsgo commit、profile 和 manifest 唯一决定。

## 2. 核心数据模型

### 2.1 TypeSnapshot

每个被运行时代码引用的类型至少捕获：

```text
TypeSnapshot {
  id                 SnapshotTypeId
  flags              TypeFlags copy
  objectFlags        ObjectFlags copy
  symbolId           optional SymbolId
  aliasSymbolId      optional SymbolId
  aliasArguments     []SnapshotTypeId
  typeArguments      []SnapshotTypeId
  baseTypes          []SnapshotTypeId
  properties         []PropertySnapshot
  callSignatures     []SignatureSnapshot
  constructSignatures []SignatureSnapshot
  indexInfos         []IndexInfoSnapshot
  unionMembers       []SnapshotTypeId
  intersectionMembers []SnapshotTypeId
  literal            optional LiteralValue
  constraint         optional SnapshotTypeId
  defaultType        optional SnapshotTypeId
  varianceHint       []TsgoVariance
  source             SourceSpan
}
```

`PropertySnapshot` 必须包含读类型、写类型、optional/readonly 标志、getter/setter、可见性、`#private` identity 和声明顺序。不能只保存一个 property type，否则无法区分只读协变和读写不变。

`SignatureSnapshot` 必须包含 `this`、参数顺序、optional/rest、返回类型、类型参数、选中 overload、min argument count、throws/suspends effects 和调用约定。overload 集只用于调用解析；真正发射的是 checker 选定的实现签名。

### 2.2 CanonicalTsType

规范化类型使用显式变体：

```text
Primitive | Literal | Nullish | Never | Unknown | Any
TypeParam | Union | Intersection | Tuple | Array | Object
Function | Constructor | Class | Enum | UniqueSymbol
ConditionalResidual | MappedResidual | IndexedResidual
```

每个节点包含：规范化子类型 ID、qualifier、source provenance 和 `RuntimeUse`。`RuntimeUse` 取 `Erased`、`Value`、`DescriptorOnly` 或 `DynamicBoundary`，用于阻止 compile-only 类型意外进入 MIR。

### 2.3 RepType

首版允许的表示族：

```text
VoidRep, NeverRep, I1, I8, I32, U32, F64, USize
Utf16StringRef, BigIntRef, SymbolRef
ObjectRef(layoutId), ArrayRef(elementRep, mutability)
TupleRef(layoutId), FuncRef(abiSignatureId)
NullableRef(inner), TaggedUnionRef(layoutId)
DynamicValue, TypeDescriptorRef, ExternRef(abiId)
```

`null` 与 `undefined` 不能因都能用零表示而语义合并。若 `NullableRef` 需要同时区分有效值、`null`、`undefined`，使用两位 tag；只有证明其中一种状态不可能出现时才压缩。

### 2.4 ConversionPlan

所有赋值、传参、返回、phi 合并、字段写入和显式断言都生成统一计划：

```text
ConversionPlan {
  kind        Identity | Numeric | Retag | Box | UnboxChecked |
              NullCheck | UnionInject | UnionProjectChecked |
              ReadonlyView | Copy | FunctionThunk | ObjectAdapter |
              DynamicBoundary | Reject
  sourceTs    TsTypeId
  targetTs    TsTypeId
  sourceRep   RepTypeId
  targetRep   RepTypeId
  proof       ProofId
  effects     EffectSet
  provenance  ConversionProvenance
  diagnostic  optional Diagnostic
}
```

`proof` 指向可序列化证据：checker assignability、narrowing fact、相同布局、方差推导、runtime tag 或显式 profile capability。`Identity` 也必须有证据，不能靠两个 LLVM 类型碰巧相同。

## 3. 类型规范化算法

### 3.1 规范化入口

对每个 snapshot 类型执行：

```text
Canonicalize(typeId, substitution, mode):
  1. 解析 alias，但保留 alias provenance 用于诊断。
  2. 用 substitution 替换已实例化类型参数。
  3. 展开 checker 已解析的 indexed/conditional/mapped 结果。
  4. flatten union/intersection，去重，按稳定 TypeKey 排序。
  5. 应用 never、unknown、any、literal 和 nullish 化简规则。
  6. 规范化 object/signature/tuple 子节点。
  7. intern 结果并返回稳定 TsTypeId。
```

`mode` 区分 `TypeOnly`、`ValueLayout`、`CallABI` 和 `RuntimeCheck`。某个 conditional type 在类型展示中可以保留，但若 `ValueLayout` 仍得到 residual，必须拒绝。

### 3.2 稳定 TypeKey

TypeKey 不使用 tsgo 内存地址。它由 variant、规范化子 ID、readonly/optional qualifier、class identity、property key、signature shape 和 substitution key 编码。递归类型先分配临时 local ID，再对整个 SCC 计算结构 hash；序列化时按 module、declaration span 和结构 hash 稳定排序。

### 3.3 Union 化简

按以下顺序处理 `A | B`：

1. flatten 嵌套 union，删除 `never`。
2. 若存在 `any`，static profile 立即标记非法；interop profile 结果为显式 `DynamicBoundary`，不是普通 union。
3. 若存在 `unknown`，类型层结果为 `unknown`；值使用前仍需收窄。
4. 删除被同一 primitive 宽类型吸收的 literal，例如 `1 | number -> number`，但保留诊断 provenance。
5. 去重相同 canonical ID。
6. 在关闭 strict null checks 的输入上仍按 tsgo 配置记录 nullability；ts2bin static profile 默认要求 strict null checks，否则拒绝构建。
7. 计算表示候选，不能仅依据 TypeScript subtype 删除结构成员。

### 3.4 Intersection 化简

按以下顺序处理 `A & B`：

1. flatten、去重并删除类型层 `unknown`。
2. 任一成员为 `never`，结果为 `never`。
3. primitive 互斥、不同 literal 互斥或不同不可合并 nominal identity 时，结果为 `never`。
4. 合并 object property 契约；同名字段分别合并 read type 和 write type。
5. readonly 与 writable 相交不能凭类型层结果得到可写别名；布局计划保留更严格 mutability。
6. 多个 call signature 构成 overload set，不合成一个不安全的函数指针签名。
7. 若字段 offset、class identity、private identity 或调用约定无法统一，标记 `requiresAdapter`；没有可实现 adapter 时拒绝。

## 4. 运行时表示选择

### 4.1 RepType 选择算法

```text
SelectRep(tsType, useSite, profile):
  1. 若 RuntimeUse=Erased，返回 NoRuntimeValue。
  2. 若存在 unresolved type parameter，转入 specialization/descriptor 选择。
  3. primitive/literal 选择固定 primitive rep。
  4. nullish union 尝试 NullableRef 压缩。
  5. 同表示 union 尝试无 tag 表示，但只允许已有 flow fact 区分的局部值。
  6. 可稳定判别 union 选择 TaggedUnionRef。
  7. object/class/tuple/array 查询已冻结 LayoutId。
  8. function 查询 ABI signature 和 closure ABI。
  9. extern 查询 capability manifest。
  10. 其余仅在显式 interop profile 选择 DynamicValue，否则拒绝。
```

表示选择结果带 `LayoutReason`，至少记录 `DirectPrimitive`、`NullableCompression`、`DiscriminatedUnion`、`BoxedUnion`、`KnownShape`、`ClassIdentity`、`SharedGenericRep` 或 `DynamicProfile`。

### 4.2 Primitive 与 literal

| TsType | RepType | 特殊规则 |
| --- | --- | --- |
| `boolean` | `I1`，ABI 边界可扩为 `I8` | 不与 number 隐式互转 |
| `number` | `F64` | 保留 NaN、Infinity、负零；位运算单独 ToInt32/ToUint32 |
| numeric literal | `F64` | 常量传播可保留 APFloat bit pattern |
| `bigint` | `BigIntRef` | 与 number 混算拒绝 |
| `string` | `Utf16StringRef` | 长度是 UTF-16 code unit 数 |
| string literal | `Utf16StringRef` | 可 intern；identity 不参与相等语义 |
| `symbol` | `SymbolRef` | 相等按 runtime identity |
| unique symbol | `SymbolRef` + identity ID | identity 必须来自声明 |
| enum | underlying rep 或 enum object ref | 取决于成员和反向映射需求 |

`number` 不能因流分析看似为整数就全局改成 `i32`。局部优化可在 MIR 使用 narrowed integer value，但 public ABI 和可观察运算仍保持 `f64`。

### 4.3 Union 表示算法

候选优先级：

1. `T | null`、`T | undefined`：若 `T` 是非空引用，使用保留空值或 tag；若 `T` 为 scalar，使用 tag + payload。
2. discriminated object union：每个成员具有同一只读 literal discriminant，使用稳定 tag table + 最大 payload。
3. primitive 异构 union：使用 tag + 对齐后的 inline payload；大对象只存 GC 引用。
4. 同 class hierarchy：可使用基类 `ObjectRef`，但 runtime downcast 仍依赖 class descriptor。
5. 成员布局不封闭、discriminant 可写、存在 index signature 或 residual type：static 拒绝；interop 可用 `DynamicValue`。

tag 编号按 canonical member key 排序，不能随遍历顺序变化。若 union 对外导出，tag table 属于 ABI hash。对 union 的读取必须先由 flow fact、switch tag 或 checked projection 证明当前 member。

### 4.4 Object 与 optional property

对象布局算法只处理封闭 shape：

1. 收集继承、intersection 和本声明的 properties。
2. property key 规范化为 string/number/symbol identity；动态 computed key 不能进入固定布局。
3. 分离 data field、getter/setter、method slot 和 index contract。
4. 按 base layout、声明顺序、alignment 计算 offset；不要按字典序改变 JS 初始化顺序。
5. optional field 使用 presence bitmap；不能仅用 payload 零值代表缺失。
6. `readonly` 只限制可写入口，不改变 payload，但进入 LayoutId 和 variance proof。
7. `#private` 使用 class-private identity，不能与同名字符串字段合并。
8. 冻结 LayoutId 后禁止追加字段；扩展行为只能新建 shape 或进入 dynamic object。

snapshot 必须固化 `exactOptionalPropertyTypes` 和 `noUncheckedIndexedAccess` 的 checker 结果。前者决定 optional property 的写类型是否自动包含 `undefined`，后者决定未证明 index 读取是否包含 `undefined`；ast2bingo 只消费已区分的 read/write/narrowed type，不能自行用一个“可选类型”同时替代二者。

开放 index signature、动态 property descriptor、prototype mutation 和 Proxy 不能伪装成固定 shape。

## 5. 双层兼容性判定

### 5.1 SourceAssignable

snapshot 必须保存调用点或赋值点的 checker 结论及选中签名。ast2bingo 不重写完整 TypeScript relation 算法；它只验证：

- tsgo 没有相关 semantic diagnostic；
- source/target TypeId 与 snapshot 记录一致；
- assertion 位置没有绕过正常 assignability；
- narrowing fact 在该 source span 有效。

若 checker 允许历史兼容行为，例如 method bivariance 或 array covariance，结论标记 `SourceCompatibleOnly`，继续进入布局判定。

### 5.2 RepresentationCompatible

布局关系返回：

```text
SameBits
WideningValueConversion
ReadonlyView
CheckedProjection
CopyRequired
ThunkRequired
ObjectAdapterRequired
DynamicBoundaryRequired
Incompatible
```

判定顺序：

1. 比较 RepType family、size、alignment、GC pointer map 和 ABI signature。
2. 对引用类型比较 class identity/LayoutId/descriptor contract。
3. 对 writable location 验证双向可赋值和相同 store representation。
4. 对 function 验证参数逆变、返回协变、effects、calling convention 和 closure environment。
5. 对 union 验证 tag mapping 和 payload mapping。
6. 对 extern 验证 capability version 和 ABI hash。

### 5.3 最终决策表

| SourceAssignable | RepresentationCompatible | 结果 |
| --- | --- | --- |
| false | 任意 | 普通 TypeScript 诊断或 `BINGO1101_SOURCE_NOT_ASSIGNABLE` |
| true | SameBits | `Identity` |
| true | 可证明转换 | 明确 `ConversionPlan` |
| true | Copy/Thunk/Adapter | 生成具名 adapter，并记录成本 |
| true | DynamicBoundaryRequired | 仅显式 interop 边界允许 |
| true | Incompatible | `BINGO1201_REPRESENTATION_MISMATCH` |

`unsafe` profile 也不能把任意位模式当作任意对象。unsafe 只开放有明确 intrinsic 和 provenance 的操作，GC pointer map、alignment 和调用约定仍必须正确。

## 6. 方差模型

### 6.1 极性代数

类型参数出现位置使用四态极性：

```text
Unused       未出现
Positive     只产生值，协变位置
Negative     只消费值，逆变位置
Both         同时读写或跨不透明边界，不变位置
```

组合规则：

| 操作 | Unused | Positive | Negative | Both |
| --- | --- | --- | --- | --- |
| negate | Unused | Negative | Positive | Both |
| join with Positive | Positive | Positive | Both | Both |
| join with Negative | Negative | Both | Negative | Both |
| join with Both | Both | Both | Both | Both |

顶层类型参数以 `Positive` 开始。进入函数参数时 negate；进入函数返回、readonly property、Promise resolved value 时保持；进入可写 property、可变 array/tuple element、inout/指针未知操作时变为 `Both`。

### 6.2 构造器传播规则

| 类型构造 | 子类型参数极性 |
| --- | --- |
| `readonly p: T`、getter result | 保持 |
| `p: T` 可读写、getter+setter | `Both` |
| setter argument | negate |
| function parameter | negate |
| function return | 保持 |
| mutable `Array<T>` / mutable tuple item | `Both` |
| `ReadonlyArray<T>` / readonly tuple item | 保持 |
| `Promise<T>` resolved result | 保持；executor/callback ABI 另行递归 |
| `Map<K,V>` | K、V 均 `Both` |
| `ReadonlyMap<K,V>` | K 按 lookup 输入为 Negative，V 为 Positive；整体通常不提供任意 K 的跨类型零成本转换 |
| conditional/mapped residual | `UnknownVariance`，不得猜测 |
| explicit dynamic/extern opaque | `UnknownVariance` |

联合和交叉对每个 member 传播当前 polarity，再 join。optional/nullability 不改变极性。类型谓词中的参数既影响控制流又可能由实现读取，按真实签名和 runtime check 分别计算。

### 6.3 递归类型的 SCC 固定点

方差不能用一次 DFS 处理递归泛型。实现算法：

1. 为每个 generic declaration 的每个 type parameter 建图节点。
2. 扫描字段、签名、base type 和约束，建立带 polarity transform 的依赖边。
3. 用 Tarjan 算法求强连通分量。
4. SCC 初值为 `Unused`；按稳定 declaration order 重复传播并 join。
5. 由于格只有四个元素，每个节点最多单调升级三次，必然收敛。
6. 遇到 residual conditional、unresolved indexed access、动态 descriptor 或 tsgo `Unmeasurable/Unreliable`，将相关节点标为 `UnknownVariance`。
7. `UnknownVariance` 在布局判定中等同于不允许跨实例零成本转换，但不妨碍同一实例内部使用。

伪代码：

```text
for scc in dependencyOrder:
  state[param] = Unused
  repeat:
    changed = false
    for occurrence in stableOccurrences(scc):
      p = apply(occurrence.context, state[occurrence.dependency])
      changed |= joinInto(state[occurrence.owner], p)
  until !changed
```

### 6.4 tsgo variance hint 的使用

tsgo 的 `getVariancesWorker` 通过 super/sub marker 的双向 assignability 推导 covariance、contravariance、bivariance 和 independence，并传播 `Unmeasurable`、`Unreliable`。Bingo 将其作为兼容性 hint 和差分 oracle：

- tsgo 与 Bingo 都为 covariance/contravariance/invariance：可继续做布局验证。
- tsgo 为 bivariance、Bingo 为 negative/both：按 Bingo 结果生成 thunk 或拒绝。
- tsgo 为 covariance，但 Bingo 发现 mutable field/array：Bingo 为 invariant。
- tsgo 为 unmeasurable/unreliable：禁止 direct ABI reuse。
- 显式 `in`/`out` 仍要用实际 occurrence 复核，不能只相信 annotation。

### 6.5 显式 `in` / `out` 验证

| 标注 | 允许的推导结果 | 冲突 |
| --- | --- | --- |
| `out T` | Unused、Positive | Negative/Both 报错 |
| `in T` | Unused、Negative | Positive/Both 报错 |
| `in out T` 或无标注要求不变 | 任意，但跨实例按 invariant | 无自动放宽 |

若 tsgo 已产生 annotation diagnostic，直接停止。若 TypeScript 允许某种结构但 Bingo layout 发现隐藏写位置，发出 Bingo 布局诊断并指出从 type parameter 到写位置的最短 occurrence path。

## 7. 函数、方法与 adapter

### 7.1 函数兼容算法

将函数赋值 `SourceFn -> TargetFn` 时：

1. `this` 参数按普通输入参数逆变检查。
2. Target 的每个可调用参数必须能安全转换后传给 Source，方向是 `TargetParam -> SourceParam`。
3. Source 返回值必须能转换为 Target 返回值，方向是 `SourceReturn -> TargetReturn`。
4. optional/rest/min argument count 必须保证 Target 允许的每次调用都能被 Source 接受。
5. Source effects 不得超过 Target contract：不能把可能 throw/suspend/allocate 的函数当作禁止该 effect 的函数。
6. calling convention、exception ABI、closure environment 和 GC root contract 相同才可 direct reuse。

### 7.2 method bivariance

TypeScript 为部分 method 位置保留 bivariance。Bingo 不直接 bitcast 函数指针，而生成：

```text
Target ABI caller
  -> generated thunk
       -> per-argument checked/copy conversion
       -> Source method call
       -> return conversion
```

若任一参数只能通过不受控 downcast 转换，static profile 拒绝；interop profile 可生成 runtime checked cast，失败行为必须是明确异常或 `Result`，不能产生未定义行为。

### 7.3 ObjectAdapter

结构化对象跨布局使用 adapter view：

- 只读字段可保存 source object + offset/accessor mapping。
- 方法保存 thunk table，并正确绑定 receiver。
- optional field mapping 保留 presence bit。
- 可写字段只有 source 与 target 写类型等价且 store representation 相同时允许 view；否则必须复制成新对象或拒绝。
- adapter identity、equality 和 mutation 可观察时必须在语言 profile 中定义；首版 static 优先拒绝会改变 identity 的隐式复制。

adapter 不能绕过 class private/protected identity，也不能假装实现缺失的 runtime descriptor。

## 8. 可变与只读容器

### 8.1 Array

`Array<S> -> Array<T>` 只有 `S` 与 `T` 在读写两个方向都表示兼容时才是 identity。即使 tsgo 允许 `Dog[] -> Animal[]`，Bingo 也拒绝别名转换，因为调用方随后可能写入 `Cat`。

允许的替代：

- `Array<Dog> -> ReadonlyArray<Animal>`：协变 readonly view，不暴露写入口。
- 显式 `map/copy` 到 `Array<Animal>`：分配并逐元素转换。
- interop dynamic array：每次 read/write runtime check，并记录 dynamic boundary。

### 8.2 Tuple

- readonly fixed tuple 按每个元素协变，optional/presence 布局必须兼容。
- mutable fixed tuple 每个可写元素不变。
- rest element 继承容器 mutability。
- tuple length literal 只在类型层存在，但 fixed layout 与 variable array layout 不可 identity bitcast。
- named tuple label 不影响 ABI，仍保留在诊断和 debug metadata。

### 8.3 Map/Set 和 iterator

可变集合默认不变。只读 view 的方差取决于实际 API：只要类型参数出现在 lookup/callback 输入位置，就不能简单声明全协变。Iterator 的 element 输出可以协变，但 `next(input)` 的 input type 必须逆变；generator 同时包含 yield、return、next 三个独立方向。

## 9. 泛型实例化

### 9.1 实例化键

```text
InstantiationKey {
  genericDefinitionId
  canonicalTypeArguments
  representationClasses
  effectProfile
  targetAbi
  runtimeAbiHash
}
```

不能只按 RepType 共享实例：两个 object 都是 `ObjectRef`，字段 layout、descriptor、write barrier 和 method set 仍可能不同。共享前必须证明函数体只执行 representation-polymorphic 操作。

### 9.2 单态化算法

1. 从 exported entry、module init 和 address-taken function 建立 root worklist。
2. 对调用点读取 snapshot 中 checker 选定的 type arguments；不在后端重新推断。
3. canonicalize substitution，构建 InstantiationKey。
4. cache miss 时先登记 `InProgress` 递归哨兵条目，阻断递归无限展开。
5. 用 substitution 克隆 HIR 类型引用，重新选择 RepType 和 ConversionPlan。
6. 验证实例 HIR，lower 到 MIR，再发现新的实例化请求。
7. 所有依赖完成后把 cache entry 置为 `Complete`；失败置为带稳定诊断的 `Rejected`。

递归调用同一 key 复用 `InProgress` 符号。若 key 持续增长，例如 `F<T> -> F<T[]>`，由 budget 拒绝。

### 9.3 实例化预算

预算属于 compiler profile，并写入 artifact provenance：

- 单个 generic definition 的 unique key 数。
- 整个 module graph 的实例总数。
- type nesting depth 和 canonical node 数。
- adapter/thunk 总数。
- 单个实例生成的 MIR block/instruction 数。

超过预算报确定性诊断，列出最短实例化链和最大的 key，不允许静默改成 `any` 或裸 `i8*`。

### 9.4 表示共享与 descriptor

仅当所有操作可通过统一 ABI 表达时共享实现，例如只传递、不解引用的 GC reference。共享函数增加 `TypeDescriptorRef` 参数，descriptor 至少提供 size、alignment、pointer map、copy/equality/hash/drop 和 runtime type identity。需要静态 field offset、unboxed arithmetic 或具体 vtable 的实例必须单态化。

dictionary/descriptor 路径不是动态逃生口：其允许的操作由 generic constraint 生成，未在 constraint 声明的 property/method 不能运行时查找。

## 10. Assertion、cast 与 narrowing

### 10.1 转换分类

每个 `as`、angle-bracket assertion、non-null assertion、FFI cast 归一为：

- `ProofOnly`：checker/flow 已证明，RepType 相同。
- `ValueConversion`：有定义的数值、enum、string 或 union 转换。
- `CheckedCast`：runtime descriptor/tag/class identity 检查。
- `UnsafeIntrinsic`：显式配置允许的受限底层操作，保留 provenance。
- `RejectedAssertion`：只改变静态名字但没有表示证明。

### 10.2 双重断言检测

不能只匹配文本 `as any as`。对表达式建立 `AssertionChain`，穿过 parentheses、`satisfies` 和 compile-only wrapper，记录每一步 source/target、top-like 类型和 flow proof：

```text
CollectAssertionChain(expr):
  while expr is assertion/non-null/parenthesized/satisfies:
    append step
    expr = inner expression
  return base expression + ordered steps
```

若链中经过 `any`，或经过未收窄 `unknown` 后到不相同表示，static profile 报 `BINGO1301_UNSAFE_ASSERTION_CHAIN`。`as unknown as T` 只有在中间存在真实 runtime predicate、class descriptor check 或可证明 discriminant narrowing 时才允许。

### 10.3 non-null assertion

- 当前 flow type 已排除 null/undefined：擦除并记录 proof。
- RepType 使用 nullable tag，但没有 flow proof：若 profile 允许 checked assertion，生成 null check 和明确异常。
- public/FFI 边界上的无证明 `!`：默认拒绝，避免把外部空指针变成 LLVM UB。

### 10.4 Flow narrowing

snapshot 为每个表达式保存 checker 的 narrowed type。HIR 同时记录产生 proof 的条件，例如 tag comparison、`typeof`、`instanceof`、null check、`in` 或 user predicate。MIR verifier 要求 checked projection 被 proof block 支配；赋值、未知 call、closure escape 或 dynamic write 会杀死相关 fact。

user-defined type predicate 不能只信返回类型：被编译的函数体必须实现实际检查，外部 predicate 必须由 capability manifest 标为 trusted 或在边界插入 runtime check。

## 11. Overload 与调用类型

调用点只使用 snapshot 的 `SelectedSignatureId` 和 inferred type arguments：

1. lower callee/receiver 一次。
2. 验证选中 signature 属于该 symbol 的 overload set。
3. 按选中签名规划 argument conversions，仍保留源码参数求值顺序。
4. optional/default/rest 在 callee ABI 入口规范化。
5. 返回值按选中签名而非 implementation 宽类型进入 HIR。

若调用依赖仅在 `.d.ts` 存在的 overload，而 runtime implementation/capability 没有兼容 ABI，报 capability/ABI 诊断，不能选择另一个“差不多”的 overload。

## 12. 类型级语法的处置

以下通常由 checker 求值后擦除：type alias、interface、`keyof`、indexed access、conditional、mapped、template literal type、infer、utility type、`typeof` type query、import type、`satisfies`、variance annotation。擦除条件是所有 value use 已得到 concrete canonical type 和 RepType。

以下残留情况必须拒绝：

- value layout 中仍有未替换 type parameter。
- conditional/mapped/indexed residual 影响字段、tag、size 或调用 ABI。
- template literal type 被当作自动 runtime validator。
- interface 只有声明而 runtime cast 需要 descriptor。
- declaration merging 产生的 value side 没有 module/runtime 实现。
- `any` 被 utility type 或 conditional type 间接带入值布局。

## 13. 缓存、确定性和并发

- CanonicalTsType、RepType、variance 和 instantiation cache 都按 immutable snapshot 工作，可并行读取。
- interner 分配不能依赖 goroutine 调度；先并行构建 local graph，再按 stable key 合并和编号。
- variance SCC 以 generic definition 为粒度，可并行计算互不依赖的 SCC component。
- 相同 InstantiationKey 只允许一个 builder；其他任务等待 immutable result，不读取半成品 MIR。
- cache key 必须包含 tsgo commit、snapshot schema、Bingo IR schema、target ABI、profile 和 runtime manifest hash。

## 14. Verifier 规则

HIR type verifier 至少检查：

- 每个 value expression 同时具有有效 TsTypeId 与 RepTypeId。
- Erased 类型没有 runtime operand。
- residual 类型没有进入 layout/call ABI。
- writable property/array conversion 没有使用 covariance proof。
- assertion chain 有 ConversionPlan 和 provenance。
- union projection 有支配当前 use 的 narrowing proof。
- function identity reuse 通过完整 ABI/effect 检查。
- explicit variance annotation 与 occurrence path 一致。

specialization verifier 至少检查：

- 所有 type parameter 已替换或由 descriptor 合法承载。
- 没有 `InProgress` cache entry 泄漏到产物。
- recursive key 有终止证明或 budget 诊断。
- adapter/thunk 没有调用自身形成无进展转换环。
- public symbol 的 representation 和 ABI hash 已冻结。

## 15. 诊断要求

类型诊断必须包含：source/target TsType、source/target RepType、source span、转换上下文、checker 结论、Bingo 拒绝原因和最短 proof/occurrence path。典型代码：

| Code | 含义 |
| --- | --- |
| `BINGO1101` | source type 不可赋值 |
| `BINGO1201` | TypeScript 可赋值但运行时表示不兼容 |
| `BINGO1202` | mutable container 需要 invariance |
| `BINGO1203` | function parameter/return ABI 不满足方差 |
| `BINGO1204` | variance unmeasurable/unreliable |
| `BINGO1301` | 不可靠 assertion chain |
| `BINGO1302` | 未证明的 non-null assertion |
| `BINGO1401` | 泛型实例化残留未解析类型 |
| `BINGO1402` | 泛型实例化预算超限 |
| `BINGO1403` | descriptor 能力不足 |

诊断完整策略和 profile 行为见 [unsupported-semantics-and-diagnostics.md](unsupported-semantics-and-diagnostics.md)。

## 16. 最低测试矩阵

每条算法同时需要 positive、negative、HIR、MIR 和 runtime/LLVM 证据：

| 专题 | 必测用例 |
| --- | --- |
| primitive | NaN、负零、i32 位运算、bigint/number 拒绝 |
| nullability | null/undefined 分离、flow proof、错误 non-null |
| union | discriminant、tag 稳定性、checked projection、不可表示 union |
| object | optional presence、readonly view、getter/setter、private identity |
| array/tuple | readonly covariance、mutable invariance、显式 copy |
| function | 参数逆变、返回协变、method thunk、rest/optional/effects |
| recursive variance | self recursion、mutual SCC、unreliable residual |
| generic | direct monomorphization、recursive key、descriptor share、budget failure |
| assertion | `as any as`、`as unknown as`、真实 predicate、FFI checked cast |
| determinism | 不同并发度产生相同 type/layout/adapter IDs 和 ABI hash |

测试必须遵守 [test-authoring-standards.md](test-authoring-standards.md)：每个 case 独享 workspace 和 cache，可单独、乱序、重复及在声明安全时并行运行。
