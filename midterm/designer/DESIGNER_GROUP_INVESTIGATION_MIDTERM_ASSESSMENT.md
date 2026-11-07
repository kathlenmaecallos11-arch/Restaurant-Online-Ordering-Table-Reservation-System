# COMP 018 – MIDTERM ASSESSMENT

**Integrated Database Administration Challenge**
*Review, Design, Investigate, Troubleshoot, and Defend*

| | |
|---|---|
| **Designer Group** | Group 10: Mesa - Order and Reserve |
| **Project Owner** | Group 04: BrewPOS - Cafe Point-of-Sale System |
| **Course** | COMP 018 – Database Administration |
| **Assessment Type** | Group-based integrated practical challenge |
| **Database Platform** | PostgreSQL |
| **Total Score** | 100 points |
| **Project Basis** | The class's projects from Activities 3 to 6, found in the tracker |
| **Format** | Flaw review, incident design, investigation, PDF report, and technical defense |

**Designer role.** Group 10 reviewed the BrewPOS project of Group 04 and recorded five flaws in the Flaw Register, covering privileges, schema, setup, seed data, and payment records. From these we designed five incident scenarios: G04-INC1 (role-based access control), G04-INC2 (order status tracking), G04-INC3 (documentation and role script mismatch), G04-INC4 (seeder product lookup), and G04-INC5 (payment transaction table).

**Owner results reviewed.** Group 04 reported all five incidents as Resolved. We compared that report with the contents of the submitted repository (brewpos-main.zip). All five fix scripts exist in midterm/owner-investigation/scripts, but only some of the fixes reach the files that set up and run the system. Our review finds: one incident solved at schema level with integration pending (INC5), one solved in the database but not integrated with the application (INC2), two partly solved (INC1, INC3), and one not solved in the repository (INC4). Details are in Part E.

**Limit of this review.** We read the scripts and documentation and compared them with the owner's claims. PostgreSQL was not available while this report was prepared, so the owner's test outputs were not re-executed. Items marked "to confirm" must be run on our disposable copy.

## Required Tasks and Deliverables

### Part A – Flaw Review (Designer Group)

| Flaw ID | Area and activity | Description | Evidence (file in owner repository) | Severity | Recommended fix |
|---|---|---|---|---|---|
| G04-F1 | Privileges (Activity 4) | Role-based access control is not implemented in the database as the user roles documentation describes. One runtime login, brewpos_app, holds INSERT, UPDATE and DELETE on menu_category and menu_item, so a cashier session can change prices. | database/05_create_app_role.sql (section 4: GRANT SELECT, INSERT, UPDATE, DELETE on menu_category and menu_item); docs/user-roles.md section 2 (Cashier "restricted from modifying menu prices, categories"). | High | Create separate group roles; give the cashier role SELECT on the menu and INSERT on orders only; reserve catalog UPDATE/DELETE for a manager role. |
| G04-F2 | Schema (Activity 3) | order_ticket has no order status. Every row is treated as a finished sale, so staff cannot track pending or preparing orders or record a cancellation without deleting the row. | database/01_create_tables.sql and schema.sql: order_ticket has only order_id, staff_id, order_timestamp, payment_method. entity/OrderTicket.java maps the same four columns. | Medium | Add an order_status column with a CHECK constraint (PENDING, PREPARING, COMPLETED, CANCELLED); default existing rows to COMPLETED. |
| G04-F3 | Setup / documentation (Activities 3 and 4) | Setup documentation does not match the SQL scripts. docs/user-roles.md documents app_runtime_grp, app_readonly_grp, app_admin_grp and the login brewpos_auditor, but 05_create_app_role.sql creates only brewpos_app. | database/05_create_app_role.sql (only CREATE ROLE brewpos_app); docs/user-roles.md sections 4.1 and 4.3; query pg_roles after setup. | Medium | Make the role script create every documented role idempotently, or correct the documentation to match. |
| G04-F4 | Maintenance / seed data (Activities 3 and 5) | The sample-data scripts identify products by item_name alone, although the schema allows the same name in different categories (UNIQUE on category_id, item_name). Duplicate names would cause wrong matches or primary key collisions. Current seed names are unique, so this is a latent defect that appears once a duplicate name is added. | database/seed.sql lines 92-133 and database/04_sample_orders.sql lines 32-61 (JOIN menu_item m ON m.item_name = ...); uq_menu_item_category_name in schema.sql. | Medium (latent) | Join through menu_category on category_name and item_name in every seed and sample-order insert. |
| G04-F5 | Financial schema / recovery (Activities 3 and 6) | Payment is a single CASH or ONLINE string on order_ticket. There is no table for reference numbers, tender and change amounts, payment status or split payments. | database/01_create_tables.sql: chk_order_ticket_payment CHECK (payment_method IN ('CASH','ONLINE')); no payment table in the five-table design. | High | Add a payment_transaction table (FK to order_ticket, CHECK constraints) and backfill historical orders. |

