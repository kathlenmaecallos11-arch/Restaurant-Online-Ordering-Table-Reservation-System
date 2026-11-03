-- 001_create_tables.sql
-- Creates the 8 tables of the approved Activity 2 design (Parts 6, 7 and 9).
-- Run while connected to grp_binarysisters_projectdb.
--
-- Naming note: the table names follow the ERD that pgAdmin generated from the real database
-- in Activity 2 (customer, menu_item, restaurant_table, orders, order_item, reservation,
-- payment, staff). "orders" is plural because ORDER is a reserved SQL word.
-- Status columns get extra CHECK constraints (listed in docs/changes-from-activity2.md).

BEGIN;

CREATE EXTENSION IF NOT EXISTS btree_gist;   -- needed by the reservation overlap constraint (002)
CREATE EXTENSION IF NOT EXISTS pgcrypto;     -- used only by the seed file to hash sample passwords

CREATE TABLE customer (
    customer_id  SERIAL        PRIMARY KEY,
    first_name   VARCHAR(50)   NOT NULL,
    last_name    VARCHAR(50)   NOT NULL,
    email        VARCHAR(100)  NOT NULL,
    phone        VARCHAR(20)   NOT NULL,
    password     VARCHAR(255)  NOT NULL,          -- stores a password HASH (bcrypt), never plain text
    created_at   TIMESTAMP     NOT NULL DEFAULT now(),
    CONSTRAINT uq_customer_email  UNIQUE (email),
    CONSTRAINT chk_customer_email CHECK (email ~* '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$')
);

CREATE TABLE menu_item (
    menu_item_id SERIAL         PRIMARY KEY,
    item_name    VARCHAR(100)   NOT NULL,
    description  TEXT           NULL,
    category     VARCHAR(50)    NOT NULL,
    price        NUMERIC(10,2)  NOT NULL,
    availability BOOLEAN        NOT NULL DEFAULT true,
    CONSTRAINT chk_menu_item_price CHECK (price >= 0)
);

CREATE TABLE restaurant_table (
    table_id     SERIAL       PRIMARY KEY,
    table_number INTEGER      NOT NULL,
    capacity     INTEGER      NOT NULL,
    status       VARCHAR(20)  NOT NULL DEFAULT 'available',
    CONSTRAINT uq_restaurant_table_number UNIQUE (table_number),
    CONSTRAINT chk_restaurant_table_capacity CHECK (capacity > 0),
    CONSTRAINT chk_restaurant_table_status
        CHECK (status IN ('available', 'occupied', 'reserved', 'out_of_service'))
);

CREATE TABLE staff (
    staff_id     SERIAL        PRIMARY KEY,
    first_name   VARCHAR(50)   NOT NULL,
    last_name    VARCHAR(50)   NOT NULL,
    email        VARCHAR(100)  NOT NULL,
    role         VARCHAR(30)   NOT NULL,
    password     VARCHAR(255)  NOT NULL,          -- password HASH
    CONSTRAINT uq_staff_email UNIQUE (email),
    CONSTRAINT chk_staff_role CHECK (role IN ('admin', 'staff'))
);

CREATE TABLE orders (
    order_id     SERIAL         PRIMARY KEY,
    customer_id  INTEGER        NOT NULL,
    order_date   TIMESTAMP      NOT NULL DEFAULT now(),
    order_status VARCHAR(20)    NOT NULL DEFAULT 'pending',
    total_amount NUMERIC(10,2)  NOT NULL DEFAULT 0,   -- kept in sync by trigger trg_order_item_total (002)
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customer (customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_orders_status
        CHECK (order_status IN ('pending', 'confirmed', 'preparing', 'ready', 'completed', 'cancelled')),
    CONSTRAINT chk_orders_total CHECK (total_amount >= 0)
);

CREATE TABLE order_item (
    order_id     INTEGER        NOT NULL,
    menu_item_id INTEGER        NOT NULL,
    quantity     INTEGER        NOT NULL,
    unit_price   NUMERIC(10,2)  NOT NULL,    -- price at the time of ordering (history is preserved)
    subtotal     NUMERIC(10,2)  NOT NULL,
    CONSTRAINT pk_order_item PRIMARY KEY (order_id, menu_item_id),
    CONSTRAINT fk_order_item_order
        FOREIGN KEY (order_id) REFERENCES orders (order_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_order_item_menu_item
        FOREIGN KEY (menu_item_id) REFERENCES menu_item (menu_item_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_order_item_quantity  CHECK (quantity > 0),
    CONSTRAINT chk_order_item_unit_price CHECK (unit_price >= 0),
    CONSTRAINT chk_order_item_subtotal  CHECK (subtotal >= 0),
    CONSTRAINT chk_order_item_math      CHECK (subtotal = quantity * unit_price)
);

CREATE TABLE reservation (
    reservation_id     SERIAL       PRIMARY KEY,
    customer_id        INTEGER      NOT NULL,
    table_id           INTEGER      NOT NULL,
    reservation_date   DATE         NOT NULL,
    reservation_time   TIME         NOT NULL,
    number_of_guests   INTEGER      NOT NULL,
    reservation_status VARCHAR(20)  NOT NULL DEFAULT 'confirmed',
    CONSTRAINT fk_reservation_customer
        FOREIGN KEY (customer_id) REFERENCES customer (customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_reservation_table
        FOREIGN KEY (table_id) REFERENCES restaurant_table (table_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_reservation_guests CHECK (number_of_guests > 0),
    CONSTRAINT chk_reservation_status
        CHECK (reservation_status IN ('pending', 'confirmed', 'seated', 'completed', 'cancelled', 'no_show'))
);

CREATE TABLE payment (
    payment_id     SERIAL         PRIMARY KEY,
    order_id       INTEGER        NOT NULL,
    payment_date   TIMESTAMP      NOT NULL DEFAULT now(),
    payment_method VARCHAR(30)    NOT NULL,
    amount         NUMERIC(10,2)  NOT NULL,
    payment_status VARCHAR(20)    NOT NULL DEFAULT 'pending',
    CONSTRAINT uq_payment_order UNIQUE (order_id),          -- ORDER 1 : 1 PAYMENT
    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id) REFERENCES orders (order_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_payment_amount CHECK (amount >= 0),
    CONSTRAINT chk_payment_method CHECK (payment_method IN ('cash', 'card', 'gcash', 'bank_transfer')),
    CONSTRAINT chk_payment_status
        CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded', 'cancelled'))
);

COMMIT;
