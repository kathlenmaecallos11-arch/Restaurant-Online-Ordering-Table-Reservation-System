-- 001_seed_data.sql
-- Sample data so the system can be tested immediately (about 5-10 rows per table, as planned in
-- Activity 2 Part 11). Run AFTER the migrations, while connected to grp_binarysisters_projectdb.
--
-- SAMPLE LOGINS (local testing only, they are NOT real credentials):
--   admin   admin@rors.example      /  Admin123!
--   staff   staff@rors.example      /  Staff123!
--   customer maria.santos@rors.example (and the 4 other customers)  /  Password123!
-- Passwords are hashed with bcrypt through pgcrypto (crypt + gen_salt('bf')). PHP's
-- password_verify() accepts these hashes.
--
-- Orders, items and payments are inserted in ONE transaction because an order must contain at
-- least one item (deferred constraint trigger, migration 002).

BEGIN;

-- ------------------------------------------------------------------ staff (2)
INSERT INTO staff (staff_id, first_name, last_name, email, role, password) VALUES
 (1, 'Alicia', 'Mendoza', 'admin@rors.example', 'admin', crypt('Admin123!', gen_salt('bf', 10))),
 (2, 'Ramon',  'Villanueva', 'staff@rors.example', 'staff', crypt('Staff123!', gen_salt('bf', 10)));

-- ------------------------------------------------------------------ customers (5)
INSERT INTO customer (customer_id, first_name, last_name, email, phone, password, created_at) VALUES
 (1, 'Maria', 'Santos',     'maria.santos@rors.example',  '09170000001', crypt('Password123!', gen_salt('bf', 10)), now() - interval '30 days'),
 (2, 'Juan',  'Dela Cruz',  'juan.delacruz@rors.example', '09170000002', crypt('Password123!', gen_salt('bf', 10)), now() - interval '25 days'),
 (3, 'Ana',   'Reyes',      'ana.reyes@rors.example',     '09170000003', crypt('Password123!', gen_salt('bf', 10)), now() - interval '20 days'),
 (4, 'Pedro', 'Garcia',     'pedro.garcia@rors.example',  '09170000004', crypt('Password123!', gen_salt('bf', 10)), now() - interval '12 days'),
 (5, 'Liza',  'Ramos',      'liza.ramos@rors.example',    '09170000005', crypt('Password123!', gen_salt('bf', 10)), now() - interval '5 days');

-- ------------------------------------------------------------------ menu items (10; one unavailable)
INSERT INTO menu_item (menu_item_id, item_name, description, category, price, availability) VALUES
 (1,  'Lumpiang Shanghai', 'Crispy pork spring rolls with sweet chili dip (8 pcs).', 'Appetizer',   180.00, true),
 (2,  'Calamares',         'Fried squid rings with spiced vinegar.',                 'Appetizer',   220.00, true),
 (3,  'Chicken Adobo',     'Chicken braised in soy sauce, vinegar and garlic.',      'Main Course', 280.00, true),
 (4,  'Sinigang na Baboy', 'Pork in tamarind broth with vegetables.',                'Main Course', 320.00, true),
 (5,  'Kare-Kare',         'Oxtail and vegetables in peanut sauce with bagoong.',    'Main Course', 420.00, true),
 (6,  'Pancit Canton',     'Stir-fried noodles with vegetables and pork.',           'Main Course', 250.00, true),
 (7,  'Halo-Halo',         'Shaved ice dessert with sweet beans, fruits and leche flan.', 'Dessert', 150.00, true),
 (8,  'Leche Flan',        'Creamy caramel custard.',                                'Dessert',     120.00, false),
 (9,  'Iced Tea',          'House-blend iced tea (glass).',                          'Beverage',     80.00, true),
 (10, 'Buko Juice',        'Fresh young coconut juice.',                             'Beverage',    100.00, true);

-- ------------------------------------------------------------------ restaurant tables (8)
INSERT INTO restaurant_table (table_id, table_number, capacity, status) VALUES
 (1, 1, 2,  'available'),
 (2, 2, 2,  'available'),
 (3, 3, 4,  'available'),
 (4, 4, 4,  'available'),
 (5, 5, 4,  'available'),
 (6, 6, 6,  'available'),
 (7, 7, 8,  'available'),
 (8, 8, 10, 'out_of_service');

