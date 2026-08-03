export {};

type Method = "GET" | "POST";
type Command = [name: string, verbose?: boolean, ...args: string[]];

const method: Method = "GET";
const command: Command = ["build", true, "src"];

type Handler = (input: unknown) => Promise<unknown>;
const routes = {
  "GET /users": async () => [],
  "POST /users": async (input: unknown) => input,
} satisfies Record<string, Handler>;

type Route = keyof typeof routes;
const route: Route = "GET /users";

// @ts-expect-error 不是已定义的路由
const invalidRoute: Route = "DELETE /users";
void [method, command, route, invalidRoute];
