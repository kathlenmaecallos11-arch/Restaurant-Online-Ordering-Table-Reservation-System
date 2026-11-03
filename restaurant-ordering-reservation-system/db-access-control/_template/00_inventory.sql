-- 00_inventory.sql  (Activity 4, Part A: identify database objects and access requirements)
-- psql -h localhost -U postgres -d <PROJECT_DB> -v schema=public -f 00_inventory.sql
\if :{?schema}
\else
  \set schema public
\endif
\pset pager off

\echo '=== Server / database ==='
SELECT version();
SELECT current_database() AS database, pg_size_pretty(pg_database_size(current_database())) AS size,
       (SELECT rolname FROM pg_roles WHERE oid = datdba) AS db_owner
FROM pg_database WHERE datname = current_database();

\echo '=== Schemas (non-system) ==='
SELECT nspname AS schema, pg_get_userbyid(nspowner) AS owner, nspacl AS acl
FROM pg_namespace WHERE nspname NOT LIKE 'pg\_%' AND nspname <> 'information_schema' ORDER BY 1;

\echo '=== Tables, owners and size ==='
SELECT schemaname, relname AS table, pg_get_userbyid(c.relowner) AS owner, n_live_tup AS est_rows,
       pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size
FROM pg_stat_user_tables s JOIN pg_class c ON c.oid = s.relid
WHERE schemaname = :'schema' ORDER BY relname;

\echo '=== Sequences ==='
SELECT sequence_schema, sequence_name FROM information_schema.sequences WHERE sequence_schema = :'schema' ORDER BY 2;

\echo '=== Views / materialized views ==='
SELECT schemaname, viewname FROM pg_views WHERE schemaname = :'schema'
UNION ALL SELECT schemaname, matviewname FROM pg_matviews WHERE schemaname = :'schema' ORDER BY 2;

\echo '=== Functions / procedures and triggers ==='
SELECT n.nspname, p.proname, p.prokind, pg_get_userbyid(p.proowner) AS owner, p.prosecdef AS security_definer
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = :'schema' ORDER BY 2;
SELECT event_object_table AS table, trigger_name, event_manipulation FROM information_schema.triggers
WHERE trigger_schema = :'schema' ORDER BY 1, 2;

\echo '=== Extensions ==='
SELECT extname, extversion FROM pg_extension ORDER BY 1;

\echo '=== Constraints by type (p=PK f=FK u=UNIQUE c=CHECK x=EXCLUDE) ==='
SELECT contype, COUNT(*) FROM pg_constraint c JOIN pg_namespace n ON n.oid = c.connamespace
WHERE n.nspname = :'schema' GROUP BY contype ORDER BY contype;

\echo '=== Columns that probably hold credentials or personal data (review by hand) ==='
SELECT table_name, column_name, data_type FROM information_schema.columns
WHERE table_schema = :'schema'
  AND column_name ~* '(pass|pwd|secret|token|hash|salt|ssn|card|cvv|iban|salary|api_?key|birth)'
ORDER BY 1, 2;

\echo '=== PUBLIC and existing privileges (PUBLIC should not have more than it needs) ==='
SELECT datname, datacl FROM pg_database WHERE datname = current_database();
SELECT table_name, grantee, privilege_type FROM information_schema.role_table_grants
WHERE table_schema = :'schema' AND grantee IN ('PUBLIC') ORDER BY 1, 3;

\echo '=== Existing login roles in the cluster (note any superuser) ==='
SELECT rolname, rolsuper, rolcreatedb, rolcreaterole, rolcanlogin FROM pg_roles
WHERE rolname NOT LIKE 'pg\_%' ORDER BY rolcanlogin DESC, rolname;
