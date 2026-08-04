# TypeScript 全语法 Lowering 算法

本文规定 tsgo Typed Snapshot 到 Bingo HIR/MIR 的逐语法实现。完整 AST Kind 集合以 [typescript-support-matrix.md](typescript-support-matrix.md) 第 13 节为账本；本文件说明每类 Kind 的具体转换、求值顺序、特殊注意和拒绝条件。类型转换和方差 proof 统一交给 [type-system-and-variance-algorithms.md](type-system-and-variance-algorithms.md)，runtime/LLVM 落地统一交给 [runtime-and-backend-lowering-algorithms.md](runtime-and-backend-lowering-algorithms.md)，不得在单个 AST handler 中另写一套规则。

## 1. Handler 入口和结果类型

禁止每个 AST handler 直接返回任意 ValueId。统一结果：

~~~text
Lowered:
  Value(valueId, tsType, repType)
  Place(placeRef, tsType, repType, mutability)
  Condition(trueBlock, falseBlock, flowFacts)
  TypeOnly(typeId)
  NoValue(effects)
  Diverges(terminator)
~~~

每个 handler 必须声明支持的 EvaluationMode；错误 mode 是 compiler bug，而不是返回空值继续编译。

### 1.1 PlaceRef

~~~text
PlaceRef:
  Local(localId)
  Global(globalId)
  Field(receiverValue, layoutId, fieldId)
  Element(receiverValue, indexValue, boundsMode)
  Property(receiverValue, keyValue, accessPlan)
  ExportSlot(moduleId, exportId)
  Capture(envValue, captureId)
~~~

LowerPlace 的关键规则：

1. receiver、key、base 先求值并保存。
2. getter/setter、Proxy/dynamic property 使用 Property，不退化为裸地址。
3. const、readonly、private、可变数组不变性在 StorePlace 前验证。
4. LoadPlace 和 StorePlace 分开；复合赋值只调用一次 LowerPlace。
5. 任何可能 throw 的 place 计算必须在运算和写回之前发生。

## 2. 名称、作用域和绑定

### 2.1 Identifier

~~~text
LowerIdentifier(node):
  symbol = snapshot.ResolvedSymbol(node)
  binding = ResolveBinding(symbol, currentScope)

  switch binding:
    Local       -> local.get/place Local
    Parameter   -> local.get/place Local
    Capture     -> capture.get/place Capture
    Global      -> global.get/place Global
    Import      -> module export slot read
    Function    -> FuncRef or closure singleton
    Class       -> class constructor/descriptor value
    Enum        -> constant or enum object
    Ambient     -> extern/capability lookup
    TypeOnly    -> error in Value mode
~~~

特殊注意：

- shadowing、hoisting 和 declaration merge 使用 resolved symbol，不按字符串查找。
- value/type namespace 分开；同名 interface/type alias 不产生 runtime binding。
- temporal dead zone 需要显式 initialization state；在初始化前读取 let/const/class 产生运行时 ReferenceError 兼容行为或 static 证明后消除。
- import binding 是 live binding，只读 export slot，不复制初始化值。

### 2.2 this、super、new.target

- 普通函数 this 来自 FuncRef calling convention；箭头函数读取捕获的 lexical this。
- super.property 读取基类 method/accessor descriptor，但 receiver 仍是当前 this。
- super(...) 只能在派生构造器中调用，且调用成功后 this 才进入 initialized 状态。
- new.target 来自构造调用 frame；非构造路径使用 undefined。
- 无 constructor/new-target ABI 时拒绝 MetaProperty。

## 3. 字面量和基础值

| 语法 | HIR | 特殊规则 |
| --- | --- | --- |
| numeric literal | const.number(f64 bits) | 保存 -0、NaN canonical policy；源整数不自动变 i32 |
| bigint literal | rt.bigint.from_literal | capability 缺失则拒绝；不能与 number 混算 |
| string literal | const.utf16 | 按 UTF-16 code unit，常量池去重 |
| true/false | const.bool | RepType I1，ABI 边界可扩为 I8 |
| null | const.null | 与 undefined 不合并 |
| undefined | const.undefined | 不能用 null 指针冒充所有 undefined |
| regex literal | rt.regexp.compile_literal | flags/Unicode engine 版本进入 capability |
| no-substitution template | const.utf16 | 与普通字符串相同 |
| JSX text | const.utf16 | 按 JSX whitespace 规则预处理 |

