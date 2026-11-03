-- 02_grants.sql   (database / schema / object privileges for grp_binarysisters_projectdb)
-- Run as postgres (the owner of the objects), connected to the PROJECT database:
--   psql -h localhost -U postgres -d grp_binarysisters_projectdb -f database/roles/02_grants.sql
--
-- Reminders (Activity 4 Part C):
--   * CONNECT does not grant table access.   * USAGE on a schema does not grant table access.
--   * Table privileges do not cover sequences (SERIAL columns need sequence privileges).
--   * Privileges on existing objects do not cover objects created later (default privileges).

\set ON_ERROR_STOP on

-- ------------------------------------------------------------------ database level
REVOKE ALL ON DATABASE grp_binarysisters_projectdb FROM PUBLIC;
GRANT CONNECT ON DATABASE grp_binarysisters_projectdb
    TO rors_runtime_grp, rors_readonly_grp, rors_maint_grp, rors_backup_grp, rors_admin_grp;

-- ------------------------------------------------------------------ schema level
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public
    TO rors_runtime_grp, rors_readonly_grp, rors_maint_grp, rors_backup_grp, rors_admin_grp;
GRANT CREATE ON SCHEMA public TO rors_admin_grp;

-- ------------------------------------------------------------------ clean slate on existing objects
REVOKE ALL ON ALL TABLES    IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES    IN SCHEMA public FROM rors_runtime_grp, rors_readonly_grp, rors_maint_grp, rors_backup_grp;

-- ------------------------------------------------------------------ application runtime (rors_app)
-- Only the operations the PHP code really performs; nothing is granted "just in case".
GRANT SELECT, INSERT, UPDATE          ON customer, orders, payment TO rors_runtime_grp;
GRANT SELECT, INSERT, UPDATE, DELETE  ON menu_item, restaurant_table, reservation, staff TO rors_runtime_grp;
GRANT SELECT, INSERT                  ON order_item TO rors_runtime_grp;   -- items are never edited or deleted by the app
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO rors_runtime_grp; -- needed for SERIAL inserts
GRANT SELECT ON v_order_summary, v_reservation_schedule TO rors_runtime_grp;

-- ------------------------------------------------------------------ read-only / auditor (rors_report)
-- Credential columns are protected by simply NOT granting customer and staff; the views expose
-- everything useful about them except the password hash.
GRANT SELECT ON menu_item, restaurant_table, orders, order_item, reservation, payment TO rors_readonly_grp;
GRANT SELECT ON v_customer_directory, v_staff_directory, v_order_summary, v_reservation_schedule
    TO rors_readonly_grp;

-- ------------------------------------------------------------------ maintenance (rors_maint)
-- VACUUM/ANALYZE come from pg_maintain (PG 17+) and monitoring from pg_monitor (see 01).
-- This role gets NO SELECT on application data.

-- ------------------------------------------------------------------ backup (rors_backup)
-- Read access comes from pg_read_all_data (see 01); no INSERT/UPDATE/DELETE of any kind.

-- ------------------------------------------------------------------ administrator (rors_dba)
GRANT ALL ON ALL TABLES    IN SCHEMA public TO rors_admin_grp;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO rors_admin_grp;

-- ------------------------------------------------------------------ default privileges (future objects)
-- New tables/sequences created by postgres are automatically manageable by the administrator group.
-- Runtime/read-only groups deliberately get NO default privileges: every new object needs a
-- conscious GRANT so a new table with sensitive data is never exposed by accident.
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES    TO rors_admin_grp;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO rors_admin_grp;
