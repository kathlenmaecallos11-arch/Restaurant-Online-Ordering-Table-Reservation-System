# Activity 3 Testing Log - Group 2

## Project Details
- **Project Tested:** Group 2 - PARK-IT-DATABASE-MANAGEMENT-SYSTEM
- **Testing Group:** Group 10
- **Repository Link:** https://github.com/HelloP0/PARK-IT-DATABASE-MANAGEMENT-SYSTEM.git
- **Branch Tested:** main

---

## 1. System Requirements & Prerequisites
- **Language/Environment:** PHP (XAMPP / Apache), HTML, CSS, JavaScript, AJAX
- **Database:** PostgreSQL (pgAdmin 4)
- **Required Database Name:** `grp_parkitdb`

---

## 2. Issues Found

1. **None**

---

## 3. Setup & Execution Results

| Step / Test Case | Result | Remarks / Notes |
| :--- | :--- | :--- |
| **Repository Clone** | **Success** | Successfully cloned from GitHub (`https://github.com/HelloP0/PARK-IT-DATABASE-MANAGEMENT-SYSTEM.git`) |
| **Database Creation** | **Success** | Successfully created `grp_parkitdb` in PostgreSQL via pgAdmin 4 |
| **Database Restoration / Seeding** | **Success** | Database schema and initial seed data configured successfully. |
| **Setup Result** | **Success** | System setup completed without major errors. |
| **Application Roles Checked** | **Success** | Tested both Admin and Staff accounts. Verified that Staff cannot access registration, the system successfully showed "Access Denied". Admin has full access to all features|

---

## 4. Overall Result & Feedback

- **Result:** **Success**
- **Feedback Sent Date:** 11-06-2026
- **Last Updated:** 11-06-2026
- **Feedback for Original Developers:**
  1. System setup and installation went smoothly with successful database creation and configuration.
  2. Role-based access controls (RBAC) are properly enforced on the backend, ensuring proper security between Admin and Staff accounts.
