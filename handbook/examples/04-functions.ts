export {};

function timed<Args extends unknown[], Result>(
  fn: (...args: Args) => Result,
  report: (milliseconds: number) => void,
): (...args: Args) => Result {
  return (...args) => {
    const start = performance.now();
    try {
      return fn(...args);
    } finally {
      report(performance.now() - start);
    }
  };
}

const join = timed((a: string, b: string) => `${a}:${b}`, () => undefined);
const result = join("x", "y");

// @ts-expect-error 第二个参数必须是 string
join("x", 1);
void result;
