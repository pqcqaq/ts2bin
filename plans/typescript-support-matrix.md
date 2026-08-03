# TypeScript 语法与语义支持矩阵

本矩阵以本地 `typescript-go/internal/ast/kind_generated.go` 的节点集合和 TypeScript 6.0 语义为审计基线。它把“语法能被 parser 接受”和“ts2bin 能安全生成本机代码”严格分开。

## 1. 支持级别与 profile

| 标记 | 含义 |
| --- | --- |
| S0 | 第一版静态子集，直接进入 Bingo HIR/MIR |
| S1 | 前端消糖后支持；源节点不进入最终 HIR |
| S2 | 依赖 runtime、状态机、对象模型或 ABI |
| C | 只参与类型检查/常量求值，最终擦除 |
| P | 设计保留，默认关闭，后续阶段实现 |
| R | 默认拒绝；不能用普通 TypeScript 类型擦除掩盖风险 |

配置 profile：

- `static`：默认；禁止隐式 dynamic、禁止不可靠断言，优先 LLVM 优化。
- `interop`：允许显式 `DynamicValue` 边界、外部 JS/宿主函数和 runtime cast；所有边界产生警告/计数。
- `unsafe`：只允许显式 `unsafeCast`/FFI 配置，不把 `as any as T` 自动升级成 unsafe。

## 2. 词法、字面量与操作符

| 语法/节点 | 级别 | 处理与限制 |
| --- | --- | --- |
| 标识符、私有标识符 `#x` | S0/S2 | 普通名称直接绑定；`#x` 使用 class-private slot，不降为公开字符串属性 |
| `number`、十六进制/二进制/八进制、科学计数 | S0 | 常量解析为 `f64`；整数上下文必须显式转换 |
| `bigint` 字面量 | S2 | 进入 BigInt runtime；禁止与 `number` 混算 |
| 字符串、转义、Unicode 转义 | S0/S2 | 采用 UTF-16 code unit string ABI；常量可静态驻留 |
| `true`、`false`、`null`、`undefined` | S0 | 保留独立类型与 nullish 标签 |
| 正则字面量 | S2 | `RegExpRef` + runtime；首版可限制 flags/Unicode 版本 |
| 模板字符串/模板 span | S1/S2 | 无插值静态拼接；有插值降低为 `StringBuilder`/runtime format |
| JSX 文本 | S1 | 由 JSX lowering 转普通字符串/子节点参数 |
| `+ - * / % **` | S0/S2 | 先按静态类型选 f64/整数/字符串路径；不模拟任意 JS coercion |
| `<< >> >>> & | ^ ~` | S0 | 生成显式整数转换、截断和移位规则；`number` 先转 u32/i32 |
| `=== !==` | S0/S2 | 静态同表示值比较；对象/函数/symbol 由 identity 比较 |
| `== !=` | S2/P | static 默认 R；interop 调用 abstract-equality runtime |
| `< <= > >=` | S0/S2 | 同域比较；跨 string/number 只在显式转换或 interop |
| `!`, `&&`, `||` | S0/S1 | `!` 只接收 bool；逻辑运算短路并保留值类型 |
| `??`, `?.` | S1 | nullish 分支，receiver/左值只求值一次 |
| `=`, `+=` 等复合赋值 | S1 | 保存左值地址，读-运算-写；禁止重复执行 getter/key |
| `++`, `--` | S0 | 只允许可写数值位置；按前置/后置值生成临时值 |
| `in`, `instanceof` | S2 | `in` 需要对象属性 runtime；`instanceof` 需要 class/prototype ABI |
| `typeof`, `void`, `delete` | S1/S2/R | `typeof` 对静态值可折叠；`void` 变 undefined；任意 `delete` 默认 R |
| `,`、括号、条件表达式 | S1 | comma 保留副作用顺序；条件表达式生成 branch/phi |
| `...` spread/rest | S1/S2 | 已知数组/对象使用静态复制，dynamic 对象调用 runtime helper |
| `new.target`、`import.meta` | S2/P | 分别映射构造器上下文和模块 metadata；无目标 ABI 时 R |

