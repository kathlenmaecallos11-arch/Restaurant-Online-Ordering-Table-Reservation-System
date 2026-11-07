<#
.SYNOPSIS  Activity 6 Part C: restore the newest backup into a NEW database named <Db>_restore_test and verify it.
.EXAMPLE   .\restore.ps1 -Db proj03_db -ReapplyAccessControl -Prefix g03
Uses the administrator account because pg_restore must create extensions / owners. The ORIGINAL database is never touched.
#>
param(
    [Parameter(Mandatory)][string]$Db,
    [string]$DumpFile,
    [string]$Admin = "postgres", [string]$PgHost = "localhost", [int]$Port = 5432,
    [string]$Schema = "public",
    [switch]$ReapplyAccessControl, [string]$Prefix, [string]$Owner = "postgres",
    [string]$BackupDir = (Join-Path $env:USERPROFILE "rors-backups")
)
$ErrorActionPreference = "Stop"
$ev = Join-Path $PSScriptRoot "evidence"; New-Item -ItemType Directory -Force $ev | Out-Null
$test = "${Db}_restore_test"
# MESA-INC4: never trust a backup file before its size and SHA-256 match evidence\backup-log.csv.
$logCsv = Join-Path $ev "backup-log.csv"
function Test-BackupFile([string]$Path) {
    if (-not (Test-Path $Path)) { return $false }
    if (-not (Test-Path $logCsv)) { Write-Warning "evidence\backup-log.csv not found: cannot verify $Path"; return $false }
    $leaf = Split-Path $Path -Leaf
    $row  = Import-Csv $logCsv | Where-Object { $_.file -eq $leaf } | Select-Object -Last 1
    if (-not $row) { Write-Warning "$leaf is not recorded in backup-log.csv"; return $false }
    $size = (Get-Item $Path).Length
    $hash = (Get-FileHash $Path -Algorithm SHA256).Hash
    if ([int64]$row.size_bytes -ne $size) { Write-Warning "REJECTED $leaf : size $size differs from logged $($row.size_bytes)"; return $false }
    if ($row.sha256 -ne $hash)            { Write-Warning "REJECTED $leaf : SHA-256 differs from the logged value"; return $false }
    & pg_restore --list $Path *> $null
    if ($LASTEXITCODE -ne 0)              { Write-Warning "REJECTED $leaf : pg_restore --list cannot read the archive"; return $false }
    Write-Host "VERIFIED $leaf (size and SHA-256 match the backup log)" -ForegroundColor Green
    return $true
}
if ($DumpFile) {
    if (-not (Test-BackupFile $DumpFile)) { throw "The backup file failed verification. Choose another file." }
} else {
    $candidates = Get-ChildItem $BackupDir -Filter "${Db}_activity6_*.dump" | Sort-Object LastWriteTime -Descending
    foreach ($c in $candidates) { if (Test-BackupFile $c.FullName) { $DumpFile = $c.FullName; break } }
}
if (-not $DumpFile -or -not (Test-Path $DumpFile)) { throw "No VERIFIED backup file found. Run backup.ps1 first." }
if ($test -eq $Db) { throw "Refusing to restore over the original database." }

$secure = Read-Host -Prompt "Password of '$Admin'" -AsSecureString
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
$env:PGPASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
$conn = @("-h", $PgHost, "-p", $Port, "-U", $Admin)
try {
    $t0 = Get-Date
    Write-Host ">> createdb $test" -ForegroundColor Cyan
    & createdb @conn $test
    if ($LASTEXITCODE -ne 0) { throw "createdb failed (does $test already exist? drop it only if it is YOUR disposable copy)." }

    Write-Host ">> pg_restore $DumpFile -> $test" -ForegroundColor Cyan
    & pg_restore @conn -d $test $DumpFile 2>&1 | Tee-Object -FilePath (Join-Path $ev "restore_output.txt")
    if ($LASTEXITCODE -ne 0) { Write-Warning "pg_restore reported problems (exit $LASTEXITCODE). Read evidence\restore_output.txt and explain every warning in the report." }

    if ($ReapplyAccessControl) {
        if (-not $Prefix) { throw "-Prefix is required with -ReapplyAccessControl" }
        $ac = Join-Path (Split-Path $PSScriptRoot -Parent | Split-Path -Parent) "db-access-control\$(Split-Path $PSScriptRoot -Leaf)\01_roles_and_grants.sql"
        if (-not (Test-Path $ac)) { throw "Access-control script not found: $ac" }
        Write-Host ">> re-applying Activity 4 grants to $test" -ForegroundColor Cyan
        & psql @conn -d $test -v ON_ERROR_STOP=1 -v "prefix=$Prefix" -v "dbname=$test" -v "schema=$Schema" -v "owner=$Owner" -f $ac 2>&1 |
            Tee-Object -FilePath (Join-Path $ev "restore_access_control.txt")
    }

    Write-Host ">> verification" -ForegroundColor Cyan
    & psql @conn -d $test -v "schema=$Schema" -f (Join-Path $PSScriptRoot "01_verify_restore.sql") 2>&1 |
        Tee-Object -FilePath (Join-Path $ev "restore_verification.txt")
    & psql @conn -d $Db  -v "schema=$Schema" -At -c "SELECT table_name || ',' || (xpath('/row/c/text()', query_to_xml(format('SELECT count(*) AS c FROM %I.%I', table_schema, table_name), false, true, '')))[1]::text FROM information_schema.tables WHERE table_schema = '$Schema' AND table_type = 'BASE TABLE' ORDER BY 1" |
        Out-File (Join-Path $ev "rowcounts_original.csv") -Encoding utf8
    & psql @conn -d $test -v "schema=$Schema" -At -c "SELECT table_name || ',' || (xpath('/row/c/text()', query_to_xml(format('SELECT count(*) AS c FROM %I.%I', table_schema, table_name), false, true, '')))[1]::text FROM information_schema.tables WHERE table_schema = '$Schema' AND table_type = 'BASE TABLE' ORDER BY 1" |
        Out-File (Join-Path $ev "rowcounts_restored.csv") -Encoding utf8
    $diff = Compare-Object (Get-Content (Join-Path $ev "rowcounts_original.csv")) (Get-Content (Join-Path $ev "rowcounts_restored.csv"))
    if ($diff) { Write-Warning "Row counts differ between original and restored database:"; $diff | Format-Table } else { Write-Host "Row counts identical in original and restored database." -ForegroundColor Green }
    Write-Host ("Restore + verification took {0:n0} s (use as the measured RTO ingredient)." -f ((Get-Date) - $t0).TotalSeconds)
}
finally { Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue }
