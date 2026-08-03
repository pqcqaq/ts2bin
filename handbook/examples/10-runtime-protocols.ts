export {};

enum Status {
  Pending,
  Done = 10,
}

class Lines implements Iterable<string>, Disposable {
  #closed = false;

  constructor(private readonly values: readonly string[]) {}

  *[Symbol.iterator](): Iterator<string> {
    if (this.#closed) throw new Error("Already closed");
    yield* this.values;
  }

  [Symbol.dispose](): void {
    this.#closed = true;
  }
}

function readAll(): string[] {
  using lines = new Lines(["a", "b"]);
  return [...lines];
}

void [Status.Done, readAll()];
