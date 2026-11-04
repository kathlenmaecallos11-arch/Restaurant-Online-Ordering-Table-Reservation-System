## Access-control plan

Customers and staff have no PostgreSQL login. Each login account receives privileges only through a `NOLOGIN` group role. Source: `database/roles/01_create_roles.sql`, `02_grants.sql`.

| Login account | Group role | Application / DBA role served | Responsibility | Required privileges |
|---|---|---|---|---|
| `rors_app` | `rors_runtime_grp` | Application runtime (all Customer, Staff and Administrator sessions) | Runs all queries of the PHP application | `CONNECT` on `grp_binarysisters_projectdb`; `USAGE` on schema `public`; `customer`, `orders`, `payment`: SELECT, INSERT, UPDATE; `menu_item`, `restaurant_table`, `reservation`, `staff`: SELECT, INSERT, UPDATE, DELETE; `order_item`: SELECT, INSERT; all sequences: USAGE, SELECT; views `v_order_summary`, `v_reservation_schedule`: SELECT. No DELETE on `orders`, `order_item`, `payment`; no CREATE, DROP or TRUNCATE. Connection limit 20, statement timeout 30 s |
| `rors_report` | `rors_readonly_grp` | Auditor / read-only reporting | View records and reports without changing anything | `CONNECT`; `USAGE` on `public`; SELECT on `menu_item`, `restaurant_table`, `orders`, `order_item`, `reservation`, `payment` and views `v_customer_directory`, `v_staff_directory`, `v_order_summary`, `v_reservation_schedule`. No access to base tables `customer` and `staff` (password hashes). No INSERT, UPDATE, DELETE. Connection limit 5, statement timeout 60 s |
| `rors_maint` | `rors_maint_grp` | Database maintenance (Activity 5) | VACUUM, ANALYZE, monitoring | `CONNECT`; `USAGE` on `public`; `pg_monitor`; `pg_maintain` (PostgreSQL 17+). No SELECT on application data |
| `rors_backup` | `rors_backup_grp` | Backup operator (Activity 6) | Runs `pg_dump` | `CONNECT`; `USAGE` on `public`; `pg_read_all_data`. Cannot modify anything |
| `rors_dba` | `rors_admin_grp` | Restaurant database administrator | Day-to-day administration | `CONNECT`; `USAGE` and `CREATE` on `public`; ALL on all tables and sequences; `pg_monitor`. Not a superuser; cannot create roles or databases |
| `postgres` | none (superuser) | Provisioning only | Creates the database, roles, schema and seed data; owns the tables | Superuser. Never used by the application |

Notes:

* The group roles are `NOLOGIN`. Nobody can log in as them.
* No login or group role has `SUPERUSER`, `CREATEDB`, `CREATEROLE` or `REPLICATION`.
* `PUBLIC` has no privileges on the database, the schema, the tables or the sequences (`REVOKE ALL ... FROM PUBLIC`).
* The differences between Customer, Staff and Administrator are enforced by the PHP code, because `rors_app` is shared by all of them.
* Passwords are never stored in the repository. They are typed at hidden prompts and kept in the local `.env`.

## Sample application accounts

Local test accounts come from `database/seeds/001_seed_data.sql` (fictional data; passwords are in that file and are not repeated here).

| Role | Email |
|---|---|
| Administrator | `admin@rors.example` |
| Staff | `staff@rors.example` |
| Customer | `maria.santos@rors.example` (also `juan.delacruz`, `ana.reyes`, `pedro.garcia`, `liza.ramos` at `@rors.example`) |

## How a tester exercises each role

1. **Customer:** `/login`, add items on `/menu`, open `/cart`, place the order, check `/orders`. Then `/reservations/new`, choose date, time and guests, and reserve. Opening `/admin` must not work for a customer.
2. **Staff:** `/staff/login`, open `/admin/orders` and change a status; open `/admin/payments` and record a payment. Opening `/admin/staff` or `/admin/menu/edit` must show **Access denied**.
3. **Administrator:** `/staff/login`, then `/admin/menu/edit` (create an item), `/admin/tables/edit` and `/admin/staff`.
4. **Database accounts:** run the real-login tests in `ACCESS_CONTROL_TEST_REPORT.md` (section 2.2) as `rors_app` and `rors_report`.
