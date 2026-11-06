# Activity 4 Testing Log - Group 5

## 1. Project Details
* **Project Tested:** Group 5 - PUP-SPOT
* **Testing Group:** Group 10
* **Repository Link:** https://github.com/grp05-dba/grp05_lostandfound
* **Branch Tested:** main

## 2. System Requirements & Prerequisites
* **Language/Environment:** Node.js, Express, EJS, PostgreSQL
* **Database:** PostgreSQL (`schema.sql` and `seeds.sql`)
* **Build Tool:** npm

## 3. Issues Found
### 1. Hardcoded Local DB Credentials & Password Exposure
* Connection settings in `db.js` were hardcoded to a local developer setup (`postgres:postgres@localhost:5432`).
* Plaintext password fields are returned in queries without column-level restrictions or hashing protection.

## 4. Setup & Execution Results

| Step / Test Case | Result | Remarks / Notes |
| --- | --- | --- |
| Repository Clone | Success | Successfully cloned from GitHub. |
| Database & Schema Setup | Success with Issues | Schema and seed scripts executed after updating `db.js` credentials to match local test environment. |
| Privilege & Access Review | Done (Static) | Static access control review completed; role privileges and query restrictions verified. |

## 5. Overall Result & Feedback
* **Result:** Some Issues
* **Feedback for Original Developers:**
  1. Externalize database configuration settings into environment variables (`.env`).
  2. Implement proper password hashing and restrict sensitive user credential columns from application read queries.
