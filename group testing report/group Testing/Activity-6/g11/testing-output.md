# Activity 6 Testing Output — Group-TBD BoardTrack

**Project repository:** https://github.com/karlrobertc-art/BoardTrack
**Repository:** `karlrobertc-art/BoardTrack`  
**Branch inspected:** `main` (default branch from repository metadata)  
**Review date:** 2026-11-06  
**Review mode:** Remote repository metadata + README-level review only.

> **Important execution limitation:** A real Git clone could not be completed in this execution environment because outbound DNS/network access to `github.com` was unavailable. No Git Bash session, Windows localhost, PostgreSQL server, application server, browser workflow, SQL command, maintenance operation, backup, or restore was executed. Therefore this file does not claim a PASS or successful runtime verification. Run the commands below on the group's Windows machine and replace every NOT RUN entry with actual captured output.

## Repository inspection

- Public repository metadata was successfully retrieved through the connected GitHub integration.
- Default branch: `main`.
- README / project notes: README identifies Node.js 20.12+, Express/EJS, pg, PostgreSQL, automatic database setup/seed, and optional static preview.
- Source code, SQL files, migrations, environment templates, and tests were **not exhaustively inspected** in this pass.

## Activity 6 checklist and results

| Test | Expected result | Actual result | Status |
|---|---|---|---|
| Backup plan | Database/objects, method, storage, access, RPO/RTO, retention, and role restoration documented | Not prepared against a running DB | NOT RUN |
| Create logical backup (`pg_dump -Fc`) | Archive created without errors; size and SHA-256 recorded | Not run | NOT RUN |
| Inspect archive (`pg_restore --list`) | Archive contents are readable | Not run | NOT RUN |
| Restore to separate test database | Restore completes without modifying source DB | Not run | NOT RUN |
| Verify restored objects and data | Tables, constraints, sequences, views, row counts, and sample queries match | Not run | NOT RUN |
| Simulate controlled recovery incident | Disposable test data is recovered from verified backup | Not run | NOT RUN |
| Recreate Activity 4 roles/grants | Required role memberships and privileges are restored and tested | Not run | NOT RUN |

### Required evidence to capture locally
- Backup plan, exact sanitized commands, archive filename, file size, checksum, timestamp, and errors.
- `pg_restore --list` output.
- Restore target database name (must be separate/disposable), restore output, and object/row-count parity checks.
- Recovery drill steps and verification. Never delete data from the source database.
- Keep dump files outside Git; commit scripts and notes only.

## Findings and recommendations

1. **Immediate:** Perform a real clone and local setup using Git Bash on the designated Windows workstation; this report is not a substitute for local execution.
2. **Follow-up:** Complete the activity-specific checks above using the Activity 3 project documentation and Activity 4 least-privilege accounts.
3. **Evidence integrity:** Save genuine terminal output and screenshots; never fabricate successful tests or expose credentials.

## Final verdict

**NOT VERIFIED — runtime testing pending.** Repository metadata is accessible, but this execution pass did not run the project. Update this report only with observed results.
