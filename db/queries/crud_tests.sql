-- =====================================================================
-- Restaurant Online Ordering & Table Reservation System
-- Group: Binary Sisters
-- Basic database operation tests (SELECT, INSERT, UPDATE, DELETE)
-- Database: grp_binarysisters_projectdb   (run AFTER schema.sql and seed.sql)
--
-- HOW TO RUN (pgAdmin Query Tool)
--   * Run one test at a time: highlight the lines of the test, then press F5.
--   * SELECT tests (Part 1) change nothing.
--   * Tests that change data (Parts 2 to 4) have two steps:
--       Step A: highlight from BEGIN to the last SELECT, press F5, take a screenshot.
--       Step B: highlight ROLLBACK, press F5. This undoes the change, so the
--               database stays exactly as it was.
--   * Part 5 uses a DO block and does not need ROLLBACK.
--   * Part 6 confirms the data is unchanged.
--
-- The expected results below are for the sample data in db/seed.sql.
-- =====================================================================


-- =====================================================================
-- PART 1: SELECT (read only)
-- =====================================================================

-- 1.1 Menu items per category and how many are available
--     (expected: 4 rows: Appetizer 10/9, Beverage 10/10, Dessert 8/7, Main Course 22/22)
SELECT category,
       COUNT(*) AS items,
       COUNT(*) FILTER (WHERE availability) AS available
FROM menu_item
GROUP BY category
ORDER BY category;

-- 1.2 Order details of orders 1 to 3 with customer and menu item names (expected: 11 rows)
SELECT o.order_id,
       c.first_name || ' ' || c.last_name AS customer,
       m.item_name,
       oi.quantity,
       oi.unit_price,
       oi.subtotal,
       o.order_status
FROM orders o
JOIN customer   c  ON c.customer_id  = o.customer_id
JOIN order_item oi ON oi.order_id    = o.order_id
JOIN menu_item  m  ON m.menu_item_id = oi.menu_item_id
WHERE o.order_id IN (1, 2, 3)
ORDER BY o.order_id, m.item_name;

-- 1.3 Integrity check: each order total must equal the sum of its items (expected: 0 rows)
SELECT o.order_id, o.total_amount, SUM(oi.subtotal) AS items_total
FROM orders o
JOIN order_item oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount <> SUM(oi.subtotal);

-- 1.4 Pending reservations with customer and table (expected: 7 rows)
SELECT r.reservation_id,
       c.first_name || ' ' || c.last_name AS customer,
       t.table_number,
       r.reservation_date,
       r.reservation_time,
       r.number_of_guests,
       r.reservation_status
FROM reservation r
JOIN customer         c ON c.customer_id = r.customer_id
JOIN restaurant_table t ON t.table_id    = r.table_id
WHERE r.reservation_status = 'pending'
ORDER BY r.reservation_date, r.reservation_time;

-- 1.5 Table availability on the date of reservation 1 (expected: 15 rows)
--     Table 15 is reserved on that date. Tables 3, 8, 14 and 17 are not 'available',
--     so they are left out too.
SELECT t.table_number, t.capacity
FROM restaurant_table t
WHERE t.status = 'available'
  AND NOT EXISTS (
        SELECT 1
        FROM reservation r
        WHERE r.table_id = t.table_id
          AND r.reservation_date = (SELECT reservation_date FROM reservation WHERE reservation_id = 1)
          AND r.reservation_status <> 'cancelled'
      )
ORDER BY t.table_number;


-- =====================================================================
-- PART 2: INSERT (a new customer places an order for 2 Iced Tea (Glass))
-- =====================================================================

-- Step A: highlight from BEGIN to the last SELECT, then press F5.
BEGIN;

INSERT INTO customer (first_name, last_name, email, phone, password)
VALUES ('Test', 'Customer', 'test.insert@example.com', '09170000000', 'test-only-not-a-real-hash');

INSERT INTO orders (customer_id)
SELECT customer_id FROM customer WHERE email = 'test.insert@example.com';

INSERT INTO order_item (order_id, menu_item_id, quantity, unit_price, subtotal)
SELECT o.order_id, m.menu_item_id, 2, m.price, 2 * m.price
FROM orders o
JOIN customer c ON c.customer_id = o.customer_id
CROSS JOIN menu_item m
WHERE c.email = 'test.insert@example.com'
  AND m.item_name = 'Iced Tea (Glass)';

-- Expected: 1 row, order_status = pending (default), quantity 2, subtotal 120.00
SELECT c.email, o.order_id, o.order_status, m.item_name, oi.quantity, oi.subtotal
FROM customer c
JOIN orders     o  ON o.customer_id  = c.customer_id
JOIN order_item oi ON oi.order_id    = o.order_id
JOIN menu_item  m  ON m.menu_item_id = oi.menu_item_id
WHERE c.email = 'test.insert@example.com';

-- Step B: highlight the next line and press F5.
ROLLBACK;


