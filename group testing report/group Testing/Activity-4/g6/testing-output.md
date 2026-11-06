# Activity 4 Testing Log - Group 6

## 1. Project Details
* **Project Tested:** Group 6 - HabalGo
* **Testing Group:** Group 10
* **Repository Link:** https://github.com/jeanaroyo/HabalGo.git[cite: 3]
* **Branch Tested:** main

## 2. System Requirements & Prerequisites
* **Language/Environment:** Web / Application environment
* **Database:** Relational Database / PostgreSQL (`habalgo` schema; 8 tables, 5 indexes, and 4 roles)
* **Build Tool:** npm / Package manager

## 3. Issues Found
### 1. Database Configuration & Privilege Gaps
* Scripts require the database to be explicitly named `grp00_habalgodb` to execute properly.
* Needs additional payment checks and proper schema/sequence USAGE grants for runtime and access roles.

## 4. Setup & Execution Results

| Step / Test Case | Result | Remarks / Notes |
| --- | --- | --- |
| Repository Clone | Success | Successfully cloned from GitHub |
| Database & Schema Setup | Success with Issues | Scripts 01-03 pass successfully when the database is properly named `grp00_habalgodb`. |
| Privilege & Access Review | Done (Static) | Static review completed: runtime requires S/I/U on eight tables and schema/sequence USAGE; read-only restricted to SELECT. |

## 5. Overall Result & Feedback
* **Result:** Some Issues
* **Feedback for Original Developers:**
  1. Use the required database naming convention (`grp00_habalgodb`) for consistency.
  2. Implement payment validation checks and ensure proper schema and sequence USAGE grants are configured.