## 3. 声明、修饰符与绑定

| 语法/节点 | 级别 | 处理与限制 |
| --- | --- | --- |
| `const`、`let` | S0 | 局部 slot/SSA；`const` 只限制源级赋值，不等于 LLVM immutable |
| `var` | S1 | 降到函数 frame，显式处理 hoisting 和初始 undefined；建议 lint 警告 |
| 对象/数组解构、默认值、rest | S1 | 逐项生成 presence check 和绑定；副作用表达式只求值一次 |
| 函数声明/函数表达式 | S0 | 生成 FuncDef；声明可提前绑定，表达式按求值顺序创建闭包 |
| 箭头函数 | S1/S2 | 生成闭包环境，捕获 lexical `this`、参数和外部变量 |
| 参数类型、返回类型、可选/默认/rest 参数 | S0/S1 | 默认值在入口处理；rest 使用数组/切片 ABI |
| overload signatures | C/S1 | 只保留实现体；调用点使用 checker 选中的签名和类型参数 |
| `type` alias | C | checker 求值后擦除；无法实例化的 conditional/mapped 类型进入 P/R |
| `interface` | C/S2 | 默认是结构化编译期契约；需要 runtime 检查时生成 descriptor |
| `enum` | S1/S2 | 数字 enum 常量可内联；字符串/反向映射生成只读 enum object |
| `const enum` | S1 | 只有可求值且同模块可见时内联；跨边界保留对象访问 |
| `namespace`/内部 module | S1/S2 | 静态命名空间转模块对象或内部符号；动态合并 P |
| `declare`、`.d.ts`、ambient module | C | 只导入类型和外部符号；没有实现体不能生成本地机器码 |
| `public/private/protected/readonly` | C/S2 | 可见性和只读检查在前端完成；class private/protected 参与布局/访问器 |
| `abstract` | C | 类型检查约束；直接实例化 abstract class R |
| `static`、class field、static block | S1/S2 | 字段进入布局；static block 进入 class init 函数 |
| `accessor`, getter/setter | S2 | 可直接 lowering 为方法；属性读写必须保留 getter/setter 副作用 |
| `override` | C | checker 验证后擦除；生成 vtable slot 必须匹配基类签名 |
| decorator（标准） | S2/P | 需 metadata/initializer ABI；无 runtime decorator support 时 R |
| legacy decorator | P | 与标准 decorator 语义分开；不得混用 metadata 规则 |
| `using`、`await using` | S1/S2 | 作用域正常退出、return、throw、finally 都执行逆序 cleanup |
| `export =`、`import = require` | S2/P | 仅在 CommonJS/interop runtime；ESM static profile R |

## 4. TypeScript 类型节点

