# Run the system on localhost (Windows 10/11, step by step)

Result: the restaurant site at **http://localhost:8000** (customers) and **http://localhost:8000/staff/login** (staff/admin).

## 0. Just want to see the design first? (no setup)
Open `preview/index.html` by double-clicking it (also `menu.html`, `cart.html`, `reserve.html`, `login.html`, `admin.html`,
`admin-orders.html`). This is an interface demo: every button works (add to order, cart, login, reserve, cancel, staff order status), but the
data is kept only in your browser. The real system with PostgreSQL is the PHP application; continue below.

## 1. Check what is installed (PowerShell)
```powershell
psql --version        # expect: psql (PostgreSQL) 18.x
php -v                # expect: PHP 8.1 or newer
php -m | findstr /i pgsql    # expect two lines: pdo_pgsql and pgsql
```
* `psql` not found -> add `C:\Program Files\PostgreSQL\18\bin` to PATH, open a NEW PowerShell.
* `php` not found -> install PHP: download the **x64 Thread Safe** zip from https://windows.php.net/download, unzip to `C:\php`,
  add `C:\php` to PATH. (Or use XAMPP and call `C:\xampp\php\php.exe` instead of `php` below.)
* `pgsql` lines missing -> in `C:\php`, copy `php.ini-development` to `php.ini`, open it, remove the `;` in front of
  `extension=pdo_pgsql` and `extension=pgsql`, and set `extension_dir = "ext"`. Open a NEW PowerShell and run `php -m` again.

## 2. Open the project folder
```powershell
cd C:\path\to\restaurant-ordering-reservation-system     # the unzipped folder
```

## 3. Optional safety check: PHP syntax test of every file
```powershell
Get-ChildItem app -Recurse -Filter *.php | ForEach-Object { php -l $_.FullName } | Where-Object { $_ -notmatch "^No syntax errors" }
```
No output = no syntax errors. Any output = send me that text and I will fix it.

## 4. Create the database (asks for your postgres password, hidden)
```powershell
.\database\setup.ps1 -WithRoles
```
If PowerShell blocks the script: `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` and run it again.
The script then asks you to choose a password for each account. **Remember the one you choose for `rors_app`.**
At the end the privilege test must show only `PASS`.

## 5. Tell the app how to connect
```powershell
copy .env.example .env
notepad .env
```
Set `DB_USER=rors_app` and `DB_PASSWORD=` the password you chose for rors_app. Save. (`.env` is never committed.)

## 5b. Test the database connection (recommended)
```powershell
php tools/test-connection.php
```
Expected: `OK Connected ...` and eight `OK <table> N rows` lines. A `FAIL` line says exactly what to fix.

## 6. Start the web server
```powershell
php -S localhost:8000 -t app/public
```
Leave this window open. Open **http://localhost:8000** in your browser. Stop with `Ctrl + C`.

## 7. What to try (2 minutes)
| Step | Where | Expected |
|---|---|---|
| Customer login | `/login` -> maria.santos@rors.example / Password123! | "You are logged in" |
| Order | `/menu` -> Add to order (2 dishes) -> `/cart` -> Place order | order page with status Pending, total correct |
| Reserve | `/reservations/new` -> date, time chip, guests -> Check availability -> Reserve this table | appears in My reservations |
| Double booking | repeat the same table and time | the table is no longer listed |
| Staff | `/staff/login` -> staff@rors.example / Staff123! -> Orders -> open order -> set Confirmed | customer sees new status |
| Admin | log out, log in admin@rors.example / Admin123! -> Menu items -> Add menu item | item appears on `/menu` |
| Role check | as staff open `/admin/staff` | "Access denied" |

## 8. If something goes wrong
| You see | Do this |
|---|---|
| Blank page or "Something went wrong" | set `APP_DEBUG=true` in `.env`, reload, read the message (set back to `false` afterwards); also read the PowerShell window that runs `php -S` |
| `could not find driver` | step 1: enable `pdo_pgsql` in php.ini |
| `password authentication failed for user "rors_app"` | wrong DB_PASSWORD; reset it: `psql -U postgres -c "\password rors_app"` |
| `permission denied for table ...` | the grants did not run: `psql -U postgres -d grp_binarysisters_projectdb -f database/roles/02_grants.sql` |
| Styles missing | you started the server from the wrong folder or forgot `-t app/public` |
| Port 8000 in use | use `php -S localhost:8080 -t app/public` and open `:8080` |
More cases: `docs/troubleshooting.md`.

## 9. Quick run without the least-privilege account (only to look around)
`.\database\setup.ps1` (without `-WithRoles`), then in `.env` use `DB_USER=postgres` and your postgres password.
Switch back to `rors_app` before submitting Activity 4: the application must not use a superuser.
