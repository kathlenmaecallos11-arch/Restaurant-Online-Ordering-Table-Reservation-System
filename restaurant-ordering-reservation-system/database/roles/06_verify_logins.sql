-- 06_verify_logins.sql   (MESA-INC2: "has no password assigned")
-- Lists every rors_* login role that has no password. Must be run as postgres (pg_authid is superuser-only).
--   psql -h localhost -U postgres -d postgres -v ON_ERROR_STOP=1 -f database/roles/06_verify_logins.sql
-- Fix: psql -h localhost -U postgres -d postgres -f database/roles/03_set_passwords.psql
\set ON_ERROR_STOP on
SELECT rolname, (rolpassword IS NULL) AS no_password, rolconnlimit
FROM pg_authid WHERE rolcanlogin AND rolname LIKE 'rors\_%' ORDER BY rolname;
DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM pg_authid WHERE rolcanlogin AND rolname LIKE 'rors\_%' AND rolpassword IS NULL;
  IF n > 0 THEN RAISE EXCEPTION '% login role(s) have no password. Run database/roles/03_set_passwords.psql', n; END IF;
  RAISE NOTICE 'PASS: every rors_* login role has a password';
END $$;
