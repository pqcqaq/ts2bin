# 05. 正则、日期与国际化

## `RegExp`

```ts
const pattern = new RegExp(RegExp.escape("a.b"), "giu");
const match = pattern.exec("A.B");
```

构造器参数：`new RegExp(pattern?, flags?)`，其中 `pattern` 可是字符串或已有 RegExp。

实例属性：

`dotAll`、`flags`、`global`、`hasIndices`、`ignoreCase`、`indices`（匹配结果）、`lastIndex`、`multiline`、`source`、`sticky`、`unicode`、`unicodeSets`。

实例方法：

| 方法/协议 | 作用 |
| --- | --- |
| `exec(input)` | 返回详细匹配结果或 `null` |
| `test(input)` | 只返回 boolean |
| `compile(pattern, flags?)` | 旧式重新编译，现代代码不使用 |
| `toString()` | `/pattern/flags` |
| `Symbol.match` | `String#match` 协议 |
| `Symbol.matchAll` | `String#matchAll` 协议 |
| `Symbol.replace` | `String#replace/replaceAll` 协议 |
| `Symbol.search` | `String#search` 协议 |
| `Symbol.split` | `String#split` 协议 |

匹配结果：`RegExpExecArray`/`RegExpMatchArray` 继承数组，可能有 `index`、`input`、`groups`、`indices`。命名捕获组在 `groups` 中按字符串键访问。

```ts
const datePattern = /(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})/u;
const result = datePattern.exec("2026-08-03");
const year = result?.groups?.year;
```

使用 `g`/`y` 时 `exec`/`test` 会读取并更新 `lastIndex`；复用 RegExp 前确认是否需要重置它。

### `RegExp.escape`（ES2025）

```ts
const userText = "price: $10.00";
const exact = new RegExp(`^${RegExp.escape(userText)}$`, "u");
```

它把正则语法字符和可能造成歧义的开头字符转义，适合把不可信文本嵌入正则。不要手写 `replace(/[.*+?^${}()|[\]\\]/g, "\\$&")` 代替全部规则。

## `Date`

`Date` 内部保存 UTC 毫秒时间戳，实例的无时区 getter/setter 使用宿主本地时区。

静态方法：`Date.now()`、`Date.parse(text)`、`Date.UTC(year, month?, ...)`。

读取方法：

`getTime`、`getTimezoneOffset`、`getFullYear`、`getMonth`、`getDate`、`getDay`、`getHours`、`getMinutes`、`getSeconds`、`getMilliseconds`，以及对应的 `getUTCFullYear`、`getUTCMonth`、`getUTCDate`、`getUTCDay`、`getUTCHours`、`getUTCMinutes`、`getUTCSeconds`、`getUTCMilliseconds`。

写入方法：`setTime`、`setMilliseconds`、`setSeconds`、`setMinutes`、`setHours`、`setDate`、`setMonth`、`setFullYear`，以及 `setUTC*` 对应方法。

格式化/转换：`toDateString`、`toTimeString`、`toString`、`toISOString`、`toJSON`、`toLocaleDateString`、`toLocaleTimeString`、`toLocaleString`、`toUTCString`、`toGMTString`（旧别名）、`valueOf`、`getTime`。

ESNext：`toTemporalInstant()` 把有效 Date 转成 `Temporal.Instant`。

```ts
const instant = new Date("2026-08-03T00:00:00Z");
instant.toISOString();
instant.getUTCDate(); // 稳定，不受本地时区影响
instant.getDate();    // 本地日期，可能是前一天/后一天
```

`Date.parse` 接受格式范围依赖实现，跨环境边界优先使用 ISO 8601；日期只表示日历日期时考虑 `Temporal.PlainDate`。

## Intl 总览

Intl 构造器通常接受 `locales` 和 `options`，实例支持 `resolvedOptions()`；静态 `supportedLocalesOf(locales, options?)` 检查实现支持的 locale。

### `Intl.NumberFormat`

方法：`format`、`formatToParts`、`formatRange`、`formatRangeToParts`、`resolvedOptions`。

```ts
const money = new Intl.NumberFormat("zh-CN", {
  style: "currency",
  currency: "CNY",
});
money.format(1234.5);
money.formatToParts(1234.5);
```

选项包括 `style`（decimal/currency/percent/unit）、`currency`、记数法、有效数字/小数位、分组与符号显示。不要对格式化结果做字符串解析。

### `Intl.DateTimeFormat`

方法：`format`、`formatToParts`、`formatRange`、`formatRangeToParts`、`resolvedOptions`。

```ts
const dateFormatter = new Intl.DateTimeFormat("zh-CN", {
  dateStyle: "medium",
  timeStyle: "short",
  timeZone: "Asia/Shanghai",
});
dateFormatter.formatRange(new Date("2026-08-03"), new Date("2026-08-04"));
```

