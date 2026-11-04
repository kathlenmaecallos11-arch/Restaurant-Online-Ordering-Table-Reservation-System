## 5. Access-control plan

The application connects to PostgreSQL with one runtime account, so all six application roles are served by the same login account. Customers and staff have no PostgreSQL login. Each login account receives its privileges only through a group role.

| Login account | Group role | Application role served | Responsibility | Required privileges |
|---|---|---|---|---|
| `bs_app` | `bs_app_grp` | Customer, Administrator, Manager, Cashier, Waiter, Kitchen Staff (every session of the web application) | Runs all queries of the PHP application | `CONNECT` on `grp_binarysisters_projectdb`; `USAGE` on schema `public`; `customer`, `orders`, `payment`, `reservation`: SELECT, INSERT, UPDATE; `menu_item`, `restaurant_table`, `staff`: SELECT, INSERT, UPDATE, DELETE; `order_item`: SELECT, INSERT; all sequences: USAGE, SELECT. No DELETE on `orders`, `order_item`, `payment`, `customer` or `reservation`; no CREATE, DROP or TRUNCATE |
| `bs_report` | `bs_readonly_grp` | None (auditor / read-only reporting) | Views records and reports without changing anything | `CONNECT`; `USAGE` on schema `public`; SELECT on `menu_item`, `restaurant_table`, `orders`, `order_item`, `reservation`, `payment`; SELECT only on `customer` (`customer_id`, `first_name`, `last_name`, `created_at`) and `staff` (`staff_id`, `first_name`, `last_name`, `role`). No password columns, no INSERT, UPDATE or DELETE, no sequences |
| `bs_dba` | `bs_admin_grp` | None (database administrator) | Day-to-day administration of the database | `CONNECT`; `USAGE` and `CREATE` on schema `public`; ALL on all tables and sequences; `pg_monitor`. Not a superuser; cannot create roles or databases |
| `postgres` | none (superuser) | None | Provisioning only: creates the database, runs the schema and seed, owns the tables | Superuser. Never used by the application |

Notes:

* The group roles (`bs_app_grp`, `bs_readonly_grp`, `bs_admin_grp`) are `NOLOGIN`. Nobody can log in as them.
* No login or group role has `SUPERUSER`, `CREATEDB` or `CREATEROLE`.
* `PUBLIC` (everyone) has no privileges on the database, the schema, the tables or the sequences.
* The differences between Customer, Cashier, Waiter and the other roles are enforced by the PHP code, because `bs_app` is shared by all of them.