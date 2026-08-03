# 13. 内置工具类型

这些工具类型来自 TypeScript 标准声明，全部只存在于类型层。

## 对象属性变换

```ts
interface User {
  readonly id: string;
  name?: string;
  active: boolean;
}
```

| 工具 | 结果示意 | 用途 |
| --- | --- | --- |
| `Partial<User>` | 所有属性可选 | 补丁/草稿 |
| `Required<User>` | 所有属性必选 | 完整化后的数据 |
| `Readonly<User>` | 所有属性只读 | 只读视图 |
| `Pick<User, "id" | "name">` | 只保留指定键 | DTO 子集 |
| `Omit<User, "active">` | 排除指定键 | 隐藏/派生对象 |
| `Record<"admin" | "user", User>` | 指定键到统一值 | 查找表 |

它们都是浅层变换。`Partial<User>` 不会自动让嵌套对象的属性也变为可选。

## 联合类型集合运算

```ts
type All = "a" | "b" | "c";
type WithoutA = Exclude<All, "a">;      // "b" | "c"
type OnlyAB = Extract<All, "a" | "b">; // "a" | "b"
type Present = NonNullable<string | null | undefined>; // string
```

| 工具 | 规则 |
| --- | --- |
| `Exclude<U, X>` | 删除 `U` 中可赋给 `X` 的成员 |
| `Extract<U, X>` | 保留 `U` 中可赋给 `X` 的成员 |
| `NonNullable<T>` | 删除 `null` 和 `undefined` |

这些工具依赖分布式条件类型。

## 函数与构造函数

```ts
function createUser(name: string, age?: number) {
  return { id: crypto.randomUUID(), name, age };
}

class Service {
  constructor(public url: string) {}
}

type P = Parameters<typeof createUser>;             // [name: string, age?: number]
type R = ReturnType<typeof createUser>;
type CP = ConstructorParameters<typeof Service>;    // [url: string]
type I = InstanceType<typeof Service>;               // Service
```

| 工具 | 输入 | 输出 |
| --- | --- | --- |
| `Parameters<F>` | 函数类型 | 参数元组 |
| `ReturnType<F>` | 函数类型 | 返回类型 |
| `ConstructorParameters<C>` | 构造函数类型 | 构造参数元组 |
| `InstanceType<C>` | 构造函数类型 | 实例类型 |

对重载函数使用这些工具时，通常取最后一个签名，不能逐个解析全部重载。

## Promise 解包 `Awaited`

```ts
type A = Awaited<Promise<string>>;                    // string
type B = Awaited<Promise<Promise<number>>>;           // number
type C = Awaited<boolean | Promise<string>>;          // boolean | string
```

`Awaited<T>` 模拟 `await`，递归解包兼容 Promise 的 thenable，并保留 `null`/`undefined` 语义。

## 控制推断 `NoInfer`

```ts
function choose<C extends string>(
  choices: readonly C[],
  defaultChoice?: NoInfer<C>,
): C {
  return defaultChoice ?? choices[0]!;
}

choose(["red", "yellow", "green"] as const, "red");
// choose(["red", "yellow", "green"] as const, "blue"); // error
```

`NoInfer<T>` 阻止该位置成为推断候选，但最终仍检查它是否兼容 `T`。它不改变结果类型。

## `this` 相关工具

```ts
function toHex(this: Number, width: number) {
  return this.valueOf().toString(16).padStart(width, "0");
}

type Receiver = ThisParameterType<typeof toHex>; // Number
type Standalone = OmitThisParameter<typeof toHex>; // (width: number) => string
```

`ThisType<T>` 是上下文 `this` 的标记工具，本身不返回变换类型，通常与对象字面量和 `noImplicitThis` 配合：

```ts
type ObjectDescriptor<D, M> = {
  data?: D;
  methods?: M & ThisType<D & M>;
};
```

## 字符串变换

```ts
type A = Uppercase<"content-type">;   // "CONTENT-TYPE"
type B = Lowercase<"HTTP">;           // "http"
type C = Capitalize<"user">;          // "User"
type D = Uncapitalize<"User">;        // "user"
```

这四个 intrinsic 类型由编译器直接实现，常与模板字面量类型、键重映射组合。

## 组合用法：按类别抽取联合

```ts
type Event =
  | { type: "created"; id: string }
  | { type: "updated"; id: string; changes: string[] }
  | { type: "deleted"; id: string };

type EventOf<K extends Event["type"]> = Extract<Event, { type: K }>;
type Updated = EventOf<"updated">;

type EventHandlers = {
  [K in Event["type"]]: (event: EventOf<K>) => void;
};
```

这里组合了 `Extract`、索引访问、泛型约束和映射类型。

## 选择指南

- 修改同一对象的属性修饰符：`Partial` / `Required` / `Readonly`。
- 选取或排除对象键：`Pick` / `Omit`。
- 选取或排除联合成员：`Extract` / `Exclude`。
- 从真实函数/类派生签名：`Parameters` / `ReturnType` / `InstanceType`。
- 阻止次要参数反向扩大类型：`NoInfer`。
- 工具类型表达不了业务不变量时，定义判别联合或专用类型，不要无限嵌套工具。
