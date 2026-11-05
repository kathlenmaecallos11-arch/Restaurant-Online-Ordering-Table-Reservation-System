# Privilege Testing Results

**Project Name:** Restaurant Online Ordering & Table Reservation System  
**Database Name:** `grp_binarysisters_projectdb`  
**Date:** November 2026  

---

## 1. Database Roles & Attributes Verification (S1 / S2)
The database environment was verified to ensure that all standard roles (`g03_*`, `rors_*`) are properly configured and unnecessary personal roles are cleaned up.

### Role List (`\du`)
![Role List Verification](./evidence/Screenshot_2026-11-05_024014.png)

### Role Attributes & Connection Limits
![Role Attributes](./evidence/Screenshot(345).png)

### Role Memberships & Table Privilege Matrix
![Role Memberships and Matrix](./evidence/Screenshot(346).png)

---

## 2. Interactive Role Login & Privilege Enforcement Tests

Manual connection and query tests were performed using `\c` to verify that each user account complies with its assigned permissions and restrictions.

### 1. Database Administrator (`rors_dba`)
- **Test:** Can create/drop temporary tables, but restricted from creating new databases.
- **Evidence:**
![rors_dba test](./evidence/Screenshot_2026-11-05_082010.png)[cite: 12]

### 2. Backup Role (`rors_backup`)
- **Test:** Can read table data (`SELECT`), but cannot modify or delete data.
- **Evidence:**
![rors_backup test](./evidence/Screenshot_2026-11-05_081846.png)[cite: 13]

### 3. Maintenance Role (`rors_maint`)
- **Test:** Can perform maintenance tasks like `VACUUM`, but blocked from direct SELECT queries on restricted tables.
- **Evidence:**
![rors_maint test](./evidence/Screenshot_2026-11-05_081831.png)[cite: 14]

### 4. Reporting Role (`rors_report`)
- **Test:** Can access reporting views, but restricted from reading sensitive columns (e.g., passwords).
- **Evidence:**
![rors_report test](./evidence/Screenshot_2026-11-05_080757.png)[cite: 15]

### 5. Application Role (`rors_app`)
- **Test:** Full transactional access on allowed tables, blocked from restricted deletions and database creation.
- **Evidence:**
![rors_app test](./evidence/Screenshot_2026-11-05_080546.png)[cite: 16]

---

## 3. Automated Security Verification Matrix

Automated verification scripts (`04_verify_privileges.sql`) tested all permissions across operational roles.

- **Total Tests Executed:** 26[cite: 5]
- **Passed:** 26[cite: 5]
- **Failed:** 0[cite: 5]

### Test Matrix Execution Logs
![Test Matrix Part 1](./evidence/Screenshot(344).png)[cite: 5]
![Test Matrix Part 2](./evidence/Screenshot(343).png)[cite: 6]

---

## 4. Conclusion
All security configurations, access control policies, privilege matrices, and role restrictions successfully passed evaluation with a **100% PASS rate (26/26)**[cite: 5]. The database enforces least-privilege principles across all operational user accounts.
