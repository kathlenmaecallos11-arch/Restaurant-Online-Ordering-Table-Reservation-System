<?php
declare(strict_types=1);

/**
 * Checks the PostgreSQL connection the web application will use. Prints no password.
 *   php tools/test-connection.php
 * Exit code 0 = everything fine, 1 = a problem (the message says what to fix).
 */
require __DIR__ . '/../app/src/bootstrap.php';

$cfg = require APP_PATH . '/config/database.php';
echo "Connecting to {$cfg['host']}:{$cfg['port']} database '{$cfg['database']}' as '{$cfg['username']}' ...\n";

if (!extension_loaded('pdo_pgsql')) {
    fwrite(STDERR, "FAIL  PHP extension pdo_pgsql is not enabled. Enable it in php.ini (docs/RUN_LOCALLY.md step 1).\n");
    exit(1);
}
if ($cfg['username'] === 'postgres') {
    echo "WARN  The application should not use the postgres superuser. Use rors_app (Activity 4).\n";
}

try {
    $info = fetch_one('SELECT current_database() AS db, current_user AS usr, split_part(version(), \' on \', 1) AS ver');
    echo "OK    Connected. Server: {$info['ver']}; database: {$info['db']}; account: {$info['usr']}\n";

    $expected = ['customer', 'menu_item', 'restaurant_table', 'staff', 'orders', 'order_item', 'reservation', 'payment'];
    $missing = 0;
    foreach ($expected as $table) {
        try {
            $n = (int) fetch_value("SELECT COUNT(*) FROM \"$table\"");
            echo sprintf("OK    %-17s %d rows\n", $table, $n);
        } catch (PDOException $e) {
            $missing++;
            $hint = $e->getCode() === '42501' ? 'permission denied: run database/roles/02_grants.sql' : 'missing: run database/setup.ps1';
            echo sprintf("FAIL  %-17s %s\n", $table, $hint);
        }
    }
    if ($missing > 0) {
        exit(1);
    }
    echo "\nAll 8 tables are reachable with this account. Start the site: php -S localhost:8000 -t app/public\n";
    exit(0);
} catch (PDOException $e) {
    $code = (string) $e->getCode();
    $hint = [
        '08006' => 'server not reachable or database/user wrong: is the postgresql-x64-18 service running? check DB_HOST, DB_PORT, DB_NAME',
        '28P01' => 'wrong password for this account: fix DB_PASSWORD in .env',
        '3D000' => 'database does not exist: run database/setup.ps1',
        '42501' => 'permission denied: run database/roles/02_grants.sql',
    ][$code] ?? 'see docs/troubleshooting.md';
    fwrite(STDERR, "FAIL  [$code] $hint\n      " . strtok($e->getMessage(), "\n") . "\n");
    exit(1);
}
