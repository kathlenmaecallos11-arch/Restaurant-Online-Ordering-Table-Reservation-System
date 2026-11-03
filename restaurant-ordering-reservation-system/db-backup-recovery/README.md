# db-backup-recovery/ — Activity 6: backup, restoration and recovery

Logical backups with `pg_dump -Fc` (custom archive) restored with `pg_restore` into a **separate** database.
**Never commit a `.dump` file** (it contains data). `.gitignore` already blocks `*.dump`, `*.sql.gz`, `*.bak`;
only the file name, size and SHA-256 are recorded (`evidence/backup-log.csv`).

```
db-backup-recovery/
├── _template/
│   ├── backup-plan.md            Part A  what / how / where / who / verify / schedule / retention / RPO / RTO / roles
│   ├── backup.ps1                Part B  pg_dump -Fc + size + SHA-256 + pg_restore --list + log line
│   ├── restore.ps1               Part C  createdb <db>_restore_test + pg_restore + optional Activity 4 role re-creation + checks
│   ├── 01_verify_restore.sql     Part C  objects, row counts, constraints, roles, representative query
│   ├── recovery-simulation.ps1   Part D  delete ONE disposable row in the restore DB, recover it from a fresh restore, compare
│   └── report.md                 Part E  per-project report
├── run-activity6.ps1             scaffolds group-XX/
└── group-XX/                     per project: plan, scripts, evidence/, report
```

## Why roles need their own step
`pg_dump` of one database does **not** include cluster-wide roles (and not the database-level `GRANT CONNECT`).
Table/schema `GRANT`s are in the dump, but they only work if the roles exist. After restoring on another server (or
into a new database) re-run the Activity 4 script `01_roles_and_grants.sql` for the restored database name, then repeat one
permitted and one denied test. `restore.ps1 -ReapplyAccessControl` does this using `db-access-control\group-XX`.

## Workflow per project
1. `.\run-activity6.ps1 -Group 03 -Step init`, then fill `backup-plan.md` **first**.
2. `group-03\backup.ps1 -Db <db> -Account g03_backup` → file name / size / checksum / archive list in `evidence\`.
3. `group-03\restore.ps1 -Db <db> -ReapplyAccessControl` → `<db>_restore_test`, verification output in `evidence\`.
4. `group-03\recovery-simulation.ps1 -Db <db> -Table <leaf table> -PkColumn <pk> -PkValue <value>`.
5. Fill `report.md`, commit scripts + notes (not dumps), update the **Activity 6 Log** tab, send feedback.

## Safety checklist (tick before every destructive step)
* [ ] a verified backup exists  * [ ] the target database name ends in `_restore_test`  * [ ] the original DB is untouched
* [ ] no production data  * [ ] no passwords on screen / in files
