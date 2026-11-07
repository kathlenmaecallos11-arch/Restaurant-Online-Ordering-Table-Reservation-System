# Activity 6 Report: Group 2 - ParkIt

## 1. Project & Backup Overview
- **Project Name:** ParkIt
- **Repository URL:** https://github.com/millerdevera6-glitch/park-it-database.git
- **Database Name:** `park_it_db`
- **Backup File Name:** `grp_parkitdb_activity6.dump`
- **File Size:** 19,750 bytes
- **SHA-256 Checksum:** `7F836A870824269350C868AB8D95EE89A177441D810CDFE8284483D87FB2F4A35`
- **Date & Time Created:** 11/04/2026 8:46:41 AM

## 2. Backup Creation & Archive Inspection
- **Method Used:** Logical backup using `pg_dump` in custom archive format (`-Fc`), restored via `pg_restore`.
- **Inspection Result (`pg_restore --list`):** Verified that the schema, tables (`park_it_db` objects), constraints, indexes, and table data entries exist correctly in the archive.
- **Status:** **Success**

## 3. Restoration & Verification
- **Test Database Target:** `park_it_db_restore_test`
- **Verification Steps:**
  - Checksum re-verified successfully before restoration using `sha256sum -c`.
  - Object lists (`\dt+`, `\di+`, `\df`) and information schema queries matched the original database.
  - Row counts and representative `SELECT` queries executed successfully and matched baseline data.
  - Constraints check (`contype` for Primary Keys, Foreign Keys, Unique, and Check) verified full parity.

## 4. Access Control After Restore
- **Roles Recreated:** Activity 4 roles (dedicated backup role and administrative roles) were recreated prior to restoration to prevent ownership and privilege errors.
- **Privileges Verified:** Tested restricted operations against the restored environment.
- **Access Control Status:** **Yes** (Role-based access controls successfully survived the restore process).

## 5. Controlled Recovery Simulation
- **Incident Simulated:** Accidental deletion of a test record from the transactional tables.
- **Recovery Path:** Restored the checksum-verified backup into a fresh recovery database (`park_it_db_recovery`) and confirmed data integrity against the expected state.
- **Status:** **Success**

## 6. Limitations & Errors Encountered
- **Status/Issues:** **Success (with expected access restriction)**
- **Cause & Resolution:** 
  - Encountered `ERROR: permission denied for table staff_user`.
  - *Cause:* The `parkit_report_user` role intentionally does not possess direct permissions to access the `staff_user` table.
  - *Resolution:* No additional permissions were granted. This restriction was confirmed as expected behavior, validating that the Role-Based Access Control (RBAC) design was functioning correctly.

## 7. Feedback to Owners
- **Key Finding:** Backup restoration was successful, and all database constraints and access restrictions were precisely preserved.
- **Recommendation:** Implement automated daily backups and continuous WAL archiving to ensure point-in-time recovery aligned with ParkIt's 1-hour RPO.


