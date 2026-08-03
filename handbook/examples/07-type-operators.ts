export {};

type Events = {
  connected: { at: Date };
  message: { body: string };
};

type ListenerMethods<T extends object> = {
  [K in keyof T as `on${Capitalize<string & K>}`]:
    (handler: (event: T[K]) => void) => () => void;
};

const listeners: ListenerMethods<Events> = {
  onConnected(handler) {
    handler({ at: new Date() });
    return () => undefined;
  },
  onMessage(handler) {
    handler({ body: "hello" });
    return () => undefined;
  },
};

type ToSingleArray<T> = [T] extends [unknown] ? T[] : never;
const mixed: ToSingleArray<string | number> = ["x", 1];
void [listeners, mixed];