| AST kind / 语法 | 级别 | 处理 |
| --- | --- | --- |
| `any` | R | 默认禁止作为值或泛型参数；外部 interop 必须显式 `DynamicValue` |
| `unknown` | C/R | 允许作为边界类型；使用前必须经过可证明收窄，否则 R |
| `never` | S0/C | 表示不可达、抛出或无返回；进入 MIR unreachable/exception edge |
| `void`, `undefined`, `null` | S0 | 独立 nullish 语义；`void` 函数返回只能产生 undefined |
| `boolean`, `number`, `bigint`, `string`, `symbol` | S0/S2 | 依照运行时表示表；symbol 需要 runtime identity |
| literal type（字符串/数字/bigint/boolean） | C/S0 | 可用于 discriminant、常量折叠和 tagged union；表示通常退化到基类型 |
| `unique symbol` | C/S2 | 编译期唯一身份；运行时用 SymbolRef |
| `object`、`Function` | R/S2 | static 不接受未具体化形状；interop 使用动态对象/函数 ABI |
| `this` type | C/S2 | 类/接口 fluent API 可解析；跨闭包使用显式 receiver |
| `T` type reference、type parameter | C/S1 | checker 求类型参数；MIR 前必须单态化或使用描述符 |
| `T[]`, `Array<T>`, `ReadonlyArray<T>` | S0/S2 | 可变 Array 不变；只读 Array 协变；边界检查由 runtime/优化决定 |
| tuple、可变/具名/可选/rest tuple | S1/S2 | 固定布局或 tuple object；越界和 rest 进入 runtime |
| union `A | B` | C/S2 | 收窄后可使用单一表示；无法区分时 tagged union 或 dynamic |
| intersection `A & B` | C/S2 | 合并字段/契约；冲突布局必须 adapter 或 R |
| function/constructor type | C/S2 | 记录参数/返回 variance、调用约定和 captures |
| call/construct/index signature | C/S2 | 变成 FuncType、Constructor ABI、index runtime helper |
| type predicate `x is T`、`asserts` | C/S1 | 只写入 flow facts；函数体仍需真实生成检查或由调用方证明 |
| `typeof` type query、`keyof` | C | checker 求值；不能在 runtime 直接读取“类型” |
| indexed access `T[K]` | C/S2 | 求值成属性类型；动态 key 需要 descriptor/runtime |
| `keyof`, indexed/mapped type | C/P | 可计算结果直接擦除；无法静态枚举 key 时 R |
| conditional `T extends U ? X : Y` | C/P | 分发和 infer 在 checker 中求值；残留未实例化类型 R |
| `infer T` | C | 只参与条件类型推导，不能残留到 MIR |
| type operator `readonly`, `keyof`, `unique` | C | 记录可写性/身份/键集合后擦除 |
| template literal type / key remapping | C/P | checker 求值后擦除；不能把字符串模式当作 runtime validator |
| import type / import type node | C | 完全擦除，不产生模块依赖 |
| `out`/`in` variance annotation | C | 验证使用位置；与 Bingo layout variance 不一致时 R |
| `satisfies` 类型约束 | C | 只做 assignability 检查，不改变表达式 runtime type |

## 5. 表达式节点

| AST kind | 级别 | 说明 |
| --- | --- | --- |
| identifier/literal/`this`/`super` | S0/S2 | 符号解析后读 local/global/receiver；`super` 用基类 vtable |
| array/object literal | S0/S1/S2 | 已知 shape 静态分配；computed key 或 spread 不稳定则 runtime |
| property/element access | S0/S2 | 已知字段直接 load/store；动态 key、getter、proxy 进入 runtime 或 R |
| call/new | S0/S2 | `GetResolvedSignature` 选择调用；函数值用闭包 ABI，构造器设置 receiver |
| function/arrow/class expression | S1/S2 | 生成闭包、class descriptor 和初始化函数 |
| tagged template | S2 | 先建立 TemplateStringsArray，再调用 tag；首版可 P |
| `as`, angle-bracket assertion | C/R | 只允许同表示或可证明重叠；不可靠链按拒绝规则处理 |
| non-null `!` | C/S1/R | 已由 flow 证明非空可擦除；否则生成 check 或 static R |
| `satisfies` | C | 只保留 checker 结果，表达式类型不被改写 |
| `delete` | R/S2 | 已知固定字段可生成清除标记；原型/任意属性删除默认 R |
| `typeof`, `void`, `await` | S1/S2 | 分别类型查询、undefined、Promise/Future 状态机 |
| prefix/postfix unary | S0/S1 | 只接收可验证类型，按 side effect 顺序 lowering |
| binary/conditional | S0/S1/S2 | 静态 operator table；短路和 branch 显式化 |
| `yield`/`yield*` | P/S2 | 需要 generator frame；第一版默认 R |
| spread element/assignment | S1/S2 | 静态复制或 runtime iterator/object spread |
| template expression | S1/S2 | 静态片段拼接；插值调用 string conversion helper |
| `MetaProperty` | S2/P | 仅支持 `new.target`/`import.meta` 的已定义 ABI |
| synthetic/partially emitted/reference expression | C | 只在 transformer/快照中出现；源程序不直接接受 |

## 6. 语句与控制流

