<#
.SYNOPSIS  Helper for Activity 4. Scaffolds db-access-control\group-XX\ and runs the template scripts, saving transcripts.
.EXAMPLE
  .\run-activity4.ps1 -Group 03 -Db proj03_db -Step init
  .\run-activity4.ps1 -Group 03 -Db proj03_db -Step inventory
  .\run-activity4.ps1 -Group 03 -Db proj03_db -Step apply
  .\run-activity4.ps1 -Group 03 -Db proj03_db -Step passwords
  .\run-activity4.ps1 -Group 03 -Db proj03_db -Step tune
  .\run-activity4.ps1 -Group 03 -Db proj03_db -Step test -ReadTable orders -WriteTable orders -SensitiveTable users
  .\run-activity4.ps1 -Group 03 -Db proj03_db -Step logintests -Prefix g03
  Transcripts go to group-XX\evidence\ . The admin password is typed at psql's own hidden prompt.
#>
param(
    [Parameter(Mandatory)][string]$Group,
    [Parameter(Mandatory)][string]$Db,
    [Parameter(Mandatory)][ValidateSet("init","inventory","apply","passwords","tune","test","logintests")][string]$Step,
    [string]$Prefix = "g$Group",
    [string]$Schema = "public",
    [string]$Owner = "postgres",
    [string]$Admin = "postgres",
    [string]$PgHost = "localhost",
    [int]$Port = 5432,
    [string]$ReadTable, [string]$WriteTable, [string]$SensitiveTable
)
$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$dir  = Join-Path $root "group-$Group"
$ev   = Join-Path $dir "evidence"
$conn = @("-h",$PgHost,"-p",$Port,"-U",$Admin)

function Run([string]$file,[string]$database,[string[]]$vars,[string]$log) {
    $args2 = $conn + @("-d",$database) + $vars + @("-f",(Join-Path $dir $file))
    Write-Host ">> psql $file ($database)" -ForegroundColor Cyan
    & psql @args2 2>&1 | Tee-Object -FilePath (Join-Path $ev $log)
}
$common = @("-v","prefix=$Prefix","-v","schema=$Schema","-v","dbname=$Db","-v","owner=$Owner")

switch ($Step) {
 "init"      { New-Item -ItemType Directory -Force $ev | Out-Null
               Copy-Item (Join-Path $root "_template\*") $dir -Recurse -Force
               Write-Host "Created $dir. Fill access-control-plan.md before running 'apply'." -ForegroundColor Green }
 "inventory" { Run "00_inventory.sql" $Db @("-v","schema=$Schema") "00_inventory.txt" }
 "apply"     { Run "01_roles_and_grants.sql" $Db $common "01_apply.txt" }
 "passwords" { & psql @($conn + @("-d","postgres","-v","prefix=$Prefix","-f",(Join-Path $dir "02_set_passwords.psql"))) }
 "tune"      { Run "03_tune_least_privilege.sql" $Db $common "03_tune.txt" }
 "test"      {
     if (-not $ReadTable -or -not $WriteTable) { throw "-ReadTable and -WriteTable are required for -Step test" }
     $v = $common + @("-v","read_table=$ReadTable","-v","write_table=$WriteTable")
     if ($SensitiveTable) { $v += @("-v","sensitive_table=$SensitiveTable") }
     Run "04_privilege_tests.sql" $Db $v "04_matrix.txt"
     Run "05_review_privileges.sql" $Db $common "05_review.txt" }
 "logintests" {
     # Real logins: each command prompts for that account's password (do not paste it into screenshots).
     $app = "${Prefix}_app"; $rep = "${Prefix}_report"
     $out = Join-Path $ev "logintests.txt"
     "== $app : CREATE DATABASE (expected DENIED) ==" | Tee-Object -FilePath $out
     & psql -h $PgHost -p $Port -U $app -d $Db -c "CREATE DATABASE ${Prefix}_should_fail;" 2>&1 | Tee-Object -FilePath $out -Append
     "== $app : connect to the postgres maintenance DB (expected DENIED, CONNECT was revoked from PUBLIC) ==" | Tee-Object -FilePath $out -Append
     & psql -h $PgHost -p $Port -U $app -d postgres -c "SELECT 1;" 2>&1 | Tee-Object -FilePath $out -Append
     "== $rep : write attempt (expected DENIED) ==" | Tee-Object -FilePath $out -Append
     & psql -h $PgHost -p $Port -U $rep -d $Db -c "CREATE TABLE $Schema.should_fail(id int);" 2>&1 | Tee-Object -FilePath $out -Append
     if ($WriteTable) {
       & psql -h $PgHost -p $Port -U $rep -d $Db -c "DELETE FROM $Schema.$WriteTable WHERE false;" 2>&1 | Tee-Object -FilePath $out -Append
     } }
}
