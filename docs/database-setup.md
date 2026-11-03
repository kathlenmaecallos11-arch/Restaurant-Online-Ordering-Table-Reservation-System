# Restaurant Online Ordering & Table Reservation System

Group: **Binary Sisters** | Course: COMP 018 Database Administration

A web application where customers can view the menu, place food orders, and reserve tables, and where staff and administrators manage orders, reservations, tables, menu items, and payments.

**Stack:** HTML, CSS, JavaScript, PHP (PDO), PostgreSQL 18

> This README currently documents the **database setup**. Instructions for running the PHP application pages are added by the group in the section "Running the application".

## 1. Prerequisites

| Software | Notes |
|---|---|
| PostgreSQL 18 (tested on 18.6) | Includes `psql` and pgAdmin 4. The `pgcrypto` extension that ships with PostgreSQL is used by the sample data. |
| XAMPP (Apache and PHP 8.x) | Used only as the local web server and PHP. Do not use its MySQL. |
| PHP extensions `pdo_pgsql` and `pgsql` | Must be enabled (see Troubleshooting). |
| Git | To clone the repository. |

## 2. Project structure (database files)

```
config/db.php             PostgreSQL connection (PDO), reads settings from .env
db/schema.sql             Creates the 8 tables, keys and constraints
db/seed.sql               Sample data for testing
db/queries/crud_tests.sql SELECT, INSERT, UPDATE, DELETE and constraint tests
.env.example              Template of the environment variables (placeholders only)
test_connection.php       Confirms that PHP can connect to the database
```

## 3. Database setup

Do these steps on a computer that has PostgreSQL installed. The database must be **new and empty**.

