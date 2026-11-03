-- 004_indexes.sql
-- Indexes that support the application's own queries and the foreign keys.
-- PostgreSQL indexes primary keys and UNIQUE constraints automatically but NOT foreign keys.
-- (The exclusion constraint in 002 already creates a GiST index on table_id + time window.)
-- Every index costs write time and disk space, so only queries that exist in the app are covered.

BEGIN;

CREATE INDEX idx_orders_customer_date  ON orders (customer_id, order_date DESC);   -- "my orders" page
CREATE INDEX idx_orders_status         ON orders (order_status);                   -- staff order queue
CREATE INDEX idx_order_item_menu_item  ON order_item (menu_item_id);               -- FK; item-level reports
CREATE INDEX idx_reservation_customer  ON reservation (customer_id, reservation_date); -- "my reservations"
CREATE INDEX idx_reservation_date      ON reservation (reservation_date);          -- daily schedule
CREATE INDEX idx_menu_item_category    ON menu_item (category);                    -- menu filter

COMMIT;
