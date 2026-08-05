[CmdletBinding()]
param(
    [ValidateSet("all", "package", "validator", "module", "checker", "cli", "compatibility", "race", "shuffle", "repeat")]
    [string[]]$Stage = @("all"),

    [ValidateRange(1, 100)]
    [int]$RepeatCount = 5,

    [switch]$List
)

$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$typescriptGoRoot = Join-Path $repositoryRoot "typescript-go"

if (-not (Test-Path -LiteralPath (Join-Path $typescriptGoRoot "go.mod") -PathType Leaf)) {
    throw "typescript-go checkout is missing at $typescriptGoRoot"
}

$goCommand = Get-Command go -ErrorAction Stop
$stageRegistry = [ordered]@{
    package = [pscustomobject]@{
        Arguments = @("test", "./internal/tsfrontend/...", "-count=1")
    }
    validator = [pscustomobject]@{
        Arguments = @(
            "test", "./internal/tsfrontend",
            "-run", "^Test(FrontendBuildProducesDeterministicValidatedSnapshot|ValidateProgramSnapshot|SnapshotValidation|ValidateLegacyProgramSnapshot|RunSubsetGate)",
            "-count=1"
        )
    }
    module = [pscustomobject]@{
        Arguments = @("test", "./internal/tsfrontend", "-run", "^Test(Finalize|Capture)ModuleGraph", "-count=1")
    }
    checker = [pscustomobject]@{
        Arguments = @(
            "test", "./internal/tsfrontend",
            "-run", "^Test(WithCheckerForFile|CollectProgramDiagnostics|CheckMatchesCompilerDiagnosticGate)",
            "-count=1"
        )
    }
    cli = [pscustomobject]@{
        Arguments = @("test", "./cmd/ts2bin", "-count=1")
    }
    compatibility = [pscustomobject]@{
        Arguments = @("test", "./internal/tsfrontend", "./cmd/ts2bin", "-run", "Compatibility", "-count=1")
    }
    race = [pscustomobject]@{
        Arguments = @("test", "-race", "./internal/tsfrontend/...", "./cmd/ts2bin", "-count=1")
    }
    shuffle = [pscustomobject]@{
        Arguments = @("test", "./internal/tsfrontend/...", "./cmd/ts2bin", "-shuffle=on", "-count=1")
    }
    repeat = [pscustomobject]@{
        Arguments = @(
            "test", "./internal/tsfrontend", "./cmd/ts2bin",
            "-run", "^Test(FrontendBuildProducesDeterministicValidatedSnapshot|WithCheckerForFileConcurrentBorrow|CaptureModuleGraph|ValidateProgramSnapshot|FrontendStage)",
            "-count=$RepeatCount"
        )
    }
}

function Format-CommandArgument([string]$Value) {
    if ($Value -notmatch '[\s"]') {
        return $Value
    }
    return '"' + $Value.Replace('"', '\"') + '"'
}

function Format-StageCommand([string[]]$Arguments) {
    $parts = @((Format-CommandArgument $goCommand.Source))
    $parts += @($Arguments | ForEach-Object { Format-CommandArgument $_ })
    return $parts -join " "
}

$selectedStages = if ($Stage -contains "all") {
    @($stageRegistry.Keys)
} else {
    @($stageRegistry.Keys | Where-Object { $Stage -contains $_ })
}

if ($List) {
    foreach ($stageName in $selectedStages) {
        $commandLine = Format-StageCommand $stageRegistry[$stageName].Arguments
        Write-Output ("[frontend:{0}] command: {1}" -f $stageName, $commandLine)
    }
    exit 0
}

$failedStages = [System.Collections.Generic.List[string]]::new()
Push-Location -LiteralPath $typescriptGoRoot
try {
    foreach ($stageName in $selectedStages) {
        $arguments = [string[]]$stageRegistry[$stageName].Arguments
        $commandLine = Format-StageCommand $arguments
        Write-Output ("[frontend:{0}] command: {1}" -f $stageName, $commandLine)

        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        & $goCommand.Source @arguments
        $stageExitCode = $LASTEXITCODE
        $stopwatch.Stop()

        $status = if ($stageExitCode -eq 0) { "passed" } else { "failed" }
        Write-Output ("[frontend:{0}] result: {1}; exit={2}; elapsedMs={3}" -f $stageName, $status, $stageExitCode, $stopwatch.ElapsedMilliseconds)
        if ($stageExitCode -ne 0) {
            $failedStages.Add($stageName)
        }
    }
}
finally {
    Pop-Location
}

$passedCount = $selectedStages.Count - $failedStages.Count
$failedSummary = if ($failedStages.Count -eq 0) { "none" } else { $failedStages -join "," }
Write-Output ("[frontend:summary] result: passed={0}; failed={1}; failedStages={2}" -f $passedCount, $failedStages.Count, $failedSummary)
exit $(if ($failedStages.Count -eq 0) { 0 } else { 1 })
