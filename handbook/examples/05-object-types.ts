export {};

const endpoints = {
  getUser: { method: "GET", path: "/users/:id" },
  createUser: { method: "POST", path: "/users" },
} as const satisfies Record<
  string,
  { method: "GET" | "POST"; path: `/${string}` }
>;

type EndpointName = keyof typeof endpoints;
type Endpoint<N extends EndpointName> = (typeof endpoints)[N];

const getUser: Endpoint<"getUser"> = endpoints.getUser;
// @ts-expect-error getUser 的方法被保留为字面量 GET
const wrong: Endpoint<"getUser"> = { method: "POST", path: "/users/:id" };
void [getUser, wrong];