| AST kind / 语法 | 级别 | 处理 |
| --- | --- | --- |
| block、empty、expression statement | S0 | 顺序执行，表达式结果按 effect/liveness 丢弃 |
| variable statement/declaration list | S0/S1 | 明确初始化顺序和 TDZ/hoist 规则 |
| `if`、conditional | S0/S1 | branch + flow facts + phi |
| `do`、`while`、`for` | S0 | loop header/body/continue/exit 基本块 |
| `for in` | S2 | runtime own-enumerable key iterator；static array 不走此路径 |
| `for of` | S1/S2 | iterable protocol；数组和字符串可优化快路径 |
| `for await of` | P/S2 | async iterator state machine |
| `break`、`continue`、label | S0/S1 | 显式 loop target；跨 cleanup 的跳转插入 cleanup |
| `return` | S0/S1 | 先执行 cleanup，再返回；async 包装 Promise resolve |
| `throw` | S2 | invoke/unwind；不当作普通返回值 |
| `try/catch/finally` | S2 | 异常边和 cleanup；catch 参数可选且需绑定 unknown/dynamic 策略 |
| `switch/case/default` | S0/S1 | 静态 discriminant 可跳转表；比较语义按严格 equality |
| `with` | R | 依赖动态作用域和属性解析，不能静态编译 |
| `debugger` | C/S2 | 默认擦除；debug profile 可映射 LLVM debug trap |
| `labeled` | S1 | 只保留控制流标签，不产生 runtime 对象 |

## 7. 模块与声明节点

| AST kind / 语法 | 级别 | 处理 |
| --- | --- | --- |
| `SourceFile` | S0 | 一个 Bingo Module，保存 source map 和初始化状态 |
| `import`/`import clause`/namespace/named import | S0/S2 | 静态模块图和导入槽；type-only 完全擦除 |
| `import attributes` | C/S2 | JSON/WASM 等资源属性交给 loader；未知属性 R |
| `import defer * as ns from "mod"` | P/S2 | 需要延迟模块求值状态和首次读取触发协议；第一版 static R |
| `export assignment`、named/namespace export | S0/S2 | 生成导出槽和符号表；循环依赖采用两阶段初始化 |
| `export default` | S0/S2 | 统一成 default export slot |
| `external module reference` | S2/P | 仅支持配置好的 FFI/require loader |
| `namespace export declaration` | S1 | 静态命名空间重导出；动态 module augmentation P |
| `module`/`namespace` block | S1/S2 | 内部命名空间转模块对象或静态符号域 |
| `JSTypeAliasDeclaration`、`JSImportDeclaration` | C | tsgo 合成/兼容节点，按对应源声明处理 |
| `MissingDeclaration`、`NotEmitted*`、synthetic nodes | C | 仅用于错误恢复或 emitter，不生成用户代码 |

## 8. 类、接口和面向对象语义

| 语法 | 级别 | 处理 |
| --- | --- | --- |
| class extends | S2 | 单继承布局，基类 init 先于子类字段 |
| implements interface | C | 只做结构化检查；必要时生成 adapter/vtable |
| method/property signature | C/S2 | interface 默认擦除；class 成为方法表/slot |
| constructor | S2 | 参数求值、super、parameter property、field initializer 顺序固定 |
| getter/setter | S2 | 读写生成调用而非裸 field access |
| computed property name | S2/R | 常量 key 可静态布局；动态 key 要求 dynamic object |
| decorators | P/S2 | 标准/legacy 分开实现，保留 initializer 顺序 |
| private/protected/`#name` | C/S2 | 访问由 checker 保证；`#` 使用隐藏 slot |
| static block | S1/S2 | 归入 class initialization function |

## 9. JSX、JSDoc 与环境声明

| 语法 | 级别 | 处理 |
| --- | --- | --- |
| JSX element/self-closing/fragment | S1/S2 | 使用 checker 得到 factory/fragment factory，先转普通调用 |
| JSX attributes/spread/expression | S1/S2 | 静态 props shape 或 runtime props object |
| JSX namespaced name | P/R | 默认拒绝 XML namespace；配置 factory 时可作为普通 key |
| JSDoc type/tag/reference | C | JS 文件类型检查输入；不独立生成 runtime |
| declaration file / ambient symbol | C | 只为外部 API 提供类型；实现缺失时报 BINGO_EXTERNAL_BODY |

