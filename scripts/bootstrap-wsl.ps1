[CmdletBinding()]
param(
    [string]$Distro = "Ubuntu-22.04",
    [int]$ProxyPort = 0,
    [string]$LlvmMirror = "https://apt.llvm.org"
)

$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
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
    throw "wsl.exe was not found."
}

function LastCleanLine([object[]]$Lines) {
    $Value = $Lines |
        ForEach-Object { ([string]$_ -replace "`0", "").Trim() } |
        Where-Object { $_ } |
        Select-Object -Last 1
    return [string]$Value
}

if ($Root -notmatch '^(?<Drive>[A-Za-z]):(?<Path>.*)$') {
    throw "Repository path is not a Windows drive path: $Root"
}
$WslRoot = "/mnt/$($Matches.Drive.ToLowerInvariant())$($Matches.Path -replace '\\', '/')"
$Wsl = ResolveWslExecutable

$Environment = @("env", "LLVM_APT_BASE=$LlvmMirror")
if ($ProxyPort -gt 0) {
    $Gateway = LastCleanLine @(& $Wsl -d $Distro -u root -- sh -c "ip route show default | sed -n 's/^default via \([^ ]*\).*/\1/p'" 2>$null)
    if (-not $Gateway) { throw "Could not determine the WSL gateway for proxy port $ProxyPort." }
    $Environment += "TS2BIN_PROXY=http://${Gateway}:$ProxyPort"
}

& $Wsl -d $Distro -u root -- @Environment bash --noprofile --norc "$WslRoot/scripts/bootstrap-wsl.sh"
if ($LASTEXITCODE -ne 0) { throw "WSL bootstrap failed with exit code $LASTEXITCODE." }
