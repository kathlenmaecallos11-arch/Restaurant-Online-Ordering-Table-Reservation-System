# ACTIVITY 5

# Database Maintenance and Monitoring

*Monitoring Database Health, Maintaining Reliability, and Analyzing Performance*

## Group Information

- **Group Number:** G10
- **Group Members:**
  - Sandoval, Cellyn S.
  - Callos, Kathlen Mae L.
  - Romingquit, Arika E.
  - Tambio, Jenny Mae N.
  - Tungol, Jaimie N.
  - Gordonas, John Benedick

## Project Monitored

- **Group Number:** G02
- **Group Project:** Park It: Smart Parking System
- **PostgreSQL Version:** 18.6
- **Inspection Environment:** Local Database Replica
- **Repository Link:** [Park It: Smart Parking System](https://github.com/millerdevera6-glitch/park-it-database/tree/main)

## Introduction

This activity focuses on monitoring and maintaining the PostgreSQL database of G02's Park It system. The inspection covered database health, user activity, PostgreSQL logs, table maintenance, and query performance.

The inspection was conducted using a local database replica created from the provided Park It project files. The Group 2 live database was not accessed.

## 1. Health and Activity Evidence

The local database was available during the inspection.

- **Database Size:** 8,526 kB
- **Total Public Tables:** 5
- **Total Public Sequences:** 5
- **Database Indexes:** 9
- **Validated Constraints:** 36
- **Connected Sessions:** 2 during inspection

The two observed sessions belonged to the **postgres** account and used the **psql** application. One session was active and one was idle.

Only the **postgres** role was found with login permission in the local database. The proposed Park It roles **parkit_app**, **parkit_report**, and **parkit_dba** were not found in the inspected replica.

## 2. Log Review

The log review showed normal checkpoint activities and a database shutdown event. No confirmed critical database failure was identified during the review. Client disconnection messages were also recorded, but their cause could not be confirmed.

## 3. Database Maintenance

The five public tables, their sizes, and their maintenance statistics were inspected.

All five tables had zero estimated dead rows during the initial health inspection. Each table had one recorded manual VACUUM and one manual ANALYZE operation.

Autovacuum was enabled, but no automatic vacuum or auto-analyze operations were recorded for the inspected tables.

No immediate maintenance issue was found in the local database during the inspection.

## 4. Query Performance Analysis

Three sample queries were inspected using PostgreSQL's **EXPLAIN** command.

PostgreSQL selected Sequential Scans for all three queries:

- Parking zone lookup using **zone_name**.
- Vehicle lookup using **license_plate**.
- Transaction lookup using **vehicle_id**.

All nine existing indexes showed zero recorded scans during the inspected workload.

The **pg_stat_statements** extension was available but was not installed in the database. Actual query execution time was not measured because **EXPLAIN ANALYZE** was not used.

Since the local database contained very little data, these results do not indicate poor query performance.

## 5. Recommendations

1. Keep autovacuum enabled and continue monitoring table statistics.
2. Review authentication failures and monitor repeated client disconnections.
3. Monitor index usage as more records are added.
4. Consider enabling **pg_stat_statements** if detailed query monitoring is needed and approved.
5. Perform future query performance tests using a larger and more realistic dataset.
6. Verify the proposed application roles and permissions in an authorized test environment.

## 6. Conclusion

The local Park It database was available during the inspection. Its tables, indexes, and constraints were present, and no immediate maintenance issue was found.

The log review showed normal checkpoint activities and a database shutdown event. No confirmed critical database failure was identified during the review. Client disconnection messages were also recorded, but their cause could not be confirmed. Query performance checks showed Sequential Scans for the selected sample queries.

Overall, the activity provided a record of the local database's condition and identified areas for future monitoring and improvement. The findings apply only to the local replica and do not confirm the condition of G02's live database.

## 7. Evidence

Screenshots and supporting files are organized in the following folders:

- `evidence/health-inspection/` – 9 screenshots
- `evidence/log-review/` – 4 screenshots
- `evidence/maintenance/` – 4 screenshots
- `evidence/query-performance/` – 7 screenshots

### Supporting Documentation

- `health-inspection.md`
- `log-review.md`
- `maintenance.md`
- `query-performance.md`
- `report.md`
