export {};

function choose<C extends string>(
  choices: readonly C[],
  defaultChoice?: NoInfer<C>,
): C {
  return defaultChoice ?? choices[0]!;
}

const color = choose(["red", "yellow", "green"] as const, "red");
// @ts-expect-error blue 不在 choices 推断出的联合中
choose(["red", "yellow", "green"] as const, "blue");

type Event =
  | { type: "created"; id: string }
  | { type: "updated"; id: string; changes: string[] }
  | { type: "deleted"; id: string };

type EventOf<K extends Event["type"]> = Extract<Event, { type: K }>;
const updated: EventOf<"updated"> = { type: "updated", id: "1", changes: [] };
void [color, updated];