-- ------------------------------------------------------------------ orders (6) and their items
-- total_amount starts at 0 and is recalculated by trigger trg_order_item_total.
INSERT INTO orders (order_id, customer_id, order_date, order_status) VALUES
 (1, 1, now() - interval '10 days', 'completed'),
 (2, 2, now() - interval '8 days',  'completed'),
 (3, 3, now() - interval '3 days',  'completed'),
 (4, 4, now() - interval '1 day',   'preparing'),
 (5, 5, now() - interval '3 hours', 'pending'),
 (6, 1, now() - interval '2 days',  'cancelled');

INSERT INTO order_item (order_id, menu_item_id, quantity, unit_price, subtotal)
SELECT v.order_id, v.menu_item_id, v.qty, m.price, v.qty * m.price
FROM (VALUES
        (1, 1, 2), (1, 3, 2), (1, 9, 2),
        (2, 4, 1), (2, 6, 1), (2, 10, 2),
        (3, 5, 1), (3, 7, 2),
        (4, 3, 3), (4, 2, 1), (4, 9, 3),
        (5, 6, 2), (5, 10, 2),
        (6, 4, 2)
     ) AS v(order_id, menu_item_id, qty)
JOIN menu_item m ON m.menu_item_id = v.menu_item_id;

-- ------------------------------------------------------------------ payments (5; order 5 has none yet)
INSERT INTO payment (order_id, payment_date, payment_method, amount, payment_status)
SELECT v.order_id, now() - v.age, v.method, o.total_amount, v.status
FROM (VALUES
        (1, interval '10 days', 'cash',  'paid'),
        (2, interval '8 days',  'gcash', 'paid'),
        (3, interval '3 days',  'card',  'paid'),
        (4, interval '1 day',   'gcash', 'pending'),
        (6, interval '2 days',  'cash',  'cancelled')
     ) AS v(order_id, age, method, status)
JOIN orders o ON o.order_id = v.order_id;

-- ------------------------------------------------------------------ reservations (7)
-- Dates are relative to the day the seed runs so the sample data stays "upcoming".
-- Table 3 is booked 18:00 and 20:00 on the same day: the 2-hour windows touch but do not overlap.
INSERT INTO reservation (reservation_id, customer_id, table_id, reservation_date, reservation_time, number_of_guests, reservation_status) VALUES
 (1, 1, 3, CURRENT_DATE + 1, '18:00', 4, 'confirmed'),
 (2, 2, 1, CURRENT_DATE + 1, '19:00', 2, 'confirmed'),
 (3, 3, 6, CURRENT_DATE + 2, '12:00', 6, 'pending'),
 (4, 4, 7, CURRENT_DATE + 3, '19:30', 8, 'confirmed'),
 (5, 5, 3, CURRENT_DATE + 1, '20:00', 3, 'confirmed'),
 (6, 1, 2, CURRENT_DATE - 2, '18:00', 2, 'completed'),
 (7, 2, 4, CURRENT_DATE + 4, '18:00', 4, 'cancelled');

-- ------------------------------------------------------------------ keep SERIAL sequences in step
-- The rows above use explicit ids, so move every sequence past the highest id.
SELECT setval(pg_get_serial_sequence('staff', 'staff_id'),                 (SELECT MAX(staff_id) FROM staff));
SELECT setval(pg_get_serial_sequence('customer', 'customer_id'),           (SELECT MAX(customer_id) FROM customer));
SELECT setval(pg_get_serial_sequence('menu_item', 'menu_item_id'),         (SELECT MAX(menu_item_id) FROM menu_item));
SELECT setval(pg_get_serial_sequence('restaurant_table', 'table_id'),      (SELECT MAX(table_id) FROM restaurant_table));
SELECT setval(pg_get_serial_sequence('orders', 'order_id'),                (SELECT MAX(order_id) FROM orders));
SELECT setval(pg_get_serial_sequence('reservation', 'reservation_id'),     (SELECT MAX(reservation_id) FROM reservation));
SELECT setval(pg_get_serial_sequence('payment', 'payment_id'),             (SELECT MAX(payment_id) FROM payment));

COMMIT;

-- Quick check (expected: 2 / 5 / 10 / 8 / 6 / 14 / 7 / 5)
SELECT (SELECT COUNT(*) FROM staff)            AS staff,
       (SELECT COUNT(*) FROM customer)         AS customers,
       (SELECT COUNT(*) FROM menu_item)        AS menu_items,
       (SELECT COUNT(*) FROM restaurant_table) AS tables,
       (SELECT COUNT(*) FROM orders)           AS orders,
       (SELECT COUNT(*) FROM order_item)       AS order_items,
       (SELECT COUNT(*) FROM reservation)      AS reservations,
       (SELECT COUNT(*) FROM payment)          AS payments;
