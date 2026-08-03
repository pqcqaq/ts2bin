const fs = require("node:fs");
const path = require("node:path");

const libRoot = path.resolve(process.argv[2] ?? "../typescript-go/internal/bundled/libs");
const compilerPath = process.argv[3] ?? "typescript";
const outputPath = path.resolve(process.argv[4] ?? "stdlib/99-api-index.md");

let ts;
try {
  ts = require(compilerPath);
} catch (error) {
  console.error("Cannot load the TypeScript compiler API.");
  console.error("Pass its package directory as the second argument after the lib root.");
  throw error;
}

const isLibraryFile = (name) =>
  name === "lib.es5.d.ts" ||
  /^lib\.es\d{4}\.[^.]+\.d\.ts$/u.test(name) ||
  /^lib\.esnext\.[^.]+\.d\.ts$/u.test(name);

const files = fs.readdirSync(libRoot)
  .filter(isLibraryFile)
  .sort((a, b) => a.localeCompare(b, "en"));

const declarations = new Map();
const globals = [];
const printer = ts.createPrinter({ removeComments: true });

function sourceLabel(fileName) {
  return fileName.replace(/^lib\./u, "").replace(/\.d\.ts$/u, "");
}

function compact(text) {
  return text.replace(/\s+/gu, " ").replace(/\s*;$/u, "").trim();
}

function nodeName(node, sourceFile) {
  if (!node.name) return "(anonymous)";
  return compact(node.name.getText(sourceFile));
}

function declarationKey(prefix, name) {
  return prefix ? `${prefix}.${name}` : name;
}

function ensureDeclaration(key, kind) {
  let entry = declarations.get(key);
  if (!entry) {
    entry = { key, kind, sources: new Set(), headers: new Map(), members: new Map(), definitions: new Map() };
    declarations.set(key, entry);
  }
  return entry;
}

function addMember(entry, member, sourceFile, label) {
  const signature = compact(printer.printNode(ts.EmitHint.Unspecified, member, sourceFile));
  const key = `${nodeName(member, sourceFile)}\0${signature}`;
  const existing = entry.members.get(key);
  if (existing) existing.sources.add(label);
  else entry.members.set(key, { signature, sources: new Set([label]) });
}

function addHeader(entry, statement, sourceFile, label, terminator) {
  const text = statement.getText(sourceFile);
  const end = text.indexOf(terminator);
  const header = compact(end >= 0 ? text.slice(0, end) : text);
  const sources = entry.headers.get(header) ?? new Set();
  sources.add(label);
  entry.headers.set(header, sources);
  return header;
}

