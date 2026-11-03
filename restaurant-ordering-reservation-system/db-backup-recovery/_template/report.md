# Backup, restoration and recovery report — Group __ : <project>

## 1. Backup (evidence: evidence/backup-log.csv, archive-listing_*.txt)
Command (placeholders only): `pg_dump -U <backup_account> -h localhost -p 5432 -Fc -d <db> -f <db>_activity6_<stamp>.dump`
File / size / SHA-256 / time / errors:
What the `pg_restore --list` output shows and why an existing file is not proof of recovery:

## 2. Restoration (evidence: restore_output.txt, restore_verification.txt, rowcounts_*.csv)
Test database: `<db>_restore_test` · Options used and why · Warnings explained:
Objects / records / constraints / representative query results:

## 3. Access control after restore
How Activity 4 roles and privileges were re-created · permitted test + denied test results:

## 4. Recovery simulation (evidence: recovery-timeline.txt, recovery_before/after.json)
Incident · timeline · method and why · expected vs recovered · what differs if the loss occurs after the last backup:

## 5. Evaluation and recommendations
Is nightly `pg_dump` enough? RPO/RTO measured vs proposed · improvements (WAL archiving/PITR, off-site copy, restore drills, encryption):

## 6. Limitations and errors
