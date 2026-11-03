-- crud_tests.sql  -- database-level Create / Retrieve / Update / Delete tests for the approved design.
-- Runs everything inside ONE transaction and ends with ROLLBACK, so the sample data is unchanged.
--   psql -h localhost -U postgres -d grp_binarysisters_projectdb -f tests/crud_tests.sql
-- Each test prints PASS or raises an error. Take a screenshot of the output for the progress PDF.
-- (Run as postgres/administrator so that the test does not depend on the Activity 4 privileges.)
\set ON_ERROR_STOP on
\pset pager off
BEGIN;

CREATE TEMP TABLE test_results (name text, outcome text);

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
INSERT INTO test_results SELECT 'C2 order total maintained by trigger (3 x 280.00 = 840.00)',
    CASE WHEN (SELECT total_amount FROM orders o JOIN customer c USING (customer_id) WHERE c.email = 'crud.test@rors.example') = 840.00 THEN 'PASS' ELSE 'FAIL' END;

INSERT INTO payment (order_id, payment_method, amount)
SELECT o.order_id, 'cash', o.total_amount FROM orders o JOIN customer c USING (customer_id) WHERE c.email = 'crud.test@rors.example';
INSERT INTO reservation (customer_id, table_id, reservation_date, reservation_time, number_of_guests)
SELECT c.customer_id, 5, CURRENT_DATE + 10, '18:00', 4 FROM customer c WHERE c.email = 'crud.test@rors.example';
INSERT INTO test_results SELECT 'C3 payment and reservation inserted',
    CASE WHEN (SELECT COUNT(*) FROM payment p JOIN orders o USING (order_id) JOIN customer c USING (customer_id) WHERE c.email = 'crud.test@rors.example') = 1
          AND (SELECT COUNT(*) FROM reservation r JOIN customer c USING (customer_id) WHERE c.email = 'crud.test@rors.example') = 1 THEN 'PASS' ELSE 'FAIL' END;

-- ---------- RETRIEVE
INSERT INTO test_results SELECT 'R1 view v_order_summary shows the new order',
    CASE WHEN EXISTS (SELECT 1 FROM v_order_summary WHERE customer_name = 'Test Customer' AND line_items = 1 AND payment_status = 'pending') THEN 'PASS' ELSE 'FAIL' END;
INSERT INTO test_results SELECT 'R2 menu search (ILIKE) finds adobo',
    CASE WHEN EXISTS (SELECT 1 FROM menu_item WHERE item_name ILIKE '%adobo%' AND availability) THEN 'PASS' ELSE 'FAIL' END;

-- ---------- UPDATE
UPDATE menu_item SET price = 300.00 WHERE item_name = 'Chicken Adobo';
UPDATE orders SET order_status = 'confirmed' WHERE customer_id = (SELECT customer_id FROM customer WHERE email = 'crud.test@rors.example');
INSERT INTO test_results SELECT 'U1 price change does NOT alter the stored order line (unit_price history kept)',
    CASE WHEN (SELECT unit_price FROM order_item oi JOIN orders o USING (order_id) JOIN customer c USING (customer_id) WHERE c.email = 'crud.test@rors.example') = 280.00 THEN 'PASS' ELSE 'FAIL' END;
INSERT INTO test_results SELECT 'U2 order status updated',
    CASE WHEN (SELECT order_status FROM orders o JOIN customer c USING (customer_id) WHERE c.email = 'crud.test@rors.example') = 'confirmed' THEN 'PASS' ELSE 'FAIL' END;

-- ---------- constraint tests: every statement below MUST fail; each runs in a savepoint
DO $$
DECLARE
    tests text[][] := ARRAY[
      ['K1 negative price rejected',               'INSERT INTO menu_item (item_name,category,price) VALUES (''x'',''x'',-1)'],
      ['K2 zero capacity rejected',                'INSERT INTO restaurant_table (table_number,capacity) VALUES (99,0)'],
      ['K3 duplicate email rejected',              'INSERT INTO customer (first_name,last_name,email,phone,password) VALUES (''a'',''b'',''crud.test@rors.example'',''1'',''x'')'],
      ['K4 order without items rejected at commit','SET CONSTRAINTS ALL IMMEDIATE; INSERT INTO orders (customer_id) SELECT customer_id FROM customer LIMIT 1'],
      ['K5 table double-booking rejected',         'INSERT INTO reservation (customer_id,table_id,reservation_date,reservation_time,number_of_guests) SELECT customer_id,5,CURRENT_DATE+10,''19:00'',2 FROM customer LIMIT 1'],
      ['K6 guests above table capacity rejected',  'INSERT INTO reservation (customer_id,table_id,reservation_date,reservation_time,number_of_guests) SELECT customer_id,1,CURRENT_DATE+20,''12:00'',5 FROM customer LIMIT 1'],
      ['K7 second payment for one order rejected', 'INSERT INTO payment (order_id,payment_method,amount) SELECT order_id,''cash'',1 FROM payment LIMIT 1'],
      ['K8 unknown status rejected',                'UPDATE orders SET order_status = ''flying'' WHERE order_id = 1'],
      ['K9 deleting a menu item used by orders rejected', 'DELETE FROM menu_item WHERE item_name = ''Chicken Adobo'''],
      ['K10 wrong subtotal rejected',              'INSERT INTO order_item (order_id,menu_item_id,quantity,unit_price,subtotal) VALUES (1,2,2,220,1)']
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
                INSERT INTO test_results VALUES (tests[i][1], 'PASS (' || SQLSTATE || ')');
        END;
    END LOOP;
END $$;

-- ---------- DELETE
DELETE FROM reservation WHERE customer_id = (SELECT customer_id FROM customer WHERE email = 'crud.test@rors.example');
UPDATE payment SET payment_status = 'cancelled' WHERE order_id IN (SELECT o.order_id FROM orders o JOIN customer c USING (customer_id) WHERE c.email = 'crud.test@rors.example');
DELETE FROM payment WHERE order_id IN (SELECT o.order_id FROM orders o JOIN customer c USING (customer_id) WHERE c.email = 'crud.test@rors.example');
DELETE FROM orders WHERE customer_id = (SELECT customer_id FROM customer WHERE email = 'crud.test@rors.example');
DELETE FROM customer WHERE email = 'crud.test@rors.example';
INSERT INTO test_results SELECT 'D1 test data removed (children first, order_item cascades)',
    CASE WHEN NOT EXISTS (SELECT 1 FROM customer WHERE email = 'crud.test@rors.example') THEN 'PASS' ELSE 'FAIL' END;

SELECT name, outcome FROM test_results ORDER BY ctid;
SELECT COUNT(*) FILTER (WHERE outcome LIKE 'PASS%') AS passed, COUNT(*) FILTER (WHERE outcome LIKE 'FAIL%') AS failed FROM test_results;

ROLLBACK;   -- nothing above is kept
