# Activity 5 Testing Output — Group-03 OJT RMA System

**Project repository:** https://github.com/swvenz/Project-OJT-RMA-System.git  
**Repository:** `swvenz/Project-OJT-RMA-System`  
**Branch inspected:** `main` (default branch from repository metadata)  
**Review date:** 2026-11-06  
**Review mode:** Remote repository metadata + local database file inspection attempt.

> **Important execution limitation:** The database SQL file provided by Group 03 was stored in a custom binary dump format. This format caused text encoding and parsing errors when opened using standard SQL text editors and tools. As a result, PostgreSQL server restoration, log review, maintenance operations, and query execution plans could not be performed during this activity.

## Repository inspection

- Public repository metadata was successfully retrieved through the connected GitHub integration.
- Default branch: `main`.
- Database file inspected: `rma_db` dump file.
- File condition: Stored in a custom binary format causing encoding issues in text editors.
- Source code, application integration, and standard SQL maintenance scripts could **not** be fully evaluated due to database unreachability.

## Activity 5 checklist and results

| Test | Expected result | Actual result | Status |
|---|---|---|---|
| Identify database/version and accounts | Correct target DB and Activity 4 role identified | Identified target database name `rma_db`; version and role unverified due to binary dump issue | FAILED |
| Health/activity inspection | Connection, database size, table/index inventory, activity statistics documented | Unable to inspect connections, table counts, or database activity | NOT RUN |
| Review available PostgreSQL logs | Relevant errors assessed, or log-access limitation stated | Log review unverified due to database setup and execution failure | NOT RUN |
| Run ANALYZE | Planner statistics refreshed; outcome recorded | Could not execute ANALYZE due to inaccessible database | NOT RUN |
| Run VACUUM (not VACUUM FULL) | Appropriate table maintenance completes outside transaction | Could not execute VACUUM due to inaccessible database | NOT RUN |
| EXPLAIN selected safe SELECT | Plan and scan type interpreted; recommendation justified | Could not execute EXPLAIN query analysis due to inaccessible database | NOT RUN |

### Required evidence to capture locally
- PostgreSQL version, DB name, current role, connection/health output, database/table sizes.
- `pg_stat_activity`, table/index inventory, and accessible log review (state limitations).
- ANALYZE/VACUUM commands and results. VACUUM must be run as a standalone command, not in a transaction.
- EXPLAIN output for a meaningful read-only SELECT; use EXPLAIN ANALYZE only in a disposable test database and only for a safe SELECT.
- Prioritized recommendation: Immediate action / Follow-up action / No action required.

## Findings and recommendations

1. **Immediate:** Request a plain-text SQL export (standard `.sql` format or plain text dump) from Group 03 to allow successful database restoration and setup.
2. **Follow-up:** Once restored, execute the required PostgreSQL health checks, log configuration review, `ANALYZE`, `VACUUM`, and `EXPLAIN` query performance tests.
3. **Evidence integrity:** Ensure all future tests use readable database files and capture genuine terminal outputs without exposing sensitive credentials.

## Final verdict

**FAILED / NOT REACHABLE — Database file unreadable.**  
The target database could not be inspected, restored, or monitored because the supplied database dump was saved in an incompatible custom binary format. As a result, no database maintenance or query performance analysis could be conducted.

