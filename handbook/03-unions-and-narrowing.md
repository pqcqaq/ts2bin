# 03. 联合、交叉与类型收窄

## 联合与交叉

```ts
type Id = string | number;           // 二者之一
type Named = { name: string };
type Timed = { createdAt: Date };
type Entity = Named & Timed;         // 同时满足二者
```

联合类型只能直接使用所有成员共有的操作；先判断具体分支，编译器才允许访问分支专有属性。

交叉不是简单的对象合并。如果同一属性要求互不兼容的类型，结果可能变成 `never`：

```ts
type Impossible = { id: string } & { id: number };
// Impossible["id"] 是 never
```

## 内置收窄方式

### `typeof`

```ts
function lengthOf(value: string | string[]) {
  if (typeof value === "string") return value.length;
  return value.length;
}
```

可识别的主要结果是 `"string"`、`"number"`、`"bigint"`、`"boolean"`、`"symbol"`、`"undefined"`、`"object"`、`"function"`。注意 `typeof null === "object"`。

### 真值、等值与空值

```ts
function print(value: string | null | undefined) {
  if (value != null) console.log(value.toUpperCase());
}
```

`value != null` 同时排除 `null` 和 `undefined`。`if (value)` 还会排除 `""`、`0`、`false`、`NaN`，业务上不一定正确。

### `in`、`instanceof`、数组检查

```ts
type FileInput = { path: string } | { content: Uint8Array };

function read(input: FileInput) {
  if ("path" in input) return input.path;
  return input.content.byteLength;
}

function message(error: Error | string) {
  return error instanceof Error ? error.message : error;
}

function count(value: string | unknown[]) {
  return Array.isArray(value) ? value.length : value.length;
}
```

若属性是可选的，`"prop" in value` 的真假两边都可能仍包含该类型。

## 用户定义类型守卫

类型谓词 `parameter is Type` 告诉编译器函数返回 `true` 时的类型：

```ts
type User = { id: number; name: string };

function isUser(value: unknown): value is User {
  if (typeof value !== "object" || value === null) return false;
  const item = value as Record<string, unknown>;
  return typeof item.id === "number" && typeof item.name === "string";
}

const values: unknown[] = [{ id: 1, name: "Ada" }, null];
const users = values.filter(isUser); // User[]
```

守卫实现错误会让静态类型与运行时事实脱节，因此守卫本身要测试。

## 断言函数

```ts
function assertDefined<T>(value: T): asserts value is NonNullable<T> {
  if (value == null) throw new Error("Expected a value");
}

let token: string | undefined;
assertDefined(token);
token.toUpperCase(); // string
```

- `asserts condition`：返回后某个条件成立。
- `asserts value is T`：返回后某个值是 `T`。
- 断言失败必须中断控制流，通常抛错。

## 判别联合

给每个成员设置同一个字面量属性：

```ts
type Result<T> =
  | { ok: true; data: T }
  | { ok: false; error: Error };

function unwrap<T>(result: Result<T>): T {
  if (result.ok) return result.data;
  throw result.error;
}
```

相比分散的 `data?` 与 `error?`，判别联合能表达“成功和失败不能同时发生”。

## 穷尽检查

```ts
type Shape =
  | { kind: "circle"; radius: number }
  | { kind: "square"; size: number };

function area(shape: Shape): number {
  switch (shape.kind) {
    case "circle": return Math.PI * shape.radius ** 2;
    case "square": return shape.size ** 2;
    default: {
      const unreachable: never = shape;
      return unreachable;
    }
  }
}
```

新增联合成员后，`never` 赋值会报错，迫使所有调用路径同步处理。

## 控制流分析

赋值、提前返回、循环和闭包都会影响收窄：

```ts
function normalize(value: string | number) {
  if (typeof value === "number") return value.toFixed(2);
  return value.trim(); // number 分支已提前返回
}
```

可变变量在闭包执行前可能被重新赋值，收窄不一定能保留；将已收窄的值放入 `const` 通常更明确。

## 组合用法：命令处理器

```ts
type Command =
  | { type: "create"; name: string }
  | { type: "rename"; id: number; name: string }
  | { type: "delete"; id: number };

function execute(command: Command): string {
  switch (command.type) {
    case "create": return `create:${command.name}`;
    case "rename": return `rename:${command.id}:${command.name}`;
    case "delete": return `delete:${command.id}`;
    default: return assertNever(command);
  }
}

function assertNever(value: never): never {
  throw new Error(`Unexpected command: ${JSON.stringify(value)}`);
}
```

这里组合了字面量类型、联合、控制流收窄、模板字符串和 `never` 穷尽检查。

## 常见坑

- `if (value)` 不是严格的非空检查，可能误排除合法的假值。
- `in` 会沿原型链查找；处理不可信 JSON 时还要检查对象非空和属性值类型。
- 类型断言不能代替守卫；断言不会生成任何运行时验证。
- 交叉类型适合组合独立能力，不适合强行覆盖已有不兼容属性。
