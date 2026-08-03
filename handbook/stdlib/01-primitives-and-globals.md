# 01. 原始值与全局对象

## 全局常量和函数

| 名称 | 用法 | 注意 |
| --- | --- | --- |
| `Infinity` / `NaN` / `undefined` | 特殊全局值 | 检测 NaN 优先 `Number.isNaN` |
| `parseInt(text, radix)` | 解析整数 | 总是明确进制，如 `parseInt("10", 10)` |
| `parseFloat(text)` | 解析浮点数 | 允许尾部非数字文本 |
| `isFinite(value)` / `isNaN(value)` | 先强制转数字再判断 | 多数业务优先 `Number.isFinite/isNaN` |
| `encodeURI` / `decodeURI` | 编解码完整 URI | 不编码 URI 结构字符 |
| `encodeURIComponent` / `decodeURIComponent` | 编解码 URI 组成部分 | 查询参数通常使用这一组 |
| `eval(code)` | 执行字符串代码 | 有安全、优化和作用域风险，应避免 |
| `escape` / `unescape` | 旧式字符串转义 | 已弃用，不用于 URL 编码 |

```ts
Number.isNaN(Number("bad"));
const query = `q=${encodeURIComponent("a+b")}`;
```

## `Object`

实例方法：

| 方法 | 作用 |
| --- | --- |
| `hasOwnProperty(key)` | 判断自有属性；不可靠对象上优先 `Object.hasOwn` |
| `isPrototypeOf(value)` | 判断当前对象是否在原型链上 |
| `propertyIsEnumerable(key)` | 判断自有属性且可枚举 |
| `toString()` / `toLocaleString()` | 字符串表示 |
| `valueOf()` | 原始值转换钩子 |

`Object` 静态 API 全表：

| 方法组 | 方法 |
| --- | --- |
| 创建/原型 | `create`、`getPrototypeOf`、`setPrototypeOf` |
| 属性定义 | `defineProperty`、`defineProperties`、`getOwnPropertyDescriptor`、`getOwnPropertyDescriptors` |
| 键与值 | `keys`、`values`、`entries`、`fromEntries`、`getOwnPropertyNames`、`getOwnPropertySymbols` |
| 复制/比较 | `assign`、`is` |
| 所有权 | `hasOwn` |
| 完整性 | `preventExtensions`、`seal`、`freeze`、`isExtensible`、`isSealed`、`isFrozen` |
| 分组 | `groupBy` |

```ts
const entries = Object.entries({ a: 1, b: 2 });
const copy = Object.fromEntries(entries);
const grouped = Object.groupBy([1, 2, 3, 4], (n) => n % 2 ? "odd" : "even");
```

- `Object.assign` 和展开都是浅复制，并会触发属性读取；二者对 setter、符号键等细节不同。
- `Object.freeze` 是浅冻结；TypeScript 返回浅 `Readonly<T>`。
- `Object.keys` 返回 `string[]`，因为运行时对象可能有类型未声明的额外键。
- `Object.groupBy` 返回可能缺键的对象；`Map.groupBy` 可保留任意键类型。

## `Function`

所有函数都有：`apply`、`call`、`bind`、`toString`、`length`、`name`、`prototype`（并非所有可调用值都能构造）。旧属性 `arguments`、`caller` 不应在现代严格模式中使用。

```ts
function add(this: { base: number }, a: number, b: number) {
  return this.base + a + b;
}

add.call({ base: 1 }, 2, 3);
add.apply({ base: 1 }, [2, 3]);
const addFromOne = add.bind({ base: 1 }, 2);
```

声明中的 `CallableFunction` / `NewableFunction` 为严格的 `call`/`apply`/`bind` 提供泛型签名。业务类型不要使用宽泛的 `Function`，应写具体调用签名。

## `Boolean`

- `Boolean(value)`：返回原始 `boolean`。
- `new Boolean(value)`：返回包装对象，通常不要使用；对象即使包装 `false` 也是真值。
- 实例方法：`valueOf()`。

```ts
Boolean(0);       // false
Boolean("false"); // true，非空字符串
```

## `String`

静态方法：

- `String(value)`：安全转换为字符串。
- `String.fromCharCode(...codes)`：从 UTF-16 code units 构造。
- `String.fromCodePoint(...points)`：从 Unicode code points 构造。
- `String.raw(template, ...values)`：取得模板字面量原始转义文本。

实例 API 全表：

| 方法组 | 方法/属性 |
| --- | --- |
| 长度/位置 | `length`、数字索引、`at`、`charAt`、`charCodeAt`、`codePointAt` |
| 查找 | `includes`、`startsWith`、`endsWith`、`indexOf`、`lastIndexOf`、`search` |
| 截取/组合 | `slice`、`substring`、`substr`（旧式）、`split`、`concat`、`repeat` |
| 空白/填充 | `trim`、`trimStart`/`trimLeft`、`trimEnd`/`trimRight`、`padStart`、`padEnd` |
| 大小写 | `toLowerCase`、`toUpperCase`、`toLocaleLowerCase`、`toLocaleUpperCase` |
| Unicode | `normalize`、`isWellFormed`、`toWellFormed`、`[Symbol.iterator]` |
| 正则协议 | `match`、`matchAll`、`replace`、`replaceAll`、`search`、`split` |
| 比较/转换 | `localeCompare`、`toString`、`valueOf` |

遗留 HTML 包装方法：`anchor`、`big`、`blink`、`bold`、`fixed`、`fontcolor`、`fontsize`、`italics`、`link`、`small`、`strike`、`sub`、`sup`。它们已弃用，不应用于生成 HTML。

```ts
const emoji = "A😀";
emoji.length;             // 3 个 UTF-16 code units
[...emoji].length;        // 2 个 Unicode code points
emoji.at(-1);             // 单个 code unit，不保证完整字符

"  hello  ".trim().replaceAll("l", "L");
```

用户可见的字素簇（例如带肤色或组合音标的字符）应使用 `Intl.Segmenter`，不能只按索引或 code point 切分。

## `Number`

静态常量：`EPSILON`、`MAX_VALUE`、`MIN_VALUE`、`MAX_SAFE_INTEGER`、`MIN_SAFE_INTEGER`、`NaN`、`POSITIVE_INFINITY`、`NEGATIVE_INFINITY`。

静态方法：`isFinite`、`isInteger`、`isNaN`、`isSafeInteger`、`parseFloat`、`parseInt`。

实例方法：`toExponential`、`toFixed`、`toLocaleString`、`toPrecision`、`toString(radix?)`、`valueOf`。

```ts
Number.isFinite("1");            // false，不强制转换
Number.isSafeInteger(2 ** 53 - 1); // true
(255).toString(16);               // "ff"
(1.005).toFixed(2);               // 浮点表示可能带来非直觉结果
```

`number` 遵守 IEEE-754 双精度；货币、十进制精度或超大整数需要明确的数据策略。

## `BigInt`

- 构造：`BigInt(value)`；不能使用 `new BigInt()`。
- 静态方法：`BigInt.asIntN(bits, value)`、`BigInt.asUintN(bits, value)`。
- 实例方法：`toString(radix?)`、`toLocaleString`、`valueOf`。

```ts
const id = 9_007_199_254_740_993n;
BigInt.asUintN(64, -1n); // 2^64 - 1
```

`bigint` 与 `number` 不能直接混合算术；`JSON.stringify` 默认也不能序列化 bigint。

## `Math`

常量：`E`、`LN10`、`LN2`、`LOG10E`、`LOG2E`、`PI`、`SQRT1_2`、`SQRT2`。

| 方法组 | 方法 |
| --- | --- |
| 绝对值/符号 | `abs`、`sign` |
| 取整 | `ceil`、`floor`、`round`、`trunc`、`fround`、`f16round` |
| 幂与根 | `pow`、`sqrt`、`cbrt`、`hypot` |
| 指数/对数 | `exp`、`expm1`、`log`、`log1p`、`log2`、`log10` |
| 三角 | `sin`、`cos`、`tan`、`asin`、`acos`、`atan`、`atan2` |
| 双曲 | `sinh`、`cosh`、`tanh`、`asinh`、`acosh`、`atanh` |
| 整数/位 | `clz32`、`imul` |
| 范围/随机 | `min`、`max`、`random` |

```ts
const radians = Math.PI / 2;
Math.sin(radians);
Math.hypot(3, 4); // 5
Math.imul(0xffffffff, 5); // 32 位整数乘法
```

`Math.random` 不适合密码学用途；使用宿主提供的安全随机 API。

## `Symbol`

静态方法：`Symbol(description?)`、`Symbol.for(key)`、`Symbol.keyFor(symbol)`。

实例属性/方法：`description`、`toString`、`valueOf`、`[Symbol.toPrimitive]`、`[Symbol.toStringTag]`。

Well-known symbols：`asyncIterator`、`dispose`、`asyncDispose`、`hasInstance`、`isConcatSpreadable`、`iterator`、`match`、`matchAll`、`metadata`、`replace`、`search`、`species`、`split`、`toPrimitive`、`toStringTag`、`unscopables`。

```ts
const cacheKey = Symbol("cache");
const registryKey = Symbol.for("app.cache");
```

`Symbol.for` 创建/取得全局注册符号；WeakMap/WeakSet 只接受非注册符号作为 symbol 弱键。

## `JSON`

- `JSON.parse(text, reviver?)`：解析字符串，可用 reviver 自底向上转换/删除属性。
- `JSON.stringify(value, replacer?, space?)`：序列化，可筛选/转换并格式化。
- 支持 `toJSON(key)` 钩子，例如 `Date`。

```ts
const value: unknown = JSON.parse('{"createdAt":"2026-08-03"}');
const text = JSON.stringify({ id: 1, secret: "x" }, ["id"], 2);
```

TypeScript 声明中 `JSON.parse` 返回 `any`；处理不可信输入时应立即放入 `unknown` 并验证。循环引用、bigint、函数、symbol 等有特殊或不支持的序列化行为。

## 错误对象

内置错误类型：`Error`、`EvalError`、`RangeError`、`ReferenceError`、`SyntaxError`、`TypeError`、`URIError`、`AggregateError`、`SuppressedError`。

共同属性：`name`、`message`、可选 `stack`（实现相关）；现代构造器支持 `{ cause }`。`AggregateError` 还有 `errors`，`SuppressedError` 还有 `error` 与 `suppressed`。

```ts
const cause = new Error("socket closed");
throw new Error("request failed", { cause });

const aggregate = new AggregateError([cause], "all attempts failed");
```

ESNext `Error.isError(value)` 能跨 realm 可靠检测内置错误；支持前仍常用 `value instanceof Error` 或结构化守卫。

## 辅助声明类型

| 类型 | 含义 |
| --- | --- |
| `PropertyKey` | `string | number | symbol` 的属性键别名 |
| `PropertyDescriptor` / `TypedPropertyDescriptor<T>` | value/get/set/writable/enumerable/configurable 描述 |
| `PropertyDescriptorMap` | 属性名到描述符 |
| `ArrayLike<T>` | 有 `length` 和数字索引，但未必可迭代 |
| `IArguments` | 非箭头函数的 `arguments` 对象 |
| `TemplateStringsArray` | tagged template 的只读片段及 `raw` |
| `ImportMeta` | `import.meta` 的可增强接口 |
| `ImportAttributes` / `ImportCallOptions` | 动态导入 `with` 属性类型 |
| `ThisType<T>` | 对象字面量上下文 `this` 标记 |

TypeScript 工具类型 `Partial`、`Record`、`Awaited` 等见 [13-内置工具类型](../13-utility-types.md)，每条真实定义见 [完整 API 索引](./99-api-index.md)。