-- =====================================================================
-- PART 3: UPDATE (complete a pending order and raise a menu price)
-- =====================================================================

-- Step A
BEGIN;

UPDATE orders    SET order_status = 'completed' WHERE order_id = 13;
UPDATE menu_item SET price = 160.00             WHERE item_name = 'Halo-Halo';

-- Expected: order 13 = completed, Halo-Halo = 160.00
-- (before the update: pending and 150.00)
SELECT 'orders' AS tbl, order_id::text AS record, order_status AS value
FROM orders WHERE order_id = 13
UNION ALL
SELECT 'menu_item', item_name, price::text
FROM menu_item WHERE item_name = 'Halo-Halo';

-- Step B
ROLLBACK;


-- =====================================================================
-- PART 4: DELETE (ON DELETE CASCADE removes the items of a deleted order)
-- Order 26 is a cancelled order with 2 items and no payment.
-- =====================================================================

-- Step A
BEGIN;

DELETE FROM orders WHERE order_id = 26;

-- Expected: orders_left = 0 and items_left = 0 (order_item rows were deleted by CASCADE)
-- (before the delete: orders_left = 1 and items_left = 2)
SELECT (SELECT COUNT(*) FROM orders     WHERE order_id = 26) AS orders_left,
       (SELECT COUNT(*) FROM order_item WHERE order_id = 26) AS items_left;

-- Step B
ROLLBACK;


-- =====================================================================
-- PART 5: CONSTRAINT TESTS (invalid data must be rejected)
-- Run the whole DO block. Expected: seven PASS lines in the Messages tab.
-- If any invalid row were accepted, the block raises an error and everything
-- done inside it is undone.
-- =====================================================================

DO $$
BEGIN
    -- CHECK: price cannot be negative
    BEGIN
        INSERT INTO menu_item (item_name, category, price) VALUES ('Bad Price', 'Test', -1);
        RAISE EXCEPTION 'FAIL: negative price was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'PASS: negative price rejected (CHECK)';
    END;

    -- CHECK: table capacity must be greater than zero
    BEGIN
        INSERT INTO restaurant_table (table_number, capacity) VALUES (99, 0);
        RAISE EXCEPTION 'FAIL: capacity 0 was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'PASS: capacity 0 rejected (CHECK)';
    END;

    -- CHECK: quantity must be greater than zero
    BEGIN
        INSERT INTO order_item (order_id, menu_item_id, quantity, unit_price, subtotal)
        VALUES (3, 2, 0, 220.00, 0);
        RAISE EXCEPTION 'FAIL: quantity 0 was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'PASS: quantity 0 rejected (CHECK)';
    END;

    -- NOT NULL: first name is required
    BEGIN
        INSERT INTO customer (first_name, last_name, email, phone, password)
        VALUES (NULL, 'NoName', 'no.name@example.com', '09170000001', 'x');
        RAISE EXCEPTION 'FAIL: NULL first name was accepted';
    EXCEPTION WHEN not_null_violation THEN
        RAISE NOTICE 'PASS: NULL first name rejected (NOT NULL)';
    END;

    -- UNIQUE: an email can be registered only once
    BEGIN
        INSERT INTO customer (first_name, last_name, email, phone, password)
        VALUES ('Dup', 'Email', 'olivia.wagner@example.com', '09170000002', 'x');
        RAISE EXCEPTION 'FAIL: duplicate email was accepted';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'PASS: duplicate email rejected (UNIQUE)';
    END;

    -- FOREIGN KEY: an order needs an existing customer
    BEGIN
        INSERT INTO orders (customer_id) VALUES (9999);
        RAISE EXCEPTION 'FAIL: order for a missing customer was accepted';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'PASS: order for a missing customer rejected (FOREIGN KEY)';
    END;

    -- FOREIGN KEY: an order that has a payment cannot be deleted
    BEGIN
        DELETE FROM orders WHERE order_id = 1;
        RAISE EXCEPTION 'FAIL: order with a payment was deleted';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'PASS: order with a payment cannot be deleted (FOREIGN KEY)';
    END;
END $$;


-- =====================================================================
-- PART 6: CONFIRM THE DATA IS UNCHANGED
-- Expected counts: customer 50, staff 8, menu_item 50, restaurant_table 20,
--                  orders 60, order_item 167, payment 56, reservation 50
-- =====================================================================

SELECT 'customer' AS tbl, COUNT(*) FROM customer
UNION ALL SELECT 'staff',            COUNT(*) FROM staff
UNION ALL SELECT 'menu_item',        COUNT(*) FROM menu_item
UNION ALL SELECT 'restaurant_table', COUNT(*) FROM restaurant_table
UNION ALL SELECT 'orders',           COUNT(*) FROM orders
UNION ALL SELECT 'order_item',       COUNT(*) FROM order_item
UNION ALL SELECT 'payment',          COUNT(*) FROM payment
UNION ALL SELECT 'reservation',      COUNT(*) FROM reservation;