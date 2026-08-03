export {};

const escaped = RegExp.escape("a.b");
const pattern = new RegExp(`^${escaped}$`, "u");
const match = /(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})/u.exec("2026-08-03");

const formatter = new Intl.DateTimeFormat("zh-CN", {
  dateStyle: "medium",
  timeZone: "UTC",
});
const from = new Date("2026-08-03T00:00:00Z");
const to = new Date("2026-08-04T00:00:00Z");
const range = formatter.formatRange(from, to);

const words = new Intl.Segmenter("zh", { granularity: "word" })
  .segment("TypeScript 很好用");
const duration = new Intl.DurationFormat("zh-CN", { style: "long" })
  .format({ hours: 1, minutes: 5 });

void [pattern, match?.groups?.year, range, words, duration];
