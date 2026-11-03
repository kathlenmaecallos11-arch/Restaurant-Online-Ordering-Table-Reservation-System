# Changes from the approved Activity 2 design (and why)

The approved ERD, schema and business rules were implemented as designed. The items below are the only differences or
additions; each one comes from an inconsistency found in the Activity 2 documents or from a rule that the original
constraints could not enforce.

| # | Change | Reason |
|---|---|---|
| 1 | Table names `menu_item` and `order_item` (singular) are used everywhere. | The Activity 2 documents mixed `MENU_ITEMS`/`menu_item` and `order_items`/`order_item`. The pgAdmin ERD generated from the real database used the singular names, so those won. `orders` stays plural because ORDER is reserved. |
| 2 | `CHECK (price >= 0)` (not `> 0` as in the Part 11 DDL sample). | Part 6 and Part 9 specify `price >= 0`; the schema table is the approved source. The `UNIQUE (item_name)` shown in the Part 11 sample was **not** added because it is not in the approved schema (two branches may sell the same name in different categories). |
| 3 | Status/role/method columns received `CHECK ... IN (...)` constraints. | Part 6 gave only defaults; unrestricted VARCHAR allows typos such as "confrimed" that break the application. |
| 4 | `orders.total_amount` has `DEFAULT 0` and is kept in sync by a trigger. | Design said NOT NULL but not how it is calculated; a trigger prevents a total that disagrees with the lines. |
| 5 | `CHECK (subtotal = quantity * unit_price)` on `order_item`. | Data dictionary says "quantity multiplied by unit price"; now guaranteed. |
| 6 | Business rule 9 (order needs ≥ 1 item) implemented with deferred constraint triggers. | A column constraint cannot express it ("ORDER-ITEM is required" in Activity 2). |
| 7 | Exclusion constraint against overlapping reservations + capacity trigger. | The problem statement names "double bookings" as the problem to solve; the original schema would still allow them. Requires `btree_gist`. |
| 8 | `payment.payment_method` limited to cash, card, gcash, bank_transfer; `payment_status` includes `cancelled`. | Needed by the application workflow. |
| 9 | Four views added (`v_*`). | Activity 2 Part 11 listed views as a planned "other database object"; they also make least-privilege read-only access possible (Activity 4). |
| 10 | Six indexes added. | Activity 2 handoff noted "no indexes yet"; foreign keys are not indexed automatically. |
| 11 | Password columns keep the name `password` but store bcrypt hashes. | Name kept for consistency with the approved schema; a later revision could rename to `password_hash`. |
| 12 | Stack: PHP 8 (no framework) + PDO/pgsql, built-in server. | Matches the Activity 2 architecture (HTML/CSS/JS → PHP → PostgreSQL). |

| 13 | Interface redesigned ("Mesa": menu-board layout with dotted price leaders, booking strip on the home page, staff area with its own sidebar). Brand name is set by `APP_BRAND` in `.env`. | Activity 2 only specified HTML/CSS/JS presentation; the design was refined for usability and accessibility (keyboard focus, labelled fields, colour plus text status chips, responsive down to phone width). |
