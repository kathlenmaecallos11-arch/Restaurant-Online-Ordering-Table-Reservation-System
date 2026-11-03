-- 01_verify_restore.sql  (Activity 6 Part C) -- run against <db>_restore_test
\if :{?schema}
\else
  \set schema public
\endif
\pset pager off
\echo '=== Database / version ==='
SELECT current_database(), version();
\echo '=== Objects present ==='
SELECT 'tables' AS kind, COUNT(*) FROM pg_tables WHERE schemaname = :'schema'
UNION ALL SELECT 'views', COUNT(*) FROM pg_views WHERE schemaname = :'schema'
UNION ALL SELECT 'sequences', COUNT(*) FROM information_schema.sequences WHERE sequence_schema = :'schema'
UNION ALL SELECT 'indexes', COUNT(*) FROM pg_indexes WHERE schemaname = :'schema'
UNION ALL SELECT 'triggers', COUNT(*) FROM information_schema.triggers WHERE trigger_schema = :'schema'
UNION ALL SELECT 'functions', COUNT(*) FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace WHERE n.nspname = :'schema'
UNION ALL SELECT 'extensions', COUNT(*) FROM pg_extension WHERE extname <> 'plpgsql';
\echo '=== Row counts per table (compare with the original: evidence/rowcounts_*.csv) ==='
SELECT table_name,
       (xpath('/row/c/text()', query_to_xml(format('SELECT count(*) AS c FROM %I.%I', table_schema, table_name), false, true, '')))[1]::text::bigint AS row_count
FROM information_schema.tables WHERE table_schema = :'schema' AND table_type = 'BASE TABLE' ORDER BY 1;
\echo '=== Constraints by type (p=PK f=FK u=UNIQUE c=CHECK x=EXCLUDE) ==='
SELECT contype, COUNT(*) FROM pg_constraint c JOIN pg_namespace n ON n.oid = c.connamespace WHERE n.nspname = :'schema' GROUP BY 1 ORDER BY 1;
\echo '=== Foreign keys ==='
SELECT conrelid::regclass AS "table", conname, pg_get_constraintdef(oid) AS definition FROM pg_constraint
WHERE contype = 'f' AND connamespace = :'schema'::regnamespace ORDER BY 1, 2;
\echo '=== Orphan check helper: sequences should be >= max(id) (compare after restore) ==='
SELECT sequencename, last_value FROM pg_sequences WHERE schemaname = :'schema' ORDER BY 1;
\echo '=== Roles that can reach this database after restore ==='
SELECT r.rolname, has_database_privilege(r.rolname, current_database(), 'CONNECT') AS can_connect
FROM pg_roles r WHERE r.rolname NOT LIKE 'pg\_%' AND r.rolcanlogin ORDER BY 1;
\echo '=== Representative query: replace with a real application SELECT and compare with the original database ==='
SELECT 'edit me: put a real SELECT here' AS note;
