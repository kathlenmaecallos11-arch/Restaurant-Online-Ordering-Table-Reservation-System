-- 03_tune_least_privilege.sql  -- FILL IN after reading the owner's code and user-roles documentation.
-- The generic grants in 01_ give the runtime role DML on every table. Remove what the application
-- does not need and hide credentials from the read-only role. Justify every line in
-- access-control-plan.md. Run with the same -v prefix / schema variables as 01_.
--   psql -h localhost -U postgres -d <PROJECT_DB> -v prefix=g03 -v schema=public -f 03_tune_least_privilege.sql

\if :{?schema}
\else
  \set schema public
\endif
\set grp_runtime  :prefix _runtime_grp
\set grp_readonly :prefix _readonly_grp

-- EXAMPLES (uncomment and adapt; table/column names below are placeholders):
--
-- 1. The application never deletes orders or payments -> remove DELETE
-- REVOKE DELETE ON :"schema".orders, :"schema".payments FROM :"grp_runtime";
--
-- 2. Read-only account must not see password hashes: remove the table, then expose safe columns only
-- REVOKE ALL ON :"schema".users FROM :"grp_readonly";
-- GRANT SELECT (user_id, name, email, created_at) ON :"schema".users TO :"grp_readonly";
--
-- 3. Reference/lookup tables are read-only for the application
-- REVOKE INSERT, UPDATE, DELETE ON :"schema".categories FROM :"grp_runtime";
--
-- 4. Audit/log tables: application may only append
-- REVOKE UPDATE, DELETE, TRUNCATE ON :"schema".audit_log FROM :"grp_runtime";

\echo 'Edit this file for the project, then re-run it. (Nothing is changed while every line is commented out.)'
