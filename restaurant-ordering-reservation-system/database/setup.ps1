<#
.SYNOPSIS
  Creates and initialises the project database on Windows (PostgreSQL 18 + psql on PATH).

.EXAMPLE
  .\database\setup.ps1                       # create DB, tables, constraints, views, indexes, sample data
  .\database\setup.ps1 -WithRoles            # ...and also create the least-privilege roles/accounts
  .\database\setup.ps1 -Reset                # drop tables and rebuild (LOCAL development database only)

  The administrator password is requested once at a hidden prompt and kept only in this
  process; it is never written to disk.
#>
param(
    [string]$PgHost    = "localhost",
    [int]   $Port      = 5432,
    [string]$AdminUser = "postgres",
    [string]$DbName    = "grp_binarysisters_projectdb",
    [switch]$WithRoles,
    [switch]$Reset,
    [switch]$SkipSeed
)

$ErrorActionPreference = "Stop"
$db = $PSScriptRoot   # the database\ folder

if (-not (Get-Command psql -ErrorAction SilentlyContinue)) {
    Write-Error "psql was not found on PATH. Add C:\Program Files\PostgreSQL\18\bin to PATH (see docs/troubleshooting.md)."
}

$secure = Read-Host -Prompt "Password of PostgreSQL user '$AdminUser'" -AsSecureString
$bstr   = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
$env:PGPASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)

function Invoke-Sql([string]$Database, [string]$File) {
    Write-Host ">> $File  (database: $Database)" -ForegroundColor Cyan
    & psql -h $PgHost -p $Port -U $AdminUser -d $Database -v ON_ERROR_STOP=1 -q -f $File
    if ($LASTEXITCODE -ne 0) { throw "psql failed on $File (exit code $LASTEXITCODE)" }
}

try {
    Invoke-Sql "postgres" (Join-Path $db "migrations\000_create_database.sql")

    if ($Reset) {
        $answer = Read-Host "RESET will delete all tables in '$DbName'. Type YES to continue"
        if ($answer -ne "YES") { throw "Reset cancelled." }
        Invoke-Sql $DbName (Join-Path $db "reset_database.sql")
    }

    foreach ($f in "001_create_tables","002_integrity_logic","003_views","004_indexes") {
        Invoke-Sql $DbName (Join-Path $db "migrations\$f.sql")
    }
    if (-not $SkipSeed) { Invoke-Sql $DbName (Join-Path $db "seeds\001_seed_data.sql") }

    # MESA-INC1: a rebuild recreates the tables, so grants on the old tables are lost. If the roles already
    # exist, re-apply the grants and fail loudly if the application role still cannot use the tables.
    if (-not $WithRoles) {
        $hasRoles = (& psql -h $PgHost -p $Port -U $AdminUser -d postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='rors_runtime_grp'")
        if ("$hasRoles".Trim() -eq "1") {
            Invoke-Sql $DbName (Join-Path $db "roles\02_grants.sql")
            Invoke-Sql $DbName (Join-Path $db "roles\05_check_app_access.sql")
        }
    }

    if ($WithRoles) {
        Invoke-Sql "postgres" (Join-Path $db "roles\01_create_roles.sql")
        Invoke-Sql $DbName    (Join-Path $db "roles\02_grants.sql")
        Write-Host "`nNow choose a password for each login account (hidden prompts)." -ForegroundColor Yellow
        & psql -h $PgHost -p $Port -U $AdminUser -d postgres -f (Join-Path $db "roles\03_set_passwords.psql")
        Invoke-Sql $DbName (Join-Path $db "roles\04_verify_privileges.sql")
        Invoke-Sql $DbName (Join-Path $db "roles\05_check_app_access.sql")
        Invoke-Sql "postgres" (Join-Path $db "roles\06_verify_logins.sql")
    }
    Write-Host "`nDatabase '$DbName' is ready." -ForegroundColor Green
    Write-Host "Next: copy .env.example to .env, set DB_USER/DB_PASSWORD, then run: php -S localhost:8000 -t app/public"
}
finally {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}
