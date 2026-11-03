# db-access-control/ — Activity 4: users, roles, privileges and access control

This folder holds **our group's own work** for Activity 4 (we never edit another group's repository).
Activity 4 is done on the Activity 3 projects of **all the other groups**, so the scripts here are
**templates that are parameterised** instead of hard-coded to one schema.

```
db-access-control/
├── README.md                    <- you are here
├── _template/                   <- copy of these files is made for every project (see run-activity4.ps1)
│   ├── 00_inventory.sql         Part A  identify objects, owners, sensitive columns, PUBLIC privileges
│   ├── 01_roles_and_grants.sql  Part C/D  group roles, login roles, memberships, GRANT/REVOKE, default privileges
│   ├── 02_set_passwords.psql    hidden-prompt passwords (nothing stored in files)
│   ├── 03_tune_least_privilege.sql  per-project tightening you fill in after reading the owner's code
│   ├── 04_privilege_tests.sql   Part E  allowed/denied matrix (SET LOCAL ROLE, always rolled back)
│   ├── 05_review_privileges.sql role attributes, memberships, effective privileges, PUBLIC, default ACLs
│   ├── access-control-plan.md   Part B  plan table (accounts, group roles, application role served)
│   ├── test-log.md              Part E  one row per test: account, statement, expected, actual, evidence
│   └── feedback-to-owners.md    Part F  setup problems + security recommendations to send to the owners
├── run-activity4.ps1            helper that scaffolds group-XX/ and runs the steps with transcripts
└── group-XX/                    <- created per project, e.g. group-03/ (scripts, plan, evidence)
```

## Workflow for one project (≈ 30–45 min once practised)

1. Clone the owner's repo to a **separate working folder** (not inside this repository) and set it up
   with its own PostgreSQL database (keep every project in its own database).
2. `.\db-access-control\run-activity4.ps1 -Group 03 -Db <their_db_name> -Step init`
   creates `group-03/` from `_template/`.
3. `-Step inventory` → read `evidence/00_inventory.txt`, then read the owner's README / user-roles doc
   and **fill `group-03/access-control-plan.md` before creating anything**.
4. `-Step apply` → creates group roles + login roles + grants (`01_roles_and_grants.sql`).
   `-Step passwords` → hidden prompts for the login accounts.
5. Tighten the generic grants in `group-03/03_tune_least_privilege.sql` (revoke DELETE where the app never
   deletes, hide credential columns/tables from the read-only role, …) and run `-Step tune`.
6. `-Step test -ReadTable <t> -WriteTable <t> [-SensitiveTable <t>]` → matrix + attribute review, then
   run the **real-login** tests (`-Step logintests`: CREATE DATABASE denied, unrelated database denied,
   wrong-table denied). Take screenshots (hide passwords!).
7. Fill `test-log.md`, commit (`git add db-access-control/group-03`), update the **Activity 4 Log** tab in the
   tracker and send `feedback-to-owners.md` to the owning group.

## Naming rules

* **Roles are cluster-wide**, but we set up several projects on the same local server. Every project therefore
  gets its own **prefix** (`g03` for group 03): `g03_runtime_grp`, `g03_readonly_grp`, `g03_maint_grp`,
  `g03_backup_grp` (NOLOGIN group roles) and `g03_app`, `g03_report`, `g03_maint`, `g03_backup` (login roles).
* Never reuse one login for two projects and never reuse the owner's `postgres` superuser for the app.

## Running the owner's application with the least-privilege account

Put `DB_USER=g03_app` and its password in the owner's **local, uncommitted** `.env` (or equivalent) — not in
their repository. If the application stops working, that is a finding: either a privilege is missing
(add it to `03_tune_least_privilege.sql` with a justification) or the application needs more than it should
(write it in `feedback-to-owners.md`).

## Safety

* Work only on local test databases. Do not commit passwords, `.env` files or screenshots showing them.
* A role name does not enforce anything — always verify effective privileges with the test scripts.
