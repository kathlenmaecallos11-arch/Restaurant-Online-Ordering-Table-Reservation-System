-- 05_review_privileges.sql  (Activity 4, Part D review) -- psql ... -v prefix=g03 -v schema=public -f 05_review_privileges.sql
\if :{?schema}
\else
  \set schema public
\endif
\pset pager off

\echo '=== Role attributes of this project''s roles (no superuser / createdb / createrole expected) ==='
SELECT rolname, rolsuper, rolcreatedb, rolcreaterole, rolreplication, rolcanlogin, rolconnlimit
FROM pg_roles WHERE rolname LIKE :'prefix' || '\_%' ORDER BY rolcanlogin, rolname;

\echo '=== Memberships (member -> member of) ==='
SELECT m.rolname AS member, g.rolname AS member_of
FROM pg_auth_members am JOIN pg_roles m ON m.oid = am.member JOIN pg_roles g ON g.oid = am.roleid
WHERE m.rolname LIKE :'prefix' || '\_%' ORDER BY 1, 2;

\echo '=== Effective table privileges per project group role ==='
SELECT t.tablename, r.rolname,
       has_table_privilege(r.rolname, format('%I.%I', t.schemaname, t.tablename), 'SELECT') AS sel,
       has_table_privilege(r.rolname, format('%I.%I', t.schemaname, t.tablename), 'INSERT') AS ins,
       has_table_privilege(r.rolname, format('%I.%I', t.schemaname, t.tablename), 'UPDATE') AS upd,
       has_table_privilege(r.rolname, format('%I.%I', t.schemaname, t.tablename), 'DELETE') AS del
FROM pg_tables t
CROSS JOIN (SELECT rolname FROM pg_roles WHERE rolname LIKE :'prefix' || '\_%' AND NOT rolcanlogin) r
WHERE t.schemaname = :'schema' ORDER BY t.tablename, r.rolname;

\echo '=== Sequence privileges ==='
SELECT c.relname AS sequence, r.rolname,
       has_sequence_privilege(r.rolname, c.oid, 'USAGE') AS usage, has_sequence_privilege(r.rolname, c.oid, 'SELECT') AS sel
FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
CROSS JOIN (SELECT rolname FROM pg_roles WHERE rolname LIKE :'prefix' || '\_%' AND NOT rolcanlogin) r
WHERE c.relkind = 'S' AND n.nspname = :'schema' ORDER BY 1, 2;

\echo '=== PUBLIC privileges that still exist ==='
SELECT table_name, privilege_type FROM information_schema.role_table_grants WHERE grantee = 'PUBLIC' AND table_schema = :'schema';
SELECT datacl FROM pg_database WHERE datname = current_database();
SELECT nspacl FROM pg_namespace WHERE nspname = :'schema';

\echo '=== Default privileges ==='
SELECT pg_get_userbyid(defaclrole) AS owner, defaclobjtype AS type, defaclacl FROM pg_default_acl;