数值解析必须由前端常量值或经过测试的 parser 完成，不用 Go strconv 的默认行为替代 JavaScript literal 规则。

## 4. 一元和更新运算

### 4.1 prefix unary

| 运算 | 算法 |
| --- | --- |
| +x | static number: identity；其他类型 static 拒绝，interop 调用 ToNumber |
| -x | f64 neg；bigint 调 runtime；保留 -0 |
| !x | static 只接受 boolean；Condition mode 交换 true/false edge |
| ~x | f64.to_i32_js → xor -1 → 可见结果转回 number/f64 |
| typeof x | 静态已知 tag 可常量化；dynamic/host 值调用 rt.dynamic.typeof |
| void x | 以 Discard 求值 x，返回 undefined |
| delete p | 固定布局字段默认拒绝；dynamic property 仅 interop/runtime |

### 4.2 ++ 和 --

~~~text
place = LowerPlace(operand)
old = LoadPlace(place)
new = NumericAdd(old, ±1)
StorePlace(place, new)
return prefix ? new : old
~~~

只允许可写数值 place。receiver/key 只求值一次；getter 读一次、setter 写一次。bigint 使用 bigint one，不得与 number one 混用。

## 5. 二元运算

### 5.1 operator selection

~~~text
SelectBinaryOperator(node):
  leftType = snapshot.NarrowedType(left)
  rightType = snapshot.NarrowedType(right)
  resultType = snapshot.Type(node)
  signature = checker operator resolution facts if available

  choose exactly one domain:
    Number
    BigInt
    StringConcat
    Boolean/Bitwise
    StrictIdentity
    OrderedComparison
    DynamicInterop

  if domain ambiguous or requires implicit unsupported coercion:
      Reject
~~~

### 5.2 算术

- number 的 + - * / % ** 使用 f64/受控 runtime；除数为零、NaN、Infinity 和 -0 遵循 JavaScript。
- bigint 使用 runtime arbitrary precision；除零抛 RangeError；不允许 unsigned right shift。
- 加法只有两种 static 路径：number+number 或确定的 string concat。string concat 的每个 operand conversion 必须有显式 to-string plan。
- number 与 bigint 混合永远拒绝，除非源代码显式调用转换函数。
- integer optimization 只在 MIR range proof 后进行，observable value 仍按 number。

### 5.3 位运算

~~~text
lhs32 = ToInt32OrUint32(lhs)
rhs32 = ToUint32(rhs) & 31
result32 = bitop(lhs32, rhs32)
result = ToNumber(result32)
~~~

>>> 使用 U32，其余移位按 I32。优化不能省略截断或把 >> 与 >>> 混同。

### 5.4 比较和相等

- ===/!==：primitive 按值和 tag；object/function/symbol 按 identity；不同静态 tag 可常量化。
- ==/!=：static profile 拒绝；interop 才调用 abstract equality runtime。
- number 比较使用 ordered/unordered NaN 语义。
- string 比较按 UTF-16 code unit lexicographic。
- bigint 同域比较走 runtime。
- 跨 string/number 等隐式关系比较 static 拒绝。
- Object.is、SameValue、SameValueZero 是标准库/runtime capability，不等同 ===。

### 5.5 in 和 instanceof

- key in object 需要 property lookup plan；固定 sealed shape 可静态检查已知 key，通用情况 S2。
- instanceof 对 Bingo class 使用 class descriptor/subclass chain；Symbol.hasInstance 或 host prototype 仅 dynamic/interop。
- 任一 operand 无可证明对象/constructor 表示时拒绝。

## 6. 短路、条件和逗号

### 6.1 &&、||、??

~~~text
left = LowerExpr(lhs, Value)
branch according to operator:
  &&: boolean true evaluates rhs
  ||: boolean false evaluates rhs
  ??: null or undefined evaluates rhs
merge with phi(left-or-rhs)
~~~

static profile 的 &&/|| 默认要求 boolean；若要保留 JavaScript value-returning truthy 语义，必须启用明确的 js-coercion capability。?? 只判断 null/undefined，不能用 false/0/empty string 条件。

### 6.2 条件表达式

- condition 使用 Condition mode。
- 两支按 expected type 独立规划 conversion。
- merge 前统一 RepType；无法统一则生成 tagged union 或拒绝。
- 只有一支 diverges 时不生成对应 phi incoming。

