# Query Performance Analysis – Group 2 Park It

## 1. Selected Queries

Three sample queries were selected to inspect how PostgreSQL searches for records in the Park It database.

**Query 1 – Parking Zone**

```sql
EXPLAIN
SELECT *
FROM parking_zone
WHERE zone_name = 'Main Parking Lot';
```

**Query 2 – Vehicle**

```sql
EXPLAIN
SELECT *
FROM vehicle
WHERE license_plate = 'TEST-123';
```

**Query 3 – Transaction**

```sql
EXPLAIN
SELECT *
FROM transaction
WHERE vehicle_id = 1;
```

## 2. Query Execution Plans

PostgreSQL selected a Sequential Scan for all three queries.

- **Parking Zone:** Sequential Scan with a filter on zone_name.
- **Vehicle:** Sequential Scan with a filter on license_plate.
- **Transaction:** Sequential Scan with a filter on vehicle_id.

This means PostgreSQL chose to check the table rows directly instead of using an index for these sample queries.

## 3. Index Usage Statistics

The inspection showed that all nine existing indexes had zero recorded scans.

Sequential scans were also recorded on all five tables.

The **pg_stat_statements** extension was available but was not installed in the database. Its library was also not listed in the **shared_preload_libraries** setting.

## 4. Analysis

PostgreSQL used Sequential Scans for the three selected queries. This may be reasonable because the local database contains very few records.

All nine indexes showed zero recorded scans during the inspected workload. This does not automatically mean that the indexes are unnecessary or ineffective.

The query plans only show the estimated execution plan. Actual query execution time was not measured because **EXPLAIN ANALYZE** was not used.

## 5. Recommendations

- Monitor index usage as more records are added.
- Test query performance again using a larger and more realistic dataset.
- Consider enabling **pg_stat_statements** if detailed query monitoring is needed and approved by the database administrator.
- Review queries and indexes as the database grows.
- Use **EXPLAIN ANALYZE** during an approved performance test to measure actual execution time.

## 6. Conclusion

The query performance inspection showed that PostgreSQL selected Sequential Scans for all three sample queries. The database had nine indexes, but no index scans were recorded during the inspection. Since the local database contained very little data, these results do not indicate poor performance. Further testing with a larger dataset is recommended.
