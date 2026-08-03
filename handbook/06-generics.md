# 06. 泛型

泛型用类型参数描述“类型之间的关系”，而不是用 `any` 放弃关系。

## 最小示例

```ts
function identity<T>(value: T): T {
  return value;
}

const text = identity("hello"); // "hello"
const count = identity<number>(1);
```

通常让编译器推断类型参数；只有推断不足或要主动扩大/固定类型时才显式传参。

## 泛型函数、接口和类

```ts
type Mapper<T, U> = (value: T) => U;

interface Repository<T, Id = string> {
  find(id: Id): Promise<T | undefined>;
  save(entity: T): Promise<void>;
}

class MemoryBox<T> {
  constructor(public value: T) {}
}
```

静态成员不能引用类自身的类型参数，因为一个类的所有实例共享同一个静态成员。

## 约束 `extends`

```ts
function lengthOf<T extends { length: number }>(value: T): number {
  return value.length;
}
```

约束描述最低能力，返回值仍保留具体 `T`。不要为了访问一个属性把参数写成完整大对象。

依赖键的约束：

```ts
function get<T extends object, K extends keyof T>(object: T, key: K): T[K] {
  return object[key];
}

const user = { id: 1, name: "Ada" };
const name = get(user, "name"); // string
```

## 默认类型参数

```ts
type Result<T = void, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };
```

规则与函数默认参数相似：必选类型参数不能出现在已有默认值的参数之后。

## `const` 类型参数

`const` 修饰符让推断偏向字面量和只读结构：

```ts
function tuple<const T extends readonly unknown[]>(...values: T): T {
  return values;
}

const point = tuple("point", 10, 20);
// readonly ["point", 10, 20]
```

它只影响推断，不让运行时值变为不可变。约束最好使用 `readonly`，否则只读候选可能因不兼容而退回到较宽的可变类型。

## 类型参数变型 `in` / `out`

```ts
interface Producer<out T> {
  get(): T;
}

interface Consumer<in T> {
  accept(value: T): void;
}

interface Cell<in out T> {
  get(): T;
  set(value: T): void;
}
```

- `out T`：协变，只向外产生 `T`。
- `in T`：逆变，只消费 `T`。
- `in out T`：不变，同时消费和产生。

变型标注主要用于说明和校验已有结构关系，不应用来强迫编译器接受本不安全的设计。

## 构造函数泛型

```ts
type AbstractConstructor<T = object> = abstract new (...args: any[]) => T;

function withId<TBase extends AbstractConstructor>(Base: TBase) {
  abstract class WithId extends Base {
    readonly id = crypto.randomUUID();
  }
  return WithId;
}
```

`abstract new` 允许抽象和具体类作为输入；若只接受可实例化类则使用 `new (...args) => T`。

## 实例化表达式

可以在不调用函数时先固定类型参数：

```ts
function makeBox<T>(value: T) {
  return { value };
}

const makeStringBox = makeBox<string>;
const box = makeStringBox("text");
```

这比手写一个仅转发参数的包装函数更直接。

## 相关类型参数

```ts
function mapValues<T extends object, R>(
  object: T,
  fn: <K extends keyof T>(value: T[K], key: K) => R,
): { [K in keyof T]: R } {
  const result = {} as { [K in keyof T]: R };
  for (const key of Object.keys(object) as Array<keyof T>) {
    result[key] = fn(object[key], key);
  }
  return result;
}
```

这里 `K` 把每次回调的键与值联系起来，返回映射类型则保留原对象的键集合。实现内部的 `Object.keys` 只返回 `string[]`，所以需要一个局部、可解释的断言。

## 推断原则

- 类型参数应至少连接两个位置，例如输入与输出、对象与键。
- 使用最少的类型参数；能写 `T` 就不要再引入等价的 `U extends T`。
- 参数约束应尽量小，让调用方保留具体类型。
- 回调参数尽量直接使用类型参数，避免不必要的条件类型阻碍推断。
- 默认值服务常用调用，显式类型参数服务少数例外。

## 组合用法：类型化事件总线接口

```ts
type EventMap = {
  connected: { at: Date };
  message: { from: string; body: string };
};

interface EventBus<Events extends object> {
  on<K extends keyof Events>(type: K, handler: (event: Events[K]) => void): () => void;
  emit<K extends keyof Events>(type: K, event: Events[K]): void;
}

declare const bus: EventBus<EventMap>;
bus.emit("message", { from: "Ada", body: "hello" });
```

`K extends keyof Events` 限制事件名，`Events[K]` 再把事件名映射到对应载荷。

## 常见坑

- `T extends object` 不表示“有任意字符串属性”，只表示非原始值。
- 泛型实现内部仍要对运行时值负责；类型参数不会生成验证逻辑。
- 过度使用泛型会降低错误可读性。没有类型关系时用具体类型或联合。
- `const T` 影响推断偏好，不等于深只读，也不能替代 `as const` 的所有使用场景。
