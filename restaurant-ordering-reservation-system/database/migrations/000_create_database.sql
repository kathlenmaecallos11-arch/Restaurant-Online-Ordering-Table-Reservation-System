-- 000_create_database.sql
-- Run while connected to the maintenance database "postgres" (NOT the project DB):
--   psql -h localhost -p 5432 -U postgres -d postgres -f database/migrations/000_create_database.sql
-- CREATE DATABASE cannot run inside a transaction or a function, so it is generated and
-- executed with \gexec only when the database does not exist yet (safe to re-run).

SELECT 'CREATE DATABASE grp_binarysisters_projectdb OWNER postgres'
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'grp_binarysisters_projectdb')
\gexec

COMMENT ON DATABASE grp_binarysisters_projectdb IS
  'Restaurant Online Ordering & Table Reservation System (Binary Sisters, COMP 018)';
