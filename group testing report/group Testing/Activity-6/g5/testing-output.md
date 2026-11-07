# Activity 6 Report: Group 5 - Lost and Found

## 1. Project & Backup Overview
- **Project Name:** Lost and Found
- **Repository URL:** https://github.com/grp05-dba/grp05_lostandfound
- **Database Name:** `lostandfound_db`
- **Backup File Name:** `grp05_lostandfounddb_activity6.dump`
- **File Size:** 35,083 bytes
- **SHA-256 Checksum:** `FA6808CEA3E2ACAF86A8887B5BAF86E04445A6C5A8C899D9B3D75F9EBB02D352C`
- **Date & Time Created:** 11/04/2026 5:55:58 AM

## 2. Backup Creation & Archive Inspection
- **Method Used:** Logical backup using `pg_dump` in custom archive format (`-Fc`), restored via `pg_restore`.
- **Inspection Result (`pg_restore --list`):** Verified that schemas, tables (`lostandfound_db` objects), constraints, indexes, and table data entries are correctly contained in the archive.
- **Status:** **Success**

## 3. Restoration & Verification
- **Test Database Target:** `lostandfound_db_restore_test`
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
- **Recovery Path:** Restored the checksum-verified backup into a fresh recovery database (`lostandfound_db_recovery`) and confirmed data integrity against the expected state.
- **Status:** **Success**

## 6. Limitations & Errors Encountered
- **Status/Issues:** **Success (with expected access restriction)**
- **Cause & Resolution:** 
  - Encountered `ERROR: permission denied for table items`.
  - *Cause:* The `lostandfound_public` role is not authorized to update records in the `items` table.
  - *Resolution:* No additional permissions were granted. The restriction was retained to prevent unauthorized modification of lost-and-found records.
  - *Additional System Note:* Image records depend on files stored in the `storage/` directory, which must be included in overall backup procedures.

## 7. Feedback to Owners
- **Key Finding:** Backup restoration was successful, but image records depend on files stored in the `storage/` directory.
- **Recommendation:** Include the storage directory in backup procedures and implement automated backups and WAL archiving.