*Evidence figures (code screenshots in the PDF, not reproduced here):*

- **Figure 1.** G04-F1: database/05_create_app_role.sql lines 57-76. brewpos_app is granted INSERT, UPDATE and DELETE on menu_category and menu_item.
- **Figure 2.** G04-F2 and G04-F5: database/01_create_tables.sql lines 42-51. order_ticket has no status column, and payment is a single CASH/ONLINE string.
- **Figure 3.** G04-F3: database/05_create_app_role.sql lines 16-35. Only brewpos_app is created.
- **Figure 4.** G04-F3: docs/user-roles.md lines 62-66 and 97-101. The documentation creates app_runtime_grp and brewpos_auditor (the password shown is a placeholder).
- **Figure 5.** G04-F4: database/seed.sql lines 88-94 and database/04_sample_orders.sql lines 28-33. Items are joined on item_name only.
- **Figure 6.** G04-F4: database/schema.sql. The unique key is (category_id, item_name), so the same name can exist in two categories.

### Part B – Incident Scenario Design (Designer Group)

Five scenarios were designed, one per flaw, so each is traceable to evidence. They cover a privilege problem (INC1), objects and configuration problems (INC2, INC3), a maintenance and data-integrity problem (INC4), and a financial audit and recovery problem (INC5). Difficulty is balanced as two easy, two medium, and one hard. The briefs describe symptoms only and do not reveal the cause.

| Incident ID | Flaw ID | Variant and activity area | Difficulty and time | Incident brief (symptoms only) |
|---|---|---|---|---|
| G04-INC1 | G04-F1 | Privileges (Activity 4) | Medium, about 45 min | A user reported that certain functions were accessible even when they should have been restricted to a different user role. |
| G04-INC2 | G04-F2 | Objects / schema (Activity 3) | Easy, about 30 min | Staff members were unable to determine whether an order was still being processed, already completed, or cancelled. |
| G04-INC3 | G04-F3 | Configuration / setup (Activities 3 and 4) | Easy, about 30 min | During database setup, the expected user accounts and permissions were not available, preventing the setup process from matching the documented configuration. |
| G04-INC4 | G04-F4 | Maintenance / seed integrity (Activity 5) | Medium, about 45 min | After sample data was inserted, some orders displayed menu items that did not match the expected products or categories. |
| G04-INC5 | G04-F5 | Financial audit / recovery (Activities 3 and 6) | Hard, about 60 min | Staff members were unable to retrieve complete payment information for certain orders, including the payment method used. |

**Reasons for the choices**

- INC1 / F1: the documented roles (Cashier, Manager, Auditor) are not enforced by the database, which is the central access-control topic of Activity 4.
- INC2 / F2: a schema gap that staff notice in daily use; easy to find by inspecting the table columns.
- INC3 / F3: a plain mismatch between documentation and scripts; easy to find by comparing pg_roles with docs/user-roles.md.
- INC4 / F4: needs the investigator to compare the unique constraint with the seeder joins and to reproduce the failure with a duplicate name; medium difficulty.
- INC5 / F5: needs a new table, constraints, and a safe data migration that keeps historical totals; hard difficulty.

