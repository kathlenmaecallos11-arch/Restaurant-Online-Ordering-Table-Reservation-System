# Activity 6 Report: Group 6 - HabalGo

## 1. Project & Backup Overview
- **Project Name:** HabalGo
- **Repository URL:** https://github.com/jeanaroyo/HabalGo.git
- **Database Name:** `habalgo_db`
- **Backup File Name:** `grp00_habalgodb_activity6.dump`
- **File Size:** 32,794 bytes
- **SHA-256 Checksum:** `6EA2832EB93D77B87A93DA7AEEC44BC377E8DD14633D62632239EA292CC6F549`
- **Date & Time Created:** 11/04/2026 7:30:58 AM

## 2. Backup Creation & Archive Inspection
- **Method Used:** Logical backup using `pg_dump` in custom archive format (`-Fc`), restored via `pg_restore`.
- **Inspection Result (`pg_restore --list`):** Verified that schemas, tables (`habalgo_db` objects), constraints, indexes, and table data entries are correctly contained in the archive.
- **Status:** **Success**

## 3. Restoration & Verification
- **Test Database Target:** `habalgo_db_restore_test`
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
- **Recovery Path:** Restored the checksum-verified backup into a fresh recovery database (`habalgo_db_recovery`) and confirmed data integrity against the expected state.
- **Status:** **Success**

## 6. Limitations & Errors Encountered
- **Status/Issues:** **Success (with expected access restrictions)**
- **Cause & Resolution:** 
  - Encountered `ERROR: permission denied for table location` and `ERROR: permission denied for table payment`.
  - *Cause:* The `habalgo_readonly_user` cannot delete payment records, and write restrictions are enforced on location entries to protect database integrity.
  - *Resolution:* No additional permissions were granted. The restrictions were retained to protect database integrity and payment information under the least-privilege principle.

## 7. Feedback to Owners
- **Key Finding:** Backup restoration was successful, and restricted access to location and payment records was maintained.
- **Recommendation:** Automate daily backups and implement point-in-time recovery to protect ride and payment transactions.

