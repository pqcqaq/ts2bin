# 01. 基础语法

TypeScript 接受 JavaScript 语法，并在变量、参数、返回值、属性等位置增加类型信息。绝大多数类型语法在编译后会被擦除。

## 文件类型

| 后缀 | 用途 |
| --- | --- |
| `.ts` | 普通 TypeScript |
| `.tsx` | 含 JSX；尖括号类型断言不可用 |
| `.mts` / `.cts` | 明确按 ESM / CommonJS 解释 |
| `.d.ts` | 只描述类型，不提供实现 |
| `.d.mts` / `.d.cts` | ESM / CommonJS 对应的声明文件 |

## 变量与类型标注

最小示例：

```ts
const name: string = "Ada"; // 显式标注
let score = 100;             // 推断为 number
score += 1;
```

- `const`：绑定不能重新赋值，但对象内容仍可修改。
- `let`：块级作用域，可重新赋值。
- `var`：函数作用域并存在提升；只为维护旧代码保留。
- 类型标注写在标识符后：`标识符: Type`。

```ts
const user: { id: number; name?: string } = { id: 1 };
function double(value: number): number {
  return value * 2;
}
```

优先让编译器推断局部变量；公共 API、函数参数和复杂返回值适合显式标注。

## 解构、剩余与展开

```ts
const point = { x: 3, y: 4, label: "A" };
const { x, y, label: name = "unknown" } = point;

const values = [10, 20, 30] as const;
const [first, ...rest] = values;

const moved = { ...point, x: point.x + 1 };
const copied = [...values, 40];
```

- 解构重命名写成 `属性名: 局部名`，这里的冒号不是类型标注。
- 对象展开时后面的同名属性覆盖前面的属性。
- 展开是浅复制；嵌套对象仍共享引用。

参数解构的类型写在整个模式后：

```ts
function printPoint({ x, y }: { x: number; y: number }) {
  console.log(x, y);
}
```

## 常用表达式

```ts
const upper = user.name?.toUpperCase(); // 可选链：null/undefined 时停止
const title = upper ?? "ANONYMOUS";      // 仅在 null/undefined 时使用默认值
const forced = user.name!;               // 非空断言：只影响类型检查
```

| 写法 | 含义 | 注意 |
| --- | --- | --- |
| `value?.prop` | 可选属性访问 | 不会把 `0`、`false`、`""` 当作缺失 |
| `fn?.()` | 可选调用 | `fn` 为 `null`/`undefined` 时不调用 |
| `a ?? b` | 空值合并 | 与 `a || b` 的真值判断不同 |
| `x!` | 非空断言 | 没有运行时检查，误用会崩溃 |
| `expr as T` | 类型断言 | 不转换运行时的值 |
| `expr as const` | 常量断言 | 保留字面量并产生只读属性/元组 |
| `expr satisfies T` | 兼容性校验 | 校验但尽量保留表达式自身的精确类型 |

`.tsx` 中使用 `value as Type`，不要使用 `<Type>value`，后者会与 JSX 冲突。

## 语句与控制流

TypeScript 直接使用 JavaScript 的语句：

```ts
for (const item of [1, 2, 3]) {
  if (item % 2 === 0) continue;
  console.log(item);
}

try {
  JSON.parse("{");
} catch (error: unknown) {
  if (error instanceof Error) console.error(error.message);
}
```

- `for...of` 遍历值；`for...in` 遍历可枚举键。
- 严格模式下 `catch` 变量适合视为 `unknown`，先收窄再使用。
- `switch`、`if`、提前 `return` 会参与控制流类型收窄。

## 类型层与值层

同一个名字有时只存在于类型层，有时同时存在于两个层：

```ts
interface User { id: number } // 仅类型
class Account {}              // 类型 + 运行时值

const ctor = Account;         // 值层的构造函数
let account: Account;         // 类型层的实例类型
type AccountConstructor = typeof Account;
```

`type`、`interface`、大多数类型标注和 `as` 会被擦除。`class`、`enum`、`namespace`、装饰器及参数属性等可能生成运行时代码。

## 组合用法：读取不可信配置

```ts
type Config = { port: number; host: string };

function isConfig(value: unknown): value is Config {
  if (typeof value !== "object" || value === null) return false;
  const item = value as Record<string, unknown>;
  return typeof item.port === "number" && typeof item.host === "string";
}

const raw: unknown = JSON.parse('{"port":3000,"host":"localhost"}');
if (!isConfig(raw)) throw new Error("Invalid config");
console.log(raw.host, raw.port); // 此处已收窄为 Config
```

关键点：外部输入先用 `unknown`，运行时检查成功后再获得静态类型，不要直接 `as Config`。

## 常见坑

- `as T` 不是转换或验证；`"1" as unknown as number` 在运行时仍是字符串。
- `const` 不等于深只读；需要类型约束时使用 `Readonly<T>`，需要运行时不可变时另用 `Object.freeze` 等方案。
- `value || fallback` 会替换 `0`、`false`、`""`；只处理空值时使用 `??`。
- 自动分号插入可能改变 `return` 换行后的含义；公共代码保持一致的格式化规则。
