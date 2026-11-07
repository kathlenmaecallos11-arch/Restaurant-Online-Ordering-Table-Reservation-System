# COMP 018 – MIDTERM ASSESSMENT

**Integrated Database Administration Challenge**
*Review, Design, Investigate, Troubleshoot, and Defend*

| | |
|---|---|
| **Project Owner** | Group 10: Mesa – Order and Reserve (Binary Sisters) |
| **Course** | COMP 018 – Database Administration |
| **Assessment Type** | Group-based integrated practical challenge |
| **Database Platform** | PostgreSQL |
| **Project Basis** | The class's projects from Activities 3 to 6, found in the tracker |
| **Format** | Flaw review, incident design, investigation, and technical defense |

## Executive Summary

**Owner role.** As the owner group of Mesa, we investigated and troubleshot the five incidents designed for our project by the designer group. Each incident was handled with the same workflow: Observe, Verify, Hypothesize, Test, Act, Verify Again, Document, and Prevent. All five incidents have been fixed.

**Summary of results.** Three incidents were permission, authentication or lock problems that blocked the application from using its tables (INC1, INC2, INC5), and two were maintenance and recovery problems (INC3, INC4). In every case the symptom was visible to users, but the cause was found only by inspecting the database itself, not the application interface.

| Incident ID | Root cause | Fix | Status |
|---|---|---|---|
| MESA-INC1 | Grants lost after database rebuild | Reapplied GRANT statements on tables and sequences | Resolved |
| MESA-INC2 | Application login role has no password | Set a secure password; updated application configuration | Resolved |
| MESA-INC3 | Autovacuum disabled; dead tuples and stale statistics | Re-enabled autovacuum; ran VACUUM ANALYZE | Resolved |
| MESA-INC4 | Backup file not validated before restore | Checked size and SHA-256 against the backup log; restored a verified backup | Resolved |
| MESA-INC5 | Idle session holding exclusive lock on orders | Identified and released the session with administrator approval | Resolved |

## Part C – Incident Investigation (Owner Group)

### MESA-INC1: Grants lost after database rebuild

| Step | Finding |
|---|---|
| Observe (Symptoms & Brief) | The application displays "Something went wrong" when users open its features, even though the /health endpoint reports the database is working. |
| Verify | Confirmed /health returns OK. Reproduced the error on the menu and orders pages. Checked the server log for permission errors. |
| Hypothesize | The application can connect, but its role lost the privileges on the required tables and sequences after the database was rebuilt. |
| Test | Checked the application role's privileges with has_table_privilege and information_schema.role_table_grants. Tried SELECT and INSERT as that role. |
| Act | Reapplied the required GRANT statements on the tables and sequences. |
| Verify Again | The application role can read and write the required tables and use the sequences. The affected features work again. |
| Document | Recorded the missing grants, the GRANT statements used, and the test results. |
| Prevent | Run the grants script as part of every rebuild. Run the privilege verification script after setup. |

### MESA-INC2: Application login role has no password

| Step | Finding |
|---|---|
| Observe (Symptoms & Brief) | The application cannot connect to the database. The server log shows "has no password assigned" on each authentication attempt. |
| Verify | Read the server log and confirmed the error repeats for every attempt. Checked that /health also fails. |
| Hypothesize | The application login role was created without a password, so PostgreSQL rejects password authentication. |
| Test | Checked the role in the catalog for a missing password (rolpassword is null). Tried a login with the configured credentials. |
| Act | Assigned a secure password to the login role. Updated the application's database configuration with the correct credentials. |
| Verify Again | The connection succeeds, /health reports OK, and application features load. |
| Document | Recorded the cause and the change. The password itself is not written in this report or in any script. |
| Prevent | Set the password with psql \password or an environment variable at setup. Never commit credentials. |

### MESA-INC3: Autovacuum disabled during bulk loading

