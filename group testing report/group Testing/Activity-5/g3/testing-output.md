# Activity 5 Testing Output — Group-02 OJT-Management-System

**Project repository:** https://github.com/swvenz/Project-OJT-RMA-System
**Repository:** `swvenz/Project-OJT-RMA-System`  
**Branch inspected:** `main` (default branch from repository metadata)  
**Review date:** 2026-11-06  
**Review mode:** Remote repository metadata + README-level review only.

> **Important execution limitation:** A real Git clone could not be completed in this execution environment because outbound DNS/network access to `github.com` was unavailable. No Git Bash session, Windows localhost, PostgreSQL server, application server, browser workflow, SQL command, maintenance operation, backup, or restore was executed. Therefore this file does not claim a PASS or successful runtime verification. Run the commands below on the group's Windows machine and replace every NOT RUN entry with actual captured output.

## Repository inspection

- Public repository metadata was successfully retrieved through the connected GitHub integration.
- Default branch: `main`.
- README / project notes: README identifies OJT Management System; PostgreSQL database ojt_managementdb; says migrations and seed script are required. Framework/runtime details were not confirmed.
- Source code, SQL files, migrations, environment templates, and tests were **not exhaustively inspected** in this pass.

## Activity 5 checklist and results

| Test | Expected result | Actual result | Status |
|---|---|---|---|
| Identify database/version and accounts | Correct target DB and Activity 4 role identified | Not run | NOT RUN |
| Health/activity inspection | Connection, database size, table/index inventory, activity statistics documented | Not run | NOT RUN |
| Review available PostgreSQL logs | Relevant errors assessed, or log-access limitation stated | Not run | NOT RUN |
| Run ANALYZE | Planner statistics refreshed; outcome recorded | Not run | NOT RUN |
| Run VACUUM (not VACUUM FULL) | Appropriate table maintenance completes outside transaction | Not run | NOT RUN |
| EXPLAIN selected safe SELECT | Plan and scan type interpreted; recommendation justified | Not run | NOT RUN |

### Required evidence to capture locally
- PostgreSQL version, DB name, current role, connection/health output, database/table sizes.
- `pg_stat_activity`, table/index inventory, and accessible log review (state limitations).
- ANALYZE/VACUUM commands and results. VACUUM must be run as a standalone command, not in a transaction.
- EXPLAIN output for a meaningful read-only SELECT; use EXPLAIN ANALYZE only in a disposable test database and only for a safe SELECT.
- Prioritized recommendation: Immediate action / Follow-up action / No action required.

## Findings and recommendations

1. **Immediate:** Perform a real clone and local setup using Git Bash on the designated Windows workstation; this report is not a substitute for local execution.
2. **Follow-up:** Complete the activity-specific checks above using the Activity 3 project documentation and Activity 4 least-privilege accounts.
3. **Evidence integrity:** Save genuine terminal output and screenshots; never fabricate successful tests or expose credentials.

## Final verdict

**NOT VERIFIED — runtime testing pending.** Repository metadata is accessible, but this execution pass did not run the project. Update this report only with observed results.
