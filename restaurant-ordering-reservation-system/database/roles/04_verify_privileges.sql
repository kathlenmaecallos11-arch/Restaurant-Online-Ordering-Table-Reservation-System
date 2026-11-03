-- 04_verify_privileges.sql   (Activity 4 Part E for OUR OWN database)
-- Runs a permitted/denied test matrix by impersonating each group role with SET LOCAL ROLE inside
-- a sub-transaction that is always rolled back, so the data is never changed.
-- Run as postgres, connected to the project database:
--   psql -h localhost -U postgres -d grp_binarysisters_projectdb -f database/roles/04_verify_privileges.sql
-- Use the output (or a screenshot of it) as evidence. Also repeat the key tests by logging in as the
-- real accounts (see docs/user-role-setup.md section 6) because SET ROLE cannot test CONNECT or login.

\set ON_ERROR_STOP off
\pset pager off

-- Helper: runs one statement as one role and reports ALLOWED / DENIED / ERROR, then rolls back.
CREATE FUNCTION pg_temp.try_as(p_role text, p_sql text) RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        EXECUTE format('SET LOCAL ROLE %I', p_role);
        EXECUTE p_sql;
        RAISE EXCEPTION '__rolled_back__' USING ERRCODE = 'P0001';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RETURN 'DENIED (insufficient_privilege)';
        WHEN OTHERS THEN
            IF SQLERRM = '__rolled_back__' THEN
                RETURN 'ALLOWED';
            END IF;
            RETURN 'ERROR ' || SQLSTATE || ': ' || SQLERRM;
    END;
END;
$$;

CREATE TEMP TABLE access_tests (
    id        serial PRIMARY KEY,
    account   text NOT NULL,
    statement text NOT NULL,
    expected  text NOT NULL,
    actual    text,
    result    text
);

INSERT INTO access_tests (account, statement, expected) VALUES
 -- application runtime ---------------------------------------------------------------
 ('rors_runtime_grp',  'SELECT * FROM menu_item LIMIT 1',                                                    'ALLOWED'),
 ('rors_runtime_grp',  $$INSERT INTO customer (first_name,last_name,email,phone,password) VALUES ('T','T','t@rors.test','0','x')$$, 'ALLOWED'),
 ('rors_runtime_grp',  'UPDATE menu_item SET price = price WHERE false',                                     'ALLOWED'),
 ('rors_runtime_grp',  'DELETE FROM orders WHERE false',                                                     'DENIED'),
 ('rors_runtime_grp',  'DELETE FROM order_item WHERE false',                                                 'DENIED'),
 ('rors_runtime_grp',  'DELETE FROM payment WHERE false',                                                    'DENIED'),
 ('rors_runtime_grp',  'CREATE TABLE public.should_fail (id int)',                                           'DENIED'),
 ('rors_runtime_grp',  'DROP TABLE public.orders',                                                           'DENIED'),
 ('rors_runtime_grp',  'TRUNCATE public.customer',                                                           'DENIED'),
 -- read-only / auditor ----------------------------------------------------------------
 ('rors_readonly_grp', 'SELECT * FROM v_order_summary LIMIT 1',                                              'ALLOWED'),
 ('rors_readonly_grp', 'SELECT * FROM menu_item LIMIT 1',                                                    'ALLOWED'),
 ('rors_readonly_grp', 'SELECT * FROM v_customer_directory LIMIT 1',                                         'ALLOWED'),
 ('rors_readonly_grp', 'UPDATE menu_item SET price = price WHERE false',                                     'DENIED'),
 ('rors_readonly_grp', 'DELETE FROM reservation WHERE false',                                                'DENIED'),
 ('rors_readonly_grp', $$INSERT INTO menu_item (item_name,category,price) VALUES ('x','x',1)$$,              'DENIED'),
 ('rors_readonly_grp', 'SELECT password FROM customer LIMIT 1',                                              'DENIED'),
 ('rors_readonly_grp', 'SELECT * FROM staff LIMIT 1',                                                        'DENIED'),
 -- maintenance (no data access) -------------------------------------------------------
 ('rors_maint_grp',    'SELECT * FROM pg_stat_activity LIMIT 1',                                             'ALLOWED'),
 ('rors_maint_grp',    'SELECT * FROM customer LIMIT 1',                                                     'DENIED'),
 ('rors_maint_grp',    'UPDATE menu_item SET price = price WHERE false',                                     'DENIED'),
 -- backup operator (read everything, change nothing) ------------------------------------
 ('rors_backup_grp',   'SELECT * FROM customer LIMIT 1',                                                     'ALLOWED'),
 ('rors_backup_grp',   'UPDATE menu_item SET price = price WHERE false',                                     'DENIED'),
 ('rors_backup_grp',   'DELETE FROM orders WHERE false',                                                     'DENIED'),
 -- administrator -------------------------------------------------------------------------
 ('rors_admin_grp',    'SELECT * FROM customer LIMIT 1',                                                     'ALLOWED'),
 ('rors_admin_grp',    'CREATE TABLE public.admin_scratch (id int)',                                         'ALLOWED'),
 ('rors_admin_grp',    'CREATE ROLE should_not_exist',                                                       'DENIED');
