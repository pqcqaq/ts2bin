# 06. Temporal（ESNext）

Temporal 把“日历日期”“墙上时间”“绝对时间点”“时区时间”“时长”分成不同类型，避免 Date 把它们混在一个对象里。

> 本地 `typescript-go` 将 Temporal 放在 `lib.esnext.temporal.d.ts`。类型可用不代表运行时已原生实现；部署前检查引擎或 polyfill。

## 类型选择

| 类型 | 表示什么 | 典型用途 |
| --- | --- | --- |
| `PlainDate` | 无时区的日历日期 | 生日、账单日 |
| `PlainTime` | 无日期/时区的时间 | 每日营业时间 |
| `PlainDateTime` | 无时区的日期 + 时间 | 尚未指定地点的会议时间 |
| `Instant` | UTC 时间线上的纳秒时间点 | 事件时间戳、存储/排序 |
| `ZonedDateTime` | 时间点 + 时区 + 日历 | 跨 DST 的日程 |
| `Duration` | 年到纳秒的时长 | 相对加减/差值 |
| `PlainYearMonth` | 年月 | 信用卡有效期、月报 |
| `PlainMonthDay` | 月日 | 每年重复纪念日 |

## 创建与 Like 类型

```ts
const date = Temporal.PlainDate.from("2026-08-03");
const time = Temporal.PlainTime.from({ hour: 9, minute: 30 });
const instant = Temporal.Instant.from("2026-08-03T01:30:00Z");
```

`PlainDateLike`、`InstantLike`、`DurationLike` 等通常接受同类实例、结构化对象或标准字符串。公共边界优先 `Type.from(input)`，集中处理解析与选项。

每类构造器通常提供：

- `from(item, options?)`：规范化输入。
- `compare(one, two)`：返回负数/0/正数。
- `new (...)`：底层分量构造，业务代码通常用 `from` 更清楚。

Temporal 对象不可变；`with`、`add`、`round` 等都返回新对象。

## `Temporal.Now`

| 方法 | 返回 |
| --- | --- |
| `timeZoneId()` | 系统时区标识 |
| `instant()` | 当前 Instant |
| `plainDateISO(timeZone?)` | 指定时区的当前 ISO 日期 |
| `plainTimeISO(timeZone?)` | 指定时区的当前 ISO 时间 |
| `plainDateTimeISO(timeZone?)` | 指定时区的当前 ISO 日期时间 |
| `zonedDateTimeISO(timeZone?)` | 指定时区的当前 ZonedDateTime |

测试不应直接散落调用 `Temporal.Now`；把“当前时间”封装成可注入的 clock。

## `PlainDate`

```ts
const date = Temporal.PlainDate.from("2026-08-03");
const nextMonth = date.add({ months: 1 });
const days = date.until(nextMonth, { largestUnit: "day" });
```

属性：

`calendarId`、`era`、`eraYear`、`year`、`month`、`monthCode`、`day`、`dayOfWeek`、`dayOfYear`、`weekOfYear`、`yearOfWeek`、`daysInWeek`、`daysInMonth`、`daysInYear`、`monthsInYear`、`inLeapYear`。

方法：

| 类别 | 方法 |
| --- | --- |
| 修改副本 | `with`、`withCalendar`、`add`、`subtract` |
| 比较/差值 | `equals`、`until`、`since`；静态 `compare` |
| 转换 | `toPlainDateTime`、`toPlainMonthDay`、`toPlainYearMonth`、`toZonedDateTime` |
| 输出 | `toString`、`toJSON`、`toLocaleString` |

`overflow: "constrain" | "reject"` 控制无效日期（如 2 月 31 日）是约束到有效范围还是抛错。

## `PlainTime`

属性：`hour`、`minute`、`second`、`millisecond`、`microsecond`、`nanosecond`。

方法：`with`、`add`、`subtract`、`until`、`since`、`round`、`equals`、`toString`、`toJSON`、`toLocaleString`；静态 `from`、`compare`。

```ts
const opening = Temporal.PlainTime.from("09:30");
const rounded = opening.add({ minutes: 17 }).round({ smallestUnit: "minute", roundingIncrement: 15 });
```

PlainTime 没有日期，跨过午夜的加减会环绕；需要知道“哪一天”时组合成 PlainDateTime。

## `PlainDateTime`

拥有 PlainDate 与 PlainTime 的全部日期/时间属性。

方法：`with`、`withCalendar`、`withPlainTime`、`add`、`subtract`、`until`、`since`、`round`、`equals`、`toPlainDate`、`toPlainTime`、`toZonedDateTime`、`toString`、`toJSON`、`toLocaleString`；静态 `from`、`compare`。

```ts
const localMeeting = Temporal.PlainDateTime.from("2026-08-03T09:30");
const scheduled = localMeeting.toZonedDateTime("Asia/Shanghai");
```

将本地时间映射到时区时可能遇到 DST 重复/缺失时间，使用 `disambiguation: "compatible" | "earlier" | "later" | "reject"` 决定策略。

## `Instant`

属性：`epochMilliseconds: number`、`epochNanoseconds: bigint`。

方法：`add`、`subtract`、`until`、`since`、`round`、`equals`、`toZonedDateTimeISO`、`toString`、`toJSON`、`toLocaleString`；静态 `from`、`fromEpochMilliseconds`、`fromEpochNanoseconds`、`compare`。

