# Activity 4 Testing Log - Group 4

## 1. Project Details
* **Project Tested:** Group 4 - BrewPOS
* **Testing Group:** Group 10
* **Repository Link:** https://github.com/Nycri/brewpos
* **Branch Tested:** main

## 2. System Requirements & Prerequisites
* **Language/Environment:** Application source files and SQL scripts
* **Database:** PostgreSQL
* **Build Tool:** SQL script execution (Scripts 01, 02, 04, 06, and 03)

## 3. Issues Found
### 1. App-Role Script Incomplete / Not Run
* Scripts 01, 02, 04, 06, and 03 passed successfully, but the specific application-role script was not executed.
* Sequence `USAGE` privileges need confirmation for the application role.

## 4. Setup & Execution Results

| Step / Test Case | Result | Remarks / Notes |
| --- | --- | --- |
| Repository Clone | Success | Successfully cloned from GitHub. |
| Database & Schema Setup | Success with Issues | Scripts 01, 02, 04, 06, and 03 passed; app-role script was not run. |
| Privilege & Access Review | Done (Static) | Runtime DELETE denied; runtime order-line insert allowed; sequence USAGE checked. |

## 5. Overall Result & Feedback
* **Result:** Some Issues
* **Feedback for Original Developers:**
  1. Grant sequence USAGE to the application role and confirm that DELETE operations are properly restricted.