### Part C – Incident Investigation (Owner Group)

Part C and Part D record the investigation of the five incidents on a disposable copy, following the eight steps. Facts come from the repository files shown in the figures; test results are the expected outcomes and must be confirmed on the disposable copy.

#### G04-INC1

| Step | Finding |
|---|---|
| Observe (Symptoms & Brief) | Users could access functions outside their assigned role. Brief: a user reported that certain functions were accessible even when they should have been restricted to a different user role. |
| Verify | Reviewed role permissions and grants. In 05_create_app_role.sql, brewpos_app holds INSERT, UPDATE and DELETE on menu_category and menu_item (Figure 1); docs/user-roles.md says a cashier cannot change prices. |
| Hypothesize | Excessive privileges on one runtime account (best supported). Alternative: a front-end access-control problem. |
| Test | Query role_table_grants for brewpos_app; attempt UPDATE menu_item SET price as a cashier-type login on the disposable copy. |
| Act | Create app_cashier_grp (SELECT on menu and staff, INSERT on order tables) and app_admin_grp (catalog write); grant them to separate logins with INHERIT. |
| Verify Again | Cashier UPDATE and DELETE on menu tables fail with permission denied; cashier order insert works; manager catalog update works. |
| Document | Record the grants listing, role changes, and test results. |
| Prevent | Run the app on least-privilege logins (not postgres); review privileges every release. |

#### G04-INC2

| Step | Finding |
|---|---|
| Observe (Symptoms & Brief) | Staff could not tell whether orders were pending, completed, or cancelled. Brief: staff members were unable to determine whether an order was still being processed, already completed, or cancelled. |
| Verify | Inspected order_ticket. It has only order_id, staff_id, order_timestamp, payment_method (Figure 2); OrderTicket.java maps the same four columns; brewpos_app has no UPDATE or DELETE on order_ticket. |
| Hypothesize | Missing order_status attribute (best supported). Alternative: staff delete cancelled orders (not possible without DELETE rights). |
| Test | List columns from information_schema.columns; count existing rows; check which sales queries read order_ticket. |
| Act | ALTER TABLE order_ticket ADD COLUMN order_status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED'; add CHECK for PENDING, PREPARING, COMPLETED, CANCELLED; grant UPDATE (order_status) only to the role that advances status. |
| Verify Again | All four statuses insert; an invalid value such as SHIPPED is rejected; historical rows stay COMPLETED with unchanged row count and totals. |
| Document | Record the schema change and validation tests. |
| Prevent | Add status to the entity, filter sales reports on COMPLETED, and include workflow states in future designs. |

#### G04-INC3

| Step | Finding |
|---|---|
| Observe (Symptoms & Brief) | Database setup did not match the documentation. Brief: during setup, the expected user accounts and permissions were not available. |
| Verify | Compared the scripts with docs/user-roles.md. 05_create_app_role.sql creates only brewpos_app (Figure 3); the documentation lists app_runtime_grp, app_readonly_grp, app_admin_grp and brewpos_auditor (Figure 4). |
| Hypothesize | The script never implemented the documented roles (best supported). Alternative: a cleanup dropped them (ruled out, since the script has no CREATE ROLE for them). |
| Test | Query pg_roles after running the setup scripts and compare with the documentation; try to log in as brewpos_auditor. |
| Act | Extend the role script, idempotently, to create every documented group role and the auditor login with default_transaction_read_only, and grant memberships; set passwords with psql \password. |
| Verify Again | pg_roles lists all documented roles; auditor can SELECT on all five tables; auditor INSERT INTO staff fails; running the script twice causes no error. |
| Document | Record the script revision and verification output. |
| Prevent | Keep setup scripts and documentation in step; check roles against the documentation in CI. |

