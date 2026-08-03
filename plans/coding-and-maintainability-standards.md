# ts2bin 代码可读性与可维护性规范

本文规定 ts2bin 的代码组织、抽象边界、注释、公共 API 文档和可维护性要求。目标是让编译器核心流程能够被新维护者按顺序读懂、被审计者定位语义责任、被测试稳定复现。

本规范适用于 Go 编译器代码、Bingo IR、runtime ABI/实现、LLVM backend、CLI、测试工具以及 TypeScript/JavaScript 测试 fixture。它与 [compiler-development-process.md](compiler-development-process.md) 配合使用；流程文档决定何时审计，本文件决定代码达到什么质量才能进入审计。

## 1. 总体原则

1. **核心流程优先可读性。** 编译器主路径应按业务阶段线性展开，读者可以从入口一路跟到诊断、snapshot、lowering、verifier 和 backend；不要为了“复用”把流程切成大量跳转。
2. **抽象必须有理由。** 不允许为了减少几行代码、追求形式上的 DRY 或预判未来需求而新增函数、接口、泛型 helper 或 `utils` 包。
3. **语义边界显式可见。** 类型转换、动态逃逸、分配、异常、cleanup、并发借用和 runtime call 必须在代码结构或注释中清晰出现，不能藏在无名 helper 里。
4. **公共契约先写文档。** 导出的类型、函数、方法、常量、CLI 命令和 runtime ABI 必须在实现合并前具有完整文档注释。
5. **注释解释原因和不变量。** 注释不能逐行翻译代码；必须说明求值顺序、所有权、生命周期、并发、失败策略、来源语义和不能改变的原因。
6. **小范围修改。** 一个变更只解决一个主问题；禁止把无关重命名、格式化、目录迁移和行为变更混在一起。
7. **可删除性。** 每个 helper、接口和抽象都应能回答“删除它会损失什么语义或复用”；无法回答则优先保持内联。

## 2. 抽象与函数封装规则

### 2.1 允许新增函数/类型的条件

新增函数、接口、类型或包，至少满足下列条件中的一项；满足两项以上才应优先考虑：

- 表达一个有名字的编译器语义，例如 `captureFileSnapshot`、`verifyDominance`、`lowerOptionalChain`。
- 在两个以上独立调用点复用，并且复用的是完整语义而不是几行相同语句。
- 集中维护一个必须一致的不变量，例如 checker release、source span 映射、ABI hash 校验、cleanup 栈平衡。
- 隔离一个明确的外部边界，例如 tsgo facade、LLVM C API、runtime FFI 或文件系统。
- 能够拥有独立的输入/输出契约和独立测试，不依赖调用者的隐式前置状态。

以下情况不得为了“封装”而抽取：

- 只有一个调用点，且抽取后需要跳转才能理解原流程。
- 只是把一行字段访问、一个条件判断或一条错误返回包装起来。
- 只是把不同阶段都叫作 `process`、`handle`、`doThing` 的通用 helper。
- 需要通过十几个布尔参数或巨大的 `Context` 才能工作。
- 为了未来可能复用而提前引入接口，但当前没有第二个实现。
- 把不同语义的代码塞进 `utils`、`common`、`helpers` 包以逃避归属决策。

### 2.2 核心流程必须保持线性

以下流程代码默认保持显式和线性，不得拆成没有语义名称的层层 wrapper：

```text
Program/config
  -> diagnostics
  -> checker borrow
  -> immutable snapshot
  -> subset gate
  -> HIR lowering
  -> HIR verifier
  -> MIR lowering
  -> MIR verifier
  -> capability binding
  -> LLVM backend
```

可以抽取的函数必须对应上面某一个完整阶段或一个明确不变量，并在调用点附近保留阶段顺序。主流程应能回答：输入是什么、何时获得 checker、何时 release、何时可以并行、哪一层负责拒绝、哪一层负责 cleanup。

### 2.3 函数长度与复杂度

不使用机械的“超过 N 行就必须拆分”规则。函数较长本身不是缺陷，隐藏语义才是缺陷。以下情况触发可读性审计，而不是自动抽取：

- 一个函数同时负责配置解析、诊断、语义查询、IR 构造和文件输出。
- 正常路径、拒绝路径、回滚/cleanup 路径混在同一层且无法通过局部注释区分。
- 嵌套控制流使读者无法判断资源释放或错误传播。
- 修改一个局部规则需要在多个 helper 间同步修改。

审计决定可以采用哪一种方式：保留线性代码并增加阶段注释、抽取有语义名字的阶段函数、引入独立对象，或拆分 issue。禁止仅以行数为理由制造包装函数。

