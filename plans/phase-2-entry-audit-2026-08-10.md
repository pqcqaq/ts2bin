# Phase 2 准入复审（2026-08-10）

> Historical entry audit. All P2A entry items described here were subsequently closed. Current status and Phase 3 sequencing live in [implementation-backlog.md](implementation-backlog.md) and [phase3-entry-and-hardening.md](phase3-entry-and-hardening.md).

## 结论

现有编译器方向保持合理，P2A 应继续按 number-only Linux x86-64 真实 LLVM 纵切推进，不需要重写总体架构。复审发现的四项准入缺口必须在进入 P2A 实现前关闭：frontend 阶段门禁可绕过、Linux/WSL 无原生 doctor、P2A 验收命令无任务归属、父仓库无自身 CI。它们属于交付与计划闭环问题，不是 HIR/TargetContext/MIR 分层错误。

## 保持不变的边界

1. `FrontendSnapshot` 与 typed HIR 保持 target-independent；`BuildPlan` 保持 unresolved。
2. resolver 只消费 `BuildPlan` 与 toolchain/runtime manifests，LLVM `TargetMachine` 的 `DataLayout` 是唯一权威来源。
3. verified HIR 与 target facts 第一次 join 发生在 `RepresentationPlan`，不能让 resolver 语义消费 HIR。
4. `BoundCapabilityClosure` 从 structural MIR 精确生成，不能直接复制 AvailableCapabilityCatalog。
5. `VERT-001` 前只接受 `number` 加法纵切；对象、字符串、GC、EH、async、模块和第二目标不进入 P2A。

## 准入整改

| 缺口 | 复审判断 | 关闭方式 |
| --- | --- | --- |
| frontend gate 可由 `--runner` 指向单一 Go test 绕过 | 确认，违反完整 stage registry 契约 | 删除 runner override；`test --stage frontend` 固定调用仓库 runner，并以负向单测锁定 |
| `doctor` 仅能调用 PowerShell | 确认，无法支撑 BE-001 的 Linux/WSL 环境 | 按 OS 选择 `doctor.ps1` / `doctor.sh`；两端统一检查 lock、fork/gitlink/provenance 与 stdlib closure |
| `emit-hir` / `emit-mir` / `static-core` 无实现归属 | 确认，完整 `IR-008` 又位于纵切之后 | 新增 `IR-008a` 拥有 first-slice IR CLI；`REL-001a` 拥有 `static-core` 并依赖 `IR-008a` |
| 父仓库无 CI | 确认，上游子模块的 Azure 配置不能代表 ts2bin | 增加 Windows frontend、Linux replay closure、远端 fork delivery 三项基线 workflow |
| README 仍称 `FND-004a` 阻塞 | 确认，与 backlog/roadmap/交付事实冲突 | 统一为已完成，并明确下一步是 `BE-001a` 与 `RT-002a` |

## P2A 顺序

```text
BE-001a || RT-002a
       -> TC-001a
       -> IR-004a -> IR-005a -> IR-008a
       -> RT-002b + BE-002a -> BE-004a
       -> REL-001a -> VERT-001 -> REL-002a
```

P2A 开始时只能并行领取 `BE-001a` 与 `RT-002a`。阶段验收命令可以提前写入计划，但只有对应 owner 完成后才能存在并通过；在 MIR 尚未实现时增加假的 `emit-mir` 或空 pass 会破坏 fail-closed 契约。

## 准入证据

进入 P2A 前必须同时满足：父仓库与子模块 clean；lock/gitlink/fork commit 闭合；Windows frontend registry 全量通过；当前 frontend/replay core 的 test 与 vet 通过；replay dependency closure 不含 AST/checker/parser；Windows 与 Linux doctor 路径均有测试，实际可用环境的 doctor 通过；fork commit 可从远端独立获取；父仓库 workflow 已提交到 `main`。