#### G04-INC4

| Step | Finding |
|---|---|
| Observe (Symptoms & Brief) | Orders showed menu items that did not match the expected products or categories after sample data was inserted. |
| Verify | Reviewed seed.sql and 04_sample_orders.sql. They join menu_item on item_name alone (Figure 5), while the schema's unique key is (category_id, item_name) (Figure 6). Current seed names are unique, so the fault appears only when a duplicate name exists. |
| Hypothesize | The join ignores the category part of the unique key (best supported). Alternative: primary key out of sync (ruled out; order_line_item uses the composite key (order_id, item_id)). |
| Test | Add a duplicate 'Americano' in Non-Coffee on the copy, run the old join, and count the rows returned. |
| Act | Join through menu_category on category_name and item_name in every seed and sample-order insert. |
| Verify Again | With the duplicate present each line matches one item and re-running the seeder gives no duplicate key error; the old join still returns two rows. |
| Document | Record the script changes and test outcomes. |
| Prevent | Add a seed test containing duplicate names; require category-qualified lookups. |

#### G04-INC5

| Step | Finding |
|---|---|
| Observe (Symptoms & Brief) | Payment information was incomplete. Brief: staff members were unable to retrieve complete payment information for certain orders, including the payment method used. |
| Verify | Reviewed the payment structure. Payment is one string with CHECK (payment_method IN ('CASH','ONLINE')) on order_ticket (Figure 2); the five-table design has no payment table. |
| Hypothesize | No dedicated payment records (best supported). Alternative: add more columns to order_ticket (ruled out; it cannot hold several payments per order). |
| Test | Compute order totals with SUM(quantity * sold_price); count orders and payments. |
| Act | Create payment_transaction (FK to order_ticket; CHECK on amount, method, status); back-fill one row per order; keep order_ticket.payment_method until the app is updated; grant INSERT to the cashier role. |
| Verify Again | Every order's payments equal its line-item total; a split payment (cash plus online) is accepted; a negative amount and method CRYPTO are rejected. |
| Document | Record the schema change and migration results. |
| Prevent | Map the table in the Java layer and add a payments-versus-line-totals reconciliation. |

### Part D – Troubleshooting Plan and Corrective Action (Owner Group)

#### G04-INC1

| Item | Details |
|---|---|
| Troubleshooting Plan | Review roles and grants, then test the restricted function. Risk: breaking the app if it uses a cashier login on menu screens. Rollback: re-grant the old privileges or restore the copy. Account: owner account of the disposable copy; no superuser used to make a test pass. |
| Root Cause | The application role had excessive permissions (no separation between register and catalog). |
| Alternative Cause Considered | Front-end issue. Ruled out because the database itself allows the change. |
| Corrective Action | Create the cashier and manager group roles and logins; do not give catalog write to the cashier path. |
| Verification | Should succeed: cashier SELECT menu_item, INSERT order. Should fail: cashier UPDATE menu_item price and DELETE FROM menu_category (permission denied). |
| Recommendation | Review privileges every quarter; use separate connections for register and manager. |

#### G04-INC2

| Item | Details |
|---|---|
| Troubleshooting Plan | Inspect the table, the row count and the queries. Risk: a NOT NULL column without a default fails on existing rows; a PENDING default would leave every new order pending. Rollback: DROP COLUMN order_status. |
| Root Cause | order_ticket has no lifecycle status column. |
| Alternative Cause Considered | Interface display problem. Ruled out because no status data exists in the database. |
| Corrective Action | Add order_status with default COMPLETED and a CHECK constraint. |
| Verification | Should succeed: all four statuses insert; totals unchanged. Should fail: status SHIPPED (check violation). |
| Recommendation | Add status to the entity; filter reports on COMPLETED. |

#### G04-INC3

