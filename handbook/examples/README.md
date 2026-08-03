# 可编译示例

这里的文件对应正文各章，使用 `../tsconfig.json` 的严格选项统一检查。故意错误的行使用 `@ts-expect-error`，这样既能说明错误，又能验证编译器确实会拒绝它。

运行：

```powershell
npm run check
```

部分语法只负责类型检查，不会执行；装饰器、资源管理、JSX 和模块示例也不要求在 Node.js 中直接运行。
