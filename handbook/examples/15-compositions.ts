export {};

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
});

type RouteName = keyof typeof routes;
type ParamsFor<N extends RouteName> = PathParams<(typeof routes)[N]["path"]>;

function navigate<N extends RouteName>(name: N, params: ParamsFor<N>) {
  return { name, params };
}

navigate("getUser", { id: "1" });
navigate("getPost", { userId: "1", postId: "2" });
// @ts-expect-error getUser 需要 id
navigate("getUser", {});

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

function reducer<T>(_state: State<T>, action: Action<T>): State<T> {
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

void reducer<string>({ status: "idle" }, { type: "resolve", data: "done" });
