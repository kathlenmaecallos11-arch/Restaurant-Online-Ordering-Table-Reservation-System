# Troubleshooting

## 1. PostgreSQL / psql
| Symptom | Cause | Fix |
|---|---|---|
| `'psql' is not recognized` | `bin` folder not on PATH | Add `C:\Program Files\PostgreSQL\18\bin` to the PATH environment variable, open a **new** terminal. |
| `connection refused` / `could not connect to server` | Service stopped or wrong port | `services.msc` → `postgresql-x64-18` → Start. Check the port with `SHOW port;` (default 5432). |
| `password authentication failed for user "..."` | Wrong password or `DB_USER` not created | Re-run `database\roles\03_set_passwords.psql`; check `.env`. Never paste passwords into screenshots. |
| `FATAL: database "grp_binarysisters_projectdb" does not exist` | Step 000 not run | Run `database\setup.ps1`. |
| `ERROR: could not open extension control file ".../btree_gist.control"` (or pgcrypto) | contrib extension missing (some Linux packages) | Install `postgresql-contrib` / `postgresql-18-contrib` or the "Additional modules" package. |
| `ERROR: permission denied to create extension` | Migrations run by a non-superuser | Run migrations as `postgres` (the setup scripts do). |
| `WARNING: Console code page (437) differs from Windows code page (1252)` | Windows console encoding | Harmless for ASCII data; optional: `chcp 1252` before psql. |
| `ERROR: relation "customer" already exists` | Migrations run twice | `.\database\setup.ps1 -Reset` (local DB only) or drop the database. |
| `Order N must contain at least one order item` while loading your own data | Business rule 9 | Insert the order and its `order_item` rows in the same `BEGIN … COMMIT`. |
| `conflicting key value violates exclusion constraint "ex_reservation_no_overlap"` | Table already booked within 2 hours | Choose another table/time (this is the rule working). |
| `permission denied for table …` when the app runs with `rors_app` | A needed privilege is missing | Compare with `docs/user-role-setup.md` §4; add the grant to `database/roles/02_grants.sql` and re-run it. |
| `permission denied for sequence …_seq` | Sequence privileges forgotten | `GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO rors_runtime_grp;` |

## 2. PHP
| Symptom | Fix |
|---|---|
| `'php' is not recognized` | Install PHP 8.1+ (e.g. from windows.php.net), unzip, add the folder to PATH. |
| `The pdo_pgsql PHP extension is not enabled` / `could not find driver` | Copy `php.ini-development` to `php.ini`, then uncomment `extension=pdo_pgsql` and `extension=pgsql`; set `extension_dir = "ext"`. Run `php -m` and confirm both appear. The PostgreSQL `bin` folder must be on PATH (it contains `libpq.dll`). |
| Blank page / "Something went wrong" | Set `APP_DEBUG=true` in your **local** `.env`, reload, read the message (set it back to `false` afterwards). Also check the terminal running `php -S`. |
| `SQLSTATE[08006] … FATAL: no pg_hba.conf entry` | Connecting from another host: use `DB_HOST=localhost`. |
| CSS missing / every URL 404 | Start the server with `-t app/public` from the repository root. |
| Logging in redirects back to login | Cookies blocked, or two different hostnames (`localhost` vs `127.0.0.1`): use one. |
| Port 8000 busy | `php -S localhost:8080 -t app/public`. |

## 3. Database design questions
* "Why can't I delete a menu item?" It appears in past orders (`ON DELETE RESTRICT`). Mark it unavailable instead.
* "Why does cancelling an order not delete it?" History must stay; cancelling sets `order_status = 'cancelled'`.
* "Seed passwords do not work": the seed needs the `pgcrypto` extension; re-run the seed after `CREATE EXTENSION pgcrypto;`.
