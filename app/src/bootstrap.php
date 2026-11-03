<?php
declare(strict_types=1);

define('ROOT_PATH', dirname(__DIR__, 2));   // repository root (where .env lives)
define('APP_PATH', dirname(__DIR__));       // app/

/** Reads KEY=value lines from .env into $_ENV (no external library needed). */
function load_env(string $file): void
{
    if (!is_file($file)) {
        return;
    }
    foreach (file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#' || strpos($line, '=') === false) {
            continue;
        }
        [$key, $value] = explode('=', $line, 2);
        $key = trim($key);
        $value = trim($value);
        if (strlen($value) >= 2 && ($value[0] === '"' || $value[0] === "'") && substr($value, -1) === $value[0]) {
            $value = substr($value, 1, -1);
        }
        $_ENV[$key] = $value;
    }
}

function env(string $key, ?string $default = null): ?string
{
    if (isset($_ENV[$key])) {
        return $_ENV[$key];
    }
    $value = getenv($key);
    return $value === false ? $default : $value;
}

load_env(ROOT_PATH . '/.env');

date_default_timezone_set(env('APP_TIMEZONE', 'Asia/Manila'));

const ORDER_STATUSES       = ['pending', 'confirmed', 'preparing', 'ready', 'completed', 'cancelled'];
const RESERVATION_STATUSES = ['pending', 'confirmed', 'seated', 'completed', 'cancelled', 'no_show'];
const PAYMENT_STATUSES     = ['pending', 'paid', 'failed', 'refunded', 'cancelled'];
const PAYMENT_METHODS      = ['cash', 'card', 'gcash', 'bank_transfer'];
const TABLE_STATUSES       = ['available', 'occupied', 'reserved', 'out_of_service'];
const STAFF_ROLES          = ['admin', 'staff'];
const RESERVATION_SLOTS    = ['10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00'];

require APP_PATH . '/src/db.php';
require APP_PATH . '/src/helpers.php';

if (PHP_SAPI !== 'cli') {   // the command-line connection test needs no session
    ini_set('session.use_strict_mode', '1');
    session_name('rors_session');
    session_set_cookie_params([
        'lifetime' => 0,
        'path'     => '/',
        'httponly' => true,
        'samesite' => 'Lax',
    ]);
    session_start();
}

set_exception_handler(function (Throwable $e): void {
    error_log('[RORS] ' . get_class($e) . ': ' . $e->getMessage());
    if (!headers_sent()) {
        http_response_code(500);
        header('Content-Type: text/html; charset=utf-8');
    }
    $debug = env('APP_DEBUG', 'false') === 'true';
    echo '<!doctype html><meta charset="utf-8"><title>Server error</title>';
    echo '<h1>Something went wrong</h1><p>The system could not complete your request.</p>';
    if ($debug) {
        echo '<pre>' . htmlspecialchars($e->getMessage(), ENT_QUOTES, 'UTF-8') . '</pre>';
    } else {
        echo '<p>If this keeps happening, see docs/troubleshooting.md or enable APP_DEBUG in your local .env.</p>';
    }
});
