[CmdletBinding()]
param(
    [string]$OutputPath = "typescript-go/built/local/ts2bin-replay.exe"
)

$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$sourceCheckout = Join-Path $repositoryRoot "typescript-go"
$lockPath = Join-Path $repositoryRoot "ts2bin.lock.json"
$lock = Get-Content -LiteralPath $lockPath -Raw | ConvertFrom-Json
$commitPattern = '^[0-9a-f]{40}$'
$goCommand = Get-Command go -ErrorAction Stop
$gitCommand = Get-Command git -ErrorAction Stop

if ($lock.schemaVersion -ne 2 -or $lock.lockFormat -ne "ts2bin.lock.v2") {
    throw "unsupported ts2bin lock schema"
}
if ([string]$lock.typescriptGo.reproducibilityStatus -ne "pinned-fork-commit") {
    throw "typescript-go is not configured as a pinned fork commit"
}
if ($null -ne $lock.typescriptGo.patch) {
    throw "legacy typescript-go patch metadata is not supported"
}

$lockedCommit = [string]$lock.typescriptGo.commit
$upstreamCommit = [string]$lock.typescriptGo.upstreamCommit
$forkCommit = [string]$lock.typescriptGo.forkCommit
$forkRemote = [string]$lock.typescriptGo.forkRemote
if ($lockedCommit -notmatch $commitPattern -or
    $upstreamCommit -notmatch $commitPattern -or
    $forkCommit -notmatch $commitPattern -or
    $lockedCommit -ne $forkCommit -or
    [string]::IsNullOrWhiteSpace($forkRemote)) {
    throw "typescript-go fork identity metadata is invalid"
}

$observedGoVersion = (& $goCommand.Source version).Trim()
$expectedGoVersionPrefix = "go version go$($lock.toolchains.go) "
if (-not $observedGoVersion.StartsWith($expectedGoVersionPrefix, [StringComparison]::Ordinal)) {
    throw "Go toolchain mismatch: expected $($lock.toolchains.go), observed $observedGoVersion"
}

$checkoutCommit = (& $gitCommand.Source -C $sourceCheckout rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $checkoutCommit -ne $forkCommit) {
    throw "typescript-go checkout mismatch: expected $forkCommit, observed $checkoutCommit"
}
$gitlinkOutput = @(& $gitCommand.Source -C $repositoryRoot ls-files --stage -- typescript-go)
$gitlinkExitCode = $LASTEXITCODE
$gitlinkLine = $gitlinkOutput | Select-Object -First 1
if ($gitlinkExitCode -ne 0 -or $gitlinkLine -notmatch '^160000\s+([0-9a-f]{40})\s+\d+\s+typescript-go$' -or $Matches[1] -ne $forkCommit) {
    throw "parent gitlink does not pin typescript-go fork commit $forkCommit"
}
$configuredSubmoduleOutput = @(& $gitCommand.Source config -f (Join-Path $repositoryRoot ".gitmodules") --get submodule.typescript-go.url)
$configuredSubmoduleExitCode = $LASTEXITCODE
$configuredSubmoduleRemote = $configuredSubmoduleOutput | Select-Object -First 1
$checkoutForkOutput = @(& $gitCommand.Source -C $sourceCheckout remote get-url origin)
$checkoutForkExitCode = $LASTEXITCODE
$checkoutForkRemote = $checkoutForkOutput | Select-Object -First 1
if ($configuredSubmoduleExitCode -ne 0 -or $checkoutForkExitCode -ne 0 -or $configuredSubmoduleRemote -ne $forkRemote -or $checkoutForkRemote -ne $forkRemote) {
    throw "typescript-go fork remote does not match the lock"
}
$checkoutChanges = @(& $gitCommand.Source -C $sourceCheckout status --porcelain --untracked-files=all)
if ($LASTEXITCODE -ne 0 -or $checkoutChanges.Count -ne 0) {
    throw "typescript-go checkout must be clean before building the locked fork"
}
& $gitCommand.Source -C $sourceCheckout merge-base --is-ancestor $upstreamCommit $forkCommit
if ($LASTEXITCODE -ne 0) {
    throw "locked upstream commit $upstreamCommit is not an ancestor of fork commit $forkCommit"
}

