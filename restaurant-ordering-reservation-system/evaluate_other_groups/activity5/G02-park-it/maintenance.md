# Database Maintenance Inspection – Group 2 Park It

## 1. Maintenance Overview

The database maintenance settings and table statistics were inspected using PostgreSQL monitoring views.

- **Database Name:** grp_parkitdb_monitoring
- **PostgreSQL Version:** 18.6
- **Total Public Tables:** 5
- **Autovacuum:** Enabled

## 2. Table Sizes

The five tables have small storage sizes:

- **parking_zone:** 72 kB
- **payment:** 16 kB
- **staff_user:** 16 kB
- **transaction:** 8192 bytes
- **vehicle:** 16 kB

## 3. Vacuum and Analyze Statistics

The inspection showed that all five tables had zero estimated dead rows.

Each table also had one recorded manual vacuum and one manual analyze operation.

No automatic vacuum or auto-analyze operations were recorded in the inspected statistics.

## 4. Autovacuum Configuration

The autovacuum feature was enabled.

The inspected settings were:

- **Vacuum Threshold:** 50
- **Analyze Threshold:** 50
- **Vacuum Scale Factor:** 0.2
- **Analyze Scale Factor:** 0.1

These settings control when PostgreSQL considers tables for automatic vacuum and analyze operations.

## 5. Maintenance Assessment

The local database had no obvious immediate maintenance issue during inspection. All five tables had zero estimated dead rows, and no changes were pending analysis.

The tables were also small, so regular monitoring is still recommended as the database grows.

## 6. Recommendations

- Keep autovacuum enabled.
- Continue checking dead row counts and table sizes.
- Monitor vacuum and analyze activity.
- Review maintenance statistics regularly as more data is added.
- Perform manual maintenance only when needed and through an authorized database account.

## 7. Conclusion

The maintenance inspection showed that autovacuum was enabled and all five tables had recorded manual vacuum and analyze operations. No dead rows or pending changes for analysis were reported. The local database appeared to have no immediate maintenance issue during the inspection.
