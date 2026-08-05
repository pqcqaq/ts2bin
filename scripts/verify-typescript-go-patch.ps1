[CmdletBinding()]
param(
    [switch]$SkipFullTests
)

$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$sourceCheckout = Join-Path $repositoryRoot "typescript-go"
$lock = Get-Content -LiteralPath (Join-Path $repositoryRoot "ts2bin.lock.json") -Raw | ConvertFrom-Json
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
$patchRelativePath = [string]$lock.typescriptGo.patch.path
$patchRoot = [IO.Path]::GetFullPath((Join-Path $repositoryRoot "patches\typescript-go"))
$patchPath = [IO.Path]::GetFullPath((Join-Path $repositoryRoot $patchRelativePath))
if (-not $patchPath.StartsWith($patchRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw "typescript-go patch path escapes patches/typescript-go"
}
if (-not (Test-Path -LiteralPath $patchPath -PathType Leaf)) {
    throw "typescript-go patch is missing: $patchPath"
}
$observedPatchHash = (Get-FileHash -LiteralPath $patchPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($observedPatchHash -ne ([string]$lock.typescriptGo.patch.sha256).ToLowerInvariant()) {
    throw "typescript-go patch hash mismatch: expected $($lock.typescriptGo.patch.sha256), observed $observedPatchHash"
}
$cloneSource = [string]$lock.typescriptGo.forkRemote
if ([string]::IsNullOrWhiteSpace($cloneSource)) { $cloneSource = [string]$lock.typescriptGo.remote }
if ([string]::IsNullOrWhiteSpace($cloneSource)) { throw "typescript-go patch has no fetchable remote" }
$temporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("ts2bin-tsgo-patch-" + [guid]::NewGuid().ToString("N"))
$isolatedCheckout = Join-Path $temporaryRoot "typescript-go"

function Remove-TemporaryTree([string]$Path) {
    $resolvedPath = [System.IO.Path]::GetFullPath($Path)
    $resolvedTempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
    $leaf = [System.IO.Path]::GetFileName($resolvedPath)
    if (-not $resolvedPath.StartsWith($resolvedTempBase, [System.StringComparison]::OrdinalIgnoreCase) -or
        $leaf -notmatch '^ts2bin-tsgo-patch-[0-9a-f]{32}$') {
        throw "refusing to remove unexpected temporary path: $resolvedPath"
    }
    if (-not [System.IO.Directory]::Exists($resolvedPath)) { return }

    $deletePath = $resolvedPath
    if ($IsWindows -and -not $deletePath.StartsWith('\\?\', [System.StringComparison]::Ordinal)) {
        if ($deletePath.StartsWith('\\', [System.StringComparison]::Ordinal)) {
            $deletePath = '\\?\UNC\' + $deletePath.Substring(2)
        } else {
            $deletePath = '\\?\' + $deletePath
        }
    }
    try {
        [System.IO.Directory]::Delete($deletePath, $true)
        return
    } catch {
        if (-not [System.IO.Directory]::Exists($deletePath)) { return }
    }

    foreach ($file in [System.IO.Directory]::EnumerateFiles($deletePath, '*', [System.IO.SearchOption]::AllDirectories)) {
        [System.IO.File]::SetAttributes($file, [System.IO.FileAttributes]::Normal)
    }
    for ($attempt = 1; $attempt -le 5; $attempt++) {
        try {
            [System.IO.Directory]::Delete($deletePath, $true)
            return
        } catch {
            if ($attempt -eq 5) { throw }
            Start-Sleep -Milliseconds (200 * $attempt)
        }
    }
}

try {
    New-Item -ItemType Directory -Path $temporaryRoot | Out-Null
    git -c core.longpaths=true init --quiet $isolatedCheckout
    if ($LASTEXITCODE -ne 0) {
        throw "failed to initialize isolated typescript-go checkout"
    }
    git -c core.longpaths=true -C $isolatedCheckout fetch --quiet --no-tags --depth=1 -- $cloneSource $lock.typescriptGo.upstreamCommit
    if ($LASTEXITCODE -ne 0) {
        throw "failed to fetch locked upstream commit from $cloneSource"
    }

    git -c core.longpaths=true -C $isolatedCheckout checkout --quiet --detach FETCH_HEAD
    if ($LASTEXITCODE -ne 0) {
        throw "failed to checkout locked upstream commit"
    }
    $fetchedCommit = (git -C $isolatedCheckout rev-parse --verify HEAD).Trim()
    if ($LASTEXITCODE -ne 0 -or $fetchedCommit -ne [string]$lock.typescriptGo.upstreamCommit) {
        throw "fetched commit mismatch: expected $($lock.typescriptGo.upstreamCommit), observed $fetchedCommit"
    }

    git -c core.longpaths=true -C $isolatedCheckout apply --check --whitespace=error-all -- $patchPath
    if ($LASTEXITCODE -ne 0) {
        throw "locked patch does not apply to the isolated upstream checkout"
    }
    git -c core.longpaths=true -C $isolatedCheckout apply --whitespace=error-all -- $patchPath
    if ($LASTEXITCODE -ne 0) {
        throw "failed to apply locked patch to the isolated checkout"
    }

    Push-Location $isolatedCheckout
    go test ./cmd/ts2bin ./internal/tsfrontend -run "TestCanonicalBuildInfoJSONIsStableAndComplete|TestVersionJSONContainsLockedProvenance|TestSnapshotPreservesConfigOptionsWhenProfileIsNotOverridden|TestFrontendBuildProducesDeterministicValidatedSnapshot|TestRunSubsetGateCoversAnyUnknownAndUnsafeAssertions" -count=1
        if ($LASTEXITCODE -ne 0) {
            throw "isolated patch smoke tests failed"
        }

    if (-not $SkipFullTests) {
        go test ./... -count=1
        if ($LASTEXITCODE -ne 0) {
            throw "isolated full Go test suite failed"
        }
        go vet ./...
        if ($LASTEXITCODE -ne 0) {
            throw "isolated go vet failed"
        }
    }

    Write-Host "Verified locked typescript-go patch in isolated checkout: $observedPatchHash"
}
finally {
    if ((Get-Location).Path -eq $isolatedCheckout) {
        Pop-Location
    }
    Remove-TemporaryTree $temporaryRoot
}
