-- 05_check_app_access.sql   (MESA-INC1: grants are lost after a database rebuild)
-- A rebuild recreates every table, so the privileges given to the application on the OLD tables are gone and
-- the app shows "Something went wrong" while /health still says OK. This script FAILS LOUDLY (non-zero exit with
-- ON_ERROR_STOP) when rors_app cannot use the tables or sequences it needs. Run as postgres on the project DB:
--   psql -h localhost -U postgres -d grp_binarysisters_projectdb -v ON_ERROR_STOP=1 -f database/roles/05_check_app_access.sql
-- Fix when it fails: psql ... -f database/roles/02_grants.sql   (it is safe to run again)
\set ON_ERROR_STOP on
DO $$
DECLARE r record; missing text := '';
BEGIN
  FOR r IN
    SELECT t.tbl, p.priv
    FROM (VALUES ('customer'),('orders'),('payment'),('menu_item'),('restaurant_table'),('reservation'),('staff'),('order_item')) AS t(tbl)
    CROSS JOIN (VALUES ('SELECT'),('INSERT')) AS p(priv)
  LOOP
    IF NOT has_table_privilege('rors_app', format('public.%I', r.tbl), r.priv) THEN
      missing := missing || format(' %s on %s;', r.priv, r.tbl);
    END IF;
  END LOOP;
  FOR r IN SELECT c.relname FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
           WHERE c.relkind = 'S' AND n.nspname = 'public' LOOP
    IF NOT has_sequence_privilege('rors_app', format('public.%I', r.relname), 'USAGE') THEN
      missing := missing || format(' USAGE on sequence %s;', r.relname);
    END IF;
  END LOOP;
  IF missing <> '' THEN
    RAISE EXCEPTION 'rors_app is missing privileges:% Re-run database/roles/02_grants.sql', missing;
  END IF;
  RAISE NOTICE 'PASS: rors_app can use all required tables and sequences';
END $$;
