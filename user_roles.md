# Application User Roles Documentation

**Restaurant Online Ordering & Table Reservation System**
Group: Binary Sisters | Course: COMP 018 – Database Administration | Database: `grp_binarysisters_projectdb`

---
## 1. Users of the system

The system has three types of users (Customers, Restaurant staff, and Restaurant administrators). Together they cover six roles (Customer, Administrator, Manager, Cashier, Waiter, and Kitchen Staff ).

| User type | Roles included | Description |
|---|---|---|
| **Customers** | Customer | Restaurant guests who register, view the menu, order food and reserve tables |
| **Restaurant staff** | Cashier, Waiter, Kitchen Staff | Employees who handle the daily service: payments, floor and reservations, and food preparation |
| **Restaurant administrators** | Administrator, Manager | Employees who manage and supervise the restaurant and its system data |

Customers are stored in the `customer` table. Restaurant staff and restaurant administrators are stored in the `staff` table; their job title is in `staff.role`.

## 2. Roles and responsibilities

| # | Role | User type | Stored in | Who | Responsibilities |
|---|---|---|---|---|---|
| 1 | **Customer** | Customers | table `customer` (self-registered) | Restaurant guest | Register and log in; view the menu; place food orders; reserve tables; follow own order and reservation status; keep own profile up to date |
| 2 | **Administrator** | Restaurant administrators | `staff.role = 'Administrator'` | Restaurant administrator | Full management of menu items, tables, orders, reservations, payments and staff accounts |
| 3 | **Manager** | Restaurant administrators | `staff.role = 'Manager'` | Manager | Supervises daily operations: orders, reservations, menu and table updates, payments, reports |
| 4 | **Cashier** | Restaurant staff | `staff.role = 'Cashier'` | Counter staff | Records and updates payments; views orders |
| 5 | **Waiter** | Restaurant staff | `staff.role = 'Waiter'` | Staff | Handles reservations and table status; follows orders until they are served |
| 6 | **Kitchen Staff** | Restaurant staff | `staff.role = 'Kitchen Staff'` | Kitchen | Views active orders and updates their preparation status; marks menu items available or unavailable |

## 3. Features each role can access

Legend: **Y** = allowed, **Own** = only the person's own records, **View** = read only, **–** = not allowed.
The features follow the 12 features of the Activity 2 blueprint.

| Feature | Customer | Administrator | Manager | Cashier | Waiter | Kitchen Staff |
|---|---|---|---|---|---|---|
| Register / log in | Register + log in | Log in | Log in | Log in | Log in | Log in |
| View menu, search, item details | Y | Y | Y | Y | Y | Y |
| Place an order online | Y | – | – | – | – | – |
| View order status | Own | All | All | View | View | Active orders |
| Update order status | Cancel own pending order | Y | Y | – | Y (served / completed) | Y (to preparing) |
| Check table availability | Y | Y | Y | View | Y | – |
| Make a reservation | Y | Y | Y | – | Y | – |
| View reservation status | Own | All | All | View | All | – |
| Update / cancel a reservation | Cancel own | Y | Y | – | Y | – |
| Manage menu items | View | Add, edit, delete | Add, edit | View | View | Availability only |
| Manage restaurant tables | View availability | Add, edit, delete | Edit | View | Update status | – |
| Record and manage payments | View own | Y | Y | Y | – | – |
| View customer records | Own profile (edit) | View (no password) | View (no password) | – | – | – |
| Manage staff accounts | – | Y | – | – | – | – |
| Sales and summary reports | – | Y | Y | – | – | – |

## 4. Data each role can access

C = create (INSERT), R = read (SELECT), U = update, D = delete.

| Table | Customer | Administrator | Manager | Cashier | Waiter | Kitchen Staff |
|---|---|---|---|---|---|---|
| `customer` | C, R/U own | R | R | – | – | – |
| `staff` | – | C R U D | R (own login) | R (own login) | R (own login) | R (own login) |
| `menu_item` | R | C R U D | C R U | R | R | R, U (availability) |
| `restaurant_table` | R | C R U D | R U | R | R, U (status) | – |
| `orders` | C, R/U own | R U | R U | R | R U | R U |
| `order_item` | C, R own | R | R | R | R | R |
| `payment` | R own | C R U | C R U | C R U | – | – |
| `reservation` | C, R/U own | C R U | C R U | R | C R U | – |

Notes:

* No role deletes `orders`, `order_item`, `payment`, `customer` or `reservation` records. Business history is kept; cancelling or voiding is a status change (an `UPDATE`).
* `customer.password` and `staff.password` hold password hashes. Only the login code reads them; no screen or report displays them.
* "Own" means the application must filter by the logged-in customer (for example `WHERE customer_id = :session_customer`).
