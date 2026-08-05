# 资料来源与范围

## 官方资料

- [The TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- [Handbook v2](https://www.typescriptlang.org/docs/handbook/2/basic-types.html)
- [Reference](https://www.typescriptlang.org/docs/handbook/utility-types.html)
- [Declaration Files](https://www.typescriptlang.org/docs/handbook/declaration-files/introduction.html)
- [TSConfig Reference](https://www.typescriptlang.org/tsconfig/)
- [Release Notes](https://www.typescriptlang.org/docs/handbook/release-notes/overview.html)
- [TypeScript-Website 仓库](https://github.com/microsoft/TypeScript-Website)
- [TypeScript 7 原生端仓库](https://github.com/microsoft/typescript-go)

整理时使用的官方仓库提交为 `c8170c35bda4811c9516cbb69c39241ae4beb6d9`，提交时间为 2026-07-06。npm registry 在 2026-08-03 返回的 TypeScript 稳定版为 7.0.2。

当前 `handbook/stdlib/99-api-index.md` 最初由 `typescript-go` 提交 `5b1047d10`（2026-07-31）的 `internal/bundled/libs/` 生成，并排除了 DOM、WebWorker 与 ScriptHost 宿主 API。编译器当前锁已前移到 `12318e599d21f516defea3b20e5d44b9369da723`（`7.1.0-dev`）；因此该手册索引只能作为历史资料，发布/coverage 必须以 `ts2bin.lock.json` 的 stdlib hash 和 `FE-007`/`RT-001` 重新生成的 manifest 为准。

## 收录原则

1. 收录 JavaScript 中会直接影响 TypeScript 写法的核心语法。
2. 收录 TypeScript 的类型标注、类型构造、声明与运行时扩展语法。
3. 收录模块、JSX、声明文件、JSDoc 和常用编译选项，因为它们决定语法如何被解释。
4. 发布说明只抽取会影响源码写法的变化，不罗列编辑器、性能和内部 API 更新。
5. 旧式语法会标注为“兼容用途”或“已弃用”，不作为新项目首选。

## “所有语法”的边界

TypeScript 是 JavaScript 的带类型超集，完整 ECMAScript 标准本身远大于一份速查手册。本手册覆盖工程中可见的 TypeScript 语法面，以及与类型分析直接相关的 JavaScript 语法；DOM、Node.js、框架 API 和每个 `lib.d.ts` 的全部接口不属于语言语法，不逐项展开。

官方 Handbook 采用滚动更新，版本行为仍应以项目实际使用的 `tsc --version` 和对应 Release Notes 为准。
