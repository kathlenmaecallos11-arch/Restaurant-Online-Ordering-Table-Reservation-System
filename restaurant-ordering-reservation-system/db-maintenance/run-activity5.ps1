<#
.SYNOPSIS  Helper for Activity 5. Scaffolds group-XX\ and runs the template scripts with the chosen Activity 4 account.
.EXAMPLE
  .\run-activity5.ps1 -Group 03 -Db proj03_db -Step init
  .\run-activity5.ps1 -Group 03 -Db proj03_db -Step health   -Account g03_maint
  .\run-activity5.ps1 -Group 03 -Db proj03_db -Step health   -Account g03_report   # compare visibility
  .\run-activity5.ps1 -Group 03 -Db proj03_db -Step review   -Account g03_maint
  .\run-activity5.ps1 -Group 03 -Db proj03_db -Step maintain -Account g03_maint
  .\run-activity5.ps1 -Group 03 -Db proj03_db -Step plan     -Account g03_report   (after editing 04_query_plan.sql)
  psql asks for the account's password itself (hidden). Transcripts: group-XX\evidence\
#>
param(
    [Parameter(Mandatory)][string]$Group,
    [Parameter(Mandatory)][string]$Db,
    [Parameter(Mandatory)][ValidateSet("init","health","review","maintain","plan")][string]$Step,
    [string]$Account, [string]$Prefix = "g$Group", [string]$Schema = "public",
    [string]$PgHost = "localhost", [int]$Port = 5432
)
$ErrorActionPreference = "Stop"
$dir = Join-Path $PSScriptRoot "group-$Group"; $ev = Join-Path $dir "evidence"
if ($Step -eq "init") {
    New-Item -ItemType Directory -Force $ev | Out-Null
    Copy-Item (Join-Path $PSScriptRoot "_template\*") $dir -Recurse -Force
    Write-Host "Created $dir" -ForegroundColor Green; return
}
if (-not $Account) { throw "-Account is required (an Activity 4 login, e.g. ${Prefix}_maint)" }
$map = @{ health = "01_health_checks.sql"; review = "02_maintenance_review.sql"; maintain = "03_maintenance.sql"; plan = "04_query_plan.sql" }
$file = Join-Path $dir $map[$Step]
$log  = Join-Path $ev ("{0}_{1}_{2}.txt" -f $map[$Step].Substring(0,2), $Step, $Account)
& psql -h $PgHost -p $Port -U $Account -d $Db -v "prefix=$Prefix" -v "schema=$Schema" -f $file 2>&1 | Tee-Object -FilePath $log
Write-Host "Saved $log (check it for secrets before committing)" -ForegroundColor Yellow
