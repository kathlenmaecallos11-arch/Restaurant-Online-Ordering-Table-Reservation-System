# Access Control Plan

**Project:** Restaurant Online Ordering & Table Reservation System (Binary Sisters)
**Database:** `grp_binarysisters_projectdb` (PostgreSQL 18)

**Rule used:** least privilege. Each account gets only what its job needs. No account used by the application is a superuser. Passwords are not stored in the repository.

## Table 1: Login accounts

| Login account | Group role | Application role served | Responsibility | Required privileges |
|---|---|---|---|---|
| `rors_app` | `rors_runtime_grp` | Customer, Staff (Cashier, Waiter, Kitchen Staff), Administrator (Manager, Administrator) | Runs the PHP application (orders, payments, reservations, menu, tables, staff) | CONNECT; USAGE on `public`; SELECT, INSERT, UPDATE on `customer`, `orders`, `payment`; SELECT, INSERT, UPDATE, DELETE on `menu_item`, `restaurant_table`, `reservation`, `staff`; SELECT, INSERT on `order_item`; USAGE, SELECT on sequences; SELECT on `v_order_summary`, `v_reservation_schedule` |
| `rors_report` | `rors_readonly_grp` | None (auditor / reporting) | Read data for reports without changing it or seeing password hashes | CONNECT; USAGE on `public`; SELECT on `menu_item`, `restaurant_table`, `orders`, `order_item`, `reservation`, `payment`; SELECT on the 4 views (`v_customer_directory`, `v_staff_directory`, `v_order_summary`, `v_reservation_schedule`) |
| `rors_maint` | `rors_maint_grp` | None (operations) | Maintenance (VACUUM, ANALYZE) and monitoring, without reading data | CONNECT; USAGE on `public`; built-in roles `pg_monitor`, `pg_maintain` |
| `rors_backup` | `rors_backup_grp` | None (operations) | Take backups with `pg_dump` | CONNECT; USAGE on `public`; built-in role `pg_read_all_data` (read only) |
| `rors_dba` | `rors_admin_grp` | None (database administrator, not the Restaurant Administrator) | Manage the database objects | CONNECT; USAGE and CREATE on `public`; ALL on tables and sequences; `pg_monitor`. Not a superuser |
| `postgres` | – | None | One-time setup only. Not used by the application | Superuser |

## Table 2: Application roles

People who use the app have no PostgreSQL logins. All three application roles use the account `rors_app` (group role `rors_runtime_grp`), and the PHP app decides what each person may do. The Cashier, Waiter and Kitchen Staff belong to the **Restaurant Staff** group (role `staff`). The Manager and the Administrator belong to the **Restaurant Administrator** group (role `admin`).

| User group | Application role | Responsibility | Required database privileges (through `rors_app`) |
|---|---|---|---|
| Customers | Customer | Register, order food and pay at checkout, reserve tables, follow and cancel own pending orders and reservations | SELECT on `menu_item`; INSERT, SELECT, UPDATE on `customer` (own profile); INSERT, SELECT, UPDATE on `orders` (cancel), `payment`, `reservation`; INSERT, SELECT on `order_item`; sequences |
| Restaurant Staff (Cashier, Waiter, Kitchen Staff) | Staff | Run daily operations: orders, reservations, tables, payments; set menu availability | SELECT on `orders`, `order_item`, `reservation`, `payment`, `restaurant_table`, `menu_item`, `customer` (name and contact shown with orders and reservations); UPDATE on `orders`, `reservation`, `payment`, `restaurant_table` (status), `menu_item` (availability); INSERT on `payment` |
| Restaurant Administrator (Manager, Administrator) | Administrator | Everything Staff do, plus manage menu items, tables, reservations and staff accounts; list customers | All of the above, plus INSERT, UPDATE, DELETE on `menu_item`, `restaurant_table`, `staff`; DELETE on `reservation`; SELECT on `customer` |

## Other protections (from the setup scripts)
- Nobody can create databases or roles (`NOCREATEDB NOCREATEROLE`); no replication.
- `PUBLIC` has no access to the project database, the `public` schema or its tables.
- Connection limits: `rors_app` 20, `rors_report` 5, `rors_maint` 3, `rors_backup` 2, `rors_dba` 3.
- Statement timeouts: 30 seconds for `rors_app`, 60 seconds for `rors_report`.
- Reports use views that leave out password hashes.
- New tables are private until someone grants access on purpose.

## Application setting
The application reads `DB_USER` and `DB_PASSWORD` from `.env` and defaults to `rors_app` (`app/config/database.php`). Each person's local `.env` must use `DB_USER=rors_app` with the password set by `03_set_passwords.psql`. `postgres` is for setup only. The older `db/` setup files and `docs/database-setup.md` still show `DB_USER=postgres` and should be updated.

## How it was checked
See `privilege_testing.md`: 26 automatic tests plus 12 real-login tests.
