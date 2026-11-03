-- 04_privilege_tests.sql  (Activity 4, Part E) -- GENERIC allowed/denied matrix.
-- Every statement runs as one group role inside a sub-transaction that is ALWAYS rolled back,
-- so no data is changed. Run as the administrator, connected to the project database:
--   psql -h localhost -U postgres -d <PROJECT_DB> -v prefix=g03 -v schema=public `
--        -v read_table=orders -v write_table=orders [-v sensitive_table=users] -f 04_privilege_tests.sql
-- read_table      a table every role may read
-- write_table     a table the application writes to
-- sensitive_table (optional) a credential table the read-only role must NOT read (expected DENIED)
-- Add project-specific rows to the INSERT below (copy a line and change table / role / expected result).

\set ON_ERROR_STOP off
\pset pager off
\if :{?schema}
\else
  \set schema public
\endif
\set grp_runtime  :prefix _runtime_grp
\set grp_readonly :prefix _readonly_grp
\set grp_maint    :prefix _maint_grp
\set grp_backup   :prefix _backup_grp

SELECT column_name AS first_col FROM information_schema.columns
WHERE table_schema = :'schema' AND table_name = :'write_table' ORDER BY ordinal_position LIMIT 1
\gset

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
    id serial PRIMARY KEY, account text, statement text, expected text, actual text, result text
);

INSERT INTO access_tests (account, statement, expected) VALUES
 (:'grp_runtime',  format('SELECT * FROM %I.%I LIMIT 1', :'schema', :'read_table'),                                         'ALLOWED'),
 (:'grp_runtime',  format('INSERT INTO %1$I.%2$I SELECT * FROM %1$I.%2$I WHERE false', :'schema', :'write_table'),        'ALLOWED'),
 (:'grp_runtime',  format('UPDATE %1$I.%2$I SET %3$I = %3$I WHERE false', :'schema', :'write_table', :'first_col'),         'ALLOWED'),
 (:'grp_runtime',  format('CREATE TABLE %I.should_fail (id int)', :'schema'),                                              'DENIED'),
 (:'grp_runtime',  format('DROP TABLE %I.%I', :'schema', :'write_table'),                                                  'DENIED'),
 (:'grp_runtime',  format('TRUNCATE %I.%I', :'schema', :'write_table'),                                                    'DENIED'),
 (:'grp_readonly', format('SELECT * FROM %I.%I LIMIT 1', :'schema', :'read_table'),                                         'ALLOWED'),
 (:'grp_readonly', format('INSERT INTO %1$I.%2$I SELECT * FROM %1$I.%2$I WHERE false', :'schema', :'write_table'),        'DENIED'),
 (:'grp_readonly', format('UPDATE %1$I.%2$I SET %3$I = %3$I WHERE false', :'schema', :'write_table', :'first_col'),         'DENIED'),
 (:'grp_readonly', format('DELETE FROM %I.%I WHERE false', :'schema', :'write_table'),                                      'DENIED'),
 (:'grp_readonly', format('CREATE TABLE %I.should_fail (id int)', :'schema'),                                              'DENIED'),
 (:'grp_backup',   format('SELECT * FROM %I.%I LIMIT 1', :'schema', :'write_table'),                                       'ALLOWED'),
 (:'grp_backup',   format('DELETE FROM %I.%I WHERE false', :'schema', :'write_table'),                                      'DENIED'),
 (:'grp_maint',    format('SELECT * FROM %I.%I LIMIT 1', :'schema', :'write_table'),                                       'DENIED'),
 (:'grp_maint',    format('DELETE FROM %I.%I WHERE false', :'schema', :'write_table'),                                      'DENIED');

\if :{?sensitive_table}
INSERT INTO access_tests (account, statement, expected) VALUES
 (:'grp_readonly', format('SELECT * FROM %I.%I LIMIT 1', :'schema', :'sensitive_table'), 'DENIED');
\endif

UPDATE access_tests SET actual = pg_temp.try_as(account, statement);
UPDATE access_tests SET result = CASE WHEN actual LIKE (expected || '%') THEN 'PASS' ELSE 'FAIL' END;

\echo '=== Permitted / denied matrix  (a FAIL means the privilege is NOT what was planned: investigate) ==='
SELECT id, account, left(statement, 80) AS statement, expected, actual, result FROM access_tests ORDER BY id;
SELECT result, COUNT(*) FROM access_tests GROUP BY result ORDER BY result;
\echo 'If something unexpected is ALLOWED check: direct grants, inherited roles, PUBLIC, ownership (05_review_privileges.sql).'
