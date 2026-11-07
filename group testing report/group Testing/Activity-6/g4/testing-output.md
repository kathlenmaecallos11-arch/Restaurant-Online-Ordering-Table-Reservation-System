# Activity 6 Report: Group 4 - BrewPOS

## 1. Project & Backup Overview
- **Project Name:** BrewPOS
- **Repository URL:** https://github.com/Nycri/brewpos
- **Database Name:** `brewpos_db`
- **Backup File Name:** `grp_brewposdb_activity6.dump`
- **File Size:** Not recorded
- **SHA-256 Checksum:** Not recorded
- **Date & Time Created:** Not recorded

## 2. Backup Creation & Archive Inspection
- **Method Used:** Logical backup using `pg_dump` in custom archive format (`-Fc`), restored via `pg_restore`.
- **Inspection Result (`pg_restore --list`):** BrewPOS uses PostgreSQL and has five documented database tables, but Group 4-specific Activity 6 backup evidence was unavailable.
- **Status:** **Failed / Missing Evidence**

## 3. Restoration & Verification
- **Test Database Target:** `brewpos_db_restore_test`
- **Verification Steps:**
  - Checksum verification could not be performed due to missing backup records.
  - Object lists, row counts, and verification queries could not be executed because backup files and restoration logs were absent.

## 4. Access Control After Restore
- **Roles Recreated:** Dedicated backup and administrative roles designed under Activity 4.
- **Privileges Verified:** Unable to test against the restored environment due to missing backup artifacts.
- **Access Control Status:** **No** (Verification data unavailable)

## 5. Controlled Recovery Simulation
- **Incident Simulated:** Controlled recovery path testing could not be completed for this project.
- **Recovery Path:** Pending acquisition of valid backup files and test restoration logs.
- **Status:** **Failed / Not Performed**

## 6. Limitations & Errors Encountered
- **Status/Issues:** **Failed / Missing Evidence**
- **Cause & Resolution:** 
  - *Cause:* No error or warning recorded in the available Activity 6 evidence because no Group 4-specific backup and restoration test results were provided.
  - *Resolution:* Obtain the actual backup files, record file size and SHA-256 checksum, verify the archive, and execute test restoration.
  - *Additional System Note:* The project relies on application requirements/uploads that should also be tracked alongside database assets.

## 7. Feedback to Owners
- **Key Finding:** The project uses PostgreSQL and has five documented database tables, but Group 4-specific Activity 6 backup evidence was unavailable.
- **Recommendation:** Provide actual backup files, SHA-256 verification, archive inspection, and successful restoration evidence.


