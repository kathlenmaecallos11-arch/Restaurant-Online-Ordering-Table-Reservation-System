# How the application connects to PostgreSQL

The browser never talks to PostgreSQL. Every button is an HTML form that sends a request to PHP, and PHP talks to the
database through **one** connection function.

```
Button / form  ->  app/public/index.php  ->  app/src/routes.php  ->  controller function
                                                                          |
        .env  ->  app/config/database.php  ->  db() in app/src/db.php  ->  q() / fetch_*()  ->  PostgreSQL
```

## The three places that matter

| Step | File | What it does |
|---|---|---|
| 1 | `.env` (copy of `.env.example`) | holds host, port, database, user, password. Never committed. |
| 2 | `app/config/database.php` | reads those values with `env()` and returns them as an array |
| 3 | `app/src/db.php` -> `db()` | builds the DSN and opens the PDO connection (**this is where PHP connects**) |

### Step 1: `.env` (you edit this)
```ini
DB_HOST=localhost
DB_PORT=5432
DB_NAME=grp_binarysisters_projectdb
DB_USER=rors_app
DB_PASSWORD=the-password-you-chose-for-rors_app
DB_SSLMODE=prefer
```
For a hosted PostgreSQL (Neon, Supabase, Render, Railway...) use its host/port/name/user/password and `DB_SSLMODE=require`.

### Step 2: `app/config/database.php`
```php
return [
    'driver'   => 'pgsql',
    'host'     => env('DB_HOST', 'localhost'),
    'port'     => env('DB_PORT', '5432'),
    'database' => env('DB_NAME', 'grp_binarysisters_projectdb'),
    'username' => env('DB_USER', 'rors_app'),
    'password' => env('DB_PASSWORD', ''),
    'sslmode'  => env('DB_SSLMODE', 'prefer'),
    'app_name' => 'rors-web',
];
```

### Step 3: `app/src/db.php` (the connection itself)
```php
function db(): PDO
{
    static $pdo = null;                       // one connection per request, reused afterwards
    if ($pdo instanceof PDO) { return $pdo; }
    $cfg = require APP_PATH . '/config/database.php';
    $dsn = sprintf('%s:host=%s;port=%s;dbname=%s;sslmode=%s;connect_timeout=5',
        $cfg['driver'], $cfg['host'], $cfg['port'], $cfg['database'], $cfg['sslmode']);
    $pdo = new PDO($dsn, (string) $cfg['username'], (string) $cfg['password'], [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,   // real prepared statements
    ]);
    return $pdo;
}
```
The same file defines `q()`, `fetch_all()`, `fetch_one()`, `fetch_value()`. Every controller uses only these, so nothing else
needs to know the connection details.

## How a button reaches the database (examples)

| Button | Route (`app/src/routes.php`) | Function | SQL it runs |
|---|---|---|---|
| Add to order | `POST /cart/add` | `cart_add()` | `SELECT availability FROM menu_item ...` (cart itself is in the session) |
| Remove / Update quantities / Empty | `POST /cart/remove`, `/cart/update`, `/cart/clear` | `cart_remove()` ... | session only |
| Place order | `POST /checkout` | `checkout()` | one transaction: `INSERT orders`, `INSERT order_item`, `INSERT payment` |
| Cancel order | `POST /orders/cancel` | `order_cancel()` | `UPDATE orders` + `UPDATE payment` (transaction) |
| Reserve this table | `POST /reservations` | `reservation_create()` | `INSERT INTO reservation` (DB rejects double booking) |
| Cancel reservation | `POST /reservations/cancel` | `reservation_cancel()` | `UPDATE reservation` |
| Register / Log in | `POST /register`, `/login` | `register_submit()`, `login_submit()` | `INSERT customer` / `SELECT ... password` |
| Update status (order) | `POST /admin/orders/status` | `admin_order_status()` | `UPDATE orders` (+ cancels a pending payment) |
| Set (reservation / payment / table) | `/admin/reservations/status`, `/admin/payments/status`, `/admin/tables/status` | `admin_*_status()` | `UPDATE ...` |
| Save / Delete (menu, tables, staff) | `/admin/menu/save` ... | `admin_*_save()`, `admin_*_delete()` | `INSERT` / `UPDATE` / `DELETE` |

Example of what a handler looks like:
```php
function admin_order_status(): void {
    require_staff();                 // role check
    csrf_check();                    // form token check
    q('UPDATE orders SET order_status = ? WHERE order_id = ?', [$status, $id]);   // bound parameters
}
```

## Setting it up (any OS)

1. Create the database, tables, rules, sample data and accounts
   `.\database\setup.ps1 -WithRoles` (Windows) or `./database/setup.sh --with-roles` (Linux/macOS).
2. `copy .env.example .env` and fill in `DB_PASSWORD` (Step 1 above).
3. Enable PHP extensions `pdo_pgsql` and `pgsql` (`php -m` must list both).
4. Check the connection: `php tools/test-connection.php` (prints OK for the server and all 8 tables).
5. Start the site: `php -S localhost:8000 -t app/public`.
6. Check from the browser: open `http://localhost:8000/health`. Expected: `{"status":"ok","database":"grp_binarysisters_projectdb","account":"rors_app","tables":8}`.

## Which database account does each action use?
The application always connects as `rors_app` (group `rors_runtime_grp`). Its privileges in `database/roles/02_grants.sql`
cover every statement above and nothing more: for example it can `INSERT`/`UPDATE` orders and payments but cannot `DELETE`
them, and it cannot create or drop tables. If a button shows "Something went wrong" and the PHP terminal says
`permission denied for table X`, a grant is missing: re-run `02_grants.sql`.

## Common errors
| Message | Fix |
|---|---|
| `could not find driver` | enable `pdo_pgsql` in `php.ini` |
| `password authentication failed for user "rors_app"` | `DB_PASSWORD` in `.env` differs from the one set in `03_set_passwords.psql` |
| `database "..." does not exist` | run `database/setup.*` |
| `connection refused` | PostgreSQL service not running, or wrong `DB_HOST` / `DB_PORT` |
| `permission denied for table ...` | run `database/roles/02_grants.sql` |
| `/health` returns 503 | run `php tools/test-connection.php`; it names the exact problem |
