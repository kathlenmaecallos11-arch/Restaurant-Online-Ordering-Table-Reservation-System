# Activity 4 Testing Log - Group 11

## 1. Project Details
* **Project Tested:** Group 11 - BoardTrack: Boarding House & Rental Management System
* **Testing Group:** Group 10
* **Repository Link:** https://github.com/karlrobertc-art/BoardTrack.git
* **Branch Tested:** main

## 2. System Requirements & Prerequisites
* **Language/Environment:** Web / Application environment
* **Database:** PostgreSQL (7 main application tables: `property`, `room`, `tenant`, `lease`, `payment`, `utility bill`, and `app_user`, plus trigger functions, summary views, and constraints)
* **Build Tool:** npm / Package manager

## 3. Issues Found
### 1. Script Provision & Access-Control Gaps
* Setup scripts are provided through `db/boardtrack_full_setup.sql` which creates tables, constraints, indexes, triggers, and views.
* Requires strict enforcement of least-privilege boundaries across runtime, read-only, and administrator roles].

## 4. Setup & Execution Results

| Step / Test Case | Result | Remarks / Notes |
| --- | --- | --- |
| Repository Clone | Success | Successfully cloned from GitHub. |
| Database & Schema Setup | Success with Issues | Setup scripts successfully provided and structured; actual execution and restoration require verification in PostgreSQL or pgAdmin. |
| Privilege & Access Review | Done (Static) | Static review completed: runtime requires SELECT, INSERT, UPDATE, and controlled DELETE; read-only requires SELECT on business tables and summary views; admin requires full business privileges without superuser or createrole. |

## 5. Overall Result & Feedback
* **Result:** Some Issues
* **Feedback for Original Developers:**
  1. Ensure complete and automated execution of full setup scripts for local environments.
  2. Maintain strict least-privilege boundaries for application runtime versus administrative operations.
