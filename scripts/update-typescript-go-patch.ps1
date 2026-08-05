[CmdletBinding()]
param(
    [string]$OutputPath = "patches/typescript-go/ts2bin.patch"
)

$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$checkoutPath = Join-Path $repositoryRoot "typescript-go"
$lockPath = Join-Path $repositoryRoot "ts2bin.lock.json"
$lock = Get-Content -LiteralPath $lockPath -Raw | ConvertFrom-Json
$resolvedOutput = [IO.Path]::GetFullPath((Join-Path $repositoryRoot $OutputPath))
$patchRoot = [IO.Path]::GetFullPath((Join-Path $repositoryRoot "patches\typescript-go"))

if (-not $resolvedOutput.StartsWith($patchRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw "patch output must remain below $patchRoot"
}

$head = (git -C $checkoutPath rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $head -ne [string]$lock.typescriptGo.upstreamCommit) {
    throw "typescript-go HEAD must equal locked upstream commit $($lock.typescriptGo.upstreamCommit); observed $head"
}

$temporaryRoot = Join-Path ([IO.Path]::GetTempPath()) ("ts2bin-patch-build-" + [guid]::NewGuid().ToString("N"))
$temporaryIndex = Join-Path $temporaryRoot "index"
$temporaryPatch = Join-Path $temporaryRoot "typescript-go.patch"
$isolatedCheckout = Join-Path $temporaryRoot "verify"

function Remove-TemporaryTree([string]$Path) {
    $resolvedPath = [IO.Path]::GetFullPath($Path)
    $resolvedTempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    $leaf = [IO.Path]::GetFileName($resolvedPath)
    if (-not $resolvedPath.StartsWith($resolvedTempBase, [StringComparison]::OrdinalIgnoreCase) -or
        $leaf -notmatch '^ts2bin-patch-build-[0-9a-f]{32}$') {
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

function Invoke-IndexedGit([string[]]$Arguments) {
    $previousIndex = $env:GIT_INDEX_FILE
    try {
        $env:GIT_INDEX_FILE = $temporaryIndex
        & git -C $checkoutPath @Arguments
        if ($LASTEXITCODE -ne 0) {
            throw "git $($Arguments -join ' ') failed"
        }
    } finally {
        if ($null -eq $previousIndex) {
            Remove-Item Env:GIT_INDEX_FILE -ErrorAction SilentlyContinue
        } else {
            $env:GIT_INDEX_FILE = $previousIndex
        }
    }
}

function Write-IndexedDiff([string]$Path) {
    $git = (Get-Command git -ErrorAction Stop).Source
    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $git
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.Environment["GIT_INDEX_FILE"] = $temporaryIndex
    foreach ($argument in @(
        "-C", $checkoutPath, "diff", "--cached", "--binary", "--full-index",
        "--no-ext-diff", "--no-renames", "--src-prefix=a/", "--dst-prefix=b/"
    )) {
        $startInfo.ArgumentList.Add($argument)
    }
    $process = [Diagnostics.Process]::Start($startInfo)
    $output = [IO.File]::Create($Path)
    try {
        $process.StandardOutput.BaseStream.CopyTo($output)
    } finally {
        $output.Dispose()
    }
    $errorText = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    if ($process.ExitCode -ne 0) {
        throw "git diff failed: $errorText"
    }
}

try {
    New-Item -ItemType Directory -Path $temporaryRoot | Out-Null
    Invoke-IndexedGit @("read-tree", "HEAD")
    Invoke-IndexedGit @("add", "-A", "--", ".")
    Write-IndexedDiff $temporaryPatch

    if ((Get-Item -LiteralPath $temporaryPatch).Length -eq 0) {
        throw "typescript-go worktree has no patchable changes"
    }

    git -c core.longpaths=true clone --quiet --no-hardlinks --no-checkout -- $checkoutPath $isolatedCheckout
    if ($LASTEXITCODE -ne 0) {
        throw "failed to create isolated verification clone"
    }
    git -c core.longpaths=true -C $isolatedCheckout checkout --quiet --detach $lock.typescriptGo.upstreamCommit
    if ($LASTEXITCODE -ne 0) {
        throw "failed to checkout locked upstream commit in verification clone"
    }
    git -c core.longpaths=true -C $isolatedCheckout apply --check --whitespace=error-all -- $temporaryPatch
    if ($LASTEXITCODE -ne 0) {
        throw "generated patch does not apply cleanly to the locked upstream commit"
    }

    New-Item -ItemType Directory -Path (Split-Path -Parent $resolvedOutput) -Force | Out-Null
    Move-Item -LiteralPath $temporaryPatch -Destination $resolvedOutput -Force
    $hash = (Get-FileHash -LiteralPath $resolvedOutput -Algorithm SHA256).Hash.ToLowerInvariant()
    Write-Host "Updated $resolvedOutput"
    Write-Host "sha256: $hash"
    Write-Host "base: $head"
} finally {
    Remove-TemporaryTree $temporaryRoot
}
