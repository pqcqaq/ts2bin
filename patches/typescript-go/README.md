# typescript-go patch delivery

This directory is the temporary reproducible delivery mechanism for the thin
`typescript-go` fork until `FND-004` is replaced by an accessible fork commit.

The patch is based on upstream commit
`12318e599d21f516defea3b20e5d44b9369da723`. The repository lock records the
patch path and SHA-256 digest. Apply it only to a clean checkout at that exact
commit:

```powershell
.\scripts\materialize-typescript-go.ps1
```

When the thin fork changes, regenerate the artifact from the current
`typescript-go` worktree with a temporary Git index, then update the lock's
`typescriptGo.patch.sha256` value from the command output:

```powershell
.\scripts\update-typescript-go-patch.ps1
```

Verify the patch from an isolated clone of the upstream base:

```powershell
.\scripts\verify-typescript-go-patch.ps1
```

The generated patch is an audited artifact. Do not edit it by hand; regenerate
it from the intended `typescript-go` working tree and update the lock digest in
the same change.
