-- 02_maintenance_review.sql  (Activity 5, Part C: decide whether maintenance is needed) -- read-only
\if :{?schema}
\else
  \set schema public
\endif
\pset pager off
\echo '=== Table activity, dead tuples and last maintenance ==='
SELECT relname AS table, n_live_tup, n_dead_tup,
       round(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 1) AS dead_pct,
       last_vacuum, last_autovacuum, last_analyze, last_autoanalyze,
       n_mod_since_analyze
FROM pg_stat_user_tables WHERE schemaname = :'schema' ORDER BY n_dead_tup DESC, relname;
\echo '=== Sequential vs index scans (tables read mostly by seq scan may need an index) ==='
SELECT relname AS table, seq_scan, seq_tup_read, idx_scan, n_live_tup
FROM pg_stat_user_tables WHERE schemaname = :'schema' ORDER BY seq_tup_read DESC;
\echo '=== Index usage and size (idx_scan = 0 for a long time = candidate to review, NOT to drop blindly) ==='
SELECT relname AS table, indexrelname AS index, idx_scan, pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes WHERE schemaname = :'schema' ORDER BY idx_scan, relname;
\echo '=== Table and index sizes ==='
SELECT c.relname, pg_size_pretty(pg_table_size(c.oid)) AS table_size, pg_size_pretty(pg_indexes_size(c.oid)) AS index_size
FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = :'schema' AND c.relkind = 'r' ORDER BY pg_total_relation_size(c.oid) DESC;