### 2.4 Helper 的命名和契约

函数名必须表达语义和副作用：

- `capture...` 表示复制稳定数据，不应保存内部指针。
- `borrow...`/`release...` 表示生命周期配对；优先用返回 release 函数并在同一作用域 `defer`。
- `lower...` 表示语义转换，不是普通遍历。
- `verify...` 表示只读验证，失败必须说明不变量。
- `bind...` 表示连接 capability/ABI，不应偷偷生成 runtime 实现。
- `emit...` 仅用于生成文本、IR 或目标文件，不能同时修改源 AST。

禁止使用含糊的 `process`、`handle`、`convert`、`build` 作为所有阶段的统一命名；必须补充对象和阶段，例如 `lowerCallToHIR`、`verifyMIRCleanupEdges`。

## 3. 模块边界与依赖方向

```text
cmd/ts2bin
  -> compiler/orchestrator
  -> internal/tsfrontend (唯一 tsgo internal 入口)
  -> snapshot / subset gate
  -> ast2bingo / bingo HIR
  -> bingo MIR / verifier
  -> runtimeabi / capability registry
  -> llvmbackend
  -> runtime/bingo-rt
```

依赖规则：

- `internal/tsfrontend` 是唯一允许导入 tsgo `internal/ast`、`internal/checker`、`internal/compiler` 和 `internal/tsoptions` 的层。
- HIR、MIR、verifier、runtimeabi 和 LLVM backend 只能读取 snapshot/DTO，不能获取 checker 指针。
- runtime 实现不能反向依赖 AST、checker 或 CLI。
- 测试可以依赖被测层的公开测试接口，但不能为了测试方便导出生产内部状态。
- 新包必须写清 ownership、依赖方向和删除/合并理由；禁止循环依赖和跨层快捷调用。

## 4. 核心流程注释规范

### 4.1 必须写块注释的位置

以下位置必须有面向维护者的块注释，且注释应放在流程入口或复杂分支之前：

- Program 构造、诊断闸门、checker 借用与 release。
- snapshot 捕获和内部指针转稳定 ID 的边界。
- HIR -> MIR 的每个 normalization/lowering pass。
- variance adapter、checked cast、unsafe provenance 和 dynamic boundary。
- 模块循环依赖初始化、异常/cleanup 边、async/generator 状态机。
- GC root、write barrier、对象布局、字符串/TypedArray ABI。
- LLVM opaque pointer、calling convention、target data layout 和 runtime intrinsic 映射。
- 任何“看起来可以简化但不能简化”的代码，例如单次求值、getter 副作用、`finally` 顺序。

### 4.2 核心流程注释必须回答的问题

复杂代码前的注释至少说明：

1. 这一段处于编译流水线哪一阶段，输入和输出是什么。
2. 哪些源语言语义或不变量必须保持，例如单次求值、协变方向、cleanup 逆序。
3. 哪些指针、资源、checker 借用或 runtime root 在这里有效，何时释放。
4. 失败是用户诊断、能力缺失还是编译器 bug；是否允许继续 lowering。
5. 为什么不能直接复用 tsgo emitter、通用 helper 或 LLVM 默认行为。

示例：

```go
// CaptureFileSnapshot owns only stable DTOs. The checker is exclusive and
// must be released before the returned snapshot is lowered concurrently.
// Do not move HIR construction into this function: keeping the boundary here
// prevents checker pointers from escaping and makes snapshot determinism testable.
func captureFileSnapshot(...) (FileSnapshot, error) { ... }
```

不合格的注释：

```go
// Loop over files.
for _, file := range files { ... }
```

### 4.3 注释维护

- 修改行为、错误策略、生命周期或性能假设时，必须同时更新注释。
- 注释与代码冲突时视为缺陷；不能用“代码才是准的”跳过修复。
- 临时 workaround 必须写原因、触发条件、上游 issue/版本和移除条件，禁止无期限的待办标记。
- 不写编译器无法保证的承诺，例如“永远无分配”“一定内联”“所有平台一致”。

## 5. 公共函数和类型文档注释

### 5.1 导出规则

以下内容合并前必须有文档注释：

- Go 导出的 package、const、var、type、func、method、field。
- CLI 命令、配置字段、诊断 code、runtime ABI symbol 和 capability manifest 字段。
- Bingo HIR/MIR schema 中的公开节点、指令、属性和序列化字段。
- TypeScript/JavaScript 对外暴露的 runtime API、测试 runner API 和工具脚本入口。

Go 文档注释必须以被说明的标识符名称开头，并描述可观察契约，而不是只写实现动作。公开函数至少说明参数语义、返回值、错误、并发、生命周期、是否修改输入、是否可能分配/阻塞/抛异常。

