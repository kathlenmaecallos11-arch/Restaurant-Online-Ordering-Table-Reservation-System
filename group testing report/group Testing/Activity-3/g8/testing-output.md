# Activity 3 Testing Log - Campus-Canteen-Pre-Order-and-Queue-Management-System

## Project Details
- **Project Tested:** Campus-Canteen-Pre-Order-and-Queue-Management-System
- **Testing Group:** Group 10 
- **Repository Link:** https://github.com/EclipseChan/bwisIT-Solutions---Campus-Canteen-Pre-Order-and-Queue-Management-System.git
- **Branch Tested:** main

---

## 1. System Requirements & Prerequisites
- **Language/Environment:** PHP / PostgreSQL (PostgreSQL 14+)
- **Database:** `canteen_db`
- **Required Roles:** `canteen_admin`, `canteen_app`, `canteen_readonly`

---

## 2. Issues Found
1. **Missing Environment Configuration (`.env`):**
   - The repository lacks a pre-configured `.env` file out-of-the-box, causing the PowerShell setup script (`setup.ps1`) to halt and throw a `Missing .env. Run: Copy-Item .env.example .env` exception.
2. **Database Not Automatically Created:**
   - Executing connection queries or running scripts via specific user accounts (`canteen_admin`) results in a fatal error because the `canteen_db` database does not exist initially and must be created manually.

---

## 3. Setup & Execution Results

| Step / Test Case | Result | Remarks / Notes |
| :--- | :--- | :--- |
| **Repository Clone** | **Success** | Successfully cloned from GitHub. |
| **Role Creation Scripts** | **Success** | Successfully executed `01-create-roles.sql` and `02-role-memberships.sql` via `psql`. |
| **Environment Setup** | **Some Issues** | Halted initially due to missing `.env` configuration file. |
| **Database Connection & Initialization** | **Failed / Some Issues** | Encountered fatal connection errors (`database "canteen_db" does not exist`) when connecting before manual database creation. |

---

## 4. Overall Result & Feedback
- **Result:** **Some Issues**
- **Feedback for Original Developers:** 
  1. Include a default `.env` template file or clear instructions in the README to copy `.env.example` before running setup scripts.
  2. Ensure the database creation step (`CREATE DATABASE canteen_db;`) is automatically handled or explicitly documented prior to running role assignments and schema scripts.
