param([switch]$Apply)
$ErrorActionPreference = 'Stop'
if (-not $Apply) { throw 'Use -Apply only for the authorized ymsw_v2 development fixture.' }
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../../../')).Path
$db = Get-Content -LiteralPath (Join-Path $projectRoot '.local/database-remote.json') -Raw | ConvertFrom-Json
$env:SMP_REVIEW_DB_URL = $db.url -replace '/ymsw\?', '/ymsw_v2?'
$env:SMP_REVIEW_DB_USER = $db.username
$env:SMP_REVIEW_DB_PASSWORD = $db.password
try {
 & (Join-Path $projectRoot '.local/tools/jdk-21.0.12.1+1/bin/java.exe') -cp "$env:USERPROFILE/.m2/repository/com/mysql/mysql-connector-j/9.7.0/mysql-connector-j-9.7.0.jar" (Join-Path $PSScriptRoot 'SeedM07Dev.java') (Join-Path $PSScriptRoot 'seed-m07-linked-cultures-20261016.sql') 'DEV-M07-1016' '11'
 if ($LASTEXITCODE -ne 0) { throw 'Fixture transaction aborted. No existing records were overwritten.' }
} finally {
 Remove-Item Env:SMP_REVIEW_DB_URL,Env:SMP_REVIEW_DB_USER,Env:SMP_REVIEW_DB_PASSWORD -ErrorAction SilentlyContinue
}
