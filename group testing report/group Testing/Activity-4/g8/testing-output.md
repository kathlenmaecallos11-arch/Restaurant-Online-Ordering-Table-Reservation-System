# Activity 4 Testing Log - Group 8

## 1. Project Details
* **Project Tested:** Group 8 - Campus Canteen Pre-Order and Queue Management System
* **Testing Group:** Group 10
* **Repository Link:** https://github.com/EclipseChan/bwisIT-Solutions---Campus-Canteen-Pre-Order-and-Queue-Management-System.git
* **Branch Tested:** main

## 2. System Requirements & Prerequisites
* **Language/Environment:** Web / Application environment
* **Database:** PostgreSQL (7 tables and check constraints)
* **Build Tool:** npm / Package manager

## 3. Issues Found
### 1. Migration Order & Data Protection Gaps
* Sample data script (`001_sample_data.sql`) requires preliminary migrations to be executed first.
* Potential risks regarding duplicate queue numbers and exposure of password hashes to read-only roles.

## 4. Setup & Execution Results

| Step / Test Case | Result | Remarks / Notes |
| --- | --- | --- |
| Repository Clone | Success | Successfully cloned from GitHub. |
| Database & Schema Setup | Success with Issues | Migrations 001 and 002 along with seed data load cleanly once the proper migration sequence is followed. |
| Privilege & Access Review | Done (Static) | Static review completed: runtime requires S/I/U on seven tables; read-only requires SELECT with password hashes protected. |

## 5. Overall Result & Feedback
* **Result:** Some Issues
* **Feedback for Original Developers:**
  1. Implement checks or constraints to prevent duplicate queue numbers.
  2. Ensure sensitive fields such as `password_hash` are strictly hidden from read-only and reporting roles.
