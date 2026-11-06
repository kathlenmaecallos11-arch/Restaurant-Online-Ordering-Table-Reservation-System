# Activity 4 Testing Log - Group 6

## 1. Project Details
* **Project Tested:** Group 6 - HabalGo - Ride and Booking Management System
* **Testing Group:** Group 10
* **Repository Link:** https://github.com/jeanaroyo/HabalGo.git
* **Branch Tested:** main

## 2. System Requirements & Prerequisites
* **Language/Environment:** Node.js, Express, JavaScript, SQL / Database environment
* **Database:** PostgreSQL / Relational Database
* **Build Tool:** npm

## 3. Issues Found
### 1. Database Configuration & Role Privileges Gaps
* Hardcoded database credentials or configuration files requiring manual adjustments for local testing environments.
* Lack of explicitly separated least-privilege database roles for runtime vs. administrative operations.

## 4. Setup & Execution Results

| Step / Test Case | Result | Remarks / Notes |
| --- | --- | --- |
| Repository Clone | Success | Successfully cloned from GitHub. |
| Database & Schema Setup | Success with Issues | Database and schema configured after setting up connection parameters. |
| Privilege & Access Review | Done (Static) | Static access control review completed for runtime and admin roles. |

## 5. Overall Result & Feedback
* **Result:** Some Issues
* **Feedback for Original Developers:**
  1. Externalize database configurations using environment variables (`.env`).
  2. Implement proper role separation and restrict direct administrative privileges on operational queries.
