[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$lockPath = Join-Path $repositoryRoot "ts2bin.lock.json"
$checkoutPath = Join-Path $repositoryRoot "typescript-go"
$lock = Get-Content -LiteralPath $lockPath -Raw | ConvertFrom-Json
$commitPattern = '^[0-9a-fA-F]{40,64}$'
if ($lock.schemaVersion -ne 2 -or $lock.lockFormat -ne "ts2bin.lock.v2") {
    throw "unsupported ts2bin lock schema"
}
if ($null -eq $lock.typescriptGo.patch) {
    throw "typescript-go patch metadata is missing; FND-004 is not configured"
}
if ([string]$lock.typescriptGo.upstreamCommit -notmatch $commitPattern -or
    [string]$lock.typescriptGo.patch.baseCommit -ne [string]$lock.typescriptGo.upstreamCommit) {
    throw "typescript-go patch base/upstream commit metadata is invalid"
}
$patchRoot = [IO.Path]::GetFullPath((Join-Path $repositoryRoot "patches\typescript-go"))
$patchPath = [IO.Path]::GetFullPath((Join-Path $repositoryRoot ([string]$lock.typescriptGo.patch.path)))
if (-not $patchPath.StartsWith($patchRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw "typescript-go patch path escapes patches/typescript-go"
}

if (-not (Test-Path -LiteralPath $patchPath -PathType Leaf)) {
    throw "typescript-go patch is missing: $patchPath"
}

if (-not (Test-Path -LiteralPath (Join-Path $checkoutPath ".git"))) {
    git -C $repositoryRoot submodule update --init -- typescript-go
    if ($LASTEXITCODE -ne 0) {
        throw "failed to initialize typescript-go submodule"
    }
}

$head = (git -C $checkoutPath rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $head -ne $lock.typescriptGo.upstreamCommit) {
    throw "typescript-go checkout must be at locked upstream commit $($lock.typescriptGo.upstreamCommit); observed $head"
}

$dirty = git -C $checkoutPath status --porcelain
if ($LASTEXITCODE -ne 0) {
    throw "failed to inspect typescript-go checkout"
}
if ($dirty) {
    throw "typescript-go checkout is not clean; refusing to apply the locked patch"
}

$observedPatchHash = (Get-FileHash -LiteralPath $patchPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($observedPatchHash -ne ([string]$lock.typescriptGo.patch.sha256).ToLowerInvariant()) {
    throw "typescript-go patch hash mismatch: expected $($lock.typescriptGo.patch.sha256), observed $observedPatchHash"
}

git -C $checkoutPath apply --check --whitespace=error-all -- $patchPath
if ($LASTEXITCODE -ne 0) {
    throw "locked typescript-go patch does not apply cleanly"
}

git -C $checkoutPath apply --whitespace=error-all -- $patchPath
if ($LASTEXITCODE -ne 0) {
    throw "failed to apply locked typescript-go patch"
}

Write-Host "Materialized typescript-go patch $observedPatchHash on $head"