$build = $lock.toolchains.replayBuild
if ($null -eq $build -or
    [string]$build.goos -notmatch '^[a-z0-9]+$' -or
    [string]$build.goarch -notmatch '^[a-z0-9]+$' -or
    [string]$build.goamd64 -notmatch '^v[1-4]$' -or
    [string]$build.cgoEnabled -notmatch '^[01]$' -or
    [string]$build.goenv -ne "off" -or
    [string]$build.goflags -ne "" -or
    [string]$build.gowork -ne "off" -or
    [string]$build.gotoolchain -ne "go$($lock.toolchains.go)" -or
    [string]$build.goexperiment -ne "" -or
    [string]$build.gofips140 -ne "off" -or
    [string]$build.godebug -ne "") {
    throw "locked replay build environment is invalid"
}

$resolvedOutput = if ([IO.Path]::IsPathRooted($OutputPath)) {
    [IO.Path]::GetFullPath($OutputPath)
} else {
    [IO.Path]::GetFullPath((Join-Path $repositoryRoot $OutputPath))
}
if ([IO.Directory]::Exists($resolvedOutput)) {
    throw "output path is a directory: $resolvedOutput"
}

$temporaryBase = Join-Path (Split-Path -Parent $repositoryRoot) ".ts2bin-tmp"
$temporaryRoot = Join-Path $temporaryBase ("ts2bin-replay-build-" + [guid]::NewGuid().ToString("N"))
$isolatedCheckout = Join-Path $temporaryRoot "typescript-go"
$goTemporaryRoot = Join-Path $temporaryRoot "go-tmp"
$goCacheRoot = Join-Path $temporaryRoot "go-cache"

function Remove-TemporaryTree([string]$Path) {
    $resolvedPath = [IO.Path]::GetFullPath($Path)
    $resolvedTempBase = [IO.Path]::GetFullPath($temporaryBase).TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
    $expectedPrefix = $resolvedTempBase + [IO.Path]::DirectorySeparatorChar
    $leaf = [IO.Path]::GetFileName($resolvedPath)
    if (-not $resolvedPath.StartsWith($expectedPrefix, [StringComparison]::OrdinalIgnoreCase) -or
        $leaf -notmatch '^ts2bin-replay-build-[0-9a-f]{32}$') {
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
    & $gitCommand.Source -c core.longpaths=true clone --quiet --no-hardlinks --no-checkout -- $sourceCheckout $isolatedCheckout
    if ($LASTEXITCODE -ne 0) {
        throw "failed to create isolated fork checkout"
    }
    & $gitCommand.Source -c core.longpaths=true -C $isolatedCheckout checkout --quiet --detach $forkCommit
    if ($LASTEXITCODE -ne 0) {
        throw "failed to checkout locked fork commit $forkCommit"
    }
    & $gitCommand.Source -C $isolatedCheckout merge-base --is-ancestor $upstreamCommit $forkCommit
    if ($LASTEXITCODE -ne 0) {
        throw "isolated fork checkout does not contain locked upstream commit $upstreamCommit"
    }

    New-Item -ItemType Directory -Path (Split-Path -Parent $resolvedOutput) -Force | Out-Null
    $ldflags = @(
        "-X github.com/microsoft/typescript-go/internal/ast2bingo.injectedUpstreamCommit=$upstreamCommit",
        "-X github.com/microsoft/typescript-go/internal/ast2bingo.injectedForkCommit=$forkCommit"
    ) -join " "

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
        & $goCommand.Source build -mod=readonly -trimpath -buildvcs=false -ldflags $ldflags -o $resolvedOutput ./cmd/ts2bin-replay
        if ($LASTEXITCODE -ne 0) {
            throw "ts2bin-replay build failed"
        }
    } finally {
        if ($locationPushed) { Pop-Location }
        foreach ($name in $previousEnvironment.Keys) {
            [Environment]::SetEnvironmentVariable($name, $previousEnvironment[$name], "Process")
        }
    }

    $binarySHA256 = (Get-FileHash -LiteralPath $resolvedOutput -Algorithm SHA256).Hash.ToLowerInvariant()
    Write-Host "Built $resolvedOutput"
    Write-Host "binary sha256: $binarySHA256"
    Write-Host "compiler upstream: $upstreamCommit"
    Write-Host "compiler fork: $forkCommit"
    Write-Host "go target: $($build.goos)/$($build.goarch) $($build.goamd64) cgo=$($build.cgoEnabled)"
} finally {
    Remove-TemporaryTree $temporaryRoot
}