| Step | Finding |
|---|---|
| Observe (Symptoms & Brief) | The order queue became noticeably slower after a large data import. Order retrieval and processing take longer than usual. |
| Verify | Timed the order queue query and reviewed its plan with EXPLAIN ANALYZE. Confirmed the slowdown began after the bulk load. |
| Hypothesize | Autovacuum was disabled during the load, so dead tuples accumulated and planner statistics became outdated. |
| Test | Queried pg_stat_user_tables for n_dead_tup, last_autovacuum and last_analyze. Checked the autovacuum setting on the affected tables. |
| Act | Re-enabled autovacuum. Ran VACUUM ANALYZE on the affected tables. |
| Verify Again | Dead tuples were cleared, statistics were refreshed, and the order queue query time returned to normal. |
| Document | Recorded before and after statistics and query timings. |
| Prevent | Re-enable autovacuum right after any bulk load and run ANALYZE as the last step. Monitor dead tuples. |

### MESA-INC4: Backup restoration script does not validate backup integrity

| Step | Finding |
|---|---|
| Observe (Symptoms & Brief) | A database restoration fails or produces incomplete data. |
| Verify | Compared the selected backup file's actual size and SHA-256 hash with the values in the backup log. |
| Hypothesize | The selected backup does not match its recorded metadata, so it is damaged or incomplete. The restore script does not validate it first. |
| Test | Computed the file size and checksum. Compared them with the log. Test-restored a candidate backup in a separate database. |
| Act | Rejected the mismatched file. Selected a verified backup and restored it in a separate database. |
| Verify Again | Size and checksum matched the log. The restore completed and the restored data was complete. |
| Document | Recorded the mismatch, the rejected file, the verified file, and the restore result. |
| Prevent | Make the restore script check size and checksum before use and stop on a mismatch. Test restores regularly. |

### MESA-INC5: Idle maintenance session holds exclusive lock on orders

| Step | Finding |
|---|---|
| Observe (Symptoms & Brief) | Database operations on the orders table wait or time out, and staff cannot retrieve or process orders. |
| Verify | Reproduced the wait from a second session. Confirmed the problem affected only the orders table. |
| Hypothesize | An idle maintenance session is holding an exclusive lock on the orders table and blocking other transactions. |
| Test | Checked pg_stat_activity and pg_locks, and used pg_blocking_pids to find the blocking session and its state. |
| Act | Found the inactive session holding the lock. With administrator approval, released it safely. |
| Verify Again | Blocked sessions proceeded. Normal read and write operations on orders worked. |
| Document | Recorded the blocking session, the approval, the action taken, and the result. |
| Prevent | Set idle_in_transaction_session_timeout and lock_timeout. Schedule maintenance outside service hours. |

## Part D – Troubleshooting Plan and Corrective Action (Owner Group)

### MESA-INC1: Grants lost after database rebuild

| Item | Details |
|---|---|
| Troubleshooting Plan | Check the log, then the application role's privileges on tables and sequences. Risk: granting too much, so grant only what the application needs. Rollback: REVOKE the new grants. |
| Root Cause | Database permissions were lost after the rebuild, so the application role could not access the required tables. |
| Alternative Cause Considered | Application or code bug. Ruled out because /health passed and the database accepted the connection; the role lacked privileges. |
| Corrective Action | Reapplied GRANT statements on the required tables and sequences. |
| Verification | Pass: the role can SELECT and INSERT on the required tables and use the sequences, and the application features work. Before the fix, the same actions failed with permission denied. |
| Recommendation | Include the grants script in the rebuild procedure and run the privilege check after every rebuild. |

### MESA-INC2: Application login role has no password

