# Activity 6 Report: Group 8 - Campus Canteen Pre-Order and Queue Management System

## 1. Project & Backup Overview
- **Project Name:** Campus Canteen Pre-Order and Queue Management System
- **Repository URL:** https://github.com/EclipseChran/bwisIT-Solutions---Campus-Canteen-Pre-Order-and-Queue-Management-System.git
- **Database Name:** `canteen_db`
- **Backup File Name:** `canteen_db_activity6.backup`
- **File Size:** 27,405 bytes
- **SHA-256 Checksum:** `1F94752EAEFA683AFF69E12554130D8D872C0245EB6A4F46D4CB27B07D36988F`
- **Date & Time Created:** 11/04/2026 9:34:58 PM

## 2. Backup Creation & Archive Inspection
- **Method Used:** Logical backup using `pg_dump` in custom archive format (`-Fc`), restored via `pg_restore`.
- **Inspection Result (`pg_restore --list`):** Verified that schemas, tables (`canteen_db` objects), constraints, indexes, and table data entries are correctly contained in the archive.
- **Status:** **Success (after permission fix)**

## 3. Restoration & Verification
- **Test Database Target:** `canteen_db_restore_test`
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
- **Recovery Path:** Restored the checksum-verified backup into a fresh recovery database (`canteen_db_recovery`) and confirmed data integrity against the expected state.
- **Status:** **Success**

## 6. Limitations & Errors Encountered
- **Status/Issues:** **Success (after resolving a schema permission issue)**
- **Cause & Resolution:** 
  - Encountered `ERROR: permission denied for schema public`.
  - *Cause:* The restored database was owned by `postgres`, while the canteen admin needed explicit schema permissions after public access was revoked.
  - *Resolution:* Executed `GRANT USAGE, CREATE ON SCHEMA public TO canteen_admin;` to resolve the permission issue successfully.

## 7. Feedback to Owners
- **Key Finding:** Backup restoration was successful after resolving a schema permission issue.
- **Recommendation:** Review schema ownership and permissions before restoration, implement automated backups, and conduct monthly restoration drills.

