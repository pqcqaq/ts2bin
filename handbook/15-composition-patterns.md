# 15. 组合用法

本章不引入新语法，而是把前面章节的语法组合成可维护的边界。核心原则：运行时事实由值和验证器负责，静态关系由类型负责，配置尽量成为唯一事实源。

## 1. 外部输入：`unknown` + 守卫 + Result

```ts
type User = {
  id: string;
  name: string;
};

type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

function isUser(value: unknown): value is User {
  if (typeof value !== "object" || value === null) return false;
  const record = value as Record<string, unknown>;
  return typeof record.id === "string" && typeof record.name === "string";
}

function parseUser(text: string): Result<User> {
  try {
    const value: unknown = JSON.parse(text);
    return isUser(value)
      ? { ok: true, value }
      : { ok: false, error: new Error("Invalid user") };
  } catch (error) {
    return {
      ok: false,
      error: error instanceof Error ? error : new Error(String(error)),
    };
  }
}
```

组合点：`unknown`、类型守卫、判别联合、catch 收窄、泛型默认参数。与直接 `JSON.parse(text) as User` 相比，这个类型来自真实运行时检查。

## 2. 从路由配置推导调用类型

```ts
type PathParams<Path extends string> =
  Path extends `${string}:${infer Name}/${infer Rest}`
    ? Record<Name, string> & PathParams<`/${Rest}`>
    : Path extends `${string}:${infer Name}`
      ? Record<Name, string>
      : {};

function defineRoutes<const T extends Record<
  string,
  { method: "GET" | "POST"; path: `/${string}` }
>>(routes: T): T {
  return routes;
}

const routes = defineRoutes({
  getUser: { method: "GET", path: "/users/:id" },
  getPost: { method: "GET", path: "/users/:userId/posts/:postId" },
  createUser: { method: "POST", path: "/users" },
});

type RouteName = keyof typeof routes;
type ParamsFor<N extends RouteName> = PathParams<(typeof routes)[N]["path"]>;

function navigate<N extends RouteName>(name: N, params: ParamsFor<N>) {
  return { name, params };
}

navigate("getUser", { id: "1" });
navigate("getPost", { userId: "1", postId: "2" });
```

组合点：`const` 类型参数、模板字面量条件类型、`infer`、递归、交叉、`keyof`、索引访问。实际项目应为可选参数、通配符和 URL 编码设置清晰边界；不要尝试在类型层完整重写路由解析器。

## 3. 事件映射同时生成 emit/on API

```ts
type Events = {
  connected: { at: Date };
  message: { from: string; body: string };
  closed: { code: number; reason?: string };
};

interface EventBus<E extends object> {
  emit<K extends keyof E>(type: K, event: E[K]): void;
  on<K extends keyof E>(type: K, handler: (event: E[K]) => void): () => void;
}

type NamedListeners<E extends object> = {
  [K in keyof E as `on${Capitalize<string & K>}`]:
    (handler: (event: E[K]) => void) => () => void;
};

type Client = EventBus<Events> & NamedListeners<Events>;

declare const client: Client;
client.emit("message", { from: "Ada", body: "hello" });
client.onClosed((event) => console.log(event.code));
```

组合点：相关泛型、映射类型、键重映射、模板字面量类型、`Capitalize`、交叉类型。

## 4. 状态机：让非法状态不可表示

```ts
type State<T> =
  | { status: "idle" }
  | { status: "loading"; requestId: string }
  | { status: "success"; data: T }
  | { status: "error"; error: Error };

type Action<T> =
  | { type: "start"; requestId: string }
  | { type: "resolve"; data: T }
  | { type: "reject"; error: Error }
  | { type: "reset" };

function reducer<T>(state: State<T>, action: Action<T>): State<T> {
  switch (action.type) {
    case "start": return { status: "loading", requestId: action.requestId };
    case "resolve": return { status: "success", data: action.data };
    case "reject": return { status: "error", error: action.error };
    case "reset": return { status: "idle" };
    default: return assertNever(action);
  }
}

function assertNever(value: never): never {
  throw new Error(`Unexpected value: ${JSON.stringify(value)}`);
}
```

不要用 `{ loading: boolean; data?: T; error?: Error }` 表达互斥状态，那会允许 `loading=true`、同时有 data 和 error 等非法组合。

## 5. `satisfies` 配置表 + 派生联合

