<?php
declare(strict_types=1);

foreach (['auth', 'menu', 'orders', 'reservations', 'admin'] as $controller) {
    require APP_PATH . '/src/controllers/' . $controller . '.php';
}

/** "METHOD /path" => function name. State-changing routes are POST only and check a CSRF token. */
$routes = [
    // public / customer
    'GET /'                    => 'page_home',
    'GET /health'              => 'health_check',   // browser test of the PostgreSQL connection
    'GET /menu'                => 'menu_index',
    'GET /menu/item'           => 'menu_show',
    'GET /register'            => 'register_form',
    'POST /register'           => 'register_submit',
    'GET /login'               => 'login_form',
    'POST /login'              => 'login_submit',
    'POST /logout'             => 'logout',
    'GET /profile'             => 'profile_form',
    'POST /profile'            => 'profile_submit',
    'GET /cart'                => 'cart_show',
    'POST /cart/add'           => 'cart_add',
    'POST /cart/update'        => 'cart_update',
    'POST /cart/remove'        => 'cart_remove',
    'POST /cart/clear'         => 'cart_clear',
    'POST /checkout'           => 'checkout',
    'GET /orders'              => 'orders_list',
    'GET /orders/view'         => 'order_show',
    'POST /orders/cancel'      => 'order_cancel',
    'GET /reservations'        => 'reservations_list',
    'GET /reservations/new'    => 'reservation_new',
    'POST /reservations'       => 'reservation_create',
    'POST /reservations/cancel'=> 'reservation_cancel',

    // staff / administrator
    'GET /staff/login'         => 'staff_login_form',
    'POST /staff/login'        => 'staff_login_submit',
    'GET /admin'               => 'admin_dashboard',
    'GET /admin/menu'          => 'admin_menu_list',
    'GET /admin/menu/edit'     => 'admin_menu_form',
    'POST /admin/menu/save'    => 'admin_menu_save',
    'POST /admin/menu/availability' => 'admin_menu_availability',
    'POST /admin/menu/delete'  => 'admin_menu_delete',
    'GET /admin/tables'        => 'admin_tables_list',
    'GET /admin/tables/edit'   => 'admin_table_form',
    'POST /admin/tables/save'  => 'admin_table_save',
    'POST /admin/tables/status'=> 'admin_table_status',
    'POST /admin/tables/delete'=> 'admin_table_delete',
    'GET /admin/orders'        => 'admin_orders_list',
    'GET /admin/orders/view'   => 'admin_order_show',
    'POST /admin/orders/status'=> 'admin_order_status',
    'GET /admin/reservations'  => 'admin_reservations_list',
    'POST /admin/reservations/status' => 'admin_reservation_status',
    'POST /admin/reservations/delete' => 'admin_reservation_delete',
    'GET /admin/payments'      => 'admin_payments_list',
    'POST /admin/payments/record' => 'admin_payment_record',
    'POST /admin/payments/status' => 'admin_payment_status',
    'GET /admin/customers'     => 'admin_customers_list',
    'GET /admin/staff'         => 'admin_staff_list',
    'GET /admin/staff/edit'    => 'admin_staff_form',
    'POST /admin/staff/save'   => 'admin_staff_save',
    'POST /admin/staff/delete' => 'admin_staff_delete',
];

function dispatch(): void
{
    global $routes;
    $method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
    $path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
    $path = rtrim($path, '/');
    if ($path === '') {
        $path = '/';
    }
    $key = $method . ' ' . $path;
    if (isset($routes[$key])) {
        $handler = $routes[$key];
        $handler();
        return;
    }
    render('errors/404', [], 404);
}
