# Activity 3 Testing Log - Group 11

## 1. Project Details
- **Project Tested:** BoardTrack — Boarding House & Rental Management System
- **Testing Group:** Group 10
- **Repository Link:** https://github.com/karlrobertc-art/BoardTrack.git
- **Branch Tested:** main

---

## 2. System Requirements & Prerequisites
- **Language/Environment:** Node.js ≥ 20.12, Express, EJS, pg
- **Database:** PostgreSQL (v13+)
- **Build Tool:** npm

---

## 3. Issues Found
1. **Missing Node.js / npm Environment Blocker:**
   - Running `npm install` throws `npm : The term 'npm' is not recognized as the name of a cmdlet...`.
   - Node.js runtime (v20.12+) is not installed or not mapped to the system PATH environment variables.

---

## 4. Setup & Execution Results

| Step / Test Case | Result | Remarks / Notes |
| :--- | :--- | :--- |
| **Repository Clone** | Success | Successfully cloned from GitHub. |
| **Dependencies (`npm install`)** | Failed | Failed to execute due to missing `npm` binary in system PATH. |
| **Database & Schema Setup** | Blocked | Automatic migrations/auto-setup could not run without Node.js execution. |
| **Application Run (`npm start`)** | Blocked | Web server (`http://localhost:3000`) could not be launched. |

---

## 5. Overall Result & Feedback
- **Result:** Some Issues
- **Feedback for Original Developers:**
  1. Add a quick prerequisite check script or explicit warning in `start.bat` to alert users if Node.js/npm is not detected in their system PATH before attempting to run setup commands.
