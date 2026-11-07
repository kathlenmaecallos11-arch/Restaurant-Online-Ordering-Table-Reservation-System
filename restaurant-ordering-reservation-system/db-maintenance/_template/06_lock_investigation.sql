-- 06_lock_investigation.sql   (MESA-INC5: idle session holds an exclusive lock on orders)
-- READ-ONLY diagnosis. Run as postgres or a pg_monitor member (for example rors_maint):
--   psql -h localhost -U postgres -d grp_binarysisters_projectdb -f db-maintenance/_template/06_lock_investigation.sql
\pset pager off
\echo '--- 1. Sessions that are waiting, and who blocks them ---'
SELECT a.pid AS waiting_pid, a.usename, a.state, a.wait_event_type, a.wait_event,
       pg_blocking_pids(a.pid) AS blocked_by, now() - a.query_start AS waiting_for, left(a.query, 80) AS query
FROM pg_stat_activity a WHERE cardinality(pg_blocking_pids(a.pid)) > 0;

\echo '--- 2. Locks held on orders ---'
SELECT l.pid, l.mode, l.granted, a.usename, a.application_name, a.state,
       now() - a.xact_start AS transaction_age, now() - a.state_change AS idle_for, left(a.query, 80) AS last_query
FROM pg_locks l JOIN pg_stat_activity a ON a.pid = l.pid
WHERE l.relation = 'public.orders'::regclass ORDER BY l.granted DESC, a.xact_start;

\echo '--- 3. Candidates: idle sessions that still hold a transaction open ---'
SELECT pid, usename, application_name, state, now() - xact_start AS transaction_age, now() - state_change AS idle_for
FROM pg_stat_activity
WHERE state IN ('idle in transaction', 'idle in transaction (aborted)') ORDER BY xact_start;
