# Activity 4 Testing Log - Group 2

## 1. Project Details
* **Project Tested:** Group 2 - PARK-IT-DATABASE-MANAGEMENT-SYSTEM
* **Testing Group:** Group 10
* **Repository Link:** https://github.com/millerdevera6-glitch/park-it-database
* **Branch Tested:** main

## 2. System Requirements & Prerequisites
* **Language/Environment:** PHP, PostgreSQL (v16+)
* **Database:** PostgreSQL with custom schema and seed scripts
* **Tools:** pgAdmin / psql

## 3. Issues Found
### 1. PostgreSQL Version Mismatch / Transaction Timeout
* Executing schema and seed scripts failed on PostgreSQL 16 because `SET transaction_timeout` requires PostgreSQL 17 or higher.
* Required removing the timeout line to successfully load the database on older versions.

## 4. Setup & Execution Results

| Step / Test Case | Result | Remarks / Notes |
| --- | --- | --- |
| Repository Clone | Success | Successfully cloned from GitHub. |
| Database & Schema Setup | Some Issues | Migrations and seed ran after removing `SET transaction_timeout` compatible only with PG17+. |
| Application Roles & Access Check | Success | Tested both Admin and Staff accounts; Staff correctly blocked from registration ("Access Denied"), Admin retained full access. |

## 5. Overall Result & Feedback
* **Result:** Some Issues
* **Feedback for Original Developers:**
  1. Adapt or remove PostgreSQL 18/17 specific commands like `SET transaction_timeout` so projects can seamlessly execute on PostgreSQL 16 environments.
  2. Protect sensitive columns such as `staff_user.password_hash` from read-only role queries.
