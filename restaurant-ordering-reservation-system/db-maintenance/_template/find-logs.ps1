<#
.SYNOPSIS  Locates the PostgreSQL log folder (Windows default) and searches for warning signs. Read-only.
.EXAMPLE   .\find-logs.ps1 -Database proj03_db -Last 2
Needs permission to read the server log folder (usually an administrator PowerShell). If you cannot read it,
record that limitation in log-findings.md instead of bypassing it.
#>
param(
    [string]$LogDir = "C:\Program Files\PostgreSQL\18\data\log",
    [string]$Database = "",
    [int]$Last = 2
)
if (-not (Test-Path $LogDir)) { Write-Warning "Log directory not found: $LogDir. Ask the server where logs go: SHOW log_directory; SHOW logging_collector;"; return }
$files = Get-ChildItem $LogDir -File | Sort-Object LastWriteTime -Descending | Select-Object -First $Last
$files | Format-Table Name, Length, LastWriteTime
$patterns = @("FATAL", "ERROR", "permission denied", "password authentication failed", "WARNING", "deadlock", "duration:")
foreach ($f in $files) {
    Write-Host "=== $($f.Name) ===" -ForegroundColor Cyan
    foreach ($p in $patterns) {
        $hits = Select-String -Path $f.FullName -Pattern $p -SimpleMatch
        if ($Database) { $hits = $hits | Where-Object { $_.Line -match [regex]::Escape($Database) -or $_.Line -notmatch "database" } }
        Write-Host ("{0,-35} {1} line(s)" -f $p, @($hits).Count)
        $hits | Select-Object -First 5 | ForEach-Object { Write-Host ("   " + $_.Line.Trim()) }
    }
}
Write-Host "`nReview lines before quoting them in the report: remove anything that contains a password or token." -ForegroundColor Yellow