```ts
type FeatureConfig = {
  enabled: boolean;
  roles: readonly ("admin" | "editor" | "reader")[];
};

const features = {
  dashboard: { enabled: true, roles: ["admin", "editor"] },
  audit: { enabled: false, roles: ["admin"] },
} as const satisfies Record<string, FeatureConfig>;

type FeatureName = keyof typeof features;
type EnabledFeature = {
  [K in FeatureName]: (typeof features)[K]["enabled"] extends true ? K : never;
}[FeatureName];
// "dashboard"
```

`as const` 保留字面量，`satisfies` 检查统一契约，映射 + 索引访问过滤出启用键。运行时仍直接遍历同一个 `features` 对象。

## 6. 类型安全的命令注册表

```ts
type CommandMap = {
  create: { input: { name: string }; output: { id: string } };
  rename: { input: { id: string; name: string }; output: void };
};

type Handlers<C extends Record<string, { input: unknown; output: unknown }>> = {
  [K in keyof C]: (input: C[K]["input"]) => Promise<C[K]["output"]>;
};

const handlers = {
  async create(input: { name: string }) {
    return { id: `${input.name}-1` };
  },
  async rename(_input: { id: string; name: string }) {},
} satisfies Handlers<CommandMap>;

async function execute<K extends keyof CommandMap>(
  command: K,
  input: CommandMap[K]["input"],
): Promise<CommandMap[K]["output"]> {
  const handler = handlers[command] as (
    value: CommandMap[K]["input"],
  ) => Promise<CommandMap[K]["output"]>;
  return handler(input);
}
```

实现处的局部断言来自 TypeScript 对“泛型键索引多个相关属性”分析的限制。把断言限制在注册表内部，并用对外签名和测试守住边界。

## 7. 品牌类型隔离同构 ID

```ts
declare const brand: unique symbol;
type Brand<T, Name extends string> = T & { readonly [brand]: Name };

type UserId = Brand<string, "UserId">;
type OrderId = Brand<string, "OrderId">;

function userId(value: string): UserId {
  if (!/^usr_[a-z0-9]+$/u.test(value)) throw new Error("Invalid UserId");
  return value as UserId;
}

function loadUser(id: UserId) {}

loadUser(userId("usr_123"));
```

品牌只在类型层区分相同底层类型。构造函数必须包含真实验证，否则品牌只是更隐蔽的断言。

## 8. 保留函数签名的中间件

```ts
function withLogging<Args extends unknown[], Result>(
  fn: (...args: Args) => Result,
): (...args: Args) => Result {
  return (...args) => {
    console.log("args", args);
    return fn(...args);
  };
}

function withRetry<Args extends unknown[], Result>(
  fn: (...args: Args) => Promise<Result>,
  retries: number,
): (...args: Args) => Promise<Result> {
  return async (...args) => {
    let lastError: unknown;
    for (let attempt = 0; attempt <= retries; attempt++) {
      try {
        return await fn(...args);
      } catch (error) {
        lastError = error;
      }
    }
    throw lastError;
  };
}
```

元组泛型保存参数列表，Result 保存返回关系。重试只适合幂等或有明确幂等键的操作，这是类型无法自动证明的业务不变量。

## 9. 类工厂/mixin 组合能力

```ts
type Constructor<T = object> = new (...args: any[]) => T;

function Timestamped<TBase extends Constructor>(Base: TBase) {
  return class extends Base {
    readonly createdAt = new Date();
  };
}

function Activatable<TBase extends Constructor>(Base: TBase) {
  return class extends Base {
    active = false;
    activate() { this.active = true; }
  };
}

class Entity {
  constructor(public readonly id: string) {}
}

class Model extends Activatable(Timestamped(Entity)) {}
```

适合正交能力组合；复杂依赖、需要覆盖冲突或大量静态成员时，显式组合对象通常比深层 mixin 更清楚。

## 10. 插件通过模块增强扩展契约

核心包声明：

```ts
export interface CommandRegistry {}

export type CommandName = keyof CommandRegistry;
export type CommandInput<K extends CommandName> = CommandRegistry[K];
```

插件声明：

```ts
import "app-core";

declare module "app-core" {
  interface CommandRegistry {
    "sync:run": { force: boolean };
  }
}
```

这适合确实开放扩展点的库。应用内部更简单的联合/对象表通常更容易追踪；模块增强还必须有对应运行时注册。

## 组合边界

- 能从值推导就用 `typeof`，避免手写重复类型。
- 外部输入必须运行时验证，不能用高级类型假装已验证。
- 将复杂条件/映射类型命名并分层，错误信息会更可读。
- 类型级字符串解析只处理有限、稳定语法；完整解析交给运行时库或代码生成。
- 局部断言可以接受，但要能解释原因并限制在实现边界。
- 一旦类型比业务规则更难理解，退回判别联合、显式重载或生成代码。