| Item | Details |
|---|---|
| Troubleshooting Plan | Read the script, query pg_roles, compare with the documentation. Risk: roles are cluster-wide, so test on a separate test cluster. Rollback: DROP the new roles and revoke their grants. |
| Root Cause | The setup script omitted the documented roles and the auditor login. |
| Alternative Cause Considered | Credential mismatch. Ruled out because the roles are absent from pg_roles. |
| Corrective Action | Update the role script to create the documented roles idempotently; set passwords with psql \password. |
| Verification | Should succeed: all roles exist; auditor SELECT works; brewpos_app still works. Should fail: auditor INSERT INTO staff (read-only and permission denied); script run twice must not error. |
| Recommendation | Automate a check of roles against the documentation. |

#### G04-INC4

| Item | Details |
|---|---|
| Troubleshooting Plan | Analyze the seeding logic and the duplicate-name case. Risk: none to data if run on the copy. Rollback: delete the test item and test orders, or restore the copy. |
| Root Cause | The seed queries match items by name only. |
| Alternative Cause Considered | Data-entry error. Ruled out by a repeatable test. |
| Corrective Action | Update every join to include the category. |
| Verification | Should succeed: each line maps to one item; no key error on re-run. Should fail (shows the cause): the old join returns two rows for the duplicate name. |
| Recommendation | Add automated seed-data validation tests. |

#### G04-INC5

| Item | Details |
|---|---|
| Troubleshooting Plan | Review the schema and the order totals. Risk: dropping order_ticket.payment_method would break the running app, so it stays. Rollback: DROP TABLE payment_transaction or restore from the Activity 6 backup and compare row counts. |
| Root Cause | There is no dedicated payment transaction table. |
| Alternative Cause Considered | Reporting bug. Ruled out because the data was never stored. |
| Corrective Action | Create payment_transaction with constraints, back-fill history, and grant privileges. |
| Verification | Should succeed: payments equal line totals; split payment accepted. Should fail: negative amount; method CRYPTO; cashier UPDATE or DELETE on payments. |
| Recommendation | Keep payment audit logs and daily reconciliation checks. |

### Part E – Designer Review (Designer Group)

| Incident ID | Owner's reported fix | Notes (what the repository shows) | Designer verdict |
|---|---|---|---|
| G04-INC1 | Created app_cashier_grp, app_admin_grp, brewpos_cashier, brewpos_manager (fix_inc01_rbac_hardening.sql). Showed a permission-denied error for a cashier price update. | Script is present and the cashier/admin split is correct. However, step 7 of the same script re-grants UPDATE and DELETE on menu_category and menu_item to app_runtime_grp, so brewpos_app (the account the app is documented to use) still changes prices. application.properties defaults DB_USERNAME to postgres, so the app never connects as brewpos_cashier (Figure 7). 05_create_app_role.sql is unchanged. | Partly solved |
| G04-INC2 | Added order_status with CHECK and default COMPLETED, then default PENDING (fix_inc02_order_status_schema.sql). | Script is present and correct for the database. The base DDL (01_create_tables.sql, schema.sql) and the Java entity OrderTicket.java were not changed (Figure 8), and the application cannot move an order from PENDING onward because brewpos_app has no UPDATE on order_ticket. New orders inserted by the app would stay PENDING; the sales queries do not filter on status. | Solved in the database, not integrated |
| G04-INC3 | Idempotent creation of group roles and brewpos_auditor with read-only default (fix_inc03_align_rbac_ddl.sql). | Script is present and idempotent. database/05_create_app_role.sql, which the flaw is about, is unchanged and still creates only brewpos_app (Figure 3), so a fresh setup still fails to match the documentation. The script runs GRANT CONNECT and ALTER ROLE ... IN DATABASE against grp_brewposdb (the production name) even though it is described as run on the sandbox (Figure 9). No auditor password step is included. | Solved as an extra script, not in the setup path |
| G04-INC4 | Category-aware join through menu_category (fix_inc04_seeder_product_lookup.sql). Report states that re-running seed.sql completes cleanly. | The fix script only inserts one new demonstration order (Figure 10). seed.sql (lines 92-133) and 04_sample_orders.sql (lines 32-61) still join on item_name alone (Figure 5), so the flaw remains in the files that actually seed data. | Not solved in the repository |
| G04-INC5 | Created payment_transaction with FK, CHECK constraints, indexes, historical backfill and grants (fix_inc05_payment_transaction_schema.sql). Tested split payment and rejected negative or unsupported tender. | Strongest fix. Table, constraints and backfill are present. Gaps: the table is not in 01_create_tables.sql or schema.sql, there is no Java entity or service writing to it, INSERT is granted to app_runtime_grp only (the cashier role from INC1 cannot record a payment; Figure 11), and nothing enforces that payments add up to the order total. The migration reference text in the script (MIGRATED-ORDER-) differs from the report (LEGACY-MIGRATION-ORDER-). | Solved as intended at schema level; integration pending |