### 5.2 公共 API 注释模板

```go
// BuildSnapshot builds an immutable program snapshot for req.
//
// The returned snapshot owns copied IDs and source spans only; it does not
// retain AST, Type, Signature, or Checker pointers. Checker access is
// exclusive during the call and is released before BuildSnapshot returns.
//
// BuildSnapshot returns diagnostics for invalid TypeScript or unsupported
// Bingo profiles. It does not lower to HIR and is safe for concurrent reads
// after the call completes.
func BuildSnapshot(ctx context.Context, req BuildRequest) (*ProgramSnapshot, []Diagnostic)
```

字段注释必须解释单位、合法范围、默认值、是否稳定持久化、是否参与 cache key 和线程安全要求。布尔字段不能以 `true/false` 代替语义命名；优先使用 `BoundsCheckMode`、`GCMode`、`Profile` 等枚举。

### 5.3 内部函数注释

未导出的简单函数不强制写长注释，但以下情况仍必须写：

- 名称无法表达完整的不变量。
- 代码依赖 TypeScript/ECMAScript 的反直觉规则。
- 代码处理所有权、并发、unsafe、异常边或跨层 ABI。
- 代码看起来可以删除、合并或改成更直观写法，但这样会破坏语义。

## 6. 错误、诊断和日志可读性

- 用户错误、能力缺失、环境错误和编译器 bug 使用不同 error type/code；禁止返回裸字符串让调用者猜类别。
- 错误必须包含 source span、节点/符号 ID、profile、目标表示或 capability 名称；不要只返回“invalid input”。
- 错误路径必须保持原始原因，使用 wrapping 保留上下文；禁止在低层静默吞错或重复打印。
- 日志不是诊断替代品。生产日志默认简洁，`debug/trace` 才输出 snapshot/IR 细节，并且不能泄漏不稳定地址。
- 错误排序必须稳定；不能依赖 map 遍历顺序、goroutine 完成顺序或机器路径。
- 编译器 bug 诊断要指向内部 artifact 和 issue，而不是伪装成用户 TypeScript 错误。

## 7. 并发、生命周期和资源

- 先保证顺序正确，再并行化；checker 借用阶段按 checker/file 分组串行，snapshot 之后才并行 lowering。
- 每一个获取资源的函数都必须有清晰的释放点；优先在同一作用域 `defer`，不要把 release 责任藏在远端调用者。
- 禁止共享可变全局状态；测试和 CLI 多次运行必须可重复。
- goroutine、线程、async frame、GC root、cleanup stack 和 LLVM context 的 ownership 必须在注释和类型契约中可见。
- 取消、超时和 panic 路径必须释放 checker、临时文件、runtime handle 和 LLVM资源。

## 8. 生成代码和外部绑定

- 生成文件头必须说明生成器、输入 commit/hash、生成命令和禁止手改原因。
- 修改生成器后必须重生成并检查 diff；不得只手工修生成结果。
- LLVM/go-llvm、FFI 和 runtime ABI wrapper 只能在边界层出现；业务代码不能散落 C API 调用。
- 外部 API 的 wrapper 必须写 ownership、空指针、错误、线程和版本假设；不要用 `unsafe.Pointer` 或裸 `i8*` 隐藏类型。

## 9. 可读性审计清单

- [ ] 主流程按编译阶段顺序可从入口读到出口。
- [ ] 没有只为减少重复行数而添加的 wrapper、接口或 `utils` helper。
- [ ] 新抽象有语义名称、边界契约和独立测试。
- [ ] 核心流程注释解释不变量、生命周期、失败策略和不能简化的原因。
- [ ] 所有导出 API、诊断、配置、IR 节点和 runtime symbol 有完整文档注释。
- [ ] 注释与代码、错误码、manifest、schema/ABI 版本一致。
- [ ] 没有隐式 checker 指针、动态逃逸、分配、异常或 cleanup。
- [ ] 变更没有夹带无关格式化、重命名或目录迁移。
- [ ] 新维护者可以仅凭代码、注释和关联设计文档写出测试。

## 10. 完成标准

代码只有同时通过以下条件才可进入实现审计：

1. 函数、类型和模块的抽象边界有明确理由。
2. 核心流程注释和公共 API 文档注释已经完成。
3. 错误、生命周期、并发和 ownership 契约可从代码中读出。
4. 代码没有用通用 helper 隐藏语义，也没有把不相关职责塞进一个巨型 context。
5. 可读性审计清单与测试、诊断、IR、manifest 变更一起提交。
