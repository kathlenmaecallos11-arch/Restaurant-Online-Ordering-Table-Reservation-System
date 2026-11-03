-- 002_integrity_logic.sql
-- Business rules that a plain column constraint cannot express (Activity 2, Part 4):
--   BR9  "An order must contain at least one order item"   -> deferred constraint triggers
--   --   orders.total_amount always equals the sum of its item subtotals -> trigger
--   --   a guest count may not exceed the table capacity     -> trigger
--   --   a table cannot be double-booked (problem statement)  -> exclusion constraint

BEGIN;

-- ---------------------------------------------------------------- order total kept in sync
CREATE OR REPLACE FUNCTION fn_refresh_order_total() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    v_order_id integer;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_order_id := OLD.order_id;
    ELSE
        v_order_id := NEW.order_id;
    END IF;

    UPDATE orders
       SET total_amount = COALESCE((SELECT SUM(subtotal) FROM order_item WHERE order_id = v_order_id), 0)
     WHERE order_id = v_order_id;

    IF TG_OP = 'UPDATE' AND OLD.order_id <> NEW.order_id THEN
        UPDATE orders
           SET total_amount = COALESCE((SELECT SUM(subtotal) FROM order_item WHERE order_id = OLD.order_id), 0)
         WHERE order_id = OLD.order_id;
    END IF;
    RETURN NULL;
END;
$$;

CREATE TRIGGER trg_order_item_total
    AFTER INSERT OR UPDATE OR DELETE ON order_item
    FOR EACH ROW EXECUTE FUNCTION fn_refresh_order_total();

-- ---------------------------------------------------------------- BR9: order needs >= 1 item
-- Checked at COMMIT (deferred) so the order row and its items can be inserted in one transaction.
CREATE OR REPLACE FUNCTION fn_require_order_items() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    v_order_id integer;
BEGIN
    IF TG_TABLE_NAME = 'orders' THEN
        v_order_id := NEW.order_id;
    ELSE
        v_order_id := OLD.order_id;
    END IF;

    IF EXISTS (SELECT 1 FROM orders WHERE order_id = v_order_id)
       AND NOT EXISTS (SELECT 1 FROM order_item WHERE order_id = v_order_id) THEN
        RAISE EXCEPTION 'Order % must contain at least one order item', v_order_id
              USING ERRCODE = '23514';
    END IF;
    RETURN NULL;
END;
$$;

CREATE CONSTRAINT TRIGGER trg_orders_require_items
    AFTER INSERT ON orders
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION fn_require_order_items();

CREATE CONSTRAINT TRIGGER trg_order_item_keep_one
    AFTER DELETE OR UPDATE OF order_id ON order_item
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION fn_require_order_items();

-- ---------------------------------------------------------------- guests <= table capacity
CREATE OR REPLACE FUNCTION fn_check_reservation_capacity() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    v_capacity integer;
BEGIN
    SELECT capacity INTO v_capacity FROM restaurant_table WHERE table_id = NEW.table_id;
    IF v_capacity IS NOT NULL AND NEW.number_of_guests > v_capacity THEN
        RAISE EXCEPTION 'Table % seats % but % guests were requested',
              NEW.table_id, v_capacity, NEW.number_of_guests
              USING ERRCODE = '23514';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_reservation_capacity
    BEFORE INSERT OR UPDATE OF table_id, number_of_guests ON reservation
    FOR EACH ROW EXECUTE FUNCTION fn_check_reservation_capacity();

-- ---------------------------------------------------------------- no double booking
-- Every active reservation blocks its table for a 2-hour window. Overlapping windows on the
-- same table are rejected by the database itself (SQLSTATE 23P01), not just by the application.
ALTER TABLE reservation
    ADD CONSTRAINT ex_reservation_no_overlap
    EXCLUDE USING gist (
        table_id WITH =,
        (tsrange(reservation_date + reservation_time,
                 reservation_date + reservation_time + interval '2 hours')) WITH &&
    ) WHERE (reservation_status IN ('pending', 'confirmed', 'seated'));

COMMIT;
