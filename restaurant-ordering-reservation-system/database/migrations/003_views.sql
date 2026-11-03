-- 003_views.sql
-- Reporting views. The credential columns (customer.password, staff.password) are never exposed.
-- Views run with their OWNER's rights, so a read-only/auditor account can be given SELECT on the
-- views without any privilege on the underlying customer/staff tables (see database/roles).

BEGIN;

CREATE OR REPLACE VIEW v_customer_directory AS
SELECT customer_id, first_name, last_name, email, phone, created_at
FROM customer;

CREATE OR REPLACE VIEW v_staff_directory AS
SELECT staff_id, first_name, last_name, email, role
FROM staff;

CREATE OR REPLACE VIEW v_order_summary AS
SELECT o.order_id,
       c.customer_id,
       c.first_name || ' ' || c.last_name AS customer_name,
       o.order_date,
       o.order_status,
       o.total_amount,
       (SELECT COUNT(*) FROM order_item oi WHERE oi.order_id = o.order_id) AS line_items,
       p.payment_method,
       p.payment_status
FROM orders o
JOIN customer c ON c.customer_id = o.customer_id
LEFT JOIN payment p ON p.order_id = o.order_id;

CREATE OR REPLACE VIEW v_reservation_schedule AS
SELECT r.reservation_id,
       r.reservation_date,
       r.reservation_time,
       r.number_of_guests,
       r.reservation_status,
       t.table_number,
       t.capacity,
       c.first_name || ' ' || c.last_name AS customer_name
FROM reservation r
JOIN restaurant_table t ON t.table_id = r.table_id
JOIN customer c ON c.customer_id = r.customer_id;

COMMIT;
