<?php
declare(strict_types=1);

function page_home(): void
{
    $featured = fetch_all(
        'SELECT menu_item_id, item_name, description, category, price
           FROM menu_item WHERE availability = true ORDER BY menu_item_id LIMIT 4'
    );
    render('home', ['featured' => $featured]);
}

/** GET /health : proves the browser -> PHP -> PostgreSQL chain works. Shows no password or host details. */
function health_check(): void
{
    header('Content-Type: application/json; charset=utf-8');
    try {
        $row = fetch_one('SELECT current_database() AS db, current_user AS account');
        $tables = (int) fetch_value("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE'");
        echo json_encode(['status' => 'ok', 'database' => $row['db'], 'account' => $row['account'], 'tables' => $tables]);
    } catch (Throwable $e) {
        http_response_code(503);
        error_log('[RORS] health check failed: ' . $e->getMessage());
        echo json_encode(['status' => 'error', 'hint' => 'Database unreachable. Run: php tools/test-connection.php']);
    }
}

// ------------------------------------------------------------------ customer registration
function register_form(): void
{
    render('auth/register', ['old' => [], 'errors' => []]);
}

function register_submit(): void
{
    csrf_check();
    $old = [
        'first_name' => post('first_name'),
        'last_name'  => post('last_name'),
        'email'      => strtolower(post('email')),
        'phone'      => post('phone'),
    ];
    $password = $_POST['password'] ?? '';
    $confirm  = $_POST['password_confirm'] ?? '';
    $errors = [];

    if ($old['first_name'] === '' || strlen($old['first_name']) > 50) {
        $errors[] = 'First name is required (max 50 characters).';
    }
    if ($old['last_name'] === '' || strlen($old['last_name']) > 50) {
        $errors[] = 'Last name is required (max 50 characters).';
    }
    if (!filter_var($old['email'], FILTER_VALIDATE_EMAIL) || strlen($old['email']) > 100) {
        $errors[] = 'Enter a valid email address.';
    }
    if ($old['phone'] === '' || strlen($old['phone']) > 20) {
        $errors[] = 'Phone number is required (max 20 characters).';
    }
    if (!is_string($password) || strlen($password) < 8) {
        $errors[] = 'Password must be at least 8 characters.';
    }
    if ($password !== $confirm) {
        $errors[] = 'Passwords do not match.';
    }
    if (!$errors && fetch_value('SELECT 1 FROM customer WHERE email = ?', [$old['email']])) {
        $errors[] = 'That email is already registered. Try logging in.';
    }
    if ($errors) {
        render('auth/register', ['old' => $old, 'errors' => $errors], 422);
        return;
    }

    $id = (int) fetch_value(
        'INSERT INTO customer (first_name, last_name, email, phone, password)
         VALUES (?, ?, ?, ?, ?) RETURNING customer_id',
        [$old['first_name'], $old['last_name'], $old['email'], $old['phone'], password_hash($password, PASSWORD_DEFAULT)]
    );
    log_in_customer($id);
    flash('success', 'Welcome! Your account has been created.');
    redirect(after_login_path());
}

// ------------------------------------------------------------------ customer login / logout
function login_form(): void
{
    render('auth/login', ['email' => '']);
}

function login_submit(): void
{
    csrf_check();
    $email = strtolower(post('email'));
    $password = $_POST['password'] ?? '';
    $row = fetch_one('SELECT customer_id, password FROM customer WHERE email = ?', [$email]);
    if ($row === null || !is_string($password) || !password_verify($password, $row['password'])) {
        render('auth/login', ['email' => $email, 'error' => 'Incorrect email or password.'], 401);
        return;
    }
    log_in_customer((int) $row['customer_id']);
    flash('success', 'You are logged in.');
    redirect(after_login_path());
}

function logout(): void
{
    csrf_check();
    $_SESSION = [];
    if (ini_get('session.use_cookies')) {
        $p = session_get_cookie_params();
        setcookie(session_name(), '', time() - 3600, $p['path'], $p['domain'] ?? '', (bool) ($p['secure'] ?? false), true);
    }
    session_destroy();
    session_start();
    flash('success', 'You have been logged out.');
    redirect('/');
}

// ------------------------------------------------------------------ customer profile (update)
function profile_form(): void
{
    $customer = require_customer();
    render('auth/profile', ['customer' => $customer, 'errors' => []]);
}

function profile_submit(): void
{
    $customer = require_customer();
    csrf_check();
    $first = post('first_name');
    $last = post('last_name');
    $phone = post('phone');
    $new = $_POST['new_password'] ?? '';
    $errors = [];

    if ($first === '' || strlen($first) > 50 || $last === '' || strlen($last) > 50) {
        $errors[] = 'First and last name are required (max 50 characters each).';
    }
    if ($phone === '' || strlen($phone) > 20) {
        $errors[] = 'Phone number is required (max 20 characters).';
    }
    if (is_string($new) && $new !== '' && strlen($new) < 8) {
        $errors[] = 'A new password must be at least 8 characters.';
    }
    if ($errors) {
        $customer['first_name'] = $first;
        $customer['last_name'] = $last;
        $customer['phone'] = $phone;
        render('auth/profile', ['customer' => $customer, 'errors' => $errors], 422);
        return;
    }

    q('UPDATE customer SET first_name = ?, last_name = ?, phone = ? WHERE customer_id = ?',
      [$first, $last, $phone, $customer['customer_id']]);
    if (is_string($new) && $new !== '') {
        q('UPDATE customer SET password = ? WHERE customer_id = ?',
          [password_hash($new, PASSWORD_DEFAULT), $customer['customer_id']]);
    }
    flash('success', 'Profile updated.');
    redirect('/profile');
}

// ------------------------------------------------------------------ staff / administrator login
function staff_login_form(): void
{
    render('auth/staff_login', ['email' => '']);
}

function staff_login_submit(): void
{
    csrf_check();
    $email = strtolower(post('email'));
    $password = $_POST['password'] ?? '';
    $row = fetch_one('SELECT staff_id, password FROM staff WHERE email = ?', [$email]);
    if ($row === null || !is_string($password) || !password_verify($password, $row['password'])) {
        render('auth/staff_login', ['email' => $email, 'error' => 'Incorrect email or password.'], 401);
        return;
    }
    log_in_staff((int) $row['staff_id']);
    flash('success', 'Staff session started.');
    redirect('/admin');
}
