# Activity 3 Testing Log - Group 5

## 1. Project Details
- **Project Tested:** Group 5 - PUP-SPOT: Campus Lost and Found
- **Testing Group:** Group 10
- **Repository Link:** https://github.com/grp05-dba/grp05_lostandfound
- **Branch Tested:** main

---

## 2. System Requirements & Prerequisites
- **Language/Environment:** PHP 8.0 or later
- **Database:** PostgreSQL (`grp05_lostandfounddb`)
- **Required Extensions:** `pdo_pgsql`, `pgsql`

---

## 3. Issues Found
1. **PHP Runtime & PATH Environment Blocker:**
   - Executing the required version and extension checks from Step 3.1 of the README (`php -v` and `php -m`) fails with `php : The term 'php' is not recognized as the name of a cmdlet, function, script file, or operable program`[cite: 2, 3].
   - Because PHP is not installed or missing from the system PATH, local application server execution (`php -S 127.0.0.1:8000` / `php -S 127.0.0.1:8001`) could not be initiated[cite: 2].

---

## 4. Setup & Execution Results

| Step / Test Case | Result | Remarks / Notes |
| :--- | :--- | :--- |
| **Repository Clone** | Success | Successfully cloned from GitHub. |
| **Database Creation** | Success | Created `grp05_lostandfounddb` in PostgreSQL via pgAdmin / psql. |
| **SQL Script Execution** | Success | Schema (`schema.sql`), necessary data, and role creation scripts executed without errors. |
| **PHP Driver Verification** | Failed | Executing `php -v` / `php -m` failed due to missing PHP installation or system PATH mapping[cite: 2, 3]. |
| **Application Run** | Partial / Blocked | Database setup is complete, but unable to launch web interfaces (`127.0.0.1:8000` / `127.0.0.1:8001`) due to missing PHP CLI in PATH[cite: 2]. |

---

## 5. Overall Result & Feedback
- **Result:** Some Issues
- **Feedback for Original Developers:**
  1. Specify system `PATH` configuration requirements for PHP in the environment setup prerequisites section of the `README.md`.
  2. Include instructions or wrapper scripts for evaluators testing on clean Windows workstations where PHP binaries are not mapped globally.
