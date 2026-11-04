-- crud_tests.sql  -- database-level Create / Retrieve / Update / Delete tests for the approved design.
-- Runs everything inside ONE transaction and ends with ROLLBACK, so the sample data is unchanged.
--   psql -h localhost -U postgres -d grp_binarysisters_projectdb -f tests/crud_tests.sql
-- Each test prints PASS or FAIL. Take a screenshot of the output for the progress PDF.
-- (Run as postgres/administrator so that the test does not depend on the Activity 4 privileges.)
--
-- The tests do not hard-code row numbers or prices: the values they need (a table with 4 or more seats,
-- the smallest table, the price of 'Chicken Adobo') are read from the sample data into test_ctx first.
-- Every constraint test (K1-K14) also checks the SQLSTATE: a statement that fails for the wrong reason is a FAIL.
--   23502 NOT NULL | 23503 FOREIGN KEY (insert) | 23001 FOREIGN KEY ON DELETE RESTRICT | 23505 UNIQUE
--   23514 CHECK / trigger rule | 23P01 no double booking
\set ON_ERROR_STOP on
\pset pager off
BEGIN;

CREATE TEMP TABLE test_results (name text, outcome text);

-- values taken from the sample data
CREATE TEMP TABLE test_ctx AS
SELECT (SELECT table_id FROM restaurant_table WHERE capacity >= 4 ORDER BY capacity, table_id LIMIT 1) AS big_table,
       (SELECT table_id FROM restaurant_table ORDER BY capacity, table_id LIMIT 1)                       AS small_table,
       (SELECT MIN(capacity) FROM restaurant_table)                                                      AS small_cap,
       (SELECT price FROM menu_item WHERE item_name = 'Chicken Adobo')                                    AS adobo_price;

-- ---------- CREATE
INSERT INTO customer (first_name, last_name, email, phone, password)
VALUES ('Test', 'Customer', 'crud.test@rors.example', '09179999999', 'not-a-real-hash');
INSERT INTO test_results SELECT 'C1 customer inserted',
    CASE WHEN EXISTS (SELECT 1 FROM customer WHERE email = 'crud.test@rors.example') THEN 'PASS' ELSE 'FAIL' END;

INSERT INTO orders (customer_id) SELECT customer_id FROM customer WHERE email = 'crud.test@rors.example';
INSERT INTO order_item (order_id, menu_item_id, quantity, unit_price, subtotal)
SELECT o.order_id, m.menu_item_id, 3, m.price, 3 * m.price
FROM orders o JOIN customer c USING (customer_id), menu_item m
WHERE c.email = 'crud.test@rors.example' AND m.item_name = 'Chicken Adobo';
INSERT INTO test_results SELECT 'C2 order total maintained by trigger (3 x price of Chicken Adobo)',
    CASE WHEN (SELECT total_amount FROM orders o JOIN customer c USING (customer_id) WHERE c.email = 'crud.test@rors.example')
              = 3 * (SELECT adobo_price FROM test_ctx) THEN 'PASS' ELSE 'FAIL' END;

INSERT INTO payment (order_id, payment_method, amount)
SELECT o.order_id, 'cash', o.total_amount FROM orders o JOIN customer c USING (customer_id) WHERE c.email = 'crud.test@rors.example';
INSERT INTO reservation (customer_id, table_id, reservation_date, reservation_time, number_of_guests)
SELECT c.customer_id, x.big_table, CURRENT_DATE + 10, '18:00', 4
FROM customer c, test_ctx x WHERE c.email = 'crud.test@rors.example';
INSERT INTO test_results SELECT 'C3 payment and reservation inserted',
    CASE WHEN (SELECT COUNT(*) FROM payment p JOIN orders o USING (order_id) JOIN customer c USING (customer_id) WHERE c.email = 'crud.test@rors.example') = 1
          AND (SELECT COUNT(*) FROM reservation r JOIN customer c USING (customer_id) WHERE c.email = 'crud.test@rors.example') = 1 THEN 'PASS' ELSE 'FAIL' END;

-- ---------- RETRIEVE
INSERT INTO test_results SELECT 'R1 view v_order_summary shows the new order',
    CASE WHEN EXISTS (SELECT 1 FROM v_order_summary WHERE customer_name = 'Test Customer' AND line_items = 1 AND payment_status = 'pending') THEN 'PASS' ELSE 'FAIL' END;
