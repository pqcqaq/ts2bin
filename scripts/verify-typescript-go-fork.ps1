[CmdletBinding()]
param(
    [switch]$SkipFullTests,
    [switch]$UseLocalCheckout
)

$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$lock = Get-Content -LiteralPath (Join-Path $repositoryRoot "ts2bin.lock.json") -Raw | ConvertFrom-Json
$commitPattern = '^[0-9a-f]{40}$'
$gitCommand = Get-Command git -ErrorAction Stop
$goCommand = Get-Command go -ErrorAction Stop

if ($lock.schemaVersion -ne 2 -or $lock.lockFormat -ne "ts2bin.lock.v2") {
    throw "unsupported ts2bin lock schema"
}
if ($null -ne $lock.typescriptGo.patch) {
    throw "legacy typescript-go patch metadata is not supported"
}
$forkCommit = [string]$lock.typescriptGo.forkCommit
$upstreamCommit = [string]$lock.typescriptGo.upstreamCommit
$forkRemote = [string]$lock.typescriptGo.forkRemote
if ([string]$lock.typescriptGo.reproducibilityStatus -ne "pinned-fork-commit" -or
    [string]$lock.typescriptGo.commit -ne $forkCommit -or
    $forkCommit -notmatch $commitPattern -or
    $upstreamCommit -notmatch $commitPattern -or
    [string]::IsNullOrWhiteSpace($forkRemote)) {
    throw "typescript-go fork metadata is invalid"
}
$observedGoVersion = (& $goCommand.Source version).Trim()
$expectedGoVersionPrefix = "go version go$($lock.toolchains.go) "
if (-not $observedGoVersion.StartsWith($expectedGoVersionPrefix, [StringComparison]::Ordinal)) {
    throw "Go toolchain mismatch: expected $($lock.toolchains.go), observed $observedGoVersion"
}

$build = $lock.toolchains.replayBuild
if ($null -eq $build -or
    [string]$build.goos -ne "windows" -or
    [string]$build.goarch -ne "amd64" -or
    [string]$build.goamd64 -ne "v1" -or
    [string]$build.cgoEnabled -ne "0" -or
    [string]$build.goenv -ne "off" -or
    [string]$build.goflags -ne "" -or
    [string]$build.gowork -ne "off" -or
    [string]$build.gotoolchain -ne "go$($lock.toolchains.go)" -or
    [string]$build.goexperiment -ne "" -or
    [string]$build.gofips140 -ne "off" -or
    [string]$build.godebug -ne "") {
    throw "locked replay build environment is invalid"
}
$fetchSource = if ($UseLocalCheckout) {
    Join-Path $repositoryRoot "typescript-go"
} else {
    $forkRemote
}
if ($UseLocalCheckout) {
    $localCommit = (& $gitCommand.Source -C $fetchSource rev-parse HEAD).Trim()
    $localChanges = @(& $gitCommand.Source -C $fetchSource status --porcelain --untracked-files=all)
    if ($LASTEXITCODE -ne 0 -or $localCommit -ne $forkCommit -or $localChanges.Count -ne 0) {
        throw "local typescript-go checkout must be clean at locked fork commit $forkCommit"
    }
    & $gitCommand.Source -C $fetchSource merge-base --is-ancestor $upstreamCommit $forkCommit
    if ($LASTEXITCODE -ne 0) {
        throw "local fork history does not contain locked upstream commit $upstreamCommit"
    }
}

$temporaryBase = Join-Path (Split-Path -Parent $repositoryRoot) ".ts2bin-tmp"
$temporaryRoot = Join-Path $temporaryBase ("ts2bin-tsgo-fork-" + [guid]::NewGuid().ToString("N"))
$isolatedCheckout = Join-Path $temporaryRoot "typescript-go"
$goTemporaryRoot = Join-Path $temporaryRoot "go-tmp"
$goCacheRoot = Join-Path $temporaryRoot "go-cache"