### 6.3 comma 和 parenthesized

- comma 以前部 Discard、最后 Value 的顺序 lowering。
- parenthesized 不改变类型/表示；保留 source origin 用于诊断。
- 无副作用表达式在 Discard mode 可删除，但必须由 effect verifier 证明 pure。

## 7. 可选链和逻辑赋值

### 7.1 optional property/element/call

~~~text
base = EvaluateOnce(chainBase)
if IsNullish(base):
    result = undefined
else:
    result = LowerRemainingChain(base)
merge result
~~~

注意：

- a?.[key] 在 a nullish 时不能求值 key。
- obj.method?.() 必须保存 obj 作为 this receiver。
- fn?.(args) 在 fn nullish 时不能求值 args。
- 链中的每个 optional boundary 独立产生 CFG。
- delete optional-chain 在 static 默认拒绝；interop 按 JS 规则实现。

### 7.2 compound/logical assignment

~~~text
place = LowerPlace(lhs)
old = LoadPlace(place)
if ShouldAssign(operator, old):
    rhs = LowerExpr(rhs)
    converted = Convert(rhs, place.type)
    StorePlace(place, converted)
    result = converted
else:
    result = old
~~~

getter/key/receiver 一次，setter 最多一次。对 readonly、const、import live binding、readonly array 直接诊断。

## 8. 数组、tuple 和 object literal

### 8.1 array literal

1. 从 contextual/expected type 选择 Array、ReadonlyArray 或 tuple plan。
2. 从左到右求值元素。
3. omitted element 需要 sparse-array capability；固定 tuple 不允许无语义 hole。
4. spread：
   - 已知 dense array/tuple：复制范围。
   - string：按 iterator protocol，而不是 UTF-16 单 code unit 简化。
   - 通用 iterable：rt.iterator，异常时 IteratorClose。
5. 分配完成前发生异常必须释放临时 buffer/root。

### 8.2 object literal

1. 创建 shape builder，按源顺序处理 property。
2. 普通常量 key 可进入静态 layout。
3. shorthand 解析 resolved symbol 后读取。
4. method/getter/setter 生成 FuncRef 和 descriptor。
5. computed key 先求 key，再求 value；每项只求值一次。
6. spread 按 OwnPropertyKeys/枚举规则；静态 sealed shape 可展开，通用对象调用 runtime。
7. 重复 key 保留最后赋值，但前面的 getter/value effect 仍执行。
8. __proto__、symbol key、property descriptor 行为没有 capability 时拒绝。

固定 shape 与 dynamic dictionary 不能在同一对象上无标记混用。

## 9. property 和 element access

~~~text
PlanPropertyAccess(receiverType, key):
  if class field:
      field.addr/load/store
  if class accessor:
      direct/virtual call with receiver
  if sealed structural shape and constant key:
      shape field
  if array/tuple numeric index:
      bounds check + element access
  if string index:
      UTF-16 code-unit access
  if index signature with runtime descriptor:
      property runtime op
  if DynamicValue:
      interop property op
  else:
      Reject
~~~

特殊注意：

- optional property 先走 optional chain。
- getter 可以 alloc/throw/dynamic；不能当作纯 load。
- private #field 以 class identity + hidden slot 查找，不用字符串。
- tuple 常量索引可以静态验证；动态索引必须统一元素表示。
- noUncheckedIndexedAccess 影响类型和 nullability，不仅影响诊断。

## 10. call、new 和 tagged template

### 10.1 call

~~~text
calleePlan = Resolve selected SignatureId
evaluate callee/receiver
evaluate arguments left-to-right
expand spread arguments with iterator/array plan
convert each argument according to parameter plan
dispatch direct/closure/virtual/interface/runtime/ffi
convert return to contextual result
~~~

必须保留：

- method call this receiver。
- optional call 的参数延迟求值。
- default 参数由被调函数入口处理，不由调用者填入 undefined 之外的默认值。
- rest 参数构造 array/slice ABI。
- overload 只使用 checker selected signature；找不到唯一实现则拒绝。
- any callable、Function 宽类型、call/apply/bind 动态形式默认拒绝或 runtime capability。
- tail-call 只是优化，不改变 cleanup/EH。

### 10.2 new

