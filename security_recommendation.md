# Security Recommendations

**Project:** Restaurant Online Ordering & Table Reservation System (Binary Sisters)
**Database:** `grp_binarysisters_projectdb` (PostgreSQL 18)
**Based on:** the privilege tests in `privilege_testing.md` / `evidence/`, `database/roles/*.sql`, and a review of the PHP code in `app/src/`.

## 1. What already works well

- 26 of 26 automatic permitted/denied tests passed (`evidence/testmatrix.png`, `evidence/summary 26.png`).
- No role is a superuser and none can create databases or roles (`evidence/atmempriv.png`).
- `PUBLIC` has no privileges left on the tables in `public` (`evidence/publicprivilege.png`).
- The read-only account cannot read `customer.password` or the `staff` table (`evidence/rors_report.png`).
- The application account cannot `DELETE` from `orders`, `order_item` or `payment`, so order and payment history is kept (`evidence/rors_app.png`).
- The PHP code uses prepared statements, CSRF tokens, bcrypt hashes (`password_hash`) and regenerates the session id at login.

## 2. Recommendations

| # | Priority | Finding | Why it matters | Recommendation |
|---|---|---|---|---|
| 1 | High (Resolved) | `rors_app` could previously connect to the `postgres` maintenance database (`evidence/rors_app.png`). `REVOKE ... FROM PUBLIC` was only done on the project database, so `postgres` and `template1` still allowed `CONNECT` to everyone. | An application account should only reach its own database. Extra access gives an attacker more to explore (for example role names and other database names). | **FIXED:** Executed `REVOKE CONNECT ON DATABASE postgres FROM PUBLIC;` and `REVOKE CONNECT ON DATABASE template1 FROM PUBLIC;` as superuser. Real-login tests now return permission denied as expected. Added this step to `02_grants.sql`. |
| 2 | High | The public sample passwords are weak and predictable (`Admin123!`, `Staff123!`, `Password123!`; the other accounts use full name + `@123`). They are written in `README.md` and in the seed file. | Anyone who reads the repository knows the admin login. This is fine for local testing only. | Never deploy the seed data as it is. On any shared or hosted copy, change or remove all sample accounts before use, and remove the credentials table from the README. |
| 3 | High | There is no limit on failed logins (`/login` and `/staff/login`) and the password rule is only "at least 8 characters". | Passwords can be guessed by trying many times, and the staff login controls the admin pages. | Add a failed-attempt limit per email and IP (for example 5 tries, then a short lock). Raise the password rule (longer minimum, block common passwords). Keep the same "Incorrect email or password." message. |
| 4 | Medium | One database account (`rors_app`) serves customers, staff and administrators. It can `INSERT`, `UPDATE` and `DELETE` on `staff`, including the `role` and `password` columns. | The database cannot tell a customer request from an admin request. A bug such as SQL injection or a broken access check in the PHP code could let an attacker create an admin or delete staff. | Short term: keep all role checks in `require_staff()` and review every new route. Longer term: use a second login for admin-only actions, or use views, column-level grants or row-level security so the customer part of the app cannot touch `staff`. |
| 5 | Medium | `rors_backup` uses `pg_read_all_data`, so backups contain every table, including password hashes. | A stolen backup file exposes customer and staff data. | Store backups outside the repository and outside the web folder, restrict who can read them, encrypt them, and delete old copies. `.gitignore` already blocks `*.dump`, `*.sql.gz` and `*.bak`. Keep it that way. |
| 6 | Medium | `rors_dba` has `ALL` on every table (including `DELETE` and `TRUNCATE`) and `CREATE` on the `public` schema. | It is needed for administration, but it is also the most powerful login in the project. | Use it only for administration, never in `.env`, give it a strong unique password, and enable logging (item 9). Review its privileges again after each activity. |
| 7 | Medium | The session cookie has `HttpOnly` and `SameSite=Lax` but no `Secure` flag, and sessions have no idle timeout. | On HTTP the cookie can be seen on the network, and a forgotten logged-in staff computer stays logged in. | When the site runs on HTTPS, add `'secure' => true` in `session_set_cookie_params` and add `use_only_cookies`. Add an idle timeout (for example 30 minutes) for staff sessions. |
| 8 | Medium | `/health` is open to everyone and shows the database name and the database account name (`current_database()`, `current_user`). | It tells outsiders which database and login the app uses. | Return only `{"status":"ok"}` publicly, or protect the details behind staff login. |
| 9 | Medium | No database logging is described. | Without logs it is hard to find who did what after a problem. | In `postgresql.conf` set `log_connections = on`, `log_disconnections = on` and `log_statement = 'ddl'`, then reload. Check the log for failed logins and unexpected `CREATE`/`DROP`. |
| 10 | Low | The pages do not send security headers. | Headers add a second layer against clickjacking and content sniffing. | Send `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy: same-origin` and a basic `Content-Security-Policy` from `render()` or the web server. |
| 11 | Low | `DB_SSLMODE=prefer` in `.env.example`. | `prefer` falls back to an unencrypted connection. | Use `require` (or `verify-full`) whenever the database is not on the same computer as PHP. |
| 12 | Low | `database/setup.ps1` and `access_control_plan.md` mention `database/roles/03_set_passwords.psql`, but the file is missing from `database/roles/` in the repository (only `01`, `02` and `04` are there). A template copy exists as `db-access-control/_template/02_set_passwords.psql`. | `setup.ps1 -WithRoles` calls this file, so it will fail at the password step. | Add `03_set_passwords.psql` to `database/roles/` (hidden `\password` prompts, no passwords inside), or update the setup script. |
| 13 | Low | `rors_app` can `DELETE` from `staff`, `reservation`, `menu_item` and `restaurant_table`. | The app really uses these deletes for admin pages, but a mistake or an attack removes data with no history. | Consider an `is_active` flag (soft delete) for staff and menu items, as is already done for orders. |

## 3. Suggested order of work

1. **Item 1 (Done) & Item 12:** Item 1 (database connection restriction) is fully resolved and verified. Next, address Item 12 (missing `03_set_passwords.psql` or update setup script), then run the tests again and take new screenshots.
2. Items 2 and 3: remove or change sample credentials and add a login limit before any real use.
3. Items 4 to 9: plan for the next iteration of the project.
4. Items 10, 11 and 13: improve when time allows.
