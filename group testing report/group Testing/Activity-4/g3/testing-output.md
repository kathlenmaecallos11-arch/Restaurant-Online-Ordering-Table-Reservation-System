# Activity 4 Testing Log - Group 3

## 1. Project Details
* **Project Tested:** Group 3 - Project-OJT-RMA-System
* **Testing Group:** Group 10
* **Repository Link:** https://github.com/swvenz/Project-OJT-RMA-System.git
* **Branch Tested:** main

## 2. System Requirements & Prerequisites
* **Language/Environment:** PHP / Web environment, PostgreSQL
* **Database:** Custom binary format database dump (`OJT Database.sql`)
* **Tools:** pgAdmin / psql

## 3. Issues Found
### 1. Custom Binary Format & Missing Roles
* Supplied file is a custom-format lending database dump (`pg_dump`) rather than a plain OJT schema, causing encoding issues in text editors.
* Missing database roles (`loan_admin_grp`, `loan_officer_grp`, `auditor_grp`) causing restoration failure on fresh setup, and pgAdmin 4 Query Tool encounters persistent HTTP 500 errors.

## 4. Setup & Execution Results

| Step / Test Case | Result | Remarks / Notes |
| --- | --- | --- |
| Repository Clone | Success | Successfully cloned from GitHub. |
| Database & Schema Setup | Failed | Supplied file is in binary format (`pg_dump`) requiring manual role creation and CLI restoration. |
| Application Roles & Access Check | Blocked | Login credentials and role permissions were not testable due to incomplete database initialization and startup configurations. |

## 5. Overall Result & Feedback
* **Result:** Some Issues
* **Feedback for Original Developers:**
  1. Provide correct plain SQL OJT schema instead of binary dumps.
  2. Document required roles and restrict access to sensitive fields like `national_id`.
