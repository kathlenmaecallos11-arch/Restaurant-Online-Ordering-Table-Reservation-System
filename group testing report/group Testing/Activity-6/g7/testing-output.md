# Activity 6 Report: Group 7 - CampusSafe

## 1. Project & Backup Overview
- **Project Name:** CampusSafe
- **Repository URL:** https://github.com/jeffersonorpesa2-ops/grp07-campussafe
- **Database Name:** `campussafe_db`
- **Backup File Name:** `grp07_campussafedb_activity6.dump`
- **File Size:** 47,711 bytes
- **SHA-256 Checksum:** `73DC76542E218D4046B236C72A7FF58019862A38AC5DEF5FAE75D59D77FB99B2`
- **Date & Time Created:** 11/04/2026 8:43:58 PM

## 2. Backup Creation & Archive Inspection
- **Method Used:** Logical backup using `pg_dump` in custom archive format (`-Fc`), restored via `pg_restore`.
- **Inspection Result (`pg_restore --list`):** Verified that schemas, tables (`campussafe_db` objects), constraints, indexes, and table data entries are correctly contained in the archive.
- **Status:** **Success**

## 3. Restoration & Verification
- **Test Database Target:** `campussafe_db_restore_test`
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
- **Recovery Path:** Restored the checksum-verified backup into a fresh recovery database (`campussafe_db_recovery`) and confirmed data integrity against the expected state.
- **Status:** **Success**

## 6. Limitations & Errors Encountered
- **Status/Issues:** **Success (with expected access restriction)**
- **Cause & Resolution:** 
  - Encountered `ERROR: permission denied for table app_user`.
  - *Cause:* The `campussafe_report` role does not have permission to access sensitive user records.
  - *Resolution:* No additional permissions were granted. The restriction was retained to protect confidential campus user information.

## 7. Feedback to Owners
- **Key Finding:** Backup restoration was successful, and database constraints and restricted access to user records were preserved.
- **Recommendation:** Automate daily backups and implement WAL archiving to improve recovery from unexpected data loss.

