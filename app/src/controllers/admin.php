<?php
declare(strict_types=1);

/**
 * Staff and administrator pages.
 *   staff : read everything operational; update order / reservation / payment status; toggle menu availability
 *   admin : everything staff can do + create/edit/delete menu items and tables, delete reservations,
 *           view customers, manage staff accounts
 * The checks live in the application. The database account (rors_app) is the same for every
 * request, see docs/user-roles.md for how the application roles map to database roles.
 */

function admin_dashboard(): void
{
    $staff = require_staff();
    $stats = [
        'pending_orders'      => (int) fetch_value("SELECT COUNT(*) FROM orders WHERE order_status = 'pending'"),
        'todays_reservations' => (int) fetch_value("SELECT COUNT(*) FROM reservation WHERE reservation_date = CURRENT_DATE AND reservation_status IN ('pending','confirmed','seated')"),
        'unpaid'              => (int) fetch_value("SELECT COUNT(*) FROM payment WHERE payment_status = 'pending'"),
        'menu_items'          => (int) fetch_value('SELECT COUNT(*) FROM menu_item'),
        'tables'              => (int) fetch_value('SELECT COUNT(*) FROM restaurant_table'),
    ];
    $recent = fetch_all(
        'SELECT o.order_id, o.order_date, o.order_status, o.total_amount, c.first_name, c.last_name
           FROM orders o JOIN customer c ON c.customer_id = o.customer_id
          ORDER BY o.order_date DESC LIMIT 5'
    );
    render('admin/dashboard', compact('staff', 'stats', 'recent'));
}

// ------------------------------------------------------------------ menu management (Feature 9)
function admin_menu_list(): void
{
    $staff = require_staff();
    $items = fetch_all('SELECT menu_item_id, item_name, category, price, availability FROM menu_item ORDER BY category, item_name');
    render('admin/menu', compact('staff', 'items'));
}

function admin_menu_form(): void
{
    $staff = require_staff(['admin']);
    $id = (int) get_param('id', '0');
    $item = ['menu_item_id' => 0, 'item_name' => '', 'description' => '', 'category' => '', 'price' => '', 'availability' => true];
    if ($id > 0) {
        $found = fetch_one('SELECT * FROM menu_item WHERE menu_item_id = ?', [$id]);
        if ($found === null) {
            render('errors/404', [], 404);
            return;
        }
        $item = $found;
    }
    render('admin/menu_form', ['staff' => $staff, 'item' => $item, 'errors' => []]);
}

function admin_menu_save(): void
{
    $staff = require_staff(['admin']);
    csrf_check();
    $item = [
        'menu_item_id' => (int) post('menu_item_id'),
        'item_name'    => post('item_name'),
        'description'  => post('description'),
        'category'     => post('category'),
        'price'        => post('price'),
        'availability' => post('availability') === '1',
    ];
    $errors = [];
    if ($item['item_name'] === '' || strlen($item['item_name']) > 100) {
        $errors[] = 'Item name is required (max 100 characters).';
    }
    if ($item['category'] === '' || strlen($item['category']) > 50) {
        $errors[] = 'Category is required (max 50 characters).';
    }
    if (!is_numeric($item['price']) || (float) $item['price'] < 0 || (float) $item['price'] > 99999999) {
        $errors[] = 'Price must be a number that is 0 or more.';
    }
    if ($errors) {
        render('admin/menu_form', ['staff' => $staff, 'item' => $item, 'errors' => $errors], 422);
        return;
    }
    $flag = $item['availability'] ? 't' : 'f';
    $desc = $item['description'] === '' ? null : $item['description'];
    if ($item['menu_item_id'] > 0) {
        q('UPDATE menu_item SET item_name = ?, description = ?, category = ?, price = ?, availability = ?::boolean
            WHERE menu_item_id = ?',
          [$item['item_name'], $desc, $item['category'], $item['price'], $flag, $item['menu_item_id']]);
        flash('success', 'Menu item updated.');
    } else {
        q('INSERT INTO menu_item (item_name, description, category, price, availability) VALUES (?, ?, ?, ?, ?::boolean)',
          [$item['item_name'], $desc, $item['category'], $item['price'], $flag]);
        flash('success', 'Menu item created.');
    }
    redirect('/admin/menu');
}