-- CREATE DATABASE cannot be tested inside a function; it is tested with a real login in
-- docs/user-role-setup.md (section 6).

UPDATE access_tests SET actual = pg_temp.try_as(account, statement);
UPDATE access_tests SET result = CASE WHEN actual LIKE (expected || '%') THEN 'PASS' ELSE 'FAIL' END;

\echo
\echo '=== Permitted / denied test matrix ==='
SELECT id, account, left(statement, 70) AS statement, expected, actual, result
FROM access_tests ORDER BY id;

\echo
\echo '=== Summary ==='
SELECT result, COUNT(*) FROM access_tests GROUP BY result ORDER BY result;

\echo
\echo '=== Role attributes: nobody may be superuser / createdb / createrole ==='
SELECT rolname, rolsuper, rolcreatedb, rolcreaterole, rolcanlogin, rolconnlimit
FROM pg_roles WHERE rolname LIKE 'rors\_%' ORDER BY rolcanlogin, rolname;

\echo
\echo '=== Role memberships ==='
SELECT m.rolname AS member, g.rolname AS member_of
FROM pg_auth_members am
JOIN pg_roles m ON m.oid = am.member
JOIN pg_roles g ON g.oid = am.roleid
WHERE m.rolname LIKE 'rors\_%'
ORDER BY 1, 2;

\echo
\echo '=== Table privilege matrix (effective, includes inherited privileges) ==='
SELECT t.tablename,
       string_agg(DISTINCT CASE WHEN has_table_privilege(r.rolname, format('public.%I', t.tablename), 'SELECT') THEN r.rolname || ':S' END, ' ') AS sel,
       string_agg(DISTINCT CASE WHEN has_table_privilege(r.rolname, format('public.%I', t.tablename), 'INSERT') THEN r.rolname || ':I' END, ' ') AS ins,
       string_agg(DISTINCT CASE WHEN has_table_privilege(r.rolname, format('public.%I', t.tablename), 'UPDATE') THEN r.rolname || ':U' END, ' ') AS upd,
       string_agg(DISTINCT CASE WHEN has_table_privilege(r.rolname, format('public.%I', t.tablename), 'DELETE') THEN r.rolname || ':D' END, ' ') AS del
FROM pg_tables t
CROSS JOIN (SELECT rolname FROM pg_roles WHERE rolname IN ('rors_runtime_grp','rors_readonly_grp','rors_maint_grp','rors_backup_grp')) r
WHERE t.schemaname = 'public'
GROUP BY t.tablename ORDER BY t.tablename;

\echo
\echo '=== PUBLIC privileges that remain (should be none on tables) ==='
SELECT table_name, privilege_type FROM information_schema.role_table_grants
WHERE grantee = 'PUBLIC' AND table_schema = 'public';
