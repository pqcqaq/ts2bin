export {};

type Result<T> =
  | { ok: true; data: T }
  | { ok: false; error: Error };

function unwrap<T>(result: Result<T>): T {
  if (result.ok) return result.data;
  throw result.error;
}

type Command =
  | { type: "create"; name: string }
  | { type: "rename"; id: number; name: string }
  | { type: "delete"; id: number };

function execute(command: Command): string {
  switch (command.type) {
    case "create": return `create:${command.name}`;
    case "rename": return `rename:${command.id}:${command.name}`;
    case "delete": return `delete:${command.id}`;
    default: return assertNever(command);
  }
}

function assertNever(value: never): never {
  throw new Error(`Unexpected command: ${JSON.stringify(value)}`);
}

void [unwrap<string>({ ok: true, data: "done" }), execute({ type: "delete", id: 1 })];
