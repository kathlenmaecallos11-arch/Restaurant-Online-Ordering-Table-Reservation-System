-- 04_query_plan.sql  (Activity 5, Part D) -- EDIT the query first: use a real SELECT from the application
-- (see the owner's code / user-roles documentation) and run it as the role that normally runs it.
--   psql -h localhost -U g03_report -d <DB> -f 04_query_plan.sql
\pset pager off
\echo '=== 1. Estimated plan (query is NOT executed) ==='
EXPLAIN
SELECT * FROM public.example_table WHERE example_column = 'sample_value';   -- <== replace

\echo '=== 2. Actual plan (EXECUTES the query: safe SELECT on the test database only) ==='
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM public.example_table WHERE example_column = 'sample_value';   -- <== replace

-- Interpretation checklist for report.md:
--  * scan type (Seq Scan / Index Scan / Bitmap Heap Scan) and why it is reasonable for this table size
--  * estimated rows vs actual rows (big gaps -> stale statistics -> ANALYZE)
--  * execution time, buffers hit vs read
--  * improvement idea (index, query rewrite) OR why the plan is already fine; mention write/storage cost of an index
