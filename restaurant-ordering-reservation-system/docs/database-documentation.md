# Database documentation

| Item | Value |
|---|---|
| Database | `grp_binarysisters_projectdb` (owner `postgres`) |
| Schema | `public` |
| PostgreSQL | 18.6 (scripts also work on 14+; `pg_maintain` needs 17+) |
| Extensions | `btree_gist` (no-overlap reservation constraint), `pgcrypto` (seed passwords only) |
| Tables / relationships | 8 tables, 6 foreign-key relationships (the M:N orders–menu_item is resolved by `order_item`) |
| Views | `v_customer_directory`, `v_staff_directory`, `v_order_summary`, `v_reservation_schedule` |
| Functions / triggers | 3 trigger functions, 4 triggers (see §4) |
| Build order | `database/migrations/000..004` → `database/seeds/001` → `database/roles/01..04` |

## 1. Entity-relationship diagram
See `docs/erd.png` (generated from the real design) and the Mermaid version in `docs/erd.md`.

## 2. Relationships

| Parent | Child | Cardinality | Foreign key | On delete |
|---|---|---|---|---|
| customer | orders | 1 : N | `orders.customer_id` | RESTRICT |
| customer | reservation | 1 : N | `reservation.customer_id` | RESTRICT |
| restaurant_table | reservation | 1 : N | `reservation.table_id` | RESTRICT |
| orders | order_item | 1 : N | `order_item.order_id` | CASCADE |
| menu_item | order_item | 1 : N | `order_item.menu_item_id` | RESTRICT |
| orders | payment | 1 : 1 | `payment.order_id` (UNIQUE) | RESTRICT |
| orders ⟷ menu_item | — | M : N resolved by `order_item` (PK = order_id + menu_item_id) | | |

## 3. Data dictionary

**customer** — PK customer_id
| Column | Type | Constraints |
|---|---|---|
| customer_id | SERIAL | PK |
| first_name, last_name | VARCHAR(50) | NOT NULL |
| email | VARCHAR(100) | NOT NULL, UNIQUE, CHECK e-mail pattern |
| phone | VARCHAR(20) | NOT NULL |
| password | VARCHAR(255) | NOT NULL — **bcrypt hash** |
| created_at | TIMESTAMP | NOT NULL DEFAULT now() |

**menu_item** — menu_item_id SERIAL PK · item_name VARCHAR(100) NN · description TEXT NULL · category VARCHAR(50) NN · price NUMERIC(10,2) NN CHECK ≥ 0 · availability BOOLEAN NN DEFAULT true

**restaurant_table** — table_id SERIAL PK · table_number INT NN UNIQUE · capacity INT NN CHECK > 0 · status VARCHAR(20) NN DEFAULT 'available' CHECK IN (available, occupied, reserved, out_of_service)

**staff** — staff_id SERIAL PK · first_name, last_name VARCHAR(50) NN · email VARCHAR(100) NN UNIQUE · role VARCHAR(30) NN CHECK IN (admin, staff) · password VARCHAR(255) NN (bcrypt hash)

**orders** — order_id SERIAL PK · customer_id INT NN FK · order_date TIMESTAMP NN DEFAULT now() · order_status VARCHAR(20) NN DEFAULT 'pending' CHECK IN (pending, confirmed, preparing, ready, completed, cancelled) · total_amount NUMERIC(10,2) NN DEFAULT 0 CHECK ≥ 0 (maintained by trigger)

**order_item** — PK (order_id, menu_item_id) · quantity INT NN CHECK > 0 · unit_price NUMERIC(10,2) NN CHECK ≥ 0 · subtotal NUMERIC(10,2) NN CHECK ≥ 0 and CHECK subtotal = quantity × unit_price

