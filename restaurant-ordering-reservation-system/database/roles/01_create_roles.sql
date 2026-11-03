-- 01_create_roles.sql   (cluster-wide objects: roles are NOT stored inside one database)
-- Run as the PostgreSQL administrator (postgres), connected to ANY database, for example:
--   psql -h localhost -U postgres -d postgres -f database/roles/01_create_roles.sql
--
-- Design (see docs/user-roles.md and docs/user-role-setup.md):
--   group roles  (NOLOGIN)  = sets of privileges
--   login roles  (LOGIN)    = accounts that authenticate; they receive privileges only by membership
-- No account below is a superuser and none can create databases or roles (least privilege).
-- Passwords are NOT in this file. They are typed at a hidden prompt by 03_set_passwords.psql.

\set ON_ERROR_STOP on

-- ------------------------------------------------------------------ group roles
SELECT format('CREATE ROLE %I NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION', r)
FROM (VALUES ('rors_runtime_grp'),    -- web application runtime
             ('rors_readonly_grp'),   -- reports / auditor (no access to credential columns)
             ('rors_maint_grp'),      -- maintenance + monitoring (Activity 5)
             ('rors_backup_grp'),     -- backup operator (Activity 6)
             ('rors_admin_grp')       -- restaurant database administrator (not a superuser)
     ) AS v(r)
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = v.r)
\gexec

-- ------------------------------------------------------------------ login roles
SELECT format('CREATE ROLE %I LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION CONNECTION LIMIT %s', r, lim)
FROM (VALUES ('rors_app',    20),   -- the account the PHP application connects with
             ('rors_report', 5),    -- auditor / read-only reporting
             ('rors_maint',  3),    -- routine maintenance / monitoring
             ('rors_backup', 2),    -- pg_dump operator
             ('rors_dba',    3)     -- day-to-day administrator
     ) AS v(r, lim)
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = v.r)
\gexec

-- ------------------------------------------------------------------ memberships
GRANT rors_runtime_grp  TO rors_app;
GRANT rors_readonly_grp TO rors_report;
GRANT rors_maint_grp    TO rors_maint;
GRANT rors_backup_grp   TO rors_backup;
GRANT rors_admin_grp    TO rors_dba;

-- ------------------------------------------------------------------ built-in predefined roles
-- pg_monitor      : read statistics views (pg_stat_activity of other sessions, etc.)
-- pg_read_all_data: SELECT on every table/view/sequence -> exactly what pg_dump needs (PG 14+)
-- pg_maintain     : VACUUM / ANALYZE / REINDEX / CLUSTER on all tables (PG 17+)
GRANT pg_monitor       TO rors_maint_grp;
GRANT pg_monitor       TO rors_admin_grp;
GRANT pg_read_all_data TO rors_backup_grp;

SELECT 'GRANT pg_maintain TO rors_maint_grp'
WHERE current_setting('server_version_num')::int >= 170000
\gexec

-- Safety limit: a runaway query from the application is cancelled after 30 seconds.
ALTER ROLE rors_app SET statement_timeout = '30s';
-- Reporting queries may run longer than web requests, but are still bounded.
ALTER ROLE rors_report SET statement_timeout = '60s';
