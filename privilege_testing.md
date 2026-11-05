# Privilege Testing Results
Restaurant Online Ordering & Table Reservation System · Group Binary Sisters · COMP 018 – Database Administration

**Project:** Restaurant Online Ordering & Table Reservation System  
**Database:** `grp_binarysisters_projectdb` (PostgreSQL 18)  
**Related files:** `access_control_plan.md`, `security_recommendation.md`, `database/roles/04_verify_privileges.sql`

---

## 1. Purpose and Method
The goal is to prove that every database account has only the privileges it needs (least privilege). Two kinds of tests were used:
1. **Automatic test matrix:** `04_verify_privileges.sql` is run as `postgres`. It becomes each group role with `SET LOCAL ROLE`, tries one statement, reports `ALLOWED` or `DENIED`, and always rolls back, so no data changes.
2. **Real-login tests:** We log in with `psql` as each real account. `SET ROLE` cannot test login or `CONNECT`, so this part is needed.

*Passwords were typed at hidden prompts and are not shown in any screenshot.*

---

## 2. Accounts Tested

| Login account | Group role | Purpose |
| :--- | :--- | :--- |
| `rors_app` | `rors_runtime_grp` | Runs the PHP application |
| `rors_report` | `rors_readonly_grp` | Read-only reports, no password hashes |
| `rors_maint` | `rors_maint_grp` | `VACUUM` / `ANALYZE` and monitoring, no data access |
| `rors_backup` | `rors_backup_grp` | Backups with `pg_dump` (read only) |
| `rors_dba` | `rors_admin_grp` | Database administration, not a superuser |

---

## 3. Automatic Test Matrix (26 tests)
**Command:** `psql -h localhost -U postgres -d grp_binarysisters_projectdb -f database/roles/04_verify_privileges.sql`

| # | Role | Statement | Expected | Actual | Result |
|---|---|---|---|---|---|
| 1 | `rors_runtime_grp` | `SELECT * FROM menu_item LIMIT 1` | ALLOWED | ALLOWED | PASS |
| 2 | `rors_runtime_grp` | `INSERT INTO customer (...)` | ALLOWED | ALLOWED | PASS |
| 3 | `rors_runtime_grp` | `UPDATE menu_item SET price = price WHERE false` | ALLOWED | ALLOWED | PASS |
| 4 | `rors_runtime_grp` | `DELETE FROM orders WHERE false` | DENIED | DENIED (insufficient_privilege) | PASS |
| 5 | `rors_runtime_grp` | `DELETE FROM order_item WHERE false` | DENIED | DENIED (insufficient_privilege) | PASS |
| 6 | `rors_runtime_grp` | `DELETE FROM payment WHERE false` | DENIED | DENIED (insufficient_privilege) | PASS |
| 7 | `rors_runtime_grp` | `CREATE TABLE public.should_fail (id int)` | DENIED | DENIED (insufficient_privilege) | PASS |
| 8 | `rors_runtime_grp` | `DROP TABLE public.orders` | DENIED | DENIED (insufficient_privilege) | PASS |
| 9 | `rors_runtime_grp` | `TRUNCATE public.customer` | DENIED | DENIED (insufficient_privilege) | PASS |
| 10 | `rors_readonly_grp` | `SELECT * FROM v_order_summary LIMIT 1` | ALLOWED | ALLOWED | PASS |
| 11 | `rors_readonly_grp` | `SELECT * FROM menu_item LIMIT 1` | ALLOWED | ALLOWED | PASS |
| 12 | `rors_readonly_grp` | `SELECT * FROM v_customer_directory LIMIT 1` | ALLOWED | ALLOWED | PASS |
| 13 | `rors_readonly_grp` | `UPDATE menu_item SET price = price WHERE false` | DENIED | DENIED (insufficient_privilege) | PASS |
| 14 | `rors_readonly_grp` | `DELETE FROM reservation WHERE false` | DENIED | DENIED (insufficient_privilege) | PASS |
| 15 | `rors_readonly_grp` | `INSERT INTO menu_item (...)` | DENIED | DENIED (insufficient_privilege) | PASS |
| 16 | `rors_readonly_grp` | `SELECT password FROM customer LIMIT 1` | DENIED | DENIED (insufficient_privilege) | PASS |
| 17 | `rors_readonly_grp` | `SELECT * FROM staff LIMIT 1` | DENIED | DENIED (insufficient_privilege) | PASS |
| 18 | `rors_maint_grp` | `SELECT * FROM pg_stat_activity LIMIT 1` | ALLOWED | ALLOWED | PASS |
| 19 | `rors_maint_grp` | `SELECT * FROM customer LIMIT 1` | DENIED | DENIED (insufficient_privilege) | PASS |
| 20 | `rors_maint_grp` | `UPDATE menu_item SET price = price WHERE false` | DENIED | DENIED (insufficient_privilege) | PASS |
| 21 | `rors_backup_grp` | `SELECT * FROM customer LIMIT 1` | ALLOWED | ALLOWED | PASS |
| 22 | `rors_backup_grp` | `UPDATE menu_item SET price = price WHERE false` | DENIED | DENIED (insufficient_privilege) | PASS |
| 23 | `rors_backup_grp` | `DELETE FROM orders WHERE false` | DENIED | DENIED (insufficient_privilege) | PASS |
| 24 | `rors_admin_grp` | `SELECT * FROM customer LIMIT 1` | ALLOWED | ALLOWED | PASS |
| 25 | `rors_admin_grp` | `CREATE TABLE public.admin_scratch (id int)` | ALLOWED | ALLOWED | PASS |
| 26 | `rors_admin_grp` | `CREATE ROLE should_not_exist` | DENIED | DENIED (insufficient_privilege) | PASS |

