<?php
declare(strict_types=1);

// ---------------------------------------------------------------- output helpers
function e($value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function money($value): string
{
    return 'PHP ' . number_format((float) $value, 2);
}

function dt($value, string $format = 'M j, Y g:i A'): string
{
    return $value ? date($format, strtotime((string) $value)) : '';
}

function label(string $status): string
{
    return ucwords(str_replace('_', ' ', $status));
}

// ---------------------------------------------------------------- request helpers
function post(string $key, string $default = ''): string
{
    $v = $_POST[$key] ?? $default;
    return is_string($v) ? trim($v) : $default;
}

function get_param(string $key, string $default = ''): string
{
    $v = $_GET[$key] ?? $default;
    return is_string($v) ? trim($v) : $default;
}

function redirect(string $path): void
{
    header('Location: ' . $path);
    exit;
}

// ---------------------------------------------------------------- flash messages
function flash(string $type, string $message): void
{
    $_SESSION['flash'][] = ['type' => $type, 'message' => $message];
}

function take_flashes(): array
{
    $messages = $_SESSION['flash'] ?? [];
    unset($_SESSION['flash']);
    return $messages;
}

// ---------------------------------------------------------------- CSRF protection
function csrf_token(): string
{
    if (empty($_SESSION['csrf'])) {
        $_SESSION['csrf'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf'];
}

function csrf_field(): string
{
    return '<input type="hidden" name="_csrf" value="' . e(csrf_token()) . '">';
}

function csrf_check(): void
{
    $sent = $_POST['_csrf'] ?? '';
    if (!is_string($sent) || !hash_equals(csrf_token(), $sent)) {
        render('errors/403', ['message' => 'Your form expired. Please go back and try again.'], 403);
        exit;
    }
}

// ---------------------------------------------------------------- views
function render(string $view, array $data = [], int $status = 200): void
{
    http_response_code($status);
    header('Content-Type: text/html; charset=utf-8');
    extract($data, EXTR_SKIP);
    $title = $title ?? null;
    ob_start();
    require APP_PATH . '/src/views/' . $view . '.php';
    $content = ob_get_clean();
    require APP_PATH . '/src/views/layout.php';
}

// ---------------------------------------------------------------- authentication
function current_customer(): ?array
{
    static $cache = false;
    if ($cache === false) {
        $cache = null;
        if (!empty($_SESSION['customer_id'])) {
            $cache = fetch_one(
                'SELECT customer_id, first_name, last_name, email, phone FROM customer WHERE customer_id = ?',
                [(int) $_SESSION['customer_id']]
            );
        }
    }
    return $cache;
}

function current_staff(): ?array
{
    static $cache = false;
    if ($cache === false) {
        $cache = null;
        if (!empty($_SESSION['staff_id'])) {
            $cache = fetch_one(
                'SELECT staff_id, first_name, last_name, email, role FROM staff WHERE staff_id = ?',
                [(int) $_SESSION['staff_id']]
            );
        }
    }
    return $cache;
}

function require_customer(): array
{
    $customer = current_customer();
    if ($customer === null) {
        if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'GET') {
            $_SESSION['intended'] = $_SERVER['REQUEST_URI'] ?? '/menu';   // come back here after logging in
        }
        flash('error', 'Log in or register to continue.');
        redirect('/login');
    }
    return $customer;
}

/** Where to send a customer after login/registration (only local paths are accepted). */
function after_login_path(): string
{
    $next = $_SESSION['intended'] ?? '/menu';
    unset($_SESSION['intended']);
    return (is_string($next) && $next !== '' && $next[0] === '/' && strncmp($next, '//', 2) !== 0) ? $next : '/menu';
}

function nav_link(string $href, string $text, string $path): string
{
    $active = $href === '/' ? $path === '/' : strncmp($path, $href, strlen($href)) === 0;
    return '<a href="' . e($href) . '"' . ($active ? ' aria-current="page"' : '') . '>' . e($text) . '</a>';
}

/** @param string[] $roles roles allowed to see the page */
function require_staff(array $roles = ['admin', 'staff']): array
{
    $staff = current_staff();
    if ($staff === null) {
        flash('error', 'Staff login required.');
        redirect('/staff/login');
    }
    if (!in_array($staff['role'], $roles, true)) {
        render('errors/403', ['message' => 'Your role is not allowed to use this page.'], 403);
        exit;
    }
    return $staff;
}

function log_in_customer(int $id): void
{
    session_regenerate_id(true);
    unset($_SESSION['staff_id']);
    $_SESSION['customer_id'] = $id;
}

function log_in_staff(int $id): void
{
    session_regenerate_id(true);
    unset($_SESSION['customer_id'], $_SESSION['cart']);
    $_SESSION['staff_id'] = $id;
}

// ---------------------------------------------------------------- small validators
function valid_date(string $date): bool
{
    $d = DateTime::createFromFormat('Y-m-d', $date);
    return $d !== false && $d->format('Y-m-d') === $date;
}

function valid_slot(string $time): bool
{
    return in_array($time, RESERVATION_SLOTS, true);
}
