# Activity 4 Testing Output — Group-07 CampusSafe

**Project repository:** https://github.com/jeffersonorpesa2-ops/grp07-campussafe
**Repository:** `jeffersonorpesa2-ops/grp07-campussafe`  
**Branch inspected:** `main` (default branch from repository metadata)  
**Review date:** 2026-11-06  
**Review mode:** Remote repository metadata + README-level review only.

> **Important execution limitation:** A real Git clone could not be completed in this execution environment because outbound DNS/network access to `github.com` was unavailable. No Git Bash session, Windows localhost, PostgreSQL server, application server, browser workflow, SQL command, maintenance operation, backup, or restore was executed. Therefore this file does not claim a PASS or successful runtime verification. Run the commands below on the group's Windows machine and replace every NOT RUN entry with actual captured output.

## Repository inspection

- Public repository metadata was successfully retrieved through the connected GitHub integration.
- Default branch: `main`.
- README / project notes: README identifies PHP 8.2+, PostgreSQL 14+, PDO, authentication/RBAC, upload handling, hazard workflow, and setup wizard.
- Source code, SQL files, migrations, environment templates, and tests were **not exhaustively inspected** in this pass.

## Activity 4 checklist and results

| Test | Expected result | Actual result | Status |
|---|---|---|---|
| Identify application roles and data operations | Roles map to documented read/write needs | README-level review only; role docs not exhaustively retrieved | PARTIAL |
| Create PostgreSQL NOLOGIN group roles | Group roles exist with least-privilege grants | Not run | NOT RUN |
| Create login roles and memberships | Login accounts inherit intended group roles | Not run | NOT RUN |
| Grant CONNECT, schema USAGE, object privileges | Only required privileges are granted | Not run | NOT RUN |
| Verify positive access | Authorized statements succeed | Not run | NOT RUN |
| Verify negative access | Unauthorized INSERT/UPDATE/DELETE/SELECT are denied | Not run | NOT RUN |
| Verify sequence and future-object privileges | Required sequences and future tables are covered | Not run | NOT RUN |

### Required evidence to capture locally
- Sanitized role inventory (`\du`), database/schema/table grants, and role memberships.
- Positive and negative permission tests with account, SQL statement, expected result, actual result.
- Access-control plan mapping each login account to Activity 3 application roles.
- Do not include real passwords; do not modify the owners' repositories.

## Findings and recommendations

1. **Immediate:** Perform a real clone and local setup using Git Bash on the designated Windows workstation; this report is not a substitute for local execution.
2. **Follow-up:** Complete the activity-specific checks above using the Activity 3 project documentation and Activity 4 least-privilege accounts.
3. **Evidence integrity:** Save genuine terminal output and screenshots; never fabricate successful tests or expose credentials.

## Final verdict

**NOT VERIFIED — runtime testing pending.** Repository metadata is accessible, but this execution pass did not run the project. Update this report only with observed results.
