# ECMAScript 标准库 API 完整索引

> 此文件由 `scripts/generate-stdlib-index.cjs` 从本地 `typescript-go/internal/bundled/libs` 生成。它是声明签名清单，不代替分组教程。聚合文件、DOM、WebWorker 和 ScriptHost 已排除。

- 输入文件：81 个实际声明分项
- 声明类型：314 个
- 全局/命名空间值签名：103 个

## 全局与命名空间值

| 名称 | 类别 | 签名 | 来源 |
| --- | --- | --- | --- |
| `AggregateError` | value | <code>AggregateError: AggregateErrorConstructor</code> | `es2021.promise` |
| `Array` | value | <code>Array: ArrayConstructor</code> | `es5` |
| `ArrayBuffer` | value | <code>ArrayBuffer: ArrayBufferConstructor</code> | `es5` |
| `AsyncDisposableStack` | value | <code>AsyncDisposableStack: AsyncDisposableStackConstructor</code> | `esnext.disposable` |
| `Atomics` | value | <code>Atomics: Atomics</code> | `es2017.sharedmemory` |
| `BigInt` | value | <code>BigInt: BigIntConstructor</code> | `es2020.bigint` |
| `BigInt64Array` | value | <code>BigInt64Array: BigInt64ArrayConstructor</code> | `es2020.bigint` |
| `BigUint64Array` | value | <code>BigUint64Array: BigUint64ArrayConstructor</code> | `es2020.bigint` |
| `Boolean` | value | <code>Boolean: BooleanConstructor</code> | `es5` |
| `DataView` | value | <code>DataView: DataViewConstructor</code> | `es5` |
| `Date` | value | <code>Date: DateConstructor</code> | `es5` |
| `decodeURI` | function | <code>declare function decodeURI(encodedURI: string): string</code> | `es5` |
| `decodeURIComponent` | function | <code>declare function decodeURIComponent(encodedURIComponent: string): string</code> | `es5` |
| `DisposableStack` | value | <code>DisposableStack: DisposableStackConstructor</code> | `esnext.disposable` |
| `encodeURI` | function | <code>declare function encodeURI(uri: string): string</code> | `es5` |
| `encodeURIComponent` | function | <code>declare function encodeURIComponent(uriComponent: string &#124; number &#124; boolean): string</code> | `es5` |
| `Error` | value | <code>Error: ErrorConstructor</code> | `es5` |
| `escape` | function | <code>declare function escape(string: string): string</code> | `es5` |
| `eval` | function | <code>declare function eval(x: string): any</code> | `es5` |
| `EvalError` | value | <code>EvalError: EvalErrorConstructor</code> | `es5` |
| `FinalizationRegistry` | value | <code>FinalizationRegistry: FinalizationRegistryConstructor</code> | `es2021.weakref` |
| `Float16Array` | value | <code>Float16Array: Float16ArrayConstructor</code> | `es2025.float16` |
| `Float32Array` | value | <code>Float32Array: Float32ArrayConstructor</code> | `es5` |
| `Float64Array` | value | <code>Float64Array: Float64ArrayConstructor</code> | `es5` |
| `Function` | value | <code>Function: FunctionConstructor</code> | `es5` |
| `global.Iterator` | value | <code>Iterator: IteratorConstructor</code> | `es2025.iterator` |
| `Infinity` | value | <code>Infinity: number</code> | `es5` |
| `Int16Array` | value | <code>Int16Array: Int16ArrayConstructor</code> | `es5` |
| `Int32Array` | value | <code>Int32Array: Int32ArrayConstructor</code> | `es5` |
| `Int8Array` | value | <code>Int8Array: Int8ArrayConstructor</code> | `es5` |
| `Intl.Collator` | value | <code>Collator: CollatorConstructor</code> | `es5` |
| `Intl.DateTimeFormat` | value | <code>DateTimeFormat: DateTimeFormatConstructor</code> | `es5` |
| `Intl.DisplayNames` | value | <code>DisplayNames: { prototype: DisplayNames; new (locales: LocalesArgument, options: DisplayNamesOptions): DisplayNames; supportedLocalesOf(locales?: LocalesArgument, options?: { localeMatcher?: RelativeTimeFormatLocaleMatcher; }): UnicodeBCP47LocaleIdentifier[]; }</code> | `es2020.intl` |
| `Intl.DurationFormat` | value | <code>DurationFormat: { prototype: DurationFormat; new (locales?: LocalesArgument, options?: DurationFormatOptions): DurationFormat; supportedLocalesOf(locales?: LocalesArgument, options?: { localeMatcher?: DurationFormatLocaleMatcher; }): UnicodeBCP47LocaleIdentifier[]; }</code> | `es2025.intl` |
| `Intl.getCanonicalLocales` | function | <code>function getCanonicalLocales(locale?: string &#124; readonly string[]): string[]</code> | `es2016.intl` |
| `Intl.ListFormat` | value | <code>ListFormat: { prototype: ListFormat; new (locales?: LocalesArgument, options?: ListFormatOptions): ListFormat; supportedLocalesOf(locales: LocalesArgument, options?: Pick&lt;ListFormatOptions, "localeMatcher"&gt;): UnicodeBCP47LocaleIdentifier[]; }</code> | `es2021.intl` |
| `Intl.Locale` | value | <code>Locale: { new (tag: UnicodeBCP47LocaleIdentifier &#124; Locale, options?: LocaleOptions): Locale; }</code> | `es2020.intl` |
| `Intl.NumberFormat` | value | <code>NumberFormat: NumberFormatConstructor</code> | `es5` |
| `Intl.PluralRules` | value | <code>PluralRules: PluralRulesConstructor</code> | `es2018.intl` |
| `Intl.RelativeTimeFormat` | value | <code>RelativeTimeFormat: { new (locales?: LocalesArgument, options?: RelativeTimeFormatOptions): RelativeTimeFormat; supportedLocalesOf(locales?: LocalesArgument, options?: RelativeTimeFormatOptions): UnicodeBCP47LocaleIdentifier[]; }</code> | `es2020.intl` |
| `Intl.Segmenter` | value | <code>Segmenter: { prototype: Segmenter; new (locales?: LocalesArgument, options?: SegmenterOptions): Segmenter; supportedLocalesOf(locales: LocalesArgument, options?: Pick&lt;SegmenterOptions, "localeMatcher"&gt;): UnicodeBCP47LocaleIdentifier[]; }</code> | `es2022.intl` |
| `Intl.supportedValuesOf` | function | <code>function supportedValuesOf(key: "calendar" &#124; "collation" &#124; "currency" &#124; "numberingSystem" &#124; "timeZone" &#124; "unit"): string[]</code> | `es2022.intl` |
| `isFinite` | function | <code>declare function isFinite(number: number): boolean</code> | `es5` |
| `isNaN` | function | <code>declare function isNaN(number: number): boolean</code> | `es5` |
| `JSON` | value | <code>JSON: JSON</code> | `es5` |
| `Map` | value | <code>Map: MapConstructor</code> | `es2015.collection` |
| `Math` | value | <code>Math: Math</code> | `es5` |
| `NaN` | value | <code>NaN: number</code> | `es5` |
| `Number` | value | <code>Number: NumberConstructor</code> | `es5` |
| `Object` | value | <code>Object: ObjectConstructor</code> | `es5` |
| `parseFloat` | function | <code>declare function parseFloat(string: string): number</code> | `es5` |
| `parseInt` | function | <code>declare function parseInt(string: string, radix?: number): number</code> | `es5` |
| `Promise` | value | <code>Promise: PromiseConstructor</code> | `es2015.promise` |
| `Proxy` | value | <code>Proxy: ProxyConstructor</code> | `es2015.proxy` |
| `RangeError` | value | <code>RangeError: RangeErrorConstructor</code> | `es5` |
| `ReferenceError` | value | <code>ReferenceError: ReferenceErrorConstructor</code> | `es5` |
| `Reflect.apply` | function | <code>function apply(target: Function, thisArgument: any, argumentsList: ArrayLike&lt;any&gt;): any</code> | `es2015.reflect` |
| `Reflect.apply` | function | <code>function apply&lt;T, A extends readonly any[], R&gt;(target: (this: T, ...args: A) =&gt; R, thisArgument: T, argumentsList: Readonly&lt;A&gt;): R</code> | `es2015.reflect` |
| `Reflect.construct` | function | <code>function construct(target: Function, argumentsList: ArrayLike&lt;any&gt;, newTarget?: Function): any</code> | `es2015.reflect` |
| `Reflect.construct` | function | <code>function construct&lt;A extends readonly any[], R&gt;(target: new (...args: A) =&gt; R, argumentsList: Readonly&lt;A&gt;, newTarget?: new (...args: any) =&gt; any): R</code> | `es2015.reflect` |
| `Reflect.defineProperty` | function | <code>function defineProperty(target: object, propertyKey: PropertyKey, attributes: PropertyDescriptor &amp; ThisType&lt;any&gt;): boolean</code> | `es2015.reflect` |
| `Reflect.deleteProperty` | function | <code>function deleteProperty(target: object, propertyKey: PropertyKey): boolean</code> | `es2015.reflect` |
| `Reflect.get` | function | <code>function get&lt;T extends object, P extends PropertyKey&gt;(target: T, propertyKey: P, receiver?: unknown): P extends keyof T ? T[P] : any</code> | `es2015.reflect` |
| `Reflect.getOwnPropertyDescriptor` | function | <code>function getOwnPropertyDescriptor&lt;T extends object, P extends PropertyKey&gt;(target: T, propertyKey: P): TypedPropertyDescriptor&lt;P extends keyof T ? T[P] : any&gt; &#124; undefined</code> | `es2015.reflect` |
| `Reflect.getPrototypeOf` | function | <code>function getPrototypeOf(target: object): object &#124; null</code> | `es2015.reflect` |
| `Reflect.has` | function | <code>function has(target: object, propertyKey: PropertyKey): boolean</code> | `es2015.reflect` |
| `Reflect.isExtensible` | function | <code>function isExtensible(target: object): boolean</code> | `es2015.reflect` |
| `Reflect.ownKeys` | function | <code>function ownKeys(target: object): (string &#124; symbol)[]</code> | `es2015.reflect` |
| `Reflect.preventExtensions` | function | <code>function preventExtensions(target: object): boolean</code> | `es2015.reflect` |
| `Reflect.set` | function | <code>function set(target: object, propertyKey: PropertyKey, value: any, receiver?: any): boolean</code> | `es2015.reflect` |
| `Reflect.set` | function | <code>function set&lt;T extends object, P extends PropertyKey&gt;(target: T, propertyKey: P, value: P extends keyof T ? T[P] : any, receiver?: any): boolean</code> | `es2015.reflect` |
| `Reflect.setPrototypeOf` | function | <code>function setPrototypeOf(target: object, proto: object &#124; null): boolean</code> | `es2015.reflect` |
| `RegExp` | value | <code>RegExp: RegExpConstructor</code> | `es5` |
| `Set` | value | <code>Set: SetConstructor</code> | `es2015.collection` |
| `SharedArrayBuffer` | value | <code>SharedArrayBuffer: SharedArrayBufferConstructor</code> | `es2017.sharedmemory` |
| `String` | value | <code>String: StringConstructor</code> | `es5` |
| `SuppressedError` | value | <code>SuppressedError: SuppressedErrorConstructor</code> | `esnext.disposable` |
| `Symbol` | value | <code>Symbol: SymbolConstructor</code> | `es2015.symbol` |
| `SyntaxError` | value | <code>SyntaxError: SyntaxErrorConstructor</code> | `es5` |
| `Temporal.Duration` | value | <code>Duration: DurationConstructor</code> | `esnext.temporal` |
| `Temporal.Instant` | value | <code>Instant: InstantConstructor</code> | `esnext.temporal` |
| `Temporal.Now.instant` | function | <code>function instant(): Instant</code> | `esnext.temporal` |
| `Temporal.Now.plainDateISO` | function | <code>function plainDateISO(timeZone?: TimeZoneLike): PlainDate</code> | `esnext.temporal` |
| `Temporal.Now.plainDateTimeISO` | function | <code>function plainDateTimeISO(timeZone?: TimeZoneLike): PlainDateTime</code> | `esnext.temporal` |
| `Temporal.Now.plainTimeISO` | function | <code>function plainTimeISO(timeZone?: TimeZoneLike): PlainTime</code> | `esnext.temporal` |
| `Temporal.Now.timeZoneId` | function | <code>function timeZoneId(): string</code> | `esnext.temporal` |
| `Temporal.Now.zonedDateTimeISO` | function | <code>function zonedDateTimeISO(timeZone?: TimeZoneLike): ZonedDateTime</code> | `esnext.temporal` |
| `Temporal.PlainDate` | value | <code>PlainDate: PlainDateConstructor</code> | `esnext.temporal` |
| `Temporal.PlainDateTime` | value | <code>PlainDateTime: PlainDateTimeConstructor</code> | `esnext.temporal` |
| `Temporal.PlainMonthDay` | value | <code>PlainMonthDay: PlainMonthDayConstructor</code> | `esnext.temporal` |
| `Temporal.PlainTime` | value | <code>PlainTime: PlainTimeConstructor</code> | `esnext.temporal` |
| `Temporal.PlainYearMonth` | value | <code>PlainYearMonth: PlainYearMonthConstructor</code> | `esnext.temporal` |
| `Temporal.ZonedDateTime` | value | <code>ZonedDateTime: ZonedDateTimeConstructor</code> | `esnext.temporal` |
| `TypeError` | value | <code>TypeError: TypeErrorConstructor</code> | `es5` |
| `Uint16Array` | value | <code>Uint16Array: Uint16ArrayConstructor</code> | `es5` |
| `Uint32Array` | value | <code>Uint32Array: Uint32ArrayConstructor</code> | `es5` |
| `Uint8Array` | value | <code>Uint8Array: Uint8ArrayConstructor</code> | `es5` |
| `Uint8ClampedArray` | value | <code>Uint8ClampedArray: Uint8ClampedArrayConstructor</code> | `es5` |
| `unescape` | function | <code>declare function unescape(string: string): string</code> | `es5` |
| `URIError` | value | <code>URIError: URIErrorConstructor</code> | `es5` |
| `WeakMap` | value | <code>WeakMap: WeakMapConstructor</code> | `es2015.collection` |
| `WeakRef` | value | <code>WeakRef: WeakRefConstructor</code> | `es2021.weakref` |
| `WeakSet` | value | <code>WeakSet: WeakSetConstructor</code> | `es2015.collection` |

## 类型与成员

### `AggregateError`

类别：interface。来源：`es2021.promise`。

```ts
interface AggregateError extends Error { ... }
```

声明来源：`es2021.promise`。

| 成员签名 | 来源 |
| --- | --- |
| <code>errors: any[]</code> | `es2021.promise` |

### `AggregateErrorConstructor`

类别：interface。来源：`es2021.promise`、`es2022.error`。

```ts
interface AggregateErrorConstructor { ... }
```

声明来源：`es2021.promise`、`es2022.error`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(errors: Iterable&lt;any&gt;, message?: string, options?: ErrorOptions): AggregateError</code> | `es2022.error` |
| <code>(errors: Iterable&lt;any&gt;, message?: string): AggregateError</code> | `es2021.promise` |
| <code>new (errors: Iterable&lt;any&gt;, message?: string, options?: ErrorOptions): AggregateError</code> | `es2022.error` |
| <code>new (errors: Iterable&lt;any&gt;, message?: string): AggregateError</code> | `es2021.promise` |
| <code>readonly prototype: AggregateError</code> | `es2021.promise` |

### `Array`

类别：interface。来源：`es2015.core`、`es2015.iterable`、`es2019.array`、`es2022.array`、`es2023.array`、`es5`。

```ts
interface Array<T> { ... }
```

声明来源：`es2015.core`、`es2015.iterable`、`es2019.array`、`es2022.array`、`es2023.array`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[n: number]: T</code> | `es5` |
| <code>[Symbol.iterator](): ArrayIterator&lt;T&gt;</code> | `es2015.iterable` |
| <code>at(index: number): T &#124; undefined</code> | `es2022.array` |
| <code>concat(...items: (T &#124; ConcatArray&lt;T&gt;)[]): T[]</code> | `es5` |
| <code>concat(...items: ConcatArray&lt;T&gt;[]): T[]</code> | `es5` |
| <code>copyWithin(target: number, start: number, end?: number): this</code> | `es2015.core` |
| <code>entries(): ArrayIterator&lt;[ number, T ]&gt;</code> | `es2015.iterable` |
| <code>every(predicate: (value: T, index: number, array: T[]) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>every&lt;S extends T&gt;(predicate: (value: T, index: number, array: T[]) =&gt; value is S, thisArg?: any): this is S[]</code> | `es5` |
| <code>fill(value: T, start?: number, end?: number): this</code> | `es2015.core` |
| <code>filter(predicate: (value: T, index: number, array: T[]) =&gt; unknown, thisArg?: any): T[]</code> | `es5` |
| <code>filter&lt;S extends T&gt;(predicate: (value: T, index: number, array: T[]) =&gt; value is S, thisArg?: any): S[]</code> | `es5` |
| <code>find(predicate: (value: T, index: number, obj: T[]) =&gt; unknown, thisArg?: any): T &#124; undefined</code> | `es2015.core` |
| <code>find&lt;S extends T&gt;(predicate: (value: T, index: number, obj: T[]) =&gt; value is S, thisArg?: any): S &#124; undefined</code> | `es2015.core` |
| <code>findIndex(predicate: (value: T, index: number, obj: T[]) =&gt; unknown, thisArg?: any): number</code> | `es2015.core` |
| <code>findLast(predicate: (value: T, index: number, array: T[]) =&gt; unknown, thisArg?: any): T &#124; undefined</code> | `es2023.array` |
| <code>findLast&lt;S extends T&gt;(predicate: (value: T, index: number, array: T[]) =&gt; value is S, thisArg?: any): S &#124; undefined</code> | `es2023.array` |
| <code>findLastIndex(predicate: (value: T, index: number, array: T[]) =&gt; unknown, thisArg?: any): number</code> | `es2023.array` |
| <code>flat&lt;A, D extends number = 1&gt;(this: A, depth?: D): FlatArray&lt;A, D&gt;[]</code> | `es2019.array` |
| <code>flatMap&lt;U, This = undefined&gt;(callback: (this: This, value: T, index: number, array: T[]) =&gt; U &#124; ReadonlyArray&lt;U&gt;, thisArg?: This): U[]</code> | `es2019.array` |
| <code>forEach(callbackfn: (value: T, index: number, array: T[]) =&gt; void, thisArg?: any): void</code> | `es5` |
| <code>indexOf(searchElement: T, fromIndex?: number): number</code> | `es5` |
| <code>join(separator?: string): string</code> | `es5` |
| <code>keys(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>lastIndexOf(searchElement: T, fromIndex?: number): number</code> | `es5` |
| <code>length: number</code> | `es5` |
| <code>map&lt;U&gt;(callbackfn: (value: T, index: number, array: T[]) =&gt; U, thisArg?: any): U[]</code> | `es5` |
| <code>pop(): T &#124; undefined</code> | `es5` |
| <code>push(...items: T[]): number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) =&gt; T, initialValue: T): T</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) =&gt; T): T</code> | `es5` |
| <code>reduce&lt;U&gt;(callbackfn: (previousValue: U, currentValue: T, currentIndex: number, array: T[]) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) =&gt; T, initialValue: T): T</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) =&gt; T): T</code> | `es5` |
| <code>reduceRight&lt;U&gt;(callbackfn: (previousValue: U, currentValue: T, currentIndex: number, array: T[]) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reverse(): T[]</code> | `es5` |
| <code>shift(): T &#124; undefined</code> | `es5` |
| <code>slice(start?: number, end?: number): T[]</code> | `es5` |
| <code>some(predicate: (value: T, index: number, array: T[]) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>sort(compareFn?: (a: T, b: T) =&gt; number): this</code> | `es5` |
| <code>splice(start: number, deleteCount: number, ...items: T[]): T[]</code> | `es5` |
| <code>splice(start: number, deleteCount?: number): T[]</code> | `es5` |
| <code>toLocaleString(): string</code> | `es5` |
| <code>toLocaleString(locales: string &#124; string[], options?: Intl.NumberFormatOptions &amp; Intl.DateTimeFormatOptions): string</code> | `es2015.core` |
| <code>toReversed(): T[]</code> | `es2023.array` |
| <code>toSorted(compareFn?: (a: T, b: T) =&gt; number): T[]</code> | `es2023.array` |
| <code>toSpliced(start: number, deleteCount: number, ...items: T[]): T[]</code> | `es2023.array` |
| <code>toSpliced(start: number, deleteCount?: number): T[]</code> | `es2023.array` |
| <code>toString(): string</code> | `es5` |
| <code>unshift(...items: T[]): number</code> | `es5` |
| <code>values(): ArrayIterator&lt;T&gt;</code> | `es2015.iterable` |
| <code>with(index: number, value: T): T[]</code> | `es2023.array` |

### `ArrayBuffer`

类别：interface。来源：`es2024.arraybuffer`、`es5`。

```ts
interface ArrayBuffer { ... }
```

声明来源：`es2024.arraybuffer`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>get detached(): boolean</code> | `es2024.arraybuffer` |
| <code>get maxByteLength(): number</code> | `es2024.arraybuffer` |
| <code>get resizable(): boolean</code> | `es2024.arraybuffer` |
| <code>readonly byteLength: number</code> | `es5` |
| <code>resize(newByteLength?: number): void</code> | `es2024.arraybuffer` |
| <code>slice(begin?: number, end?: number): ArrayBuffer</code> | `es5` |
| <code>transfer(newByteLength?: number): ArrayBuffer</code> | `es2024.arraybuffer` |
| <code>transferToFixedLength(newByteLength?: number): ArrayBuffer</code> | `es2024.arraybuffer` |

### `ArrayBufferConstructor`

类别：interface。来源：`es2017.arraybuffer`、`es2024.arraybuffer`、`es5`。

```ts
interface ArrayBufferConstructor { ... }
```

声明来源：`es2017.arraybuffer`、`es2024.arraybuffer`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>isView(arg: any): arg is ArrayBufferView</code> | `es5` |
| <code>new (): ArrayBuffer</code> | `es2017.arraybuffer` |
| <code>new (byteLength: number, options?: { maxByteLength?: number; }): ArrayBuffer</code> | `es2024.arraybuffer` |
| <code>new (byteLength: number): ArrayBuffer</code> | `es5` |
| <code>readonly prototype: ArrayBuffer</code> | `es5` |

### `ArrayBufferLike`

类别：type。来源：`es5`。

```ts
type ArrayBufferLike = ArrayBufferTypes[keyof ArrayBufferTypes];
```

定义来源：`es5`。

### `ArrayBufferTypes`

类别：interface。来源：`es2017.sharedmemory`、`es5`。

```ts
interface ArrayBufferTypes { ... }
```

声明来源：`es2017.sharedmemory`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>ArrayBuffer: ArrayBuffer</code> | `es5` |
| <code>SharedArrayBuffer: SharedArrayBuffer</code> | `es2017.sharedmemory` |

### `ArrayBufferView`

类别：interface。来源：`es5`。

```ts
interface ArrayBufferView<TArrayBuffer extends ArrayBufferLike = ArrayBufferLike> { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>readonly buffer: TArrayBuffer</code> | `es5` |
| <code>readonly byteLength: number</code> | `es5` |
| <code>readonly byteOffset: number</code> | `es5` |

### `ArrayConstructor`

类别：interface。来源：`es2015.core`、`es2015.iterable`、`es5`、`esnext.array`。

```ts
interface ArrayConstructor { ... }
```

声明来源：`es2015.core`、`es2015.iterable`、`es5`、`esnext.array`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(arrayLength?: number): any[]</code> | `es5` |
| <code>&lt;T&gt;(...items: T[]): T[]</code> | `es5` |
| <code>&lt;T&gt;(arrayLength: number): T[]</code> | `es5` |
| <code>from&lt;T, U&gt;(arrayLike: ArrayLike&lt;T&gt;, mapfn: (v: T, k: number) =&gt; U, thisArg?: any): U[]</code> | `es2015.core` |
| <code>from&lt;T, U&gt;(iterable: Iterable&lt;T&gt; &#124; ArrayLike&lt;T&gt;, mapfn: (v: T, k: number) =&gt; U, thisArg?: any): U[]</code> | `es2015.iterable` |
| <code>from&lt;T&gt;(arrayLike: ArrayLike&lt;T&gt;): T[]</code> | `es2015.core` |
| <code>from&lt;T&gt;(iterable: Iterable&lt;T&gt; &#124; ArrayLike&lt;T&gt;): T[]</code> | `es2015.iterable` |
| <code>fromAsync&lt;T, U&gt;(iterableOrArrayLike: AsyncIterable&lt;T&gt; &#124; Iterable&lt;T&gt; &#124; ArrayLike&lt;T&gt;, mapFn: (value: Awaited&lt;T&gt;, index: number) =&gt; U, thisArg?: any): Promise&lt;Awaited&lt;U&gt;[]&gt;</code> | `esnext.array` |
| <code>fromAsync&lt;T&gt;(iterableOrArrayLike: AsyncIterable&lt;T&gt; &#124; Iterable&lt;T &#124; PromiseLike&lt;T&gt;&gt; &#124; ArrayLike&lt;T &#124; PromiseLike&lt;T&gt;&gt;): Promise&lt;T[]&gt;</code> | `esnext.array` |
| <code>isArray(arg: any): arg is any[]</code> | `es5` |
| <code>new (arrayLength?: number): any[]</code> | `es5` |
| <code>new &lt;T&gt;(...items: T[]): T[]</code> | `es5` |
| <code>new &lt;T&gt;(arrayLength: number): T[]</code> | `es5` |
| <code>of&lt;T&gt;(...items: T[]): T[]</code> | `es2015.core` |
| <code>readonly prototype: any[]</code> | `es5` |

### `ArrayIterator`

类别：interface。来源：`es2015.iterable`。

```ts
interface ArrayIterator<T> extends IteratorObject<T, BuiltinIteratorReturn, unknown> { ... }
```

声明来源：`es2015.iterable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.iterator](): ArrayIterator&lt;T&gt;</code> | `es2015.iterable` |

### `ArrayLike`

类别：interface。来源：`es5`。

```ts
interface ArrayLike<T> { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>readonly [n: number]: T</code> | `es5` |
| <code>readonly length: number</code> | `es5` |

### `AsyncDisposable`

类别：interface。来源：`esnext.disposable`。

```ts
interface AsyncDisposable { ... }
```

声明来源：`esnext.disposable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.asyncDispose](): PromiseLike&lt;void&gt;</code> | `esnext.disposable` |

### `AsyncDisposableStack`

类别：interface。来源：`esnext.disposable`。

```ts
interface AsyncDisposableStack { ... }
```

声明来源：`esnext.disposable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.asyncDispose](): Promise&lt;void&gt;</code> | `esnext.disposable` |
| <code>adopt&lt;T&gt;(value: T, onDisposeAsync: (value: T) =&gt; PromiseLike&lt;void&gt; &#124; void): T</code> | `esnext.disposable` |
| <code>defer(onDisposeAsync: () =&gt; PromiseLike&lt;void&gt; &#124; void): void</code> | `esnext.disposable` |
| <code>disposeAsync(): Promise&lt;void&gt;</code> | `esnext.disposable` |
| <code>move(): AsyncDisposableStack</code> | `esnext.disposable` |
| <code>readonly [Symbol.toStringTag]: string</code> | `esnext.disposable` |
| <code>readonly disposed: boolean</code> | `esnext.disposable` |
| <code>use&lt;T extends AsyncDisposable &#124; Disposable &#124; null &#124; undefined&gt;(value: T): T</code> | `esnext.disposable` |

### `AsyncDisposableStackConstructor`

类别：interface。来源：`esnext.disposable`。

```ts
interface AsyncDisposableStackConstructor { ... }
```

声明来源：`esnext.disposable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>new (): AsyncDisposableStack</code> | `esnext.disposable` |
| <code>readonly prototype: AsyncDisposableStack</code> | `esnext.disposable` |

### `AsyncGenerator`

类别：interface。来源：`es2018.asyncgenerator`。

```ts
interface AsyncGenerator<T = unknown, TReturn = any, TNext = any> extends AsyncIteratorObject<T, TReturn, TNext> { ... }
```

声明来源：`es2018.asyncgenerator`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.asyncIterator](): AsyncGenerator&lt;T, TReturn, TNext&gt;</code> | `es2018.asyncgenerator` |
| <code>next(...[value]: [ ] &#124; [ TNext ]): Promise&lt;IteratorResult&lt;T, TReturn&gt;&gt;</code> | `es2018.asyncgenerator` |
| <code>return(value: TReturn &#124; PromiseLike&lt;TReturn&gt;): Promise&lt;IteratorResult&lt;T, TReturn&gt;&gt;</code> | `es2018.asyncgenerator` |
| <code>throw(e: any): Promise&lt;IteratorResult&lt;T, TReturn&gt;&gt;</code> | `es2018.asyncgenerator` |

### `AsyncGeneratorFunction`

类别：interface。来源：`es2018.asyncgenerator`。

```ts
interface AsyncGeneratorFunction { ... }
```

声明来源：`es2018.asyncgenerator`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(...args: any[]): AsyncGenerator</code> | `es2018.asyncgenerator` |
| <code>new (...args: any[]): AsyncGenerator</code> | `es2018.asyncgenerator` |
| <code>readonly length: number</code> | `es2018.asyncgenerator` |
| <code>readonly name: string</code> | `es2018.asyncgenerator` |
| <code>readonly prototype: AsyncGenerator</code> | `es2018.asyncgenerator` |

### `AsyncGeneratorFunctionConstructor`

类别：interface。来源：`es2018.asyncgenerator`。

```ts
interface AsyncGeneratorFunctionConstructor { ... }
```

声明来源：`es2018.asyncgenerator`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(...args: string[]): AsyncGeneratorFunction</code> | `es2018.asyncgenerator` |
| <code>new (...args: string[]): AsyncGeneratorFunction</code> | `es2018.asyncgenerator` |
| <code>readonly length: number</code> | `es2018.asyncgenerator` |
| <code>readonly name: string</code> | `es2018.asyncgenerator` |
| <code>readonly prototype: AsyncGeneratorFunction</code> | `es2018.asyncgenerator` |

### `AsyncIterable`

类别：interface。来源：`es2018.asynciterable`。

```ts
interface AsyncIterable<T, TReturn = any, TNext = any> { ... }
```

声明来源：`es2018.asynciterable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.asyncIterator](): AsyncIterator&lt;T, TReturn, TNext&gt;</code> | `es2018.asynciterable` |

### `AsyncIterableIterator`

类别：interface。来源：`es2018.asynciterable`。

```ts
interface AsyncIterableIterator<T, TReturn = any, TNext = any> extends AsyncIterator<T, TReturn, TNext> { ... }
```

声明来源：`es2018.asynciterable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.asyncIterator](): AsyncIterableIterator&lt;T, TReturn, TNext&gt;</code> | `es2018.asynciterable` |

### `AsyncIterator`

类别：interface。来源：`es2018.asynciterable`。

```ts
interface AsyncIterator<T, TReturn = any, TNext = any> { ... }
```

声明来源：`es2018.asynciterable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>next(...[value]: [ ] &#124; [ TNext ]): Promise&lt;IteratorResult&lt;T, TReturn&gt;&gt;</code> | `es2018.asynciterable` |
| <code>return?(value?: TReturn &#124; PromiseLike&lt;TReturn&gt;): Promise&lt;IteratorResult&lt;T, TReturn&gt;&gt;</code> | `es2018.asynciterable` |
| <code>throw?(e?: any): Promise&lt;IteratorResult&lt;T, TReturn&gt;&gt;</code> | `es2018.asynciterable` |

### `AsyncIteratorObject`

类别：interface。来源：`es2018.asynciterable`、`esnext.disposable`。

```ts
interface AsyncIteratorObject<T, TReturn = unknown, TNext = unknown> extends AsyncIterator<T, TReturn, TNext> { ... }
```

声明来源：`es2018.asynciterable`。

```ts
interface AsyncIteratorObject<T, TReturn, TNext> extends AsyncDisposable { ... }
```

声明来源：`esnext.disposable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.asyncIterator](): AsyncIteratorObject&lt;T, TReturn, TNext&gt;</code> | `es2018.asynciterable` |

### `Atomics`

类别：interface。来源：`es2017.sharedmemory`、`es2020.sharedmemory`、`es2024.sharedmemory`、`esnext.sharedmemory`。

```ts
interface Atomics { ... }
```

声明来源：`es2017.sharedmemory`、`es2020.sharedmemory`、`es2024.sharedmemory`、`esnext.sharedmemory`。

| 成员签名 | 来源 |
| --- | --- |
| <code>add(typedArray: BigInt64Array&lt;ArrayBufferLike&gt; &#124; BigUint64Array&lt;ArrayBufferLike&gt;, index: number, value: bigint): bigint</code> | `es2020.sharedmemory` |
| <code>add(typedArray: Int8Array&lt;ArrayBufferLike&gt; &#124; Uint8Array&lt;ArrayBufferLike&gt; &#124; Int16Array&lt;ArrayBufferLike&gt; &#124; Uint16Array&lt;ArrayBufferLike&gt; &#124; Int32Array&lt;ArrayBufferLike&gt; &#124; Uint32Array&lt;ArrayBufferLike&gt;, index: number, value: number): number</code> | `es2017.sharedmemory` |
| <code>and(typedArray: BigInt64Array&lt;ArrayBufferLike&gt; &#124; BigUint64Array&lt;ArrayBufferLike&gt;, index: number, value: bigint): bigint</code> | `es2020.sharedmemory` |
| <code>and(typedArray: Int8Array&lt;ArrayBufferLike&gt; &#124; Uint8Array&lt;ArrayBufferLike&gt; &#124; Int16Array&lt;ArrayBufferLike&gt; &#124; Uint16Array&lt;ArrayBufferLike&gt; &#124; Int32Array&lt;ArrayBufferLike&gt; &#124; Uint32Array&lt;ArrayBufferLike&gt;, index: number, value: number): number</code> | `es2017.sharedmemory` |
| <code>compareExchange(typedArray: BigInt64Array&lt;ArrayBufferLike&gt; &#124; BigUint64Array&lt;ArrayBufferLike&gt;, index: number, expectedValue: bigint, replacementValue: bigint): bigint</code> | `es2020.sharedmemory` |
| <code>compareExchange(typedArray: Int8Array&lt;ArrayBufferLike&gt; &#124; Uint8Array&lt;ArrayBufferLike&gt; &#124; Int16Array&lt;ArrayBufferLike&gt; &#124; Uint16Array&lt;ArrayBufferLike&gt; &#124; Int32Array&lt;ArrayBufferLike&gt; &#124; Uint32Array&lt;ArrayBufferLike&gt;, index: number, expectedValue: number, replacementValue: number): number</code> | `es2017.sharedmemory` |
| <code>exchange(typedArray: BigInt64Array&lt;ArrayBufferLike&gt; &#124; BigUint64Array&lt;ArrayBufferLike&gt;, index: number, value: bigint): bigint</code> | `es2020.sharedmemory` |
| <code>exchange(typedArray: Int8Array&lt;ArrayBufferLike&gt; &#124; Uint8Array&lt;ArrayBufferLike&gt; &#124; Int16Array&lt;ArrayBufferLike&gt; &#124; Uint16Array&lt;ArrayBufferLike&gt; &#124; Int32Array&lt;ArrayBufferLike&gt; &#124; Uint32Array&lt;ArrayBufferLike&gt;, index: number, value: number): number</code> | `es2017.sharedmemory` |
| <code>isLockFree(size: number): boolean</code> | `es2017.sharedmemory` |
| <code>load(typedArray: BigInt64Array&lt;ArrayBufferLike&gt; &#124; BigUint64Array&lt;ArrayBufferLike&gt;, index: number): bigint</code> | `es2020.sharedmemory` |
| <code>load(typedArray: Int8Array&lt;ArrayBufferLike&gt; &#124; Uint8Array&lt;ArrayBufferLike&gt; &#124; Int16Array&lt;ArrayBufferLike&gt; &#124; Uint16Array&lt;ArrayBufferLike&gt; &#124; Int32Array&lt;ArrayBufferLike&gt; &#124; Uint32Array&lt;ArrayBufferLike&gt;, index: number): number</code> | `es2017.sharedmemory` |
| <code>notify(typedArray: BigInt64Array&lt;ArrayBufferLike&gt;, index: number, count?: number): number</code> | `es2020.sharedmemory` |
| <code>notify(typedArray: Int32Array&lt;ArrayBufferLike&gt;, index: number, count?: number): number</code> | `es2017.sharedmemory` |
| <code>or(typedArray: BigInt64Array&lt;ArrayBufferLike&gt; &#124; BigUint64Array&lt;ArrayBufferLike&gt;, index: number, value: bigint): bigint</code> | `es2020.sharedmemory` |
| <code>or(typedArray: Int8Array&lt;ArrayBufferLike&gt; &#124; Uint8Array&lt;ArrayBufferLike&gt; &#124; Int16Array&lt;ArrayBufferLike&gt; &#124; Uint16Array&lt;ArrayBufferLike&gt; &#124; Int32Array&lt;ArrayBufferLike&gt; &#124; Uint32Array&lt;ArrayBufferLike&gt;, index: number, value: number): number</code> | `es2017.sharedmemory` |
| <code>pause(n?: number): void</code> | `esnext.sharedmemory` |
| <code>readonly [Symbol.toStringTag]: "Atomics"</code> | `es2017.sharedmemory` |
| <code>store(typedArray: BigInt64Array&lt;ArrayBufferLike&gt; &#124; BigUint64Array&lt;ArrayBufferLike&gt;, index: number, value: bigint): bigint</code> | `es2020.sharedmemory` |
| <code>store(typedArray: Int8Array&lt;ArrayBufferLike&gt; &#124; Uint8Array&lt;ArrayBufferLike&gt; &#124; Int16Array&lt;ArrayBufferLike&gt; &#124; Uint16Array&lt;ArrayBufferLike&gt; &#124; Int32Array&lt;ArrayBufferLike&gt; &#124; Uint32Array&lt;ArrayBufferLike&gt;, index: number, value: number): number</code> | `es2017.sharedmemory` |
| <code>sub(typedArray: BigInt64Array&lt;ArrayBufferLike&gt; &#124; BigUint64Array&lt;ArrayBufferLike&gt;, index: number, value: bigint): bigint</code> | `es2020.sharedmemory` |
| <code>sub(typedArray: Int8Array&lt;ArrayBufferLike&gt; &#124; Uint8Array&lt;ArrayBufferLike&gt; &#124; Int16Array&lt;ArrayBufferLike&gt; &#124; Uint16Array&lt;ArrayBufferLike&gt; &#124; Int32Array&lt;ArrayBufferLike&gt; &#124; Uint32Array&lt;ArrayBufferLike&gt;, index: number, value: number): number</code> | `es2017.sharedmemory` |
| <code>wait(typedArray: BigInt64Array&lt;ArrayBufferLike&gt;, index: number, value: bigint, timeout?: number): "ok" &#124; "not-equal" &#124; "timed-out"</code> | `es2020.sharedmemory` |
| <code>wait(typedArray: Int32Array&lt;ArrayBufferLike&gt;, index: number, value: number, timeout?: number): "ok" &#124; "not-equal" &#124; "timed-out"</code> | `es2017.sharedmemory` |
| <code>waitAsync(typedArray: BigInt64Array, index: number, value: bigint, timeout?: number): { async: false; value: "not-equal" &#124; "timed-out"; } &#124; { async: true; value: Promise&lt;"ok" &#124; "timed-out"&gt;; }</code> | `es2024.sharedmemory` |
| <code>waitAsync(typedArray: Int32Array, index: number, value: number, timeout?: number): { async: false; value: "not-equal" &#124; "timed-out"; } &#124; { async: true; value: Promise&lt;"ok" &#124; "timed-out"&gt;; }</code> | `es2024.sharedmemory` |
| <code>xor(typedArray: BigInt64Array&lt;ArrayBufferLike&gt; &#124; BigUint64Array&lt;ArrayBufferLike&gt;, index: number, value: bigint): bigint</code> | `es2020.sharedmemory` |
| <code>xor(typedArray: Int8Array&lt;ArrayBufferLike&gt; &#124; Uint8Array&lt;ArrayBufferLike&gt; &#124; Int16Array&lt;ArrayBufferLike&gt; &#124; Uint16Array&lt;ArrayBufferLike&gt; &#124; Int32Array&lt;ArrayBufferLike&gt; &#124; Uint32Array&lt;ArrayBufferLike&gt;, index: number, value: number): number</code> | `es2017.sharedmemory` |

### `Awaited`

类别：type。来源：`es5`。

```ts
type Awaited<T> = T extends null | undefined ? T : // special case for `null | undefined` when not in `--strictNullChecks` mode T extends object & { then(onfulfilled: infer F, ...args: infer _): any; } ? // `await` only unwraps object types with a callable `then`. Non-object types are not unwrapped F extends ((value: infer V, ...args: infer _) => any) ? // if the argument to `then` is callable, extracts the first argument Awaited<V> : // recursively unwrap the value never : // the argument to `then` was not callable T;
```

定义来源：`es5`。

### `BigInt`

类别：interface。来源：`es2020.bigint`。

```ts
interface BigInt { ... }
```

声明来源：`es2020.bigint`。

| 成员签名 | 来源 |
| --- | --- |
| <code>readonly [Symbol.toStringTag]: "BigInt"</code> | `es2020.bigint` |
| <code>toLocaleString(locales?: Intl.LocalesArgument, options?: BigIntToLocaleStringOptions): string</code> | `es2020.bigint` |
| <code>toString(radix?: number): string</code> | `es2020.bigint` |
| <code>valueOf(): bigint</code> | `es2020.bigint` |

### `BigInt64Array`

类别：interface。来源：`es2020.bigint`、`es2022.array`、`es2023.array`。

```ts
interface BigInt64Array<TArrayBuffer extends ArrayBufferLike = ArrayBufferLike> { ... }
```

声明来源：`es2020.bigint`。

```ts
interface BigInt64Array<TArrayBuffer extends ArrayBufferLike> { ... }
```

声明来源：`es2022.array`、`es2023.array`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[index: number]: bigint</code> | `es2020.bigint` |
| <code>[Symbol.iterator](): ArrayIterator&lt;bigint&gt;</code> | `es2020.bigint` |
| <code>at(index: number): bigint &#124; undefined</code> | `es2022.array` |
| <code>copyWithin(target: number, start: number, end?: number): this</code> | `es2020.bigint` |
| <code>entries(): ArrayIterator&lt;[ number, bigint ]&gt;</code> | `es2020.bigint` |
| <code>every(predicate: (value: bigint, index: number, array: BigInt64Array&lt;TArrayBuffer&gt;) =&gt; boolean, thisArg?: any): boolean</code> | `es2020.bigint` |
| <code>fill(value: bigint, start?: number, end?: number): this</code> | `es2020.bigint` |
| <code>filter(predicate: (value: bigint, index: number, array: BigInt64Array&lt;TArrayBuffer&gt;) =&gt; any, thisArg?: any): BigInt64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>find(predicate: (value: bigint, index: number, array: BigInt64Array&lt;TArrayBuffer&gt;) =&gt; boolean, thisArg?: any): bigint &#124; undefined</code> | `es2020.bigint` |
| <code>findIndex(predicate: (value: bigint, index: number, array: BigInt64Array&lt;TArrayBuffer&gt;) =&gt; boolean, thisArg?: any): number</code> | `es2020.bigint` |
| <code>findLast(predicate: (value: bigint, index: number, array: this) =&gt; unknown, thisArg?: any): bigint &#124; undefined</code> | `es2023.array` |
| <code>findLast&lt;S extends bigint&gt;(predicate: (value: bigint, index: number, array: this) =&gt; value is S, thisArg?: any): S &#124; undefined</code> | `es2023.array` |
| <code>findLastIndex(predicate: (value: bigint, index: number, array: this) =&gt; unknown, thisArg?: any): number</code> | `es2023.array` |
| <code>forEach(callbackfn: (value: bigint, index: number, array: BigInt64Array&lt;TArrayBuffer&gt;) =&gt; void, thisArg?: any): void</code> | `es2020.bigint` |
| <code>includes(searchElement: bigint, fromIndex?: number): boolean</code> | `es2020.bigint` |
| <code>indexOf(searchElement: bigint, fromIndex?: number): number</code> | `es2020.bigint` |
| <code>join(separator?: string): string</code> | `es2020.bigint` |
| <code>keys(): ArrayIterator&lt;number&gt;</code> | `es2020.bigint` |
| <code>lastIndexOf(searchElement: bigint, fromIndex?: number): number</code> | `es2020.bigint` |
| <code>map(callbackfn: (value: bigint, index: number, array: BigInt64Array&lt;TArrayBuffer&gt;) =&gt; bigint, thisArg?: any): BigInt64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>readonly [Symbol.toStringTag]: "BigInt64Array"</code> | `es2020.bigint` |
| <code>readonly buffer: TArrayBuffer</code> | `es2020.bigint` |
| <code>readonly byteLength: number</code> | `es2020.bigint` |
| <code>readonly byteOffset: number</code> | `es2020.bigint` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es2020.bigint` |
| <code>readonly length: number</code> | `es2020.bigint` |
| <code>reduce(callbackfn: (previousValue: bigint, currentValue: bigint, currentIndex: number, array: BigInt64Array&lt;TArrayBuffer&gt;) =&gt; bigint): bigint</code> | `es2020.bigint` |
| <code>reduce&lt;U&gt;(callbackfn: (previousValue: U, currentValue: bigint, currentIndex: number, array: BigInt64Array&lt;TArrayBuffer&gt;) =&gt; U, initialValue: U): U</code> | `es2020.bigint` |
| <code>reduceRight(callbackfn: (previousValue: bigint, currentValue: bigint, currentIndex: number, array: BigInt64Array&lt;TArrayBuffer&gt;) =&gt; bigint): bigint</code> | `es2020.bigint` |
| <code>reduceRight&lt;U&gt;(callbackfn: (previousValue: U, currentValue: bigint, currentIndex: number, array: BigInt64Array&lt;TArrayBuffer&gt;) =&gt; U, initialValue: U): U</code> | `es2020.bigint` |
| <code>reverse(): this</code> | `es2020.bigint` |
| <code>set(array: ArrayLike&lt;bigint&gt;, offset?: number): void</code> | `es2020.bigint` |
| <code>slice(start?: number, end?: number): BigInt64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>some(predicate: (value: bigint, index: number, array: BigInt64Array&lt;TArrayBuffer&gt;) =&gt; boolean, thisArg?: any): boolean</code> | `es2020.bigint` |
| <code>sort(compareFn?: (a: bigint, b: bigint) =&gt; number &#124; bigint): this</code> | `es2020.bigint` |
| <code>subarray(begin?: number, end?: number): BigInt64Array&lt;TArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>toLocaleString(locales?: string &#124; string[], options?: Intl.NumberFormatOptions): string</code> | `es2020.bigint` |
| <code>toReversed(): BigInt64Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toSorted(compareFn?: (a: bigint, b: bigint) =&gt; number): BigInt64Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toString(): string</code> | `es2020.bigint` |
| <code>valueOf(): BigInt64Array&lt;TArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>values(): ArrayIterator&lt;bigint&gt;</code> | `es2020.bigint` |
| <code>with(index: number, value: bigint): BigInt64Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |

### `BigInt64ArrayConstructor`

类别：interface。来源：`es2020.bigint`。

```ts
interface BigInt64ArrayConstructor { ... }
```

声明来源：`es2020.bigint`。

| 成员签名 | 来源 |
| --- | --- |
| <code>from(arrayLike: ArrayLike&lt;bigint&gt;): BigInt64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>from(elements: Iterable&lt;bigint&gt;): BigInt64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>from&lt;T&gt;(elements: Iterable&lt;T&gt;, mapfn?: (v: T, k: number) =&gt; bigint, thisArg?: any): BigInt64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>from&lt;U&gt;(arrayLike: ArrayLike&lt;U&gt;, mapfn: (v: U, k: number) =&gt; bigint, thisArg?: any): BigInt64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>new (array: ArrayLike&lt;bigint&gt; &#124; ArrayBuffer): BigInt64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>new (array: ArrayLike&lt;bigint&gt; &#124; Iterable&lt;bigint&gt;): BigInt64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>new (buffer: ArrayBuffer, byteOffset?: number, length?: number): BigInt64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>new (length?: number): BigInt64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>new &lt;TArrayBuffer extends ArrayBufferLike = ArrayBuffer&gt;(buffer: TArrayBuffer, byteOffset?: number, length?: number): BigInt64Array&lt;TArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>of(...items: bigint[]): BigInt64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es2020.bigint` |
| <code>readonly prototype: BigInt64Array&lt;ArrayBufferLike&gt;</code> | `es2020.bigint` |

### `BigIntConstructor`

类别：interface。来源：`es2020.bigint`。

```ts
interface BigIntConstructor { ... }
```

声明来源：`es2020.bigint`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(value: bigint &#124; boolean &#124; number &#124; string): bigint</code> | `es2020.bigint` |
| <code>asIntN(bits: number, int: bigint): bigint</code> | `es2020.bigint` |
| <code>asUintN(bits: number, int: bigint): bigint</code> | `es2020.bigint` |
| <code>readonly prototype: BigInt</code> | `es2020.bigint` |

### `BigIntToLocaleStringOptions`

类别：interface。来源：`es2020.bigint`。

```ts
interface BigIntToLocaleStringOptions { ... }
```

声明来源：`es2020.bigint`。

| 成员签名 | 来源 |
| --- | --- |
| <code>compactDisplay?: string</code> | `es2020.bigint` |
| <code>currency?: string</code> | `es2020.bigint` |
| <code>currencyDisplay?: string</code> | `es2020.bigint` |
| <code>localeMatcher?: string</code> | `es2020.bigint` |
| <code>maximumFractionDigits?: 0 &#124; 1 &#124; 2 &#124; 3 &#124; 4 &#124; 5 &#124; 6 &#124; 7 &#124; 8 &#124; 9 &#124; 10 &#124; 11 &#124; 12 &#124; 13 &#124; 14 &#124; 15 &#124; 16 &#124; 17 &#124; 18 &#124; 19 &#124; 20</code> | `es2020.bigint` |
| <code>maximumSignificantDigits?: 1 &#124; 2 &#124; 3 &#124; 4 &#124; 5 &#124; 6 &#124; 7 &#124; 8 &#124; 9 &#124; 10 &#124; 11 &#124; 12 &#124; 13 &#124; 14 &#124; 15 &#124; 16 &#124; 17 &#124; 18 &#124; 19 &#124; 20 &#124; 21</code> | `es2020.bigint` |
| <code>minimumFractionDigits?: 0 &#124; 1 &#124; 2 &#124; 3 &#124; 4 &#124; 5 &#124; 6 &#124; 7 &#124; 8 &#124; 9 &#124; 10 &#124; 11 &#124; 12 &#124; 13 &#124; 14 &#124; 15 &#124; 16 &#124; 17 &#124; 18 &#124; 19 &#124; 20</code> | `es2020.bigint` |
| <code>minimumIntegerDigits?: 1 &#124; 2 &#124; 3 &#124; 4 &#124; 5 &#124; 6 &#124; 7 &#124; 8 &#124; 9 &#124; 10 &#124; 11 &#124; 12 &#124; 13 &#124; 14 &#124; 15 &#124; 16 &#124; 17 &#124; 18 &#124; 19 &#124; 20 &#124; 21</code> | `es2020.bigint` |
| <code>minimumSignificantDigits?: 1 &#124; 2 &#124; 3 &#124; 4 &#124; 5 &#124; 6 &#124; 7 &#124; 8 &#124; 9 &#124; 10 &#124; 11 &#124; 12 &#124; 13 &#124; 14 &#124; 15 &#124; 16 &#124; 17 &#124; 18 &#124; 19 &#124; 20 &#124; 21</code> | `es2020.bigint` |
| <code>notation?: string</code> | `es2020.bigint` |
| <code>numberingSystem?: string</code> | `es2020.bigint` |
| <code>style?: string</code> | `es2020.bigint` |
| <code>unit?: string</code> | `es2020.bigint` |
| <code>unitDisplay?: string</code> | `es2020.bigint` |
| <code>useGrouping?: boolean</code> | `es2020.bigint` |

### `BigUint64Array`

类别：interface。来源：`es2020.bigint`、`es2022.array`、`es2023.array`。

```ts
interface BigUint64Array<TArrayBuffer extends ArrayBufferLike = ArrayBufferLike> { ... }
```

声明来源：`es2020.bigint`。

```ts
interface BigUint64Array<TArrayBuffer extends ArrayBufferLike> { ... }
```

声明来源：`es2022.array`、`es2023.array`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[index: number]: bigint</code> | `es2020.bigint` |
| <code>[Symbol.iterator](): ArrayIterator&lt;bigint&gt;</code> | `es2020.bigint` |
| <code>at(index: number): bigint &#124; undefined</code> | `es2022.array` |
| <code>copyWithin(target: number, start: number, end?: number): this</code> | `es2020.bigint` |
| <code>entries(): ArrayIterator&lt;[ number, bigint ]&gt;</code> | `es2020.bigint` |
| <code>every(predicate: (value: bigint, index: number, array: BigUint64Array&lt;TArrayBuffer&gt;) =&gt; boolean, thisArg?: any): boolean</code> | `es2020.bigint` |
| <code>fill(value: bigint, start?: number, end?: number): this</code> | `es2020.bigint` |
| <code>filter(predicate: (value: bigint, index: number, array: BigUint64Array&lt;TArrayBuffer&gt;) =&gt; any, thisArg?: any): BigUint64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>find(predicate: (value: bigint, index: number, array: BigUint64Array&lt;TArrayBuffer&gt;) =&gt; boolean, thisArg?: any): bigint &#124; undefined</code> | `es2020.bigint` |
| <code>findIndex(predicate: (value: bigint, index: number, array: BigUint64Array&lt;TArrayBuffer&gt;) =&gt; boolean, thisArg?: any): number</code> | `es2020.bigint` |
| <code>findLast(predicate: (value: bigint, index: number, array: this) =&gt; unknown, thisArg?: any): bigint &#124; undefined</code> | `es2023.array` |
| <code>findLast&lt;S extends bigint&gt;(predicate: (value: bigint, index: number, array: this) =&gt; value is S, thisArg?: any): S &#124; undefined</code> | `es2023.array` |
| <code>findLastIndex(predicate: (value: bigint, index: number, array: this) =&gt; unknown, thisArg?: any): number</code> | `es2023.array` |
| <code>forEach(callbackfn: (value: bigint, index: number, array: BigUint64Array&lt;TArrayBuffer&gt;) =&gt; void, thisArg?: any): void</code> | `es2020.bigint` |
| <code>includes(searchElement: bigint, fromIndex?: number): boolean</code> | `es2020.bigint` |
| <code>indexOf(searchElement: bigint, fromIndex?: number): number</code> | `es2020.bigint` |
| <code>join(separator?: string): string</code> | `es2020.bigint` |
| <code>keys(): ArrayIterator&lt;number&gt;</code> | `es2020.bigint` |
| <code>lastIndexOf(searchElement: bigint, fromIndex?: number): number</code> | `es2020.bigint` |
| <code>map(callbackfn: (value: bigint, index: number, array: BigUint64Array&lt;TArrayBuffer&gt;) =&gt; bigint, thisArg?: any): BigUint64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>readonly [Symbol.toStringTag]: "BigUint64Array"</code> | `es2020.bigint` |
| <code>readonly buffer: TArrayBuffer</code> | `es2020.bigint` |
| <code>readonly byteLength: number</code> | `es2020.bigint` |
| <code>readonly byteOffset: number</code> | `es2020.bigint` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es2020.bigint` |
| <code>readonly length: number</code> | `es2020.bigint` |
| <code>reduce(callbackfn: (previousValue: bigint, currentValue: bigint, currentIndex: number, array: BigUint64Array&lt;TArrayBuffer&gt;) =&gt; bigint): bigint</code> | `es2020.bigint` |
| <code>reduce&lt;U&gt;(callbackfn: (previousValue: U, currentValue: bigint, currentIndex: number, array: BigUint64Array&lt;TArrayBuffer&gt;) =&gt; U, initialValue: U): U</code> | `es2020.bigint` |
| <code>reduceRight(callbackfn: (previousValue: bigint, currentValue: bigint, currentIndex: number, array: BigUint64Array&lt;TArrayBuffer&gt;) =&gt; bigint): bigint</code> | `es2020.bigint` |
| <code>reduceRight&lt;U&gt;(callbackfn: (previousValue: U, currentValue: bigint, currentIndex: number, array: BigUint64Array&lt;TArrayBuffer&gt;) =&gt; U, initialValue: U): U</code> | `es2020.bigint` |
| <code>reverse(): this</code> | `es2020.bigint` |
| <code>set(array: ArrayLike&lt;bigint&gt;, offset?: number): void</code> | `es2020.bigint` |
| <code>slice(start?: number, end?: number): BigUint64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>some(predicate: (value: bigint, index: number, array: BigUint64Array&lt;TArrayBuffer&gt;) =&gt; boolean, thisArg?: any): boolean</code> | `es2020.bigint` |
| <code>sort(compareFn?: (a: bigint, b: bigint) =&gt; number &#124; bigint): this</code> | `es2020.bigint` |
| <code>subarray(begin?: number, end?: number): BigUint64Array&lt;TArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>toLocaleString(locales?: string &#124; string[], options?: Intl.NumberFormatOptions): string</code> | `es2020.bigint` |
| <code>toReversed(): BigUint64Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toSorted(compareFn?: (a: bigint, b: bigint) =&gt; number): BigUint64Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toString(): string</code> | `es2020.bigint` |
| <code>valueOf(): BigUint64Array&lt;TArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>values(): ArrayIterator&lt;bigint&gt;</code> | `es2020.bigint` |
| <code>with(index: number, value: bigint): BigUint64Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |

### `BigUint64ArrayConstructor`

类别：interface。来源：`es2020.bigint`。

```ts
interface BigUint64ArrayConstructor { ... }
```

声明来源：`es2020.bigint`。

| 成员签名 | 来源 |
| --- | --- |
| <code>from(arrayLike: ArrayLike&lt;bigint&gt;): BigUint64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>from(elements: Iterable&lt;bigint&gt;): BigUint64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>from&lt;T&gt;(elements: Iterable&lt;T&gt;, mapfn?: (v: T, k: number) =&gt; bigint, thisArg?: any): BigUint64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>from&lt;U&gt;(arrayLike: ArrayLike&lt;U&gt;, mapfn: (v: U, k: number) =&gt; bigint, thisArg?: any): BigUint64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>new (array: ArrayLike&lt;bigint&gt; &#124; ArrayBuffer): BigUint64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>new (array: ArrayLike&lt;bigint&gt; &#124; Iterable&lt;bigint&gt;): BigUint64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>new (buffer: ArrayBuffer, byteOffset?: number, length?: number): BigUint64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>new (length?: number): BigUint64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>new &lt;TArrayBuffer extends ArrayBufferLike = ArrayBuffer&gt;(buffer: TArrayBuffer, byteOffset?: number, length?: number): BigUint64Array&lt;TArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>of(...items: bigint[]): BigUint64Array&lt;ArrayBuffer&gt;</code> | `es2020.bigint` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es2020.bigint` |
| <code>readonly prototype: BigUint64Array&lt;ArrayBufferLike&gt;</code> | `es2020.bigint` |

### `Boolean`

类别：interface。来源：`es5`。

```ts
interface Boolean { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>valueOf(): boolean</code> | `es5` |

### `BooleanConstructor`

类别：interface。来源：`es5`。

```ts
interface BooleanConstructor { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>&lt;T&gt;(value?: T): boolean</code> | `es5` |
| <code>new (value?: any): Boolean</code> | `es5` |
| <code>readonly prototype: Boolean</code> | `es5` |

### `BuiltinIteratorReturn`

类别：type。来源：`es2015.iterable`。

```ts
type BuiltinIteratorReturn = intrinsic;
```

定义来源：`es2015.iterable`。

### `CallableFunction`

类别：interface。来源：`es5`。

```ts
interface CallableFunction extends Function { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>apply&lt;T, A extends any[], R&gt;(this: (this: T, ...args: A) =&gt; R, thisArg: T, args: A): R</code> | `es5` |
| <code>apply&lt;T, R&gt;(this: (this: T) =&gt; R, thisArg: T): R</code> | `es5` |
| <code>bind&lt;T, A extends any[], B extends any[], R&gt;(this: (this: T, ...args: [ ...A, ...B ]) =&gt; R, thisArg: T, ...args: A): (...args: B) =&gt; R</code> | `es5` |
| <code>bind&lt;T&gt;(this: T, thisArg: ThisParameterType&lt;T&gt;): OmitThisParameter&lt;T&gt;</code> | `es5` |
| <code>call&lt;T, A extends any[], R&gt;(this: (this: T, ...args: A) =&gt; R, thisArg: T, ...args: A): R</code> | `es5` |

### `Capitalize`

类别：type。来源：`es5`。

```ts
type Capitalize<S extends string> = intrinsic;
```

定义来源：`es5`。

### `ConcatArray`

类别：interface。来源：`es5`。

```ts
interface ConcatArray<T> { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>join(separator?: string): string</code> | `es5` |
| <code>readonly [n: number]: T</code> | `es5` |
| <code>readonly length: number</code> | `es5` |
| <code>slice(start?: number, end?: number): T[]</code> | `es5` |

### `ConstructorParameters`

类别：type。来源：`es5`。

```ts
type ConstructorParameters<T extends abstract new (...args: any) = T extends abstract new (...args: infer P) => any ? P : never;
```

定义来源：`es5`。

### `DataView`

类别：interface。来源：`es2020.bigint`、`es2025.float16`、`es5`。

```ts
interface DataView<TArrayBuffer extends ArrayBufferLike> { ... }
```

声明来源：`es2020.bigint`、`es2025.float16`。

```ts
interface DataView<TArrayBuffer extends ArrayBufferLike = ArrayBufferLike> { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>getBigInt64(byteOffset: number, littleEndian?: boolean): bigint</code> | `es2020.bigint` |
| <code>getBigUint64(byteOffset: number, littleEndian?: boolean): bigint</code> | `es2020.bigint` |
| <code>getFloat16(byteOffset: number, littleEndian?: boolean): number</code> | `es2025.float16` |
| <code>getFloat32(byteOffset: number, littleEndian?: boolean): number</code> | `es5` |
| <code>getFloat64(byteOffset: number, littleEndian?: boolean): number</code> | `es5` |
| <code>getInt16(byteOffset: number, littleEndian?: boolean): number</code> | `es5` |
| <code>getInt32(byteOffset: number, littleEndian?: boolean): number</code> | `es5` |
| <code>getInt8(byteOffset: number): number</code> | `es5` |
| <code>getUint16(byteOffset: number, littleEndian?: boolean): number</code> | `es5` |
| <code>getUint32(byteOffset: number, littleEndian?: boolean): number</code> | `es5` |
| <code>getUint8(byteOffset: number): number</code> | `es5` |
| <code>readonly buffer: TArrayBuffer</code> | `es5` |
| <code>readonly byteLength: number</code> | `es5` |
| <code>readonly byteOffset: number</code> | `es5` |
| <code>setBigInt64(byteOffset: number, value: bigint, littleEndian?: boolean): void</code> | `es2020.bigint` |
| <code>setBigUint64(byteOffset: number, value: bigint, littleEndian?: boolean): void</code> | `es2020.bigint` |
| <code>setFloat16(byteOffset: number, value: number, littleEndian?: boolean): void</code> | `es2025.float16` |
| <code>setFloat32(byteOffset: number, value: number, littleEndian?: boolean): void</code> | `es5` |
| <code>setFloat64(byteOffset: number, value: number, littleEndian?: boolean): void</code> | `es5` |
| <code>setInt16(byteOffset: number, value: number, littleEndian?: boolean): void</code> | `es5` |
| <code>setInt32(byteOffset: number, value: number, littleEndian?: boolean): void</code> | `es5` |
| <code>setInt8(byteOffset: number, value: number): void</code> | `es5` |
| <code>setUint16(byteOffset: number, value: number, littleEndian?: boolean): void</code> | `es5` |
| <code>setUint32(byteOffset: number, value: number, littleEndian?: boolean): void</code> | `es5` |
| <code>setUint8(byteOffset: number, value: number): void</code> | `es5` |

### `DataViewConstructor`

类别：interface。来源：`es5`。

```ts
interface DataViewConstructor { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>new &lt;TArrayBuffer extends ArrayBufferLike &amp; { BYTES_PER_ELEMENT?: never; }&gt;(buffer: TArrayBuffer, byteOffset?: number, byteLength?: number): DataView&lt;TArrayBuffer&gt;</code> | `es5` |
| <code>readonly prototype: DataView&lt;ArrayBufferLike&gt;</code> | `es5` |

### `Date`

类别：interface。来源：`es2020.date`、`es5`、`esnext.date`。

```ts
interface Date { ... }
```

声明来源：`es2020.date`、`es5`、`esnext.date`。

| 成员签名 | 来源 |
| --- | --- |
| <code>getDate(): number</code> | `es5` |
| <code>getDay(): number</code> | `es5` |
| <code>getFullYear(): number</code> | `es5` |
| <code>getHours(): number</code> | `es5` |
| <code>getMilliseconds(): number</code> | `es5` |
| <code>getMinutes(): number</code> | `es5` |
| <code>getMonth(): number</code> | `es5` |
| <code>getSeconds(): number</code> | `es5` |
| <code>getTime(): number</code> | `es5` |
| <code>getTimezoneOffset(): number</code> | `es5` |
| <code>getUTCDate(): number</code> | `es5` |
| <code>getUTCDay(): number</code> | `es5` |
| <code>getUTCFullYear(): number</code> | `es5` |
| <code>getUTCHours(): number</code> | `es5` |
| <code>getUTCMilliseconds(): number</code> | `es5` |
| <code>getUTCMinutes(): number</code> | `es5` |
| <code>getUTCMonth(): number</code> | `es5` |
| <code>getUTCSeconds(): number</code> | `es5` |
| <code>setDate(date: number): number</code> | `es5` |
| <code>setFullYear(year: number, month?: number, date?: number): number</code> | `es5` |
| <code>setHours(hours: number, min?: number, sec?: number, ms?: number): number</code> | `es5` |
| <code>setMilliseconds(ms: number): number</code> | `es5` |
| <code>setMinutes(min: number, sec?: number, ms?: number): number</code> | `es5` |
| <code>setMonth(month: number, date?: number): number</code> | `es5` |
| <code>setSeconds(sec: number, ms?: number): number</code> | `es5` |
| <code>setTime(time: number): number</code> | `es5` |
| <code>setUTCDate(date: number): number</code> | `es5` |
| <code>setUTCFullYear(year: number, month?: number, date?: number): number</code> | `es5` |
| <code>setUTCHours(hours: number, min?: number, sec?: number, ms?: number): number</code> | `es5` |
| <code>setUTCMilliseconds(ms: number): number</code> | `es5` |
| <code>setUTCMinutes(min: number, sec?: number, ms?: number): number</code> | `es5` |
| <code>setUTCMonth(month: number, date?: number): number</code> | `es5` |
| <code>setUTCSeconds(sec: number, ms?: number): number</code> | `es5` |
| <code>toDateString(): string</code> | `es5` |
| <code>toISOString(): string</code> | `es5` |
| <code>toJSON(key?: any): string</code> | `es5` |
| <code>toLocaleDateString(): string</code> | `es5` |
| <code>toLocaleDateString(locales?: Intl.LocalesArgument, options?: Intl.DateTimeFormatOptions): string</code> | `es2020.date` |
| <code>toLocaleDateString(locales?: string &#124; string[], options?: Intl.DateTimeFormatOptions): string</code> | `es5` |
| <code>toLocaleString(): string</code> | `es5` |
| <code>toLocaleString(locales?: Intl.LocalesArgument, options?: Intl.DateTimeFormatOptions): string</code> | `es2020.date` |
| <code>toLocaleString(locales?: string &#124; string[], options?: Intl.DateTimeFormatOptions): string</code> | `es5` |
| <code>toLocaleTimeString(): string</code> | `es5` |
| <code>toLocaleTimeString(locales?: Intl.LocalesArgument, options?: Intl.DateTimeFormatOptions): string</code> | `es2020.date` |
| <code>toLocaleTimeString(locales?: string &#124; string[], options?: Intl.DateTimeFormatOptions): string</code> | `es5` |
| <code>toString(): string</code> | `es5` |
| <code>toTemporalInstant(): Temporal.Instant</code> | `esnext.date` |
| <code>toTimeString(): string</code> | `es5` |
| <code>toUTCString(): string</code> | `es5` |
| <code>valueOf(): number</code> | `es5` |

### `DateConstructor`

类别：interface。来源：`es2015.core`、`es2017.date`、`es5`。

```ts
interface DateConstructor { ... }
```

声明来源：`es2015.core`、`es2017.date`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(): string</code> | `es5` |
| <code>new (): Date</code> | `es5` |
| <code>new (value: number &#124; string &#124; Date): Date</code> | `es2015.core` |
| <code>new (value: number &#124; string): Date</code> | `es5` |
| <code>new (year: number, monthIndex: number, date?: number, hours?: number, minutes?: number, seconds?: number, ms?: number): Date</code> | `es5` |
| <code>now(): number</code> | `es5` |
| <code>parse(s: string): number</code> | `es5` |
| <code>readonly prototype: Date</code> | `es5` |
| <code>UTC(year: number, monthIndex: number, date?: number, hours?: number, minutes?: number, seconds?: number, ms?: number): number</code> | `es5` |
| <code>UTC(year: number, monthIndex?: number, date?: number, hours?: number, minutes?: number, seconds?: number, ms?: number): number</code> | `es2017.date` |

### `Disposable`

类别：interface。来源：`esnext.disposable`。

```ts
interface Disposable { ... }
```

声明来源：`esnext.disposable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.dispose](): void</code> | `esnext.disposable` |

### `DisposableStack`

类别：interface。来源：`esnext.disposable`。

```ts
interface DisposableStack { ... }
```

声明来源：`esnext.disposable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.dispose](): void</code> | `esnext.disposable` |
| <code>adopt&lt;T&gt;(value: T, onDispose: (value: T) =&gt; void): T</code> | `esnext.disposable` |
| <code>defer(onDispose: () =&gt; void): void</code> | `esnext.disposable` |
| <code>dispose(): void</code> | `esnext.disposable` |
| <code>move(): DisposableStack</code> | `esnext.disposable` |
| <code>readonly [Symbol.toStringTag]: string</code> | `esnext.disposable` |
| <code>readonly disposed: boolean</code> | `esnext.disposable` |
| <code>use&lt;T extends Disposable &#124; null &#124; undefined&gt;(value: T): T</code> | `esnext.disposable` |

### `DisposableStackConstructor`

类别：interface。来源：`esnext.disposable`。

```ts
interface DisposableStackConstructor { ... }
```

声明来源：`esnext.disposable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>new (): DisposableStack</code> | `esnext.disposable` |
| <code>readonly prototype: DisposableStack</code> | `esnext.disposable` |

### `Error`

类别：interface。来源：`es2022.error`、`es5`。

```ts
interface Error { ... }
```

声明来源：`es2022.error`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>cause?: unknown</code> | `es2022.error` |
| <code>message: string</code> | `es5` |
| <code>name: string</code> | `es5` |
| <code>stack?: string</code> | `es5` |

### `ErrorConstructor`

类别：interface。来源：`es2022.error`、`es5`、`esnext.error`。

```ts
interface ErrorConstructor { ... }
```

声明来源：`es2022.error`、`es5`、`esnext.error`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(message?: string, options?: ErrorOptions): Error</code> | `es2022.error` |
| <code>(message?: string): Error</code> | `es5` |
| <code>isError(error: unknown): error is Error</code> | `esnext.error` |
| <code>new (message?: string, options?: ErrorOptions): Error</code> | `es2022.error` |
| <code>new (message?: string): Error</code> | `es5` |
| <code>readonly prototype: Error</code> | `es5` |

### `ErrorOptions`

类别：interface。来源：`es2022.error`。

```ts
interface ErrorOptions { ... }
```

声明来源：`es2022.error`。

| 成员签名 | 来源 |
| --- | --- |
| <code>cause?: unknown</code> | `es2022.error` |

### `EvalError`

类别：interface。来源：`es5`。

```ts
interface EvalError extends Error { ... }
```

声明来源：`es5`。

### `EvalErrorConstructor`

类别：interface。来源：`es2022.error`、`es5`。

```ts
interface EvalErrorConstructor { ... }
```

声明来源：`es2022.error`。

```ts
interface EvalErrorConstructor extends ErrorConstructor { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(message?: string, options?: ErrorOptions): EvalError</code> | `es2022.error` |
| <code>(message?: string): EvalError</code> | `es5` |
| <code>new (message?: string, options?: ErrorOptions): EvalError</code> | `es2022.error` |
| <code>new (message?: string): EvalError</code> | `es5` |
| <code>readonly prototype: EvalError</code> | `es5` |

### `Exclude`

类别：type。来源：`es5`。

```ts
type Exclude<T, U> = T extends U ? never : T;
```

定义来源：`es5`。

### `Extract`

类别：type。来源：`es5`。

```ts
type Extract<T, U> = T extends U ? T : never;
```

定义来源：`es5`。

### `FinalizationRegistry`

类别：interface。来源：`es2021.weakref`。

```ts
interface FinalizationRegistry<T> { ... }
```

声明来源：`es2021.weakref`。

| 成员签名 | 来源 |
| --- | --- |
| <code>readonly [Symbol.toStringTag]: "FinalizationRegistry"</code> | `es2021.weakref` |
| <code>register(target: WeakKey, heldValue: T, unregisterToken?: WeakKey): void</code> | `es2021.weakref` |
| <code>unregister(unregisterToken: WeakKey): boolean</code> | `es2021.weakref` |

### `FinalizationRegistryConstructor`

类别：interface。来源：`es2021.weakref`。

```ts
interface FinalizationRegistryConstructor { ... }
```

声明来源：`es2021.weakref`。

| 成员签名 | 来源 |
| --- | --- |
| <code>new &lt;T&gt;(cleanupCallback: (heldValue: T) =&gt; void): FinalizationRegistry&lt;T&gt;</code> | `es2021.weakref` |
| <code>readonly prototype: FinalizationRegistry&lt;any&gt;</code> | `es2021.weakref` |

### `FlatArray`

类别：type。来源：`es2019.array`。

```ts
type FlatArray<Arr, Depth extends number> = { done: Arr; recur: Arr extends ReadonlyArray<infer InnerArr> ? FlatArray<InnerArr, [-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20][Depth]> : Arr; }[Depth extends -1 ? "done" : "recur"];
```

定义来源：`es2019.array`。

### `Float16Array`

类别：interface。来源：`es2025.float16`。

```ts
interface Float16Array<TArrayBuffer extends ArrayBufferLike = ArrayBufferLike> { ... }
```

声明来源：`es2025.float16`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[index: number]: number</code> | `es2025.float16` |
| <code>[Symbol.iterator](): ArrayIterator&lt;number&gt;</code> | `es2025.float16` |
| <code>at(index: number): number &#124; undefined</code> | `es2025.float16` |
| <code>copyWithin(target: number, start: number, end?: number): this</code> | `es2025.float16` |
| <code>entries(): ArrayIterator&lt;[ number, number ]&gt;</code> | `es2025.float16` |
| <code>every(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es2025.float16` |
| <code>fill(value: number, start?: number, end?: number): this</code> | `es2025.float16` |
| <code>filter(predicate: (value: number, index: number, array: this) =&gt; any, thisArg?: any): Float16Array&lt;ArrayBuffer&gt;</code> | `es2025.float16` |
| <code>find(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number &#124; undefined</code> | `es2025.float16` |
| <code>findIndex(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number</code> | `es2025.float16` |
| <code>findLast(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number &#124; undefined</code> | `es2025.float16` |
| <code>findLast&lt;S extends number&gt;(predicate: (value: number, index: number, array: this) =&gt; value is S, thisArg?: any): S &#124; undefined</code> | `es2025.float16` |
| <code>findLastIndex(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number</code> | `es2025.float16` |
| <code>forEach(callbackfn: (value: number, index: number, array: this) =&gt; void, thisArg?: any): void</code> | `es2025.float16` |
| <code>includes(searchElement: number, fromIndex?: number): boolean</code> | `es2025.float16` |
| <code>indexOf(searchElement: number, fromIndex?: number): number</code> | `es2025.float16` |
| <code>join(separator?: string): string</code> | `es2025.float16` |
| <code>keys(): ArrayIterator&lt;number&gt;</code> | `es2025.float16` |
| <code>lastIndexOf(searchElement: number, fromIndex?: number): number</code> | `es2025.float16` |
| <code>map(callbackfn: (value: number, index: number, array: this) =&gt; number, thisArg?: any): Float16Array&lt;ArrayBuffer&gt;</code> | `es2025.float16` |
| <code>readonly [Symbol.toStringTag]: "Float16Array"</code> | `es2025.float16` |
| <code>readonly buffer: TArrayBuffer</code> | `es2025.float16` |
| <code>readonly byteLength: number</code> | `es2025.float16` |
| <code>readonly byteOffset: number</code> | `es2025.float16` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es2025.float16` |
| <code>readonly length: number</code> | `es2025.float16` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es2025.float16` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es2025.float16` |
| <code>reduce&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es2025.float16` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es2025.float16` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es2025.float16` |
| <code>reduceRight&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es2025.float16` |
| <code>reverse(): this</code> | `es2025.float16` |
| <code>set(array: ArrayLike&lt;number&gt;, offset?: number): void</code> | `es2025.float16` |
| <code>slice(start?: number, end?: number): Float16Array&lt;ArrayBuffer&gt;</code> | `es2025.float16` |
| <code>some(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es2025.float16` |
| <code>sort(compareFn?: (a: number, b: number) =&gt; number): this</code> | `es2025.float16` |
| <code>subarray(begin?: number, end?: number): Float16Array&lt;TArrayBuffer&gt;</code> | `es2025.float16` |
| <code>toLocaleString(locales?: string &#124; string[], options?: Intl.NumberFormatOptions): string</code> | `es2025.float16` |
| <code>toReversed(): Float16Array&lt;ArrayBuffer&gt;</code> | `es2025.float16` |
| <code>toSorted(compareFn?: (a: number, b: number) =&gt; number): Float16Array&lt;ArrayBuffer&gt;</code> | `es2025.float16` |
| <code>toString(): string</code> | `es2025.float16` |
| <code>valueOf(): this</code> | `es2025.float16` |
| <code>values(): ArrayIterator&lt;number&gt;</code> | `es2025.float16` |
| <code>with(index: number, value: number): Float16Array&lt;ArrayBuffer&gt;</code> | `es2025.float16` |

### `Float16ArrayConstructor`

类别：interface。来源：`es2025.float16`。

```ts
interface Float16ArrayConstructor { ... }
```

声明来源：`es2025.float16`。

| 成员签名 | 来源 |
| --- | --- |
| <code>from(arrayLike: ArrayLike&lt;number&gt;): Float16Array&lt;ArrayBuffer&gt;</code> | `es2025.float16` |
| <code>from(elements: Iterable&lt;number&gt;): Float16Array&lt;ArrayBuffer&gt;</code> | `es2025.float16` |
| <code>from&lt;T&gt;(arrayLike: ArrayLike&lt;T&gt;, mapfn: (v: T, k: number) =&gt; number, thisArg?: any): Float16Array&lt;ArrayBuffer&gt;</code> | `es2025.float16` |
| <code>from&lt;T&gt;(elements: Iterable&lt;T&gt;, mapfn?: (v: T, k: number) =&gt; number, thisArg?: any): Float16Array&lt;ArrayBuffer&gt;</code> | `es2025.float16` |
| <code>new (array: ArrayLike&lt;number&gt; &#124; ArrayBuffer): Float16Array&lt;ArrayBuffer&gt;</code> | `es2025.float16` |
| <code>new (array: ArrayLike&lt;number&gt; &#124; Iterable&lt;number&gt;): Float16Array&lt;ArrayBuffer&gt;</code> | `es2025.float16` |
| <code>new (buffer: ArrayBuffer, byteOffset?: number, length?: number): Float16Array&lt;ArrayBuffer&gt;</code> | `es2025.float16` |
| <code>new (length?: number): Float16Array&lt;ArrayBuffer&gt;</code> | `es2025.float16` |
| <code>new &lt;TArrayBuffer extends ArrayBufferLike = ArrayBuffer&gt;(buffer: TArrayBuffer, byteOffset?: number, length?: number): Float16Array&lt;TArrayBuffer&gt;</code> | `es2025.float16` |
| <code>of(...items: number[]): Float16Array&lt;ArrayBuffer&gt;</code> | `es2025.float16` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es2025.float16` |
| <code>readonly prototype: Float16Array&lt;ArrayBufferLike&gt;</code> | `es2025.float16` |

### `Float32Array`

类别：interface。来源：`es2015.core`、`es2015.iterable`、`es2022.array`、`es2023.array`、`es5`。

```ts
interface Float32Array<TArrayBuffer extends ArrayBufferLike> { ... }
```

声明来源：`es2015.core`、`es2015.iterable`、`es2022.array`、`es2023.array`。

```ts
interface Float32Array<TArrayBuffer extends ArrayBufferLike = ArrayBufferLike> { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[index: number]: number</code> | `es5` |
| <code>[Symbol.iterator](): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>at(index: number): number &#124; undefined</code> | `es2022.array` |
| <code>copyWithin(target: number, start: number, end?: number): this</code> | `es5` |
| <code>entries(): ArrayIterator&lt;[ number, number ]&gt;</code> | `es2015.iterable` |
| <code>every(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>fill(value: number, start?: number, end?: number): this</code> | `es5` |
| <code>filter(predicate: (value: number, index: number, array: this) =&gt; any, thisArg?: any): Float32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>find(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number &#124; undefined</code> | `es5` |
| <code>findIndex(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number</code> | `es5` |
| <code>findLast(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number &#124; undefined</code> | `es2023.array` |
| <code>findLast&lt;S extends number&gt;(predicate: (value: number, index: number, array: this) =&gt; value is S, thisArg?: any): S &#124; undefined</code> | `es2023.array` |
| <code>findLastIndex(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number</code> | `es2023.array` |
| <code>forEach(callbackfn: (value: number, index: number, array: this) =&gt; void, thisArg?: any): void</code> | `es5` |
| <code>indexOf(searchElement: number, fromIndex?: number): number</code> | `es5` |
| <code>join(separator?: string): string</code> | `es5` |
| <code>keys(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>lastIndexOf(searchElement: number, fromIndex?: number): number</code> | `es5` |
| <code>map(callbackfn: (value: number, index: number, array: this) =&gt; number, thisArg?: any): Float32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>readonly buffer: TArrayBuffer</code> | `es5` |
| <code>readonly byteLength: number</code> | `es5` |
| <code>readonly byteOffset: number</code> | `es5` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es5` |
| <code>readonly length: number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es5` |
| <code>reduce&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es5` |
| <code>reduceRight&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reverse(): this</code> | `es5` |
| <code>set(array: ArrayLike&lt;number&gt;, offset?: number): void</code> | `es5` |
| <code>slice(start?: number, end?: number): Float32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>some(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>sort(compareFn?: (a: number, b: number) =&gt; number): this</code> | `es5` |
| <code>subarray(begin?: number, end?: number): Float32Array&lt;TArrayBuffer&gt;</code> | `es5` |
| <code>toLocaleString(): string</code> | `es5` |
| <code>toLocaleString(locales: string &#124; string[], options?: Intl.NumberFormatOptions): string</code> | `es2015.core` |
| <code>toReversed(): Float32Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toSorted(compareFn?: (a: number, b: number) =&gt; number): Float32Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toString(): string</code> | `es5` |
| <code>valueOf(): this</code> | `es5` |
| <code>values(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>with(index: number, value: number): Float32Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |

### `Float32ArrayConstructor`

类别：interface。来源：`es2015.iterable`、`es2017.typedarrays`、`es5`。

```ts
interface Float32ArrayConstructor { ... }
```

声明来源：`es2015.iterable`、`es2017.typedarrays`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>from(arrayLike: ArrayLike&lt;number&gt;): Float32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>from(elements: Iterable&lt;number&gt;): Float32Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>from&lt;T&gt;(arrayLike: ArrayLike&lt;T&gt;, mapfn: (v: T, k: number) =&gt; number, thisArg?: any): Float32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>from&lt;T&gt;(elements: Iterable&lt;T&gt;, mapfn?: (v: T, k: number) =&gt; number, thisArg?: any): Float32Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>new (): Float32Array&lt;ArrayBuffer&gt;</code> | `es2017.typedarrays` |
| <code>new (array: ArrayLike&lt;number&gt; &#124; ArrayBuffer): Float32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (array: ArrayLike&lt;number&gt;): Float32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (buffer: ArrayBuffer, byteOffset?: number, length?: number): Float32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (elements: Iterable&lt;number&gt;): Float32Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>new (length: number): Float32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new &lt;TArrayBuffer extends ArrayBufferLike = ArrayBuffer&gt;(buffer: TArrayBuffer, byteOffset?: number, length?: number): Float32Array&lt;TArrayBuffer&gt;</code> | `es5` |
| <code>of(...items: number[]): Float32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es5` |
| <code>readonly prototype: Float32Array&lt;ArrayBufferLike&gt;</code> | `es5` |

### `Float64Array`

类别：interface。来源：`es2015.core`、`es2015.iterable`、`es2022.array`、`es2023.array`、`es5`。

```ts
interface Float64Array<TArrayBuffer extends ArrayBufferLike> { ... }
```

声明来源：`es2015.core`、`es2015.iterable`、`es2022.array`、`es2023.array`。

```ts
interface Float64Array<TArrayBuffer extends ArrayBufferLike = ArrayBufferLike> { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[index: number]: number</code> | `es5` |
| <code>[Symbol.iterator](): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>at(index: number): number &#124; undefined</code> | `es2022.array` |
| <code>copyWithin(target: number, start: number, end?: number): this</code> | `es5` |
| <code>entries(): ArrayIterator&lt;[ number, number ]&gt;</code> | `es2015.iterable` |
| <code>every(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>fill(value: number, start?: number, end?: number): this</code> | `es5` |
| <code>filter(predicate: (value: number, index: number, array: this) =&gt; any, thisArg?: any): Float64Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>find(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number &#124; undefined</code> | `es5` |
| <code>findIndex(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number</code> | `es5` |
| <code>findLast(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number &#124; undefined</code> | `es2023.array` |
| <code>findLast&lt;S extends number&gt;(predicate: (value: number, index: number, array: this) =&gt; value is S, thisArg?: any): S &#124; undefined</code> | `es2023.array` |
| <code>findLastIndex(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number</code> | `es2023.array` |
| <code>forEach(callbackfn: (value: number, index: number, array: this) =&gt; void, thisArg?: any): void</code> | `es5` |
| <code>indexOf(searchElement: number, fromIndex?: number): number</code> | `es5` |
| <code>join(separator?: string): string</code> | `es5` |
| <code>keys(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>lastIndexOf(searchElement: number, fromIndex?: number): number</code> | `es5` |
| <code>map(callbackfn: (value: number, index: number, array: this) =&gt; number, thisArg?: any): Float64Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>readonly buffer: TArrayBuffer</code> | `es5` |
| <code>readonly byteLength: number</code> | `es5` |
| <code>readonly byteOffset: number</code> | `es5` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es5` |
| <code>readonly length: number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es5` |
| <code>reduce&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es5` |
| <code>reduceRight&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reverse(): this</code> | `es5` |
| <code>set(array: ArrayLike&lt;number&gt;, offset?: number): void</code> | `es5` |
| <code>slice(start?: number, end?: number): Float64Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>some(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>sort(compareFn?: (a: number, b: number) =&gt; number): this</code> | `es5` |
| <code>subarray(begin?: number, end?: number): Float64Array&lt;TArrayBuffer&gt;</code> | `es5` |
| <code>toLocaleString(): string</code> | `es5` |
| <code>toLocaleString(locales: string &#124; string[], options?: Intl.NumberFormatOptions): string</code> | `es2015.core` |
| <code>toReversed(): Float64Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toSorted(compareFn?: (a: number, b: number) =&gt; number): Float64Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toString(): string</code> | `es5` |
| <code>valueOf(): this</code> | `es5` |
| <code>values(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>with(index: number, value: number): Float64Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |

### `Float64ArrayConstructor`

类别：interface。来源：`es2015.iterable`、`es2017.typedarrays`、`es5`。

```ts
interface Float64ArrayConstructor { ... }
```

声明来源：`es2015.iterable`、`es2017.typedarrays`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>from(arrayLike: ArrayLike&lt;number&gt;): Float64Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>from(elements: Iterable&lt;number&gt;): Float64Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>from&lt;T&gt;(arrayLike: ArrayLike&lt;T&gt;, mapfn: (v: T, k: number) =&gt; number, thisArg?: any): Float64Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>from&lt;T&gt;(elements: Iterable&lt;T&gt;, mapfn?: (v: T, k: number) =&gt; number, thisArg?: any): Float64Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>new (): Float64Array&lt;ArrayBuffer&gt;</code> | `es2017.typedarrays` |
| <code>new (array: ArrayLike&lt;number&gt; &#124; ArrayBuffer): Float64Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (array: ArrayLike&lt;number&gt;): Float64Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (buffer: ArrayBuffer, byteOffset?: number, length?: number): Float64Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (elements: Iterable&lt;number&gt;): Float64Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>new (length: number): Float64Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new &lt;TArrayBuffer extends ArrayBufferLike = ArrayBuffer&gt;(buffer: TArrayBuffer, byteOffset?: number, length?: number): Float64Array&lt;TArrayBuffer&gt;</code> | `es5` |
| <code>of(...items: number[]): Float64Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es5` |
| <code>readonly prototype: Float64Array&lt;ArrayBufferLike&gt;</code> | `es5` |

### `Function`

类别：interface。来源：`es2015.core`、`es5`、`esnext.decorators`。

```ts
interface Function { ... }
```

声明来源：`es2015.core`、`es5`、`esnext.decorators`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.metadata]: DecoratorMetadata &#124; null</code> | `esnext.decorators` |
| <code>apply(this: Function, thisArg: any, argArray?: any): any</code> | `es5` |
| <code>arguments: any</code> | `es5` |
| <code>bind(this: Function, thisArg: any, ...argArray: any[]): any</code> | `es5` |
| <code>call(this: Function, thisArg: any, ...argArray: any[]): any</code> | `es5` |
| <code>caller: Function</code> | `es5` |
| <code>prototype: any</code> | `es5` |
| <code>readonly length: number</code> | `es5` |
| <code>readonly name: string</code> | `es2015.core` |
| <code>toString(): string</code> | `es5` |

### `FunctionConstructor`

类别：interface。来源：`es5`。

```ts
interface FunctionConstructor { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(...args: string[]): Function</code> | `es5` |
| <code>new (...args: string[]): Function</code> | `es5` |
| <code>readonly prototype: Function</code> | `es5` |

### `Generator`

类别：interface。来源：`es2015.generator`。

```ts
interface Generator<T = unknown, TReturn = any, TNext = any> extends IteratorObject<T, TReturn, TNext> { ... }
```

声明来源：`es2015.generator`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.iterator](): Generator&lt;T, TReturn, TNext&gt;</code> | `es2015.generator` |
| <code>next(...[value]: [ ] &#124; [ TNext ]): IteratorResult&lt;T, TReturn&gt;</code> | `es2015.generator` |
| <code>return(value: TReturn): IteratorResult&lt;T, TReturn&gt;</code> | `es2015.generator` |
| <code>throw(e: any): IteratorResult&lt;T, TReturn&gt;</code> | `es2015.generator` |

### `GeneratorFunction`

类别：interface。来源：`es2015.generator`。

```ts
interface GeneratorFunction { ... }
```

声明来源：`es2015.generator`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(...args: any[]): Generator</code> | `es2015.generator` |
| <code>new (...args: any[]): Generator</code> | `es2015.generator` |
| <code>readonly length: number</code> | `es2015.generator` |
| <code>readonly name: string</code> | `es2015.generator` |
| <code>readonly prototype: Generator</code> | `es2015.generator` |

### `GeneratorFunctionConstructor`

类别：interface。来源：`es2015.generator`。

```ts
interface GeneratorFunctionConstructor { ... }
```

声明来源：`es2015.generator`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(...args: string[]): GeneratorFunction</code> | `es2015.generator` |
| <code>new (...args: string[]): GeneratorFunction</code> | `es2015.generator` |
| <code>readonly length: number</code> | `es2015.generator` |
| <code>readonly name: string</code> | `es2015.generator` |
| <code>readonly prototype: GeneratorFunction</code> | `es2015.generator` |

### `global.IteratorConstructor`

类别：interface。来源：`es2025.iterator`。

```ts
interface IteratorConstructor extends IteratorObjectConstructor { ... }
```

声明来源：`es2025.iterator`。

| 成员签名 | 来源 |
| --- | --- |
| <code>from&lt;T&gt;(value: Iterator&lt;T, unknown, undefined&gt; &#124; Iterable&lt;T, unknown, undefined&gt;): IteratorObject&lt;T, undefined, unknown&gt;</code> | `es2025.iterator` |

### `global.IteratorObject`

类别：interface。来源：`es2025.iterator`。

```ts
interface IteratorObject<T, TReturn, TNext> { ... }
```

声明来源：`es2025.iterator`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.iterator](): IteratorObject&lt;T, TReturn, TNext&gt;</code> | `es2025.iterator` |
| <code>drop(count: number): IteratorObject&lt;T, undefined, unknown&gt;</code> | `es2025.iterator` |
| <code>every(predicate: (value: T, index: number) =&gt; unknown): boolean</code> | `es2025.iterator` |
| <code>filter(predicate: (value: T, index: number) =&gt; unknown): IteratorObject&lt;T, undefined, unknown&gt;</code> | `es2025.iterator` |
| <code>filter&lt;S extends T&gt;(predicate: (value: T, index: number) =&gt; value is S): IteratorObject&lt;S, undefined, unknown&gt;</code> | `es2025.iterator` |
| <code>find(predicate: (value: T, index: number) =&gt; unknown): T &#124; undefined</code> | `es2025.iterator` |
| <code>find&lt;S extends T&gt;(predicate: (value: T, index: number) =&gt; value is S): S &#124; undefined</code> | `es2025.iterator` |
| <code>flatMap&lt;U&gt;(callback: (value: T, index: number) =&gt; Iterator&lt;U, unknown, undefined&gt; &#124; Iterable&lt;U, unknown, undefined&gt;): IteratorObject&lt;U, undefined, unknown&gt;</code> | `es2025.iterator` |
| <code>forEach(callbackfn: (value: T, index: number) =&gt; void): void</code> | `es2025.iterator` |
| <code>map&lt;U&gt;(callbackfn: (value: T, index: number) =&gt; U): IteratorObject&lt;U, undefined, unknown&gt;</code> | `es2025.iterator` |
| <code>readonly [Symbol.toStringTag]: string</code> | `es2025.iterator` |
| <code>reduce(callbackfn: (previousValue: T, currentValue: T, currentIndex: number) =&gt; T, initialValue: T): T</code> | `es2025.iterator` |
| <code>reduce(callbackfn: (previousValue: T, currentValue: T, currentIndex: number) =&gt; T): T</code> | `es2025.iterator` |
| <code>reduce&lt;U&gt;(callbackfn: (previousValue: U, currentValue: T, currentIndex: number) =&gt; U, initialValue: U): U</code> | `es2025.iterator` |
| <code>some(predicate: (value: T, index: number) =&gt; unknown): boolean</code> | `es2025.iterator` |
| <code>take(limit: number): IteratorObject&lt;T, undefined, unknown&gt;</code> | `es2025.iterator` |
| <code>toArray(): T[]</code> | `es2025.iterator` |

### `IArguments`

类别：interface。来源：`es2015.iterable`、`es5`。

```ts
interface IArguments { ... }
```

声明来源：`es2015.iterable`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[index: number]: any</code> | `es5` |
| <code>[Symbol.iterator](): ArrayIterator&lt;any&gt;</code> | `es2015.iterable` |
| <code>callee: Function</code> | `es5` |
| <code>length: number</code> | `es5` |

### `ImportAssertions`

类别：interface。来源：`es5`。

```ts
interface ImportAssertions { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[key: string]: string</code> | `es5` |

### `ImportAttributes`

类别：interface。来源：`es5`。

```ts
interface ImportAttributes { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[key: string]: string</code> | `es5` |

### `ImportCallOptions`

类别：interface。来源：`es5`。

```ts
interface ImportCallOptions { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>assert?: ImportAssertions</code> | `es5` |
| <code>with?: ImportAttributes</code> | `es5` |

### `ImportMeta`

类别：interface。来源：`es5`。

```ts
interface ImportMeta { ... }
```

声明来源：`es5`。

### `InstanceType`

类别：type。来源：`es5`。

```ts
type InstanceType<T extends abstract new (...args: any) = T extends abstract new (...args: any) => infer R ? R : any;
```

定义来源：`es5`。

### `Int16Array`

类别：interface。来源：`es2015.core`、`es2015.iterable`、`es2022.array`、`es2023.array`、`es5`。

```ts
interface Int16Array<TArrayBuffer extends ArrayBufferLike> { ... }
```

声明来源：`es2015.core`、`es2015.iterable`、`es2022.array`、`es2023.array`。

```ts
interface Int16Array<TArrayBuffer extends ArrayBufferLike = ArrayBufferLike> { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[index: number]: number</code> | `es5` |
| <code>[Symbol.iterator](): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>at(index: number): number &#124; undefined</code> | `es2022.array` |
| <code>copyWithin(target: number, start: number, end?: number): this</code> | `es5` |
| <code>entries(): ArrayIterator&lt;[ number, number ]&gt;</code> | `es2015.iterable` |
| <code>every(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>fill(value: number, start?: number, end?: number): this</code> | `es5` |
| <code>filter(predicate: (value: number, index: number, array: this) =&gt; any, thisArg?: any): Int16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>find(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number &#124; undefined</code> | `es5` |
| <code>findIndex(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number</code> | `es5` |
| <code>findLast(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number &#124; undefined</code> | `es2023.array` |
| <code>findLast&lt;S extends number&gt;(predicate: (value: number, index: number, array: this) =&gt; value is S, thisArg?: any): S &#124; undefined</code> | `es2023.array` |
| <code>findLastIndex(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number</code> | `es2023.array` |
| <code>forEach(callbackfn: (value: number, index: number, array: this) =&gt; void, thisArg?: any): void</code> | `es5` |
| <code>indexOf(searchElement: number, fromIndex?: number): number</code> | `es5` |
| <code>join(separator?: string): string</code> | `es5` |
| <code>keys(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>lastIndexOf(searchElement: number, fromIndex?: number): number</code> | `es5` |
| <code>map(callbackfn: (value: number, index: number, array: this) =&gt; number, thisArg?: any): Int16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>readonly buffer: TArrayBuffer</code> | `es5` |
| <code>readonly byteLength: number</code> | `es5` |
| <code>readonly byteOffset: number</code> | `es5` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es5` |
| <code>readonly length: number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es5` |
| <code>reduce&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es5` |
| <code>reduceRight&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reverse(): this</code> | `es5` |
| <code>set(array: ArrayLike&lt;number&gt;, offset?: number): void</code> | `es5` |
| <code>slice(start?: number, end?: number): Int16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>some(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>sort(compareFn?: (a: number, b: number) =&gt; number): this</code> | `es5` |
| <code>subarray(begin?: number, end?: number): Int16Array&lt;TArrayBuffer&gt;</code> | `es5` |
| <code>toLocaleString(): string</code> | `es5` |
| <code>toLocaleString(locales: string &#124; string[], options?: Intl.NumberFormatOptions): string</code> | `es2015.core` |
| <code>toReversed(): Int16Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toSorted(compareFn?: (a: number, b: number) =&gt; number): Int16Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toString(): string</code> | `es5` |
| <code>valueOf(): this</code> | `es5` |
| <code>values(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>with(index: number, value: number): Int16Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |

### `Int16ArrayConstructor`

类别：interface。来源：`es2015.iterable`、`es2017.typedarrays`、`es5`。

```ts
interface Int16ArrayConstructor { ... }
```

声明来源：`es2015.iterable`、`es2017.typedarrays`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>from(arrayLike: ArrayLike&lt;number&gt;): Int16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>from(elements: Iterable&lt;number&gt;): Int16Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>from&lt;T&gt;(arrayLike: ArrayLike&lt;T&gt;, mapfn: (v: T, k: number) =&gt; number, thisArg?: any): Int16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>from&lt;T&gt;(elements: Iterable&lt;T&gt;, mapfn?: (v: T, k: number) =&gt; number, thisArg?: any): Int16Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>new (): Int16Array&lt;ArrayBuffer&gt;</code> | `es2017.typedarrays` |
| <code>new (array: ArrayLike&lt;number&gt; &#124; ArrayBuffer): Int16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (array: ArrayLike&lt;number&gt;): Int16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (buffer: ArrayBuffer, byteOffset?: number, length?: number): Int16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (elements: Iterable&lt;number&gt;): Int16Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>new (length: number): Int16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new &lt;TArrayBuffer extends ArrayBufferLike = ArrayBuffer&gt;(buffer: TArrayBuffer, byteOffset?: number, length?: number): Int16Array&lt;TArrayBuffer&gt;</code> | `es5` |
| <code>of(...items: number[]): Int16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es5` |
| <code>readonly prototype: Int16Array&lt;ArrayBufferLike&gt;</code> | `es5` |

### `Int32Array`

类别：interface。来源：`es2015.core`、`es2015.iterable`、`es2022.array`、`es2023.array`、`es5`。

```ts
interface Int32Array<TArrayBuffer extends ArrayBufferLike> { ... }
```

声明来源：`es2015.core`、`es2015.iterable`、`es2022.array`、`es2023.array`。

```ts
interface Int32Array<TArrayBuffer extends ArrayBufferLike = ArrayBufferLike> { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[index: number]: number</code> | `es5` |
| <code>[Symbol.iterator](): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>at(index: number): number &#124; undefined</code> | `es2022.array` |
| <code>copyWithin(target: number, start: number, end?: number): this</code> | `es5` |
| <code>entries(): ArrayIterator&lt;[ number, number ]&gt;</code> | `es2015.iterable` |
| <code>every(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>fill(value: number, start?: number, end?: number): this</code> | `es5` |
| <code>filter(predicate: (value: number, index: number, array: this) =&gt; any, thisArg?: any): Int32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>find(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number &#124; undefined</code> | `es5` |
| <code>findIndex(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number</code> | `es5` |
| <code>findLast(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number &#124; undefined</code> | `es2023.array` |
| <code>findLast&lt;S extends number&gt;(predicate: (value: number, index: number, array: this) =&gt; value is S, thisArg?: any): S &#124; undefined</code> | `es2023.array` |
| <code>findLastIndex(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number</code> | `es2023.array` |
| <code>forEach(callbackfn: (value: number, index: number, array: this) =&gt; void, thisArg?: any): void</code> | `es5` |
| <code>indexOf(searchElement: number, fromIndex?: number): number</code> | `es5` |
| <code>join(separator?: string): string</code> | `es5` |
| <code>keys(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>lastIndexOf(searchElement: number, fromIndex?: number): number</code> | `es5` |
| <code>map(callbackfn: (value: number, index: number, array: this) =&gt; number, thisArg?: any): Int32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>readonly buffer: TArrayBuffer</code> | `es5` |
| <code>readonly byteLength: number</code> | `es5` |
| <code>readonly byteOffset: number</code> | `es5` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es5` |
| <code>readonly length: number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es5` |
| <code>reduce&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es5` |
| <code>reduceRight&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reverse(): this</code> | `es5` |
| <code>set(array: ArrayLike&lt;number&gt;, offset?: number): void</code> | `es5` |
| <code>slice(start?: number, end?: number): Int32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>some(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>sort(compareFn?: (a: number, b: number) =&gt; number): this</code> | `es5` |
| <code>subarray(begin?: number, end?: number): Int32Array&lt;TArrayBuffer&gt;</code> | `es5` |
| <code>toLocaleString(): string</code> | `es5` |
| <code>toLocaleString(locales: string &#124; string[], options?: Intl.NumberFormatOptions): string</code> | `es2015.core` |
| <code>toReversed(): Int32Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toSorted(compareFn?: (a: number, b: number) =&gt; number): Int32Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toString(): string</code> | `es5` |
| <code>valueOf(): this</code> | `es5` |
| <code>values(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>with(index: number, value: number): Int32Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |

### `Int32ArrayConstructor`

类别：interface。来源：`es2015.iterable`、`es2017.typedarrays`、`es5`。

```ts
interface Int32ArrayConstructor { ... }
```

声明来源：`es2015.iterable`、`es2017.typedarrays`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>from(arrayLike: ArrayLike&lt;number&gt;): Int32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>from(elements: Iterable&lt;number&gt;): Int32Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>from&lt;T&gt;(arrayLike: ArrayLike&lt;T&gt;, mapfn: (v: T, k: number) =&gt; number, thisArg?: any): Int32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>from&lt;T&gt;(elements: Iterable&lt;T&gt;, mapfn?: (v: T, k: number) =&gt; number, thisArg?: any): Int32Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>new (): Int32Array&lt;ArrayBuffer&gt;</code> | `es2017.typedarrays` |
| <code>new (array: ArrayLike&lt;number&gt; &#124; ArrayBuffer): Int32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (array: ArrayLike&lt;number&gt;): Int32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (buffer: ArrayBuffer, byteOffset?: number, length?: number): Int32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (elements: Iterable&lt;number&gt;): Int32Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>new (length: number): Int32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new &lt;TArrayBuffer extends ArrayBufferLike = ArrayBuffer&gt;(buffer: TArrayBuffer, byteOffset?: number, length?: number): Int32Array&lt;TArrayBuffer&gt;</code> | `es5` |
| <code>of(...items: number[]): Int32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es5` |
| <code>readonly prototype: Int32Array&lt;ArrayBufferLike&gt;</code> | `es5` |

### `Int8Array`

类别：interface。来源：`es2015.core`、`es2015.iterable`、`es2022.array`、`es2023.array`、`es5`。

```ts
interface Int8Array<TArrayBuffer extends ArrayBufferLike> { ... }
```

声明来源：`es2015.core`、`es2015.iterable`、`es2022.array`、`es2023.array`。

```ts
interface Int8Array<TArrayBuffer extends ArrayBufferLike = ArrayBufferLike> { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[index: number]: number</code> | `es5` |
| <code>[Symbol.iterator](): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>at(index: number): number &#124; undefined</code> | `es2022.array` |
| <code>copyWithin(target: number, start: number, end?: number): this</code> | `es5` |
| <code>entries(): ArrayIterator&lt;[ number, number ]&gt;</code> | `es2015.iterable` |
| <code>every(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>fill(value: number, start?: number, end?: number): this</code> | `es5` |
| <code>filter(predicate: (value: number, index: number, array: this) =&gt; any, thisArg?: any): Int8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>find(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number &#124; undefined</code> | `es5` |
| <code>findIndex(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number</code> | `es5` |
| <code>findLast(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number &#124; undefined</code> | `es2023.array` |
| <code>findLast&lt;S extends number&gt;(predicate: (value: number, index: number, array: this) =&gt; value is S, thisArg?: any): S &#124; undefined</code> | `es2023.array` |
| <code>findLastIndex(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number</code> | `es2023.array` |
| <code>forEach(callbackfn: (value: number, index: number, array: this) =&gt; void, thisArg?: any): void</code> | `es5` |
| <code>indexOf(searchElement: number, fromIndex?: number): number</code> | `es5` |
| <code>join(separator?: string): string</code> | `es5` |
| <code>keys(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>lastIndexOf(searchElement: number, fromIndex?: number): number</code> | `es5` |
| <code>map(callbackfn: (value: number, index: number, array: this) =&gt; number, thisArg?: any): Int8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>readonly buffer: TArrayBuffer</code> | `es5` |
| <code>readonly byteLength: number</code> | `es5` |
| <code>readonly byteOffset: number</code> | `es5` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es5` |
| <code>readonly length: number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es5` |
| <code>reduce&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es5` |
| <code>reduceRight&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reverse(): this</code> | `es5` |
| <code>set(array: ArrayLike&lt;number&gt;, offset?: number): void</code> | `es5` |
| <code>slice(start?: number, end?: number): Int8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>some(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>sort(compareFn?: (a: number, b: number) =&gt; number): this</code> | `es5` |
| <code>subarray(begin?: number, end?: number): Int8Array&lt;TArrayBuffer&gt;</code> | `es5` |
| <code>toLocaleString(): string</code> | `es5` |
| <code>toLocaleString(locales: string &#124; string[], options?: Intl.NumberFormatOptions): string</code> | `es2015.core` |
| <code>toReversed(): Int8Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toSorted(compareFn?: (a: number, b: number) =&gt; number): Int8Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toString(): string</code> | `es5` |
| <code>valueOf(): this</code> | `es5` |
| <code>values(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>with(index: number, value: number): Int8Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |

### `Int8ArrayConstructor`

类别：interface。来源：`es2015.iterable`、`es2017.typedarrays`、`es5`。

```ts
interface Int8ArrayConstructor { ... }
```

声明来源：`es2015.iterable`、`es2017.typedarrays`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>from(arrayLike: ArrayLike&lt;number&gt;): Int8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>from(elements: Iterable&lt;number&gt;): Int8Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>from&lt;T&gt;(arrayLike: ArrayLike&lt;T&gt;, mapfn: (v: T, k: number) =&gt; number, thisArg?: any): Int8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>from&lt;T&gt;(elements: Iterable&lt;T&gt;, mapfn?: (v: T, k: number) =&gt; number, thisArg?: any): Int8Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>new (): Int8Array&lt;ArrayBuffer&gt;</code> | `es2017.typedarrays` |
| <code>new (array: ArrayLike&lt;number&gt; &#124; ArrayBuffer): Int8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (array: ArrayLike&lt;number&gt;): Int8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (buffer: ArrayBuffer, byteOffset?: number, length?: number): Int8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (elements: Iterable&lt;number&gt;): Int8Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>new (length: number): Int8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new &lt;TArrayBuffer extends ArrayBufferLike = ArrayBuffer&gt;(buffer: TArrayBuffer, byteOffset?: number, length?: number): Int8Array&lt;TArrayBuffer&gt;</code> | `es5` |
| <code>of(...items: number[]): Int8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es5` |
| <code>readonly prototype: Int8Array&lt;ArrayBufferLike&gt;</code> | `es5` |

### `Intl.Collator`

类别：interface。来源：`es5`。

```ts
interface Collator { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>compare(x: string, y: string): number</code> | `es5` |
| <code>resolvedOptions(): ResolvedCollatorOptions</code> | `es5` |

### `Intl.CollatorConstructor`

类别：interface。来源：`es2020.intl`、`es5`。

```ts
interface CollatorConstructor { ... }
```

声明来源：`es2020.intl`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(locales?: LocalesArgument, options?: CollatorOptions): Collator</code> | `es2020.intl` |
| <code>(locales?: string &#124; string[], options?: CollatorOptions): Collator</code> | `es5` |
| <code>new (locales?: LocalesArgument, options?: CollatorOptions): Collator</code> | `es2020.intl` |
| <code>new (locales?: string &#124; string[], options?: CollatorOptions): Collator</code> | `es5` |
| <code>supportedLocalesOf(locales: LocalesArgument, options?: CollatorOptions): string[]</code> | `es2020.intl` |
| <code>supportedLocalesOf(locales: string &#124; string[], options?: CollatorOptions): string[]</code> | `es5` |

### `Intl.CollatorOptions`

类别：interface。来源：`es5`。

```ts
interface CollatorOptions { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>caseFirst?: "upper" &#124; "lower" &#124; "false" &#124; undefined</code> | `es5` |
| <code>collation?: "big5han" &#124; "compat" &#124; "default" &#124; "dict" &#124; "direct" &#124; "ducet" &#124; "emoji" &#124; "eor" &#124; "gb2312" &#124; "phonebk" &#124; "phonetic" &#124; "pinyin" &#124; "reformed" &#124; "searchjl" &#124; "stroke" &#124; "trad" &#124; "unihan" &#124; "zhuyin" &#124; undefined</code> | `es5` |
| <code>ignorePunctuation?: boolean &#124; undefined</code> | `es5` |
| <code>localeMatcher?: "lookup" &#124; "best fit" &#124; undefined</code> | `es5` |
| <code>numeric?: boolean &#124; undefined</code> | `es5` |
| <code>sensitivity?: "base" &#124; "accent" &#124; "case" &#124; "variant" &#124; undefined</code> | `es5` |
| <code>usage?: "sort" &#124; "search" &#124; undefined</code> | `es5` |

### `Intl.DateTimeFormat`

类别：interface。来源：`es2017.intl`、`es2021.intl`、`es5`、`esnext.intl`。

```ts
interface DateTimeFormat { ... }
```

声明来源：`es2017.intl`、`es2021.intl`、`es5`、`esnext.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>format(date?: Date &#124; number): string</code> | `es5` |
| <code>format(date?: FormattableTemporalObject &#124; Date &#124; number): string</code> | `esnext.intl` |
| <code>formatRange(startDate: Date &#124; number &#124; bigint, endDate: Date &#124; number &#124; bigint): string</code> | `es2021.intl` |
| <code>formatRange(startDate: FormattableTemporalObject &#124; Date &#124; number, endDate: FormattableTemporalObject &#124; Date &#124; number): string</code> | `esnext.intl` |
| <code>formatRangeToParts(startDate: Date &#124; number &#124; bigint, endDate: Date &#124; number &#124; bigint): DateTimeRangeFormatPart[]</code> | `es2021.intl` |
| <code>formatRangeToParts(startDate: FormattableTemporalObject &#124; Date &#124; number, endDate: FormattableTemporalObject &#124; Date &#124; number): DateTimeRangeFormatPart[]</code> | `esnext.intl` |
| <code>formatToParts(date?: Date &#124; number): DateTimeFormatPart[]</code> | `es2017.intl` |
| <code>formatToParts(date?: FormattableTemporalObject &#124; Date &#124; number): DateTimeFormatPart[]</code> | `esnext.intl` |
| <code>resolvedOptions(): ResolvedDateTimeFormatOptions</code> | `es5` |

### `Intl.DateTimeFormatConstructor`

类别：interface。来源：`es2020.intl`、`es5`。

```ts
interface DateTimeFormatConstructor { ... }
```

声明来源：`es2020.intl`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(locales?: LocalesArgument, options?: DateTimeFormatOptions): DateTimeFormat</code> | `es2020.intl` |
| <code>(locales?: string &#124; string[], options?: DateTimeFormatOptions): DateTimeFormat</code> | `es5` |
| <code>new (locales?: LocalesArgument, options?: DateTimeFormatOptions): DateTimeFormat</code> | `es2020.intl` |
| <code>new (locales?: string &#124; string[], options?: DateTimeFormatOptions): DateTimeFormat</code> | `es5` |
| <code>readonly prototype: DateTimeFormat</code> | `es5` |
| <code>supportedLocalesOf(locales: LocalesArgument, options?: DateTimeFormatOptions): string[]</code> | `es2020.intl` |
| <code>supportedLocalesOf(locales: string &#124; string[], options?: DateTimeFormatOptions): string[]</code> | `es5` |

### `Intl.DateTimeFormatOptions`

类别：interface。来源：`es2020.intl`、`es2021.intl`、`es5`。

```ts
interface DateTimeFormatOptions { ... }
```

声明来源：`es2020.intl`、`es2021.intl`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>calendar?: string &#124; undefined</code> | `es2020.intl` |
| <code>dateStyle?: "full" &#124; "long" &#124; "medium" &#124; "short" &#124; undefined</code> | `es2020.intl`、`es2021.intl` |
| <code>day?: "numeric" &#124; "2-digit" &#124; undefined</code> | `es5` |
| <code>dayPeriod?: "narrow" &#124; "short" &#124; "long" &#124; undefined</code> | `es2020.intl`、`es2021.intl` |
| <code>era?: "long" &#124; "short" &#124; "narrow" &#124; undefined</code> | `es5` |
| <code>formatMatcher?: "basic" &#124; "best fit" &#124; "best fit" &#124; undefined</code> | `es2021.intl` |
| <code>formatMatcher?: "best fit" &#124; "basic" &#124; undefined</code> | `es5` |
| <code>fractionalSecondDigits?: 1 &#124; 2 &#124; 3 &#124; undefined</code> | `es2021.intl` |
| <code>hour?: "numeric" &#124; "2-digit" &#124; undefined</code> | `es5` |
| <code>hour12?: boolean &#124; undefined</code> | `es5` |
| <code>hourCycle?: "h11" &#124; "h12" &#124; "h23" &#124; "h24" &#124; undefined</code> | `es2020.intl` |
| <code>localeMatcher?: "best fit" &#124; "lookup" &#124; undefined</code> | `es5` |
| <code>minute?: "numeric" &#124; "2-digit" &#124; undefined</code> | `es5` |
| <code>month?: "numeric" &#124; "2-digit" &#124; "long" &#124; "short" &#124; "narrow" &#124; undefined</code> | `es5` |
| <code>numberingSystem?: string &#124; undefined</code> | `es2020.intl` |
| <code>second?: "numeric" &#124; "2-digit" &#124; undefined</code> | `es5` |
| <code>timeStyle?: "full" &#124; "long" &#124; "medium" &#124; "short" &#124; undefined</code> | `es2020.intl`、`es2021.intl` |
| <code>timeZone?: string &#124; undefined</code> | `es5` |
| <code>timeZoneName?: "short" &#124; "long" &#124; "shortOffset" &#124; "longOffset" &#124; "shortGeneric" &#124; "longGeneric" &#124; undefined</code> | `es5` |
| <code>weekday?: "long" &#124; "short" &#124; "narrow" &#124; undefined</code> | `es5` |
| <code>year?: "numeric" &#124; "2-digit" &#124; undefined</code> | `es5` |

### `Intl.DateTimeFormatPart`

类别：interface。来源：`es2017.intl`。

```ts
interface DateTimeFormatPart { ... }
```

声明来源：`es2017.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>type: DateTimeFormatPartTypes</code> | `es2017.intl` |
| <code>value: string</code> | `es2017.intl` |

### `Intl.DateTimeFormatPartTypes`

类别：type。来源：`es2017.intl`。

```ts
type DateTimeFormatPartTypes = keyof DateTimeFormatPartTypesRegistry;
```

定义来源：`es2017.intl`。

### `Intl.DateTimeFormatPartTypesRegistry`

类别：interface。来源：`es2017.intl`、`es2019.intl`、`es2021.intl`。

```ts
interface DateTimeFormatPartTypesRegistry { ... }
```

声明来源：`es2017.intl`、`es2019.intl`、`es2021.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>day: any</code> | `es2017.intl` |
| <code>dayPeriod: any</code> | `es2017.intl` |
| <code>era: any</code> | `es2017.intl` |
| <code>fractionalSecond: any</code> | `es2021.intl` |
| <code>hour: any</code> | `es2017.intl` |
| <code>literal: any</code> | `es2017.intl` |
| <code>minute: any</code> | `es2017.intl` |
| <code>month: any</code> | `es2017.intl` |
| <code>second: any</code> | `es2017.intl` |
| <code>timeZoneName: any</code> | `es2017.intl` |
| <code>unknown: never</code> | `es2019.intl` |
| <code>weekday: any</code> | `es2017.intl` |
| <code>year: any</code> | `es2017.intl` |

### `Intl.DateTimeRangeFormatPart`

类别：interface。来源：`es2021.intl`。

```ts
interface DateTimeRangeFormatPart extends DateTimeFormatPart { ... }
```

声明来源：`es2021.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>source: "startRange" &#124; "endRange" &#124; "shared"</code> | `es2021.intl` |

### `Intl.DisplayNames`

类别：interface。来源：`es2020.intl`。

```ts
interface DisplayNames { ... }
```

声明来源：`es2020.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>of(code: string): string &#124; undefined</code> | `es2020.intl` |
| <code>resolvedOptions(): ResolvedDisplayNamesOptions</code> | `es2020.intl` |

### `Intl.DisplayNamesFallback`

类别：type。来源：`es2020.intl`。

```ts
type DisplayNamesFallback = | "code" | "none";
```

定义来源：`es2020.intl`。

### `Intl.DisplayNamesLanguageDisplay`

类别：type。来源：`es2020.intl`。

```ts
type DisplayNamesLanguageDisplay = | "dialect" | "standard";
```

定义来源：`es2020.intl`。

### `Intl.DisplayNamesOptions`

类别：interface。来源：`es2020.intl`。

```ts
interface DisplayNamesOptions { ... }
```

声明来源：`es2020.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>fallback?: DisplayNamesFallback</code> | `es2020.intl` |
| <code>languageDisplay?: DisplayNamesLanguageDisplay</code> | `es2020.intl` |
| <code>localeMatcher?: RelativeTimeFormatLocaleMatcher</code> | `es2020.intl` |
| <code>style?: RelativeTimeFormatStyle</code> | `es2020.intl` |
| <code>type: DisplayNamesType</code> | `es2020.intl` |

### `Intl.DisplayNamesType`

类别：type。来源：`es2020.intl`。

```ts
type DisplayNamesType = | "language" | "region" | "script" | "calendar" | "dateTimeField" | "currency";
```

定义来源：`es2020.intl`。

### `Intl.DurationFormat`

类别：interface。来源：`es2025.intl`。

```ts
interface DurationFormat { ... }
```

声明来源：`es2025.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>format(duration: Partial&lt;Record&lt;DurationFormatUnit, number&gt;&gt;): string</code> | `es2025.intl` |
| <code>formatToParts(duration: Partial&lt;Record&lt;DurationFormatUnit, number&gt;&gt;): DurationFormatPart[]</code> | `es2025.intl` |
| <code>resolvedOptions(): ResolvedDurationFormatOptions</code> | `es2025.intl` |

### `Intl.DurationFormatDisplayOption`

类别：type。来源：`es2025.intl`。

```ts
type DurationFormatDisplayOption = "always" | "auto";
```

定义来源：`es2025.intl`。

### `Intl.DurationFormatLocaleMatcher`

类别：type。来源：`es2025.intl`。

```ts
type DurationFormatLocaleMatcher = "lookup" | "best fit";
```

定义来源：`es2025.intl`。

### `Intl.DurationFormatOptions`

类别：interface。来源：`es2025.intl`。

```ts
interface DurationFormatOptions { ... }
```

声明来源：`es2025.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>days?: "long" &#124; "short" &#124; "narrow" &#124; undefined</code> | `es2025.intl` |
| <code>daysDisplay?: DurationFormatDisplayOption &#124; undefined</code> | `es2025.intl` |
| <code>fractionalDigits?: 0 &#124; 1 &#124; 2 &#124; 3 &#124; 4 &#124; 5 &#124; 6 &#124; 7 &#124; 8 &#124; 9 &#124; undefined</code> | `es2025.intl` |
| <code>hours?: "long" &#124; "short" &#124; "narrow" &#124; "numeric" &#124; "2-digit" &#124; undefined</code> | `es2025.intl` |
| <code>hoursDisplay?: DurationFormatDisplayOption &#124; undefined</code> | `es2025.intl` |
| <code>localeMatcher?: DurationFormatLocaleMatcher &#124; undefined</code> | `es2025.intl` |
| <code>microseconds?: "long" &#124; "short" &#124; "narrow" &#124; "numeric" &#124; undefined</code> | `es2025.intl` |
| <code>microsecondsDisplay?: DurationFormatDisplayOption &#124; undefined</code> | `es2025.intl` |
| <code>milliseconds?: "long" &#124; "short" &#124; "narrow" &#124; "numeric" &#124; undefined</code> | `es2025.intl` |
| <code>millisecondsDisplay?: DurationFormatDisplayOption &#124; undefined</code> | `es2025.intl` |
| <code>minutes?: "long" &#124; "short" &#124; "narrow" &#124; "numeric" &#124; "2-digit" &#124; undefined</code> | `es2025.intl` |
| <code>minutesDisplay?: DurationFormatDisplayOption &#124; undefined</code> | `es2025.intl` |
| <code>months?: "long" &#124; "short" &#124; "narrow" &#124; undefined</code> | `es2025.intl` |
| <code>monthsDisplay?: DurationFormatDisplayOption &#124; undefined</code> | `es2025.intl` |
| <code>nanoseconds?: "long" &#124; "short" &#124; "narrow" &#124; "numeric" &#124; undefined</code> | `es2025.intl` |
| <code>nanosecondsDisplay?: DurationFormatDisplayOption &#124; undefined</code> | `es2025.intl` |
| <code>numberingSystem?: string &#124; undefined</code> | `es2025.intl` |
| <code>seconds?: "long" &#124; "short" &#124; "narrow" &#124; "numeric" &#124; "2-digit" &#124; undefined</code> | `es2025.intl` |
| <code>secondsDisplay?: DurationFormatDisplayOption &#124; undefined</code> | `es2025.intl` |
| <code>style?: DurationFormatStyle &#124; undefined</code> | `es2025.intl` |
| <code>weeks?: "long" &#124; "short" &#124; "narrow" &#124; undefined</code> | `es2025.intl` |
| <code>weeksDisplay?: DurationFormatDisplayOption &#124; undefined</code> | `es2025.intl` |
| <code>years?: "long" &#124; "short" &#124; "narrow" &#124; undefined</code> | `es2025.intl` |
| <code>yearsDisplay?: DurationFormatDisplayOption &#124; undefined</code> | `es2025.intl` |

### `Intl.DurationFormatPart`

类别：type。来源：`es2025.intl`。

```ts
type DurationFormatPart = | { type: "literal"; value: string; unit?: DurationFormatUnitSingular; } | { type: Exclude<NumberFormatPartTypes, "literal">; value: string; unit: DurationFormatUnitSingular; };
```

定义来源：`es2025.intl`。

### `Intl.DurationFormatStyle`

类别：type。来源：`es2025.intl`。

```ts
type DurationFormatStyle = "long" | "short" | "narrow" | "digital";
```

定义来源：`es2025.intl`。

### `Intl.DurationFormatUnit`

类别：type。来源：`es2025.intl`。

```ts
type DurationFormatUnit = | "years" | "months" | "weeks" | "days" | "hours" | "minutes" | "seconds" | "milliseconds" | "microseconds" | "nanoseconds";
```

定义来源：`es2025.intl`。

### `Intl.DurationFormatUnitSingular`

类别：type。来源：`es2025.intl`。

```ts
type DurationFormatUnitSingular = | "year" | "month" | "week" | "day" | "hour" | "minute" | "second" | "millisecond" | "microsecond" | "nanosecond";
```

定义来源：`es2025.intl`。

### `Intl.FormattableTemporalObject`

类别：type。来源：`esnext.intl`。

```ts
type FormattableTemporalObject = Temporal.PlainDate | Temporal.PlainYearMonth | Temporal.PlainMonthDay | Temporal.PlainTime | Temporal.PlainDateTime | Temporal.Instant;
```

定义来源：`esnext.intl`。

### `Intl.LDMLPluralRule`

类别：type。来源：`es2018.intl`。

```ts
type LDMLPluralRule = "zero" | "one" | "two" | "few" | "many" | "other";
```

定义来源：`es2018.intl`。

### `Intl.ListFormat`

类别：interface。来源：`es2021.intl`。

```ts
interface ListFormat { ... }
```

声明来源：`es2021.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>format(list: Iterable&lt;string&gt;): string</code> | `es2021.intl` |
| <code>formatToParts(list: Iterable&lt;string&gt;): { type: "element" &#124; "literal"; value: string; }[]</code> | `es2021.intl` |
| <code>resolvedOptions(): ResolvedListFormatOptions</code> | `es2021.intl` |

### `Intl.ListFormatLocaleMatcher`

类别：type。来源：`es2021.intl`。

```ts
type ListFormatLocaleMatcher = "lookup" | "best fit";
```

定义来源：`es2021.intl`。

### `Intl.ListFormatOptions`

类别：interface。来源：`es2021.intl`。

```ts
interface ListFormatOptions { ... }
```

声明来源：`es2021.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>localeMatcher?: ListFormatLocaleMatcher &#124; undefined</code> | `es2021.intl` |
| <code>style?: ListFormatStyle &#124; undefined</code> | `es2021.intl` |
| <code>type?: ListFormatType &#124; undefined</code> | `es2021.intl` |

### `Intl.ListFormatStyle`

类别：type。来源：`es2021.intl`。

```ts
type ListFormatStyle = "long" | "short" | "narrow";
```

定义来源：`es2021.intl`。

### `Intl.ListFormatType`

类别：type。来源：`es2021.intl`。

```ts
type ListFormatType = "conjunction" | "disjunction" | "unit";
```

定义来源：`es2021.intl`。

### `Intl.Locale`

类别：interface。来源：`es2020.intl`、`esnext.intl`。

```ts
interface Locale extends LocaleOptions { ... }
```

声明来源：`es2020.intl`。

```ts
interface Locale { ... }
```

声明来源：`esnext.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>baseName: string</code> | `es2020.intl` |
| <code>getCalendars(): string[]</code> | `esnext.intl` |
| <code>getCollations(): string[]</code> | `esnext.intl` |
| <code>getHourCycles(): string[]</code> | `esnext.intl` |
| <code>getNumberingSystems(): string[]</code> | `esnext.intl` |
| <code>getTextInfo(): TextInfo</code> | `esnext.intl` |
| <code>getTimeZones(): string[] &#124; undefined</code> | `esnext.intl` |
| <code>getWeekInfo(): WeekInfo</code> | `esnext.intl` |
| <code>language: string</code> | `es2020.intl` |
| <code>maximize(): Locale</code> | `es2020.intl` |
| <code>minimize(): Locale</code> | `es2020.intl` |
| <code>toString(): UnicodeBCP47LocaleIdentifier</code> | `es2020.intl` |

### `Intl.LocaleCollationCaseFirst`

类别：type。来源：`es2020.intl`。

```ts
type LocaleCollationCaseFirst = "upper" | "lower" | "false";
```

定义来源：`es2020.intl`。

### `Intl.LocaleHourCycleKey`

类别：type。来源：`es2020.intl`。

```ts
type LocaleHourCycleKey = "h12" | "h23" | "h11" | "h24";
```

定义来源：`es2020.intl`。

### `Intl.LocaleOptions`

类别：interface。来源：`es2020.intl`。

```ts
interface LocaleOptions { ... }
```

声明来源：`es2020.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>baseName?: string</code> | `es2020.intl` |
| <code>calendar?: string</code> | `es2020.intl` |
| <code>caseFirst?: LocaleCollationCaseFirst</code> | `es2020.intl` |
| <code>collation?: string</code> | `es2020.intl` |
| <code>hourCycle?: LocaleHourCycleKey</code> | `es2020.intl` |
| <code>language?: string</code> | `es2020.intl` |
| <code>numberingSystem?: string</code> | `es2020.intl` |
| <code>numeric?: boolean</code> | `es2020.intl` |
| <code>region?: string</code> | `es2020.intl` |
| <code>script?: string</code> | `es2020.intl` |

### `Intl.LocalesArgument`

类别：type。来源：`es2020.intl`。

```ts
type LocalesArgument = UnicodeBCP47LocaleIdentifier | Locale | readonly (UnicodeBCP47LocaleIdentifier | Locale)[] | undefined;
```

定义来源：`es2020.intl`。

### `Intl.NumberFormat`

类别：interface。来源：`es2018.intl`、`es2020.bigint`、`es2023.intl`、`es5`。

```ts
interface NumberFormat { ... }
```

声明来源：`es2018.intl`、`es2020.bigint`、`es2023.intl`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>format(value: number &#124; bigint &#124; StringNumericLiteral): string</code> | `es2023.intl` |
| <code>format(value: number &#124; bigint): string</code> | `es2020.bigint` |
| <code>format(value: number): string</code> | `es5` |
| <code>formatRange(start: number &#124; bigint &#124; StringNumericLiteral, end: number &#124; bigint &#124; StringNumericLiteral): string</code> | `es2023.intl` |
| <code>formatRangeToParts(start: number &#124; bigint &#124; StringNumericLiteral, end: number &#124; bigint &#124; StringNumericLiteral): NumberRangeFormatPart[]</code> | `es2023.intl` |
| <code>formatToParts(number?: number &#124; bigint): NumberFormatPart[]</code> | `es2018.intl` |
| <code>formatToParts(value: number &#124; bigint &#124; StringNumericLiteral): NumberFormatPart[]</code> | `es2023.intl` |
| <code>resolvedOptions(): ResolvedNumberFormatOptions</code> | `es5` |

### `Intl.NumberFormatConstructor`

类别：interface。来源：`es2020.intl`、`es5`。

```ts
interface NumberFormatConstructor { ... }
```

声明来源：`es2020.intl`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(locales?: LocalesArgument, options?: NumberFormatOptions): NumberFormat</code> | `es2020.intl` |
| <code>(locales?: string &#124; string[], options?: NumberFormatOptions): NumberFormat</code> | `es5` |
| <code>new (locales?: LocalesArgument, options?: NumberFormatOptions): NumberFormat</code> | `es2020.intl` |
| <code>new (locales?: string &#124; string[], options?: NumberFormatOptions): NumberFormat</code> | `es5` |
| <code>readonly prototype: NumberFormat</code> | `es5` |
| <code>supportedLocalesOf(locales: LocalesArgument, options?: NumberFormatOptions): string[]</code> | `es2020.intl` |
| <code>supportedLocalesOf(locales: string &#124; string[], options?: NumberFormatOptions): string[]</code> | `es5` |

### `Intl.NumberFormatOptions`

类别：interface。来源：`es2020.intl`、`es2023.intl`、`es5`。

```ts
interface NumberFormatOptions { ... }
```

声明来源：`es2020.intl`、`es2023.intl`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>compactDisplay?: "short" &#124; "long" &#124; undefined</code> | `es2020.intl` |
| <code>currency?: string &#124; undefined</code> | `es5` |
| <code>currencyDisplay?: NumberFormatOptionsCurrencyDisplay &#124; undefined</code> | `es5` |
| <code>currencySign?: "standard" &#124; "accounting" &#124; undefined</code> | `es2020.intl` |
| <code>localeMatcher?: "lookup" &#124; "best fit" &#124; undefined</code> | `es5` |
| <code>maximumFractionDigits?: number &#124; undefined</code> | `es5` |
| <code>maximumSignificantDigits?: number &#124; undefined</code> | `es5` |
| <code>minimumFractionDigits?: number &#124; undefined</code> | `es5` |
| <code>minimumIntegerDigits?: number &#124; undefined</code> | `es5` |
| <code>minimumSignificantDigits?: number &#124; undefined</code> | `es5` |
| <code>notation?: "standard" &#124; "scientific" &#124; "engineering" &#124; "compact" &#124; undefined</code> | `es2020.intl` |
| <code>numberingSystem?: string &#124; undefined</code> | `es2020.intl` |
| <code>roundingIncrement?: 1 &#124; 2 &#124; 5 &#124; 10 &#124; 20 &#124; 25 &#124; 50 &#124; 100 &#124; 200 &#124; 250 &#124; 500 &#124; 1000 &#124; 2000 &#124; 2500 &#124; 5000 &#124; undefined</code> | `es2023.intl` |
| <code>roundingMode?: "ceil" &#124; "floor" &#124; "expand" &#124; "trunc" &#124; "halfCeil" &#124; "halfFloor" &#124; "halfExpand" &#124; "halfTrunc" &#124; "halfEven" &#124; undefined</code> | `es2023.intl` |
| <code>roundingPriority?: "auto" &#124; "morePrecision" &#124; "lessPrecision" &#124; undefined</code> | `es2023.intl` |
| <code>signDisplay?: NumberFormatOptionsSignDisplay &#124; undefined</code> | `es2020.intl` |
| <code>style?: NumberFormatOptionsStyle &#124; undefined</code> | `es5` |
| <code>trailingZeroDisplay?: "auto" &#124; "stripIfInteger" &#124; undefined</code> | `es2023.intl` |
| <code>unit?: string &#124; undefined</code> | `es2020.intl` |
| <code>unitDisplay?: "short" &#124; "long" &#124; "narrow" &#124; undefined</code> | `es2020.intl` |
| <code>useGrouping?: NumberFormatOptionsUseGrouping &#124; undefined</code> | `es5` |

### `Intl.NumberFormatOptionsCurrencyDisplay`

类别：type。来源：`es5`。

```ts
type NumberFormatOptionsCurrencyDisplay = keyof NumberFormatOptionsCurrencyDisplayRegistry;
```

定义来源：`es5`。

### `Intl.NumberFormatOptionsCurrencyDisplayRegistry`

类别：interface。来源：`es2020.intl`、`es5`。

```ts
interface NumberFormatOptionsCurrencyDisplayRegistry { ... }
```

声明来源：`es2020.intl`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>code: never</code> | `es5` |
| <code>name: never</code> | `es5` |
| <code>narrowSymbol: never</code> | `es2020.intl` |
| <code>symbol: never</code> | `es5` |

### `Intl.NumberFormatOptionsSignDisplay`

类别：type。来源：`es2020.intl`。

```ts
type NumberFormatOptionsSignDisplay = keyof NumberFormatOptionsSignDisplayRegistry;
```

定义来源：`es2020.intl`。

### `Intl.NumberFormatOptionsSignDisplayRegistry`

类别：interface。来源：`es2020.intl`、`es2023.intl`。

```ts
interface NumberFormatOptionsSignDisplayRegistry { ... }
```

声明来源：`es2020.intl`、`es2023.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>always: never</code> | `es2020.intl` |
| <code>auto: never</code> | `es2020.intl` |
| <code>exceptZero: never</code> | `es2020.intl` |
| <code>negative: never</code> | `es2023.intl` |
| <code>never: never</code> | `es2020.intl` |

### `Intl.NumberFormatOptionsStyle`

类别：type。来源：`es5`。

```ts
type NumberFormatOptionsStyle = keyof NumberFormatOptionsStyleRegistry;
```

定义来源：`es5`。

### `Intl.NumberFormatOptionsStyleRegistry`

类别：interface。来源：`es2020.intl`、`es5`。

```ts
interface NumberFormatOptionsStyleRegistry { ... }
```

声明来源：`es2020.intl`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>currency: never</code> | `es5` |
| <code>decimal: never</code> | `es5` |
| <code>percent: never</code> | `es5` |
| <code>unit: never</code> | `es2020.intl` |

### `Intl.NumberFormatOptionsUseGrouping`

类别：type。来源：`es5`。

```ts
type NumberFormatOptionsUseGrouping = {} extends NumberFormatOptionsUseGroupingRegistry ? boolean : keyof NumberFormatOptionsUseGroupingRegistry | "true" | "false" | boolean;
```

定义来源：`es5`。

### `Intl.NumberFormatOptionsUseGroupingRegistry`

类别：interface。来源：`es2023.intl`、`es5`。

```ts
interface NumberFormatOptionsUseGroupingRegistry { ... }
```

声明来源：`es2023.intl`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>always: never</code> | `es2023.intl` |
| <code>auto: never</code> | `es2023.intl` |
| <code>min2: never</code> | `es2023.intl` |

### `Intl.NumberFormatPart`

类别：interface。来源：`es2018.intl`。

```ts
interface NumberFormatPart { ... }
```

声明来源：`es2018.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>type: NumberFormatPartTypes</code> | `es2018.intl` |
| <code>value: string</code> | `es2018.intl` |

### `Intl.NumberFormatPartTypeRegistry`

类别：interface。来源：`es2018.intl`、`es2020.intl`。

```ts
interface NumberFormatPartTypeRegistry { ... }
```

声明来源：`es2018.intl`、`es2020.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>compact: never</code> | `es2020.intl` |
| <code>currency: never</code> | `es2018.intl` |
| <code>decimal: never</code> | `es2018.intl` |
| <code>exponentInteger: never</code> | `es2020.intl` |
| <code>exponentMinusSign: never</code> | `es2020.intl` |
| <code>exponentSeparator: never</code> | `es2020.intl` |
| <code>fraction: never</code> | `es2018.intl` |
| <code>group: never</code> | `es2018.intl` |
| <code>infinity: never</code> | `es2018.intl` |
| <code>integer: never</code> | `es2018.intl` |
| <code>literal: never</code> | `es2018.intl` |
| <code>minusSign: never</code> | `es2018.intl` |
| <code>nan: never</code> | `es2018.intl` |
| <code>percent: never</code> | `es2018.intl` |
| <code>percentSign: never</code> | `es2018.intl` |
| <code>plusSign: never</code> | `es2018.intl` |
| <code>unit: never</code> | `es2020.intl` |
| <code>unknown: never</code> | `es2020.intl` |

### `Intl.NumberFormatPartTypes`

类别：type。来源：`es2018.intl`。

```ts
type NumberFormatPartTypes = keyof NumberFormatPartTypeRegistry;
```

定义来源：`es2018.intl`。

### `Intl.NumberFormatRangePartTypeRegistry`

类别：interface。来源：`es2023.intl`。

```ts
interface NumberFormatRangePartTypeRegistry extends NumberFormatPartTypeRegistry { ... }
```

声明来源：`es2023.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>approximatelySign: never</code> | `es2023.intl` |

### `Intl.NumberFormatRangePartTypes`

类别：type。来源：`es2023.intl`。

```ts
type NumberFormatRangePartTypes = keyof NumberFormatRangePartTypeRegistry;
```

定义来源：`es2023.intl`。

### `Intl.NumberRangeFormatPart`

类别：interface。来源：`es2023.intl`。

```ts
interface NumberRangeFormatPart { ... }
```

声明来源：`es2023.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>source: "startRange" &#124; "endRange" &#124; "shared"</code> | `es2023.intl` |
| <code>type: NumberFormatRangePartTypes</code> | `es2023.intl` |
| <code>value: string</code> | `es2023.intl` |

### `Intl.PluralRules`

类别：interface。来源：`es2018.intl`。

```ts
interface PluralRules { ... }
```

声明来源：`es2018.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>resolvedOptions(): ResolvedPluralRulesOptions</code> | `es2018.intl` |
| <code>select(n: number): LDMLPluralRule</code> | `es2018.intl` |

### `Intl.PluralRulesConstructor`

类别：interface。来源：`es2018.intl`、`es2020.intl`。

```ts
interface PluralRulesConstructor { ... }
```

声明来源：`es2018.intl`、`es2020.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(locales?: LocalesArgument, options?: PluralRulesOptions): PluralRules</code> | `es2020.intl` |
| <code>(locales?: string &#124; readonly string[], options?: PluralRulesOptions): PluralRules</code> | `es2018.intl` |
| <code>new (locales?: LocalesArgument, options?: PluralRulesOptions): PluralRules</code> | `es2020.intl` |
| <code>new (locales?: string &#124; readonly string[], options?: PluralRulesOptions): PluralRules</code> | `es2018.intl` |
| <code>supportedLocalesOf(locales: LocalesArgument, options?: { localeMatcher?: "lookup" &#124; "best fit"; }): string[]</code> | `es2020.intl` |
| <code>supportedLocalesOf(locales: string &#124; readonly string[], options?: { localeMatcher?: "lookup" &#124; "best fit"; }): string[]</code> | `es2018.intl` |

### `Intl.PluralRulesOptions`

类别：interface。来源：`es2018.intl`。

```ts
interface PluralRulesOptions { ... }
```

声明来源：`es2018.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>localeMatcher?: "lookup" &#124; "best fit" &#124; undefined</code> | `es2018.intl` |
| <code>maximumFractionDigits?: number &#124; undefined</code> | `es2018.intl` |
| <code>maximumSignificantDigits?: number &#124; undefined</code> | `es2018.intl` |
| <code>minimumFractionDigits?: number &#124; undefined</code> | `es2018.intl` |
| <code>minimumIntegerDigits?: number &#124; undefined</code> | `es2018.intl` |
| <code>minimumSignificantDigits?: number &#124; undefined</code> | `es2018.intl` |
| <code>type?: PluralRuleType &#124; undefined</code> | `es2018.intl` |

### `Intl.PluralRuleType`

类别：type。来源：`es2018.intl`。

```ts
type PluralRuleType = "cardinal" | "ordinal";
```

定义来源：`es2018.intl`。

### `Intl.RelativeTimeFormat`

类别：interface。来源：`es2020.intl`。

```ts
interface RelativeTimeFormat { ... }
```

声明来源：`es2020.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>format(value: number, unit: RelativeTimeFormatUnit): string</code> | `es2020.intl` |
| <code>formatToParts(value: number, unit: RelativeTimeFormatUnit): RelativeTimeFormatPart[]</code> | `es2020.intl` |
| <code>resolvedOptions(): ResolvedRelativeTimeFormatOptions</code> | `es2020.intl` |

### `Intl.RelativeTimeFormatLocaleMatcher`

类别：type。来源：`es2020.intl`。

```ts
type RelativeTimeFormatLocaleMatcher = "lookup" | "best fit";
```

定义来源：`es2020.intl`。

### `Intl.RelativeTimeFormatNumeric`

类别：type。来源：`es2020.intl`。

```ts
type RelativeTimeFormatNumeric = "always" | "auto";
```

定义来源：`es2020.intl`。

### `Intl.RelativeTimeFormatOptions`

类别：interface。来源：`es2020.intl`。

```ts
interface RelativeTimeFormatOptions { ... }
```

声明来源：`es2020.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>localeMatcher?: RelativeTimeFormatLocaleMatcher</code> | `es2020.intl` |
| <code>numeric?: RelativeTimeFormatNumeric</code> | `es2020.intl` |
| <code>style?: RelativeTimeFormatStyle</code> | `es2020.intl` |

### `Intl.RelativeTimeFormatPart`

类别：type。来源：`es2020.intl`。

```ts
type RelativeTimeFormatPart = | { type: "literal"; value: string; } | { type: Exclude<NumberFormatPartTypes, "literal">; value: string; unit: RelativeTimeFormatUnitSingular; };
```

定义来源：`es2020.intl`。

### `Intl.RelativeTimeFormatStyle`

类别：type。来源：`es2020.intl`。

```ts
type RelativeTimeFormatStyle = "long" | "short" | "narrow";
```

定义来源：`es2020.intl`。

### `Intl.RelativeTimeFormatUnit`

类别：type。来源：`es2020.intl`。

```ts
type RelativeTimeFormatUnit = | "year" | "years" | "quarter" | "quarters" | "month" | "months" | "week" | "weeks" | "day" | "days" | "hour" | "hours" | "minute" | "minutes" | "second" | "seconds";
```

定义来源：`es2020.intl`。

### `Intl.RelativeTimeFormatUnitSingular`

类别：type。来源：`es2020.intl`。

```ts
type RelativeTimeFormatUnitSingular = | "year" | "quarter" | "month" | "week" | "day" | "hour" | "minute" | "second";
```

定义来源：`es2020.intl`。

### `Intl.ResolvedCollatorOptions`

类别：interface。来源：`es5`。

```ts
interface ResolvedCollatorOptions { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>caseFirst: string</code> | `es5` |
| <code>collation: string</code> | `es5` |
| <code>ignorePunctuation: boolean</code> | `es5` |
| <code>locale: string</code> | `es5` |
| <code>numeric: boolean</code> | `es5` |
| <code>sensitivity: string</code> | `es5` |
| <code>usage: string</code> | `es5` |

### `Intl.ResolvedDateTimeFormatOptions`

类别：interface。来源：`es2021.intl`、`es5`。

```ts
interface ResolvedDateTimeFormatOptions { ... }
```

声明来源：`es2021.intl`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>calendar: string</code> | `es5` |
| <code>dateStyle?: "full" &#124; "long" &#124; "medium" &#124; "short"</code> | `es2021.intl` |
| <code>day?: string</code> | `es5` |
| <code>dayPeriod?: "narrow" &#124; "short" &#124; "long"</code> | `es2021.intl` |
| <code>era?: string</code> | `es5` |
| <code>formatMatcher?: "basic" &#124; "best fit" &#124; "best fit"</code> | `es2021.intl` |
| <code>fractionalSecondDigits?: 1 &#124; 2 &#124; 3</code> | `es2021.intl` |
| <code>hour?: string</code> | `es5` |
| <code>hour12?: boolean</code> | `es5` |
| <code>hourCycle?: "h11" &#124; "h12" &#124; "h23" &#124; "h24"</code> | `es2021.intl` |
| <code>locale: string</code> | `es5` |
| <code>minute?: string</code> | `es5` |
| <code>month?: string</code> | `es5` |
| <code>numberingSystem: string</code> | `es5` |
| <code>second?: string</code> | `es5` |
| <code>timeStyle?: "full" &#124; "long" &#124; "medium" &#124; "short"</code> | `es2021.intl` |
| <code>timeZone: string</code> | `es5` |
| <code>timeZoneName?: string</code> | `es5` |
| <code>weekday?: string</code> | `es5` |
| <code>year?: string</code> | `es5` |

### `Intl.ResolvedDisplayNamesOptions`

类别：interface。来源：`es2020.intl`。

```ts
interface ResolvedDisplayNamesOptions { ... }
```

声明来源：`es2020.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>fallback: DisplayNamesFallback</code> | `es2020.intl` |
| <code>languageDisplay?: DisplayNamesLanguageDisplay</code> | `es2020.intl` |
| <code>locale: UnicodeBCP47LocaleIdentifier</code> | `es2020.intl` |
| <code>style: RelativeTimeFormatStyle</code> | `es2020.intl` |
| <code>type: DisplayNamesType</code> | `es2020.intl` |

### `Intl.ResolvedDurationFormatOptions`

类别：interface。来源：`es2025.intl`。

```ts
interface ResolvedDurationFormatOptions { ... }
```

声明来源：`es2025.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>days: "long" &#124; "short" &#124; "narrow"</code> | `es2025.intl` |
| <code>daysDisplay: DurationFormatDisplayOption</code> | `es2025.intl` |
| <code>fractionalDigits?: 0 &#124; 1 &#124; 2 &#124; 3 &#124; 4 &#124; 5 &#124; 6 &#124; 7 &#124; 8 &#124; 9</code> | `es2025.intl` |
| <code>hours: "long" &#124; "short" &#124; "narrow" &#124; "numeric" &#124; "2-digit"</code> | `es2025.intl` |
| <code>hoursDisplay: DurationFormatDisplayOption</code> | `es2025.intl` |
| <code>locale: UnicodeBCP47LocaleIdentifier</code> | `es2025.intl` |
| <code>microseconds: "long" &#124; "short" &#124; "narrow" &#124; "numeric"</code> | `es2025.intl` |
| <code>microsecondsDisplay: DurationFormatDisplayOption</code> | `es2025.intl` |
| <code>milliseconds: "long" &#124; "short" &#124; "narrow" &#124; "numeric"</code> | `es2025.intl` |
| <code>millisecondsDisplay: DurationFormatDisplayOption</code> | `es2025.intl` |
| <code>minutes: "long" &#124; "short" &#124; "narrow" &#124; "numeric" &#124; "2-digit"</code> | `es2025.intl` |
| <code>minutesDisplay: DurationFormatDisplayOption</code> | `es2025.intl` |
| <code>months: "long" &#124; "short" &#124; "narrow"</code> | `es2025.intl` |
| <code>monthsDisplay: DurationFormatDisplayOption</code> | `es2025.intl` |
| <code>nanoseconds: "long" &#124; "short" &#124; "narrow" &#124; "numeric"</code> | `es2025.intl` |
| <code>nanosecondsDisplay: DurationFormatDisplayOption</code> | `es2025.intl` |
| <code>numberingSystem: string</code> | `es2025.intl` |
| <code>seconds: "long" &#124; "short" &#124; "narrow" &#124; "numeric" &#124; "2-digit"</code> | `es2025.intl` |
| <code>secondsDisplay: DurationFormatDisplayOption</code> | `es2025.intl` |
| <code>style: DurationFormatStyle</code> | `es2025.intl` |
| <code>weeks: "long" &#124; "short" &#124; "narrow"</code> | `es2025.intl` |
| <code>weeksDisplay: DurationFormatDisplayOption</code> | `es2025.intl` |
| <code>years: "long" &#124; "short" &#124; "narrow"</code> | `es2025.intl` |
| <code>yearsDisplay: DurationFormatDisplayOption</code> | `es2025.intl` |

### `Intl.ResolvedListFormatOptions`

类别：interface。来源：`es2021.intl`。

```ts
interface ResolvedListFormatOptions { ... }
```

声明来源：`es2021.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>locale: string</code> | `es2021.intl` |
| <code>style: ListFormatStyle</code> | `es2021.intl` |
| <code>type: ListFormatType</code> | `es2021.intl` |

### `Intl.ResolvedNumberFormatOptions`

类别：interface。来源：`es2020.intl`、`es2023.intl`、`es5`。

```ts
interface ResolvedNumberFormatOptions { ... }
```

声明来源：`es2020.intl`、`es2023.intl`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>compactDisplay?: "short" &#124; "long"</code> | `es2020.intl` |
| <code>currency?: string</code> | `es5` |
| <code>currencyDisplay?: NumberFormatOptionsCurrencyDisplay</code> | `es5` |
| <code>currencySign?: "standard" &#124; "accounting"</code> | `es2020.intl` |
| <code>locale: string</code> | `es5` |
| <code>maximumFractionDigits?: number</code> | `es5` |
| <code>maximumSignificantDigits?: number</code> | `es5` |
| <code>minimumFractionDigits?: number</code> | `es5` |
| <code>minimumIntegerDigits: number</code> | `es5` |
| <code>minimumSignificantDigits?: number</code> | `es5` |
| <code>notation: "standard" &#124; "scientific" &#124; "engineering" &#124; "compact"</code> | `es2020.intl` |
| <code>numberingSystem: string</code> | `es5` |
| <code>roundingIncrement: 1 &#124; 2 &#124; 5 &#124; 10 &#124; 20 &#124; 25 &#124; 50 &#124; 100 &#124; 200 &#124; 250 &#124; 500 &#124; 1000 &#124; 2000 &#124; 2500 &#124; 5000</code> | `es2023.intl` |
| <code>roundingMode: "ceil" &#124; "floor" &#124; "expand" &#124; "trunc" &#124; "halfCeil" &#124; "halfFloor" &#124; "halfExpand" &#124; "halfTrunc" &#124; "halfEven"</code> | `es2023.intl` |
| <code>roundingPriority: "auto" &#124; "morePrecision" &#124; "lessPrecision"</code> | `es2023.intl` |
| <code>signDisplay: NumberFormatOptionsSignDisplay</code> | `es2020.intl` |
| <code>style: NumberFormatOptionsStyle</code> | `es5` |
| <code>trailingZeroDisplay: "auto" &#124; "stripIfInteger"</code> | `es2023.intl` |
| <code>unit?: string</code> | `es2020.intl` |
| <code>unitDisplay?: "short" &#124; "long" &#124; "narrow"</code> | `es2020.intl` |
| <code>useGrouping: ResolvedNumberFormatOptionsUseGrouping</code> | `es5` |

### `Intl.ResolvedNumberFormatOptionsUseGrouping`

类别：type。来源：`es5`。

```ts
type ResolvedNumberFormatOptionsUseGrouping = {} extends NumberFormatOptionsUseGroupingRegistry ? boolean : keyof NumberFormatOptionsUseGroupingRegistry | false;
```

定义来源：`es5`。

### `Intl.ResolvedPluralRulesOptions`

类别：interface。来源：`es2018.intl`。

```ts
interface ResolvedPluralRulesOptions { ... }
```

声明来源：`es2018.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>locale: string</code> | `es2018.intl` |
| <code>maximumFractionDigits: number</code> | `es2018.intl` |
| <code>maximumSignificantDigits?: number</code> | `es2018.intl` |
| <code>minimumFractionDigits: number</code> | `es2018.intl` |
| <code>minimumIntegerDigits: number</code> | `es2018.intl` |
| <code>minimumSignificantDigits?: number</code> | `es2018.intl` |
| <code>pluralCategories: LDMLPluralRule[]</code> | `es2018.intl` |
| <code>type: PluralRuleType</code> | `es2018.intl` |

### `Intl.ResolvedRelativeTimeFormatOptions`

类别：interface。来源：`es2020.intl`。

```ts
interface ResolvedRelativeTimeFormatOptions { ... }
```

声明来源：`es2020.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>locale: UnicodeBCP47LocaleIdentifier</code> | `es2020.intl` |
| <code>numberingSystem: string</code> | `es2020.intl` |
| <code>numeric: RelativeTimeFormatNumeric</code> | `es2020.intl` |
| <code>style: RelativeTimeFormatStyle</code> | `es2020.intl` |

### `Intl.ResolvedSegmenterOptions`

类别：interface。来源：`es2022.intl`。

```ts
interface ResolvedSegmenterOptions { ... }
```

声明来源：`es2022.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>granularity: "grapheme" &#124; "word" &#124; "sentence"</code> | `es2022.intl` |
| <code>locale: string</code> | `es2022.intl` |

### `Intl.SegmentData`

类别：interface。来源：`es2022.intl`。

```ts
interface SegmentData { ... }
```

声明来源：`es2022.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>index: number</code> | `es2022.intl` |
| <code>input: string</code> | `es2022.intl` |
| <code>isWordLike?: boolean</code> | `es2022.intl` |
| <code>segment: string</code> | `es2022.intl` |

### `Intl.Segmenter`

类别：interface。来源：`es2022.intl`。

```ts
interface Segmenter { ... }
```

声明来源：`es2022.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>resolvedOptions(): ResolvedSegmenterOptions</code> | `es2022.intl` |
| <code>segment(input: string): Segments</code> | `es2022.intl` |

### `Intl.SegmenterOptions`

类别：interface。来源：`es2022.intl`。

```ts
interface SegmenterOptions { ... }
```

声明来源：`es2022.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>granularity?: "grapheme" &#124; "word" &#124; "sentence" &#124; undefined</code> | `es2022.intl` |
| <code>localeMatcher?: "best fit" &#124; "lookup" &#124; undefined</code> | `es2022.intl` |

### `Intl.SegmentIterator`

类别：interface。来源：`es2022.intl`。

```ts
interface SegmentIterator<T> extends IteratorObject<T, BuiltinIteratorReturn, unknown> { ... }
```

声明来源：`es2022.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.iterator](): SegmentIterator&lt;T&gt;</code> | `es2022.intl` |

### `Intl.Segments`

类别：interface。来源：`es2022.intl`。

```ts
interface Segments { ... }
```

声明来源：`es2022.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.iterator](): SegmentIterator&lt;SegmentData&gt;</code> | `es2022.intl` |
| <code>containing(codeUnitIndex?: number): SegmentData &#124; undefined</code> | `es2022.intl` |

### `Intl.StringNumericLiteral`

类别：type。来源：`es2023.intl`。

```ts
type StringNumericLiteral = `${number}` | "Infinity" | "-Infinity" | "+Infinity";
```

定义来源：`es2023.intl`。

### `Intl.TextInfo`

类别：interface。来源：`esnext.intl`。

```ts
interface TextInfo { ... }
```

声明来源：`esnext.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>direction?: "ltr" &#124; "rtl"</code> | `esnext.intl` |

### `Intl.UnicodeBCP47LocaleIdentifier`

类别：type。来源：`es2020.intl`。

```ts
type UnicodeBCP47LocaleIdentifier = string;
```

定义来源：`es2020.intl`。

### `Intl.WeekInfo`

类别：interface。来源：`esnext.intl`。

```ts
interface WeekInfo { ... }
```

声明来源：`esnext.intl`。

| 成员签名 | 来源 |
| --- | --- |
| <code>firstDay: number</code> | `esnext.intl` |
| <code>weekend: number[]</code> | `esnext.intl` |

### `Iterable`

类别：interface。来源：`es2015.iterable`。

```ts
interface Iterable<T, TReturn = any, TNext = any> { ... }
```

声明来源：`es2015.iterable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.iterator](): Iterator&lt;T, TReturn, TNext&gt;</code> | `es2015.iterable` |

### `IterableIterator`

类别：interface。来源：`es2015.iterable`。

```ts
interface IterableIterator<T, TReturn = any, TNext = any> extends Iterator<T, TReturn, TNext> { ... }
```

声明来源：`es2015.iterable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.iterator](): IterableIterator&lt;T, TReturn, TNext&gt;</code> | `es2015.iterable` |

### `Iterator`

类别：interface。来源：`es2015.iterable`、`es2025.iterator`。

```ts
interface Iterator<T, TReturn = any, TNext = any> { ... }
```

声明来源：`es2015.iterable`。

```ts
declare abstract class Iterator<T, TResult = undefined, TNext = unknown> { ... }
```

声明来源：`es2025.iterator`。

```ts
interface Iterator<T, TResult, TNext> extends globalThis.IteratorObject<T, TResult, TNext> { ... }
```

声明来源：`es2025.iterator`。

| 成员签名 | 来源 |
| --- | --- |
| <code>abstract next(value?: TNext): IteratorResult&lt;T, TResult&gt;</code> | `es2025.iterator` |
| <code>next(...[value]: [ ] &#124; [ TNext ]): IteratorResult&lt;T, TReturn&gt;</code> | `es2015.iterable` |
| <code>return?(value?: TReturn): IteratorResult&lt;T, TReturn&gt;</code> | `es2015.iterable` |
| <code>throw?(e?: any): IteratorResult&lt;T, TReturn&gt;</code> | `es2015.iterable` |

### `IteratorObject`

类别：interface。来源：`es2015.iterable`、`esnext.disposable`。

```ts
interface IteratorObject<T, TReturn = unknown, TNext = unknown> extends Iterator<T, TReturn, TNext> { ... }
```

声明来源：`es2015.iterable`。

```ts
interface IteratorObject<T, TReturn, TNext> extends Disposable { ... }
```

声明来源：`esnext.disposable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.iterator](): IteratorObject&lt;T, TReturn, TNext&gt;</code> | `es2015.iterable` |

### `IteratorObjectConstructor`

类别：type。来源：`es2025.iterator`。

```ts
type IteratorObjectConstructor = typeof Iterator;
```

定义来源：`es2025.iterator`。

### `IteratorResult`

类别：type。来源：`es2015.iterable`。

```ts
type IteratorResult<T, TReturn = IteratorYieldResult<T> | IteratorReturnResult<TReturn>;
```

定义来源：`es2015.iterable`。

### `IteratorReturnResult`

类别：interface。来源：`es2015.iterable`。

```ts
interface IteratorReturnResult<TReturn> { ... }
```

声明来源：`es2015.iterable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>done: true</code> | `es2015.iterable` |
| <code>value: TReturn</code> | `es2015.iterable` |

### `IteratorYieldResult`

类别：interface。来源：`es2015.iterable`。

```ts
interface IteratorYieldResult<TYield> { ... }
```

声明来源：`es2015.iterable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>done?: false</code> | `es2015.iterable` |
| <code>value: TYield</code> | `es2015.iterable` |

### `JSON`

类别：interface。来源：`es5`。

```ts
interface JSON { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>parse(text: string, reviver?: (this: any, key: string, value: any) =&gt; any): any</code> | `es5` |
| <code>stringify(value: any, replacer?: (number &#124; string)[] &#124; null, space?: string &#124; number): string</code> | `es5` |
| <code>stringify(value: any, replacer?: (this: any, key: string, value: any) =&gt; any, space?: string &#124; number): string</code> | `es5` |

### `Lowercase`

类别：type。来源：`es5`。

```ts
type Lowercase<S extends string> = intrinsic;
```

定义来源：`es5`。

### `Map`

类别：interface。来源：`es2015.collection`、`es2015.iterable`、`esnext.collection`。

```ts
interface Map<K, V> { ... }
```

声明来源：`es2015.collection`、`es2015.iterable`、`esnext.collection`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.iterator](): MapIterator&lt;[ K, V ]&gt;</code> | `es2015.iterable` |
| <code>clear(): void</code> | `es2015.collection` |
| <code>delete(key: K): boolean</code> | `es2015.collection` |
| <code>entries(): MapIterator&lt;[ K, V ]&gt;</code> | `es2015.iterable` |
| <code>forEach(callbackfn: (value: V, key: K, map: Map&lt;K, V&gt;) =&gt; void, thisArg?: any): void</code> | `es2015.collection` |
| <code>get(key: K): V &#124; undefined</code> | `es2015.collection` |
| <code>getOrInsert(key: K, defaultValue: V): V</code> | `esnext.collection` |
| <code>getOrInsertComputed(key: K, callback: (key: K) =&gt; V): V</code> | `esnext.collection` |
| <code>has(key: K): boolean</code> | `es2015.collection` |
| <code>keys(): MapIterator&lt;K&gt;</code> | `es2015.iterable` |
| <code>readonly size: number</code> | `es2015.collection` |
| <code>set(key: K, value: V): this</code> | `es2015.collection` |
| <code>values(): MapIterator&lt;V&gt;</code> | `es2015.iterable` |

### `MapConstructor`

类别：interface。来源：`es2015.collection`、`es2015.iterable`、`es2024.collection`。

```ts
interface MapConstructor { ... }
```

声明来源：`es2015.collection`、`es2015.iterable`、`es2024.collection`。

| 成员签名 | 来源 |
| --- | --- |
| <code>groupBy&lt;K, T&gt;(items: Iterable&lt;T&gt;, keySelector: (item: T, index: number) =&gt; K): Map&lt;K, T[]&gt;</code> | `es2024.collection` |
| <code>new (): Map&lt;any, any&gt;</code> | `es2015.collection`、`es2015.iterable` |
| <code>new &lt;K, V&gt;(entries?: readonly (readonly [ K, V ])[] &#124; null): Map&lt;K, V&gt;</code> | `es2015.collection` |
| <code>new &lt;K, V&gt;(iterable?: Iterable&lt;readonly [ K, V ]&gt; &#124; null): Map&lt;K, V&gt;</code> | `es2015.iterable` |
| <code>readonly prototype: Map&lt;any, any&gt;</code> | `es2015.collection` |

### `MapIterator`

类别：interface。来源：`es2015.iterable`。

```ts
interface MapIterator<T> extends IteratorObject<T, BuiltinIteratorReturn, unknown> { ... }
```

声明来源：`es2015.iterable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.iterator](): MapIterator&lt;T&gt;</code> | `es2015.iterable` |

### `Math`

类别：interface。来源：`es2015.core`、`es2025.float16`、`es5`。

```ts
interface Math { ... }
```

声明来源：`es2015.core`、`es2025.float16`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>abs(x: number): number</code> | `es5` |
| <code>acos(x: number): number</code> | `es5` |
| <code>acosh(x: number): number</code> | `es2015.core` |
| <code>asin(x: number): number</code> | `es5` |
| <code>asinh(x: number): number</code> | `es2015.core` |
| <code>atan(x: number): number</code> | `es5` |
| <code>atan2(y: number, x: number): number</code> | `es5` |
| <code>atanh(x: number): number</code> | `es2015.core` |
| <code>cbrt(x: number): number</code> | `es2015.core` |
| <code>ceil(x: number): number</code> | `es5` |
| <code>clz32(x: number): number</code> | `es2015.core` |
| <code>cos(x: number): number</code> | `es5` |
| <code>cosh(x: number): number</code> | `es2015.core` |
| <code>exp(x: number): number</code> | `es5` |
| <code>expm1(x: number): number</code> | `es2015.core` |
| <code>f16round(x: number): number</code> | `es2025.float16` |
| <code>floor(x: number): number</code> | `es5` |
| <code>fround(x: number): number</code> | `es2015.core` |
| <code>hypot(...values: number[]): number</code> | `es2015.core` |
| <code>imul(x: number, y: number): number</code> | `es2015.core` |
| <code>log(x: number): number</code> | `es5` |
| <code>log10(x: number): number</code> | `es2015.core` |
| <code>log1p(x: number): number</code> | `es2015.core` |
| <code>log2(x: number): number</code> | `es2015.core` |
| <code>max(...values: number[]): number</code> | `es5` |
| <code>min(...values: number[]): number</code> | `es5` |
| <code>pow(x: number, y: number): number</code> | `es5` |
| <code>random(): number</code> | `es5` |
| <code>readonly E: number</code> | `es5` |
| <code>readonly LN10: number</code> | `es5` |
| <code>readonly LN2: number</code> | `es5` |
| <code>readonly LOG10E: number</code> | `es5` |
| <code>readonly LOG2E: number</code> | `es5` |
| <code>readonly PI: number</code> | `es5` |
| <code>readonly SQRT1_2: number</code> | `es5` |
| <code>readonly SQRT2: number</code> | `es5` |
| <code>round(x: number): number</code> | `es5` |
| <code>sign(x: number): number</code> | `es2015.core` |
| <code>sin(x: number): number</code> | `es5` |
| <code>sinh(x: number): number</code> | `es2015.core` |
| <code>sqrt(x: number): number</code> | `es5` |
| <code>tan(x: number): number</code> | `es5` |
| <code>tanh(x: number): number</code> | `es2015.core` |
| <code>trunc(x: number): number</code> | `es2015.core` |

### `NewableFunction`

类别：interface。来源：`es5`。

```ts
interface NewableFunction extends Function { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>apply&lt;T, A extends any[]&gt;(this: new (...args: A) =&gt; T, thisArg: T, args: A): void</code> | `es5` |
| <code>apply&lt;T&gt;(this: new () =&gt; T, thisArg: T): void</code> | `es5` |
| <code>bind&lt;A extends any[], B extends any[], R&gt;(this: new (...args: [ ...A, ...B ]) =&gt; R, thisArg: any, ...args: A): new (...args: B) =&gt; R</code> | `es5` |
| <code>bind&lt;T&gt;(this: T, thisArg: any): T</code> | `es5` |
| <code>call&lt;T, A extends any[]&gt;(this: new (...args: A) =&gt; T, thisArg: T, ...args: A): void</code> | `es5` |

### `NoInfer`

类别：type。来源：`es5`。

```ts
type NoInfer<T> = intrinsic;
```

定义来源：`es5`。

### `NonNullable`

类别：type。来源：`es5`。

```ts
type NonNullable<T> = T & {};
```

定义来源：`es5`。

### `Number`

类别：interface。来源：`es2020.number`、`es5`。

```ts
interface Number { ... }
```

声明来源：`es2020.number`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>toExponential(fractionDigits?: number): string</code> | `es5` |
| <code>toFixed(fractionDigits?: number): string</code> | `es5` |
| <code>toLocaleString(locales?: Intl.LocalesArgument, options?: Intl.NumberFormatOptions): string</code> | `es2020.number` |
| <code>toLocaleString(locales?: string &#124; string[], options?: Intl.NumberFormatOptions): string</code> | `es5` |
| <code>toPrecision(precision?: number): string</code> | `es5` |
| <code>toString(radix?: number): string</code> | `es5` |
| <code>valueOf(): number</code> | `es5` |

### `NumberConstructor`

类别：interface。来源：`es2015.core`、`es5`。

```ts
interface NumberConstructor { ... }
```

声明来源：`es2015.core`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(value?: any): number</code> | `es5` |
| <code>isFinite(number: unknown): boolean</code> | `es2015.core` |
| <code>isInteger(number: unknown): boolean</code> | `es2015.core` |
| <code>isNaN(number: unknown): boolean</code> | `es2015.core` |
| <code>isSafeInteger(number: unknown): boolean</code> | `es2015.core` |
| <code>new (value?: any): Number</code> | `es5` |
| <code>parseFloat(string: string): number</code> | `es2015.core` |
| <code>parseInt(string: string, radix?: number): number</code> | `es2015.core` |
| <code>readonly EPSILON: number</code> | `es2015.core` |
| <code>readonly MAX_SAFE_INTEGER: number</code> | `es2015.core` |
| <code>readonly MAX_VALUE: number</code> | `es5` |
| <code>readonly MIN_SAFE_INTEGER: number</code> | `es2015.core` |
| <code>readonly MIN_VALUE: number</code> | `es5` |
| <code>readonly NaN: number</code> | `es5` |
| <code>readonly NEGATIVE_INFINITY: number</code> | `es5` |
| <code>readonly POSITIVE_INFINITY: number</code> | `es5` |
| <code>readonly prototype: Number</code> | `es5` |

### `Object`

类别：interface。来源：`es5`。

```ts
interface Object { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>constructor: Function</code> | `es5` |
| <code>hasOwnProperty(v: PropertyKey): boolean</code> | `es5` |
| <code>isPrototypeOf(v: Object): boolean</code> | `es5` |
| <code>propertyIsEnumerable(v: PropertyKey): boolean</code> | `es5` |
| <code>toLocaleString(): string</code> | `es5` |
| <code>toString(): string</code> | `es5` |
| <code>valueOf(): Object</code> | `es5` |

### `ObjectConstructor`

类别：interface。来源：`es2015.core`、`es2017.object`、`es2019.object`、`es2022.object`、`es2024.object`、`es5`。

```ts
interface ObjectConstructor { ... }
```

声明来源：`es2015.core`、`es2017.object`、`es2019.object`、`es2022.object`、`es2024.object`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(): any</code> | `es5` |
| <code>(value: any): any</code> | `es5` |
| <code>assign(target: object, ...sources: any[]): any</code> | `es2015.core` |
| <code>assign&lt;T extends {}, U, V, W&gt;(target: T, source1: U, source2: V, source3: W): T &amp; U &amp; V &amp; W</code> | `es2015.core` |
| <code>assign&lt;T extends {}, U, V&gt;(target: T, source1: U, source2: V): T &amp; U &amp; V</code> | `es2015.core` |
| <code>assign&lt;T extends {}, U&gt;(target: T, source: U): T &amp; U</code> | `es2015.core` |
| <code>create(o: object &#124; null, properties: PropertyDescriptorMap &amp; ThisType&lt;any&gt;): any</code> | `es5` |
| <code>create(o: object &#124; null): any</code> | `es5` |
| <code>defineProperties&lt;T&gt;(o: T, properties: PropertyDescriptorMap &amp; ThisType&lt;any&gt;): T</code> | `es5` |
| <code>defineProperty&lt;T&gt;(o: T, p: PropertyKey, attributes: PropertyDescriptor &amp; ThisType&lt;any&gt;): T</code> | `es5` |
| <code>entries(o: {}): [ string, any ][]</code> | `es2017.object` |
| <code>entries&lt;T&gt;(o: { [s: string]: T; } &#124; ArrayLike&lt;T&gt;): [ string, T ][]</code> | `es2017.object` |
| <code>freeze&lt;T extends { [idx: string]: U &#124; null &#124; undefined &#124; object; }, U extends string &#124; bigint &#124; number &#124; boolean &#124; symbol&gt;(o: T): Readonly&lt;T&gt;</code> | `es5` |
| <code>freeze&lt;T extends Function&gt;(f: T): T</code> | `es5` |
| <code>freeze&lt;T&gt;(o: T): Readonly&lt;T&gt;</code> | `es5` |
| <code>fromEntries(entries: Iterable&lt;readonly any[]&gt;): any</code> | `es2019.object` |
| <code>fromEntries&lt;T = any&gt;(entries: Iterable&lt;readonly [ PropertyKey, T ]&gt;): { [k: string]: T; }</code> | `es2019.object` |
| <code>getOwnPropertyDescriptor(o: any, p: PropertyKey): PropertyDescriptor &#124; undefined</code> | `es5` |
| <code>getOwnPropertyDescriptors&lt;T&gt;(o: T): { [P in keyof T]: TypedPropertyDescriptor&lt;T[P]&gt;; } &amp; { [x: string]: PropertyDescriptor; }</code> | `es2017.object` |
| <code>getOwnPropertyNames(o: any): string[]</code> | `es5` |
| <code>getOwnPropertySymbols(o: any): symbol[]</code> | `es2015.core` |
| <code>getPrototypeOf(o: any): any</code> | `es5` |
| <code>groupBy&lt;K extends PropertyKey, T&gt;(items: Iterable&lt;T&gt;, keySelector: (item: T, index: number) =&gt; K): Partial&lt;Record&lt;K, T[]&gt;&gt;</code> | `es2024.object` |
| <code>hasOwn(o: object, v: PropertyKey): boolean</code> | `es2022.object` |
| <code>is(value1: any, value2: any): boolean</code> | `es2015.core` |
| <code>isExtensible(o: any): boolean</code> | `es5` |
| <code>isFrozen(o: any): boolean</code> | `es5` |
| <code>isSealed(o: any): boolean</code> | `es5` |
| <code>keys(o: {}): string[]</code> | `es2015.core` |
| <code>keys(o: object): string[]</code> | `es5` |
| <code>new (value?: any): Object</code> | `es5` |
| <code>preventExtensions&lt;T&gt;(o: T): T</code> | `es5` |
| <code>readonly prototype: Object</code> | `es5` |
| <code>seal&lt;T&gt;(o: T): T</code> | `es5` |
| <code>setPrototypeOf(o: any, proto: object &#124; null): any</code> | `es2015.core` |
| <code>values(o: {}): any[]</code> | `es2017.object` |
| <code>values&lt;T&gt;(o: { [s: string]: T; } &#124; ArrayLike&lt;T&gt;): T[]</code> | `es2017.object` |

### `Omit`

类别：type。来源：`es5`。

```ts
type Omit<T, K extends keyof any> = Pick<T, Exclude<keyof T, K>>;
```

定义来源：`es5`。

### `OmitThisParameter`

类别：type。来源：`es5`。

```ts
type OmitThisParameter<T> = unknown extends ThisParameterType<T> ? T : T extends (...args: infer A) => infer R ? (...args: A) => R : T;
```

定义来源：`es5`。

### `Parameters`

类别：type。来源：`es5`。

```ts
type Parameters<T extends (...args: any) = T extends (...args: infer P) => any ? P : never;
```

定义来源：`es5`。

### `Partial`

类别：type。来源：`es5`。

```ts
type Partial<T> = { [P in keyof T]?: T[P]; };
```

定义来源：`es5`。

### `Pick`

类别：type。来源：`es5`。

```ts
type Pick<T, K extends keyof T> = { [P in K]: T[P]; };
```

定义来源：`es5`。

### `Promise`

类别：interface。来源：`es2015.iterable`、`es2018.promise`、`es5`。

```ts
interface Promise<T> { ... }
```

声明来源：`es2015.iterable`、`es2018.promise`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>catch&lt;TResult = never&gt;(onrejected?: ((reason: any) =&gt; TResult &#124; PromiseLike&lt;TResult&gt;) &#124; undefined &#124; null): Promise&lt;T &#124; TResult&gt;</code> | `es5` |
| <code>finally(onfinally?: (() =&gt; void) &#124; undefined &#124; null): Promise&lt;T&gt;</code> | `es2018.promise` |
| <code>then&lt;TResult1 = T, TResult2 = never&gt;(onfulfilled?: ((value: T) =&gt; TResult1 &#124; PromiseLike&lt;TResult1&gt;) &#124; undefined &#124; null, onrejected?: ((reason: any) =&gt; TResult2 &#124; PromiseLike&lt;TResult2&gt;) &#124; undefined &#124; null): Promise&lt;TResult1 &#124; TResult2&gt;</code> | `es5` |

### `PromiseConstructor`

类别：interface。来源：`es2015.iterable`、`es2015.promise`、`es2020.promise`、`es2021.promise`、`es2024.promise`、`es2025.promise`。

```ts
interface PromiseConstructor { ... }
```

声明来源：`es2015.iterable`、`es2015.promise`、`es2020.promise`、`es2021.promise`、`es2024.promise`、`es2025.promise`。

| 成员签名 | 来源 |
| --- | --- |
| <code>all&lt;T extends readonly unknown[] &#124; [ ]&gt;(values: T): Promise&lt;{ -readonly [P in keyof T]: Awaited&lt;T[P]&gt;; }&gt;</code> | `es2015.promise` |
| <code>all&lt;T&gt;(values: Iterable&lt;T &#124; PromiseLike&lt;T&gt;&gt;): Promise&lt;Awaited&lt;T&gt;[]&gt;</code> | `es2015.iterable` |
| <code>allSettled&lt;T extends readonly unknown[] &#124; [ ]&gt;(values: T): Promise&lt;{ -readonly [P in keyof T]: PromiseSettledResult&lt;Awaited&lt;T[P]&gt;&gt;; }&gt;</code> | `es2020.promise` |
| <code>allSettled&lt;T&gt;(values: Iterable&lt;T &#124; PromiseLike&lt;T&gt;&gt;): Promise&lt;PromiseSettledResult&lt;Awaited&lt;T&gt;&gt;[]&gt;</code> | `es2020.promise` |
| <code>any&lt;T extends readonly unknown[] &#124; [ ]&gt;(values: T): Promise&lt;Awaited&lt;T[number]&gt;&gt;</code> | `es2021.promise` |
| <code>any&lt;T&gt;(values: Iterable&lt;T &#124; PromiseLike&lt;T&gt;&gt;): Promise&lt;Awaited&lt;T&gt;&gt;</code> | `es2021.promise` |
| <code>new &lt;T&gt;(executor: (resolve: (value: T &#124; PromiseLike&lt;T&gt;) =&gt; void, reject: (reason?: any) =&gt; void) =&gt; void): Promise&lt;T&gt;</code> | `es2015.promise` |
| <code>race&lt;T extends readonly unknown[] &#124; [ ]&gt;(values: T): Promise&lt;Awaited&lt;T[number]&gt;&gt;</code> | `es2015.promise` |
| <code>race&lt;T&gt;(values: Iterable&lt;T &#124; PromiseLike&lt;T&gt;&gt;): Promise&lt;Awaited&lt;T&gt;&gt;</code> | `es2015.iterable` |
| <code>readonly prototype: Promise&lt;any&gt;</code> | `es2015.promise` |
| <code>reject&lt;T = never&gt;(reason?: any): Promise&lt;T&gt;</code> | `es2015.promise` |
| <code>resolve(): Promise&lt;void&gt;</code> | `es2015.promise` |
| <code>resolve&lt;T&gt;(value: T &#124; PromiseLike&lt;T&gt;): Promise&lt;Awaited&lt;T&gt;&gt;</code> | `es2015.promise` |
| <code>resolve&lt;T&gt;(value: T): Promise&lt;Awaited&lt;T&gt;&gt;</code> | `es2015.promise` |
| <code>try&lt;T, U extends unknown[]&gt;(callbackFn: (...args: U) =&gt; T &#124; PromiseLike&lt;T&gt;, ...args: U): Promise&lt;Awaited&lt;T&gt;&gt;</code> | `es2025.promise` |
| <code>withResolvers&lt;T&gt;(): PromiseWithResolvers&lt;T&gt;</code> | `es2024.promise` |

### `PromiseConstructorLike`

类别：type。来源：`es5`。

```ts
declare type PromiseConstructorLike = new <T>(executor: (resolve: (value: T | PromiseLike<T>) => void, reject: (reason?: any) => void) => void) => PromiseLike<T>;
```

定义来源：`es5`。

### `PromiseFulfilledResult`

类别：interface。来源：`es2020.promise`。

```ts
interface PromiseFulfilledResult<T> { ... }
```

声明来源：`es2020.promise`。

| 成员签名 | 来源 |
| --- | --- |
| <code>status: "fulfilled"</code> | `es2020.promise` |
| <code>value: T</code> | `es2020.promise` |

### `PromiseLike`

类别：interface。来源：`es5`。

```ts
interface PromiseLike<T> { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>then&lt;TResult1 = T, TResult2 = never&gt;(onfulfilled?: ((value: T) =&gt; TResult1 &#124; PromiseLike&lt;TResult1&gt;) &#124; undefined &#124; null, onrejected?: ((reason: any) =&gt; TResult2 &#124; PromiseLike&lt;TResult2&gt;) &#124; undefined &#124; null): PromiseLike&lt;TResult1 &#124; TResult2&gt;</code> | `es5` |

### `PromiseRejectedResult`

类别：interface。来源：`es2020.promise`。

```ts
interface PromiseRejectedResult { ... }
```

声明来源：`es2020.promise`。

| 成员签名 | 来源 |
| --- | --- |
| <code>reason: any</code> | `es2020.promise` |
| <code>status: "rejected"</code> | `es2020.promise` |

### `PromiseSettledResult`

类别：type。来源：`es2020.promise`。

```ts
type PromiseSettledResult<T> = PromiseFulfilledResult<T> | PromiseRejectedResult;
```

定义来源：`es2020.promise`。

### `PromiseWithResolvers`

类别：interface。来源：`es2024.promise`。

```ts
interface PromiseWithResolvers<T> { ... }
```

声明来源：`es2024.promise`。

| 成员签名 | 来源 |
| --- | --- |
| <code>promise: Promise&lt;T&gt;</code> | `es2024.promise` |
| <code>reject: (reason?: any) =&gt; void</code> | `es2024.promise` |
| <code>resolve: (value: T &#124; PromiseLike&lt;T&gt;) =&gt; void</code> | `es2024.promise` |

### `PropertyDescriptor`

类别：interface。来源：`es5`。

```ts
interface PropertyDescriptor { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>configurable?: boolean</code> | `es5` |
| <code>enumerable?: boolean</code> | `es5` |
| <code>get?(): any</code> | `es5` |
| <code>set?(v: any): void</code> | `es5` |
| <code>value?: any</code> | `es5` |
| <code>writable?: boolean</code> | `es5` |

### `PropertyDescriptorMap`

类别：interface。来源：`es5`。

```ts
interface PropertyDescriptorMap { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[key: PropertyKey]: PropertyDescriptor</code> | `es5` |

### `PropertyKey`

类别：type。来源：`es5`。

```ts
declare type PropertyKey = string | number | symbol;
```

定义来源：`es5`。

### `ProxyConstructor`

类别：interface。来源：`es2015.proxy`。

```ts
interface ProxyConstructor { ... }
```

声明来源：`es2015.proxy`。

| 成员签名 | 来源 |
| --- | --- |
| <code>new &lt;T extends object&gt;(target: T, handler: ProxyHandler&lt;T&gt;): T</code> | `es2015.proxy` |
| <code>revocable&lt;T extends object&gt;(target: T, handler: ProxyHandler&lt;T&gt;): { proxy: T; revoke: () =&gt; void; }</code> | `es2015.proxy` |

### `ProxyHandler`

类别：interface。来源：`es2015.proxy`。

```ts
interface ProxyHandler<T extends object> { ... }
```

声明来源：`es2015.proxy`。

| 成员签名 | 来源 |
| --- | --- |
| <code>apply?(target: T, thisArg: any, argArray: any[]): any</code> | `es2015.proxy` |
| <code>construct?(target: T, argArray: any[], newTarget: Function): object</code> | `es2015.proxy` |
| <code>defineProperty?(target: T, property: string &#124; symbol, attributes: PropertyDescriptor): boolean</code> | `es2015.proxy` |
| <code>deleteProperty?(target: T, p: string &#124; symbol): boolean</code> | `es2015.proxy` |
| <code>get?(target: T, p: string &#124; symbol, receiver: any): any</code> | `es2015.proxy` |
| <code>getOwnPropertyDescriptor?(target: T, p: string &#124; symbol): PropertyDescriptor &#124; undefined</code> | `es2015.proxy` |
| <code>getPrototypeOf?(target: T): object &#124; null</code> | `es2015.proxy` |
| <code>has?(target: T, p: string &#124; symbol): boolean</code> | `es2015.proxy` |
| <code>isExtensible?(target: T): boolean</code> | `es2015.proxy` |
| <code>ownKeys?(target: T): ArrayLike&lt;string &#124; symbol&gt;</code> | `es2015.proxy` |
| <code>preventExtensions?(target: T): boolean</code> | `es2015.proxy` |
| <code>set?(target: T, p: string &#124; symbol, newValue: any, receiver: any): boolean</code> | `es2015.proxy` |
| <code>setPrototypeOf?(target: T, v: object &#124; null): boolean</code> | `es2015.proxy` |

### `RangeError`

类别：interface。来源：`es5`。

```ts
interface RangeError extends Error { ... }
```

声明来源：`es5`。

### `RangeErrorConstructor`

类别：interface。来源：`es2022.error`、`es5`。

```ts
interface RangeErrorConstructor { ... }
```

声明来源：`es2022.error`。

```ts
interface RangeErrorConstructor extends ErrorConstructor { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(message?: string, options?: ErrorOptions): RangeError</code> | `es2022.error` |
| <code>(message?: string): RangeError</code> | `es5` |
| <code>new (message?: string, options?: ErrorOptions): RangeError</code> | `es2022.error` |
| <code>new (message?: string): RangeError</code> | `es5` |
| <code>readonly prototype: RangeError</code> | `es5` |

### `Readonly`

类别：type。来源：`es5`。

```ts
type Readonly<T> = { readonly [P in keyof T]: T[P]; };
```

定义来源：`es5`。

### `ReadonlyArray`

类别：interface。来源：`es2015.core`、`es2015.iterable`、`es2019.array`、`es2022.array`、`es2023.array`、`es5`。

```ts
interface ReadonlyArray<T> { ... }
```

声明来源：`es2015.core`、`es2015.iterable`、`es2019.array`、`es2022.array`、`es2023.array`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.iterator](): ArrayIterator&lt;T&gt;</code> | `es2015.iterable` |
| <code>at(index: number): T &#124; undefined</code> | `es2022.array` |
| <code>concat(...items: (T &#124; ConcatArray&lt;T&gt;)[]): T[]</code> | `es5` |
| <code>concat(...items: ConcatArray&lt;T&gt;[]): T[]</code> | `es5` |
| <code>entries(): ArrayIterator&lt;[ number, T ]&gt;</code> | `es2015.iterable` |
| <code>every(predicate: (value: T, index: number, array: readonly T[]) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>every&lt;S extends T&gt;(predicate: (value: T, index: number, array: readonly T[]) =&gt; value is S, thisArg?: any): this is readonly S[]</code> | `es5` |
| <code>filter(predicate: (value: T, index: number, array: readonly T[]) =&gt; unknown, thisArg?: any): T[]</code> | `es5` |
| <code>filter&lt;S extends T&gt;(predicate: (value: T, index: number, array: readonly T[]) =&gt; value is S, thisArg?: any): S[]</code> | `es5` |
| <code>find(predicate: (value: T, index: number, obj: readonly T[]) =&gt; unknown, thisArg?: any): T &#124; undefined</code> | `es2015.core` |
| <code>find&lt;S extends T&gt;(predicate: (value: T, index: number, obj: readonly T[]) =&gt; value is S, thisArg?: any): S &#124; undefined</code> | `es2015.core` |
| <code>findIndex(predicate: (value: T, index: number, obj: readonly T[]) =&gt; unknown, thisArg?: any): number</code> | `es2015.core` |
| <code>findLast(predicate: (value: T, index: number, array: readonly T[]) =&gt; unknown, thisArg?: any): T &#124; undefined</code> | `es2023.array` |
| <code>findLast&lt;S extends T&gt;(predicate: (value: T, index: number, array: readonly T[]) =&gt; value is S, thisArg?: any): S &#124; undefined</code> | `es2023.array` |
| <code>findLastIndex(predicate: (value: T, index: number, array: readonly T[]) =&gt; unknown, thisArg?: any): number</code> | `es2023.array` |
| <code>flat&lt;A, D extends number = 1&gt;(this: A, depth?: D): FlatArray&lt;A, D&gt;[]</code> | `es2019.array` |
| <code>flatMap&lt;U, This = undefined&gt;(callback: (this: This, value: T, index: number, array: T[]) =&gt; U &#124; ReadonlyArray&lt;U&gt;, thisArg?: This): U[]</code> | `es2019.array` |
| <code>forEach(callbackfn: (value: T, index: number, array: readonly T[]) =&gt; void, thisArg?: any): void</code> | `es5` |
| <code>indexOf(searchElement: T, fromIndex?: number): number</code> | `es5` |
| <code>join(separator?: string): string</code> | `es5` |
| <code>keys(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>lastIndexOf(searchElement: T, fromIndex?: number): number</code> | `es5` |
| <code>map&lt;U&gt;(callbackfn: (value: T, index: number, array: readonly T[]) =&gt; U, thisArg?: any): U[]</code> | `es5` |
| <code>readonly [n: number]: T</code> | `es5` |
| <code>readonly length: number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: readonly T[]) =&gt; T, initialValue: T): T</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: readonly T[]) =&gt; T): T</code> | `es5` |
| <code>reduce&lt;U&gt;(callbackfn: (previousValue: U, currentValue: T, currentIndex: number, array: readonly T[]) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: readonly T[]) =&gt; T, initialValue: T): T</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: readonly T[]) =&gt; T): T</code> | `es5` |
| <code>reduceRight&lt;U&gt;(callbackfn: (previousValue: U, currentValue: T, currentIndex: number, array: readonly T[]) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>slice(start?: number, end?: number): T[]</code> | `es5` |
| <code>some(predicate: (value: T, index: number, array: readonly T[]) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>toLocaleString(): string</code> | `es5` |
| <code>toLocaleString(locales: string &#124; string[], options?: Intl.NumberFormatOptions &amp; Intl.DateTimeFormatOptions): string</code> | `es2015.core` |
| <code>toReversed(): T[]</code> | `es2023.array` |
| <code>toSorted(compareFn?: (a: T, b: T) =&gt; number): T[]</code> | `es2023.array` |
| <code>toSpliced(start: number, deleteCount: number, ...items: T[]): T[]</code> | `es2023.array` |
| <code>toSpliced(start: number, deleteCount?: number): T[]</code> | `es2023.array` |
| <code>toString(): string</code> | `es5` |
| <code>values(): ArrayIterator&lt;T&gt;</code> | `es2015.iterable` |
| <code>with(index: number, value: T): T[]</code> | `es2023.array` |

### `ReadonlyMap`

类别：interface。来源：`es2015.collection`、`es2015.iterable`。

```ts
interface ReadonlyMap<K, V> { ... }
```

声明来源：`es2015.collection`、`es2015.iterable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.iterator](): MapIterator&lt;[ K, V ]&gt;</code> | `es2015.iterable` |
| <code>entries(): MapIterator&lt;[ K, V ]&gt;</code> | `es2015.iterable` |
| <code>forEach(callbackfn: (value: V, key: K, map: ReadonlyMap&lt;K, V&gt;) =&gt; void, thisArg?: any): void</code> | `es2015.collection` |
| <code>get(key: K): V &#124; undefined</code> | `es2015.collection` |
| <code>has(key: K): boolean</code> | `es2015.collection` |
| <code>keys(): MapIterator&lt;K&gt;</code> | `es2015.iterable` |
| <code>readonly size: number</code> | `es2015.collection` |
| <code>values(): MapIterator&lt;V&gt;</code> | `es2015.iterable` |

### `ReadonlySet`

类别：interface。来源：`es2015.collection`、`es2015.iterable`、`es2025.collection`。

```ts
interface ReadonlySet<T> { ... }
```

声明来源：`es2015.collection`、`es2015.iterable`、`es2025.collection`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.iterator](): SetIterator&lt;T&gt;</code> | `es2015.iterable` |
| <code>difference&lt;U&gt;(other: ReadonlySetLike&lt;U&gt;): Set&lt;T&gt;</code> | `es2025.collection` |
| <code>entries(): SetIterator&lt;[ T, T ]&gt;</code> | `es2015.iterable` |
| <code>forEach(callbackfn: (value: T, value2: T, set: ReadonlySet&lt;T&gt;) =&gt; void, thisArg?: any): void</code> | `es2015.collection` |
| <code>has(value: T): boolean</code> | `es2015.collection` |
| <code>intersection&lt;U&gt;(other: ReadonlySetLike&lt;U&gt;): Set&lt;T &amp; U&gt;</code> | `es2025.collection` |
| <code>isDisjointFrom(other: ReadonlySetLike&lt;unknown&gt;): boolean</code> | `es2025.collection` |
| <code>isSubsetOf(other: ReadonlySetLike&lt;unknown&gt;): boolean</code> | `es2025.collection` |
| <code>isSupersetOf(other: ReadonlySetLike&lt;unknown&gt;): boolean</code> | `es2025.collection` |
| <code>keys(): SetIterator&lt;T&gt;</code> | `es2015.iterable` |
| <code>readonly size: number</code> | `es2015.collection` |
| <code>symmetricDifference&lt;U&gt;(other: ReadonlySetLike&lt;U&gt;): Set&lt;T &#124; U&gt;</code> | `es2025.collection` |
| <code>union&lt;U&gt;(other: ReadonlySetLike&lt;U&gt;): Set&lt;T &#124; U&gt;</code> | `es2025.collection` |
| <code>values(): SetIterator&lt;T&gt;</code> | `es2015.iterable` |

### `ReadonlySetLike`

类别：interface。来源：`es2025.collection`。

```ts
interface ReadonlySetLike<T> { ... }
```

声明来源：`es2025.collection`。

| 成员签名 | 来源 |
| --- | --- |
| <code>has(value: T): boolean</code> | `es2025.collection` |
| <code>keys(): Iterator&lt;T&gt;</code> | `es2025.collection` |
| <code>readonly size: number</code> | `es2025.collection` |

### `Record`

类别：type。来源：`es5`。

```ts
type Record<K extends keyof any, T> = { [P in K]: T; };
```

定义来源：`es5`。

### `ReferenceError`

类别：interface。来源：`es5`。

```ts
interface ReferenceError extends Error { ... }
```

声明来源：`es5`。

### `ReferenceErrorConstructor`

类别：interface。来源：`es2022.error`、`es5`。

```ts
interface ReferenceErrorConstructor { ... }
```

声明来源：`es2022.error`。

```ts
interface ReferenceErrorConstructor extends ErrorConstructor { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(message?: string, options?: ErrorOptions): ReferenceError</code> | `es2022.error` |
| <code>(message?: string): ReferenceError</code> | `es5` |
| <code>new (message?: string, options?: ErrorOptions): ReferenceError</code> | `es2022.error` |
| <code>new (message?: string): ReferenceError</code> | `es5` |
| <code>readonly prototype: ReferenceError</code> | `es5` |

### `RegExp`

类别：interface。来源：`es2015.core`、`es2018.regexp`、`es2022.regexp`、`es2024.regexp`、`es5`。

```ts
interface RegExp { ... }
```

声明来源：`es2015.core`、`es2018.regexp`、`es2022.regexp`、`es2024.regexp`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>compile(pattern: string, flags?: string): this</code> | `es5` |
| <code>exec(string: string): RegExpExecArray &#124; null</code> | `es5` |
| <code>lastIndex: number</code> | `es5` |
| <code>readonly dotAll: boolean</code> | `es2018.regexp` |
| <code>readonly flags: string</code> | `es2015.core` |
| <code>readonly global: boolean</code> | `es5` |
| <code>readonly hasIndices: boolean</code> | `es2022.regexp` |
| <code>readonly ignoreCase: boolean</code> | `es5` |
| <code>readonly multiline: boolean</code> | `es5` |
| <code>readonly source: string</code> | `es5` |
| <code>readonly sticky: boolean</code> | `es2015.core` |
| <code>readonly unicode: boolean</code> | `es2015.core` |
| <code>readonly unicodeSets: boolean</code> | `es2024.regexp` |
| <code>test(string: string): boolean</code> | `es5` |

### `RegExpConstructor`

类别：interface。来源：`es2015.core`、`es2025.regexp`、`es5`。

```ts
interface RegExpConstructor { ... }
```

声明来源：`es2015.core`、`es2025.regexp`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>"$_": string</code> | `es5` |
| <code>"$'": string</code> | `es5` |
| <code>"$&amp;": string</code> | `es5` |
| <code>"$`": string</code> | `es5` |
| <code>"$+": string</code> | `es5` |
| <code>"$1": string</code> | `es5` |
| <code>"$2": string</code> | `es5` |
| <code>"$3": string</code> | `es5` |
| <code>"$4": string</code> | `es5` |
| <code>"$5": string</code> | `es5` |
| <code>"$6": string</code> | `es5` |
| <code>"$7": string</code> | `es5` |
| <code>"$8": string</code> | `es5` |
| <code>"$9": string</code> | `es5` |
| <code>"input": string</code> | `es5` |
| <code>"lastMatch": string</code> | `es5` |
| <code>"lastParen": string</code> | `es5` |
| <code>"leftContext": string</code> | `es5` |
| <code>"rightContext": string</code> | `es5` |
| <code>(pattern: RegExp &#124; string, flags?: string): RegExp</code> | `es2015.core` |
| <code>(pattern: RegExp &#124; string): RegExp</code> | `es5` |
| <code>(pattern: string, flags?: string): RegExp</code> | `es5` |
| <code>escape(string: string): string</code> | `es2025.regexp` |
| <code>new (pattern: RegExp &#124; string, flags?: string): RegExp</code> | `es2015.core` |
| <code>new (pattern: RegExp &#124; string): RegExp</code> | `es5` |
| <code>new (pattern: string, flags?: string): RegExp</code> | `es5` |
| <code>readonly "prototype": RegExp</code> | `es5` |

### `RegExpExecArray`

类别：interface。来源：`es2018.regexp`、`es2022.regexp`、`es5`。

```ts
interface RegExpExecArray { ... }
```

声明来源：`es2018.regexp`、`es2022.regexp`。

```ts
interface RegExpExecArray extends Array<string> { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>0: string</code> | `es5` |
| <code>groups?: { [key: string]: string; }</code> | `es2018.regexp` |
| <code>index: number</code> | `es5` |
| <code>indices?: RegExpIndicesArray</code> | `es2022.regexp` |
| <code>input: string</code> | `es5` |

### `RegExpIndicesArray`

类别：interface。来源：`es2022.regexp`。

```ts
interface RegExpIndicesArray extends Array<[number, number] | undefined> { ... }
```

声明来源：`es2022.regexp`。

| 成员签名 | 来源 |
| --- | --- |
| <code>groups?: { [key: string]: [ number, number ]; }</code> | `es2022.regexp` |

### `RegExpMatchArray`

类别：interface。来源：`es2018.regexp`、`es2022.regexp`、`es5`。

```ts
interface RegExpMatchArray { ... }
```

声明来源：`es2018.regexp`、`es2022.regexp`。

```ts
interface RegExpMatchArray extends Array<string> { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>0: string</code> | `es5` |
| <code>groups?: { [key: string]: string; }</code> | `es2018.regexp` |
| <code>index?: number</code> | `es5` |
| <code>indices?: RegExpIndicesArray</code> | `es2022.regexp` |
| <code>input?: string</code> | `es5` |

### `Required`

类别：type。来源：`es5`。

```ts
type Required<T> = { [P in keyof T]-?: T[P]; };
```

定义来源：`es5`。

### `ReturnType`

类别：type。来源：`es5`。

```ts
type ReturnType<T extends (...args: any) = T extends (...args: any) => infer R ? R : any;
```

定义来源：`es5`。

### `Set`

类别：interface。来源：`es2015.collection`、`es2015.iterable`、`es2025.collection`。

```ts
interface Set<T> { ... }
```

声明来源：`es2015.collection`、`es2015.iterable`、`es2025.collection`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.iterator](): SetIterator&lt;T&gt;</code> | `es2015.iterable` |
| <code>add(value: T): this</code> | `es2015.collection` |
| <code>clear(): void</code> | `es2015.collection` |
| <code>delete(value: T): boolean</code> | `es2015.collection` |
| <code>difference&lt;U&gt;(other: ReadonlySetLike&lt;U&gt;): Set&lt;T&gt;</code> | `es2025.collection` |
| <code>entries(): SetIterator&lt;[ T, T ]&gt;</code> | `es2015.iterable` |
| <code>forEach(callbackfn: (value: T, value2: T, set: Set&lt;T&gt;) =&gt; void, thisArg?: any): void</code> | `es2015.collection` |
| <code>has(value: T): boolean</code> | `es2015.collection` |
| <code>intersection&lt;U&gt;(other: ReadonlySetLike&lt;U&gt;): Set&lt;T &amp; U&gt;</code> | `es2025.collection` |
| <code>isDisjointFrom(other: ReadonlySetLike&lt;unknown&gt;): boolean</code> | `es2025.collection` |
| <code>isSubsetOf(other: ReadonlySetLike&lt;unknown&gt;): boolean</code> | `es2025.collection` |
| <code>isSupersetOf(other: ReadonlySetLike&lt;unknown&gt;): boolean</code> | `es2025.collection` |
| <code>keys(): SetIterator&lt;T&gt;</code> | `es2015.iterable` |
| <code>readonly size: number</code> | `es2015.collection` |
| <code>symmetricDifference&lt;U&gt;(other: ReadonlySetLike&lt;U&gt;): Set&lt;T &#124; U&gt;</code> | `es2025.collection` |
| <code>union&lt;U&gt;(other: ReadonlySetLike&lt;U&gt;): Set&lt;T &#124; U&gt;</code> | `es2025.collection` |
| <code>values(): SetIterator&lt;T&gt;</code> | `es2015.iterable` |

### `SetConstructor`

类别：interface。来源：`es2015.collection`、`es2015.iterable`。

```ts
interface SetConstructor { ... }
```

声明来源：`es2015.collection`、`es2015.iterable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>new &lt;T = any&gt;(values?: readonly T[] &#124; null): Set&lt;T&gt;</code> | `es2015.collection` |
| <code>new &lt;T&gt;(iterable?: Iterable&lt;T&gt; &#124; null): Set&lt;T&gt;</code> | `es2015.iterable` |
| <code>readonly prototype: Set&lt;any&gt;</code> | `es2015.collection` |

### `SetIterator`

类别：interface。来源：`es2015.iterable`。

```ts
interface SetIterator<T> extends IteratorObject<T, BuiltinIteratorReturn, unknown> { ... }
```

声明来源：`es2015.iterable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.iterator](): SetIterator&lt;T&gt;</code> | `es2015.iterable` |

### `SharedArrayBuffer`

类别：interface。来源：`es2017.sharedmemory`、`es2024.sharedmemory`。

```ts
interface SharedArrayBuffer { ... }
```

声明来源：`es2017.sharedmemory`、`es2024.sharedmemory`。

| 成员签名 | 来源 |
| --- | --- |
| <code>get growable(): boolean</code> | `es2024.sharedmemory` |
| <code>get maxByteLength(): number</code> | `es2024.sharedmemory` |
| <code>grow(newByteLength?: number): void</code> | `es2024.sharedmemory` |
| <code>readonly [Symbol.toStringTag]: "SharedArrayBuffer"</code> | `es2017.sharedmemory` |
| <code>readonly byteLength: number</code> | `es2017.sharedmemory` |
| <code>slice(begin?: number, end?: number): SharedArrayBuffer</code> | `es2017.sharedmemory` |

### `SharedArrayBufferConstructor`

类别：interface。来源：`es2017.sharedmemory`、`es2024.sharedmemory`。

```ts
interface SharedArrayBufferConstructor { ... }
```

声明来源：`es2017.sharedmemory`、`es2024.sharedmemory`。

| 成员签名 | 来源 |
| --- | --- |
| <code>new (byteLength: number, options?: { maxByteLength?: number; }): SharedArrayBuffer</code> | `es2024.sharedmemory` |
| <code>new (byteLength?: number): SharedArrayBuffer</code> | `es2017.sharedmemory` |
| <code>readonly [Symbol.species]: SharedArrayBufferConstructor</code> | `es2017.sharedmemory` |
| <code>readonly prototype: SharedArrayBuffer</code> | `es2017.sharedmemory` |

### `String`

类别：interface。来源：`es2015.core`、`es2015.iterable`、`es2017.string`、`es2019.string`、`es2020.string`、`es2021.string`、`es2022.string`、`es2024.string`、`es5`。

```ts
interface String { ... }
```

声明来源：`es2015.core`、`es2015.iterable`、`es2017.string`、`es2019.string`、`es2020.string`、`es2021.string`、`es2022.string`、`es2024.string`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.iterator](): StringIterator&lt;string&gt;</code> | `es2015.iterable` |
| <code>anchor(name: string): string</code> | `es2015.core` |
| <code>at(index: number): string &#124; undefined</code> | `es2022.string` |
| <code>big(): string</code> | `es2015.core` |
| <code>blink(): string</code> | `es2015.core` |
| <code>bold(): string</code> | `es2015.core` |
| <code>charAt(pos: number): string</code> | `es5` |
| <code>charCodeAt(index: number): number</code> | `es5` |
| <code>codePointAt(pos: number): number &#124; undefined</code> | `es2015.core` |
| <code>concat(...strings: string[]): string</code> | `es5` |
| <code>endsWith(searchString: string, endPosition?: number): boolean</code> | `es2015.core` |
| <code>fixed(): string</code> | `es2015.core` |
| <code>fontcolor(color: string): string</code> | `es2015.core` |
| <code>fontsize(size: number): string</code> | `es2015.core` |
| <code>fontsize(size: string): string</code> | `es2015.core` |
| <code>includes(searchString: string, position?: number): boolean</code> | `es2015.core` |
| <code>indexOf(searchString: string, position?: number): number</code> | `es5` |
| <code>isWellFormed(): boolean</code> | `es2024.string` |
| <code>italics(): string</code> | `es2015.core` |
| <code>lastIndexOf(searchString: string, position?: number): number</code> | `es5` |
| <code>link(url: string): string</code> | `es2015.core` |
| <code>localeCompare(that: string, locales?: Intl.LocalesArgument, options?: Intl.CollatorOptions): number</code> | `es2020.string` |
| <code>localeCompare(that: string, locales?: string &#124; string[], options?: Intl.CollatorOptions): number</code> | `es5` |
| <code>localeCompare(that: string): number</code> | `es5` |
| <code>match(regexp: string &#124; RegExp): RegExpMatchArray &#124; null</code> | `es5` |
| <code>matchAll(regexp: RegExp): RegExpStringIterator&lt;RegExpExecArray&gt;</code> | `es2020.string` |
| <code>normalize(form: "NFC" &#124; "NFD" &#124; "NFKC" &#124; "NFKD"): string</code> | `es2015.core` |
| <code>normalize(form?: string): string</code> | `es2015.core` |
| <code>padEnd(targetLength: number, padString?: string): string</code> | `es2017.string` |
| <code>padStart(targetLength: number, padString?: string): string</code> | `es2017.string` |
| <code>readonly [index: number]: string</code> | `es5` |
| <code>readonly length: number</code> | `es5` |
| <code>repeat(count: number): string</code> | `es2015.core` |
| <code>replace(searchValue: string &#124; RegExp, replacer: (substring: string, ...args: any[]) =&gt; string): string</code> | `es5` |
| <code>replace(searchValue: string &#124; RegExp, replaceValue: string): string</code> | `es5` |
| <code>replaceAll(searchValue: string &#124; RegExp, replacer: (substring: string, ...args: any[]) =&gt; string): string</code> | `es2021.string` |
| <code>replaceAll(searchValue: string &#124; RegExp, replaceValue: string): string</code> | `es2021.string` |
| <code>search(regexp: string &#124; RegExp): number</code> | `es5` |
| <code>slice(start?: number, end?: number): string</code> | `es5` |
| <code>small(): string</code> | `es2015.core` |
| <code>split(separator: string &#124; RegExp, limit?: number): string[]</code> | `es5` |
| <code>startsWith(searchString: string, position?: number): boolean</code> | `es2015.core` |
| <code>strike(): string</code> | `es2015.core` |
| <code>sub(): string</code> | `es2015.core` |
| <code>substr(from: number, length?: number): string</code> | `es5` |
| <code>substring(start: number, end?: number): string</code> | `es5` |
| <code>sup(): string</code> | `es2015.core` |
| <code>toLocaleLowerCase(locales?: Intl.LocalesArgument): string</code> | `es2020.string` |
| <code>toLocaleLowerCase(locales?: string &#124; string[]): string</code> | `es5` |
| <code>toLocaleUpperCase(locales?: Intl.LocalesArgument): string</code> | `es2020.string` |
| <code>toLocaleUpperCase(locales?: string &#124; string[]): string</code> | `es5` |
| <code>toLowerCase(): string</code> | `es5` |
| <code>toString(): string</code> | `es5` |
| <code>toUpperCase(): string</code> | `es5` |
| <code>toWellFormed(): string</code> | `es2024.string` |
| <code>trim(): string</code> | `es5` |
| <code>trimEnd(): string</code> | `es2019.string` |
| <code>trimLeft(): string</code> | `es2019.string` |
| <code>trimRight(): string</code> | `es2019.string` |
| <code>trimStart(): string</code> | `es2019.string` |
| <code>valueOf(): string</code> | `es5` |

### `StringConstructor`

类别：interface。来源：`es2015.core`、`es5`。

```ts
interface StringConstructor { ... }
```

声明来源：`es2015.core`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(value?: any): string</code> | `es5` |
| <code>fromCharCode(...codes: number[]): string</code> | `es5` |
| <code>fromCodePoint(...codePoints: number[]): string</code> | `es2015.core` |
| <code>new (value?: any): String</code> | `es5` |
| <code>raw(template: { raw: readonly string[] &#124; ArrayLike&lt;string&gt;; }, ...substitutions: any[]): string</code> | `es2015.core` |
| <code>readonly prototype: String</code> | `es5` |

### `StringIterator`

类别：interface。来源：`es2015.iterable`。

```ts
interface StringIterator<T> extends IteratorObject<T, BuiltinIteratorReturn, unknown> { ... }
```

声明来源：`es2015.iterable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[Symbol.iterator](): StringIterator&lt;T&gt;</code> | `es2015.iterable` |

### `SuppressedError`

类别：interface。来源：`esnext.disposable`。

```ts
interface SuppressedError extends Error { ... }
```

声明来源：`esnext.disposable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>error: any</code> | `esnext.disposable` |
| <code>suppressed: any</code> | `esnext.disposable` |

### `SuppressedErrorConstructor`

类别：interface。来源：`esnext.disposable`。

```ts
interface SuppressedErrorConstructor { ... }
```

声明来源：`esnext.disposable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(error: any, suppressed: any, message?: string): SuppressedError</code> | `esnext.disposable` |
| <code>new (error: any, suppressed: any, message?: string): SuppressedError</code> | `esnext.disposable` |
| <code>readonly prototype: SuppressedError</code> | `esnext.disposable` |

### `Symbol`

类别：interface。来源：`es2019.symbol`、`es5`。

```ts
interface Symbol { ... }
```

声明来源：`es2019.symbol`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>readonly description: string &#124; undefined</code> | `es2019.symbol` |
| <code>toString(): string</code> | `es5` |
| <code>valueOf(): symbol</code> | `es5` |

### `SymbolConstructor`

类别：interface。来源：`es2015.iterable`、`es2015.symbol`、`es2018.asynciterable`、`esnext.decorators`、`esnext.disposable`。

```ts
interface SymbolConstructor { ... }
```

声明来源：`es2015.iterable`、`es2015.symbol`、`es2018.asynciterable`、`esnext.decorators`、`esnext.disposable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(description?: string &#124; number): symbol</code> | `es2015.symbol` |
| <code>for(key: string): symbol</code> | `es2015.symbol` |
| <code>keyFor(sym: symbol): string &#124; undefined</code> | `es2015.symbol` |
| <code>readonly asyncDispose: unique symbol</code> | `esnext.disposable` |
| <code>readonly asyncIterator: unique symbol</code> | `es2018.asynciterable` |
| <code>readonly dispose: unique symbol</code> | `esnext.disposable` |
| <code>readonly iterator: unique symbol</code> | `es2015.iterable` |
| <code>readonly metadata: unique symbol</code> | `esnext.decorators` |
| <code>readonly prototype: Symbol</code> | `es2015.symbol` |

### `SyntaxError`

类别：interface。来源：`es5`。

```ts
interface SyntaxError extends Error { ... }
```

声明来源：`es5`。

### `SyntaxErrorConstructor`

类别：interface。来源：`es2022.error`、`es5`。

```ts
interface SyntaxErrorConstructor { ... }
```

声明来源：`es2022.error`。

```ts
interface SyntaxErrorConstructor extends ErrorConstructor { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(message?: string, options?: ErrorOptions): SyntaxError</code> | `es2022.error` |
| <code>(message?: string): SyntaxError</code> | `es5` |
| <code>new (message?: string, options?: ErrorOptions): SyntaxError</code> | `es2022.error` |
| <code>new (message?: string): SyntaxError</code> | `es5` |
| <code>readonly prototype: SyntaxError</code> | `es5` |

### `TemplateStringsArray`

类别：interface。来源：`es5`。

```ts
interface TemplateStringsArray extends ReadonlyArray<string> { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>readonly raw: readonly string[]</code> | `es5` |

### `Temporal.CalendarLike`

类别：type。来源：`esnext.temporal`。

```ts
type CalendarLike = PlainDate | PlainDateTime | PlainMonthDay | PlainYearMonth | ZonedDateTime | string;
```

定义来源：`esnext.temporal`。

### `Temporal.DateLikeObject`

类别：interface。来源：`esnext.temporal`。

```ts
interface DateLikeObject { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>calendar?: string &#124; undefined</code> | `esnext.temporal` |
| <code>day: number</code> | `esnext.temporal` |
| <code>era?: string &#124; undefined</code> | `esnext.temporal` |
| <code>eraYear?: number &#124; undefined</code> | `esnext.temporal` |
| <code>month?: number &#124; undefined</code> | `esnext.temporal` |
| <code>monthCode?: string &#124; undefined</code> | `esnext.temporal` |
| <code>year?: number &#124; undefined</code> | `esnext.temporal` |

### `Temporal.DateTimeLikeObject`

类别：interface。来源：`esnext.temporal`。

```ts
interface DateTimeLikeObject extends DateLikeObject, TimeLikeObject { ... }
```

声明来源：`esnext.temporal`。

### `Temporal.DateUnit`

类别：type。来源：`esnext.temporal`。

```ts
type DateUnit = "year" | "month" | "week" | "day";
```

定义来源：`esnext.temporal`。

### `Temporal.DisambiguationOptions`

类别：interface。来源：`esnext.temporal`。

```ts
interface DisambiguationOptions { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>disambiguation?: "compatible" &#124; "earlier" &#124; "later" &#124; "reject" &#124; undefined</code> | `esnext.temporal` |

### `Temporal.Duration`

类别：interface。来源：`esnext.temporal`。

```ts
interface Duration { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>abs(): Duration</code> | `esnext.temporal` |
| <code>add(other: DurationLike): Duration</code> | `esnext.temporal` |
| <code>negated(): Duration</code> | `esnext.temporal` |
| <code>readonly [Symbol.toStringTag]: "Temporal.Duration"</code> | `esnext.temporal` |
| <code>readonly blank: boolean</code> | `esnext.temporal` |
| <code>readonly days: number</code> | `esnext.temporal` |
| <code>readonly hours: number</code> | `esnext.temporal` |
| <code>readonly microseconds: number</code> | `esnext.temporal` |
| <code>readonly milliseconds: number</code> | `esnext.temporal` |
| <code>readonly minutes: number</code> | `esnext.temporal` |
| <code>readonly months: number</code> | `esnext.temporal` |
| <code>readonly nanoseconds: number</code> | `esnext.temporal` |
| <code>readonly seconds: number</code> | `esnext.temporal` |
| <code>readonly sign: number</code> | `esnext.temporal` |
| <code>readonly weeks: number</code> | `esnext.temporal` |
| <code>readonly years: number</code> | `esnext.temporal` |
| <code>round(roundTo: DurationRoundingOptions): Duration</code> | `esnext.temporal` |
| <code>round(roundTo: PluralizeUnit&lt;"day" &#124; TimeUnit&gt;): Duration</code> | `esnext.temporal` |
| <code>subtract(other: DurationLike): Duration</code> | `esnext.temporal` |
| <code>toJSON(): string</code> | `esnext.temporal` |
| <code>toLocaleString(locales?: Intl.LocalesArgument, options?: Intl.DurationFormatOptions): string</code> | `esnext.temporal` |
| <code>toString(options?: DurationToStringOptions): string</code> | `esnext.temporal` |
| <code>total(totalOf: DurationTotalOptions): number</code> | `esnext.temporal` |
| <code>total(totalOf: PluralizeUnit&lt;"day" &#124; TimeUnit&gt;): number</code> | `esnext.temporal` |
| <code>valueOf(): never</code> | `esnext.temporal` |
| <code>with(durationLike: PartialTemporalLike&lt;DurationLikeObject&gt;): Duration</code> | `esnext.temporal` |

### `Temporal.DurationConstructor`

类别：interface。来源：`esnext.temporal`。

```ts
interface DurationConstructor { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>compare(one: DurationLike, two: DurationLike, options?: DurationRelativeToOptions): number</code> | `esnext.temporal` |
| <code>from(item: DurationLike): Duration</code> | `esnext.temporal` |
| <code>new (years?: number, months?: number, weeks?: number, days?: number, hours?: number, minutes?: number, seconds?: number, milliseconds?: number, microseconds?: number, nanoseconds?: number): Duration</code> | `esnext.temporal` |
| <code>readonly prototype: Duration</code> | `esnext.temporal` |

### `Temporal.DurationLike`

类别：type。来源：`esnext.temporal`。

```ts
type DurationLike = Duration | DurationLikeObject | string;
```

定义来源：`esnext.temporal`。

### `Temporal.DurationLikeObject`

类别：interface。来源：`esnext.temporal`。

```ts
interface DurationLikeObject { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>days?: number &#124; undefined</code> | `esnext.temporal` |
| <code>hours?: number &#124; undefined</code> | `esnext.temporal` |
| <code>microseconds?: number &#124; undefined</code> | `esnext.temporal` |
| <code>milliseconds?: number &#124; undefined</code> | `esnext.temporal` |
| <code>minutes?: number &#124; undefined</code> | `esnext.temporal` |
| <code>months?: number &#124; undefined</code> | `esnext.temporal` |
| <code>nanoseconds?: number &#124; undefined</code> | `esnext.temporal` |
| <code>seconds?: number &#124; undefined</code> | `esnext.temporal` |
| <code>weeks?: number &#124; undefined</code> | `esnext.temporal` |
| <code>years?: number &#124; undefined</code> | `esnext.temporal` |

### `Temporal.DurationRelativeToOptions`

类别：interface。来源：`esnext.temporal`。

```ts
interface DurationRelativeToOptions { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>relativeTo?: ZonedDateTimeLike &#124; PlainDateLike &#124; undefined</code> | `esnext.temporal` |

### `Temporal.DurationRoundingOptions`

类别：interface。来源：`esnext.temporal`。

```ts
interface DurationRoundingOptions extends DurationRelativeToOptions, RoundingOptionsWithLargestUnit<DateUnit | TimeUnit> { ... }
```

声明来源：`esnext.temporal`。

### `Temporal.DurationToStringOptions`

类别：interface。来源：`esnext.temporal`。

```ts
interface DurationToStringOptions extends ToStringRoundingOptionsWithFractionalSeconds<Exclude<TimeUnit, "hour" | "minute">> { ... }
```

声明来源：`esnext.temporal`。

### `Temporal.DurationTotalOptions`

类别：interface。来源：`esnext.temporal`。

```ts
interface DurationTotalOptions extends DurationRelativeToOptions { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>unit: PluralizeUnit&lt;DateUnit &#124; TimeUnit&gt;</code> | `esnext.temporal` |

### `Temporal.Instant`

类别：interface。来源：`esnext.temporal`。

```ts
interface Instant { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>add(duration: DurationLike): Instant</code> | `esnext.temporal` |
| <code>equals(other: InstantLike): boolean</code> | `esnext.temporal` |
| <code>readonly [Symbol.toStringTag]: "Temporal.Instant"</code> | `esnext.temporal` |
| <code>readonly epochMilliseconds: number</code> | `esnext.temporal` |
| <code>readonly epochNanoseconds: bigint</code> | `esnext.temporal` |
| <code>round(roundTo: PluralizeUnit&lt;TimeUnit&gt;): Instant</code> | `esnext.temporal` |
| <code>round(roundTo: RoundingOptions&lt;TimeUnit&gt;): Instant</code> | `esnext.temporal` |
| <code>since(other: InstantLike, options?: RoundingOptionsWithLargestUnit&lt;TimeUnit&gt;): Duration</code> | `esnext.temporal` |
| <code>subtract(duration: DurationLike): Instant</code> | `esnext.temporal` |
| <code>toJSON(): string</code> | `esnext.temporal` |
| <code>toLocaleString(locales?: Intl.LocalesArgument, options?: Intl.DateTimeFormatOptions): string</code> | `esnext.temporal` |
| <code>toString(options?: InstantToStringOptions): string</code> | `esnext.temporal` |
| <code>toZonedDateTimeISO(timeZone: TimeZoneLike): ZonedDateTime</code> | `esnext.temporal` |
| <code>until(other: InstantLike, options?: RoundingOptionsWithLargestUnit&lt;TimeUnit&gt;): Duration</code> | `esnext.temporal` |
| <code>valueOf(): never</code> | `esnext.temporal` |

### `Temporal.InstantConstructor`

类别：interface。来源：`esnext.temporal`。

```ts
interface InstantConstructor { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>compare(one: InstantLike, two: InstantLike): number</code> | `esnext.temporal` |
| <code>from(item: InstantLike): Instant</code> | `esnext.temporal` |
| <code>fromEpochMilliseconds(epochMilliseconds: number): Instant</code> | `esnext.temporal` |
| <code>fromEpochNanoseconds(epochNanoseconds: bigint): Instant</code> | `esnext.temporal` |
| <code>new (epochNanoseconds: bigint): Instant</code> | `esnext.temporal` |
| <code>readonly prototype: Instant</code> | `esnext.temporal` |

### `Temporal.InstantLike`

类别：type。来源：`esnext.temporal`。

```ts
type InstantLike = Instant | ZonedDateTime | string;
```

定义来源：`esnext.temporal`。

### `Temporal.InstantToStringOptions`

类别：interface。来源：`esnext.temporal`。

```ts
interface InstantToStringOptions extends PlainTimeToStringOptions { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>timeZone?: TimeZoneLike &#124; undefined</code> | `esnext.temporal` |

### `Temporal.OverflowOptions`

类别：interface。来源：`esnext.temporal`。

```ts
interface OverflowOptions { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>overflow?: "constrain" &#124; "reject" &#124; undefined</code> | `esnext.temporal` |

### `Temporal.PartialTemporalLike`

类别：type。来源：`esnext.temporal`。

```ts
type PartialTemporalLike<T extends object> = { [P in Exclude<keyof T, "calendar" | "timeZone">]?: T[P] | undefined; };
```

定义来源：`esnext.temporal`。

### `Temporal.PlainDate`

类别：interface。来源：`esnext.temporal`。

```ts
interface PlainDate { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>add(duration: DurationLike, options?: OverflowOptions): PlainDate</code> | `esnext.temporal` |
| <code>equals(other: PlainDateLike): boolean</code> | `esnext.temporal` |
| <code>readonly [Symbol.toStringTag]: "Temporal.PlainDate"</code> | `esnext.temporal` |
| <code>readonly calendarId: string</code> | `esnext.temporal` |
| <code>readonly day: number</code> | `esnext.temporal` |
| <code>readonly dayOfWeek: number</code> | `esnext.temporal` |
| <code>readonly dayOfYear: number</code> | `esnext.temporal` |
| <code>readonly daysInMonth: number</code> | `esnext.temporal` |
| <code>readonly daysInWeek: number</code> | `esnext.temporal` |
| <code>readonly daysInYear: number</code> | `esnext.temporal` |
| <code>readonly era: string &#124; undefined</code> | `esnext.temporal` |
| <code>readonly eraYear: number &#124; undefined</code> | `esnext.temporal` |
| <code>readonly inLeapYear: boolean</code> | `esnext.temporal` |
| <code>readonly month: number</code> | `esnext.temporal` |
| <code>readonly monthCode: string</code> | `esnext.temporal` |
| <code>readonly monthsInYear: number</code> | `esnext.temporal` |
| <code>readonly weekOfYear: number &#124; undefined</code> | `esnext.temporal` |
| <code>readonly year: number</code> | `esnext.temporal` |
| <code>readonly yearOfWeek: number &#124; undefined</code> | `esnext.temporal` |
| <code>since(other: PlainDateLike, options?: RoundingOptionsWithLargestUnit&lt;DateUnit&gt;): Duration</code> | `esnext.temporal` |
| <code>subtract(duration: DurationLike, options?: OverflowOptions): PlainDate</code> | `esnext.temporal` |
| <code>toJSON(): string</code> | `esnext.temporal` |
| <code>toLocaleString(locales?: Intl.LocalesArgument, options?: Intl.DateTimeFormatOptions): string</code> | `esnext.temporal` |
| <code>toPlainDateTime(time?: PlainTimeLike): PlainDateTime</code> | `esnext.temporal` |
| <code>toPlainMonthDay(): PlainMonthDay</code> | `esnext.temporal` |
| <code>toPlainYearMonth(): PlainYearMonth</code> | `esnext.temporal` |
| <code>toString(options?: PlainDateToStringOptions): string</code> | `esnext.temporal` |
| <code>toZonedDateTime(item: PlainDateToZonedDateTimeOptions): ZonedDateTime</code> | `esnext.temporal` |
| <code>toZonedDateTime(timeZone: TimeZoneLike): ZonedDateTime</code> | `esnext.temporal` |
| <code>until(other: PlainDateLike, options?: RoundingOptionsWithLargestUnit&lt;DateUnit&gt;): Duration</code> | `esnext.temporal` |
| <code>valueOf(): never</code> | `esnext.temporal` |
| <code>with(dateLike: PartialTemporalLike&lt;DateLikeObject&gt;, options?: OverflowOptions): PlainDate</code> | `esnext.temporal` |
| <code>withCalendar(calendarLike: CalendarLike): PlainDate</code> | `esnext.temporal` |

### `Temporal.PlainDateConstructor`

类别：interface。来源：`esnext.temporal`。

```ts
interface PlainDateConstructor { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>compare(one: PlainDateLike, two: PlainDateLike): number</code> | `esnext.temporal` |
| <code>from(item: PlainDateLike, options?: OverflowOptions): PlainDate</code> | `esnext.temporal` |
| <code>new (isoYear: number, isoMonth: number, isoDay: number, calendar?: string): PlainDate</code> | `esnext.temporal` |
| <code>readonly prototype: PlainDate</code> | `esnext.temporal` |

### `Temporal.PlainDateLike`

类别：type。来源：`esnext.temporal`。

```ts
type PlainDateLike = PlainDate | ZonedDateTime | PlainDateTime | DateLikeObject | string;
```

定义来源：`esnext.temporal`。

### `Temporal.PlainDateTime`

类别：interface。来源：`esnext.temporal`。

```ts
interface PlainDateTime { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>add(duration: DurationLike, options?: OverflowOptions): PlainDateTime</code> | `esnext.temporal` |
| <code>equals(other: PlainDateTimeLike): boolean</code> | `esnext.temporal` |
| <code>readonly [Symbol.toStringTag]: "Temporal.PlainDateTime"</code> | `esnext.temporal` |
| <code>readonly calendarId: string</code> | `esnext.temporal` |
| <code>readonly day: number</code> | `esnext.temporal` |
| <code>readonly dayOfWeek: number</code> | `esnext.temporal` |
| <code>readonly dayOfYear: number</code> | `esnext.temporal` |
| <code>readonly daysInMonth: number</code> | `esnext.temporal` |
| <code>readonly daysInWeek: number</code> | `esnext.temporal` |
| <code>readonly daysInYear: number</code> | `esnext.temporal` |
| <code>readonly era: string &#124; undefined</code> | `esnext.temporal` |
| <code>readonly eraYear: number &#124; undefined</code> | `esnext.temporal` |
| <code>readonly hour: number</code> | `esnext.temporal` |
| <code>readonly inLeapYear: boolean</code> | `esnext.temporal` |
| <code>readonly microsecond: number</code> | `esnext.temporal` |
| <code>readonly millisecond: number</code> | `esnext.temporal` |
| <code>readonly minute: number</code> | `esnext.temporal` |
| <code>readonly month: number</code> | `esnext.temporal` |
| <code>readonly monthCode: string</code> | `esnext.temporal` |
| <code>readonly monthsInYear: number</code> | `esnext.temporal` |
| <code>readonly nanosecond: number</code> | `esnext.temporal` |
| <code>readonly second: number</code> | `esnext.temporal` |
| <code>readonly weekOfYear: number &#124; undefined</code> | `esnext.temporal` |
| <code>readonly year: number</code> | `esnext.temporal` |
| <code>readonly yearOfWeek: number &#124; undefined</code> | `esnext.temporal` |
| <code>round(roundTo: PluralizeUnit&lt;"day" &#124; TimeUnit&gt;): PlainDateTime</code> | `esnext.temporal` |
| <code>round(roundTo: RoundingOptions&lt;"day" &#124; TimeUnit&gt;): PlainDateTime</code> | `esnext.temporal` |
| <code>since(other: PlainDateTimeLike, options?: RoundingOptionsWithLargestUnit&lt;DateUnit &#124; TimeUnit&gt;): Duration</code> | `esnext.temporal` |
| <code>subtract(duration: DurationLike, options?: OverflowOptions): PlainDateTime</code> | `esnext.temporal` |
| <code>toJSON(): string</code> | `esnext.temporal` |
| <code>toLocaleString(locales?: Intl.LocalesArgument, options?: Intl.DateTimeFormatOptions): string</code> | `esnext.temporal` |
| <code>toPlainDate(): PlainDate</code> | `esnext.temporal` |
| <code>toPlainTime(): PlainTime</code> | `esnext.temporal` |
| <code>toString(options?: PlainDateTimeToStringOptions): string</code> | `esnext.temporal` |
| <code>toZonedDateTime(timeZone: TimeZoneLike, options?: DisambiguationOptions): ZonedDateTime</code> | `esnext.temporal` |
| <code>until(other: PlainDateTimeLike, options?: RoundingOptionsWithLargestUnit&lt;DateUnit &#124; TimeUnit&gt;): Duration</code> | `esnext.temporal` |
| <code>valueOf(): never</code> | `esnext.temporal` |
| <code>with(dateTimeLike: PartialTemporalLike&lt;DateTimeLikeObject&gt;, options?: OverflowOptions): PlainDateTime</code> | `esnext.temporal` |
| <code>withCalendar(calendar: CalendarLike): PlainDateTime</code> | `esnext.temporal` |
| <code>withPlainTime(plainTime?: PlainTimeLike): PlainDateTime</code> | `esnext.temporal` |

### `Temporal.PlainDateTimeConstructor`

类别：interface。来源：`esnext.temporal`。

```ts
interface PlainDateTimeConstructor { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>compare(one: PlainDateTimeLike, two: PlainDateTimeLike): number</code> | `esnext.temporal` |
| <code>from(item: PlainDateTimeLike, options?: OverflowOptions): PlainDateTime</code> | `esnext.temporal` |
| <code>new (isoYear: number, isoMonth: number, isoDay: number, hour?: number, minute?: number, second?: number, millisecond?: number, microsecond?: number, nanosecond?: number, calendar?: string): PlainDateTime</code> | `esnext.temporal` |
| <code>readonly prototype: PlainDateTime</code> | `esnext.temporal` |

### `Temporal.PlainDateTimeLike`

类别：type。来源：`esnext.temporal`。

```ts
type PlainDateTimeLike = PlainDateTime | ZonedDateTime | PlainDate | DateTimeLikeObject | string;
```

定义来源：`esnext.temporal`。

### `Temporal.PlainDateTimeToStringOptions`

类别：interface。来源：`esnext.temporal`。

```ts
interface PlainDateTimeToStringOptions extends PlainDateToStringOptions, PlainTimeToStringOptions { ... }
```

声明来源：`esnext.temporal`。

### `Temporal.PlainDateToStringOptions`

类别：interface。来源：`esnext.temporal`。

```ts
interface PlainDateToStringOptions { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>calendarName?: "auto" &#124; "always" &#124; "never" &#124; "critical" &#124; undefined</code> | `esnext.temporal` |

### `Temporal.PlainDateToZonedDateTimeOptions`

类别：interface。来源：`esnext.temporal`。

```ts
interface PlainDateToZonedDateTimeOptions { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>plainTime?: PlainTimeLike &#124; undefined</code> | `esnext.temporal` |
| <code>timeZone: TimeZoneLike</code> | `esnext.temporal` |

### `Temporal.PlainMonthDay`

类别：interface。来源：`esnext.temporal`。

```ts
interface PlainMonthDay { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>equals(other: PlainMonthDayLike): boolean</code> | `esnext.temporal` |
| <code>readonly [Symbol.toStringTag]: "Temporal.PlainMonthDay"</code> | `esnext.temporal` |
| <code>readonly calendarId: string</code> | `esnext.temporal` |
| <code>readonly day: number</code> | `esnext.temporal` |
| <code>readonly monthCode: string</code> | `esnext.temporal` |
| <code>toJSON(): string</code> | `esnext.temporal` |
| <code>toLocaleString(locales?: Intl.LocalesArgument, options?: Intl.DateTimeFormatOptions): string</code> | `esnext.temporal` |
| <code>toPlainDate(item: PlainMonthDayToPlainDateOptions): PlainDate</code> | `esnext.temporal` |
| <code>toString(options?: PlainDateToStringOptions): string</code> | `esnext.temporal` |
| <code>valueOf(): never</code> | `esnext.temporal` |
| <code>with(monthDayLike: PartialTemporalLike&lt;DateLikeObject&gt;, options?: OverflowOptions): PlainMonthDay</code> | `esnext.temporal` |

### `Temporal.PlainMonthDayConstructor`

类别：interface。来源：`esnext.temporal`。

```ts
interface PlainMonthDayConstructor { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>from(item: PlainMonthDayLike, options?: OverflowOptions): PlainMonthDay</code> | `esnext.temporal` |
| <code>new (isoMonth: number, isoDay: number, calendar?: string, referenceISOYear?: number): PlainMonthDay</code> | `esnext.temporal` |
| <code>readonly prototype: PlainMonthDay</code> | `esnext.temporal` |

### `Temporal.PlainMonthDayLike`

类别：type。来源：`esnext.temporal`。

```ts
type PlainMonthDayLike = PlainMonthDay | DateLikeObject | string;
```

定义来源：`esnext.temporal`。

### `Temporal.PlainMonthDayToPlainDateOptions`

类别：interface。来源：`esnext.temporal`。

```ts
interface PlainMonthDayToPlainDateOptions { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>era?: string &#124; undefined</code> | `esnext.temporal` |
| <code>eraYear?: number &#124; undefined</code> | `esnext.temporal` |
| <code>year?: number &#124; undefined</code> | `esnext.temporal` |

### `Temporal.PlainTime`

类别：interface。来源：`esnext.temporal`。

```ts
interface PlainTime { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>add(duration: DurationLike): PlainTime</code> | `esnext.temporal` |
| <code>equals(other: PlainTimeLike): boolean</code> | `esnext.temporal` |
| <code>readonly [Symbol.toStringTag]: "Temporal.PlainTime"</code> | `esnext.temporal` |
| <code>readonly hour: number</code> | `esnext.temporal` |
| <code>readonly microsecond: number</code> | `esnext.temporal` |
| <code>readonly millisecond: number</code> | `esnext.temporal` |
| <code>readonly minute: number</code> | `esnext.temporal` |
| <code>readonly nanosecond: number</code> | `esnext.temporal` |
| <code>readonly second: number</code> | `esnext.temporal` |
| <code>round(roundTo: PluralizeUnit&lt;TimeUnit&gt;): PlainTime</code> | `esnext.temporal` |
| <code>round(roundTo: RoundingOptions&lt;TimeUnit&gt;): PlainTime</code> | `esnext.temporal` |
| <code>since(other: PlainTimeLike, options?: RoundingOptionsWithLargestUnit&lt;TimeUnit&gt;): Duration</code> | `esnext.temporal` |
| <code>subtract(duration: DurationLike): PlainTime</code> | `esnext.temporal` |
| <code>toJSON(): string</code> | `esnext.temporal` |
| <code>toLocaleString(locales?: Intl.LocalesArgument, options?: Intl.DateTimeFormatOptions): string</code> | `esnext.temporal` |
| <code>toString(options?: PlainTimeToStringOptions): string</code> | `esnext.temporal` |
| <code>until(other: PlainTimeLike, options?: RoundingOptionsWithLargestUnit&lt;TimeUnit&gt;): Duration</code> | `esnext.temporal` |
| <code>valueOf(): never</code> | `esnext.temporal` |
| <code>with(timeLike: PartialTemporalLike&lt;TimeLikeObject&gt;, options?: OverflowOptions): PlainTime</code> | `esnext.temporal` |

### `Temporal.PlainTimeConstructor`

类别：interface。来源：`esnext.temporal`。

```ts
interface PlainTimeConstructor { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>compare(one: PlainTimeLike, two: PlainTimeLike): number</code> | `esnext.temporal` |
| <code>from(item: PlainTimeLike, options?: OverflowOptions): PlainTime</code> | `esnext.temporal` |
| <code>new (hour?: number, minute?: number, second?: number, millisecond?: number, microsecond?: number, nanosecond?: number): PlainTime</code> | `esnext.temporal` |
| <code>readonly prototype: PlainTime</code> | `esnext.temporal` |

### `Temporal.PlainTimeLike`

类别：type。来源：`esnext.temporal`。

```ts
type PlainTimeLike = PlainTime | PlainDateTime | ZonedDateTime | TimeLikeObject | string;
```

定义来源：`esnext.temporal`。

### `Temporal.PlainTimeToStringOptions`

类别：interface。来源：`esnext.temporal`。

```ts
interface PlainTimeToStringOptions extends ToStringRoundingOptionsWithFractionalSeconds<Exclude<TimeUnit, "hour">> { ... }
```

声明来源：`esnext.temporal`。

### `Temporal.PlainYearMonth`

类别：interface。来源：`esnext.temporal`。

```ts
interface PlainYearMonth { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>add(duration: DurationLike, options?: OverflowOptions): PlainYearMonth</code> | `esnext.temporal` |
| <code>equals(other: PlainYearMonthLike): boolean</code> | `esnext.temporal` |
| <code>readonly [Symbol.toStringTag]: "Temporal.PlainYearMonth"</code> | `esnext.temporal` |
| <code>readonly calendarId: string</code> | `esnext.temporal` |
| <code>readonly daysInMonth: number</code> | `esnext.temporal` |
| <code>readonly daysInYear: number</code> | `esnext.temporal` |
| <code>readonly era: string &#124; undefined</code> | `esnext.temporal` |
| <code>readonly eraYear: number &#124; undefined</code> | `esnext.temporal` |
| <code>readonly inLeapYear: boolean</code> | `esnext.temporal` |
| <code>readonly month: number</code> | `esnext.temporal` |
| <code>readonly monthCode: string</code> | `esnext.temporal` |
| <code>readonly monthsInYear: number</code> | `esnext.temporal` |
| <code>readonly year: number</code> | `esnext.temporal` |
| <code>since(other: PlainYearMonthLike, options?: RoundingOptionsWithLargestUnit&lt;"year" &#124; "month"&gt;): Duration</code> | `esnext.temporal` |
| <code>subtract(duration: DurationLike, options?: OverflowOptions): PlainYearMonth</code> | `esnext.temporal` |
| <code>toJSON(): string</code> | `esnext.temporal` |
| <code>toLocaleString(locales?: Intl.LocalesArgument, options?: Intl.DateTimeFormatOptions): string</code> | `esnext.temporal` |
| <code>toPlainDate(item: PlainYearMonthToPlainDateOptions): PlainDate</code> | `esnext.temporal` |
| <code>toString(options?: PlainDateToStringOptions): string</code> | `esnext.temporal` |
| <code>until(other: PlainYearMonthLike, options?: RoundingOptionsWithLargestUnit&lt;"year" &#124; "month"&gt;): Duration</code> | `esnext.temporal` |
| <code>valueOf(): never</code> | `esnext.temporal` |
| <code>with(yearMonthLike: PartialTemporalLike&lt;YearMonthLikeObject&gt;, options?: OverflowOptions): PlainYearMonth</code> | `esnext.temporal` |

### `Temporal.PlainYearMonthConstructor`

类别：interface。来源：`esnext.temporal`。

```ts
interface PlainYearMonthConstructor { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>compare(one: PlainYearMonthLike, two: PlainYearMonthLike): number</code> | `esnext.temporal` |
| <code>from(item: PlainYearMonthLike, options?: OverflowOptions): PlainYearMonth</code> | `esnext.temporal` |
| <code>new (isoYear: number, isoMonth: number, calendar?: string, referenceISODay?: number): PlainYearMonth</code> | `esnext.temporal` |
| <code>readonly prototype: PlainYearMonth</code> | `esnext.temporal` |

### `Temporal.PlainYearMonthLike`

类别：type。来源：`esnext.temporal`。

```ts
type PlainYearMonthLike = PlainYearMonth | YearMonthLikeObject | string;
```

定义来源：`esnext.temporal`。

### `Temporal.PlainYearMonthToPlainDateOptions`

类别：interface。来源：`esnext.temporal`。

```ts
interface PlainYearMonthToPlainDateOptions { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>day: number</code> | `esnext.temporal` |

### `Temporal.PluralizeUnit`

类别：type。来源：`esnext.temporal`。

```ts
type PluralizeUnit<T extends DateUnit | TimeUnit> = | T | { year: "years"; month: "months"; week: "weeks"; day: "days"; hour: "hours"; minute: "minutes"; second: "seconds"; millisecond: "milliseconds"; microsecond: "microseconds"; nanosecond: "nanoseconds"; }[T];
```

定义来源：`esnext.temporal`。

### `Temporal.RoundingOptions`

类别：interface。来源：`esnext.temporal`。

```ts
interface RoundingOptions<Units extends DateUnit | TimeUnit> { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>roundingIncrement?: number &#124; undefined</code> | `esnext.temporal` |
| <code>roundingMode?: "ceil" &#124; "floor" &#124; "expand" &#124; "trunc" &#124; "halfCeil" &#124; "halfFloor" &#124; "halfExpand" &#124; "halfTrunc" &#124; "halfEven" &#124; undefined</code> | `esnext.temporal` |
| <code>smallestUnit?: PluralizeUnit&lt;Units&gt; &#124; undefined</code> | `esnext.temporal` |

### `Temporal.RoundingOptionsWithLargestUnit`

类别：interface。来源：`esnext.temporal`。

```ts
interface RoundingOptionsWithLargestUnit<Units extends DateUnit | TimeUnit> extends RoundingOptions<Units> { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>largestUnit?: "auto" &#124; PluralizeUnit&lt;Units&gt; &#124; undefined</code> | `esnext.temporal` |

### `Temporal.TimeLikeObject`

类别：interface。来源：`esnext.temporal`。

```ts
interface TimeLikeObject { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>hour?: number &#124; undefined</code> | `esnext.temporal` |
| <code>microsecond?: number &#124; undefined</code> | `esnext.temporal` |
| <code>millisecond?: number &#124; undefined</code> | `esnext.temporal` |
| <code>minute?: number &#124; undefined</code> | `esnext.temporal` |
| <code>nanosecond?: number &#124; undefined</code> | `esnext.temporal` |
| <code>second?: number &#124; undefined</code> | `esnext.temporal` |

### `Temporal.TimeUnit`

类别：type。来源：`esnext.temporal`。

```ts
type TimeUnit = "hour" | "minute" | "second" | "millisecond" | "microsecond" | "nanosecond";
```

定义来源：`esnext.temporal`。

### `Temporal.TimeZoneLike`

类别：type。来源：`esnext.temporal`。

```ts
type TimeZoneLike = ZonedDateTime | string;
```

定义来源：`esnext.temporal`。

### `Temporal.ToStringRoundingOptions`

类别：interface。来源：`esnext.temporal`。

```ts
interface ToStringRoundingOptions<Units extends DateUnit | TimeUnit> extends Pick<RoundingOptions<Units>, "smallestUnit" | "roundingMode"> { ... }
```

声明来源：`esnext.temporal`。

### `Temporal.ToStringRoundingOptionsWithFractionalSeconds`

类别：interface。来源：`esnext.temporal`。

```ts
interface ToStringRoundingOptionsWithFractionalSeconds<Units extends DateUnit | TimeUnit> extends ToStringRoundingOptions<Units> { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>fractionalSecondDigits?: "auto" &#124; 0 &#124; 1 &#124; 2 &#124; 3 &#124; 4 &#124; 5 &#124; 6 &#124; 7 &#124; 8 &#124; 9 &#124; undefined</code> | `esnext.temporal` |

### `Temporal.TransitionOptions`

类别：interface。来源：`esnext.temporal`。

```ts
interface TransitionOptions { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>direction: "next" &#124; "previous"</code> | `esnext.temporal` |

### `Temporal.YearMonthLikeObject`

类别：interface。来源：`esnext.temporal`。

```ts
interface YearMonthLikeObject extends Omit<DateLikeObject, "day"> { ... }
```

声明来源：`esnext.temporal`。

### `Temporal.ZonedDateTime`

类别：interface。来源：`esnext.temporal`。

```ts
interface ZonedDateTime { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>add(duration: DurationLike, options?: OverflowOptions): ZonedDateTime</code> | `esnext.temporal` |
| <code>equals(other: ZonedDateTimeLike): boolean</code> | `esnext.temporal` |
| <code>getTimeZoneTransition(direction: "next" &#124; "previous"): ZonedDateTime &#124; null</code> | `esnext.temporal` |
| <code>getTimeZoneTransition(direction: TransitionOptions): ZonedDateTime &#124; null</code> | `esnext.temporal` |
| <code>readonly [Symbol.toStringTag]: "Temporal.ZonedDateTime"</code> | `esnext.temporal` |
| <code>readonly calendarId: string</code> | `esnext.temporal` |
| <code>readonly day: number</code> | `esnext.temporal` |
| <code>readonly dayOfWeek: number</code> | `esnext.temporal` |
| <code>readonly dayOfYear: number</code> | `esnext.temporal` |
| <code>readonly daysInMonth: number</code> | `esnext.temporal` |
| <code>readonly daysInWeek: number</code> | `esnext.temporal` |
| <code>readonly daysInYear: number</code> | `esnext.temporal` |
| <code>readonly epochMilliseconds: number</code> | `esnext.temporal` |
| <code>readonly epochNanoseconds: bigint</code> | `esnext.temporal` |
| <code>readonly era: string &#124; undefined</code> | `esnext.temporal` |
| <code>readonly eraYear: number &#124; undefined</code> | `esnext.temporal` |
| <code>readonly hour: number</code> | `esnext.temporal` |
| <code>readonly hoursInDay: number</code> | `esnext.temporal` |
| <code>readonly inLeapYear: boolean</code> | `esnext.temporal` |
| <code>readonly microsecond: number</code> | `esnext.temporal` |
| <code>readonly millisecond: number</code> | `esnext.temporal` |
| <code>readonly minute: number</code> | `esnext.temporal` |
| <code>readonly month: number</code> | `esnext.temporal` |
| <code>readonly monthCode: string</code> | `esnext.temporal` |
| <code>readonly monthsInYear: number</code> | `esnext.temporal` |
| <code>readonly nanosecond: number</code> | `esnext.temporal` |
| <code>readonly offset: string</code> | `esnext.temporal` |
| <code>readonly offsetNanoseconds: number</code> | `esnext.temporal` |
| <code>readonly second: number</code> | `esnext.temporal` |
| <code>readonly timeZoneId: string</code> | `esnext.temporal` |
| <code>readonly weekOfYear: number &#124; undefined</code> | `esnext.temporal` |
| <code>readonly year: number</code> | `esnext.temporal` |
| <code>readonly yearOfWeek: number &#124; undefined</code> | `esnext.temporal` |
| <code>round(roundTo: PluralizeUnit&lt;"day" &#124; TimeUnit&gt;): ZonedDateTime</code> | `esnext.temporal` |
| <code>round(roundTo: RoundingOptions&lt;"day" &#124; TimeUnit&gt;): ZonedDateTime</code> | `esnext.temporal` |
| <code>since(other: ZonedDateTimeLike, options?: RoundingOptionsWithLargestUnit&lt;DateUnit &#124; TimeUnit&gt;): Duration</code> | `esnext.temporal` |
| <code>startOfDay(): ZonedDateTime</code> | `esnext.temporal` |
| <code>subtract(duration: DurationLike, options?: OverflowOptions): ZonedDateTime</code> | `esnext.temporal` |
| <code>toInstant(): Instant</code> | `esnext.temporal` |
| <code>toJSON(): string</code> | `esnext.temporal` |
| <code>toLocaleString(locales?: Intl.LocalesArgument, options?: Intl.DateTimeFormatOptions): string</code> | `esnext.temporal` |
| <code>toPlainDate(): PlainDate</code> | `esnext.temporal` |
| <code>toPlainDateTime(): PlainDateTime</code> | `esnext.temporal` |
| <code>toPlainTime(): PlainTime</code> | `esnext.temporal` |
| <code>toString(options?: ZonedDateTimeToStringOptions): string</code> | `esnext.temporal` |
| <code>until(other: ZonedDateTimeLike, options?: RoundingOptionsWithLargestUnit&lt;DateUnit &#124; TimeUnit&gt;): Duration</code> | `esnext.temporal` |
| <code>valueOf(): never</code> | `esnext.temporal` |
| <code>with(zonedDateTimeLike: PartialTemporalLike&lt;ZonedDateTimeLikeObject&gt;, options?: ZonedDateTimeFromOptions): ZonedDateTime</code> | `esnext.temporal` |
| <code>withCalendar(calendar: CalendarLike): ZonedDateTime</code> | `esnext.temporal` |
| <code>withPlainTime(plainTime?: PlainTimeLike): ZonedDateTime</code> | `esnext.temporal` |
| <code>withTimeZone(timeZone: TimeZoneLike): ZonedDateTime</code> | `esnext.temporal` |

### `Temporal.ZonedDateTimeConstructor`

类别：interface。来源：`esnext.temporal`。

```ts
interface ZonedDateTimeConstructor { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>compare(one: ZonedDateTimeLike, two: ZonedDateTimeLike): number</code> | `esnext.temporal` |
| <code>from(item: ZonedDateTimeLike, options?: ZonedDateTimeFromOptions): ZonedDateTime</code> | `esnext.temporal` |
| <code>new (epochNanoseconds: bigint, timeZone: string, calendar?: string): ZonedDateTime</code> | `esnext.temporal` |
| <code>readonly prototype: ZonedDateTime</code> | `esnext.temporal` |

### `Temporal.ZonedDateTimeFromOptions`

类别：interface。来源：`esnext.temporal`。

```ts
interface ZonedDateTimeFromOptions extends OverflowOptions, DisambiguationOptions { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>offset?: "use" &#124; "ignore" &#124; "prefer" &#124; "reject" &#124; undefined</code> | `esnext.temporal` |

### `Temporal.ZonedDateTimeLike`

类别：type。来源：`esnext.temporal`。

```ts
type ZonedDateTimeLike = ZonedDateTime | ZonedDateTimeLikeObject | string;
```

定义来源：`esnext.temporal`。

### `Temporal.ZonedDateTimeLikeObject`

类别：interface。来源：`esnext.temporal`。

```ts
interface ZonedDateTimeLikeObject extends DateTimeLikeObject { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>offset?: string &#124; undefined</code> | `esnext.temporal` |
| <code>timeZone: TimeZoneLike</code> | `esnext.temporal` |

### `Temporal.ZonedDateTimeToStringOptions`

类别：interface。来源：`esnext.temporal`。

```ts
interface ZonedDateTimeToStringOptions extends PlainDateTimeToStringOptions { ... }
```

声明来源：`esnext.temporal`。

| 成员签名 | 来源 |
| --- | --- |
| <code>offset?: "auto" &#124; "never" &#124; undefined</code> | `esnext.temporal` |
| <code>timeZoneName?: "auto" &#124; "never" &#124; "critical" &#124; undefined</code> | `esnext.temporal` |

### `ThisParameterType`

类别：type。来源：`es5`。

```ts
type ThisParameterType<T> = T extends (this: infer U, ...args: never) => any ? U : unknown;
```

定义来源：`es5`。

### `ThisType`

类别：interface。来源：`es5`。

```ts
interface ThisType<T> { ... }
```

声明来源：`es5`。

### `TypedPropertyDescriptor`

类别：interface。来源：`es5`。

```ts
interface TypedPropertyDescriptor<T> { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>configurable?: boolean</code> | `es5` |
| <code>enumerable?: boolean</code> | `es5` |
| <code>get?: () =&gt; T</code> | `es5` |
| <code>set?: (value: T) =&gt; void</code> | `es5` |
| <code>value?: T</code> | `es5` |
| <code>writable?: boolean</code> | `es5` |

### `TypeError`

类别：interface。来源：`es5`。

```ts
interface TypeError extends Error { ... }
```

声明来源：`es5`。

### `TypeErrorConstructor`

类别：interface。来源：`es2022.error`、`es5`。

```ts
interface TypeErrorConstructor { ... }
```

声明来源：`es2022.error`。

```ts
interface TypeErrorConstructor extends ErrorConstructor { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(message?: string, options?: ErrorOptions): TypeError</code> | `es2022.error` |
| <code>(message?: string): TypeError</code> | `es5` |
| <code>new (message?: string, options?: ErrorOptions): TypeError</code> | `es2022.error` |
| <code>new (message?: string): TypeError</code> | `es5` |
| <code>readonly prototype: TypeError</code> | `es5` |

### `Uint16Array`

类别：interface。来源：`es2015.core`、`es2015.iterable`、`es2022.array`、`es2023.array`、`es5`。

```ts
interface Uint16Array<TArrayBuffer extends ArrayBufferLike> { ... }
```

声明来源：`es2015.core`、`es2015.iterable`、`es2022.array`、`es2023.array`。

```ts
interface Uint16Array<TArrayBuffer extends ArrayBufferLike = ArrayBufferLike> { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[index: number]: number</code> | `es5` |
| <code>[Symbol.iterator](): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>at(index: number): number &#124; undefined</code> | `es2022.array` |
| <code>copyWithin(target: number, start: number, end?: number): this</code> | `es5` |
| <code>entries(): ArrayIterator&lt;[ number, number ]&gt;</code> | `es2015.iterable` |
| <code>every(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>fill(value: number, start?: number, end?: number): this</code> | `es5` |
| <code>filter(predicate: (value: number, index: number, array: this) =&gt; any, thisArg?: any): Uint16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>find(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number &#124; undefined</code> | `es5` |
| <code>findIndex(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number</code> | `es5` |
| <code>findLast(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number &#124; undefined</code> | `es2023.array` |
| <code>findLast&lt;S extends number&gt;(predicate: (value: number, index: number, array: this) =&gt; value is S, thisArg?: any): S &#124; undefined</code> | `es2023.array` |
| <code>findLastIndex(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number</code> | `es2023.array` |
| <code>forEach(callbackfn: (value: number, index: number, array: this) =&gt; void, thisArg?: any): void</code> | `es5` |
| <code>indexOf(searchElement: number, fromIndex?: number): number</code> | `es5` |
| <code>join(separator?: string): string</code> | `es5` |
| <code>keys(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>lastIndexOf(searchElement: number, fromIndex?: number): number</code> | `es5` |
| <code>map(callbackfn: (value: number, index: number, array: this) =&gt; number, thisArg?: any): Uint16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>readonly buffer: TArrayBuffer</code> | `es5` |
| <code>readonly byteLength: number</code> | `es5` |
| <code>readonly byteOffset: number</code> | `es5` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es5` |
| <code>readonly length: number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es5` |
| <code>reduce&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es5` |
| <code>reduceRight&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reverse(): this</code> | `es5` |
| <code>set(array: ArrayLike&lt;number&gt;, offset?: number): void</code> | `es5` |
| <code>slice(start?: number, end?: number): Uint16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>some(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>sort(compareFn?: (a: number, b: number) =&gt; number): this</code> | `es5` |
| <code>subarray(begin?: number, end?: number): Uint16Array&lt;TArrayBuffer&gt;</code> | `es5` |
| <code>toLocaleString(): string</code> | `es5` |
| <code>toLocaleString(locales: string &#124; string[], options?: Intl.NumberFormatOptions): string</code> | `es2015.core` |
| <code>toReversed(): Uint16Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toSorted(compareFn?: (a: number, b: number) =&gt; number): Uint16Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toString(): string</code> | `es5` |
| <code>valueOf(): this</code> | `es5` |
| <code>values(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>with(index: number, value: number): Uint16Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |

### `Uint16ArrayConstructor`

类别：interface。来源：`es2015.iterable`、`es2017.typedarrays`、`es5`。

```ts
interface Uint16ArrayConstructor { ... }
```

声明来源：`es2015.iterable`、`es2017.typedarrays`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>from(arrayLike: ArrayLike&lt;number&gt;): Uint16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>from(elements: Iterable&lt;number&gt;): Uint16Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>from&lt;T&gt;(arrayLike: ArrayLike&lt;T&gt;, mapfn: (v: T, k: number) =&gt; number, thisArg?: any): Uint16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>from&lt;T&gt;(elements: Iterable&lt;T&gt;, mapfn?: (v: T, k: number) =&gt; number, thisArg?: any): Uint16Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>new (): Uint16Array&lt;ArrayBuffer&gt;</code> | `es2017.typedarrays` |
| <code>new (array: ArrayLike&lt;number&gt; &#124; ArrayBuffer): Uint16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (array: ArrayLike&lt;number&gt;): Uint16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (buffer: ArrayBuffer, byteOffset?: number, length?: number): Uint16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (elements: Iterable&lt;number&gt;): Uint16Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>new (length: number): Uint16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new &lt;TArrayBuffer extends ArrayBufferLike = ArrayBuffer&gt;(buffer: TArrayBuffer, byteOffset?: number, length?: number): Uint16Array&lt;TArrayBuffer&gt;</code> | `es5` |
| <code>of(...items: number[]): Uint16Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es5` |
| <code>readonly prototype: Uint16Array&lt;ArrayBufferLike&gt;</code> | `es5` |

### `Uint32Array`

类别：interface。来源：`es2015.core`、`es2015.iterable`、`es2022.array`、`es2023.array`、`es5`。

```ts
interface Uint32Array<TArrayBuffer extends ArrayBufferLike> { ... }
```

声明来源：`es2015.core`、`es2015.iterable`、`es2022.array`、`es2023.array`。

```ts
interface Uint32Array<TArrayBuffer extends ArrayBufferLike = ArrayBufferLike> { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[index: number]: number</code> | `es5` |
| <code>[Symbol.iterator](): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>at(index: number): number &#124; undefined</code> | `es2022.array` |
| <code>copyWithin(target: number, start: number, end?: number): this</code> | `es5` |
| <code>entries(): ArrayIterator&lt;[ number, number ]&gt;</code> | `es2015.iterable` |
| <code>every(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>fill(value: number, start?: number, end?: number): this</code> | `es5` |
| <code>filter(predicate: (value: number, index: number, array: this) =&gt; any, thisArg?: any): Uint32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>find(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number &#124; undefined</code> | `es5` |
| <code>findIndex(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number</code> | `es5` |
| <code>findLast(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number &#124; undefined</code> | `es2023.array` |
| <code>findLast&lt;S extends number&gt;(predicate: (value: number, index: number, array: this) =&gt; value is S, thisArg?: any): S &#124; undefined</code> | `es2023.array` |
| <code>findLastIndex(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number</code> | `es2023.array` |
| <code>forEach(callbackfn: (value: number, index: number, array: this) =&gt; void, thisArg?: any): void</code> | `es5` |
| <code>indexOf(searchElement: number, fromIndex?: number): number</code> | `es5` |
| <code>join(separator?: string): string</code> | `es5` |
| <code>keys(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>lastIndexOf(searchElement: number, fromIndex?: number): number</code> | `es5` |
| <code>map(callbackfn: (value: number, index: number, array: this) =&gt; number, thisArg?: any): Uint32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>readonly buffer: TArrayBuffer</code> | `es5` |
| <code>readonly byteLength: number</code> | `es5` |
| <code>readonly byteOffset: number</code> | `es5` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es5` |
| <code>readonly length: number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es5` |
| <code>reduce&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es5` |
| <code>reduceRight&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reverse(): this</code> | `es5` |
| <code>set(array: ArrayLike&lt;number&gt;, offset?: number): void</code> | `es5` |
| <code>slice(start?: number, end?: number): Uint32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>some(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>sort(compareFn?: (a: number, b: number) =&gt; number): this</code> | `es5` |
| <code>subarray(begin?: number, end?: number): Uint32Array&lt;TArrayBuffer&gt;</code> | `es5` |
| <code>toLocaleString(): string</code> | `es5` |
| <code>toLocaleString(locales: string &#124; string[], options?: Intl.NumberFormatOptions): string</code> | `es2015.core` |
| <code>toReversed(): Uint32Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toSorted(compareFn?: (a: number, b: number) =&gt; number): Uint32Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toString(): string</code> | `es5` |
| <code>valueOf(): this</code> | `es5` |
| <code>values(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>with(index: number, value: number): Uint32Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |

### `Uint32ArrayConstructor`

类别：interface。来源：`es2015.iterable`、`es2017.typedarrays`、`es5`。

```ts
interface Uint32ArrayConstructor { ... }
```

声明来源：`es2015.iterable`、`es2017.typedarrays`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>from(arrayLike: ArrayLike&lt;number&gt;): Uint32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>from(elements: Iterable&lt;number&gt;): Uint32Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>from&lt;T&gt;(arrayLike: ArrayLike&lt;T&gt;, mapfn: (v: T, k: number) =&gt; number, thisArg?: any): Uint32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>from&lt;T&gt;(elements: Iterable&lt;T&gt;, mapfn?: (v: T, k: number) =&gt; number, thisArg?: any): Uint32Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>new (): Uint32Array&lt;ArrayBuffer&gt;</code> | `es2017.typedarrays` |
| <code>new (array: ArrayLike&lt;number&gt; &#124; ArrayBuffer): Uint32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (array: ArrayLike&lt;number&gt;): Uint32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (buffer: ArrayBuffer, byteOffset?: number, length?: number): Uint32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (elements: Iterable&lt;number&gt;): Uint32Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>new (length: number): Uint32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new &lt;TArrayBuffer extends ArrayBufferLike = ArrayBuffer&gt;(buffer: TArrayBuffer, byteOffset?: number, length?: number): Uint32Array&lt;TArrayBuffer&gt;</code> | `es5` |
| <code>of(...items: number[]): Uint32Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es5` |
| <code>readonly prototype: Uint32Array&lt;ArrayBufferLike&gt;</code> | `es5` |

### `Uint8Array`

类别：interface。来源：`es2015.core`、`es2015.iterable`、`es2022.array`、`es2023.array`、`es5`、`esnext.typedarrays`。

```ts
interface Uint8Array<TArrayBuffer extends ArrayBufferLike> { ... }
```

声明来源：`es2015.core`、`es2015.iterable`、`es2022.array`、`es2023.array`、`esnext.typedarrays`。

```ts
interface Uint8Array<TArrayBuffer extends ArrayBufferLike = ArrayBufferLike> { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[index: number]: number</code> | `es5` |
| <code>[Symbol.iterator](): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>at(index: number): number &#124; undefined</code> | `es2022.array` |
| <code>copyWithin(target: number, start: number, end?: number): this</code> | `es5` |
| <code>entries(): ArrayIterator&lt;[ number, number ]&gt;</code> | `es2015.iterable` |
| <code>every(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>fill(value: number, start?: number, end?: number): this</code> | `es5` |
| <code>filter(predicate: (value: number, index: number, array: this) =&gt; any, thisArg?: any): Uint8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>find(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number &#124; undefined</code> | `es5` |
| <code>findIndex(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number</code> | `es5` |
| <code>findLast(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number &#124; undefined</code> | `es2023.array` |
| <code>findLast&lt;S extends number&gt;(predicate: (value: number, index: number, array: this) =&gt; value is S, thisArg?: any): S &#124; undefined</code> | `es2023.array` |
| <code>findLastIndex(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number</code> | `es2023.array` |
| <code>forEach(callbackfn: (value: number, index: number, array: this) =&gt; void, thisArg?: any): void</code> | `es5` |
| <code>indexOf(searchElement: number, fromIndex?: number): number</code> | `es5` |
| <code>join(separator?: string): string</code> | `es5` |
| <code>keys(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>lastIndexOf(searchElement: number, fromIndex?: number): number</code> | `es5` |
| <code>map(callbackfn: (value: number, index: number, array: this) =&gt; number, thisArg?: any): Uint8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>readonly buffer: TArrayBuffer</code> | `es5` |
| <code>readonly byteLength: number</code> | `es5` |
| <code>readonly byteOffset: number</code> | `es5` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es5` |
| <code>readonly length: number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es5` |
| <code>reduce&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es5` |
| <code>reduceRight&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reverse(): this</code> | `es5` |
| <code>set(array: ArrayLike&lt;number&gt;, offset?: number): void</code> | `es5` |
| <code>setFromBase64(string: string, options?: { alphabet?: "base64" &#124; "base64url" &#124; undefined; lastChunkHandling?: "loose" &#124; "strict" &#124; "stop-before-partial" &#124; undefined; }): { read: number; written: number; }</code> | `esnext.typedarrays` |
| <code>setFromHex(string: string): { read: number; written: number; }</code> | `esnext.typedarrays` |
| <code>slice(start?: number, end?: number): Uint8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>some(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>sort(compareFn?: (a: number, b: number) =&gt; number): this</code> | `es5` |
| <code>subarray(begin?: number, end?: number): Uint8Array&lt;TArrayBuffer&gt;</code> | `es5` |
| <code>toBase64(options?: { alphabet?: "base64" &#124; "base64url" &#124; undefined; omitPadding?: boolean &#124; undefined; }): string</code> | `esnext.typedarrays` |
| <code>toHex(): string</code> | `esnext.typedarrays` |
| <code>toLocaleString(): string</code> | `es5` |
| <code>toLocaleString(locales: string &#124; string[], options?: Intl.NumberFormatOptions): string</code> | `es2015.core` |
| <code>toReversed(): Uint8Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toSorted(compareFn?: (a: number, b: number) =&gt; number): Uint8Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toString(): string</code> | `es5` |
| <code>valueOf(): this</code> | `es5` |
| <code>values(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>with(index: number, value: number): Uint8Array&lt;ArrayBuffer&gt;</code> | `es2023.array` |

### `Uint8ArrayConstructor`

类别：interface。来源：`es2015.iterable`、`es2017.typedarrays`、`es5`、`esnext.typedarrays`。

```ts
interface Uint8ArrayConstructor { ... }
```

声明来源：`es2015.iterable`、`es2017.typedarrays`、`es5`、`esnext.typedarrays`。

| 成员签名 | 来源 |
| --- | --- |
| <code>from(arrayLike: ArrayLike&lt;number&gt;): Uint8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>from(elements: Iterable&lt;number&gt;): Uint8Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>from&lt;T&gt;(arrayLike: ArrayLike&lt;T&gt;, mapfn: (v: T, k: number) =&gt; number, thisArg?: any): Uint8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>from&lt;T&gt;(elements: Iterable&lt;T&gt;, mapfn?: (v: T, k: number) =&gt; number, thisArg?: any): Uint8Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>fromBase64(string: string, options?: { alphabet?: "base64" &#124; "base64url" &#124; undefined; lastChunkHandling?: "loose" &#124; "strict" &#124; "stop-before-partial" &#124; undefined; }): Uint8Array&lt;ArrayBuffer&gt;</code> | `esnext.typedarrays` |
| <code>fromHex(string: string): Uint8Array&lt;ArrayBuffer&gt;</code> | `esnext.typedarrays` |
| <code>new (): Uint8Array&lt;ArrayBuffer&gt;</code> | `es2017.typedarrays` |
| <code>new (array: ArrayLike&lt;number&gt; &#124; ArrayBuffer): Uint8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (array: ArrayLike&lt;number&gt;): Uint8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (buffer: ArrayBuffer, byteOffset?: number, length?: number): Uint8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (elements: Iterable&lt;number&gt;): Uint8Array&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>new (length: number): Uint8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new &lt;TArrayBuffer extends ArrayBufferLike = ArrayBuffer&gt;(buffer: TArrayBuffer, byteOffset?: number, length?: number): Uint8Array&lt;TArrayBuffer&gt;</code> | `es5` |
| <code>of(...items: number[]): Uint8Array&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es5` |
| <code>readonly prototype: Uint8Array&lt;ArrayBufferLike&gt;</code> | `es5` |

### `Uint8ClampedArray`

类别：interface。来源：`es2015.core`、`es2015.iterable`、`es2022.array`、`es2023.array`、`es5`。

```ts
interface Uint8ClampedArray<TArrayBuffer extends ArrayBufferLike> { ... }
```

声明来源：`es2015.core`、`es2015.iterable`、`es2022.array`、`es2023.array`。

```ts
interface Uint8ClampedArray<TArrayBuffer extends ArrayBufferLike = ArrayBufferLike> { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>[index: number]: number</code> | `es5` |
| <code>[Symbol.iterator](): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>at(index: number): number &#124; undefined</code> | `es2022.array` |
| <code>copyWithin(target: number, start: number, end?: number): this</code> | `es5` |
| <code>entries(): ArrayIterator&lt;[ number, number ]&gt;</code> | `es2015.iterable` |
| <code>every(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>fill(value: number, start?: number, end?: number): this</code> | `es5` |
| <code>filter(predicate: (value: number, index: number, array: this) =&gt; any, thisArg?: any): Uint8ClampedArray&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>find(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number &#124; undefined</code> | `es5` |
| <code>findIndex(predicate: (value: number, index: number, obj: this) =&gt; boolean, thisArg?: any): number</code> | `es5` |
| <code>findLast(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number &#124; undefined</code> | `es2023.array` |
| <code>findLast&lt;S extends number&gt;(predicate: (value: number, index: number, array: this) =&gt; value is S, thisArg?: any): S &#124; undefined</code> | `es2023.array` |
| <code>findLastIndex(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): number</code> | `es2023.array` |
| <code>forEach(callbackfn: (value: number, index: number, array: this) =&gt; void, thisArg?: any): void</code> | `es5` |
| <code>indexOf(searchElement: number, fromIndex?: number): number</code> | `es5` |
| <code>join(separator?: string): string</code> | `es5` |
| <code>keys(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>lastIndexOf(searchElement: number, fromIndex?: number): number</code> | `es5` |
| <code>map(callbackfn: (value: number, index: number, array: this) =&gt; number, thisArg?: any): Uint8ClampedArray&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>readonly buffer: TArrayBuffer</code> | `es5` |
| <code>readonly byteLength: number</code> | `es5` |
| <code>readonly byteOffset: number</code> | `es5` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es5` |
| <code>readonly length: number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es5` |
| <code>reduce(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es5` |
| <code>reduce&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number, initialValue: number): number</code> | `es5` |
| <code>reduceRight(callbackfn: (previousValue: number, currentValue: number, currentIndex: number, array: this) =&gt; number): number</code> | `es5` |
| <code>reduceRight&lt;U&gt;(callbackfn: (previousValue: U, currentValue: number, currentIndex: number, array: this) =&gt; U, initialValue: U): U</code> | `es5` |
| <code>reverse(): this</code> | `es5` |
| <code>set(array: ArrayLike&lt;number&gt;, offset?: number): void</code> | `es5` |
| <code>slice(start?: number, end?: number): Uint8ClampedArray&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>some(predicate: (value: number, index: number, array: this) =&gt; unknown, thisArg?: any): boolean</code> | `es5` |
| <code>sort(compareFn?: (a: number, b: number) =&gt; number): this</code> | `es5` |
| <code>subarray(begin?: number, end?: number): Uint8ClampedArray&lt;TArrayBuffer&gt;</code> | `es5` |
| <code>toLocaleString(): string</code> | `es5` |
| <code>toLocaleString(locales: string &#124; string[], options?: Intl.NumberFormatOptions): string</code> | `es2015.core` |
| <code>toReversed(): Uint8ClampedArray&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toSorted(compareFn?: (a: number, b: number) =&gt; number): Uint8ClampedArray&lt;ArrayBuffer&gt;</code> | `es2023.array` |
| <code>toString(): string</code> | `es5` |
| <code>valueOf(): this</code> | `es5` |
| <code>values(): ArrayIterator&lt;number&gt;</code> | `es2015.iterable` |
| <code>with(index: number, value: number): Uint8ClampedArray&lt;ArrayBuffer&gt;</code> | `es2023.array` |

### `Uint8ClampedArrayConstructor`

类别：interface。来源：`es2015.iterable`、`es2017.typedarrays`、`es5`。

```ts
interface Uint8ClampedArrayConstructor { ... }
```

声明来源：`es2015.iterable`、`es2017.typedarrays`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>from(arrayLike: ArrayLike&lt;number&gt;): Uint8ClampedArray&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>from(elements: Iterable&lt;number&gt;): Uint8ClampedArray&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>from&lt;T&gt;(arrayLike: ArrayLike&lt;T&gt;, mapfn: (v: T, k: number) =&gt; number, thisArg?: any): Uint8ClampedArray&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>from&lt;T&gt;(elements: Iterable&lt;T&gt;, mapfn?: (v: T, k: number) =&gt; number, thisArg?: any): Uint8ClampedArray&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>new (): Uint8ClampedArray&lt;ArrayBuffer&gt;</code> | `es2017.typedarrays` |
| <code>new (array: ArrayLike&lt;number&gt; &#124; ArrayBuffer): Uint8ClampedArray&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (array: ArrayLike&lt;number&gt;): Uint8ClampedArray&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (buffer: ArrayBuffer, byteOffset?: number, length?: number): Uint8ClampedArray&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new (elements: Iterable&lt;number&gt;): Uint8ClampedArray&lt;ArrayBuffer&gt;</code> | `es2015.iterable` |
| <code>new (length: number): Uint8ClampedArray&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>new &lt;TArrayBuffer extends ArrayBufferLike = ArrayBuffer&gt;(buffer: TArrayBuffer, byteOffset?: number, length?: number): Uint8ClampedArray&lt;TArrayBuffer&gt;</code> | `es5` |
| <code>of(...items: number[]): Uint8ClampedArray&lt;ArrayBuffer&gt;</code> | `es5` |
| <code>readonly BYTES_PER_ELEMENT: number</code> | `es5` |
| <code>readonly prototype: Uint8ClampedArray&lt;ArrayBufferLike&gt;</code> | `es5` |

### `Uncapitalize`

类别：type。来源：`es5`。

```ts
type Uncapitalize<S extends string> = intrinsic;
```

定义来源：`es5`。

### `Uppercase`

类别：type。来源：`es5`。

```ts
type Uppercase<S extends string> = intrinsic;
```

定义来源：`es5`。

### `URIError`

类别：interface。来源：`es5`。

```ts
interface URIError extends Error { ... }
```

声明来源：`es5`。

### `URIErrorConstructor`

类别：interface。来源：`es2022.error`、`es5`。

```ts
interface URIErrorConstructor { ... }
```

声明来源：`es2022.error`。

```ts
interface URIErrorConstructor extends ErrorConstructor { ... }
```

声明来源：`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>(message?: string, options?: ErrorOptions): URIError</code> | `es2022.error` |
| <code>(message?: string): URIError</code> | `es5` |
| <code>new (message?: string, options?: ErrorOptions): URIError</code> | `es2022.error` |
| <code>new (message?: string): URIError</code> | `es5` |
| <code>readonly prototype: URIError</code> | `es5` |

### `WeakKey`

类别：type。来源：`es5`。

```ts
type WeakKey = WeakKeyTypes[keyof WeakKeyTypes];
```

定义来源：`es5`。

### `WeakKeyTypes`

类别：interface。来源：`es2023.collection`、`es5`。

```ts
interface WeakKeyTypes { ... }
```

声明来源：`es2023.collection`、`es5`。

| 成员签名 | 来源 |
| --- | --- |
| <code>object: object</code> | `es5` |
| <code>symbol: symbol</code> | `es2023.collection` |

### `WeakMap`

类别：interface。来源：`es2015.collection`、`es2015.iterable`、`esnext.collection`。

```ts
interface WeakMap<K extends WeakKey, V> { ... }
```

声明来源：`es2015.collection`、`es2015.iterable`、`esnext.collection`。

| 成员签名 | 来源 |
| --- | --- |
| <code>delete(key: K): boolean</code> | `es2015.collection` |
| <code>get(key: K): V &#124; undefined</code> | `es2015.collection` |
| <code>getOrInsert(key: K, defaultValue: V): V</code> | `esnext.collection` |
| <code>getOrInsertComputed(key: K, callback: (key: K) =&gt; V): V</code> | `esnext.collection` |
| <code>has(key: K): boolean</code> | `es2015.collection` |
| <code>set(key: K, value: V): this</code> | `es2015.collection` |

### `WeakMapConstructor`

类别：interface。来源：`es2015.collection`、`es2015.iterable`。

```ts
interface WeakMapConstructor { ... }
```

声明来源：`es2015.collection`、`es2015.iterable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>new &lt;K extends WeakKey = WeakKey, V = any&gt;(entries?: readonly (readonly [ K, V ])[] &#124; null): WeakMap&lt;K, V&gt;</code> | `es2015.collection` |
| <code>new &lt;K extends WeakKey = WeakKey, V = any&gt;(iterable?: Iterable&lt;readonly [ K, V ]&gt; &#124; null): WeakMap&lt;K, V&gt;</code> | `es2015.iterable` |
| <code>readonly prototype: WeakMap&lt;WeakKey, any&gt;</code> | `es2015.collection` |

### `WeakRef`

类别：interface。来源：`es2021.weakref`。

```ts
interface WeakRef<T extends WeakKey> { ... }
```

声明来源：`es2021.weakref`。

| 成员签名 | 来源 |
| --- | --- |
| <code>deref(): T &#124; undefined</code> | `es2021.weakref` |
| <code>readonly [Symbol.toStringTag]: "WeakRef"</code> | `es2021.weakref` |

### `WeakRefConstructor`

类别：interface。来源：`es2021.weakref`。

```ts
interface WeakRefConstructor { ... }
```

声明来源：`es2021.weakref`。

| 成员签名 | 来源 |
| --- | --- |
| <code>new &lt;T extends WeakKey&gt;(target: T): WeakRef&lt;T&gt;</code> | `es2021.weakref` |
| <code>readonly prototype: WeakRef&lt;any&gt;</code> | `es2021.weakref` |

### `WeakSet`

类别：interface。来源：`es2015.collection`、`es2015.iterable`。

```ts
interface WeakSet<T extends WeakKey> { ... }
```

声明来源：`es2015.collection`、`es2015.iterable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>add(value: T): this</code> | `es2015.collection` |
| <code>delete(value: T): boolean</code> | `es2015.collection` |
| <code>has(value: T): boolean</code> | `es2015.collection` |

### `WeakSetConstructor`

类别：interface。来源：`es2015.collection`、`es2015.iterable`。

```ts
interface WeakSetConstructor { ... }
```

声明来源：`es2015.collection`、`es2015.iterable`。

| 成员签名 | 来源 |
| --- | --- |
| <code>new &lt;T extends WeakKey = WeakKey&gt;(iterable: Iterable&lt;T&gt;): WeakSet&lt;T&gt;</code> | `es2015.iterable` |
| <code>new &lt;T extends WeakKey = WeakKey&gt;(values?: readonly T[] &#124; null): WeakSet&lt;T&gt;</code> | `es2015.collection` |
| <code>readonly prototype: WeakSet&lt;WeakKey&gt;</code> | `es2015.collection` |