function admin_menu_availability(): void
{
    require_staff();
    csrf_check();
    q('UPDATE menu_item SET availability = NOT availability WHERE menu_item_id = ?', [(int) post('menu_item_id')]);
    flash('success', 'Availability changed.');
    redirect('/admin/menu');
}

function admin_menu_delete(): void
{
    require_staff(['admin']);
    csrf_check();
    try {
        q('DELETE FROM menu_item WHERE menu_item_id = ?', [(int) post('menu_item_id')]);
        flash('success', 'Menu item deleted.');
    } catch (PDOException $e) {
        if ((string) $e->getCode() === '23503') {
            flash('error', 'This item appears in past orders and cannot be deleted. Mark it unavailable instead.');
        } else {
            throw $e;
        }
    }
    redirect('/admin/menu');
}

// ------------------------------------------------------------------ table management (Feature 10)
function admin_tables_list(): void
{
    $staff = require_staff();
    $tables = fetch_all('SELECT table_id, table_number, capacity, status FROM restaurant_table ORDER BY table_number');
    render('admin/tables', compact('staff', 'tables'));
}

function admin_table_form(): void
{
    $staff = require_staff(['admin']);
    $id = (int) get_param('id', '0');
    $table = ['table_id' => 0, 'table_number' => '', 'capacity' => '', 'status' => 'available'];
    if ($id > 0) {
        $found = fetch_one('SELECT * FROM restaurant_table WHERE table_id = ?', [$id]);
        if ($found === null) {
            render('errors/404', [], 404);
            return;
        }
        $table = $found;
    }
    render('admin/table_form', ['staff' => $staff, 'table' => $table, 'errors' => []]);
}

function admin_table_save(): void
{
    $staff = require_staff(['admin']);
    csrf_check();
    $table = [
        'table_id'     => (int) post('table_id'),
        'table_number' => post('table_number'),
        'capacity'     => post('capacity'),
        'status'       => post('status'),
    ];
    $errors = [];
    if (!ctype_digit($table['table_number']) || (int) $table['table_number'] < 1) {
        $errors[] = 'Table number must be a positive whole number.';
    }
    if (!ctype_digit($table['capacity']) || (int) $table['capacity'] < 1 || (int) $table['capacity'] > 50) {
        $errors[] = 'Capacity must be between 1 and 50.';
    }
    if (!in_array($table['status'], TABLE_STATUSES, true)) {
        $errors[] = 'Choose a valid status.';
    }
    if (!$errors) {
        $dup = fetch_value('SELECT 1 FROM restaurant_table WHERE table_number = ? AND table_id <> ?',
                           [(int) $table['table_number'], $table['table_id']]);
        if ($dup) {
            $errors[] = 'Another table already uses that number.';
        }
    }
    if ($errors) {
        render('admin/table_form', ['staff' => $staff, 'table' => $table, 'errors' => $errors], 422);
        return;
    }
    if ($table['table_id'] > 0) {
        q('UPDATE restaurant_table SET table_number = ?, capacity = ?, status = ? WHERE table_id = ?',
          [(int) $table['table_number'], (int) $table['capacity'], $table['status'], $table['table_id']]);
        flash('success', 'Table updated.');
    } else {
        q('INSERT INTO restaurant_table (table_number, capacity, status) VALUES (?, ?, ?)',
          [(int) $table['table_number'], (int) $table['capacity'], $table['status']]);
        flash('success', 'Table created.');
    }
    redirect('/admin/tables');
}

function admin_table_status(): void
{
    require_staff();   // staff and admin: front-of-house marks a table occupied / available / out of service
    csrf_check();
    $status = post('status');
    if (!in_array($status, TABLE_STATUSES, true)) {
        flash('error', 'Invalid table status.');
        redirect('/admin/tables');
    }
    q('UPDATE restaurant_table SET status = ? WHERE table_id = ?', [$status, (int) post('table_id')]);
    flash('success', 'Table status updated.');
    redirect('/admin/tables');
}

