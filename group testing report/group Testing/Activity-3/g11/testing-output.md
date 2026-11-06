# Activity 3 Testing Output — Group-TBD BoardTrack

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

## Activity 3 checklist and results

| Test | Expected result | Actual result | Status |
|---|---|---|---|
| Clone repository using Git | Working tree created; correct branch checked out | Clone not run: DNS/network unavailable in this environment | NOT RUN |
| Inspect README, dependencies, and setup instructions | Prerequisites and reproducible steps are complete | README-level notes only; see above | PARTIAL |
| Identify database schema/migrations and seed data | SQL/migrations and seed data exist and are ordered/documented | Not verified from source files | NOT RUN |
| Initialize PostgreSQL database | Schema loads without errors | No local PostgreSQL server available | NOT RUN |
| Load sample data | Seed completes and expected rows are present | Not run | NOT RUN |
| Start application on localhost | Application loads without fatal errors | Not run; no local Windows localhost/browser session | NOT RUN |
| Test essential CRUD/business workflows | Create/read/update/delete behavior matches approved scope | Not run | NOT RUN |
| Check secrets and configuration | Example config uses placeholders; no secrets committed | Not audited exhaustively | NOT RUN |

### Required evidence to capture locally
- `git clone` and `git status` output; branch and commit hash.
- `php -v` / `php -m`, `java -version`, `node -v`, or other stack-specific version checks.
- `psql --version`, database creation, schema import, and seed import output.
- Browser screenshots of the running application and each tested workflow.
- Actual errors, fixes, and retest results.

## Findings and recommendations

1. **Immediate:** Perform a real clone and local setup using Git Bash on the designated Windows workstation; this report is not a substitute for local execution.
2. **Follow-up:** Complete the activity-specific checks above using the Activity 3 project documentation and Activity 4 least-privilege accounts.
3. **Evidence integrity:** Save genuine terminal output and screenshots; never fabricate successful tests or expose credentials.

## Final verdict

**NOT VERIFIED — runtime testing pending.** Repository metadata is accessible, but this execution pass did not run the project. Update this report only with observed results.
