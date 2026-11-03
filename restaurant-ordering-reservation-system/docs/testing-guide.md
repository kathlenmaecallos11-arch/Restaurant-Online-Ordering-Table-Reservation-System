# Guide for groups that test this project (Activity 3 Part D, Activity 4–6 set-up)

Use a clean local environment and **only** this repository and its documentation.

1. Clone: `git clone <REPOSITORY_URL>` (branch/tag listed in the tracker).
2. Required software: PostgreSQL 14+ (18 recommended; `pg_maintain` needs 17+), PHP 8.1+ with `pdo_pgsql`, `psql` on PATH.
3. Keep this project's database separate from the others: the database is `grp_binarysisters_projectdb`.
   **Roles are cluster-wide**: the names `rors_*` do not collide with other groups' roles.
4. Build: `.\database\setup.ps1 -WithRoles` (hidden prompts for passwords).  `.\database\setup.ps1` alone creates only schema + data.
5. Configure `.env` from `.env.example`; start `php -S localhost:8000 -t app/public`.
6. Exercise the roles listed in `docs/user-roles.md` §3–4 (admin, staff, customer sample logins).
7. Database checks: `tests/crud_tests.sql` and `database/roles/04_verify_privileges.sql` (expected: all PASS).
8. Record the outcome in the **Activity 3 Testing Log** tab; send missing steps / errors to the owners. Do not edit this repository.

## Inventory for Activity 4 / 5 / 6 (so you do not have to hunt)
| Item | Value |
|---|---|
| Database / schema | `grp_binarysisters_projectdb` / `public` |
| Owner of objects | `postgres` |
| Tables | customer, menu_item, restaurant_table, staff, orders, order_item, reservation, payment |
| Views | v_customer_directory, v_staff_directory, v_order_summary, v_reservation_schedule |
| Sequences | one per SERIAL column (8) |
| Credential columns | `customer.password`, `staff.password` (bcrypt hashes) |
| Extensions | btree_gist, pgcrypto |
| Write-heavy tables | orders, order_item, payment, reservation |
| Suggested "leaf" row for recovery drill | `payment` (nothing references it) |
| Suggested query for EXPLAIN | `SELECT * FROM orders WHERE customer_id = 1 ORDER BY order_date DESC;` |
| Application's own least-privilege plan | `docs/user-role-setup.md` |