1. 求值 constructor。
2. 左到右求值参数。
3. 验证 construct signature 和 class/extern constructor ABI。
4. 分配 receiver 或让 host constructor 分配。
5. derived class 必须先成功 super() 再使用 this。
6. constructor 显式返回对象时按 TS/JS 规则选择结果；static profile 可限制为 class receiver。
7. abstract class、无 construct signature、dynamic constructor 默认拒绝。

### 10.3 tagged template

- 构建按调用点缓存的 frozen TemplateStringsArray，包含 cooked/raw。
- 插值从左到右求值。
- 以普通 call lowering 调用 tag。
- 无 frozen-array、raw-string 或 dynamic tag capability 时 P/R。

## 11. template expression 和 string conversion

无 tag 模板：

1. 创建 StringBuilder 或预估容量。
2. 追加 head。
3. 每个 span：求 expression → 显式 ToString plan → 追加 literal。
4. finish 为 Utf16String。

static profile 只允许具有明确 string conversion 的 primitive/已注册对象；任意 object 的 toString 动态 dispatch 默认拒绝。

## 12. assertion、satisfies 和 non-null

### 12.1 as / angle-bracket assertion

调用 TypePlanner.PlanAssertion，结果只能是 Identity、WidenLiteral、ReadonlyView、CheckedCast、DynamicBoundary、Reject。禁止 AST handler 直接擦除所有 assertion。

- 同表示、无 nullability/写权限丢失：cast.noop。
- 可证明 tagged union member：tag check/retag。
- unknown 经实际 narrowing：允许后续具体类型。
- any 链、disjoint layout、mutable covariance：拒绝。
- 显式 unsafeCast intrinsic 单独处理并记录 provenance。

### 12.2 satisfies

checker 验证后返回原表达式 runtime value 和原 inferred type；不改变 RepType，不生成 cast。

### 12.3 non-null !

- flow 已证明非空：擦除并保留 provenance。
- profile 允许 checked non-null：插入 null.check，失败抛 TypeError/配置错误。
- static-no-runtime-check profile：无法证明时拒绝。
- 不能把 NullableRef 裸 bitcast 成 Ref。

## 13. function、arrow 和 closure

### 13.1 function declaration/expression

- 声明在 scope 初始化阶段创建 binding；函数表达式在求值点创建 FuncRef/closure。
- 参数 slot 顺序：this/receiver、普通参数、可选、rest、隐藏 type descriptor（如需）。
- 入口依次处理 missing argument、default initializer、parameter destructuring、parameter property（constructor）。
- arguments object 需要专门 runtime；未实现时只支持不引用 arguments 的函数。
- overload signature C，唯一 implementation 进入 HIR。

### 13.2 capture analysis

~~~text
for each referenced symbol not local to function:
  classify read-only / mutable / this / super / type-only
  if mutable and outlives defining frame:
      box into environment cell
  else:
      capture by value/reference according to representation
sort captures by stable SymbolId
build EnvLayout
~~~

箭头函数捕获 lexical this/new.target/arguments；普通函数不捕获调用方 this。闭包环境是 GC root，递归/互相递归函数先分配函数槽再填充 closure。

### 13.3 return

- expression 按 declared/resolved return type conversion。
- void 返回只产生 undefined；不能悄悄丢弃错误类型。
- 穿过 finally/cleanup 后终结当前 block。
- async 返回进入 Promise resolve/reject，不直接 native return T。
- never function 的可达 return 是 verifier error。

## 14. variable 和 binding pattern

### 14.1 const/let/var

- const/let 在 lexical scope 建 slot 和 TDZ 状态。
- const 初始化后禁止 StorePlace。
- let 无 initializer 初始化为 undefined，但 TDZ 到声明执行点结束。
- var 提升到函数/模块 frame，进入函数时初始化 undefined。
- 重复 var/declaration merge 使用 binder 结果，不手工合并名字。

### 14.2 object destructuring

~~~text
source = EvaluateOnce(initializer)
for property in source order:
  key = EvaluateOnce(computed key if any)
  value = GetProperty(source, key)
  if value is undefined and default exists:
      value = Evaluate(default)
  Bind(pattern, value)
rest = CopyEnumerableOwnPropertiesExcluding(usedKeys)
~~~

### 14.3 array destructuring

- 获取 iterator；逐 element 调 next。
- hole 仍推进 iterator。
- default 只在 value === undefined 时执行。
- rest 消耗剩余 iterator。
- abrupt completion 执行 IteratorClose。
- 已知 tuple/array 可走等价 fast path，但必须保持 getter/iterator 可观察差异条件。

