# 03. 集合、弱引用与反射

## `Map<K, V>`

```ts
const users = new Map<string, { name: string }>([
  ["1", { name: "Ada" }],
]);

users.set("2", { name: "Lin" });
const user = users.get("1"); // V | undefined
```

实例完整 API：

| 类别 | 成员 |
| --- | --- |
| 大小/清理 | `size`、`clear`、`delete` |
| 读写 | `get`、`set`、`has` |
| 遍历 | `forEach`、`entries`、`keys`、`values`、`[Symbol.iterator]` |
| 缺省插入（ESNext） | `getOrInsert`、`getOrInsertComputed` |

`Map` 按插入顺序迭代，键使用 SameValueZero 比较；对象键按引用身份区分。

```ts
const cache = new Map<string, string[]>();
const list = cache.getOrInsertComputed("users", () => []);
list.push("Ada");
```

`ReadonlyMap<K, V>` 只提供 `size`、`get`、`has`、`forEach`、`entries`、`keys`、`values` 和迭代。它是只读视图，不冻结底层 Map。

### `Map.groupBy`

```ts
const byOwner = Map.groupBy(
  [{ owner: { id: 1 }, value: "a" }, { owner: { id: 1 }, value: "b" }],
  (item) => item.owner,
);
```

它允许任意类型键。注意示例中的两个 `{ id: 1 }` 是不同对象，会形成两个组；按值分组应返回稳定的原始键或共享对象引用。

## `Set<T>`

```ts
const tags = new Set(["ts", "js"]);
tags.add("web");
tags.has("ts");
tags.delete("js");
```

基础 API：`size`、`add`、`clear`、`delete`、`has`、`forEach`、`entries`、`keys`、`values`、`[Symbol.iterator]`。`keys()` 与 `values()` 为兼容 Map 迭代形状而等价。

ES2025 集合组合方法：

| 方法 | 结果 |
| --- | --- |
| `union(other)` | 并集 |
| `intersection(other)` | 交集 |
| `difference(other)` | 当前集合减去 other |
| `symmetricDifference(other)` | 只出现在其中一边的元素 |
| `isSubsetOf(other)` | 当前集合是否为子集 |
| `isSupersetOf(other)` | 当前集合是否为超集 |
| `isDisjointFrom(other)` | 是否无交集 |

```ts
const left = new Set([1, 2]);
const right = new Set([2, 3]);

left.union(right);        // Set {1, 2, 3}
left.intersection(right); // Set {2}
left.difference(right);   // Set {1}
```

参数只需满足 `ReadonlySetLike<T>`：有 `size`、`has`、`keys`，不一定是真正的 Set。组合方法返回新 Set，不修改原集合。

`ReadonlySet<T>` 移除 `add`、`delete`、`clear`，但保留读取、迭代和返回新 Set 的组合方法。

## `WeakMap<K, V>` 与 `WeakSet<T>`

```ts
const metadata = new WeakMap<object, { seen: boolean }>();
const object = {};
metadata.set(object, { seen: true });
```

`WeakMap` API：`get`、`set`、`has`、`delete`，以及 ESNext `getOrInsert`、`getOrInsertComputed`。

`WeakSet` API：`add`、`has`、`delete`。

弱集合的键只能是对象或非注册 symbol；没有 `size`、`clear` 和迭代，因为垃圾回收状态不可观察。它们适合把元数据与对象生命周期绑定。

```ts
const privateData = new WeakMap<object, { token: string }>();

function dataFor(target: object) {
  return privateData.getOrInsertComputed(target, () => ({ token: crypto.randomUUID() }));
}
```

## `WeakRef<T>`

```ts
const target = { large: true };
const reference = new WeakRef(target);
const value = reference.deref(); // T | undefined
```

构造器接收弱键，唯一实例方法是 `deref()`。返回值只在当前同步 job 内被临时保持；不能假设何时变为 `undefined`，也不能用它实现必须命中的业务缓存。

## `FinalizationRegistry<T>`

```ts
const registry = new FinalizationRegistry<string>((id) => {
  console.log(`collected: ${id}`);
});

const token = {};
let object: object | null = {};
registry.register(object, "object-1", token);
registry.unregister(token);
object = null;
```

