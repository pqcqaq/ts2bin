import defer * as feature from "./modules/feature.js";

function defineRoutes<const T extends Record<string, `/${string}`>>(routes: T): T {
  return routes;
}

const routes = defineRoutes({ home: "/", users: "/users" });
const started = feature.start();
void [routes, started];