## 10. 必须拒绝的类型与行为

### 10.1 不可靠断言

以下代码在 `static` profile 必须产生稳定的编译错误：

```ts
const n = 1 as any as string;       // BINGO_UNSAFE_CAST
const x = value as unknown as Foo;   // 未收窄且改变运行时表示
const y = object as TotallyUnrelated;
```

规则：

1. 沿 `AsExpression`/type assertion 链追踪源类型、目标类型和中间 `any`/`unknown`。
2. 若链包含 `any`，且源/目标类型不赋值兼容、运行时表示不同或结构不重叠，直接 R；不能因为 TS checker 接受就当作安全。
3. 允许的无操作断言：源/目标 assignable、两者表示相同且没有丢失 nullability/写权限。
4. 需要表示变化的断言只能生成 `checked_cast`（例如 string -> number 的显式 parser），不能生成裸 bitcast。
5. `unsafe` profile 也要求源代码调用显式 `unsafeCast<T>(value)` 或配置的 FFI intrinsic，并在诊断和产物 metadata 中标记。

### 10.2 动态逃逸

默认拒绝或要求 dynamic profile：`any` 值传播、未收窄 `unknown`、`Object`/`Function` 宽类型、任意 index signature、`eval`、`new Function`、`with`、任意 `Proxy`、修改原型、动态 `import()`、未声明外部函数、把 mutable container 当作只读/可变不兼容类型传递。

### 10.3 语义不可证明

拒绝不可静态决定的 union 表示、unmeasurable/unreliable variance 跨 ABI 赋值、未实例化泛型残留到 MIR、未处理的 `finally`/cleanup、没有 runtime ABI 的 `await`/generator/decorator、依赖宿主对象布局的 DOM/Node 类型。

## 11. 可直接消糖的清单

以下消糖必须有 side-effect 顺序测试和 source map：

```text
optional chain       -> null check + single receiver temp
nullish coalescing   -> null/undefined branch
logical assignment   -> address temp + short circuit
destructuring        -> property/element reads + defaults
parameter property   -> constructor field store
overload             -> selected implementation signature
type assertion       -> erase or checked_cast
satisfies             -> erase after assignability
const enum            -> constant value (when safe)
for-of                -> iterator protocol / array fast path
JSX                  -> factory call
using                 -> cleanup stack
arrow                 -> closure with lexical this
```

这些不是“无条件删除”：getter、computed key、迭代器、异常和 `finally` 都可能有副作用，消糖器必须先保存求值结果。

## 12. 语义测试最小集

每个矩阵行至少有：正例 source、预期 BINGO 诊断（如 R）、HIR golden、MIR golden、LLVM verifier 结果。高风险专题还要有：

- `as any as`、unknown narrowing、nullability 和 `never`。
- function parameter contra、readonly covariance、mutable array invariance、`in/out` 标注。
- getter/setter/Proxy 边界、computed key、spread 单次求值。
- closure capture、recursive function、class field/static block、super。
- try/finally/using/await 错误边、循环依赖模块。
- f64 number、整数位运算、bigint 与 string UTF-16 行为。

## 13. AST Kind 覆盖账本

下面按 `kind_generated.go` 的连续节点区间建立追踪账本。增加新的 `Kind` 时，CI 必须要求本表和 subset gate 同时更新；不能落入默认分支后静默忽略。