| Owner claim | In repository? | Note |
|---|---|---|
| Group roles and brewpos_auditor created idempotently | Script only | fix_inc03 and fix_inc01 exist; 05_create_app_role.sql unchanged. |
| Cashier cannot update menu prices | Script only | Holds for brewpos_cashier; brewpos_app keeps UPDATE and DELETE through app_runtime_grp. |
| order_status column with CHECK constraint | Script only | Not in 01_create_tables.sql, schema.sql, or OrderTicket.java. |
| Seeder refactored to category-aware join | No | seed.sql and 04_sample_orders.sql still join on item_name only. |
| payment_transaction table with backfill | Script only | Not in base DDL; no Java mapping. |
| Verification suite covering all five fixes | Yes | midterm/owner-investigation/scripts/verify_all_fixes.sql (142 lines). |

*Evidence figures (code screenshots in the PDF, not reproduced here):*

- **Figure 7.** G04-INC1: fix_inc01_rbac_hardening.sql lines 53-57 re-grants catalog write to app_runtime_grp; application.properties lines 7-9 default the application login to postgres.
- **Figure 8.** G04-INC2: OrderTicket.java lines 24-40. The entity still maps only the original four columns; no order status field.
- **Figure 9.** G04-INC3: fix_inc03_align_rbac_ddl.sql lines 27-29 and 72-75 grant and alter settings against grp_brewposdb, the production database name.
- **Figure 10.** G04-INC4: fix_inc04_seeder_product_lookup.sql lines 33-50 only insert one demonstration order; seed.sql was not changed (see Figure 5).
- **Figure 11.** G04-INC5: fix_inc05_payment_transaction_schema.sql lines 78-82. INSERT on payment_transaction goes to app_runtime_grp only.

#### Feedback to Group 04

The following findings were noticed during the review and are sent to Group 04 as feedback, in priority order.

1. **Merge the fixes into the canonical files.** Update 01_create_tables.sql, schema.sql, 05_create_app_role.sql, seed.sql and 04_sample_orders.sql so that a clean setup produces the corrected design. Today the fixes exist only in midterm/owner-investigation/scripts.
2. **Patch the real seeders (INC4).** Replace every `JOIN menu_item m ON m.item_name = ...` in seed.sql and 04_sample_orders.sql with a join through menu_category on both category_name and item_name, then re-run on a database that contains a duplicate item name.
3. **Remove catalog write access from the runtime path (INC1).** Delete the re-grant of UPDATE and DELETE to app_runtime_grp, make the application connect as a least-privilege login (not postgres), and use a manager login only for catalog endpoints.
4. **Keep the sandbox scripts off the production database name (INC3).** Parameterize or remove GRANT CONNECT ... grp_brewposdb and ALTER ROLE ... IN DATABASE grp_brewposdb. Roles are cluster-wide, so creating them from a sandbox script also affects the production cluster; this contradicts the report's "zero production risk" statement.
5. **Check role inheritance.** The login roles are created with NOINHERIT and then granted group roles. In PostgreSQL 16 and later the inherit option of a GRANT follows the member role's setting, so those logins may need SET ROLE before the group privileges apply. Confirm with pg_auth_members (inherit_option) and test a real login as brewpos_cashier and brewpos_auditor, not only SET ROLE.
6. **Set auditor and manager credentials securely.** The fix scripts create login roles without passwords. Use psql \password and do not commit credentials.
7. **Make the order-status feature usable (INC2).** Add orderStatus to OrderTicket.java, grant UPDATE (order_status) only to the roles that need it, set the register default deliberately, and filter sales reports on COMPLETED.
8. **Wire up payment_transaction (INC5).** Add the entity and service, grant INSERT to the cashier role, and add a reconciliation check (payments total equals line-item total).
9. **Fix report consistency.** The report and scripts use IDs G01-INC1 to G01-INC5 and "Designer Group: Group 1", while the assessment pairing is Group 10 and the incident IDs are G04-INC1 to G04-INC5. Links in the report point to a local C:\ path and will not open for reviewers. The claim of a findByPaymentMethod query in the JPA layer is not supported by the repository. Duplicate copies of the report exist in midterm/ and midterm/owner-investigation/.

