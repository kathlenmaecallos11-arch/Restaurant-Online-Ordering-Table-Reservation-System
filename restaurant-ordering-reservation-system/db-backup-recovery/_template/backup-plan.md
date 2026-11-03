# Backup plan — Group __ : <project>

| Question | Answer |
|---|---|
| Database / objects to back up | all tables, sequences, views, functions, triggers, constraints, extensions, data of `<db>` (schema `public`) |
| Not covered by the dump | cluster roles and logins, `pg_hba.conf`, `postgresql.conf`, the application's uploaded files / `.env` |
| Method and why | Logical backup, `pg_dump -Fc`: portable across hosts and versions, compressed, supports selective `pg_restore`, no server downtime, fine for small databases. Physical backup / WAL archiving (PITR) is needed only for stricter RPO. |
| Account | `g__backup` (member of `g__backup_grp` -> `pg_read_all_data`; cannot modify anything). Not the application account. |
| Storage location | protected local folder outside any repository, e.g. `%USERPROFILE%\rors-backups\group-__\` (NTFS permissions: owner only) |
| Who may read the backup file | the DBA group members only (it contains personal data and password hashes) |
| Verification | `pg_restore --list` + restore into `<db>_restore_test` + row counts + constraints + sample query + role test. A file on disk alone proves nothing. |
| Proposed schedule (real deployment) | nightly full dump + weekly copy to off-site/offline storage; before every schema change |
| Retention (real deployment) | 7 daily, 4 weekly, 3 monthly; delete older; test a restore monthly |
| RPO | e.g. 24 h for a small restaurant system (up to one day of orders may be re-entered). Tighter RPO -> WAL archiving. |
| RTO | e.g. 2 h to restore service (restore + role re-creation + app reconnect) — measured value from this activity: __ min |
| Re-creating Activity 4 roles after restore | re-run `db-access-control/group-__/01_roles_and_grants.sql` (+ tuning script) with `-v dbname=<restored db>`, set passwords with hidden prompts, run 04 tests |