function admin_table_delete(): void
{
    require_staff(['admin']);
    csrf_check();
    try {
        q('DELETE FROM restaurant_table WHERE table_id = ?', [(int) post('table_id')]);
        flash('success', 'Table deleted.');
    } catch (PDOException $e) {
        if ((string) $e->getCode() === '23503') {
            flash('error', 'This table has reservations on record and cannot be deleted. Set it out of service instead.');
        } else {
            throw $e;
        }
    }
    redirect('/admin/tables');
}

// ------------------------------------------------------------------ order management (Feature 11)
function admin_orders_list(): void
{
    $staff = require_staff();
    $status = get_param('status');
    $sql = 'SELECT o.order_id, o.order_date, o.order_status, o.total_amount,
                   c.first_name, c.last_name, p.payment_status
              FROM orders o
              JOIN customer c ON c.customer_id = o.customer_id
              LEFT JOIN payment p ON p.order_id = o.order_id';
    $params = [];
    if (in_array($status, ORDER_STATUSES, true)) {
        $sql .= ' WHERE o.order_status = ?';
        $params[] = $status;
    } else {
        $status = '';
    }
    $sql .= ' ORDER BY o.order_date DESC LIMIT 200';
    render('admin/orders', ['staff' => $staff, 'orders' => fetch_all($sql, $params), 'status' => $status]);
}