**Summary:** 26 PASS, 0 FAIL.

![Automatic Test Matrix](https://raw.githubusercontent.com/kathlenmaecallos11-arch/Restaurant-Online-Ordering-Table-Reservation-System/main/evidence/testmatrix.png)

---

## 4. Role Attributes, Memberships and PUBLIC Privileges
* No `rors_*` role is a superuser, and none can create databases or roles (`rolsuper`, `rolcreatedb` and `rolcreaterole` are all `f`).
* **Connection limits:** `rors_app` 20, `rors_report` 5, `rors_maint` 3, `rors_dba` 3, `rors_backup` 2.
* Each login account is a member of exactly one group role. The group roles also hold the built-in roles `pg_monitor` (maint, admin), `pg_maintain` (maint) and `pg_read_all_data` (backup).
* The effective table privilege matrix shows that only `rors_runtime_grp` can insert or update the application tables, and only `rors_runtime_grp` has `DELETE` on `menu_item` and `reservation`. `rors_readonly_grp` has no access to `customer`.
* `PUBLIC` privileges left on tables in `public`: 0 rows.

![Role Attributes](https://raw.githubusercontent.com/kathlenmaecallos11-arch/Restaurant-Online-Ordering-Table-Reservation-System/main/evidence/rolesattributes.png)
![Role Memberships](https://raw.githubusercontent.com/kathlenmaecallos11-arch/Restaurant-Online-Ordering-Table-Reservation-System/main/evidence/rolesprivilege.png)

---

## 5. Real-Login Tests

### 5.1 rors_app
| Command | Expected | Actual | Result |
|---|---|---|---|
| `SELECT COUNT(*) FROM orders;` | Allowed | `count = 60` | PASS |
| `DELETE FROM orders WHERE false;` | Denied | `permission denied for table orders` | PASS |
| `CREATE DATABASE should_fail;` | Denied | `permission denied to create database` | PASS |
| `DELETE FROM reservation WHERE false;` | Allowed | `DELETE 0` | PASS |
| `\c postgres rors_app` | Denied (least privilege) | Connected to database "postgres" | **FAIL - Finding 1** |

![rors_app real login](https://raw.githubusercontent.com/kathlenmaecallos11-arch/Restaurant-Online-Ordering-Table-Reservation-System/main/evidence/rors_app.png)

### 5.2 rors_report
| Command | Expected | Actual | Result |
|---|---|---|---|
| `SELECT * FROM v_customer_directory LIMIT 3;` | Allowed | 3 rows, no password column | PASS |
| `SELECT password FROM customer LIMIT 1;` | Denied | `permission denied for table customer` | PASS |

![rors_report real login](https://raw.githubusercontent.com/kathlenmaecallos11-arch/Restaurant-Online-Ordering-Table-Reservation-System/main/evidence/rors_report.png)

### 5.3 rors_maint
*(The first login attempt used a wrong password and was rejected (`FATAL: password authentication failed`). The second attempt was correct.)*

| Command | Expected | Actual | Result |
|---|---|---|---|
| `SELECT * FROM customer LIMIT 1;` | Denied | `permission denied for table customer` | PASS |
| `VACUUM ANALYZE menu_item;` | Allowed | `VACUUM` | PASS |

![rors_maint real login](https://raw.githubusercontent.com/kathlenmaecallos11-arch/Restaurant-Online-Ordering-Table-Reservation-System/main/evidence/rors_maint.png)

### 5.4 rors_backup
| Command | Expected | Actual | Result |
|---|---|---|---|
| `SELECT customer_id, first_name FROM customer LIMIT 1;` | Allowed | 1 row | PASS |
| `DELETE FROM orders WHERE false;` | Denied | `permission denied for table orders` | PASS |

![rors_backup real login](https://raw.githubusercontent.com/kathlenmaecallos11-arch/Restaurant-Online-Ordering-Table-Reservation-System/main/evidence/rors_backup.png)

### 5.5 rors_dba
| Command | Expected | Actual | Result |
|---|---|---|---|
| `CREATE TABLE public.dba_scratch (id int);` | Allowed | `CREATE TABLE` | PASS |
| `DROP TABLE public.dba_scratch;` | Allowed | `DROP TABLE` | PASS |
| `CREATE DATABASE should_fail;` | Denied | `permission denied to create database` | PASS |

![rors_dba real login](https://raw.githubusercontent.com/kathlenmaecallos11-arch/Restaurant-Online-Ordering-Table-Reservation-System/main/evidence/rows_dba.png)

---

## 6. Finding and Fix
* **Finding 1:** `rors_app` can connect to the `postgres` maintenance database. The setup script runs `REVOKE ALL ... FROM PUBLIC` on the project database only, so `postgres` and `template1` still allow `CONNECT` to everyone.

**Fix (run as postgres):**
```sql
REVOKE CONNECT ON DATABASE postgres FROM PUBLIC;
REVOKE CONNECT ON DATABASE template1 FROM PUBLIC;