API：

- `new FinalizationRegistry(cleanupCallback)`。
- `register(target, heldValue, unregisterToken?)`。
- `unregister(token)`。

回调是否执行、何时执行都不保证。它只能做非关键优化/诊断，不能承担关闭文件、提交事务或释放必须回收的资源；确定性释放使用 `using`/`DisposableStack`。

## 属性描述符

```ts
const object = {};
Object.defineProperty(object, "id", {
  value: 1,
  writable: false,
  enumerable: true,
  configurable: false,
});
```

`PropertyDescriptor` 有两类互斥形状：

- 数据属性：`value`、`writable`。
- 访问器属性：`get`、`set`。

两者都可有 `enumerable`、`configurable`。未显式提供的布尔标志在 `defineProperty` 中默认为 `false`，与对象字面量创建的普通属性默认值不同。

## `Reflect`

Reflect 把对象内部操作暴露为函数：

| 操作 | 方法 |
| --- | --- |
| 调用/构造 | `apply`、`construct` |
| 属性读写 | `get`、`set`、`has`、`deleteProperty` |
| 属性描述 | `defineProperty`、`getOwnPropertyDescriptor`、`ownKeys` |
| 原型 | `getPrototypeOf`、`setPrototypeOf` |
| 扩展性 | `isExtensible`、`preventExtensions` |

```ts
const result = Reflect.apply(Math.max, undefined, [1, 3, 2]);
const ok = Reflect.set({ x: 1 }, "x", 2);
```

与部分 `Object` 方法相比，Reflect 的失败操作通常返回 boolean，而不是返回目标对象或直接抛错；但参数类型错误和不变量违规仍可能抛错。

## `Proxy`

```ts
const target = { count: 0 };
const proxy = new Proxy(target, {
  get(object, key, receiver) {
    console.log("get", key);
    return Reflect.get(object, key, receiver);
  },
  set(object, key, value, receiver) {
    if (key === "count" && typeof value !== "number") return false;
    return Reflect.set(object, key, value, receiver);
  },
});
```

全部 `ProxyHandler<T>` traps：

| 类别 | trap |
| --- | --- |
| 调用/构造 | `apply`、`construct` |
| 属性读写 | `get`、`set`、`has`、`deleteProperty` |
| 属性定义/查询 | `defineProperty`、`getOwnPropertyDescriptor`、`ownKeys` |
| 原型 | `getPrototypeOf`、`setPrototypeOf` |
| 扩展性 | `isExtensible`、`preventExtensions` |

`Proxy.revocable(target, handler)` 返回 `{ proxy, revoke }`，撤销后任何操作都会抛错。

### 代理不变量

trap 不能谎报违反目标对象硬约束的结果，例如：

- 不能把不可配置的自有属性从 `ownKeys` 中隐藏。
- 不能为不可写、不可配置数据属性返回不同值。
- 目标不可扩展时，不能报告不存在的新属性。
- `preventExtensions` 返回 true 时目标必须真的不可扩展。

使用对应 `Reflect.*` 作为默认转发能减少语义偏差，但仍需理解 receiver、访问器 `this` 和私有字段的行为。

## 组合用法：分组 + 集合 + 缓存

```ts
type User = { id: string; team: string };

function indexUsers(users: readonly User[]) {
  const byTeam = Map.groupBy(users, (user) => user.team);
  const ids = new Set(users.map((user) => user.id));
  return { byTeam, ids };
}
```

Map 保留分组键类型，Set 表达唯一 ID；如果输入对象需要附加不可枚举缓存，可再使用 WeakMap 而不污染数据模型。

## 常见坑

- `Map#get` 返回 `V | undefined`，无法区分“键不存在”和“值就是 undefined”；先用 `has` 或避免存 undefined。
- 对象键按引用比较，不按字段内容比较。
- WeakRef/FinalizationRegistry 不提供确定的生命周期事件。
- Proxy 不能直接代理对象的内部 slots；Map、Date、`#private` 等方法对 receiver 有额外要求。
- 代理会影响优化、调试和身份判断，能用普通函数/访问器表达时保持简单。
