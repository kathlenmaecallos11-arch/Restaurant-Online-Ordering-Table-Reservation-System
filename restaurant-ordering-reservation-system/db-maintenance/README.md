# db-maintenance/ — Activity 5: monitoring, maintenance and performance

Work is done on the other groups' databases (set up in Activity 4) using the **Activity 4 accounts** — the account is
chosen to fit the task: `g__report` (read-only) for inspection, `g__maint` (pg_monitor + pg_maintain) for statistics,
ANALYZE and VACUUM. Do not switch to a superuser just to make a command work; record the limitation instead.

```
db-maintenance/
├── _template/
│   ├── 01_health_checks.sql      Part A  version, size, objects, sessions, running queries, roles vs plan
│   ├── 02_maintenance_review.sql Part C  dead tuples / last (auto)vacuum / analyze / index usage review (read-only)
│   ├── 03_maintenance.sql        Part C  ANALYZE + VACUUM (VERBOSE, ANALYZE) per table (standalone commands)
│   ├── 04_query_plan.sql         Part D  EXPLAIN / EXPLAIN (ANALYZE, BUFFERS) for one chosen SELECT (edit first)
│   ├── find-logs.ps1             Part B  locate and search the PostgreSQL log (FATAL / ERROR / permission denied)
│   ├── log-findings.md           Part B  finding table
│   └── report.md                 Part E  per-project report
├── run-activity5.ps1             scaffolds group-XX/ and runs steps with transcripts
└── group-XX/                     per project: scripts, evidence/, log notes, report
```

## Workflow per project
1. `.\db-maintenance\run-activity5.ps1 -Group 03 -Db <db> -Step init`
2. `-Step health -Account g03_maint` (uses pg_monitor so other sessions are visible) — also run it once as `g03_report`
   and note what is hidden: that *is* the permission limitation to document.
3. `.\_template\find-logs.ps1` → fill `log-findings.md`. **Do not invent incidents**; write what you checked.
4. `-Step review` → decide what is needed → `-Step maintain -Account g03_maint` (needs PostgreSQL 17+ `pg_maintain`;
   on older servers VACUUM/ANALYZE need table ownership: record the limitation and recommend a maintenance role).
5. Edit `04_query_plan.sql` to a real query the app runs, `-Step plan`, interpret the plan in `report.md`.
6. Commit, update the **Activity 5 Log** tracker tab, send recommendations to the owners.

## Rules of thumb
* `VACUUM` runs outside a transaction; **no `VACUUM FULL`** (exclusive lock) unless the instructor approves.
* `EXPLAIN ANALYZE` really executes the query: only for safe SELECTs on the test database.
* Do not create an index just to satisfy the activity; weigh read benefit against write/storage cost.
* Never commit passwords, `.env` files or log lines that contain credentials.
