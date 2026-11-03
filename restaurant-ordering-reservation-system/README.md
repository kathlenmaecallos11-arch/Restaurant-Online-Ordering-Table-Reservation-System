# Restaurant Online Ordering & Table Reservation System

COMP 018 – Database Administration · Group **Binary Sisters** · PostgreSQL 18 + PHP 8

Customers register, browse and search the menu, place food orders, reserve tables (with availability checking) and follow
the status of both. Staff and administrators manage orders, reservations, payments, menu items and tables.
Approved design: Activity 2 (ERD, schema, 12 business rules). This repository covers Activities 3 – 6.

## What is in this repository

| Path | Purpose | Activity |
|---|---|---|
| `app/` | PHP application (`public/` web root with `assets/style.css`, `src/` code, `config/database.php` PostgreSQL connection, no framework) | 3 |
| `tools/test-connection.php` | command-line check of the PostgreSQL connection | 3 |
| `database/migrations/` | `000`–`004` SQL: database, tables, business-rule logic, views, indexes | 3 |
| `database/seeds/` | sample data (staff, customers, menu, tables, orders, payments, reservations) | 3 |
| `database/roles/` | least-privilege group roles, login roles, grants, password prompts, verification | 3 → 4 |
| `database/setup.ps1`, `setup.sh` | one-command build of the database | 3 |
| `tests/crud_tests.sql` | create/retrieve/update/delete + constraint tests (rolled back) | 3 |
| `docs/` | user roles, role setup, database documentation, troubleshooting, testing guide, changes, AI usage, progress PDF | 3 |
| `db-access-control/` | templates + helper to secure the **other groups'** databases | 4 |
| `db-maintenance/` | monitoring, maintenance, query-plan templates | 5 |
| `db-backup-recovery/` | backup, restore, recovery-simulation templates | 6 |
| `tracker/` | ready-to-paste rows for the class Google Sheets tracker tabs | 3–6 |

**Step-by-step run guide with troubleshooting: `docs/RUN_LOCALLY.md`. How PHP connects to PostgreSQL (exact code, every button mapped to its SQL): `docs/DATABASE_CONNECTION.md`. Working interface demo without any setup (data kept in the browser only): open `preview/index.html`.**

## Prerequisites
* PostgreSQL **18** (14+ works; role `pg_maintain` needs 17+) with `psql` on PATH, and the contrib extensions
  `btree_gist` and `pgcrypto` (included in the standard installers).
* PHP **8.1+** with the `pdo_pgsql` and `pgsql` extensions enabled (see `docs/troubleshooting.md` §2).
* Git. Windows 10/11 is the reference platform; Linux/macOS use `setup.sh`.

## Install and run (≈ 5 minutes)

```powershell
git clone <REPOSITORY_URL> ; cd <folder>

# 1. database: creates grp_binarysisters_projectdb, tables, rules, views, indexes, sample data,
#    and the least-privilege accounts. Asks (hidden) for the postgres password and for a NEW password per account.
.\database\setup.ps1 -WithRoles          # Linux/macOS: ./database/setup.sh --with-roles

# 2. configuration (local, never committed)
copy .env.example .env                   # then edit .env: DB_USER=rors_app, DB_PASSWORD=<password you chose for rors_app>

# 3. start the application
php -S localhost:8000 -t app/public      # open http://localhost:8000
```
Without roles (quick look only): run `.\database\setup.ps1`, set `DB_USER=postgres` in your local `.env` — not for real use (Activity 4 forbids a superuser for the application).

### Sample accounts (local test data)
| Role | Email | Password |
|---|---|---|
| Administrator | admin@rors.example | Admin123! |
| Staff | staff@rors.example | Staff123! |
| Customer | maria.santos@rors.example | Password123! |

Customer login `/login`, staff/admin login `/staff/login`.

## Verify the installation
1. `psql -h localhost -U postgres -d grp_binarysisters_projectdb -f tests/crud_tests.sql` → every line `PASS`, `failed = 0`.
2. `psql -h localhost -U postgres -d grp_binarysisters_projectdb -f database/roles/04_verify_privileges.sql` → every row `PASS`.
3. `php tools/test-connection.php` → `OK` for the connection and all 8 tables.
4. Open `http://localhost:8000/health` → `{"status":"ok", ...}` (proves browser → PHP → PostgreSQL).
5. Browser smoke test: log in as customer → add 2 dishes → place order → reserve a table → log in as staff → set the order to *confirmed*.

## Environment variables (`.env.example`)
`APP_NAME`, `APP_DEBUG`, `APP_TIMEZONE`, `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_SSLMODE`. Placeholders only.

## Documentation
`docs/RUN_LOCALLY.md` (start here) · `docs/user-roles.md` · `docs/user-role-setup.md` · `docs/database-documentation.md` · `docs/erd.md` ·
`docs/troubleshooting.md` · `docs/testing-guide.md` (for groups that test this project) · `docs/changes-from-activity2.md` ·
`docs/ai-usage.md` · `docs/progress/` (PDF progress documentation).

## Security notes
* Prepared statements everywhere (PDO, native prepares); output escaped; CSRF token on every POST; bcrypt password hashes; session id regenerated on login.
* Application connects as `rors_app` (no superuser, no DDL, no DELETE on orders/payments).
* Known limitations: no login rate-limiting, no e-mail verification, no HTTPS in the built-in server (development only).

## Group and links
Group: Binary Sisters · Tracker: `<TRACKER_URL>` · Progress PDF: `docs/progress/` · Members: see PDF cover.
