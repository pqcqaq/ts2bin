# 11. 装饰器

本章默认讲 TypeScript 5.0 起支持的 ECMAScript 标准装饰器语义。它与 `experimentalDecorators` 下的旧式装饰器不是同一套 API。

## 最小方法装饰器

```ts
function loggedMethod<This, Args extends unknown[], Return>(
  target: (this: This, ...args: Args) => Return,
  context: ClassMethodDecoratorContext<
    This,
    (this: This, ...args: Args) => Return
  >,
) {
  const name = String(context.name);

  return function (this: This, ...args: Args): Return {
    console.log(`enter ${name}`);
    return target.call(this, ...args);
  };
}

class Greeter {
  @loggedMethod
  greet(name: string) {
    return `Hello ${name}`;
  }
}
```

装饰器接收被装饰值和上下文，可返回替换值。泛型保留原方法的 `this`、参数和返回类型。

## 可装饰位置与上下文

| 位置 | 典型上下文 | 可返回内容 |
| --- | --- | --- |
| 类 | `ClassDecoratorContext` | 替换类 |
| 方法 | `ClassMethodDecoratorContext` | 替换方法 |
| getter | `ClassGetterDecoratorContext` | 替换 getter |
| setter | `ClassSetterDecoratorContext` | 替换 setter |
| 字段 | `ClassFieldDecoratorContext` | 字段初始化转换函数 |
| `accessor` | `ClassAccessorDecoratorContext` | `get`/`set`/`init` 组成的对象 |

上下文常用属性：

- `kind`：`"class"`、`"method"`、`"field"` 等。
- `name`：字符串或符号成员名。
- `static`、`private`：成员性质。
- `access`：安全访问成员的 `has/get/set` 能力。
- `addInitializer(fn)`：登记额外初始化逻辑。
- `metadata`：支持时访问装饰器元数据容器。

## 装饰器工厂

工厂先接收配置，再返回装饰器：

```ts
function deprecated(message: string) {
  return function <This, Args extends unknown[], Return>(
    target: (this: This, ...args: Args) => Return,
    context: ClassMethodDecoratorContext<This, typeof target>,
  ) {
    return function (this: This, ...args: Args): Return {
      console.warn(`${String(context.name)}: ${message}`);
      return target.call(this, ...args);
    };
  };
}
```

使用：`@deprecated("use newMethod instead")`。

## 字段与自动访问器

字段装饰器返回初始化函数：

```ts
function trim(
  _target: undefined,
  _context: ClassFieldDecoratorContext<unknown, string>,
) {
  return (initialValue: string) => initialValue.trim();
}

class Form {
  @trim
  title = "  hello  ";
}
```

自动访问器装饰器可分别包装读、写和初始化：

```ts
function nonNegative<This>(
  target: ClassAccessorDecoratorTarget<This, number>,
  _context: ClassAccessorDecoratorContext<This, number>,
): ClassAccessorDecoratorResult<This, number> {
  return {
    get: target.get,
    set(value) {
      target.set.call(this, Math.max(0, value));
    },
  };
}

class Counter {
  @nonNegative accessor value = 0;
}
```

## 绑定方法

`addInitializer` 可在实例初始化时绑定方法：

```ts
function bound<This, Args extends unknown[], Return>(
  _target: (this: This, ...args: Args) => Return,
  context: ClassMethodDecoratorContext<This>,
) {
  if (context.private) throw new Error("@bound cannot decorate private members");
  context.addInitializer(function () {
    const self = this as Record<PropertyKey, unknown>;
    self[context.name] = (self[context.name] as Function).bind(this);
  });
}
```

实际代码应进一步收紧内部断言并测试继承行为。

## 组合与求值顺序

```ts
@first
@second
class Example {}
```

装饰器表达式从上到下求值，应用/调用通常从下到上：`second` 先包装目标，`first` 再包装结果。多个装饰器共享状态时要明确顺序。

标准装饰器可放在 `export` 前或后，但同一声明不要混用两种位置风格。

## 类装饰器与类型

```ts
function tagged<T extends abstract new (...args: any[]) => object>(Base: T) {
  abstract class Tagged extends Base {
    readonly tag = "service";
  }
  return Tagged;
}
```

装饰器替换类时，TypeScript 不会自动让声明位置的类类型获得新增成员。若调用方需要这些成员，优先使用显式工厂/mixin，或另外声明清楚的接口契约。

## 标准与旧式装饰器对比

| 项目 | 标准装饰器 | 旧式实验装饰器 |
| --- | --- | --- |
| 开关 | 默认语法支持 | `experimentalDecorators: true` |
| 签名 | `(value, context)` | `(target, key, descriptor/index)` |
| 参数装饰器 | 不支持 | 支持 |
| 元数据输出 | 不使用旧 `emitDecoratorMetadata` | 可配合 `emitDecoratorMetadata` |
| `addInitializer` | 支持 | 不支持同一上下文 API |
| 与 `export` 的位置 | 标准规则 | 旧规则不同 |

许多依赖注入框架仍要求旧式装饰器和 `reflect-metadata`。迁移前必须确认框架版本，不能只删除编译选项。

## 组合用法：可测量的方法

```ts
function measured<This, Args extends unknown[], Return>(
  target: (this: This, ...args: Args) => Return,
  context: ClassMethodDecoratorContext<This, typeof target>,
) {
  return function (this: This, ...args: Args): Return {
    const start = performance.now();
    try {
      return target.call(this, ...args);
    } finally {
      console.log(String(context.name), performance.now() - start);
    }
  };
}
```

装饰器适合横切行为，但业务数据验证、权限判断等核心流程通常用显式函数更容易测试和追踪。

## 常见坑

- 标准与旧式装饰器签名不可混用；先确认 `tsconfig` 和框架要求。
- 装饰器能改变运行时行为，类型声明却未必自动反映新增成员。
- 在装饰器中丢失 `this`、参数或返回类型会让 API 退化成 `any`；使用泛型完整保留签名。
- 装饰器执行顺序、继承和字段初始化顺序要有测试，不要只靠直觉。
