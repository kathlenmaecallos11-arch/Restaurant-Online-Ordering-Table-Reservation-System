#!/usr/bin/env bash
# Creates and initialises the project database on Linux/macOS (psql on PATH).
#   ./database/setup.sh                 # DB, tables, constraints, views, indexes, sample data
#   ./database/setup.sh --with-roles    # ...plus least-privilege roles/accounts
#   ./database/setup.sh --reset         # drop tables and rebuild (LOCAL development DB only)
# The admin password is read once at a hidden prompt and never written to disk.
set -euo pipefail

PGHOST_="${PGHOST_:-localhost}"; PGPORT_="${PGPORT_:-5432}"
ADMIN="${ADMIN_USER:-postgres}"; DB="${DB_NAME:-grp_binarysisters_projectdb}"
DIR="$(cd "$(dirname "$0")" && pwd)"
WITH_ROLES=0; RESET=0
for a in "$@"; do
  case "$a" in --with-roles) WITH_ROLES=1;; --reset) RESET=1;; *) echo "unknown option $a"; exit 1;; esac
done

command -v psql >/dev/null || { echo "psql not found on PATH"; exit 1; }
read -r -s -p "Password of PostgreSQL user '$ADMIN': " PGPASSWORD; echo
export PGPASSWORD
trap 'unset PGPASSWORD' EXIT

run() { echo ">> $2  (database: $1)"; psql -h "$PGHOST_" -p "$PGPORT_" -U "$ADMIN" -d "$1" -v ON_ERROR_STOP=1 -q -f "$2"; }

run postgres "$DIR/migrations/000_create_database.sql"
if [ "$RESET" = 1 ]; then
  read -r -p "RESET deletes all tables in '$DB'. Type YES to continue: " ans
  [ "$ans" = "YES" ] || { echo "Reset cancelled."; exit 1; }
  run "$DB" "$DIR/reset_database.sql"
fi
for f in 001_create_tables 002_integrity_logic 003_views 004_indexes; do run "$DB" "$DIR/migrations/$f.sql"; done
run "$DB" "$DIR/seeds/001_seed_data.sql"

if [ "$WITH_ROLES" = 1 ]; then
  run postgres "$DIR/roles/01_create_roles.sql"
  run "$DB" "$DIR/roles/02_grants.sql"
  echo "Choose a password for each login account (hidden prompts)."
  psql -h "$PGHOST_" -p "$PGPORT_" -U "$ADMIN" -d postgres -f "$DIR/roles/03_set_passwords.psql"
  run "$DB" "$DIR/roles/04_verify_privileges.sql"
fi
echo "Database '$DB' is ready. Next: cp .env.example .env, edit it, then: php -S localhost:8000 -t app/public"
