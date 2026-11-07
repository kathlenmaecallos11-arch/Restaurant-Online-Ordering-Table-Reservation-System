# Activity 6 Report: Group 3 - OJT RMA System

## 1. Project & Backup Overview
- **Project Name:** OJT RMA System
- **Repository URL:** https://github.com/swvenz/Project-OJT-RMA-System.git
- **Database Name:** `rma_db`
- **Backup File Name:** `ojt_management_activity6.dump`
- **File Size:** 56,714 bytes
- **SHA-256 Checksum:** `FC979FF8640AE61F9A747475427E472B7D83434B193D751097DDEF576E3A10A7F`
- **Date & Time Created:** 11/05/2026 3:50:58 AM

## 2. Backup Creation & Archive Inspection
- **Method Used:** Logical backup using `pg_dump` in custom archive format (`-Fc`), restored via `pg_restore`.
- **Inspection Result (`pg_restore --list`):** Verified that schemas, tables (`rma_db` objects), constraints, indexes, and table data entries are correctly contained in the archive.
- **Status:** **Success**

## 3. Restoration & Verification
- **Test Database Target:** `rma_db_restore_test`
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
- **Recovery Path:** Restored the checksum-verified backup into a fresh recovery database (`rma_db_recovery`) and confirmed data integrity against the expected state.
- **Status:** **Success**

## 6. Limitations & Errors Encountered
- **Status/Issues:** **Success (with expected access restriction)**
- **Cause & Resolution:** 
  - Encountered `ERROR: permission denied for table users`.
  - *Cause:* The `ojt_report_user` role intentionally does not possess direct permissions to access the `users` table.
  - *Resolution:* No additional permissions were granted. The restricted access was retained to protect sensitive user information.
  - *Additional System Note:* Student document paths depend on external files stored in `uploads/requirements/`, which require separate file-level backups alongside the database.

## 7. Feedback to Owners
- **Key Finding:** Backup restoration was successful, but student document paths depend on external files stored in `uploads/requirements/`.
- **Recommendation:** Back up the uploads folder together with the database and automate daily database backups.

