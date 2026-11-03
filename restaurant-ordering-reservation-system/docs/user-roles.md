# Application user roles documentation

Restaurant Online Ordering & Table Reservation System — Group Binary Sisters (COMP 018)

The roles **inside the application** (what a person can do after logging in) are separate from the roles **inside
PostgreSQL** (what a database account can do). End users do **not** have PostgreSQL logins: the web application connects
with one runtime account and enforces the application roles in code. Names and responsibilities below match
`database/roles/` (Activity 4).

## 1. Application roles

| Application role | Who | Responsibilities in the application | Functions and data access | Intended database role |
|---|---|---|---|---|
| Customer | Restaurant guest (self-registered, table `customer`) | Browse menu, order food, reserve tables, follow status | Register, log in, edit own profile (C/R/U); search/view menu (R); create orders and reservations (C); view and cancel only **own** pending orders/reservations (R/U). Cannot see other customers' data. | Served by the application runtime account → `rors_runtime_grp` |
| Staff | Waiter / counter staff (table `staff`, role `staff`) | Run daily operations | Read orders, reservations, payments, tables, menu; update order status, reservation status, payment status; record payments; toggle menu availability. **No** create/delete of menu items or tables, no staff or customer administration. | `rors_runtime_grp` (restrictions enforced by the application) |
| Administrator | Restaurant manager (table `staff`, role `admin`) | Manage the catalogue and accounts | Everything Staff can do + create/edit/delete menu items and tables, delete reservations, list customers (no password hashes), create/edit/delete staff accounts. | `rors_runtime_grp` in the application; **separate** DBA role below for the database itself |
| Application runtime (system account) | The PHP application | Connect to PostgreSQL for every request | Only operations the code performs (see table in §2) | Login `rors_app` ∈ `rors_runtime_grp` |

Application roles that never get a database login: Customer, Staff, Administrator. Their identity is a row in `customer` / `staff` and a PHP session.

## 2. Database roles (Activity 4 plan, implemented in `database/roles/`)

| Login role (account) | Group role | Application / DBA role served | Responsibility | Privileges |
|---|---|---|---|---|
| `rors_app` | `rors_runtime_grp` | Application runtime (Customer, Staff, Administrator sessions) | Normal application operations | `customer`, `orders`, `payment`: SELECT, INSERT, UPDATE · `menu_item`, `restaurant_table`, `reservation`, `staff`: SELECT, INSERT, UPDATE, DELETE · `order_item`: SELECT, INSERT · sequences: USAGE, SELECT · views `v_order_summary`, `v_reservation_schedule`: SELECT. No DDL, no TRUNCATE, no DELETE on orders/payments/order lines. |
| `rors_report` | `rors_readonly_grp` | Viewer / auditor | Reporting and inspection | SELECT on `menu_item`, `restaurant_table`, `orders`, `order_item`, `reservation`, `payment` and the four views. **No** access to `customer` / `staff` base tables (password hashes). |
| `rors_maint` | `rors_maint_grp` | Database maintenance (Activity 5) | VACUUM, ANALYZE, monitoring | `pg_monitor`, `pg_maintain` (PG 17+); no SELECT on application data |
| `rors_backup` | `rors_backup_grp` | Backup operator (Activity 6) | `pg_dump` | `pg_read_all_data`; cannot modify anything |
| `rors_dba` | `rors_admin_grp` | Restaurant database administrator | Day-to-day administration, not a superuser | ALL on tables/sequences of `public`, CREATE on schema, `pg_monitor`; cannot create roles or databases |
| `postgres` | — (superuser) | Provisioning only | Creates the DB, roles, migrations | Never used by the application |

Group roles are `NOLOGIN`; accounts receive privileges only through membership. No account has SUPERUSER, CREATEDB or CREATEROLE.
Passwords are **not** stored in the repository: they are entered at hidden prompts (`database/roles/03_set_passwords.psql`)
and copied into the local `.env`.

## 3. Sample application accounts (local test data from `database/seeds/001_seed_data.sql`)

| Role | Email | Sample password |
|---|---|---|
| Administrator | `admin@rors.example` | `Admin123!` |
| Staff | `staff@rors.example` | `Staff123!` |
| Customer | `maria.santos@rors.example` (also juan.delacruz, ana.reyes, pedro.garcia, liza.ramos `@rors.example`) | `Password123!` |

These are fictional sample credentials for local testing only; change or delete them in any real deployment.

## 4. How a tester exercises each role
1. Customer: `/login` → add items on `/menu` → `/cart` → place order → `/orders`; `/reservations/new` → pick date/time/guests → reserve.
2. Staff: `/staff/login` → `/admin/orders` → change a status; `/admin/payments` → record payment. Open `/admin/staff` → expect **Access denied**.
3. Administrator: `/staff/login` → `/admin/menu/edit` (create item), `/admin/tables/edit`, `/admin/staff`.
4. Database roles: follow `docs/user-role-setup.md` §6 (real logins as `rors_report` and `rors_app`).
