# Activity 3 Testing Log

## Project Details

- **Project Tested:** HabalGo
- **Testing Group:** G10
- **Repository Link:** [https://github.com/jeanaroyo/HabalGo.git](https://github.com/jeanaroyo/HabalGo.git)
- **Branch Tested:** main

---

## 1. System Requirements & Prerequisites

- **Programming Language:** PHP
- **Database:** PostgreSQL 18.6
- **PHP Version:** 8.0.30
- **Database Name:** `grp00_habalgodb`
- **Database Schema:** `habalgo`
- **Required Environment:** XAMPP / PHP Built-in Development Server
- **Required PHP Extensions:** `pdo_pgsql`, `pgsql`

---

## 2. Issues Found

1. **Database Connection Failed**
   - The local `.env` file uses `DB_PASSWORD`, while `config.php` expects `DB_PASS`. Additionally, the application does not automatically load the `.env` file. This initially caused a database connection failure.
   - **Resolution:** Modified the local `config.php` to load the `.env` file using `parse_ini_file()` and corrected the variable name from `DB_PASSWORD` to `DB_PASS`. The database connection worked successfully afterward.

---

## 3. Setup & Execution Results

| Step / Test Case | Result | Remarks / Notes |
|---|---|---|
| Repository Clone | Success | Successfully cloned the HabalGo repository from GitHub. |
| Database Creation | Success | Created `grp00_habalgodb` in PostgreSQL. |
| Database Schema Restoration | Success | Successfully executed `schema.sql`. |
| Sample Data Insertion | Success | Successfully executed `sample data.sql`. |
| PHP Environment Setup | Success | Configured PHP 8.0.30 and the required PostgreSQL extensions. |
| Database Connection | Success | Successfully connected the PHP application to PostgreSQL after correcting the configuration. |
| Application Run | Success | Application opened using the PHP built-in development server. |
| Customers Module | Success | Tested viewing, adding, editing, and deleting customer records. |
| Vehicles Module | Success | Tested viewing, adding, editing, and deleting vehicle records. |
| Bookings Module | Success | Tested viewing, adding, editing, and deleting booking records. |
| Payments Module | Success | Tested viewing, adding, editing, and deleting payment records. |
| Ratings & Feedbacks Module | Success | Tested viewing, adding, editing, and deleting ratings and feedback records. |
| Primary Key Verification | Success | Verified primary keys across all eight database tables. The `driver_vehicle` table uses a composite primary key consisting of `driver_id` and `vehicle_id`, resulting in nine primary key columns. |
| Foreign Key Verification | Success | Identified nine foreign key relationships across the database tables. |
| Database Record Verification | Success | Successfully retrieved record counts from all eight database tables. |

---

## 4. Database Verification Results

- **Total Tables:** 8
- **Primary Key Columns:** 9
- **Foreign Key Relationships:** 9
- **Total Records:** 19 (at the time of verification)



---

## 5. Overall Result & Feedback

- **Result:** Successful with additional testing recommended.

### Feedback for Original Developers

1. Ensure consistent database environment variable names between `.env.example` and `config.php` to prevent database connection issues.
2. Consider implementing automatic `.env` file loading or providing clear setup instructions for configuring database credentials.
3. Provide clearer documentation for database configuration and application setup to make local installation easier for future testers.

The HabalGo application was successfully set up and executed in the local environment. The main pages loaded successfully after resolving the database configuration issue. 