| Item | Details |
|---|---|
| Troubleshooting Plan | Read the server log, check the role in the catalog, then set the password and update the configuration. Risk: wrong credentials locking the application out. Rollback: reset the password and restore the previous configuration file. |
| Root Cause | The application login role had no password, so PostgreSQL rejected authentication. |
| Alternative Cause Considered | Network or pg_hba.conf problem. Ruled out because the log message names the missing password, not a refused connection. |
| Corrective Action | Assigned a secure password to the role. Updated the application's database configuration with the correct credentials. |
| Verification | Pass: the application connects and /health reports OK. Expected to fail before the fix: login with an empty password. |
| Recommendation | Set passwords at setup without writing them in scripts. Store them in configuration kept out of the repository. |

### MESA-INC3: Autovacuum disabled during bulk loading

| Item | Details |
|---|---|
| Troubleshooting Plan | Time the slow query, check dead tuples and statistics, then re-enable autovacuum and run VACUUM ANALYZE. Risk: VACUUM uses I/O, so run it when traffic is low. Rollback: not needed; VACUUM and ANALYZE do not change data. |
| Root Cause | Autovacuum was disabled during bulk loading, leaving dead tuples and stale statistics. |
| Alternative Cause Considered | Missing index or hardware limit. Ruled out because the slowdown began after the import and recovered after maintenance, with no schema change. |
| Corrective Action | Re-enabled autovacuum and executed VACUUM ANALYZE on the affected tables. Checked statistics and monitored query performance. |
| Verification | Pass: dead tuples are low, last_analyze is recent, and the order queue time is back to normal. |
| Recommendation | Re-enable autovacuum after every bulk load and add ANALYZE to the load script. |

### MESA-INC4: Backup restoration script does not validate backup integrity

| Item | Details |
|---|---|
| Troubleshooting Plan | Compare size and SHA-256 with the backup log, then test-restore in a separate database. Risk: restoring a bad file over live data, so never restore into the live database first. Rollback: drop the test database. |
| Root Cause | The restore script selected a backup without checking its integrity. The file's size and hash did not match the backup log. |
| Alternative Cause Considered | Wrong database version or restore command error. Ruled out because the file metadata itself did not match the log. |
| Corrective Action | Verified size and checksum, rejected the mismatched file, selected a verified backup, and tested its restoration in a separate database. |
| Verification | Pass: size and checksum match the log, the restore completes without errors, and row counts match the source. |
| Recommendation | Add checksum and size validation to the restore script. Keep the backup log current and test restores regularly. |

### MESA-INC5: Idle maintenance session holds exclusive lock on orders

| Item | Details |
|---|---|
| Troubleshooting Plan | Check pg_stat_activity and pg_locks, find the blocker with pg_blocking_pids, and confirm it is idle. Risk: ending a session that is doing real work, so get administrator approval first. Rollback: the session's open transaction is rolled back, so no partial changes remain. |
| Root Cause | An idle maintenance session held an exclusive lock on the orders table and blocked other transactions. |
| Alternative Cause Considered | Slow query or server overload. Ruled out because the waiting sessions were blocked by a lock, and the holder was idle. |
| Corrective Action | Identified the inactive session and released it safely with administrator approval. |
| Verification | Pass: no sessions are waiting on orders, and normal operations complete. |
| Recommendation | Set idle_in_transaction_session_timeout and lock_timeout. Keep maintenance sessions short and scheduled. |

### Verification Summary

| Incident ID | Check performed | Result |
|---|---|---|
| MESA-INC1 | Application role privileges on tables and sequences; application features retested | Passed |
| MESA-INC2 | Login with the new password; /health and application features | Passed |
| MESA-INC3 | Dead tuple count, last_analyze, order queue timing | Passed |
| MESA-INC4 | Size and SHA-256 against the backup log; restore in a separate database | Passed |
| MESA-INC5 | No blocked sessions; normal operations on orders | Passed |

### Prevention and Escalation

**Prevention:** run the grants script and the privilege verification after every rebuild; set passwords outside scripts; re-enable autovacuum and ANALYZE after bulk loads; validate backups before restore; use idle and lock timeouts.

**Escalation:** ending a database session, restoring from a backup, and any change that affects the production database require administrator or instructor approval first.

