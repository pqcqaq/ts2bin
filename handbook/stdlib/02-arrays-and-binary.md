# 02. 数组与二进制数据

## `Array<T>` 与 `ReadonlyArray<T>`

构造/静态方法：

| 方法 | 作用 |
| --- | --- |
| `Array(length)` / `new Array(...items)` | 创建数组；单个数字参数表示长度，容易混淆 |
| `Array.isArray(value)` | 跨 realm 的数组检测与类型守卫 |
| `Array.from(source, mapFn?)` | 从可迭代或类数组对象同步构造 |
| `Array.of(...items)` | 始终把参数当元素 |
| `Array.fromAsync(source, mapFn?)` | 从异步/同步 iterable 或类数组异步构造（ESNext） |

```ts
Array(3);          // 三个空槽
Array.of(3);       // [3]
Array.from("abc"); // ["a", "b", "c"]
```

实例成员完整分组：

| 类别 | 方法/属性 |
| --- | --- |
| 长度/访问 | `length`、数字索引、`at` |
| 添加/删除（原地） | `push`、`pop`、`unshift`、`shift`、`splice` |
| 重排/覆盖（原地） | `sort`、`reverse`、`copyWithin`、`fill` |
| 非修改版 | `toSorted`、`toReversed`、`toSpliced`、`with` |
| 截取/组合 | `slice`、`concat`、`flat`、`flatMap` |
| 查找 | `includes`、`indexOf`、`lastIndexOf`、`find`、`findIndex`、`findLast`、`findLastIndex` |
| 判断 | `every`、`some` |
| 变换/遍历 | `map`、`filter`、`forEach`、`reduce`、`reduceRight` |
| 迭代 | `entries`、`keys`、`values`、`[Symbol.iterator]` |
| 字符串 | `join`、`toString`、`toLocaleString` |

```ts
const values = [3, 1, 2];
const sorted = values.toSorted((a, b) => a - b); // 新数组
const changed = values.with(0, 10);              // 新数组
values.sort((a, b) => a - b);                    // 修改原数组
```

### 关键行为

- `sort()` 默认按字符串比较；数字必须传 `(a, b) => a - b`。
- `includes` 使用 SameValueZero，能找到 `NaN`；`indexOf` 使用严格相等，找不到 `NaN`。
- `slice` 不修改，`splice` 修改原数组。
- `map` 一对一；`flatMap` 相当于一层 `map` + `flat(1)`。
- `reduce` 无初始值时空数组会抛错；泛型累加器最好显式传初始值。
- 稀疏数组的空槽在不同方法中处理不同，业务数据优先稠密数组。

`ReadonlyArray<T>` / `readonly T[]` 提供读取、查找、迭代和返回新数组的方法，但不提供原地修改方法。它是静态只读视图，底层数组仍可能通过其他引用被修改。

```ts
function total(values: readonly number[]) {
  return values.reduce((sum, value) => sum + value, 0);
}
```

`ArrayLike<T>` 只有 `length` 与数字索引，未必可迭代；`Iterable<T>` 能迭代，未必有长度。`Array.from` 可把二者转换成数组。

## TypedArray 家族

| 类型 | 元素 |
| --- | --- |
| `Int8Array` / `Uint8Array` / `Uint8ClampedArray` | 8 位有符号/无符号/钳制无符号整数 |
| `Int16Array` / `Uint16Array` | 16 位整数 |
| `Int32Array` / `Uint32Array` | 32 位整数 |
| `Float16Array` / `Float32Array` / `Float64Array` | 16/32/64 位浮点数 |
| `BigInt64Array` / `BigUint64Array` | 64 位 bigint 整数 |

每种类型都有：

- 构造：长度、数组/iterable、另一个 typed array、`ArrayBuffer` + 偏移 + 长度。
- 静态属性/方法：`BYTES_PER_ELEMENT`、`from`、`of`。
- 实例属性：`buffer`、`byteLength`、`byteOffset`、`length`、`BYTES_PER_ELEMENT`。

共享实例方法：

`at`、`copyWithin`、`entries`、`every`、`fill`、`filter`、`find`、`findIndex`、`findLast`、`findLastIndex`、`forEach`、`includes`、`indexOf`、`join`、`keys`、`lastIndexOf`、`map`、`reduce`、`reduceRight`、`reverse`、`set`、`slice`、`some`、`sort`、`subarray`、`toLocaleString`、`toReversed`、`toSorted`、`toString`、`values`、`with`、`[Symbol.iterator]`。

