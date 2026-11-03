# Access-control plan — Group __ : <project name>

Prepared BEFORE creating any role (Activity 4 Part A/B). Source documents read: owner's README, user-roles doc, database doc.

| Item | Value |
|---|---|
| Repository / branch tested | |
| Database name / PostgreSQL version | |
| Schema(s) | |
| Prefix used for roles | g__ |
| Object owner | |
| Setup result | Success / Success with issues / Failed — note: |

## Objects found (from `00_inventory.sql`)
Tables: … · Sequences: … · Views: … · Functions/triggers: … · Sensitive columns: …

## Plan

| Login account | Group role | Application role served | Responsibility | Required privileges | Explicitly NOT allowed |
|---|---|---|---|---|---|
| g__app | g__runtime_grp | Application runtime | The account the application connects with | SELECT/INSERT/UPDATE on …; DELETE only on …; sequence USAGE | DDL, TRUNCATE, DELETE on …, any superuser attribute |
| g__report | g__readonly_grp | Viewer / auditor | Reports and inspection | SELECT on approved tables/views | write access; credential columns |
| g__maint | g__maint_grp | DBA – maintenance | VACUUM/ANALYZE, monitoring (Activity 5) | pg_monitor, pg_maintain (PG17+) | reading application data |
| g__backup | g__backup_grp | DBA – backup | pg_dump (Activity 6) | pg_read_all_data | any modification |

## Justification of tuning (what was revoked from the generic grants and why)
1. …
