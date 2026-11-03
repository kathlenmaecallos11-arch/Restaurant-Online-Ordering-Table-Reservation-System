-- =====================================================================
-- Restaurant Online Ordering & Table Reservation System
-- Group: Binary Sisters
-- Database: grp_binarysisters_projectdb   (PostgreSQL 18.6, schema: public)
-- =====================================================================

-- ---------- Independent tables ----------

CREATE TABLE customer (
    customer_id  SERIAL PRIMARY KEY,
    first_name   VARCHAR(50)  NOT NULL,
    last_name    VARCHAR(50)  NOT NULL,
    email        VARCHAR(100) NOT NULL UNIQUE,
    phone        VARCHAR(20)  NOT NULL,
    password     VARCHAR(255) NOT NULL,          -- store a hash, never plain text
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE menu_item (
    menu_item_id SERIAL PRIMARY KEY,
    item_name    VARCHAR(100)  NOT NULL,
    description  TEXT,
    category     VARCHAR(50)   NOT NULL,
    price        NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    availability BOOLEAN       NOT NULL DEFAULT TRUE
);

CREATE TABLE restaurant_table (
    table_id     SERIAL PRIMARY KEY,
    table_number INTEGER     NOT NULL UNIQUE,
    capacity     INTEGER     NOT NULL CHECK (capacity > 0),
    status       VARCHAR(20) NOT NULL DEFAULT 'available'
);

CREATE TABLE staff (
    staff_id     SERIAL PRIMARY KEY,
    first_name   VARCHAR(50)  NOT NULL,
    last_name    VARCHAR(50)  NOT NULL,
    email        VARCHAR(100) NOT NULL UNIQUE,
    role         VARCHAR(30)  NOT NULL,
    password     VARCHAR(255) NOT NULL           -- store a hash, never plain text
);

-- ---------- Dependent tables ----------

CREATE TABLE orders (
    order_id     SERIAL PRIMARY KEY,
    customer_id  INTEGER       NOT NULL,
    order_date   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    order_status VARCHAR(20)   NOT NULL DEFAULT 'pending',
    total_amount NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    CONSTRAINT fk_order_customer
        FOREIGN KEY (customer_id) REFERENCES customer (customer_id)
);

CREATE TABLE order_item (
    order_id     INTEGER       NOT NULL,
    menu_item_id INTEGER       NOT NULL,
    quantity     INTEGER       NOT NULL CHECK (quantity > 0),
    unit_price   NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    subtotal     NUMERIC(10,2) NOT NULL CHECK (subtotal >= 0),
    PRIMARY KEY (order_id, menu_item_id),
    CONSTRAINT fk_order_item_order
        FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE,
    CONSTRAINT fk_order_item_menu
        FOREIGN KEY (menu_item_id) REFERENCES menu_item (menu_item_id)
);

CREATE TABLE payment (
    payment_id     SERIAL PRIMARY KEY,
    order_id       INTEGER       NOT NULL UNIQUE,  -- 1:1 with orders
    payment_date   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(30)   NOT NULL,
    amount         NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
    payment_status VARCHAR(20)   NOT NULL DEFAULT 'pending',
    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id) REFERENCES orders (order_id)
);

CREATE TABLE reservation (
    reservation_id     SERIAL PRIMARY KEY,
    customer_id        INTEGER     NOT NULL,
    table_id           INTEGER     NOT NULL,
    reservation_date   DATE        NOT NULL,
    reservation_time   TIME        NOT NULL,
    number_of_guests   INTEGER     NOT NULL CHECK (number_of_guests > 0),
    reservation_status VARCHAR(20) NOT NULL DEFAULT 'confirmed',
    CONSTRAINT fk_reservation_customer
        FOREIGN KEY (customer_id) REFERENCES customer (customer_id),
    CONSTRAINT fk_reservation_table
        FOREIGN KEY (table_id) REFERENCES restaurant_table (table_id)
);