export {};

const date = Temporal.PlainDate.from("2026-08-03");
const nextMonth = date.add({ months: 1 });
const difference = date.until(nextMonth, { largestUnit: "month" });

const instant = Temporal.Instant.from("2026-08-03T01:30:00Z");
const shanghai = instant.toZonedDateTimeISO("Asia/Shanghai");

const duration = Temporal.Duration.from({ hours: 1, minutes: 30 });
const minutes = duration.total("minutes");

const birthday = Temporal.PlainMonthDay.from("--08-03");
const birthday2026 = birthday.toPlainDate({ year: 2026 });

void [date, nextMonth, difference, shanghai, minutes, birthday2026];
