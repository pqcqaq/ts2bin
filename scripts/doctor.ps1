[CmdletBinding()]
param(
    [switch]$Quiet
)

$ErrorActionPreference = "Continue"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Lock = Get-Content (Join-Path $Root "ts2bin.lock.json") -Raw | ConvertFrom-Json
$Failures = [System.Collections.Generic.List[string]]::new()

function Report([string]$Name, [bool]$Ok, [string]$Detail) {
    if ($Ok) {
        if (-not $Quiet) { Write-Host ("[ok]   {0}: {1}" -f $Name, $Detail) -ForegroundColor Green }
    } else {
        $Failures.Add($Name)
        Write-Host ("[FAIL] {0}: {1}" -f $Name, $Detail) -ForegroundColor Red
    }
}

function CommandVersion([string]$Name, [string[]]$Arguments = @()) {
    $Command = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $Command) { return $null }
    try { return (& $Command.Source @Arguments 2>$null | Select-Object -First 1).ToString().Trim() } catch { return $null }
}

function CheckVersion([string]$Name, [string]$Command, [string[]]$Arguments, [string]$ExpectedPrefix) {
    $Value = CommandVersion $Command $Arguments
    Report $Name ($null -ne $Value -and $Value -match [regex]::Escape($ExpectedPrefix)) ($Value ?? "command not found; expected $ExpectedPrefix")
}

function ResolveWslExecutable {
    $Candidates = @(
        (Join-Path $env:WINDIR "System32\wsl.exe"),
        (Join-Path $env:ProgramFiles "WSL\wsl.exe")
    )
    foreach ($Candidate in $Candidates) {
        if (Test-Path -LiteralPath $Candidate) { return $Candidate }
    }
    $Command = Get-Command wsl.exe -ErrorAction SilentlyContinue
    if ($Command) { return $Command.Source }
    return $null
}