function admin_order_show(): void
{
    $staff = require_staff();
    $id = (int) get_param('id', '0');
    $order = fetch_one(
        'SELECT o.order_id, o.order_date, o.order_status, o.total_amount,
                c.first_name, c.last_name, c.email, c.phone, p.payment_method, p.payment_status
           FROM orders o JOIN customer c ON c.customer_id = o.customer_id
           LEFT JOIN payment p ON p.order_id = o.order_id WHERE o.order_id = ?', [$id]);
    if ($order === null) {
        render('errors/404', [], 404);
        return;
    }
    $lines = fetch_all(
        'SELECT m.item_name, oi.quantity, oi.unit_price, oi.subtotal
           FROM order_item oi JOIN menu_item m ON m.menu_item_id = oi.menu_item_id
          WHERE oi.order_id = ? ORDER BY m.item_name', [$id]);
    render('admin/order', compact('staff', 'order', 'lines'));
}

function admin_order_status(): void
{
    require_staff();
    csrf_check();
    $id = (int) post('order_id');
    $status = post('order_status');
    if (!in_array($status, ORDER_STATUSES, true)) {
        flash('error', 'Invalid status.');
        redirect('/admin/orders');
    }
    $pdo = db();
    try {
        $pdo->beginTransaction();
        $stmt = q('UPDATE orders SET order_status = ? WHERE order_id = ?', [$status, $id]);
        if ($stmt->rowCount() !== 1) {
            $pdo->rollBack();
            flash('error', 'Order not found.');
            redirect('/admin/orders');
        }
        if ($status === 'cancelled') {   // a cancelled order must not keep a payment waiting
            q("UPDATE payment SET payment_status = 'cancelled' WHERE order_id = ? AND payment_status = 'pending'", [$id]);
        }
        $pdo->commit();
    } catch (Throwable $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        error_log('[RORS] order status failed: ' . $e->getMessage());
        flash('error', 'Could not update the order.');
        redirect('/admin/orders/view?id=' . $id);
    }
    flash('success', 'Order #' . $id . ' is now ' . label($status) . '.');
    redirect('/admin/orders/view?id=' . $id);
}

// ------------------------------------------------------------------ reservations
function admin_reservations_list(): void
{
    $staff = require_staff();
    $date = get_param('date');
    $sql = 'SELECT r.reservation_id, r.reservation_date, r.reservation_time, r.number_of_guests,
                   r.reservation_status, t.table_number, c.first_name, c.last_name, c.phone
              FROM reservation r
              JOIN restaurant_table t ON t.table_id = r.table_id
              JOIN customer c ON c.customer_id = r.customer_id';
    $params = [];
    if (valid_date($date)) {
        $sql .= ' WHERE r.reservation_date = ?';
        $params[] = $date;
    } else {
        $date = '';
    }
    $sql .= ' ORDER BY r.reservation_date DESC, r.reservation_time DESC LIMIT 200';
    render('admin/reservations', ['staff' => $staff, 'reservations' => fetch_all($sql, $params), 'date' => $date]);
}

function admin_reservation_status(): void
{
    require_staff();
    csrf_check();
    $status = post('reservation_status');
    if (!in_array($status, RESERVATION_STATUSES, true)) {
        flash('error', 'Invalid status.');
        redirect('/admin/reservations');
    }
    try {
        q('UPDATE reservation SET reservation_status = ? WHERE reservation_id = ?', [$status, (int) post('reservation_id')]);
        flash('success', 'Reservation updated.');
    } catch (PDOException $e) {
        if ((string) $e->getCode() === '23P01') {
            flash('error', 'Cannot reactivate: the table is already booked for an overlapping time.');
        } else {
            throw $e;
        }
    }
    redirect('/admin/reservations');
}

function admin_reservation_delete(): void
{
    require_staff(['admin']);
    csrf_check();
    q('DELETE FROM reservation WHERE reservation_id = ?', [(int) post('reservation_id')]);
    flash('success', 'Reservation deleted.');
    redirect('/admin/reservations');
}

// ------------------------------------------------------------------ payments (Feature 12)
function admin_payments_list(): void
{
    $staff = require_staff();
    $payments = fetch_all(
        'SELECT p.payment_id, p.order_id, p.payment_date, p.payment_method, p.amount, p.payment_status,
                c.first_name, c.last_name
           FROM payment p JOIN orders o ON o.order_id = p.order_id
           JOIN customer c ON c.customer_id = o.customer_id
          ORDER BY p.payment_date DESC LIMIT 200');
    $unpaid_orders = fetch_all(
        "SELECT o.order_id, o.total_amount, c.first_name, c.last_name
           FROM orders o JOIN customer c ON c.customer_id = o.customer_id
          WHERE o.order_status <> 'cancelled'
            AND NOT EXISTS (SELECT 1 FROM payment p WHERE p.order_id = o.order_id)
          ORDER BY o.order_id");
    render('admin/payments', compact('staff', 'payments', 'unpaid_orders'));
}

function admin_payment_record(): void
{
    require_staff();
    csrf_check();
    $orderId = (int) post('order_id');
    $method = post('payment_method');
    if (!in_array($method, PAYMENT_METHODS, true)) {
        flash('error', 'Choose a payment method.');
        redirect('/admin/payments');
    }
    try {
        q("INSERT INTO payment (order_id, payment_method, amount, payment_status)
           SELECT order_id, ?::varchar, total_amount, 'paid' FROM orders WHERE order_id = ?", [$method, $orderId]);
        flash('success', 'Payment recorded for order #' . $orderId . '.');
    } catch (PDOException $e) {
        if ((string) $e->getCode() === '23505') {
            flash('error', 'That order already has a payment.');
        } else {
            throw $e;
        }
    }
    redirect('/admin/payments');
}

function admin_payment_status(): void
{
    require_staff();
    csrf_check();
    $status = post('payment_status');
    if (!in_array($status, PAYMENT_STATUSES, true)) {
        flash('error', 'Invalid status.');
        redirect('/admin/payments');
    }
    q('UPDATE payment SET payment_status = ?, payment_date = now() WHERE payment_id = ?', [$status, (int) post('payment_id')]);
    flash('success', 'Payment updated.');
    redirect('/admin/payments');
}

// ------------------------------------------------------------------ customers (read only, admin)
function admin_customers_list(): void
{
    $staff = require_staff(['admin']);
    $customers = fetch_all(
        'SELECT c.customer_id, c.first_name, c.last_name, c.email, c.phone, c.created_at,
                (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.customer_id) AS order_count
           FROM customer c ORDER BY c.created_at DESC');
    render('admin/customers', compact('staff', 'customers'));
}

// ------------------------------------------------------------------ staff accounts (admin only)
function admin_staff_list(): void
{
    $staff = require_staff(['admin']);
    $members = fetch_all('SELECT staff_id, first_name, last_name, email, role FROM staff ORDER BY role, last_name');
    render('admin/staff', compact('staff', 'members'));
}

function admin_staff_form(): void
{
    $staff = require_staff(['admin']);
    $id = (int) get_param('id', '0');
    $member = ['staff_id' => 0, 'first_name' => '', 'last_name' => '', 'email' => '', 'role' => 'staff'];
    if ($id > 0) {
        $found = fetch_one('SELECT staff_id, first_name, last_name, email, role FROM staff WHERE staff_id = ?', [$id]);
        if ($found === null) {
            render('errors/404', [], 404);
            return;
        }
        $member = $found;
    }
    render('admin/staff_form', ['staff' => $staff, 'member' => $member, 'errors' => []]);
}

function admin_staff_save(): void
{
    $staff = require_staff(['admin']);
    csrf_check();
    $member = [
        'staff_id'   => (int) post('staff_id'),
        'first_name' => post('first_name'),
        'last_name'  => post('last_name'),
        'email'      => strtolower(post('email')),
        'role'       => post('role'),
    ];
    $password = $_POST['password'] ?? '';
    $errors = [];
    if ($member['first_name'] === '' || $member['last_name'] === '') {
        $errors[] = 'First and last name are required.';
    }
    if (!filter_var($member['email'], FILTER_VALIDATE_EMAIL)) {
        $errors[] = 'Enter a valid email address.';
    }
    if (!in_array($member['role'], STAFF_ROLES, true)) {
        $errors[] = 'Choose a valid role.';
    }
    if ($member['staff_id'] === 0 && (!is_string($password) || strlen($password) < 8)) {
        $errors[] = 'A new account needs a password of at least 8 characters.';
    }
    if ($member['staff_id'] > 0 && is_string($password) && $password !== '' && strlen($password) < 8) {
        $errors[] = 'A new password must be at least 8 characters.';
    }
    if ($member['staff_id'] === (int) $staff['staff_id'] && $member['role'] !== 'admin') {
        $errors[] = 'You cannot remove your own administrator role.';
    }
    if (!$errors && fetch_value('SELECT 1 FROM staff WHERE email = ? AND staff_id <> ?', [$member['email'], $member['staff_id']])) {
        $errors[] = 'That email is already used by another staff account.';
    }
    if ($errors) {
        render('admin/staff_form', ['staff' => $staff, 'member' => $member, 'errors' => $errors], 422);
        return;
    }
    if ($member['staff_id'] > 0) {
        q('UPDATE staff SET first_name = ?, last_name = ?, email = ?, role = ? WHERE staff_id = ?',
          [$member['first_name'], $member['last_name'], $member['email'], $member['role'], $member['staff_id']]);
        if (is_string($password) && $password !== '') {
            q('UPDATE staff SET password = ? WHERE staff_id = ?', [password_hash($password, PASSWORD_DEFAULT), $member['staff_id']]);
        }
        flash('success', 'Staff account updated.');
    } else {
        q('INSERT INTO staff (first_name, last_name, email, role, password) VALUES (?, ?, ?, ?, ?)',
          [$member['first_name'], $member['last_name'], $member['email'], $member['role'], password_hash($password, PASSWORD_DEFAULT)]);
        flash('success', 'Staff account created.');
    }
    redirect('/admin/staff');
}

function admin_staff_delete(): void
{
    $staff = require_staff(['admin']);
    csrf_check();
    $id = (int) post('staff_id');
    if ($id === (int) $staff['staff_id']) {
        flash('error', 'You cannot delete your own account.');
        redirect('/admin/staff');
    }
    q('DELETE FROM staff WHERE staff_id = ?', [$id]);
    flash('success', 'Staff account deleted.');
    redirect('/admin/staff');
}
