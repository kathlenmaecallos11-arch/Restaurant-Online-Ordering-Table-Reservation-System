-- 05_after_bulk_load.sql   (MESA-INC3: autovacuum disabled during bulk loading)
-- Run as postgres (or an account allowed to ALTER SYSTEM / ALTER TABLE and VACUUM) right after any large import:
--   psql -h localhost -U postgres -d grp_binarysisters_projectdb -f db-maintenance/_template/05_after_bulk_load.sql
-- Rule: do not leave autovacuum off. If a load script turns it off, this script turns it back on and cleans up.
\pset pager off
\echo '--- 1. BEFORE: autovacuum setting, per-table overrides, dead tuples, statistics age ---'
SHOW autovacuum;
SELECT c.relname, c.reloptions FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public' AND c.relkind = 'r' AND c.reloptions IS NOT NULL;
SELECT relname, n_live_tup, n_dead_tup, last_autovacuum, last_analyze, last_autoanalyze
FROM pg_stat_user_tables WHERE schemaname = 'public' ORDER BY n_dead_tup DESC;

\echo '--- 2. Re-enable autovacuum (server level, then per table) ---'
SELECT 'ALTER SYSTEM SET autovacuum = on' WHERE current_setting('autovacuum') = 'off'
\gexec
SELECT pg_reload_conf();
SELECT format('ALTER TABLE %I.%I RESET (autovacuum_enabled)', n.nspname, c.relname)
FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public' AND c.relkind = 'r' AND c.reloptions::text LIKE '%autovacuum_enabled=false%'
\gexec

\echo '--- 3. VACUUM (ANALYZE) on every table (cannot run inside a transaction block) ---'
SELECT format('VACUUM (ANALYZE) %I.%I', schemaname, relname) FROM pg_stat_user_tables WHERE schemaname = 'public'
\gexec

\echo '--- 4. AFTER ---'
SHOW autovacuum;
SELECT relname, n_dead_tup, last_vacuum, last_analyze FROM pg_stat_user_tables WHERE schemaname = 'public' ORDER BY relname;
\echo 'Then compare the order queue plan:  EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM v_order_summary ORDER BY 1 DESC LIMIT 50;'