function GetCanonicalTreeHash([string]$Path) {
    $Resolved = (Resolve-Path -LiteralPath $Path).Path
    $Files = @(Get-ChildItem -LiteralPath $Resolved -File -Recurse | Sort-Object {
        [IO.Path]::GetRelativePath($Resolved, $_.FullName).Replace('\', '/')
    })
    $Hash = [Security.Cryptography.IncrementalHash]::CreateHash([Security.Cryptography.HashAlgorithmName]::SHA256)
    $Utf8 = [Text.UTF8Encoding]::new($false)
    [long]$TotalBytes = 0
    try {
        foreach ($File in $Files) {
            $Relative = [IO.Path]::GetRelativePath($Resolved, $File.FullName).Replace('\', '/')
            $Hash.AppendData($Utf8.GetBytes($Relative))
            $Hash.AppendData([byte[]](0))
            $Stream = [IO.File]::OpenRead($File.FullName)
            try {
                $Buffer = [byte[]]::new(65536)
                while (($Read = $Stream.Read($Buffer, 0, $Buffer.Length)) -gt 0) {
                    $Hash.AppendData($Buffer, 0, $Read)
                    $TotalBytes += $Read
                }
            } finally { $Stream.Dispose() }
            $Hash.AppendData([byte[]](0))
        }
        return [pscustomobject]@{
            Sha256 = [Convert]::ToHexString($Hash.GetHashAndReset()).ToLowerInvariant()
            FileCount = $Files.Count
            TotalBytes = $TotalBytes
        }
    } finally { $Hash.Dispose() }
}

function GetWorktreePatchHash([string]$CheckoutPath) {
    $temporaryRoot = Join-Path ([IO.Path]::GetTempPath()) ("ts2bin-doctor-" + [guid]::NewGuid().ToString("N"))
    $temporaryIndex = Join-Path $temporaryRoot "index"
    $temporaryPatch = Join-Path $temporaryRoot "worktree.patch"
    $previousIndex = $env:GIT_INDEX_FILE
    try {
        New-Item -ItemType Directory -Path $temporaryRoot -Force | Out-Null
        $env:GIT_INDEX_FILE = $temporaryIndex
        & git -c core.longpaths=true -C $CheckoutPath read-tree HEAD 2>$null
        if ($LASTEXITCODE -ne 0) { return $null }
        & git -c core.longpaths=true -C $CheckoutPath add -A -- . 2>$null
        if ($LASTEXITCODE -ne 0) { return $null }

        $git = (Get-Command git -ErrorAction Stop).Source
        $startInfo = [Diagnostics.ProcessStartInfo]::new()
        $startInfo.FileName = $git
        $startInfo.UseShellExecute = $false
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        $startInfo.Environment["GIT_INDEX_FILE"] = $temporaryIndex
        foreach ($argument in @(
            "-c", "core.longpaths=true", "-C", $CheckoutPath, "diff", "--cached", "--binary", "--full-index",
            "--no-ext-diff", "--no-renames", "--src-prefix=a/", "--dst-prefix=b/"
        )) { $startInfo.ArgumentList.Add($argument) }
        $process = [Diagnostics.Process]::Start($startInfo)
        $output = [IO.File]::Create($temporaryPatch)
        try { $process.StandardOutput.BaseStream.CopyTo($output) } finally { $output.Dispose() }
        $process.StandardError.ReadToEnd() | Out-Null
        $process.WaitForExit()
        if ($process.ExitCode -ne 0) { return $null }
        return (Get-FileHash -LiteralPath $temporaryPatch -Algorithm SHA256).Hash.ToLowerInvariant()
    } finally {
        if ($null -eq $previousIndex) { Remove-Item Env:GIT_INDEX_FILE -ErrorAction SilentlyContinue }
        else { $env:GIT_INDEX_FILE = $previousIndex }
        if (Test-Path -LiteralPath $temporaryRoot) { Remove-Item -LiteralPath $temporaryRoot -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

if (-not $Quiet) { Write-Host "ts2bin toolchain doctor" -ForegroundColor Cyan; Write-Host "root: $Root" }
Report "lock schema" ($Lock.schemaVersion -eq 2 -and $Lock.lockFormat -eq "ts2bin.lock.v2") ("schema={0}; format={1}" -f $Lock.schemaVersion, $Lock.lockFormat)
CheckVersion "Go" "go" @("version") ("go" + $Lock.toolchains.go)
CheckVersion "Node" "node" @("--version") ("v" + $Lock.toolchains.node)
CheckVersion "npm" "npm.cmd" @("--version") $Lock.toolchains.npm
CheckVersion "Rust" "rustc" @("--version") ("rustc " + $Lock.toolchains.rust)
CheckVersion "Cargo" "cargo" @("--version") ("cargo " + $Lock.toolchains.rust)
CheckVersion "Clang" "clang" @("--version") ("clang version " + $Lock.toolchains.llvmWindows)
CheckVersion "LLD" "lld-link" @("--version") ("LLD " + $Lock.toolchains.llvmWindows)
CheckVersion "CMake" "cmake" @("--version") "cmake version "
CheckVersion "Ninja" "ninja" @("--version") ""

$Git = Get-Command git -ErrorAction SilentlyContinue
if ($Git) {
    $LockedCommit = [string]$Lock.typescriptGo.commit
    $GitlinkLine = (& $Git.Source -C $Root ls-files --stage -- typescript-go 2>$null | Select-Object -First 1)
    $GitlinkCommit = $null
    if ($GitlinkLine -match '^160000\s+([0-9a-fA-F]{40,64})\s+\d+\s+typescript-go$') {
        $GitlinkCommit = $Matches[1].ToLowerInvariant()
    }
    $CheckoutCommit = (& $Git.Source -C (Join-Path $Root "typescript-go") rev-parse HEAD 2>$null | Select-Object -First 1)
    if ($CheckoutCommit) { $CheckoutCommit = $CheckoutCommit.Trim().ToLowerInvariant() }

    $CommitPattern = '^[0-9a-f]{40,64}$'
    Report "typescript-go lock" ($LockedCommit -match $CommitPattern) ($LockedCommit ?? "missing or invalid commit")
    Report "typescript-go parent gitlink" ($null -ne $GitlinkCommit) ($GitlinkCommit ?? "missing 160000 gitlink entry")
    Report "typescript-go checkout" ($CheckoutCommit -match $CommitPattern) ($CheckoutCommit ?? "unable to resolve HEAD")
    $Closed = (
        $LockedCommit -match $CommitPattern -and
        $null -ne $GitlinkCommit -and
        $CheckoutCommit -match $CommitPattern -and
        $LockedCommit.ToLowerInvariant() -eq $GitlinkCommit -and
        $LockedCommit.ToLowerInvariant() -eq $CheckoutCommit
    )
    $ClosureDetail = "gitlink={0}; checkout={1}; lock={2}" -f ($GitlinkCommit ?? "missing"), ($CheckoutCommit ?? "missing"), ($LockedCommit ?? "missing")
    Report "typescript-go revision closure" $Closed $ClosureDetail

    $PatchState = "unconfigured"
    $PatchDetail = "lock has no patch metadata"
    $PatchConfigured = $null -ne $Lock.typescriptGo.patch
    $MetadataOk = $false
    if ($PatchConfigured) {
        $PatchPath = Join-Path $Root ([string]$Lock.typescriptGo.patch.path)
        $PatchRoot = [IO.Path]::GetFullPath((Join-Path $Root "patches\typescript-go"))
        $ResolvedPatchPath = [IO.Path]::GetFullPath($PatchPath)
        $PathOk = $ResolvedPatchPath.StartsWith($PatchRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)
        $PatchExists = Test-Path -LiteralPath $PatchPath -PathType Leaf
        $PatchHash = $null
        if ($PatchExists) {
            $PatchHash = (Get-FileHash -LiteralPath $PatchPath -Algorithm SHA256).Hash.ToLowerInvariant()
        }
        $PatchHashOk = $PatchExists -and $PatchHash -eq ([string]$Lock.typescriptGo.patch.sha256).ToLowerInvariant()
        $MetadataOk = $PathOk -and $PatchHashOk -and
            [string]$Lock.typescriptGo.patch.baseCommit -eq [string]$Lock.typescriptGo.upstreamCommit -and
            [string]$Lock.typescriptGo.patch.sha256 -match '^[0-9a-fA-F]{64}$'
        $CheckoutPath = Join-Path $Root "typescript-go"
        $DirtyLines = @(git -C $CheckoutPath status --porcelain --untracked-files=all 2>$null)
        $WorktreeHash = if ($MetadataOk) { GetWorktreePatchHash $CheckoutPath } else { $null }
        if (-not $DirtyLines) {
            $PatchState = "clean-upstream"
            $PatchDetail = "checkout is clean at the locked upstream base"
        } elseif ($MetadataOk -and $WorktreeHash -eq ([string]$Lock.typescriptGo.patch.sha256).ToLowerInvariant()) {
            $PatchState = "materialized-exact"
            $PatchDetail = "worktree diff matches the locked patch hash"
        } else {
            $PatchState = "divergent"
            $PatchDetail = "worktree diff does not match the locked patch"
        }
    }
    $MetadataDetail = if ($PatchConfigured) {
        "path={0}; metadata={1}" -f ([string]$Lock.typescriptGo.patch.path), $MetadataOk
    } else {
        "lock has no patch metadata"
    }
    Report "typescript-go patch metadata" $MetadataOk $MetadataDetail
    Report "typescript-go patch state" ($PatchState -eq "materialized-exact") ("state={0}; {1}" -f $PatchState, $PatchDetail)
    Report "typescript-go reproducibility" ([string]$Lock.typescriptGo.reproducibilityStatus -eq "reproducible-patch" -and $PatchState -eq "materialized-exact") ("status={0}; state={1}" -f ([string]$Lock.typescriptGo.reproducibilityStatus), $PatchState)
} else { Report "git" $false "command not found" }

$VersionSource = Join-Path $Root "typescript-go\internal\core\version.go"
$VersionText = Get-Content -LiteralPath $VersionSource -Raw -ErrorAction SilentlyContinue
$SourceVersion = $null
if ($VersionText -match 'var\s+version\s*=\s*"([^"]+)"') { $SourceVersion = $Matches[1] }
Report "TypeScript version" ($SourceVersion -eq [string]$Lock.typescriptGo.version) ($SourceVersion ?? "unable to read internal/core/version.go")

try {
    $Stdlib = GetCanonicalTreeHash (Join-Path $Root "typescript-go\internal\bundled\libs")
    $StdlibOk = (
        $Lock.typescriptGo.stdlib.hashAlgorithm -eq "sha256-path-nul-content-nul-v1" -and
        $Stdlib.Sha256 -eq [string]$Lock.typescriptGo.stdlib.sha256 -and
        $Stdlib.FileCount -eq [int]$Lock.typescriptGo.stdlib.fileCount -and
        $Stdlib.TotalBytes -eq [long]$Lock.typescriptGo.stdlib.totalBytes
    )
    Report "bundled stdlib" $StdlibOk ("files={0}; bytes={1}; sha256={2}" -f $Stdlib.FileCount, $Stdlib.TotalBytes, $Stdlib.Sha256)
} catch {
    Report "bundled stdlib" $false $_.Exception.Message
}

$VsWhere = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $VsWhere) {
    $VsPath = (& $VsWhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath 2>$null | Select-Object -First 1).Trim()
    Report "MSVC tools" (-not [string]::IsNullOrWhiteSpace($VsPath)) ($VsPath ?? "VC tools component not found")
    $SdkPath = (& $VsWhere -latest -products * -requires Microsoft.VisualStudio.Component.Windows11SDK.26100 -property installationPath 2>$null | Select-Object -First 1).Trim()
    Report "Windows SDK" (-not [string]::IsNullOrWhiteSpace($SdkPath)) ($SdkPath ?? "Windows 11 SDK 26100 component not found")
} else { Report "Visual Studio" $false "vswhere.exe not found" }

$Wsl = ResolveWslExecutable
if ($Wsl) {
    $WslDistro = $Lock.toolchains.wslDistro
    & $Wsl -d $WslDistro -u root -- true 2>$null
    if ($LASTEXITCODE -eq 0) {
        $WslChecks = @(
            @{ Name = "WSL LLVM"; Command = "llvm-config-20"; Args = @("--version"); Expected = "20." },
            @{ Name = "WSL Clang"; Command = "clang-20"; Args = @("--version"); Expected = "20." },
            @{ Name = "WSL LLD"; Command = "ld.lld-20"; Args = @("--version"); Expected = "LLD 20" },
            @{ Name = "WSL Go"; Command = "go"; Args = @("version"); Expected = "go" + $Lock.toolchains.go },
            @{ Name = "WSL Node"; Command = "node"; Args = @("--version"); Expected = "v" + $Lock.toolchains.node },
            @{ Name = "WSL npm"; Command = "npm"; Args = @("--version"); Expected = $Lock.toolchains.npm },
            @{ Name = "WSL Rust"; Command = "rustc"; Args = @("--version"); Expected = "rustc " + $Lock.toolchains.rust },
            @{ Name = "WSL Cargo"; Command = "cargo"; Args = @("--version"); Expected = "cargo " + $Lock.toolchains.rust }
        )
        foreach ($Check in $WslChecks) {
            $Value = (& $Wsl -d $WslDistro -u root -- bash --noprofile --norc -c ("{0} {1}" -f $Check.Command, ($Check.Args -join " ")) 2>$null | Select-Object -First 1).Trim()
            Report $Check.Name ($Value -match [regex]::Escape($Check.Expected)) ($Value ?? "missing in $WslDistro")
        }
    } else { Report "WSL Ubuntu" $false "$WslDistro is unavailable" }
} else { Report "WSL" $false "wsl.exe not found" }

if ($Failures.Count -eq 0) {
    if (-not $Quiet) { Write-Host "All required toolchain checks passed." -ForegroundColor Green }
    exit 0
}
Write-Host ("{0} check(s) failed." -f $Failures.Count) -ForegroundColor Red
exit 1
