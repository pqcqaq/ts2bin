# 16. 编译配置

`tsconfig.json` 同时定义项目边界、类型检查、模块解析和输出方式。配置必须匹配真实运行时，不能只以“编译通过”为目标。

## 一份严格的应用配置

```jsonc
{
  "compilerOptions": {
    "target": "ES2024",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "lib": ["ES2024", "DOM", "DOM.Iterable"],

    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitOverride": true,
    "noFallthroughCasesInSwitch": true,
    "useUnknownInCatchVariables": true,

    "verbatimModuleSyntax": true,
    "isolatedModules": true,
    "noUncheckedSideEffectImports": true,
    "noEmit": true,

    "types": []
  },
  "include": ["src/**/*.ts", "src/**/*.tsx"]
}
```

这是打包器应用的起点，不是所有项目的万能配置。Node 服务、npm 库和只做类型检查的项目需要不同模块/输出选项。

## `target`、`lib`、运行时

| 概念 | 决定什么 | 不负责什么 |
| --- | --- | --- |
| `target` | 语法降级输出、默认 ES 库集合 | 不提供 polyfill |
| `lib` | 编译时可见的标准/宿主 API 声明 | 不安装或实现 API |
| 实际运行时 | 真正支持的语法和 API | 不自动告诉 TypeScript 类型 |

例如把 `lib` 加到 `ESNext` 会让 `Iterator#map` 通过类型检查，但旧 Node/浏览器上仍可能不存在该方法。需要升级运行时、转译或 polyfill。

常见 `lib`：

- `ES2024` / `ES2025` / `ESNext`：ECMAScript 内置 API。
- `DOM`、`DOM.Iterable`、`DOM.AsyncIterable`：浏览器 API。
- `WebWorker`：Worker 环境，不应与 DOM 无差别混用。
- `ESNext.Disposable`、`ESNext.Temporal`：可按功能单独启用的前沿声明。

完整 ES 内置类型见 [标准库总览](./stdlib/README.md)。

## 模块配置选择

### 打包器应用

```jsonc
{
  "module": "ESNext",
  "moduleResolution": "Bundler",
  "verbatimModuleSyntax": true,
  "noEmit": true
}
```

由 Vite、Rspack、webpack、esbuild 等处理输出。若打包器支持保留混合 ESM/CommonJS 语法，也可评估 `module: "Preserve"`。

### Node.js

```jsonc
{
  "module": "NodeNext",
  "moduleResolution": "NodeNext",
  "verbatimModuleSyntax": true,
  "types": ["node"]
}
```

`NodeNext` 随最新 Node 规则变化；需要固定 Node 语义时选择编译器支持的 `Node18`、`Node20` 等模式。文件后缀 `.mts`/`.cts`、输出 `.mjs`/`.cjs`、`package.json#type` 和导入后缀必须一致。

### npm 库

```jsonc
{
  "declaration": true,
  "declarationMap": true,
  "sourceMap": true,
  "outDir": "./dist",
  "rootDir": "./src",
  "stripInternal": true,
  "isolatedDeclarations": true
}
```

库还需要正确的 `exports`/`types` 映射与真实消费测试。是否同时发布 ESM/CJS 是包设计问题，不是打开一个选项就完成。

## 严格检查选项

`strict` 是一组选项的总开关，包括 `strictNullChecks`、`noImplicitAny`、`strictFunctionTypes`、`strictPropertyInitialization`、`useUnknownInCatchVariables` 等。TypeScript 6.0 起 `strict` 默认已为 `true`，但公共配置仍建议显式写出意图。

常用增强：

| 选项 | 捕获的问题 |
| --- | --- |
| `noUncheckedIndexedAccess` | 未知键/数组索引可能不存在 |
| `exactOptionalPropertyTypes` | “属性缺席”与“值为 undefined”的区别 |
| `noImplicitOverride` | 派生类覆盖意图不明确 |
| `noPropertyAccessFromIndexSignature` | 未知键误写成已知属性 |
| `noFallthroughCasesInSwitch` | `switch` 意外贯穿 |
| `noImplicitReturns` | 并非所有路径返回 |
| `allowUnreachableCode: false` | 明显不可达代码 |
| `allowUnusedLabels: false` | 错误标签 |

未使用变量/参数是否交给 TypeScript 或 lint 工具检查取决于团队工作流，避免重复且冲突的规则。

## 模块与隔离编译

- `verbatimModuleSyntax`：类型导入必须明确用 `type`，值导入按源码保留。
- `isolatedModules`：确保每个文件可单独转译，适配 Babel/SWC/打包器。
- `isolatedDeclarations`：确保声明可逐文件生成，公共 API 往往需要更多显式类型。
- `moduleDetection`：控制哪些文件被当作模块，现代项目常用 `force`。
- `allowImportingTsExtensions`：允许导入 `.ts` 后缀，通常要求不生成 JS 或由专门工具改写。
- `rewriteRelativeImportExtensions`：生成输出时改写相对 TypeScript 后缀，适用性取决于工具链。
- `resolveJsonModule`：为 JSON 导入生成类型。
- `customConditions`：加入包 `exports` 的自定义解析条件，必须与运行时/打包器一致。

