-- reset_database.sql  -- DESTRUCTIVE: removes every table, view and function of the project.
-- Use only on your own LOCAL development database, then re-run migrations + seeds.
--   psql -h localhost -U postgres -d grp_binarysisters_projectdb -f database/reset_database.sql
-- It does NOT drop the database, roles, or extensions.

BEGIN;
DROP TABLE IF EXISTS payment, order_item, reservation, orders, staff, restaurant_table, menu_item, customer CASCADE;
DROP FUNCTION IF EXISTS fn_refresh_order_total();
DROP FUNCTION IF EXISTS fn_require_order_items();
DROP FUNCTION IF EXISTS fn_check_reservation_capacity();
COMMIT;
