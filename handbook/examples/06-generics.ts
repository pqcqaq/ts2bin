export {};

function tuple<const T extends readonly unknown[]>(...values: T): T {
  return values;
}

const point = tuple("point", 10, 20);

type EventMap = {
  connected: { at: Date };
  message: { from: string; body: string };
};

interface EventBus<Events extends object> {
  on<K extends keyof Events>(type: K, handler: (event: Events[K]) => void): () => void;
  emit<K extends keyof Events>(type: K, event: Events[K]): void;
}

declare const bus: EventBus<EventMap>;
bus.emit("message", { from: "Ada", body: "hello" });
// @ts-expect-error message 事件缺少 from
bus.emit("message", { body: "hello" });
void point;