## `erasableSyntaxOnly`

此选项保证源码中的 TypeScript 专属语法可通过“删除类型”得到 JavaScript，适合直接运行 TypeScript 的环境。会拒绝需要生成运行时代码的语法，例如：

- `enum`。
- 含运行时成员的 `namespace`。
- 构造函数参数属性。
- `import x = require(...)`、`export =` 等专属模块语法。

标准 JavaScript 类、`#private`、标准装饰器等是否可直接运行仍取决于目标运行时。开启该选项前先检查框架与发布格式。

## 文件范围

```jsonc
{
  "files": ["src/index.ts"],
  "include": ["src/**/*.ts", "tests/**/*.ts"],
  "exclude": ["dist", "coverage"]
}
```

- `files`：明确文件列表，适合很小的项目。
- `include`：glob 范围；通常是主要入口。
- `exclude`：只影响 `include` 的发现，不阻止被导入文件进入程序。
- `rootDir`：输出目录结构的源根，不是“只允许导入这里”的安全边界。
- `types`：加入全局范围的 `@types` 包列表，不影响正常模块导入解析。
- `typeRoots`：完全替换类型根目录搜索，通常不需要。

TypeScript 6.0 中 `rootDir` 默认改为 `tsconfig.json` 所在目录，`types` 默认改为 `[]`；依赖旧行为的项目要显式配置。

## JSX

| `jsx` 值 | 典型输出 |
| --- | --- |
| `preserve` | 保留 JSX 给后续工具处理 |
| `react-jsx` | 自动 JSX 运行时，开发以外常用 |
| `react-jsxdev` | 自动运行时的开发输出 |
| `react` | 旧式 `React.createElement` |
| `react-native` | 保留 JSX 且输出 `.js` |

`jsxImportSource` 指定自动运行时包。它也会影响 JSX 类型从哪个包读取。

## JavaScript 项目

```jsonc
{
  "allowJs": true,
  "checkJs": true,
  "maxNodeModuleJsDepth": 0,
  "noEmit": true
}
```

可用 `// @ts-check`、`// @ts-nocheck`、`// @ts-expect-error` 控制单文件/单行检查。迁移时从边界添加 JSDoc 和 `unknown`，不要一次性用大量 `any` 消除错误。

## 项目引用

根配置：

```jsonc
{
  "files": [],
  "references": [
    { "path": "./packages/core" },
    { "path": "./packages/app" }
  ]
}
```

被引用项目：

```jsonc
{
  "compilerOptions": {
    "composite": true,
    "declaration": true,
    "outDir": "./dist"
  }
}
```

使用 `tsc -b` 按依赖图构建，`tsc -b --clean` 清理构建产物。项目引用适合明确包边界和增量构建，但要与包管理器/workspace 的实际依赖保持一致。

## TypeScript 6.0 → 7.0 迁移

TypeScript 6.0 是原生 7.0 的过渡版本。应处理这些弃用项，而不是长期依赖 `ignoreDeprecations: "6.0"`：

- `target: es5` 与 `downlevelIteration`。
- `moduleResolution: node`/`node10`/`classic`。
- `module: amd`/`umd`/`system`。
- `baseUrl` 的旧式依赖方式。
- 显式关闭 `esModuleInterop` / `allowSyntheticDefaultImports`。
- `alwaysStrict: false`、`outFile`。
- 以 `module Name {}` 表示内部命名空间。
- 旧导入断言 `assert { ... }`，改用 `with { ... }`。
- 三斜线 `no-default-lib` 指令。

还要留意 6.0 新默认值：`strict: true`、`module: esnext`、浮动到当前 ES 的 `target`、`noUncheckedSideEffectImports: true`、`types: []`、`rootDir: .`。可复现构建最好显式固定关键选项。

## 常用命令

```powershell
tsc -p tsconfig.json
tsc -p tsconfig.json --noEmit
tsc -b
tsc --showConfig
tsc --explainFiles
tsc --traceResolution
```

排查优先顺序：先看 `--showConfig` 的最终合并结果，再用 `--explainFiles` 查文件为何进入项目，最后用 `--traceResolution` 查具体模块解析。

## 常见坑

- `skipLibCheck` 不是“忽略所有 node_modules 错误”；它主要跳过声明文件内部检查，应用代码使用这些类型时仍可能报错。
- `exclude` 不能阻止被 `import` 的文件进入项目。
- `paths` 不保证改写输出路径；运行时工具必须匹配。
- `ESNext` 会随编译器更新，不适合要求类型表面长期稳定的库基线。
- 不显式固定 TypeScript 版本与关键配置，会让 CI、本地和编辑器产生不同结果。