**reservation** — reservation_id SERIAL PK · customer_id FK NN · table_id FK NN · reservation_date DATE NN · reservation_time TIME NN · number_of_guests INT NN CHECK > 0 · reservation_status VARCHAR(20) NN DEFAULT 'confirmed' CHECK IN (pending, confirmed, seated, completed, cancelled, no_show)

**payment** — payment_id SERIAL PK · order_id INT NN UNIQUE FK · payment_date TIMESTAMP NN DEFAULT now() · payment_method VARCHAR(30) NN CHECK IN (cash, card, gcash, bank_transfer) · amount NUMERIC(10,2) NN CHECK ≥ 0 · payment_status VARCHAR(20) NN DEFAULT 'pending' CHECK IN (pending, paid, failed, refunded, cancelled)

## 4. Business rules enforced by the database (beyond keys and checks)
| Rule | Mechanism |
|---|---|
| An order must contain ≥ 1 item (Activity 2 BR9) | deferred constraint triggers `trg_orders_require_items`, `trg_order_item_keep_one` (checked at COMMIT) |
| Order total = sum of its lines | trigger `trg_order_item_total` |
| A table cannot be double-booked (2-hour window) | exclusion constraint `ex_reservation_no_overlap` (`btree_gist`) |
| Guests ≤ table capacity | trigger `trg_reservation_capacity` |
| Price history is preserved | `order_item.unit_price` copies the price when the order is placed |

## 5. Indexes (`004_indexes.sql`)
`idx_orders_customer_date`, `idx_orders_status`, `idx_order_item_menu_item`, `idx_reservation_customer`, `idx_reservation_date`, `idx_menu_item_category` + automatic indexes of PKs, UNIQUE constraints and the exclusion constraint.

## 6. Seed data (`database/seeds/001_seed_data.sql`)
Synthetic data, no real people: **51 customers, 10 staff, 50 menu items, 20 tables, 60 orders (167 order lines), 56 payments, 50 reservations.**
Run it once, on an empty database, after the migrations. The file ends with a count query that must show 51 / 10 / 50 / 20 / 60 / 167 / 56 / 50.

* Order totals equal the sum of their lines, every payment equals its order total, no table is double-booked and no reservation exceeds its table's capacity, so the whole file passes the constraints and triggers of migrations 001 and 002.
* Orders and reservations are dated 2023 (history). New orders and reservations are made through the application.
* The sample data is larger than the "approximately 5–10 rows per table" planned in Activity 2 (Part 11) so that queries, filters and the later monitoring activities work on a realistic amount of data.
* The values follow the CHECK lists above: staff roles are `admin` / `staff` (the application roles); payment methods are `cash`, `card`, `gcash`, `bank_transfer`; tables that are not usable are `out_of_service`.

### Sample accounts (local testing only, not real credentials)
| Application role | Email | Password |
|---|---|---|
| Administrator | `admin@rors.example` | `Admin123!` |
| Staff | `staff@rors.example` | `Staff123!` |
| Customer | `maria.santos@rors.example` | `Password123!` |
| Administrator | `maria.santos@binarysisters-resto.example` | `MariaClaraSantos@123` |
| Staff | `andrea.cruz@binarysisters-resto.example` | `AndreaDelaCruz@123` |
| Customer | `olivia.wagner@example.com` | `OliviaWagner@123` |

Every other sample account (50 customers and 8 staff) uses the password **full name without spaces + `@123`**.
The first three accounts are the ones named in `README.md` and `docs/user-roles.md`.

## 7. Tests (`tests/crud_tests.sql`)
Create, retrieve, update and delete tests plus 14 constraint tests (NOT NULL, UNIQUE, CHECK, FOREIGN KEY, the no-double-booking rule and the capacity rule). Everything runs in one transaction that ends with `ROLLBACK`, so the sample data is unchanged. Every line must show `PASS` and `failed = 0`; each constraint test also checks that the database refused the statement for the expected reason (SQLSTATE).

## 8. Reset / rebuild
`.\database\setup.ps1 -Reset` (local development database only).