function Remove-TemporaryTree([string]$Path) {
    $resolvedPath = [IO.Path]::GetFullPath($Path)
    $resolvedTempBase = [IO.Path]::GetFullPath($temporaryBase).TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
    $expectedPrefix = $resolvedTempBase + [IO.Path]::DirectorySeparatorChar
    $leaf = [IO.Path]::GetFileName($resolvedPath)
    if (-not $resolvedPath.StartsWith($expectedPrefix, [StringComparison]::OrdinalIgnoreCase) -or
        $leaf -notmatch '^ts2bin-tsgo-fork-[0-9a-f]{32}$') {
        throw "refusing to remove unexpected temporary path: $resolvedPath"
    }
    if (-not [IO.Directory]::Exists($resolvedPath)) { return }

    $deletePath = $resolvedPath
    if ($IsWindows -and -not $deletePath.StartsWith('\\?\', [StringComparison]::Ordinal)) {
        if ($deletePath.StartsWith('\\', [StringComparison]::Ordinal)) {
            $deletePath = '\\?\UNC\' + $deletePath.Substring(2)
        } else {
            $deletePath = '\\?\' + $deletePath
        }
    }
    try {
        [IO.Directory]::Delete($deletePath, $true)
        return
    } catch {
        if (-not [IO.Directory]::Exists($deletePath)) { return }
    }
    foreach ($file in [IO.Directory]::EnumerateFiles($deletePath, '*', [IO.SearchOption]::AllDirectories)) {
        [IO.File]::SetAttributes($file, [IO.FileAttributes]::Normal)
    }
    for ($attempt = 1; $attempt -le 5; $attempt++) {
        try {
            [IO.Directory]::Delete($deletePath, $true)
            return
        } catch {
            if ($attempt -eq 5) { throw }
            Start-Sleep -Milliseconds (200 * $attempt)
        }
    }
}

try {
    New-Item -ItemType Directory -Path $temporaryBase -Force | Out-Null
    New-Item -ItemType Directory -Path $temporaryRoot | Out-Null
    New-Item -ItemType Directory -Path $goTemporaryRoot, $goCacheRoot | Out-Null
    & $gitCommand.Source -c core.longpaths=true init --quiet $isolatedCheckout
    if ($LASTEXITCODE -ne 0) {
        throw "failed to initialize isolated fork checkout"
    }
    & $gitCommand.Source -c core.longpaths=true -C $isolatedCheckout fetch --quiet --no-tags --depth=64 -- $fetchSource $forkCommit
    if ($LASTEXITCODE -ne 0) {
        throw "failed to fetch locked fork commit $forkCommit from $fetchSource"
    }
    & $gitCommand.Source -c core.longpaths=true -C $isolatedCheckout checkout --quiet --detach FETCH_HEAD
    if ($LASTEXITCODE -ne 0) {
        throw "failed to checkout locked fork commit"
    }
    $fetchedCommit = (& $gitCommand.Source -C $isolatedCheckout rev-parse HEAD).Trim()
    if ($fetchedCommit -ne $forkCommit) {
        throw "fetched commit mismatch: expected $forkCommit, observed $fetchedCommit"
    }
    & $gitCommand.Source -C $isolatedCheckout merge-base --is-ancestor $upstreamCommit $forkCommit
    $ancestryExitCode = $LASTEXITCODE
    $ancestryOk = $ancestryExitCode -eq 0
    if (-not $ancestryOk) {
        $isShallowOutput = @(& $gitCommand.Source -C $isolatedCheckout rev-parse --is-shallow-repository)
        $shallowExitCode = $LASTEXITCODE
        $isShallow = [string]($isShallowOutput | Select-Object -First 1)
        $isShallow = $isShallow.Trim()
        if ($shallowExitCode -ne 0 -or $isShallow -notin @("true", "false")) {
            throw "failed to determine whether fork history is shallow"
        }
        if ($isShallow -eq "true") {
            & $gitCommand.Source -c core.longpaths=true -C $isolatedCheckout fetch --quiet --no-tags --unshallow -- $fetchSource $forkCommit
            $unshallowExitCode = $LASTEXITCODE
            if ($unshallowExitCode -ne 0) {
                throw "failed to deepen fork history for upstream ancestry verification"
            }
            & $gitCommand.Source -C $isolatedCheckout merge-base --is-ancestor $upstreamCommit $forkCommit
            $ancestryExitCode = $LASTEXITCODE
            $ancestryOk = $ancestryExitCode -eq 0
            if ($ancestryExitCode -gt 1) {
                throw "failed to verify fork/upstream ancestry after deepening history (git exit $ancestryExitCode)"
            }
        } elseif ($ancestryExitCode -gt 1) {
            throw "failed to verify fork/upstream ancestry (git exit $ancestryExitCode)"
        }
    }
    if (-not $ancestryOk) {
        throw "fork history does not contain locked upstream commit $upstreamCommit"
    }

    $buildEnvironment = @{
        GOENV        = [string]$build.goenv
        GOFLAGS      = [string]$build.goflags
        GOWORK       = [string]$build.gowork
        GOTOOLCHAIN  = [string]$build.gotoolchain
        GOOS         = [string]$build.goos
        GOARCH       = [string]$build.goarch
        GOAMD64      = [string]$build.goamd64
        CGO_ENABLED  = [string]$build.cgoEnabled
        GOEXPERIMENT = [string]$build.goexperiment
        GOFIPS140    = [string]$build.gofips140
        GODEBUG      = [string]$build.godebug
        GOTMPDIR     = $goTemporaryRoot
        GOCACHE      = $goCacheRoot
    }
    $previousEnvironment = @{}
    $locationPushed = $false
    try {
        foreach ($name in $buildEnvironment.Keys) {
            $previousEnvironment[$name] = [Environment]::GetEnvironmentVariable($name, "Process")
            [Environment]::SetEnvironmentVariable($name, $buildEnvironment[$name], "Process")
        }
        Push-Location -LiteralPath $isolatedCheckout
        $locationPushed = $true
        & $goCommand.Source test -mod=readonly ./cmd/ts2bin ./internal/tsfrontend ./internal/ast2bingo ./internal/bingo -count=1
        if ($LASTEXITCODE -ne 0) {
            throw "isolated fork smoke tests failed"
        }
        if (-not $SkipFullTests) {
            & $goCommand.Source test -mod=readonly -p 1 ./... -count=1
            if ($LASTEXITCODE -ne 0) {
                throw "isolated fork full Go test suite failed"
            }
            & $goCommand.Source vet -mod=readonly -p 1 ./...
            if ($LASTEXITCODE -ne 0) {
                throw "isolated fork go vet failed"
            }
        }
    } finally {
        if ($locationPushed) { Pop-Location }
        foreach ($name in $previousEnvironment.Keys) {
            [Environment]::SetEnvironmentVariable($name, $previousEnvironment[$name], "Process")
        }
    }

    Write-Host "Verified locked typescript-go fork commit: $forkCommit"
    Write-Host "fetch source: $fetchSource"
    Write-Host "upstream baseline: $upstreamCommit"
    Write-Host "go target: $($build.goos)/$($build.goarch) $($build.goamd64) cgo=$($build.cgoEnabled)"
} finally {
    Remove-TemporaryTree $temporaryRoot
}
