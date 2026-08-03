# 08. 类

类同时创建运行时构造函数和实例类型。

## 字段、构造函数和方法

```ts
class User {
  readonly id: number;
  name: string;
  nickname?: string;

  constructor(id: number, name: string) {
    this.id = id;
    this.name = name;
  }

  rename(name: string): void {
    this.name = name;
  }
}
```

启用 `strictPropertyInitialization` 后，非可选字段必须在声明处或构造函数中初始化。

```ts
class Deferred {
  value!: string; // 明确承诺会由框架等外部机制初始化
}
```

`!` 不生成初始化代码，应只用于确有外部初始化保证的场景。

派生类构造函数必须在访问 `this` 前调用 `super()`。

## 参数属性

构造参数加可见性或 `readonly` 后，会同时声明并初始化同名字段：

```ts
class Point {
  constructor(
    public x: number,
    public y: number,
    readonly label = "point",
  ) {}
}
```

参数属性会生成运行时代码；启用 `erasableSyntaxOnly` 时不可使用。

## 访问器与自动访问器

```ts
class Temperature {
  #celsius = 0;

  get celsius(): number {
    return this.#celsius;
  }

  set celsius(value: number) {
    if (!Number.isFinite(value)) throw new Error("Invalid temperature");
    this.#celsius = value;
  }
}

class Model {
  accessor id = crypto.randomUUID();
}
```

`accessor` 是自动访问器，会创建隐藏存储和 getter/setter，常与标准装饰器配合。它与普通字段的运行时语义不同。

## 可见性

```ts
class Account {
  public owner: string;
  protected balance = 0;
  private auditCode = "internal";
  #pin = 1234;

  constructor(owner: string) {
    this.owner = owner;
  }
}
```

| 写法 | 检查/隔离方式 |
| --- | --- |
| `public` | 默认，任何位置可访问 |
| `protected` | 类及其子类可访问 |
| `private` | TypeScript 静态限制，运行时仍是普通属性 |
| `#name` | JavaScript 私有字段，运行时也真正隔离 |

TypeScript 的 `private`/`protected` 会影响类之间的结构兼容性：它们必须来自同一个声明体系。`#private` 由 JavaScript 运行时强制。

## 继承、实现与覆盖

```ts
interface Printable {
  print(): string;
}

class Entity {
  constructor(public readonly id: number) {}
  describe(): string {
    return `Entity(${this.id})`;
  }
}

class UserEntity extends Entity implements Printable {
  constructor(id: number, public name: string) {
    super(id);
  }

  override describe(): string {
    return `User(${this.id}, ${this.name})`;
  }

  print(): string {
    return this.describe();
  }
}
```

- `implements` 只检查实例面是否满足接口，不改变成员类型，也不会生成实现。
- `extends` 继承实现和实例结构。
- `override` 明确成员在覆盖基类成员；配合 `noImplicitOverride` 可捕获重命名后的意外新方法。
- 覆盖方法必须保持兼容契约，不能收窄基类允许的输入。

只声明字段类型、不生成初始化覆盖基类值时使用 `declare`：

```ts
class Animal { resident: object = {} }
class Shelter extends Animal {
  declare resident: { name: string };
}
```

## 抽象类

```ts
abstract class Store<T> {
  abstract get(id: string): Promise<T | undefined>;

  async require(id: string): Promise<T> {
    const value = await this.get(id);
    if (value === undefined) throw new Error(`Missing ${id}`);
    return value;
  }
}
```

抽象类不能直接实例化，但可以包含实现。接受抽象类构造函数时使用：

```ts
type AbstractConstructor<T> = abstract new (...args: any[]) => T;
```

## 静态成员与静态块

```ts
class Registry {
  static readonly entries = new Map<string, unknown>();
  static #ready = false;

  static {
    Registry.#ready = true;
  }

  static isReady() {
    return Registry.#ready;
  }
}
```

静态块按声明顺序执行，可访问私有静态字段。类的静态成员不能引用类的类型参数，因为它们由所有实例共享。

## `this` 类型

```ts
class Query {
  protected parts: string[] = [];

  where(condition: string): this {
    this.parts.push(condition);
    return this;
  }
}

class UserQuery extends Query {
  active(): this {
    return this.where("active = true");
  }
}

new UserQuery().where("role = 'admin'").active();
```

返回 `this` 会保留派生类类型，适合链式 API。

基于 `this` 的守卫：

```ts
class Box<T> {
  value?: T;
  hasValue(): this is this & { value: T } {
    return this.value !== undefined;
  }
}
```

## 类表达式与构造函数类型

```ts
const NamedEntity = class {
  constructor(public name: string) {}
};

type NamedEntityInstance = InstanceType<typeof NamedEntity>;
type NamedEntityConstructor = typeof NamedEntity;
```

`typeof ClassName` 是静态面/构造函数类型，`ClassName` 是实例类型。

## 组合用法：抽象仓库 + 泛型服务

```ts
type Identified = { id: string };

abstract class Repository<T extends Identified> {
  abstract find(id: string): Promise<T | undefined>;
  abstract save(entity: T): Promise<void>;
}

class Service<T extends Identified> {
  constructor(private readonly repository: Repository<T>) {}

  async require(id: string): Promise<T> {
    const entity = await this.repository.find(id);
    if (!entity) throw new Error(`Missing entity: ${id}`);
    return entity;
  }
}
```

这里组合了抽象类、泛型约束、参数属性、可见性、Promise 与控制流收窄。

## 常见坑

- `implements` 不会把接口中的可选性或类型“注入”类成员；类仍需显式声明。
- 将方法作为回调传递可能丢失 `this`；可绑定、包装为箭头函数，或设计为不依赖 `this`。
- 构造函数调用可覆盖的方法时，派生类字段尚未完成初始化。
- `private` 不是运行时安全边界；需要真正私有时使用 `#private`。
