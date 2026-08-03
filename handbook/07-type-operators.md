# 07. 类型运算与类型构造

本章的语法只存在于类型层，用已有类型生成新类型。

## `keyof`

```ts
type User = { id: number; name: string };
type UserKey = keyof User; // "id" | "name"
```

若类型有字符串索引签名，`keyof` 通常包含 `string | number`，因为对象的数字键会转成字符串。符号索引签名则产生 `symbol`。

## 类型位置的 `typeof`

```ts
const settings = { theme: "dark", pageSize: 20 } as const;
type Settings = typeof settings;

function createUser() {
  return { id: 1, name: "Ada" };
}
type User = ReturnType<typeof createUser>;
```

类型查询 `typeof` 通常只能作用于标识符或属性访问，不会执行任意表达式。它与值位置的 `typeof value` 运行时操作符不是同一用途。

## 索引访问类型

```ts
type User = { id: number; roles: Array<"admin" | "reader"> };
type Id = User["id"];                  // number
type Fields = User["id" | "roles"];   // number | ("admin" | "reader")[]
type Role = User["roles"][number];     // "admin" | "reader"
```

索引必须是类型。要使用常量键，先用 `typeof key` 得到其类型。

## 条件类型

```ts
type ElementOf<T> = T extends readonly (infer Item)[] ? Item : T;

type A = ElementOf<string[]>; // string
type B = ElementOf<number>;   // number
```

形式为 `T extends Constraint ? True : False`。`infer` 可在真分支中声明待推断类型变量：

```ts
type AsyncValue<T> = T extends PromiseLike<infer Value> ? Value : T;
type FunctionResult<T> = T extends (...args: any[]) => infer R ? R : never;
```

### 分布式条件类型

裸类型参数遇到联合会逐项分发：

```ts
type ToArray<T> = T extends unknown ? T[] : never;
type Distributed = ToArray<string | number>; // string[] | number[]
```

用方括号关闭分发：

```ts
type ToSingleArray<T> = [T] extends [unknown] ? T[] : never;
type Together = ToSingleArray<string | number>; // (string | number)[]
```

## 映射类型

```ts
type Optional<T> = {
  [K in keyof T]?: T[K];
};

type MutableRequired<T> = {
  -readonly [K in keyof T]-?: T[K];
};
```

- `[K in Keys]` 遍历属性键。
- `+readonly` / `-readonly` 添加或移除只读。
- `+?` / `-?` 添加或移除可选；`+` 可省略。

### 键重映射

```ts
type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

type WithoutKind<T> = {
  [K in keyof T as K extends "kind" ? never : K]: T[K];
};
```

`as` 后得到 `never` 的键会被过滤。

## 模板字面量类型

```ts
type HttpMethod = "GET" | "POST";
type Resource = "users" | "posts";
type Route = `${HttpMethod} /${Resource}`;
// "GET /users" | "GET /posts" | "POST /users" | "POST /posts"
```

联合出现在多个插值位置时会做笛卡尔积。大型组合会显著增加类型规模，应在生成代码或普通 `string` 之间权衡。

内置字符串变换：`Uppercase<S>`、`Lowercase<S>`、`Capitalize<S>`、`Uncapitalize<S>`。

## 递归类型

```ts
type AwaitedValue<T> = T extends null | undefined
  ? T
  : T extends { then(onfulfilled: infer F, ...args: any[]): any }
    ? F extends (value: infer V, ...args: any[]) => any
      ? AwaitedValue<V>
      : never
    : T;
```

递归条件类型可表达深层结构，但有实例化深度限制。优先使用内置 `Awaited<T>`、`Partial<T>` 等标准工具。

## 组合用法：从事件数据生成监听器

```ts
type Events = {
  connected: { at: Date };
  message: { body: string };
};

type ListenerMethods<T extends object> = {
  [K in keyof T as `on${Capitalize<string & K>}`]:
    (handler: (event: T[K]) => void) => () => void;
};

type ClientListeners = ListenerMethods<Events>;
// onConnected(handler: (event: { at: Date }) => void): () => void
// onMessage(handler: (event: { body: string }) => void): () => void
```

这段类型组合了 `keyof`、映射类型、键重映射、模板字面量类型、`Capitalize` 和索引访问。

## 常见坑

- `typeof` 的值查询与类型查询同名但发生在不同语法位置。
- 条件类型意外分发是高级类型中最常见的原因之一；判断整个联合时使用 `[T]`。
- 映射类型不是运行时循环，不会创建对象。
- 复杂递归类型会拖慢检查并恶化错误信息；优先分解、命名中间结果，并为公共类型添加测试。
