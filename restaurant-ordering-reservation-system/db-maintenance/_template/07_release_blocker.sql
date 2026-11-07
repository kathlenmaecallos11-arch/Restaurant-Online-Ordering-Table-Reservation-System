-- 07_release_blocker.sql   (MESA-INC5 corrective action)
-- Ends ONE idle blocking session. Needs ADMINISTRATOR APPROVAL first: its open transaction is rolled back.
-- Write the pid, the approver and the time in your log BEFORE running it.
--   psql -h localhost -U postgres -d grp_binarysisters_projectdb -v pid=12345 -f db-maintenance/_template/07_release_blocker.sql
-- Safety: it only acts on a session that is idle (not running a query) and never on your own connection.
\if :{?pid}
\else
  \echo 'Pass the pid from 06_lock_investigation.sql:  -v pid=<number>'
  \quit
\endif
SELECT pid, usename, state, now() - state_change AS idle_for FROM pg_stat_activity WHERE pid = :pid;
SELECT pg_terminate_backend(pid) AS terminated
FROM pg_stat_activity
WHERE pid = :pid AND pid <> pg_backend_pid() AND state LIKE 'idle%';
\echo 'Verify: re-run 06_lock_investigation.sql. Section 1 must return no rows.'