### Part F – Technical Defense

| Question | Answer |
|---|---|
| Why can the cashier change prices in the original design? | brewpos_app holds UPDATE and DELETE on menu_category and menu_item (05_create_app_role.sql section 4) and no separate cashier role exists; the interface only hides the buttons. |
| Why is a SET ROLE test not enough? | SET ROLE proves what a role is allowed to do, not what a real login inherits. Logins created NOINHERIT may not receive their group privileges automatically, so test by connecting as the login. |
| Why default order_status to COMPLETED and not PENDING? | The register treats every sale as complete and the application has no UPDATE on order_ticket, so a PENDING default would leave every new order pending and unfixable. |
| What does the CHECK constraint on order_status do? | It makes the database reject any value other than PENDING, PREPARING, COMPLETED, or CANCELLED, so bad statuses cannot enter even from outside the app. |
| Why is the seeder join wrong? | uq_menu_item_category_name is UNIQUE (category_id, item_name), so item_name alone can match several rows; the join must also use the category. |
| Why a separate payment_transaction table? | One order can have several payments, each with a method, amount, reference, and status; a single string on order_ticket cannot store that. |
| Why keep order_ticket.payment_method? | The application still reads it; dropping it would break the running system before the code is updated. |
| How do you roll back each fix? | Revoke the added grants (INC1), drop the added column or constraint (INC2), drop the new roles (INC3), delete the test rows (INC4), drop payment_transaction (INC5), or restore the disposable copy from the Activity 6 backup. |
| How do you prove a fix did not break anything? | Compare row counts and totals before and after, run the tests that should succeed, and run the tests that should fail (permission denied or check violation). |

### Part G – Repository, Tracker, and Progress Documentation

As in Activities 3 to 6, there is no centralized repository. Each group keeps its midterm work in its own project repository and records its status in the class Google Sheets tracker. The group then submits a PDF report that documents all of its progress.

#### STEP 1 - Work kept in the group's own repository

| Item | Status and location |
|---|---|
| midterm/ folder with designer and owner subfolders | Prepared in midterm_folder_for_repository.zip: midterm/designer/ (flaw-review.md, incident-design-sheets-public.md, scripts-notes/procedure-notes.md) and midterm/owner/ (README for the investigation of our own project). |
| Public design sheets only | Yes. The designer folder holds only the public rows until the defense is complete. |
| Private answer key and fault and reset scripts | Kept out of the repository; submitted to the instructor in PRIVATE_instructor_package.zip. |
| Passwords, secrets, and data backups | None included. Auditor and manager passwords are set with psql \password and never written in a script. |
| Commits | Use meaningful commits, for example: add flaw review; add public design sheets; add procedure notes; add designer review. Every member makes at least one commit. |
| Other groups' repositories | Not changed. The Group 04 repository was only read, and findings are sent as feedback (Part E). |

