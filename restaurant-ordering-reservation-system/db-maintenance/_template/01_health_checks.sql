-- 01_health_checks.sql  (Activity 5, Part A)
--   psql -h localhost -U g03_maint -d <DB> -v prefix=g03 -v schema=public -f 01_health_checks.sql
-- Rows that other users' sessions hide are shown as NULL/<insufficient privilege>: record that as a limitation.
\if :{?schema}
\else
  \set schema public
\endif
\pset pager off
\echo '=== Who am I (account and group roles) ==='
SELECT current_user AS account, session_user,
       (SELECT string_agg(g.rolname, ', ') FROM pg_auth_members am JOIN pg_roles g ON g.oid = am.roleid
        WHERE am.member = (SELECT oid FROM pg_roles WHERE rolname = current_user)) AS member_of;
\echo '=== Version / database ==='
SELECT version();
SELECT current_database() AS database, pg_size_pretty(pg_database_size(current_database())) AS size;
\echo '=== Object counts ==='
SELECT (SELECT COUNT(*) FROM pg_stat_user_tables WHERE schemaname = :'schema') AS tables,
       (SELECT COUNT(*) FROM pg_stat_user_indexes WHERE schemaname = :'schema') AS indexes,
       (SELECT COUNT(*) FROM pg_views WHERE schemaname = :'schema') AS views,
       (SELECT COUNT(*) FROM information_schema.sequences WHERE sequence_schema = :'schema') AS sequences;
\echo '=== Database statistics (connections, rollbacks, deadlocks, temp files) ==='
SELECT datname, numbackends, xact_commit, xact_rollback, deadlocks, temp_files, conflicts, stats_reset
FROM pg_stat_database WHERE datname = current_database();
\echo '=== Sessions in this database ==='
SELECT pid, usename, application_name, client_addr, state, wait_event_type, wait_event,
       backend_start, query_start, now() - query_start AS running_for, left(query, 80) AS query
FROM pg_stat_activity WHERE datname = current_database() ORDER BY query_start NULLS LAST;
\echo '=== Sessions by state ==='
SELECT state, COUNT(*) FROM pg_stat_activity WHERE datname = current_database() GROUP BY state;
\echo '=== Long-running (> 1 minute) or blocked ==='
SELECT pid, usename, state, now() - query_start AS running_for, wait_event_type, pg_blocking_pids(pid) AS blocked_by, left(query, 80) AS query
FROM pg_stat_activity
WHERE datname = current_database() AND pid <> pg_backend_pid()
  AND (now() - query_start > interval '1 minute' OR cardinality(pg_blocking_pids(pid)) > 0);
\echo '=== Activity 4 roles present (compare with access-control-plan.md and record differences) ==='
SELECT rolname, rolsuper, rolcreatedb, rolcreaterole, rolcanlogin FROM pg_roles
WHERE rolname LIKE :'prefix' || '\_%' ORDER BY rolcanlogin, rolname;
\echo '=== Key settings that affect logging and maintenance ==='
SELECT name, setting FROM pg_settings WHERE name IN
 ('log_destination','logging_collector','log_directory','log_min_duration_statement','log_connections',
  'log_disconnections','log_min_messages','autovacuum','max_connections','shared_buffers');
