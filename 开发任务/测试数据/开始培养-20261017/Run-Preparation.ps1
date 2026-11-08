param(
    [Parameter(Mandatory=$true)][ValidateSet('Check','Upgrade','Seed','Verify')][string]$Action,
    [string]$ConnectionFile,
    [string]$JdbcJar,
    [string]$JavaExe = 'java'
)
$ErrorActionPreference='Stop'
$taskRepoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../..'))
if (-not $ConnectionFile) { $ConnectionFile=Join-Path $taskRepoRoot 'data-connect.txt' }
if (-not $JdbcJar) { $JdbcJar=Join-Path $env:USERPROFILE '.m2/repository/com/mysql/mysql-connector-j/9.7.0/mysql-connector-j-9.7.0.jar' }
foreach ($taskFile in @($ConnectionFile,$JdbcJar)) { if (-not (Test-Path -LiteralPath $taskFile -PathType Leaf)) { throw "Required local file missing: $taskFile" } }
$taskArguments=@('-Dfile.encoding=UTF-8','-cp',$JdbcJar)
if ($Action -in @('Upgrade','Seed')) {
    $taskArguments+=@((Join-Path $PSScriptRoot 'ScDatabasePrepare.java'),$ConnectionFile,$PSScriptRoot,$Action.ToLowerInvariant())
} else {
    $taskSql=if($Action -eq 'Check') {'00-precheck.sql'} else {'03-verify.sql'}
    $taskArguments+=@((Join-Path $PSScriptRoot 'ScDatabaseProbe.java'),$ConnectionFile,(Join-Path $PSScriptRoot $taskSql))
}
& $JavaExe @taskArguments
if ($LASTEXITCODE -ne 0) { throw "Preparation $Action stopped with exit code $LASTEXITCODE. Do not blindly rerun an incomplete Upgrade." }