INSERT INTO test_results SELECT 'R2 menu search (ILIKE) finds adobo',
    CASE WHEN EXISTS (SELECT 1 FROM menu_item WHERE item_name ILIKE '%adobo%' AND availability) THEN 'PASS' ELSE 'FAIL' END;
INSERT INTO test_results SELECT 'R3 every order total equals the sum of its lines (0 mismatches)',
    CASE WHEN NOT EXISTS (SELECT 1 FROM orders o
                           WHERE o.total_amount <> COALESCE((SELECT SUM(oi.subtotal) FROM order_item oi WHERE oi.order_id = o.order_id), 0))
         THEN 'PASS' ELSE 'FAIL' END;
INSERT INTO test_results SELECT 'R4 every payment amount equals the total of its order (0 mismatches)',
    CASE WHEN NOT EXISTS (SELECT 1 FROM payment p JOIN orders o USING (order_id) WHERE p.amount <> o.total_amount)
         THEN 'PASS' ELSE 'FAIL' END;

-- ---------- UPDATE
UPDATE menu_item SET price = price + 20 WHERE item_name = 'Chicken Adobo';
UPDATE orders SET order_status = 'confirmed' WHERE customer_id = (SELECT customer_id FROM customer WHERE email = 'crud.test@rors.example');
INSERT INTO test_results SELECT 'U1 price change does NOT alter the stored order line (unit_price history kept)',
    CASE WHEN (SELECT unit_price FROM order_item oi JOIN orders o USING (order_id) JOIN customer c USING (customer_id) WHERE c.email = 'crud.test@rors.example')
              = (SELECT adobo_price FROM test_ctx) THEN 'PASS' ELSE 'FAIL' END;
INSERT INTO test_results SELECT 'U2 order status updated',
    CASE WHEN (SELECT order_status FROM orders o JOIN customer c USING (customer_id) WHERE c.email = 'crud.test@rors.example') = 'confirmed' THEN 'PASS' ELSE 'FAIL' END;

-- ---------- constraint tests: every statement below MUST fail with the expected SQLSTATE; each runs in a savepoint
DO $$
DECLARE
    tests text[][] := ARRAY[
      ['K1 negative price rejected',                       'INSERT INTO menu_item (item_name,category,price) VALUES (''x'',''x'',-1)', '23514'],
      ['K2 zero capacity rejected',                        'INSERT INTO restaurant_table (table_number,capacity) VALUES (99,0)', '23514'],
      ['K3 duplicate email rejected',                      'INSERT INTO customer (first_name,last_name,email,phone,password) VALUES (''a'',''b'',''crud.test@rors.example'',''1'',''x'')', '23505'],
      ['K4 order without items rejected at commit',        'SET CONSTRAINTS ALL IMMEDIATE; INSERT INTO orders (customer_id) SELECT customer_id FROM customer LIMIT 1', '23514'],
      ['K5 table double-booking rejected',                 'INSERT INTO reservation (customer_id,table_id,reservation_date,reservation_time,number_of_guests) SELECT customer_id,(SELECT big_table FROM test_ctx),CURRENT_DATE+10,''19:00'',2 FROM customer LIMIT 1', '23P01'],
      ['K6 guests above table capacity rejected',          'INSERT INTO reservation (customer_id,table_id,reservation_date,reservation_time,number_of_guests) SELECT customer_id,(SELECT small_table FROM test_ctx),CURRENT_DATE+20,''12:00'',(SELECT small_cap FROM test_ctx)+1 FROM customer LIMIT 1', '23514'],
      ['K7 second payment for one order rejected',         'INSERT INTO payment (order_id,payment_method,amount) SELECT order_id,''cash'',1 FROM payment LIMIT 1', '23505'],
      ['K8 unknown status rejected',                       'UPDATE orders SET order_status = ''flying'' WHERE order_id = 1', '23514'],
      ['K9 deleting a menu item used by orders rejected',  'DELETE FROM menu_item WHERE item_name = ''Chicken Adobo''', '23001'],
      ['K10 wrong subtotal rejected',                      'INSERT INTO order_item (order_id,menu_item_id,quantity,unit_price,subtotal) VALUES (1,2,2,220,1)', '23514'],
      ['K11 NULL first name rejected',                     'INSERT INTO customer (first_name,last_name,email,phone,password) VALUES (NULL,''No'',''no.name@rors.example'',''1'',''x'')', '23502'],
      ['K12 quantity 0 rejected',                          'INSERT INTO order_item (order_id,menu_item_id,quantity,unit_price,subtotal) VALUES (1,2,0,220,0)', '23514'],
      ['K13 order for a missing customer rejected',        'INSERT INTO orders (customer_id) VALUES (999999)', '23503'],
      ['K14 order that has a payment cannot be deleted',   'DELETE FROM orders WHERE order_id = 1', '23001']
    ];
    i int;
