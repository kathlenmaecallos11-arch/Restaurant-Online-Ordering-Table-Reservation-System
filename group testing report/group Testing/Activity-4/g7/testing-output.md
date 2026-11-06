# Activity 4 Testing Log - Group 7

## 1. Project Details
* **Project Tested:** Group 7 - Campus Safe
* **Testing Group:** Group 10
* **Repository Link:** https://github.com/jeffersonorpesa2-ops/grp07-campussafe[cite: 3]
* **Branch Tested:** main

## 2. System Requirements & Prerequisites
* **Language/Environment:** Web / Application environment
* **Database:** Relational Database / PostgreSQL (`grp07_campussafedb`; 9 tables, 10 indexes, and 6 roles)
* **Build Tool:** npm / Package manager

## 3. Issues Found
### 1. Destructive Scripts & Data Protection Gaps
* Schema and seed scripts erase existing data when executed.
* Sensitive information such as password hashes must be protected from read-only roles.
* Status history should be strictly restricted to INSERT-only operations.

## 4. Setup & Execution Results

| Step / Test Case | Result | Remarks / Notes |
| --- | --- | --- |
| Repository Clone | Success | Successfully cloned from GitHub. |
| Database & Schema Setup | Success with Issues | Scripts and verification pass when the database is named `grp07_campussafedb`; note that schema and seed scripts erase existing data. |
| Privilege & Access Review | Done (Static) | Static review completed: runtime requires S/I/U on application tables (status history S/I only); read-only requires SELECT excluding password hash. |

## 5. Overall Result & Feedback
* **Result:** Some Issues
* **Feedback for Original Developers:**
  1. Add warnings or safeguards before running scripts that perform destructive data resets.
  2. Protect password hashes and ensure status history tables are kept as INSERT-only.
