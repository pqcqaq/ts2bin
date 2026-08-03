export {};

function loggedMethod<This, Args extends unknown[], Return>(
  target: (this: This, ...args: Args) => Return,
  context: ClassMethodDecoratorContext<This, (this: This, ...args: Args) => Return>,
) {
  const name = String(context.name);
  return function (this: This, ...args: Args): Return {
    console.log(`enter ${name}`);
    return target.call(this, ...args);
  };
}

function trim(
  _target: undefined,
  _context: ClassFieldDecoratorContext<unknown, string>,
) {
  return (initialValue: string) => initialValue.trim();
}

class Greeter {
  @trim
  prefix = "  Hello  ";

  @loggedMethod
  greet(name: string): string {
    return `${this.prefix} ${name}`;
  }
}

void new Greeter().greet("Ada");