1. **Clone the repository** into the XAMPP `htdocs` folder (for example `C:\xampp\htdocs\`).

2. **Create your `.env` file.** Copy `.env.example` to a new file named `.env`, then put your own PostgreSQL password in `DB_PASS`:

   ```
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=grp_binarysisters_projectdb
   DB_USER=postgres
   DB_PASS=your_password_here
   ```

   Never commit `.env`. It is listed in `.gitignore`.

3. **Create the database.** Open **SQL Shell (psql)** from the Start menu, log in as `postgres`, and run:

   ```sql
   CREATE DATABASE grp_binarysisters_projectdb;
   ```

   (In pgAdmin 4: right-click **Databases** > **Create** > **Database**, and use the same name.)

4. **Create the tables.** From the project folder, run:

   ```
   psql -U postgres -d grp_binarysisters_projectdb -f db/schema.sql
   ```

   (In pgAdmin 4: open a Query Tool on the new database, open `db/schema.sql`, and press F5.)

5. **Load the sample data:**

   ```
   psql -U postgres -d grp_binarysisters_projectdb -f db/seed.sql
   ```

   The script ends with `COMMIT`. Run it **only once** on an empty database.

6. **Check the result.** Run this query. The expected counts are 50, 8, 50, 20, 60, 167, 56, 50.

   ```sql
   SELECT 'customer' AS tbl, COUNT(*) FROM customer
   UNION ALL SELECT 'staff', COUNT(*) FROM staff
   UNION ALL SELECT 'menu_item', COUNT(*) FROM menu_item
   UNION ALL SELECT 'restaurant_table', COUNT(*) FROM restaurant_table
   UNION ALL SELECT 'orders', COUNT(*) FROM orders
   UNION ALL SELECT 'order_item', COUNT(*) FROM order_item
   UNION ALL SELECT 'payment', COUNT(*) FROM payment
   UNION ALL SELECT 'reservation', COUNT(*) FROM reservation;
   ```

7. **Check the PHP connection.** Start Apache in the XAMPP Control Panel and open:

   ```
   http://localhost/<project-folder-name>/test_connection.php
   ```

   It should show `Connected to: grp_binarysisters_projectdb` and the PostgreSQL version.

8. **(Optional) Run the database tests.** Open `db/queries/crud_tests.sql` in the Query Tool and follow the instructions at the top of the file. The tests do not change the data: changes are undone with `ROLLBACK`.

### Starting over

To rebuild the database from scratch, connect to the `postgres` database (not the project database) and run the two statements one at a time, then repeat steps 4 to 6:

```sql
DROP DATABASE grp_binarysisters_projectdb WITH (FORCE);
CREATE DATABASE grp_binarysisters_projectdb;
```

## 4. Database overview

| Table | Purpose |
|---|---|
| `customer` | Customer accounts and contact details |
| `staff` | Staff and administrator accounts (`role` holds the job title: Administrator, Manager, Cashier, Waiter, or Kitchen Staff) |
| `menu_item` | Food and drinks that can be ordered |
| `restaurant_table` | Tables with their number, capacity, and status |
| `orders` | One row per customer order, with status and total |
| `order_item` | Items inside an order (resolves the many-to-many relationship between orders and menu items) |
| `payment` | One payment per order |
| `reservation` | Table reservations by customers |

Relationships: a customer has many orders and reservations; an order has many order items and one payment; a restaurant table has many reservations; a menu item can appear in many order items. The design follows the Activity 2 ERD and relational schema.

### Database objects and access needs

This list helps anyone who sets up the database and plans its access control.

| Object type | Names |
|---|---|
| Database | `grp_binarysisters_projectdb` |
| Schema | `public` (no custom schema) |
| Tables (8) | `customer`, `staff`, `menu_item`, `restaurant_table`, `orders`, `order_item`, `payment`, `reservation` |
| Sequences (7) | `customer_customer_id_seq`, `staff_staff_id_seq`, `menu_item_menu_item_id_seq`, `restaurant_table_table_id_seq`, `orders_order_id_seq`, `payment_payment_id_seq`, `reservation_reservation_id_seq` (`order_item` has none because its key is the pair `order_id` and `menu_item_id`) |
| Views, functions, triggers | none |
| Extensions | `pgcrypto`, needed only to run `db/seed.sql` (it creates the sample password hashes), not by the application |

An account that inserts rows needs `INSERT` on the table **and** `USAGE` on that table's sequence, because the ID is generated automatically. The application never creates or alters tables. The application roles of the system and their intended database roles are documented in the group's user roles document.

## 5. Sample data and accounts

`db/seed.sql` loads synthetic data (no real people): 50 customers, 8 staff, 50 menu items, 20 tables, 60 orders with 167 order items, 56 payments, and 50 reservations. The dates of the orders and reservations are in 2023.

The password of every account is its **full name without spaces, followed by `@123`** (for example, Olivia Wagner has the password `OliviaWagner@123`). The accounts below are sample data only, not real credentials.

| Application role | Email | Password |
|---|---|---|
| Administrator | `maria.santos@binarysisters-resto.example` | `MariaClaraSantos@123` |
| Administrator | `jose.reyes@binarysisters-resto.example` | `JoseReyes@123` |
| Staff (Manager) | `andrea.cruz@binarysisters-resto.example` | `AndreaDelaCruz@123` |
| Staff (Cashier) | `liza.mendoza@binarysisters-resto.example` | `LizaMendoza@123` |
| Staff (Waiter) | `katrina.villanueva@binarysisters-resto.example` | `KatrinaVillanueva@123` |
| Customer | `olivia.wagner@example.com` | `OliviaWagner@123` |
| Customer | `diego.lopez@example.org` | `DiegoLopez@123` |
| Customer | `noah.smith@example.com` | `NoahSmith@123` |

## 6. Troubleshooting

| Problem | Likely cause and fix |
|---|---|
| `could not find driver` | The PostgreSQL extension of PHP is off. In `C:\xampp\php\php.ini`, remove the `;` before `extension=pdo_pgsql` and `extension=pgsql`, then stop and start Apache. Check with `C:\xampp\php\php.exe -m`. |
| `password authentication failed for user "postgres"` | The `DB_PASS` in `.env` is wrong. Use the password you set when installing PostgreSQL. |
| `database "grp_binarysisters_projectdb" does not exist` | Step 3 was not done, or `DB_NAME` in `.env` has a different name. |
| `relation "customer" already exists` | `schema.sql` was run on a database that already has tables. Use the "Starting over" steps. |
| `duplicate key value violates unique constraint` while loading `seed.sql` | The sample data was already loaded. Use the "Starting over" steps. |
| `permission denied to create extension "pgcrypto"` | Run `seed.sql` as the `postgres` user (a superuser). |
| `extension "pgcrypto" is not available` | The PostgreSQL contrib files are missing. Reinstall PostgreSQL with the standard installer. |
| `'psql' is not recognized` | Use **SQL Shell (psql)** from the Start menu, or call it with its full path, for example `"C:\Program Files\PostgreSQL\18\bin\psql.exe"`. |
| Blank page or no output in `test_connection.php` | Apache is not running, or the project is not inside `htdocs`. |

## 7. Running the application

*To be completed by the group: login, registration, and the main pages.*