-- 01_roles_and_grants.sql  (Activity 4, Parts C and D) -- GENERIC starting point, tune in 03_.
-- Run as the PostgreSQL administrator, connected to the PROJECT database:
--   psql -h localhost -U postgres -d <PROJECT_DB> -v prefix=g03 -v dbname=<PROJECT_DB> `
--        -v schema=public -v owner=postgres -f 01_roles_and_grants.sql
-- Variables:  prefix (required, e.g. g03)   dbname (required)   schema (default public)
--             owner = role that OWNS the application's tables (default postgres)
-- Safe to re-run. No passwords are created here (see 02_set_passwords.psql).

\set ON_ERROR_STOP on
\if :{?schema}
\else
  \set schema public
\endif
\if :{?owner}
\else
  \set owner postgres
\endif

-- names are built from the prefix because roles are cluster-wide
\set grp_runtime  :prefix _runtime_grp
\set grp_readonly :prefix _readonly_grp
\set grp_maint    :prefix _maint_grp
\set grp_backup   :prefix _backup_grp
\set login_app    :prefix _app
\set login_report :prefix _report
\set login_maint  :prefix _maint
\set login_backup :prefix _backup

-- ---------------------------------------------------------------- group roles (NOLOGIN)
SELECT format('CREATE ROLE %I NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION', r)
FROM unnest(ARRAY[:'grp_runtime', :'grp_readonly', :'grp_maint', :'grp_backup']) AS r
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = r)
\gexec

-- ---------------------------------------------------------------- login roles (no password yet)
SELECT format('CREATE ROLE %I LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION CONNECTION LIMIT 10', r)
FROM unnest(ARRAY[:'login_app', :'login_report', :'login_maint', :'login_backup']) AS r
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = r)
\gexec

-- ---------------------------------------------------------------- memberships
GRANT :"grp_runtime"  TO :"login_app";
GRANT :"grp_readonly" TO :"login_report";
GRANT :"grp_maint"    TO :"login_maint";
GRANT :"grp_backup"   TO :"login_backup";

-- predefined roles: monitoring (PG10+), read-everything for pg_dump (PG14+), maintenance (PG17+)
GRANT pg_monitor       TO :"grp_maint";
GRANT pg_read_all_data TO :"grp_backup";
SELECT format('GRANT pg_maintain TO %I', :'grp_maint')
WHERE current_setting('server_version_num')::int >= 170000
\gexec

-- ---------------------------------------------------------------- database + schema access
REVOKE ALL ON DATABASE :"dbname" FROM PUBLIC;
GRANT CONNECT ON DATABASE :"dbname" TO :"grp_runtime", :"grp_readonly", :"grp_maint", :"grp_backup";

REVOKE ALL ON SCHEMA :"schema" FROM PUBLIC;
GRANT USAGE ON SCHEMA :"schema" TO :"grp_runtime", :"grp_readonly", :"grp_maint", :"grp_backup";

-- ---------------------------------------------------------------- object privileges
REVOKE ALL ON ALL TABLES    IN SCHEMA :"schema" FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA :"schema" FROM PUBLIC;

-- runtime: starting point = DML on all tables; tighten in 03_tune_least_privilege.sql
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA :"schema" TO :"grp_runtime";
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA :"schema" TO :"grp_runtime";

-- read-only / auditor: SELECT only (hide credential tables/columns in 03_)
GRANT SELECT ON ALL TABLES IN SCHEMA :"schema" TO :"grp_readonly";

-- maintenance: gets NO table privileges here (pg_maintain / ownership handle VACUUM, ANALYZE)
-- backup:      reads everything through pg_read_all_data and can change nothing

-- ---------------------------------------------------------------- future objects
-- Deliberately NO default privileges for runtime/readonly: each new table needs a conscious GRANT.
-- (To allow it anyway:  ALTER DEFAULT PRIVILEGES FOR ROLE :"owner" IN SCHEMA :"schema" GRANT SELECT ON TABLES TO ...;)

\echo 'Roles and grants applied. Now run 02_set_passwords.psql, tune in 03_, then test with 04_.'