BEGIN
    FOR i IN 1 .. array_length(tests, 1) LOOP
        BEGIN
            EXECUTE tests[i][2];
            RAISE EXCEPTION '__undo__' USING ERRCODE = 'P0001';   -- statement succeeded: roll it back, record FAIL
        EXCEPTION
            WHEN SQLSTATE 'P0001' THEN
                INSERT INTO test_results VALUES (tests[i][1], 'FAIL (statement succeeded)');
            WHEN OTHERS THEN
                INSERT INTO test_results VALUES (tests[i][1],
                    CASE WHEN SQLSTATE = tests[i][3] THEN 'PASS (' || SQLSTATE || ')'
                         ELSE 'FAIL (expected ' || tests[i][3] || ', got ' || SQLSTATE || ')' END);
        END;
    END LOOP;
END $$;

-- ---------- DELETE
ALTER TABLE test_ctx ADD COLUMN test_order integer;
UPDATE test_ctx SET test_order = (SELECT o.order_id FROM orders o JOIN customer c USING (customer_id) WHERE c.email = 'crud.test@rors.example');

DELETE FROM reservation WHERE customer_id = (SELECT customer_id FROM customer WHERE email = 'crud.test@rors.example');
UPDATE payment SET payment_status = 'cancelled' WHERE order_id IN (SELECT o.order_id FROM orders o JOIN customer c USING (customer_id) WHERE c.email = 'crud.test@rors.example');
DELETE FROM payment WHERE order_id IN (SELECT o.order_id FROM orders o JOIN customer c USING (customer_id) WHERE c.email = 'crud.test@rors.example');
DELETE FROM orders WHERE customer_id = (SELECT customer_id FROM customer WHERE email = 'crud.test@rors.example');
DELETE FROM customer WHERE email = 'crud.test@rors.example';
INSERT INTO test_results SELECT 'D1 test data removed (children first, order_item cascades)',
    CASE WHEN NOT EXISTS (SELECT 1 FROM customer WHERE email = 'crud.test@rors.example') THEN 'PASS' ELSE 'FAIL' END;
INSERT INTO test_results SELECT 'D2 the order lines were removed with their order (ON DELETE CASCADE)',
    CASE WHEN NOT EXISTS (SELECT 1 FROM order_item WHERE order_id = (SELECT test_order FROM test_ctx)) THEN 'PASS' ELSE 'FAIL' END;

SELECT name, outcome FROM test_results ORDER BY ctid;
SELECT COUNT(*) FILTER (WHERE outcome LIKE 'PASS%') AS passed, COUNT(*) FILTER (WHERE outcome LIKE 'FAIL%') AS failed FROM test_results;

ROLLBACK;   -- nothing above is kept

-- ---------- the data is unchanged: compare with the quick check at the end of database/seeds/001_seed_data.sql
-- (sample data: customers 51, staff 10, menu items 50, tables 20, orders 60, order lines 167, payments 56, reservations 50)
SELECT 'customer' AS tbl, COUNT(*) FROM customer
UNION ALL SELECT 'staff',            COUNT(*) FROM staff
UNION ALL SELECT 'menu_item',        COUNT(*) FROM menu_item
UNION ALL SELECT 'restaurant_table', COUNT(*) FROM restaurant_table
UNION ALL SELECT 'orders',           COUNT(*) FROM orders
UNION ALL SELECT 'order_item',       COUNT(*) FROM order_item
UNION ALL SELECT 'payment',          COUNT(*) FROM payment
UNION ALL SELECT 'reservation',      COUNT(*) FROM reservation;