pattern lowering 不能被多个声明/赋值复用时重复求 initializer。

## 15. 控制流语句

### 15.1 block 和 expression statement

- block push lexical scope 和 cleanup scope，结束时正常清理。
- expression statement 使用 Discard，仍保留 effect。
- empty/semicolon class element 只保留 source mapping，不产生 op。
- debugger 在 release static 默认为 no-op+metadata 或拒绝 debug capability。

### 15.2 if

~~~text
LowerCondition(cond) -> trueEdge/falseEdge + flow facts
lower then under true facts
lower else under false facts
merge reachable predecessors and phi/live locals
~~~

narrowing facts来自 snapshot/checker，不由 lowering 重新实现 TypeScript flow。

### 15.3 while/do/for

每个 loop 生成 header/body/continue/exit，记录 LoopFrame：

~~~text
LoopFrame:
  continueTarget
  breakTarget
  cleanupDepth
  label
~~~

- for initializer 在 loop scope。
- condition 缺失视为 true。
- increment 在 continue target。
- break/continue 先运行超出目标 cleanup depth 的 cleanup。
- loop-carried SSA 通过 phi 构建；无法 SSA 化的 captured/mutable local 使用 slot。

### 15.4 for-of

1. 求 iterable。
2. 选择 array/string fast path 或 iterator protocol。
3. 每轮取得 value/done。
4. 绑定 pattern。
5. break/throw/return 时 IteratorClose。
6. continue 不关闭 iterator。
7. for-await-of 交给 async iterator 状态机；capability 缺失则拒绝。

### 15.5 for-in

枚举 own enumerable string keys 的 runtime 协议。固定 sealed object 可生成稳定 key list，但必须证明无 prototype/dynamic mutation；否则 static profile 拒绝或 S2。

### 15.6 switch

- 先求 discriminant 一次。
- case expression 按源顺序求值直到匹配。
- 构造 case blocks，保留 fallthrough。
- default 可位于任意位置。
- break 走 switch exit 并执行相应 cleanup。
- discriminated union 的 flow facts从 snapshot应用；exhaustive never 可生成 unreachable。

### 15.7 labels

LabelStack 映射 label 到 loop/switch/block target 与 cleanup depth。未知 label 是 parser/checker 错误。带 label 的普通 block只支持 break，不支持 continue。

## 16. throw、try、catch、finally

### 16.1 throw

- 求值 expression。
- 按 exception ABI box/validate throwable。
- 运行当前路径必须执行的 cleanup。
- 生成 HIR throw，MIR invoke/unwind edge。

### 16.2 try/catch/finally

~~~text
enter exception region
lower try
normal exit -> finally dispatcher
exception exit:
  if catch:
      bind exception and lower catch
      catch normal/throw -> finally dispatcher
  else:
      pending exception -> finally dispatcher
lower finally once for each completion kind via dispatcher/state
resume original return/throw/break/continue unless finally overrides
~~~

不能简单复制 finally 到每个出口导致副作用或代码顺序错误。实现建议用 CompletionKind + payload：

~~~text
Normal | Return(value) | Throw(error) | Break(target) | Continue(target)
~~~

finally 自己产生新 abrupt completion 时覆盖原 completion，但资源/异常合并规则仍执行。

## 17. using 和 await using

每个声明：

1. 左到右求 initializer。
2. 获取 Symbol.dispose/Symbol.asyncDispose 方法并验证 callable。
3. 成功后 push CleanupEntry(resource, disposer, async, origin)。
4. 作用域所有出口逆序 pop。
5. 初始化中途失败只清理已成功注册资源。
6. disposer 抛错与已有异常按 SuppressedError 规则组合。
7. await using 只能位于 async/TLA capability 环境，cleanup 是 suspend point。

没有 disposal runtime、symbol capability 或异常合并 ABI 时拒绝。

## 18. class lowering

### 18.1 class evaluation order

~~~text
evaluate extends expression
evaluate class decorators/metadata plan
create class descriptor and private-name identities
evaluate computed member names in source order
create methods/accessors
run decorator application/initializer registration
publish class binding
run static fields and static blocks in source order
~~~

具体 decorator 次序以标准/legacy 独立算法为准，不能混用。

### 18.2 instance construction

Base class：

~~~text
allocate receiver
run constructor prologue
initialize parameter properties
initialize base private/instance fields in source order
run constructor body
return receiver or allowed object result
~~~

