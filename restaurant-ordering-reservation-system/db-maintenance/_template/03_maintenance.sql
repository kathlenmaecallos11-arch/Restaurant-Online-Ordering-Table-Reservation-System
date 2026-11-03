-- 03_maintenance.sql  (Activity 5, Part C) -- run as the maintenance account (g03_maint).
--   psql -h localhost -U g03_maint -d <DB> -v schema=public -f 03_maintenance.sql
-- Purpose:  ANALYZE refreshes planner statistics (row counts / value distribution) so plans stay good.
--           VACUUM reclaims dead tuples left by UPDATE/DELETE and keeps the visibility map current.
-- Safe: no VACUUM FULL, no exclusive locks, small test databases. \gexec sends each generated command on
-- its own, which matters because VACUUM cannot run inside a transaction block.
\if :{?schema}
\else
  \set schema public
\endif
\pset pager off
\echo '--- BEFORE ---'
SELECT relname, n_dead_tup, last_analyze, last_autoanalyze FROM pg_stat_user_tables WHERE schemaname = :'schema' ORDER BY relname;

\echo '--- ANALYZE (whole database) ---'
ANALYZE;

\echo '--- VACUUM (VERBOSE, ANALYZE) on each table ---'
SELECT format('VACUUM (VERBOSE, ANALYZE) %I.%I', schemaname, relname)
FROM pg_stat_user_tables WHERE schemaname = :'schema' ORDER BY relname
\gexec

\echo '--- AFTER ---'
SELECT relname, n_dead_tup, last_vacuum, last_analyze FROM pg_stat_user_tables WHERE schemaname = :'schema' ORDER BY relname;