```ts
const instant = Temporal.Instant.from("2026-08-03T01:30:00Z");
const shanghai = instant.toZonedDateTimeISO("Asia/Shanghai");
```

Instant 不包含日历或时区。它适合存储、排序和传输；展示前转 ZonedDateTime 或交给 Intl。

`Date#toTemporalInstant()` 与 `Temporal.Instant.fromEpochMilliseconds(date.getTime())` 可从有效 Date 转换。

## `ZonedDateTime`

核心属性：`epochMilliseconds`、`epochNanoseconds`、`timeZoneId`、`offset`、`offsetNanoseconds`、`calendarId`、`hoursInDay`，再加全部日历和墙上时间字段。

方法：

| 类别 | 方法 |
| --- | --- |
| 修改副本 | `with`、`withCalendar`、`withTimeZone`、`withPlainTime`、`add`、`subtract` |
| 比较/差值 | `equals`、`until`、`since`、`round`；静态 `compare` |
| 时区 | `startOfDay`、`getTimeZoneTransition` |
| 转换 | `toInstant`、`toPlainDate`、`toPlainTime`、`toPlainDateTime` |
| 输出 | `toString`、`toJSON`、`toLocaleString` |

```ts
const beforeDst = Temporal.ZonedDateTime.from(
  "2026-03-07T12:00-05:00[America/New_York]",
);

const sameWallTimeNextDay = beforeDst.add({ days: 1 });
const exactly24HoursLater = beforeDst.add({ hours: 24 });
```

跨夏令时边界时“一日”按日历算术保持墙上时间，“24 小时”按精确时长移动时间点，结果可能不同。

`ZonedDateTime.from` 还支持：

- `disambiguation`：重复/缺失墙上时间策略。
- `offset: "use" | "ignore" | "prefer" | "reject"`：字符串偏移与时区规则冲突时的策略。
- `overflow`：字段越界策略。

## `Duration`

属性：`years`、`months`、`weeks`、`days`、`hours`、`minutes`、`seconds`、`milliseconds`、`microseconds`、`nanoseconds`、`sign`、`blank`。

方法：`with`、`add`、`subtract`、`negated`、`abs`、`round`、`total`、`toString`、`toJSON`、`toLocaleString`；静态 `from`、`compare`。

```ts
const duration = Temporal.Duration.from({ hours: 1, minutes: 30 });
duration.total("minutes"); // 90

const month = Temporal.Duration.from({ months: 1 });
month.total({ unit: "days", relativeTo: "2026-02-01" });
```

年/月/周/日的实际长度依赖日历和起点。转换或比较涉及日历单位时需要 `relativeTo`，否则无法唯一回答“一月是多少天”。

## `PlainYearMonth`

属性：`calendarId`、`era`、`eraYear`、`year`、`month`、`monthCode`、`daysInMonth`、`daysInYear`、`monthsInYear`、`inLeapYear`。

方法：`with`、`add`、`subtract`、`until`、`since`、`equals`、`toPlainDate({ day })`、`toString`、`toJSON`、`toLocaleString`；静态 `from`、`compare`。

```ts
const billingMonth = Temporal.PlainYearMonth.from("2026-08");
const lastDay = billingMonth.toPlainDate({ day: billingMonth.daysInMonth });
```

## `PlainMonthDay`

属性：`calendarId`、`monthCode`、`day`。

方法：`with`、`equals`、`toPlainDate({ year })`、`toString`、`toJSON`、`toLocaleString`；静态 `from`。

```ts
const birthday = Temporal.PlainMonthDay.from("--08-03");
const in2026 = birthday.toPlainDate({ year: 2026 });
```

## 通用舍入与输出选项

常见选项：

- `smallestUnit` / `largestUnit`。
- `roundingIncrement`。
- `roundingMode`：`ceil`、`floor`、`expand`、`trunc`、`halfCeil`、`halfFloor`、`halfExpand`、`halfTrunc`、`halfEven`。
- `fractionalSecondDigits`。
- `calendarName`、`timeZoneName`、`offset`。

所有主要 Temporal 对象的 `valueOf(): never`，因此不能用 `<`、`>`、`+` 做隐式比较/算术。使用 `equals`、静态 `compare`、`add`/`subtract`/`until`。

```ts
const dates = [
  Temporal.PlainDate.from("2026-08-03"),
  Temporal.PlainDate.from("2025-01-01"),
].toSorted(Temporal.PlainDate.compare);
```

## 组合用法：存 Instant，展示 ZonedDateTime

```ts
type Event = {
  id: string;
  occurredAt: Temporal.Instant;
};

function display(event: Event, timeZone: string, locale: string) {
  const zoned = event.occurredAt.toZonedDateTimeISO(timeZone);
  return zoned.toLocaleString(locale, {
    dateStyle: "medium",
    timeStyle: "long",
  });
}
```

存储层保持唯一时间点，展示层才加入用户时区和 locale，可避免服务器本地时区泄漏到业务数据。

## 常见坑

- PlainDateTime 没有时区，不能直接代表唯一时间点。
- Duration 的月/年不能无上下文地转换为秒或天。
- `withTimeZone` 保持同一 Instant，只改变墙上显示；从 PlainDateTime 选择时区是在创建 Instant。
- Temporal 是 ESNext；公共库使用前要声明运行时/polyfill 前提。
- 不要用 `as Temporal.Instant` 包装字符串；用 `Temporal.Instant.from` 做真实解析。
