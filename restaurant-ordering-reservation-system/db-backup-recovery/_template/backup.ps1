<#
.SYNOPSIS  Activity 6 Part B: custom-format backup + size + SHA-256 + archive listing. Run from the group-XX folder.
.EXAMPLE   .\backup.ps1 -Db proj03_db -Account g03_backup
The backup account's password is requested by pg_dump itself (hidden). The dump is stored OUTSIDE the repository.
#>
param(
    [Parameter(Mandatory)][string]$Db,
    [Parameter(Mandatory)][string]$Account,
    [string]$PgHost = "localhost", [int]$Port = 5432,
    [string]$BackupDir = (Join-Path $env:USERPROFILE "rors-backups")
)
$ErrorActionPreference = "Stop"
$ev = Join-Path $PSScriptRoot "evidence"; New-Item -ItemType Directory -Force $ev, $BackupDir | Out-Null
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$file  = Join-Path $BackupDir "${Db}_activity6_$stamp.dump"

Write-Host ">> pg_dump -Fc  ($Db as $Account)" -ForegroundColor Cyan
& pg_dump -h $PgHost -p $Port -U $Account -Fc -d $Db -f $file
if ($LASTEXITCODE -ne 0) { throw "pg_dump failed (exit $LASTEXITCODE). Check the account's privileges and the password." }

$size = (Get-Item $file).Length
$hash = (Get-FileHash $file -Algorithm SHA256).Hash
$list = Join-Path $ev "archive-listing_$stamp.txt"
& pg_restore --list $file | Out-File -FilePath $list -Encoding utf8
if ($LASTEXITCODE -ne 0) { throw "pg_restore --list failed: the archive is not readable." }
Get-Content $list -TotalCount 25

$csv = Join-Path $ev "backup-log.csv"
if (-not (Test-Path $csv)) { "timestamp,database,file,size_bytes,sha256,method,account" | Out-File $csv -Encoding utf8 }
"{0},{1},{2},{3},{4},pg_dump -Fc,{5}" -f (Get-Date -Format s), $Db, (Split-Path $file -Leaf), $size, $hash, $Account | Out-File $csv -Append -Encoding utf8

Write-Host "`nBackup file : $file"
Write-Host "Size        : $size bytes"
Write-Host "SHA-256     : $hash"
Write-Host "Listing     : $list   (TOC entries: $((Select-String -Path $list -Pattern '^\d+;' | Measure-Object).Count))"
Write-Host "DO NOT COMMIT the .dump file. The log line was added to evidence\backup-log.csv." -ForegroundColor Yellow