```ts
const bytes = new Uint8Array([1, 2, 255]);
const view = bytes.subarray(1); // 与原数组共享 buffer
const copy = bytes.slice(1);    // 复制数据
view[0] = 10;
```

- TypedArray 长度固定，写入会按目标数值格式转换/截断。
- `subarray` 共享内存；`slice` 复制。
- `filter`、`map` 等返回同类 TypedArray，而不是普通数组。
- bigint TypedArray 的回调和值使用 bigint，不能混用 number。

### `Uint8Array` Base64/Hex（ESNext）

```ts
const bytes = Uint8Array.fromHex("48656c6c6f");
bytes.toHex();
bytes.toBase64({ alphabet: "base64url", omitPadding: true });

const target = new Uint8Array(32);
const { read, written } = target.setFromBase64("SGVsbG8=");
```

完整方法：静态 `fromBase64`、`fromHex`；实例 `toBase64`、`setFromBase64`、`toHex`、`setFromHex`。Base64 选项可控制 `base64`/`base64url`、padding 和最后一块处理。

## `ArrayBuffer`

```ts
const buffer = new ArrayBuffer(16);
buffer.byteLength;    // 16
const copy = buffer.slice(0, 8);
ArrayBuffer.isView(new Uint8Array(buffer)); // true
```

实例 API：

| 成员 | 作用 |
| --- | --- |
| `byteLength` | 当前字节数 |
| `slice(begin, end?)` | 复制范围 |
| `maxByteLength` / `resizable` | 可调整缓冲区能力（ES2024） |
| `resize(newLength)` | 调整可调整缓冲区 |
| `detached` | 是否已分离（ES2024） |
| `transfer(newLength?)` | 转移数据并分离原缓冲区 |
| `transferToFixedLength(newLength?)` | 转为固定长度并分离原缓冲区 |

```ts
const growable = new ArrayBuffer(8, { maxByteLength: 64 });
growable.resize(16);
const moved = growable.transferToFixedLength();
```

目标运行时不支持可调整/转移 API 时，即使 `lib` 声明存在也会失败。

## `SharedArrayBuffer`

用于多个 agent/Worker 共享内存。成员：`byteLength`、`slice`、`maxByteLength`、`growable`、`grow(newLength)`；构造器支持 `maxByteLength`。

共享内存有安全响应头、宿主支持和并发模型要求。普通应用不要把它当成更快的 ArrayBuffer。

## `DataView`

`DataView` 在任意字节偏移按指定端序读写多种数值：

```ts
const buffer = new ArrayBuffer(8);
const view = new DataView(buffer);
view.setUint32(0, 0x12345678, false); // 大端
const value = view.getUint32(0, false);
```

属性：`buffer`、`byteLength`、`byteOffset`。

读方法：`getInt8`、`getUint8`、`getInt16`、`getUint16`、`getInt32`、`getUint32`、`getBigInt64`、`getBigUint64`、`getFloat16`、`getFloat32`、`getFloat64`。

写方法：对应的 `setInt8`、`setUint8`、`setInt16`、`setUint16`、`setInt32`、`setUint32`、`setBigInt64`、`setBigUint64`、`setFloat16`、`setFloat32`、`setFloat64`。

多字节方法最后一个参数 `littleEndian` 默认为 `false`（大端）。DataView 不要求自然对齐，适合解析协议；TypedArray 更适合批量同类型数据。

## `Atomics`

用于 SharedArrayBuffer 上的整数 TypedArray：

| 类别 | 方法 |
| --- | --- |
| 原子读写 | `load`、`store`、`exchange`、`compareExchange` |
| 原子运算 | `add`、`sub`、`and`、`or`、`xor` |
| 等待/唤醒 | `wait`、`waitAsync`、`notify` |
| 能力/提示 | `isLockFree`、`pause`（ESNext） |

```ts
const shared = new SharedArrayBuffer(Int32Array.BYTES_PER_ELEMENT);
const state = new Int32Array(shared);
Atomics.store(state, 0, 1);
Atomics.add(state, 0, 2);
```

`wait` 会阻塞当前 agent，主线程环境通常受限；`waitAsync` 返回同步结果或 Promise 包装结果。并发算法必须按内存模型设计，不能只把普通读写机械替换成 Atomics。

## 选择指南

- 日常列表与异构数据：`Array<T>`。
- 只读参数：`readonly T[]`。
- 二进制同类型批量数值：TypedArray。
- 任意端序协议解析：`DataView`。
- 可转移内存：`ArrayBuffer`。
- 跨 Worker 共享并发内存：`SharedArrayBuffer` + `Atomics`。