Derived class：

~~~text
this = uninitialized
execute body in source order with this unavailable
on each reachable super(...) path:
  evaluate super arguments
  call base constructor
  this = returned/initialized receiver
  initialize parameter properties
  initialize derived private/instance fields in source order
continue the remaining body on that path
~~~

constructor CFG 对 `this` 传播 `Uninitialized | Initialized | MaybeInitialized` 状态；每条实际执行路径的字段初始化紧跟其成功的 `super()`，不能把 `super()` 前允许执行的普通语句移到后面。super 前读 this、返回未初始化 this、同一路径重复 super 都必须诊断或 runtime check；显式返回另一个合法 object 的路径按 checker 和 constructor ABI 单独验证。

具体顺序不能由 backend 猜测。snapshot 为每个 constructor 生成 `ConstructorInitPlan`：directive/prologue -> base constructor 的 receiver 建立（derived only）-> parameter-property stores -> non-parameter instance fields -> remaining body。对 derived CFG，这个 init segment 插入每个合法 `super()` 的 normal successor。tsgo class-fields transformer 同样把 parameter-property assignments 定位在 prologue/`super()` 后并排在普通字段初始化前，可作为差分 oracle。

每个 class field 还记录 `DefineOwnSlot` 或 `SetThroughProperty`：`useDefineForClassFields=true` 使用 own-property/own-slot define 语义，不触发同名基类 setter；`false` 使用 property set 语义，可能调用 setter。Bingo 的固定 class layout 也必须保留这个可观察差异。decorator extra initializer 由独立 decorator plan 插入规定的 before/after 位置，不能一律附加到 constructor 开头。

### 18.3 member plan

| 成员 | lowering |
| --- | --- |
| instance field | layout slot + initializer |
| static field | class global/descriptor slot + class init |
| method | direct/vtable slot |
| getter/setter | accessor pair and call plan |
| #private | class identity keyed hidden slot |
| private/protected | checker access control + layout slot |
| abstract/signature-only | compile only |
| static block | ordered class init function body |
| computed dynamic name | dynamic class object capability，否则拒绝 |

implements 只做结构契约；extends 决定 nominal base layout 和 vtable。

## 19. interface、type alias 和类型声明

- interface/type alias/type parameter/type predicate/conditional/mapped/template type 等进入 snapshot/type planner，不产生普通 HIR value。
- interface 只有在 FFI/runtime reflection/adapter 需要时产生 descriptor；descriptor 是显式能力，不是所有 interface 自动 reify。
- type predicate/asserts 只提供 checker flow facts；函数实现仍必须真实检查或通过受信 intrinsic。
- declare/.d.ts 只产生 extern contract；无 capability/FFI 实现时报 external body missing。
- JSDoc 节点只影响 JS 输入类型检查和 origin，不独立生成 runtime。

任何 CompileOnly type 进入 MIR 都是 verifier error。

## 20. enum 和 namespace

### 20.1 enum

- 可证明常量成员进入 constant table。
- 数字 enum 若需要 reverse mapping，生成只读 enum object；纯 static/const enum 可只内联。
- 字符串 enum 生成 name→value table，不生成数字 reverse mapping。
- computed member 按源顺序求值；跨模块不能假定可内联。
- heterogeneous/dynamic enum 没有明确 runtime plan 时拒绝。

### 20.2 namespace/internal module

- 静态 namespace 转内部 symbol scope 或 module object。
- declaration merge 使用 binder symbol/declaration set，初始化只执行一次。
- namespace 与 class/function/enum 合并需显式 ordered initialization。
- 动态 module augmentation、跨包运行时补丁默认拒绝。

## 21. import/export 和模块

### 21.1 module graph

只使用 Program resolved module、resolution mode 和 emit module format。每个 module：

~~~text
allocate module record and export slots
link imports to live export slots
mark Linking
after graph/SCC linking:
  execute module initialization in defined order
  mark Evaluated or Errored
~~~

循环依赖按 SCC 和 live binding 处理，不能按 DFS 简单执行文件。

### 21.2 import

- import type/type-only specifier 完全擦除，且不增加 runtime dependency。
- value import 连接 export slot。
- namespace import 生成只读 module namespace view。
- default/named import 使用 resolved export identity。
- side-effect import 只有初始化边，无 local binding。
- import attributes 交给已注册 loader；未知属性拒绝。
- import = require 仅 CommonJS/interop capability。

