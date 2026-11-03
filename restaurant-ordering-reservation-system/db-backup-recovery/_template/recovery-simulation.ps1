<#
.SYNOPSIS  Activity 6 Part D: controlled incident. Works ONLY on <Db>_restore_test; the original database is untouched.
.EXAMPLE   .\recovery-simulation.ps1 -Db proj03_db -Table payments -PkColumn payment_id -PkValue 4
Steps: record row -> delete it in the restore DB -> restore the backup into a fresh <Db>_recovery DB ->
copy the row back -> compare. Pick a row from a LEAF table (no other table references it) or the delete is blocked by a foreign key.
#>
param(
    [Parameter(Mandatory)][string]$Db, [Parameter(Mandatory)][string]$Table,
    [Parameter(Mandatory)][string]$PkColumn, [Parameter(Mandatory)][string]$PkValue,
    [string]$DumpFile, [string]$Schema = "public",
    [string]$Admin = "postgres", [string]$PgHost = "localhost", [int]$Port = 5432,
    [string]$BackupDir = (Join-Path $env:USERPROFILE "rors-backups")
)
$ErrorActionPreference = "Stop"
$ident = '^[A-Za-z_][A-Za-z0-9_]*$'
foreach ($n in $Table, $PkColumn, $Schema) { if ($n -notmatch $ident) { throw "Unsafe identifier: $n" } }
$restoreDb = "${Db}_restore_test"; $recoveryDb = "${Db}_recovery"
if (-not $restoreDb.EndsWith("_restore_test")) { throw "Safety check failed" }
if (-not $DumpFile) { $DumpFile = (Get-ChildItem $BackupDir -Filter "${Db}_activity6_*.dump" | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName }
if (-not (Test-Path $DumpFile)) { throw "Backup file not found; the recovery needs a verified backup." }
$ev = Join-Path $PSScriptRoot "evidence"; New-Item -ItemType Directory -Force $ev | Out-Null
$timeline = Join-Path $ev "recovery-timeline.txt"
function Log([string]$m) { $line = "{0}  {1}" -f (Get-Date -Format "HH:mm:ss"), $m; Write-Host $line; $line | Out-File $timeline -Append -Encoding utf8 }

$secure = Read-Host -Prompt "Password of '$Admin'" -AsSecureString
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
$env:PGPASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
$conn = @("-h", $PgHost, "-p", $Port, "-U", $Admin)

function Sql([string]$db, [string]$sql, [switch]$Quiet) {
    $out = $sql | & psql @conn -d $db -v ON_ERROR_STOP=1 -v "pkv=$PkValue" -At -f - 2>&1
    if ($LASTEXITCODE -ne 0) { throw "SQL failed on ${db}: $out" }
    return ($out -join "`n").Trim()
}
$select = "SELECT row_to_json(t)::text FROM $Schema.$Table t WHERE ${PkColumn}::text = :'pkv';"

try {
    Log "Incident scope: ONE row in $Schema.$Table where $PkColumn = $PkValue, in database $restoreDb only."
    $before = Sql $restoreDb $select
    if (-not $before) { throw "No such row in $restoreDb. Check the table, key column and value." }
    Log "BEFORE (expected state): $before"
    $before | Out-File (Join-Path $ev "recovery_before.json") -Encoding utf8

    Log "Simulating the incident: DELETE the row in $restoreDb"
    Sql $restoreDb "DELETE FROM $Schema.$Table WHERE ${PkColumn}::text = :'pkv';" | Out-Null
    $after = Sql $restoreDb $select
    Log ("AFTER LOSS: " + $(if ($after) { "row still present (delete did not happen)" } else { "row is gone (0 rows)" }))

    Log "Recovery: restoring the backup into a fresh database $recoveryDb"
    & createdb @conn $recoveryDb
    if ($LASTEXITCODE -ne 0) { throw "createdb $recoveryDb failed (drop your own old disposable copy first)." }
    & pg_restore @conn -d $recoveryDb $DumpFile 2>&1 | Out-File (Join-Path $ev "recovery_restore_output.txt") -Encoding utf8

    $rowJson = Sql $recoveryDb $select
    if (-not $rowJson) { throw "The row does not exist in the backup (it was created after the backup was taken?)." }
    $insert = Sql $recoveryDb ("SELECT format('INSERT INTO %I.%I SELECT * FROM json_populate_record(NULL::%I.%I, %L);', '$Schema', '$Table', '$Schema', '$Table', row_to_json(t)::text) FROM $Schema.$Table t WHERE ${PkColumn}::text = :'pkv';")
    $tmp = Join-Path $env:TEMP "rors_recover_$([guid]::NewGuid().ToString('N')).sql"
    $insert | Out-File $tmp -Encoding utf8
    & psql @conn -d $restoreDb -v ON_ERROR_STOP=1 -f $tmp 2>&1 | ForEach-Object { Log "psql: $_" }
    Remove-Item $tmp -Force

    $recovered = Sql $restoreDb $select
    $recovered | Out-File (Join-Path $ev "recovery_after.json") -Encoding utf8
    if ($recovered -eq $before) { Log "RESULT: RECOVERED. The row is identical to the recorded expected state." }
    else { Log "RESULT: NOT (fully) RECOVERED. Expected: $before  Got: $recovered" }
    Log "If the loss had happened AFTER the newest backup, the change would be unrecoverable from this file: that is what the RPO describes."
}
finally { Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue }
