# Application User Roles Documentation

**Restaurant Online Ordering & Table Reservation System (RORS)**
Group: Binary Sisters | Course: COMP 018 – Database Administration | Database: `grp_binarysisters_projectdb`

The roles **inside the application** (what a person can do after logging in) are separate from the roles **inside PostgreSQL** (what a database account can do). End users do **not** have PostgreSQL logins. The web application connects with one runtime account and enforces the application roles in PHP code (`require_customer()` and `require_staff([...])`).

> This document follows the implemented code (`app/src/helpers.php`, `controllers/admin.php`), the schema (`staff.role IN ('admin','staff')`) and the SQL in `database/roles/`.

---

## 1. Users of the system

| User type | Application role | Stored in | Description |
|---|---|---|---|
| Customers | **Customer** | table `customer` (self-registered) | Restaurant guests who register, view the menu, order food and reserve tables |
| Restaurant staff | **Staff** | table `staff`, `role = 'staff'` | Employees who run daily service: orders, reservations, payments, table status, menu availability |
| Restaurant administrators | **Administrator** | table `staff`, `role = 'admin'` | Staff who also manage the catalogue (menu, tables) and accounts |

Identity of every user is a row in `customer` or `staff` plus a PHP session. Staff accounts are created only by an Administrator.

Note on job titles: in the application, **Staff** covers the waiter / counter staff and **Administrator** covers the restaurant manager. The Activity 2 job titles (Waiter, Cashier, Kitchen Staff, Manager) are not separate roles in the code or the database, because `staff.role` accepts only `admin` and `staff`.

## 2. Roles and responsibilities

| # | Role | Responsibilities |
|---|---|---|
| 1 | **Customer** | Register and log in; view the menu; place food orders; reserve tables; follow own order and reservation status; cancel own pending order or reservation; edit own profile |
| 2 | **Staff** | View all orders, reservations and payments; update order status; update reservation status; record and update payments; change table status; mark menu items available or unavailable |
| 3 | **Administrator** | Everything Staff can do, plus: create, edit and delete menu items and tables; delete reservations; list customers (no password hashes); create, edit and delete staff accounts |

## 3. Features each role can access

Legend: **Y** = allowed, **Own** = only the person's own records, **–** = not allowed.

| Feature | Customer | Staff | Administrator |
|---|---|---|---|
| Register | Y | – | – |
| Log in | Y (`/login`) | Y (`/staff/login`) | Y (`/staff/login`) |
| View menu, search, item details | Y | Y | Y |
| Place an order online | Y | – | – |
| View order status | Own | All | All |
| Update order status | Cancel own pending order | Y (any valid status) | Y |
| Make a reservation | Y | – | – |
| View reservation status | Own | All | All |
| Update reservation status | Cancel own | Y | Y |
| Delete a reservation | – | – | Y |
| Create / edit menu items | – | – | Y |
| Mark menu item available / unavailable | – | Y | Y |
| Delete menu items | – | – | Y |
| Create / edit / delete restaurant tables | – | – | Y |
| Change table status | – | Y | Y |
| Record and update payments | Pending payment created automatically at checkout | Y | Y |
| View customer list | Own profile (edit) | – | Y (no password) |
| Manage staff accounts | – | – | Y |
| Dashboard summary | – | Y | Y |

## 4. Data each role can access

C = create, R = read, U = update, D = delete. All operations pass through the single runtime account (see section 5); the role restrictions below are enforced by the application.

| Table | Customer | Staff | Administrator |
|---|---|---|---|
| `customer` | C (register), R/U own | – | R (list, no password) |
| `staff` | – | R (own login) | C R U D |
| `menu_item` | R | R, U (availability) | C R U D |
| `restaurant_table` | R (availability) | R, U (status) | C R U D |
| `orders` | C, R own, U own (cancel) | R U | R U |
| `order_item` | C, R own | R | R |
| `payment` | C (pending, at checkout), R own | C R U | C R U |
| `reservation` | C, R own, U own (cancel) | R U (status) | R U D |

Notes:

* No role deletes `orders`, `order_item`, `payment` or `customer` records. Cancelling or voiding is a status change (an `UPDATE`). Only an Administrator deletes `reservation`, `menu_item`, `restaurant_table` and `staff` rows.
* `customer.password` and `staff.password` hold password hashes. Only the login code reads them; no screen displays them.
* "Own" means the application filters by the logged-in customer (for example `WHERE customer_id = ?` with the session customer id).
