# Database Health Inspection – Group 2 Park It

## 1. Database Information

- **Database Name:** grp_parkitdb_monitoring
- **PostgreSQL Version:** 18.6
- **Database Size:** 8,526 kB
- **Total Public Tables:** 5
- **Total Public Sequences:** 5
- **Connected Account During Inspection:** postgres

## 2. Database Tables

The database contains five public tables:

1. parking_zone
2. payment
3. staff_user
4. transaction
5. vehicle

All five tables are owned by the **postgres** account.

## 3. Table Health and Statistics

The inspection showed that **parking_zone** had one estimated live row, while the other four tables had zero estimated live rows.

All five tables showed zero estimated dead rows during the health inspection. Their recorded table sizes were small, ranging from 8 KB to 72 KB.

The database also had nine indexes and 36 constraints. All inspected constraints were validated, including the three foreign key constraints.

## 4. Connection and Database Status

The database accepted connections during the inspection. Two PostgreSQL sessions were observed: one active and one idle.

Both sessions belonged to the postgres account and used the psql application. The active query shown during inspection was a monitoring query, not a confirmed Park It application query.

## 5. Database Roles and Accounts

Only the **postgres** role was found with login permission in the local database replica.

The proposed Park It roles **parkit_app**, **parkit_report**, and **parkit_dba** were not found in the inspected local database.

These roles were identified during the earlier review of the project files, but their actual login and permissions were not tested in this replica.

## 6. Overall Health Assessment

The local Park It database was available during the inspection. It contained five public tables, five sequences, nine indexes, and 36 validated constraints.

No dead rows were recorded in the initial table statistics. The database was small and had only limited data, so these results describe the local replica only and do not represent the actual condition or performance of G02’s live database.
