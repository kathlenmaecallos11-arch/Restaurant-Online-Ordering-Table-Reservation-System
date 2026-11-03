<#
.SYNOPSIS  Scaffolds db-backup-recovery\group-XX\ from _template. Then work from that folder.
.EXAMPLE   .\run-activity6.ps1 -Group 03
#>
param([Parameter(Mandatory)][string]$Group)
$dir = Join-Path $PSScriptRoot "group-$Group"
New-Item -ItemType Directory -Force (Join-Path $dir "evidence") | Out-Null
Copy-Item (Join-Path $PSScriptRoot "_template\*") $dir -Recurse -Force
Write-Host "Created $dir. Fill backup-plan.md first, then run backup.ps1 from that folder." -ForegroundColor Green
