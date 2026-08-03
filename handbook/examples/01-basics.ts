export {};

type Config = { port: number; host: string };

function isConfig(value: unknown): value is Config {
  if (typeof value !== "object" || value === null) return false;
  const item = value as Record<string, unknown>;
  return typeof item.port === "number" && typeof item.host === "string";
}

const raw: unknown = JSON.parse('{"port":3000,"host":"localhost"}');
if (!isConfig(raw)) throw new Error("Invalid config");

const endpoint = `${raw.host}:${raw.port}`;
const [host, portText] = endpoint.split(":");
const port = Number(portText ?? "0");
void [host, port];
