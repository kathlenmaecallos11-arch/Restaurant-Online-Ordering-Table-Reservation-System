<?php
declare(strict_types=1);

/**
 * ============================================================================
 *  STEP 2 OF 3  --  THE CONNECTION  (this is where PHP connects to PostgreSQL)
 * ============================================================================
 * db() reads the settings from app/config/database.php (STEP 1), builds the DSN string and opens
 * ONE PDO connection per request; later calls in the same request reuse it.
 * Every page and button reaches the database only through q() / fetch_all() / fetch_one() /
 * fetch_value() below (STEP 3), so this is the single door to PostgreSQL.
 * Normal use: the account rors_app created by database/roles/.
 */
function db(): PDO
{
    static $pdo = null;
    if ($pdo instanceof PDO) {
        return $pdo;
    }
    if (!extension_loaded('pdo_pgsql')) {
        throw new RuntimeException('The pdo_pgsql PHP extension is not enabled (see docs/troubleshooting.md).');
    }
    $cfg = require APP_PATH . '/config/database.php';
    $dsn = sprintf(
        '%s:host=%s;port=%s;dbname=%s;sslmode=%s;connect_timeout=5',
        $cfg['driver'], $cfg['host'], $cfg['port'], $cfg['database'], $cfg['sslmode']
    );
    $pdo = new PDO($dsn, (string) $cfg['username'], (string) $cfg['password'], [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ]);
    // Makes the application's sessions easy to recognise in pg_stat_activity (Activity 5).
    $pdo->exec("SET application_name = '" . $cfg['app_name'] . "'");
    return $pdo;
}

/**
 * STEP 3 OF 3 -- QUERY HELPERS used by every controller (app/src/controllers/*.php).
 * Prepared statement helper: every query in the app uses bound parameters (no SQL injection).
 * Example from a button handler:  q('UPDATE orders SET order_status = ? WHERE order_id = ?', [$status, $id]);
 */
function q(string $sql, array $params = []): PDOStatement
{
    $stmt = db()->prepare($sql);
    $stmt->execute($params);
    return $stmt;
}

function fetch_all(string $sql, array $params = []): array
{
    return q($sql, $params)->fetchAll();
}

function fetch_one(string $sql, array $params = []): ?array
{
    $row = q($sql, $params)->fetch();
    return $row === false ? null : $row;
}

function fetch_value(string $sql, array $params = [])
{
    $value = q($sql, $params)->fetchColumn();
    return $value === false ? null : $value;
}

/** PostgreSQL booleans may arrive as true/false or 't'/'f' depending on the driver. */
function to_bool($value): bool
{
    return $value === true || $value === 't' || $value === 'true' || $value === 1 || $value === '1';
}
