export {};

async function promiseExamples() {
  const result = await Promise.try(JSON.parse, '{"ok":true}');
  const { promise, resolve } = Promise.withResolvers<string>();
  resolve("ready");
  return [result, await promise] as const;
}

const values = Iterator.from([1, 2, 3, 4])
  .filter((value) => value % 2 === 0)
  .map((value) => value * 10)
  .take(2)
  .toArray();

class Resource implements Disposable {
  disposed = false;
  [Symbol.dispose](): void {
    this.disposed = true;
  }
}

function manage() {
  using stack = new DisposableStack();
  const resource = stack.use(new Resource());
  stack.defer(() => undefined);
  return resource.disposed;
}

void [promiseExamples, values, manage()];