| 节点组 | Kind 覆盖 | 本文对应章节 |
| --- | --- | --- |
| 名称 | `QualifiedName`, `ComputedPropertyName` | 3、4、8 |
| 签名/成员 | `TypeParameter`, `Parameter`, `Decorator`, `PropertySignature`, `PropertyDeclaration`, `MethodSignature`, `MethodDeclaration`, `ClassStaticBlockDeclaration`, `Constructor`, `GetAccessor`, `SetAccessor`, `CallSignature`, `ConstructSignature`, `IndexSignature` | 3、4、8 |
| 类型节点 | `TypePredicate`, `TypeReference`, `FunctionType`, `ConstructorType`, `TypeQuery`, `TypeLiteral`, `ArrayType`, `TupleType`, `OptionalType`, `RestType`, `UnionType`, `IntersectionType`, `ConditionalType`, `InferType`, `ParenthesizedType`, `ThisType`, `TypeOperator`, `IndexedAccessType`, `MappedType`, `LiteralType`, `NamedTupleMember`, `TemplateLiteralType`, `TemplateLiteralTypeSpan`, `ImportType` | 4 |
| 绑定模式 | `ObjectBindingPattern`, `ArrayBindingPattern`, `BindingElement` | 3 |
| 表达式 | `ArrayLiteralExpression`, `ObjectLiteralExpression`, `PropertyAccessExpression`, `ElementAccessExpression`, `CallExpression`, `NewExpression`, `TaggedTemplateExpression`, `TypeAssertionExpression`, `ParenthesizedExpression`, `FunctionExpression`, `ArrowFunction`, `DeleteExpression`, `TypeOfExpression`, `VoidExpression`, `AwaitExpression`, `PrefixUnaryExpression`, `PostfixUnaryExpression`, `BinaryExpression`, `ConditionalExpression`, `TemplateExpression`, `YieldExpression`, `SpreadElement`, `ClassExpression`, `OmittedExpression`, `ExpressionWithTypeArguments`, `AsExpression`, `NonNullExpression`, `MetaProperty`, `SyntheticExpression`, `SatisfiesExpression` | 2、5 |
| 模板/类分隔 | `TemplateSpan`, `SemicolonClassElement` | 2、8 |
| 语句 | `Block`, `EmptyStatement`, `VariableStatement`, `ExpressionStatement`, `IfStatement`, `DoStatement`, `WhileStatement`, `ForStatement`, `ForInStatement`, `ForOfStatement`, `ContinueStatement`, `BreakStatement`, `ReturnStatement`, `WithStatement`, `SwitchStatement`, `LabeledStatement`, `ThrowStatement`, `TryStatement`, `DebuggerStatement` | 6 |
| 声明 | `VariableDeclaration`, `VariableDeclarationList`, `FunctionDeclaration`, `ClassDeclaration`, `InterfaceDeclaration`, `TypeAliasDeclaration`, `EnumDeclaration`, `ModuleDeclaration`, `ModuleBlock`, `EnumMember` | 3、8 |
| import/export | `NamespaceExportDeclaration`, `ImportEqualsDeclaration`, `ImportDeclaration`, `ImportClause`, `NamespaceImport`, `NamedImports`, `ImportSpecifier`, `ExportAssignment`, `ExportDeclaration`, `NamedExports`, `NamespaceExport`, `ExportSpecifier`, `ExternalModuleReference`, `ImportAttributes`, `ImportAttribute` | 7 |
| JSX | `JsxElement`, `JsxSelfClosingElement`, `JsxOpeningElement`, `JsxClosingElement`, `JsxFragment`, `JsxOpeningFragment`, `JsxClosingFragment`, `JsxAttribute`, `JsxAttributes`, `JsxSpreadAttribute`, `JsxExpression`, `JsxNamespacedName` | 9 |
| clause/对象成员 | `CaseBlock`, `CaseClause`, `DefaultClause`, `HeritageClause`, `CatchClause`, `PropertyAssignment`, `ShorthandPropertyAssignment`, `SpreadAssignment` | 5、6、8 |
| 文件/JSDoc | `SourceFile` 及 `JSDoc*` 全部节点 | 7、9 |
| 错误恢复/合成 | `MissingDeclaration`, `SyntaxList`, `JSTypeAliasDeclaration`, `JSImportDeclaration`, `NotEmittedStatement`, `PartiallyEmittedExpression`, `SyntheticReferenceExpression`, `NotEmittedTypeElement` | 7；只允许适配层处理，不产生用户 MIR |

token 级别由 parser 负责；subset gate 只审计具有运行时或类型语义的 token。全部 assignment、binary、unary token 已在第 2 节按运算族覆盖。`type`/`defer` import phase modifier 分别按擦除和延迟求值处理；`immediate` 等仅被 scanner 识别但没有独立源节点语义的 contextual keyword 不单独生成 IR。
