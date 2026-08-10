[CmdletBinding()]
param(
    [string]$Branch = "ts2bin/main"
)

$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$checkout = Join-Path $repositoryRoot "typescript-go"
$gitCommand = Get-Command git -ErrorAction Stop
$lock = Get-Content -LiteralPath (Join-Path $repositoryRoot "ts2bin.lock.json") -Raw | ConvertFrom-Json
$commitPattern = '^[0-9a-f]{40}$'

if ($lock.schemaVersion -ne 2 -or $lock.lockFormat -ne "ts2bin.lock.v2") {
    throw "unsupported ts2bin lock schema"
}
if ([string]$lock.typescriptGo.reproducibilityStatus -ne "pinned-fork-commit" -or $null -ne $lock.typescriptGo.patch) {
    throw "typescript-go is not configured as a patch-free pinned fork commit"
}
$lockedCommit = [string]$lock.typescriptGo.commit
$forkCommit = [string]$lock.typescriptGo.forkCommit
$upstreamCommit = [string]$lock.typescriptGo.upstreamCommit
$forkRemote = [string]$lock.typescriptGo.forkRemote
$upstreamRemote = [string]$lock.typescriptGo.remote
if ($lockedCommit -notmatch $commitPattern -or
    $forkCommit -notmatch $commitPattern -or
    $upstreamCommit -notmatch $commitPattern -or
    $lockedCommit -ne $forkCommit -or
    [string]::IsNullOrWhiteSpace($forkRemote) -or
    [string]::IsNullOrWhiteSpace($upstreamRemote)) {
    throw "typescript-go fork metadata is invalid"
}

$currentBranch = (& $gitCommand.Source -C $checkout branch --show-current).Trim()
if ($LASTEXITCODE -ne 0 -or $currentBranch -ne $Branch) {
    throw "typescript-go must be on fork branch $Branch; observed $currentBranch"
}
$currentCommit = (& $gitCommand.Source -C $checkout rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $currentCommit -ne $forkCommit) {
    throw "typescript-go HEAD must equal locked fork commit $forkCommit; observed $currentCommit"
}
$changes = @(& $gitCommand.Source -C $checkout status --porcelain --untracked-files=all)
if ($LASTEXITCODE -ne 0 -or $changes.Count -ne 0) {
    throw "typescript-go worktree must be clean before merging upstream"
}
$mergeHead = (& $gitCommand.Source -C $checkout rev-parse -q --verify MERGE_HEAD 2>$null | Select-Object -First 1)
if ($mergeHead) {
    throw "typescript-go already has a merge in progress"
}

$gitlinkOutput = @(& $gitCommand.Source -C $repositoryRoot ls-files --stage -- typescript-go)
$gitlinkExitCode = $LASTEXITCODE
$gitlinkLine = $gitlinkOutput | Select-Object -First 1
if ($gitlinkExitCode -ne 0 -or $gitlinkLine -notmatch '^160000\s+([0-9a-f]{40})\s+\d+\s+typescript-go$' -or $Matches[1] -ne $forkCommit) {
    throw "parent gitlink does not pin locked fork commit $forkCommit"
}
$configuredSubmoduleOutput = @(& $gitCommand.Source config -f (Join-Path $repositoryRoot ".gitmodules") --get submodule.typescript-go.url)
$configuredSubmoduleExitCode = $LASTEXITCODE
$configuredSubmoduleRemote = $configuredSubmoduleOutput | Select-Object -First 1
$originOutput = @(& $gitCommand.Source -C $checkout remote get-url origin)
$originExitCode = $LASTEXITCODE
$originRemote = $originOutput | Select-Object -First 1
if ($configuredSubmoduleExitCode -ne 0 -or $originExitCode -ne 0 -or $configuredSubmoduleRemote -ne $forkRemote -or $originRemote -ne $forkRemote) {
    throw "typescript-go origin/submodule URL does not match locked fork remote $forkRemote"
}

$remoteNames = @(& $gitCommand.Source -C $checkout remote)
if ($LASTEXITCODE -ne 0) {
    throw "failed to inspect typescript-go remotes"
}
if ($remoteNames -notcontains "upstream") {
    & $gitCommand.Source -C $checkout remote add upstream $upstreamRemote
    if ($LASTEXITCODE -ne 0) {
        throw "failed to add locked upstream remote $upstreamRemote"
    }
} else {
    $configuredUpstreamRemote = (& $gitCommand.Source -C $checkout remote get-url upstream | Select-Object -First 1)
    if ($LASTEXITCODE -ne 0 -or $configuredUpstreamRemote -ne $upstreamRemote) {
        throw "typescript-go upstream remote does not match lock: expected $upstreamRemote, observed $configuredUpstreamRemote"
    }
}

& $gitCommand.Source -C $checkout merge-base --is-ancestor $upstreamCommit $forkCommit
if ($LASTEXITCODE -ne 0) {
    throw "locked upstream commit $upstreamCommit is not an ancestor of fork commit $forkCommit"
}
$baselineSource = Get-Content -LiteralPath (Join-Path $checkout "internal\tsfrontend\baseline.go") -Raw
if ($baselineSource -notmatch 'TypeScriptGoUpstreamCommit\s*=\s*"([0-9a-f]{40})"' -or $Matches[1] -ne $upstreamCommit) {
    throw "TypeScriptGoUpstreamCommit does not match locked upstream commit $upstreamCommit"
}

& $gitCommand.Source -C $checkout fetch --prune upstream '+refs/heads/main:refs/remotes/upstream/main'
if ($LASTEXITCODE -ne 0) {
    throw "failed to fetch upstream/main"
}
$newUpstream = (& $gitCommand.Source -C $checkout rev-parse upstream/main).Trim()
if ($LASTEXITCODE -ne 0 -or $newUpstream -notmatch $commitPattern) {
    throw "failed to resolve fetched upstream/main"
}
& $gitCommand.Source -C $checkout merge-base --is-ancestor $upstreamCommit $newUpstream
if ($LASTEXITCODE -ne 0) {
    throw "fetched upstream/main $newUpstream does not descend from locked upstream $upstreamCommit"
}
$headAncestryExitCode = 0
& $gitCommand.Source -C $checkout merge-base --is-ancestor $newUpstream HEAD
$headAncestryExitCode = $LASTEXITCODE
if ($headAncestryExitCode -gt 1) {
    throw "failed to verify whether fork HEAD contains upstream/main (git exit $headAncestryExitCode)"
}
if ($headAncestryExitCode -eq 0) {
    if ($newUpstream -ne $upstreamCommit) {
        throw "fork already contains upstream/main $newUpstream but lock/source baseline still names $upstreamCommit"
    }
    Write-Host "typescript-go fork and lock already contain upstream/main $newUpstream"
    exit 0
}

& $gitCommand.Source -C $checkout merge --no-ff --no-commit $newUpstream
if ($LASTEXITCODE -ne 0) {
    throw "upstream merge requires conflict resolution in $checkout"
}
$pendingMergeHead = (& $gitCommand.Source -C $checkout rev-parse --verify MERGE_HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $pendingMergeHead -ne $newUpstream) {
    throw "pending merge does not target fetched upstream commit $newUpstream"
}

Write-Host "Merged upstream/main without committing."
Write-Host "previous upstream: $upstreamCommit"
Write-Host "new upstream: $newUpstream"
Write-Host "Update TypeScriptGoUpstreamCommit, review compatibility/golden changes, run all gates, then commit the merge."
