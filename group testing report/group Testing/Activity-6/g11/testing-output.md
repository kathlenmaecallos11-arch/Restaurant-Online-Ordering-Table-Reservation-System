# Activity 6 Report: Group 11 - BoardTrack

## 1. Project & Backup Overview
- **Project Name:** BoardTrack
- **Repository URL:** https://github.com/karlrobertc-art/BoardTrack
- **Database Name:** `boardtrack_db`
- **Backup File Name:** `boardtrack_db_activity6.dump`
- **File Size:** 35,849 bytes
- **SHA-256 Checksum:** `5B83883ADEB30784905A7EB22B7B67607DC6D1CCB22A508E5559DE60EB48559A`
- **Date & Time Created:** 11/04/2026 10:48:58 PM

## 2. Backup Creation & Archive Inspection
- **Method Used:** Logical backup using `pg_dump` in custom archive format (`-Fc`), restored via `pg_restore`.
- **Inspection Result (`pg_restore --list`):** Verified that schemas, tables (`boardtrack_db` objects), constraints, indexes, and table data entries are correctly contained in the archive.
- **Status:** **Success**

## 3. Restoration & Verification
- **Test Database Target:** `boardtrack_db_restore_test`
- **Verification Steps:**
  - Checksum re-verified successfully prior to restoration using `sha256sum -c`.
  - Object lists (`\dt+`, `\di+`, `\df`) and information schema queries matched the original database.
  - Row counts and representative `SELECT` queries executed successfully and matched baseline data.
  - Constraint check (`contype` for Primary Keys, Foreign Keys, Unique, and Check) verified full parity.

## 4. Access Control After Restore
- **Roles Recreated:** Activity 4 roles (dedicated backup role and administrative roles) were recreated prior to restoration to prevent missing-role errors.
- **Privileges Verified:** Tested restricted operations against the restored environment.
- **Access Control Status:** **Yes** (Role-based access controls successfully survived the restore process).

## 5. Controlled Recovery Simulation
- **Incident Simulated:** Accidental deletion of a test record from the transactional tables.
- **Recovery Path:** Restored the checksum-verified backup into a fresh recovery database (`boardtrack_db_recovery`) and confirmed data integrity against the expected state.
- **Status:** **Success**

## 6. Limitations & Errors Encountered
- **Status/Issues:** **Success (with expected access restriction)**
- **Cause & Resolution:** 
  - Encountered `ERROR: permission denied for table app_user`.
  - *Cause:* The `boardtrack_report_user` role does not have permission to access sensitive application user records.
  - *Resolution:* No additional permissions were granted. The restriction was retained to enforce least-privilege access.
  - *Additional System Note:* Ensure required PostgreSQL extensions, particularly `btree_gist`, are installed on the server environment.

## 7. Feedback to Owners
- **Key Finding:** Backup restoration was successful, and database constraints, triggers, and access restrictions were preserved.
- **Recommendation:** Ensure required PostgreSQL extensions (particularly `btree_gist`) are installed and automate backups with point-in-time recovery.

