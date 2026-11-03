<?php
declare(strict_types=1);

// ------------------------------------------------------------------ shopping cart (kept in the session)
/** @return array<int,array> cart lines with current menu data */
function cart_items(): array
{
    $cart = $_SESSION['cart'] ?? [];
    if (!$cart) {
        return [];
    }
    $ids = array_map('intval', array_keys($cart));
    $placeholders = implode(',', array_fill(0, count($ids), '?'));
    $rows = fetch_all(
        "SELECT menu_item_id, item_name, price, availability FROM menu_item
          WHERE menu_item_id IN ($placeholders) ORDER BY item_name",
        $ids
    );
    foreach ($rows as &$row) {
        $row['qty'] = (int) $cart[(int) $row['menu_item_id']];
        $row['line_total'] = round($row['qty'] * (float) $row['price'], 2);
    }
    unset($row);
    return $rows;
}

function cart_show(): void
{
    $items = cart_items();
    $total = array_sum(array_column($items, 'line_total'));
    render('orders/cart', ['items' => $items, 'total' => $total]);
}

function cart_add(): void
{
    csrf_check();
    $id = (int) post('menu_item_id');
    $qty = max(1, min(20, (int) post('quantity', '1')));
    $item = fetch_one('SELECT availability FROM menu_item WHERE menu_item_id = ?', [$id]);
    if ($item === null || !to_bool($item['availability'])) {
        flash('error', 'That item is not available.');
        redirect('/menu');
    }
    $_SESSION['cart'][$id] = min(20, ($_SESSION['cart'][$id] ?? 0) + $qty);
    flash('success', 'Added to your order.');
    redirect('/cart');
}

function cart_update(): void
{
    csrf_check();
    $quantities = $_POST['qty'] ?? [];
    if (is_array($quantities)) {
        foreach ($quantities as $id => $qty) {
            $id = (int) $id;
            $qty = (int) $qty;
            if ($qty <= 0) {
                unset($_SESSION['cart'][$id]);
            } else {
                $_SESSION['cart'][$id] = min(20, $qty);
            }
        }
    }
    flash('success', 'Cart updated.');
    redirect('/cart');
}

function cart_remove(): void
{
    csrf_check();
    unset($_SESSION['cart'][(int) post('remove')]);
    if (empty($_SESSION['cart'])) {
        unset($_SESSION['cart']);
    }
    flash('success', 'Dish removed from your order.');
    redirect('/cart');
}

function cart_clear(): void
{
    csrf_check();
    unset($_SESSION['cart']);
    redirect('/cart');
}

// ------------------------------------------------------------------ checkout: ORDER + ORDER_ITEM + PAYMENT in one transaction
function checkout(): void
{
    $customer = require_customer();
    csrf_check();

    $method = post('payment_method');
    $items = cart_items();
    if (!$items) {
        flash('error', 'Your cart is empty.');
        redirect('/cart');
    }
    if (!in_array($method, PAYMENT_METHODS, true)) {
        flash('error', 'Choose a payment method.');
        redirect('/cart');
    }
    foreach ($items as $it) {
        if (!to_bool($it['availability'])) {
            flash('error', $it['item_name'] . ' is no longer available. Remove it to continue.');
            redirect('/cart');
        }
    }

    $pdo = db();
    try {
        $pdo->beginTransaction();
        $orderId = (int) fetch_value(
            'INSERT INTO orders (customer_id) VALUES (?) RETURNING order_id',
            [$customer['customer_id']]
        );
        foreach ($items as $it) {
            // unit_price is copied from the menu NOW, so later price changes never alter past orders.
            q('INSERT INTO order_item (order_id, menu_item_id, quantity, unit_price, subtotal)
               SELECT ?::int, menu_item_id, ?::int, price, price * ?::int
                 FROM menu_item WHERE menu_item_id = ?',
              [$orderId, $it['qty'], $it['qty'], $it['menu_item_id']]);
        }
        q("INSERT INTO payment (order_id, payment_method, amount, payment_status)
           SELECT order_id, ?::varchar, total_amount, 'pending' FROM orders WHERE order_id = ?",
          [$method, $orderId]);
        $pdo->commit();
    } catch (Throwable $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        error_log('[RORS] checkout failed: ' . $e->getMessage());
        flash('error', 'We could not place your order. Please try again.');
        redirect('/cart');
    }

    unset($_SESSION['cart']);
    flash('success', 'Order #' . $orderId . ' placed. Staff will confirm it shortly.');
    redirect('/orders/view?id=' . $orderId);
}

// ------------------------------------------------------------------ customer order status (Feature 8)
function orders_list(): void
{
    $customer = require_customer();
    $orders = fetch_all(
        'SELECT o.order_id, o.order_date, o.order_status, o.total_amount, p.payment_status
           FROM orders o LEFT JOIN payment p ON p.order_id = o.order_id
          WHERE o.customer_id = ? ORDER BY o.order_date DESC',
        [$customer['customer_id']]
    );
    render('orders/index', ['orders' => $orders]);
}

function order_show(): void
{
    $customer = require_customer();
    $id = (int) get_param('id', '0');
    $order = fetch_one(
        'SELECT o.order_id, o.order_date, o.order_status, o.total_amount, p.payment_method, p.payment_status
           FROM orders o LEFT JOIN payment p ON p.order_id = o.order_id
          WHERE o.order_id = ? AND o.customer_id = ?',
        [$id, $customer['customer_id']]
    );
    if ($order === null) {
        render('errors/404', [], 404);
        return;
    }
    $lines = fetch_all(
        'SELECT m.item_name, oi.quantity, oi.unit_price, oi.subtotal
           FROM order_item oi JOIN menu_item m ON m.menu_item_id = oi.menu_item_id
          WHERE oi.order_id = ? ORDER BY m.item_name',
        [$id]
    );
    render('orders/show', ['order' => $order, 'lines' => $lines]);
}

function order_cancel(): void
{
    $customer = require_customer();
    csrf_check();
    $id = (int) post('order_id');
    $pdo = db();
    try {
        $pdo->beginTransaction();
        $stmt = q("UPDATE orders SET order_status = 'cancelled'
                    WHERE order_id = ? AND customer_id = ? AND order_status = 'pending'",
                  [$id, $customer['customer_id']]);
        if ($stmt->rowCount() === 1) {
            q("UPDATE payment SET payment_status = 'cancelled' WHERE order_id = ? AND payment_status = 'pending'", [$id]);
            $pdo->commit();
            flash('success', 'Order #' . $id . ' was cancelled.');
        } else {
            $pdo->rollBack();
            flash('error', 'Only pending orders can be cancelled.');
        }
    } catch (Throwable $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        error_log('[RORS] cancel failed: ' . $e->getMessage());
        flash('error', 'Could not cancel the order.');
    }
    redirect('/orders/view?id=' . $id);
}