`timeZone` 要显式指定时区以获得可复现结果；格式器可接受 Date、时间戳及实现支持的 Temporal 对象。

### `Intl.Collator`

实例：`compare(a, b)`、`resolvedOptions()`。

```ts
const collator = new Intl.Collator("zh-CN", { numeric: true });
["item10", "item2"].toSorted(collator.compare);
```

不要直接保存未绑定的 `collator.compare` 并依赖 `this` 行为；构造器返回的 compare 通常适合回调，但包装函数可使意图更清晰。

### `Intl.PluralRules`

实例：`select(value)`、`selectRange(start, end)`、`resolvedOptions()`。

```ts
const plural = new Intl.PluralRules("en", { type: "ordinal" });
plural.select(2); // "two"
```

### `Intl.RelativeTimeFormat`

实例：`format(value, unit)`、`formatToParts(value, unit)`、`resolvedOptions()`。

```ts
new Intl.RelativeTimeFormat("zh-CN", { numeric: "auto" }).format(-1, "day");
```

### `Intl.ListFormat`

实例：`format(list)`、`formatToParts(list)`、`resolvedOptions()`。

```ts
new Intl.ListFormat("zh-CN", { type: "disjunction" }).format(["A", "B", "C"]);
```

### `Intl.DisplayNames`

实例：`of(code)`、`resolvedOptions()`。通过 `type` 选择语言、地区、货币、脚本、日期时区等名称类别，`fallback` 控制未知值行为。

```ts
new Intl.DisplayNames("zh-CN", { type: "region" }).of("CN");
```

### `Intl.Locale`

属性/方法：`baseName`、`language`、`script`、`region`、`calendar`、`collation`、`hourCycle`、`numberingSystem`、`numeric`、`caseFirst`、`textInfo`、`weekInfo`、`timeZones`、`toString`、`maximize`、`minimize`、`getCalendars`、`getCollations`、`getHourCycles`、`getNumberingSystems`、`getTextInfo`、`getTimeZones`、`getWeekInfo`。

```ts
const locale = new Intl.Locale("zh-CN");
const week = locale.getWeekInfo();
```

区域扩展信息可能取决于 ICU 数据版本；不要在业务中硬编码所有地区规则。

### `Intl.Segmenter`

实例：`segment(input)`、`resolvedOptions()`；返回 `Segments`，可 `containing(index)` 或迭代 `SegmentData`（`segment`、`index`、`input`、可选 `isWordLike`）。

```ts
const segmenter = new Intl.Segmenter("zh", { granularity: "word" });
for (const part of segmenter.segment("TypeScript 很好用")) {
  console.log(part.segment, part.index, part.isWordLike);
}
```

### `Intl.DurationFormat`（ES2025）

实例：`format(duration)`、`formatToParts(duration)`、`resolvedOptions()`。

```ts
const duration = new Intl.DurationFormat("zh-CN", {
  style: "digital",
  hours: "numeric",
  minutes: "2-digit",
});
duration.format({ hours: 1, minutes: 5, seconds: 9 });
```

## Intl 全局函数

- `Intl.getCanonicalLocales(locales)`：规范化并去重 BCP 47 locale。
- `Intl.supportedValuesOf(key)`：取得实现支持的 calendar、collation、currency、numberingSystem、timeZone、unit 值。

```ts
Intl.getCanonicalLocales(["zh-cn", "en-us"]);
Intl.supportedValuesOf("timeZone");
```

## 组合用法：稳定解析 + 本地化展示

```ts
function describeRange(input: string, locale: string) {
  const match = /^(?<from>\d{4}-\d{2}-\d{2})\/(?<to>\d{4}-\d{2}-\d{2})$/u.exec(input);
  if (!match?.groups) throw new Error("Invalid range");

  const from = new Date(`${match.groups.from}T00:00:00Z`);
  const to = new Date(`${match.groups.to}T00:00:00Z`);
  return new Intl.DateTimeFormat(locale, { dateStyle: "medium", timeZone: "UTC" })
    .formatRange(from, to);
}
```

正则负责验证形状，Date 负责时间戳，Intl 负责展示；不要把本地化字符串再拿去做日期解析。

## 常见坑

- `Date` 同时包含时间戳、本地时区和 UTC API，混用 getter 会产生跨时区偏移。
- `Intl` 输出是给人看的，不保证稳定机器可读；机器数据使用 ISO/结构化值。
- `RegExp#test` 在全局/粘滞模式会修改 `lastIndex`。
- `Intl.Segmenter` 的 `isWordLike` 是可选属性，并非所有粒度都有。
- ESNext/ES2025 声明只代表类型可见，运行时需对应 V8/SpiderMonkey/JavaScriptCore/Node 版本或 polyfill。
