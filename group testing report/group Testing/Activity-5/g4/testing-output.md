# Activity 5 Testing Output — Group-04 BrewPOS

**Project repository:** https://github.com/Nycri/brewpos  
**Repository:** `Nycri/brewpos`  
**Branch inspected:** `main` (default branch from repository metadata)  
**Review date:** 2026-11-06  
**Review mode:** Database inspection, log configuration review, routine maintenance, and query execution plan analysis.

> **Execution Context:** Based on actual database inspection records and testing results from the local test environment. The database was accessible, and standard maintenance and query performance procedures were executed using the `postgres` account.

## Repository inspection

- Public repository metadata was successfully retrieved through the connected GitHub integration.
- Default branch: `main`.
- Database name: `grp_brewposdb` (PostgreSQL 18.6).
- Database size: 8,334 kB with 5 public tables.
- Active connections: 3 connections (2 idle, 1 active monitoring session).

## Activity 5 checklist and results

| Test | Expected result | Actual result | Status |
|---|---|---|---|
| Identify database/version and accounts | Correct target DB and Activity 4 role identified | Identified `grp_brewposdb` (PostgreSQL 18.6) using `postgres` account | SUCCESS |
| Health/activity inspection | Connection, database size, table/index inventory, activity statistics documented | Verified 8,334 kB size, 5 public tables, and normal connection states | SUCCESS |
| Review available PostgreSQL logs | Relevant errors assessed, or log-access limitation stated | Logging collector enabled (`stderr`, timestamped filenames); actual log contents unverified due to local scope | SUCCESS (with scope limitation) |
| Run ANALYZE | Planner statistics refreshed; outcome recorded | Executed `ANALYZE;` successfully in approximately 254 ms | SUCCESS |
| Run VACUUM (not VACUUM FULL) | Appropriate table maintenance completes outside transaction | Executed `VACUUM (VERBOSE, ANALYZE) public.menu_category;` successfully in ~74 ms | SUCCESS |
| EXPLAIN selected safe SELECT | Plan and scan type interpreted; recommendation justified | Executed `SELECT * FROM public.menu_item WHERE price = '90.00';` using Sequential Scan | SUCCESS |

### Required evidence to capture locally
- PostgreSQL version, DB name, current role, connection/health output, database/table sizes.
- `pg_stat_activity`, table/index inventory, and accessible log review (state limitations).
- ANALYZE/VACUUM commands and results. VACUUM must be run as a standalone command, not in a transaction.
- EXPLAIN output for a meaningful read-only SELECT; use EXPLAIN ANALYZE only in a disposable test database and only for a safe SELECT.
- Prioritized recommendation: Immediate action / Follow-up action / No action required.

## Findings and recommendations

1. **Immediate:** None required for basic connection and tool execution, as the database was reachable and responsive.
2. **Follow-up:** Review actual PostgreSQL logs regularly and conduct additional testing with larger datasets before drawing final performance conclusions.
3. **Evidence integrity:** Ensure genuine terminal outputs and execution plans are retained in the progress documentation without exposing sensitive credentials.

## Final verdict

**SUCCESS — Database operational with minor testing scope limitations.**  
Repository metadata, database connections, and standard maintenance operations executed successfully without errors. The tested query executed efficiently, though performance evaluation is limited by the small dataset size of the inspected tables.