### 21.3 export

- declaration export 在初始化时写对应 live slot。
- export {x} 建 alias slot，不复制值。
- export * 按 module namespace/冲突规则链接。
- export default 使用固定 default slot。
- export = 仅 CommonJS profile。
- ambient/type-only export 擦除。

### 21.4 dynamic/import defer

- import() 需要异步 loader、Promise 和 module cache，static v1 默认拒绝。
- import defer 需要 DeferModuleRecord；只允许 namespace import，首次可观察属性读取触发 evaluate。未实现完整状态机前拒绝。
- import.meta 由 module metadata capability 提供固定字段；任意宿主扩展拒绝。

## 22. async、await、generator

### 22.1 async/await 前端 lowering

- async function HIR 保留 await 和 local liveness。
- await expression 先求 operand，再 PromiseResolve/thenable assimilation。
- suspend point 保存 program counter、活跃 local、exception region、cleanup stack。
- success/reject 分别进入 continuation/throw edge。
- async return 调 resolve，throw 调 reject。

没有 scheduler/Promise/GC frame capability 时整函数拒绝，不能把 await 编成阻塞调用。

### 22.2 generator

- yield 保存 frame 并返回 IteratorResult。
- yield* 委托 next/throw/return，异常和 close 必须传播。
- generator 的 next/return/throw 状态机处理 suspendedStart/suspendedYield/executing/completed。
- 未实现完整协议时默认拒绝，不提供“只支持简单 yield”的不完整兼容。

## 23. JSX

1. 使用 checker/config 确定 classic factory、fragment 或 automatic runtime。
2. tag：
   - intrinsic string tag → Utf16String。
   - component symbol → 普通 FuncRef/class constructor。
3. attributes 从左到右构建 props；spread 走 object spread 语义。
4. children 按 JSX whitespace/表达式顺序处理。
5. 生成普通 call/new HIR。
6. 缺 JSX runtime capability、namespaced XML 语义或 dynamic component ABI 时拒绝。

JSX lowering 后不保留 JSX node 到 MIR。

## 24. decorators

- 标准 decorator 与 experimental legacy decorator 使用不同 feature/profile。
- 必须保存 decorator expression 求值、application、initializer registration 和 initializer execution 顺序。
- metadata 只有 capability 显式开启时生成。
- decorator 可以替换 class/method/accessor 时需要 compatible descriptor/check。
- 私有成员、auto-accessor 和 static/instance initializer 分开。
- 同时启用无法区分的 legacy/standard metadata 组合时配置拒绝。

## 25. source file、JSDoc 和 synthetic Kind

- SourceFile 生成 module/script unit、directives、imports、declarations 和 init。
- JSDoc* 只供 JS 类型信息/诊断，C。
- MissingDeclaration/SyntaxList 是 parser/recovery/list 容器，不生成用户值。
- NotEmitted/PartiallyEmitted/SyntheticReference 等只允许受信 transformer oracle 输入；正常 source snapshot 出现时标为 frontend bug。
- token/trivia 由 parser 处理；lowering 不为每个 punctuation/keyword 建 handler。

## 26. 明确拒绝的语法路径

static v1 默认拒绝：

- with、eval、new Function。
- 任意 Proxy、运行时修改 prototype、未绑定 delete。
- abstract equality 和未建模隐式 coercion。
- 未知 computed property 导致固定 layout 失效。
- dynamic import/import defer（直到模块状态机完成）。
- 未实现 generator/for-await/async 状态机。
- legacy decorator 或 metadata capability 缺失。
- arbitrary call/apply/bind、Function/Object/any 宽值。
- host DOM/Node API 没有 FFI manifest。
- parser recovery/synthetic node 进入用户 HIR。

完整诊断和 profile 规则见 [unsupported-semantics-and-diagnostics.md](unsupported-semantics-and-diagnostics.md)。

## 27. Handler 完成清单

每个 Kind handler 必须具备：

- 接受的 EvaluationMode。
- snapshot TypeId/SignatureId/SymbolId 需求。
- 子表达式求值顺序。
- Place/Value/Condition 结果。
- conversion plan 和 RepType。
- effects/throw/suspend/cleanup。
- runtime capability。
- 正例、拒绝例、单次求值和 golden。
- 未支持分支的稳定诊断。