## Part F – Technical Defense

| Question | Answer |
|---|---|
| Why did the application show "Something went wrong" while /health was healthy? | The health check only proves the database accepts a connection. The application role had lost its privileges on the tables and sequences after the rebuild, so the real queries failed with permission denied. |
| Why is a missing role password a database problem and not an application problem? | PostgreSQL rejects the login before any query runs. The server log shows "has no password assigned", so the cause is the role, not the application code. |
| Why does a bulk load make queries slower? | With autovacuum disabled, dead tuples pile up and the planner statistics stay old, so the planner picks poor plans. VACUUM ANALYZE removes the dead tuples and refreshes the statistics. |
| Why check size and SHA-256 before a restore? | A truncated or damaged backup can restore partly or fail. Comparing size and hash with the backup log shows whether the file can be trusted, and a test restore in a separate database confirms it. |
| How did you find the blocking session, and why was approval needed? | pg_stat_activity and pg_locks (with pg_blocking_pids) show which session holds the lock and that it is idle. Ending it rolls back its open transaction, so an administrator must approve. |
| Why work on a disposable copy? | The fixes change privileges, settings and data, and the restore test could overwrite data. A copy keeps the original database safe and can be restored if a test fails. |

## Part G – Repository, Tracker, and Progress Documentation

| Item | Status and location |
|---|---|
| midterm/ folder with designer and owner subfolders | Owner subfolder holds the investigation of our own project: scripts used for the five fixes, test queries, and notes. |
| Passwords, secrets, and data backups | None included. The application password is set with psql \password or kept in configuration outside the repository. |
| Commits | Meaningful commits, for example: add grants fix; add role password fix; add autovacuum maintenance script; add backup verification; add lock investigation notes. Every member makes at least one commit. |
| Other groups' repositories | Not changed. |

| Incident ID | Owner status | Owner result |
|---|---|---|
| MESA-INC1 | Resolved | Entered by Group 10 |
| MESA-INC2 | Resolved | Entered by Group 10 |
| MESA-INC3 | Resolved | Entered by Group 10 |
| MESA-INC4 | Resolved | Entered by Group 10 |
| MESA-INC5 | Resolved | Entered by Group 10 |

### Contribution Record

| Date | Milestone | Who | Key Commits |
|---|---|---|---|
| Nov 1, 2026 | Project repository initialization & initial README | Celleyna | f6bi650 |
| Nov 3, 2026 | Added database schema, configuration, connection test, and setup docs | Jenny-57, Celleyna, AkiAkira07 | a9588a9, c4ddf7e |
| Nov 4, 2026 | Updated seed data, CRUD tests, and security/access control plans | Jenny-57, AkiAkira07, Celleyna | c6b028d, 91803fa, fe9eb23 |
| Nov 5, 2026 | Final application evidence, privilege test verification (PASS \| 26), and UI updates | jaimient, Jenny-57, AkiAkira07, Celleyna, kathlenmaecallos11-arch | dfc538e, 74f7ebc, ba82400, 85fb5ef |

### AI Usage Declaration

- Tool used: Claude
- What it generated or suggested: the structure and wording of this report, based on the incident descriptions and fixes our group supplied.
- How it was validated: our group compared each statement with the fixes we actually made and the test results from our disposable copy. Items that do not match our work were corrected before submission.
- Not done by the AI: running SQL on PostgreSQL. The group ran all checks and fixes itself.
- No passwords or secrets appear in this report.

### Student Submission Checklist

- [ ] We investigated all five incidents designed for our project and followed the workflow.
- [ ] We wrote a troubleshooting plan before acting and verified each fix.
- [ ] We worked only on disposable copies and preserved every original database and repository.
- [ ] Our scripts and evidence are in our own repository, and our tracker rows are updated.
- [ ] Our report is complete and contains no secrets.
- [ ] Every group member can explain both roles.
- [ ] We declared AI usage and validated any AI-generated suggestions.