function visitStatements(statements, prefix, sourceFile, label) {
  for (const statement of statements) {
    if (ts.isInterfaceDeclaration(statement) || ts.isClassDeclaration(statement)) {
      if (!statement.name) continue;
      const key = declarationKey(prefix, statement.name.text);
      const kind = ts.isInterfaceDeclaration(statement) ? "interface" : "class";
      const entry = ensureDeclaration(key, kind);
      entry.sources.add(label);
      addHeader(entry, statement, sourceFile, label, "{");
      for (const member of statement.members) addMember(entry, member, sourceFile, label);
      continue;
    }

    if (ts.isTypeAliasDeclaration(statement)) {
      const key = declarationKey(prefix, statement.name.text);
      const entry = ensureDeclaration(key, "type");
      entry.sources.add(label);
      const header = addHeader(entry, statement, sourceFile, label, "=");
      const definition = compact(statement.type.getText(sourceFile));
      const definitionKey = `${header}\0${definition}`;
      const existing = entry.definitions.get(definitionKey);
      if (existing) existing.sources.add(label);
      else entry.definitions.set(definitionKey, { header, definition, sources: new Set([label]) });
      continue;
    }

    if (ts.isFunctionDeclaration(statement) && statement.name) {
      globals.push({
        key: declarationKey(prefix, statement.name.text),
        kind: "function",
        signature: compact(printer.printNode(ts.EmitHint.Unspecified, statement, sourceFile)),
        source: label,
      });
      continue;
    }

    if (ts.isVariableStatement(statement)) {
      for (const declaration of statement.declarationList.declarations) {
        globals.push({
          key: declarationKey(prefix, nodeName(declaration, sourceFile)),
          kind: "value",
          signature: compact(printer.printNode(ts.EmitHint.Unspecified, declaration, sourceFile)),
          source: label,
        });
      }
      continue;
    }

    if (ts.isModuleDeclaration(statement)) {
      const moduleName = nodeName(statement, sourceFile).replace(/^['"]|['"]$/gu, "");
      let body = statement.body;
      let nestedPrefix = declarationKey(prefix, moduleName);
      while (body && ts.isModuleDeclaration(body)) {
        nestedPrefix = declarationKey(nestedPrefix, nodeName(body, sourceFile));
        body = body.body;
      }
      if (body && ts.isModuleBlock(body)) {
        visitStatements(body.statements, nestedPrefix, sourceFile, label);
      }
    }
  }
}

for (const fileName of files) {
  const filePath = path.join(libRoot, fileName);
  const sourceText = fs.readFileSync(filePath, "utf8");
  const sourceFile = ts.createSourceFile(fileName, sourceText, ts.ScriptTarget.Latest, true);
  visitStatements(sourceFile.statements, "", sourceFile, sourceLabel(fileName));
}

const lines = [
  "# ECMAScript 标准库 API 完整索引",
  "",
  "> 此文件由 `scripts/generate-stdlib-index.cjs` 从本地 `typescript-go/internal/bundled/libs` 生成。它是声明签名清单，不代替分组教程。聚合文件、DOM、WebWorker 和 ScriptHost 已排除。",
  "",
  `- 输入文件：${files.length} 个实际声明分项`,
  `- 声明类型：${declarations.size} 个`,
  `- 全局/命名空间值签名：${globals.length} 个`,
  "",
  "## 全局与命名空间值",
  "",
  "| 名称 | 类别 | 签名 | 来源 |",
  "| --- | --- | --- | --- |",
];

const escapeCell = (value) => value
  .replace(/&/gu, "&amp;")
  .replace(/</gu, "&lt;")
  .replace(/>/gu, "&gt;")
  .replace(/\|/gu, "&#124;");

for (const item of globals.sort((a, b) => a.key.localeCompare(b.key, "en") || a.signature.localeCompare(b.signature, "en"))) {
  lines.push(`| \`${escapeCell(item.key)}\` | ${item.kind} | <code>${escapeCell(item.signature)}</code> | \`${item.source}\` |`);
}

lines.push("", "## 类型与成员", "");

for (const entry of [...declarations.values()].sort((a, b) => a.key.localeCompare(b.key, "en"))) {
  lines.push(`### \`${entry.key}\``, "");
  lines.push(`类别：${entry.kind}。来源：${[...entry.sources].sort().map((x) => `\`${x}\``).join("、")}。`, "");

  for (const [header, sources] of entry.headers) {
    if (entry.kind !== "type") {
      lines.push("```ts", `${header} { ... }`, "```", "");
      lines.push(`声明来源：${[...sources].sort().map((x) => `\`${x}\``).join("、")}。`, "");
    }
  }

  for (const { header, definition, sources } of entry.definitions.values()) {
    lines.push("```ts", `${header} = ${definition};`, "```", "");
    lines.push(`定义来源：${[...sources].sort().map((x) => `\`${x}\``).join("、")}。`, "");
  }

  if (entry.members.size > 0) {
    lines.push("| 成员签名 | 来源 |", "| --- | --- |");
    for (const member of [...entry.members.values()].sort((a, b) => a.signature.localeCompare(b.signature, "en"))) {
      lines.push(`| <code>${escapeCell(member.signature)}</code> | ${[...member.sources].sort().map((x) => `\`${x}\``).join("、")} |`);
    }
    lines.push("");
  }
}

fs.mkdirSync(path.dirname(outputPath), { recursive: true });
fs.writeFileSync(outputPath, `${lines.join("\n")}\n`, "utf8");
console.log(`Generated ${outputPath}`);
console.log(`${declarations.size} declarations, ${globals.length} global/value signatures`);