#### STEP 2 - Tracker rows (Flaw Register and Incident Register)

| Flaw ID | Reported by | Area and activity | Severity | Owner status |
|---|---|---|---|---|
| G04-F1 – BrewPOS (Group 04) | G10 | Privileges (Activity 4) | High | Acknowledged (Group 04 reported Fixed; see Part E) |
| G04-F2 – BrewPOS (Group 04) | G10 | Schema (Activity 3) | Medium | Acknowledged (Group 04 reported Fixed; see Part E) |
| G04-F3 – BrewPOS (Group 04) | G10 | Setup / documentation (Activities 3 and 4) | Medium | Acknowledged (Group 04 reported Fixed; see Part E) |
| G04-F4 – BrewPOS (Group 04) | G10 | Maintenance / seed data (Activities 3 and 5) | Medium (latent) | Acknowledged (Group 04 reported Fixed; see Part E) |
| G04-F5 – BrewPOS (Group 04) | G10 | Financial schema / recovery (Activities 3 and 6) | High | Acknowledged (Group 04 reported Fixed; see Part E) |

| Incident ID | Project and designer | Variant and activity area | Status | Owner result |
|---|---|---|---|---|
| G04-INC1 / G04-F1 | BrewPOS (Group 04); Group 10 | Privileges – Activity 4 (users, roles, and access control) | Reviewed | Entered by Group 04 |
| G04-INC2 / G04-F2 | BrewPOS (Group 04); Group 10 | Objects / schema – Activity 3 (database design and integrity) | Reviewed | Entered by Group 04 |
| G04-INC3 / G04-F3 | BrewPOS (Group 04); Group 10 | Configuration / setup – Activities 3 and 4 | Reviewed | Entered by Group 04 |
| G04-INC4 / G04-F4 | BrewPOS (Group 04); Group 10 | Maintenance / seed data integrity – Activity 5 | Reviewed | Entered by Group 04 |
| G04-INC5 / G04-F5 | BrewPOS (Group 04); Group 10 | Financial audit / recovery – Activities 3 and 6 | Reviewed | Entered by Group 04 |

#### STEP 3 - PDF report sections (checklist)

| Required section | Where in this report |
|---|---|
| Executive summary and links | Executive summary at the start of the report |
| Flaw review | Part A |
| Incident designs | Part B (public parts of the five design sheets) |
| Investigation per incident | Part C |
| Troubleshooting plans and fixes | Part D |
| Verification | Part D (Verification column) |
| Prevention and escalation | Part C (Prevent) and Part D (Recommendation) |
| Designer review | Part E |
| Feedback to owners | Part E (Feedback to Owners) |
| Contribution record | Part G, below |
| AI usage declaration | Part G, below |

#### Contribution Record

| Member | Responsibility (designer role) |
|---|---|
| SANDOVAL | Flaw review of access control and roles (F1, F3); design sheets INC1 and INC3 |
| CALLOS | Flaw review of schema (F2, F5); design sheets INC2 and INC5 |
| ROMINGQUIT | Flaw review of seed data (F4); design sheet INC4; fault and reset scripts |
| TAMBIO | Evidence collection and code excerpts; tracker rows; repository commits |
| TUNGOL | Report writing; designer review of the owner results; feedback to owners |

#### AI Usage Declaration

- Tool used: ChatGpt
- What it generated or suggested: the structure and wording of this report, the comparison table in Part E, and the draft feedback items.
- How it was validated: every claim about the owner's repository was checked against the named file and line range in brewpos-main.zip (05_create_app_role.sql, 01_create_tables.sql, seed.sql, 04_sample_orders.sql, docs/user-roles.md, application.properties, OrderTicket.java, and the five fix scripts). The inheritance and production-grant points are marked as risks to confirm.
- Not done by the AI: running SQL on PostgreSQL. The group executed the checks on its own disposable copy and confirmed or corrected the marked items before the technical defense was given.
- No passwords or secrets appear in this report.
