export {};

const cache = new Map<string, string[]>();
cache.getOrInsertComputed("users", () => []).push("Ada");

const left = new Set([1, 2]);
const right = new Set([2, 3]);
const union = left.union(right);
const intersection = left.intersection(right);

const grouped = Map.groupBy(
  [{ team: "a", id: 1 }, { team: "a", id: 2 }, { team: "b", id: 3 }],
  (item) => item.team,
);

const target = { count: 0 };
const proxy = new Proxy(target, {
  get(object, key, receiver) {
    return Reflect.get(object, key, receiver);
  },
  set(object, key, value, receiver) {
    return key !== "count" || typeof value === "number"
      ? Reflect.set(object, key, value, receiver)
      : false;
  },
});

void [cache, union, intersection, grouped, proxy];
