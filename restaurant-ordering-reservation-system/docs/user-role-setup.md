# User and role setup (database accounts and privileges)

Companion of `docs/user-roles.md`. **No real passwords are committed**; every password is typed at a hidden prompt.

## 1. What gets created
Group roles (NOLOGIN): `rors_runtime_grp`, `rors_readonly_grp`, `rors_maint_grp`, `rors_backup_grp`, `rors_admin_grp`
Login roles: `rors_app`, `rors_report`, `rors_maint`, `rors_backup`, `rors_dba` (each a member of exactly one group role).

## 2. Create them (administrator = `postgres`)
```powershell
.\database\setup.ps1 -WithRoles          # does everything, including the hidden password prompts
```
or by hand:
```bash
psql -h localhost -U postgres -d postgres                      -f database/roles/01_create_roles.sql
psql -h localhost -U postgres -d grp_binarysisters_projectdb   -f database/roles/02_grants.sql
psql -h localhost -U postgres -d postgres                      -f database/roles/03_set_passwords.psql   # hidden prompts
psql -h localhost -U postgres -d grp_binarysisters_projectdb   -f database/roles/04_verify_privileges.sql
```
## 3. Point the application at the runtime account
In your **local** `.env` (never committed): `DB_USER=rors_app` and `DB_PASSWORD=<the one you typed>`.

## 4. Privilege matrix (S=SELECT I=INSERT U=UPDATE D=DELETE)

| Table / view | rors_runtime_grp | rors_readonly_grp | rors_maint_grp | rors_backup_grp | rors_admin_grp |
|---|---|---|---|---|---|
| customer | S I U | — (use `v_customer_directory`) | — | S (pg_read_all_data) | all |
| staff | S I U D | — (use `v_staff_directory`) | — | S | all |
| menu_item | S I U D | S | — | S | all |
| restaurant_table | S I U D | S | — | S | all |
| orders | S I U | S | — | S | all |
| order_item | S I | S | — | S | all |
| reservation | S I U D | S | — | S | all |
| payment | S I U | S | — | S | all |
| views (4) | order/reservation summary: S | S | — | S | all |
| sequences | USAGE, SELECT | — | — | S | all |
| VACUUM / ANALYZE | — | — | yes (`pg_maintain`) | — | — |
| statistics of other sessions | — | — | yes (`pg_monitor`) | — | yes |

## 5. Design decisions (least privilege)
* `REVOKE ALL ... FROM PUBLIC` on the database and schema, then explicit `CONNECT` and `USAGE` to the group roles only.
* CONNECT does not give table access; schema USAGE does not give table access; sequences need their own grants (SERIAL columns).
* Read-only role is kept away from `customer` and `staff` (password hashes) by not granting them — views expose the safe columns.
* No default privileges for runtime/read-only roles: a new table is invisible to them until someone grants it consciously.
* Runtime has no DELETE on `orders`, `order_item`, `payment` (history must not vanish); cancelling is a status update.
* `rors_app` has `statement_timeout = 30s` and `CONNECTION LIMIT 20`.

## 6. Verify with real logins (take screenshots; do not show passwords)
```bash
psql -h localhost -U rors_report -d grp_binarysisters_projectdb -c "SELECT * FROM v_order_summary LIMIT 3;"       # allowed
psql -h localhost -U rors_report -d grp_binarysisters_projectdb -c "SELECT password FROM customer LIMIT 1;"       # denied
psql -h localhost -U rors_report -d grp_binarysisters_projectdb -c "UPDATE menu_item SET price = price + 1;"     # denied
psql -h localhost -U rors_app    -d grp_binarysisters_projectdb -c "SELECT COUNT(*) FROM menu_item;"            # allowed
psql -h localhost -U rors_app    -d grp_binarysisters_projectdb -c "DELETE FROM orders;"                        # denied
psql -h localhost -U rors_app    -d grp_binarysisters_projectdb -c "CREATE DATABASE hack;"                      # denied
psql -h localhost -U rors_app    -d postgres -c "SELECT 1;"                                                     # denied (no CONNECT)
```
