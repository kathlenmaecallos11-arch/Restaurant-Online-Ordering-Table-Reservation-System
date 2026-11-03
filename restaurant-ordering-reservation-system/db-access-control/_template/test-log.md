# Privilege verification — Group __ : <project name>

| # | Account | Statement / operation | Expected | Actual | Result | Evidence |
|---|---|---|---|---|---|---|
| 1 | g__app | `SELECT … FROM <table> LIMIT 1` | Allowed | | | evidence/04_matrix.txt |
| 2 | g__app | `INSERT …` | Allowed | | | |
| 3 | g__report | `UPDATE …` | Denied | | | |
| 4 | g__app (real login) | `CREATE DATABASE x` | Denied | | | evidence/logintests.txt |
| 5 | g__app (real login) | connect to an unrelated database | Denied | | | |
| 6 | g__report | `SELECT` on credential table | Denied | | | |

## Unexpected results, cause and fix
| Finding | Cause (direct grant / inherited role / PUBLIC / ownership) | Fix |
|---|---|---|
