<?php
/** @var string $content */
$customerUser = current_customer();
$staffUser    = current_staff();
$flashes      = take_flashes();
$cartCount    = array_sum($_SESSION['cart'] ?? []);
$path         = rtrim((string) (parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/'), '/') ?: '/';
$inAdmin      = $staffUser !== null && strncmp($path, '/admin', 6) === 0;
$brand        = env('APP_BRAND', 'Mesa');
$pageTitle    = ($title ? $title . ' | ' : '') . $brand;
$isHome       = $path === '/' && $staffUser === null;
?><!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><?= e($pageTitle) ?></title>
  <link rel="stylesheet" href="/assets/style.css">
</head>
<body>
<a class="skip" href="#main">Skip to content</a>

<?php if ($inAdmin): ?>
<div class="shell">
  <aside class="side">
    <a class="brand" href="/admin"><?= e($brand) ?></a>
    <nav aria-label="Staff">
      <a href="/admin"<?= $path === '/admin' ? ' aria-current="page"' : '' ?>>Today</a>
      <?= nav_link('/admin/orders', 'Orders', $path) ?>
      <?= nav_link('/admin/reservations', 'Reservations', $path) ?>
      <?= nav_link('/admin/payments', 'Payments', $path) ?>
      <?= nav_link('/admin/menu', 'Menu items', $path) ?>
      <?= nav_link('/admin/tables', 'Tables', $path) ?>
      <?php if ($staffUser['role'] === 'admin'): ?>
        <?= nav_link('/admin/customers', 'Customers', $path) ?>
        <?= nav_link('/admin/staff', 'Staff accounts', $path) ?>
      <?php endif; ?>
      <a href="/menu">View customer site</a>
    </nav>
    <div class="me">
      <?= e($staffUser['first_name'] . ' ' . $staffUser['last_name']) ?><br>
      <span><?= $staffUser['role'] === 'admin' ? 'Administrator' : 'Staff' ?></span>
      <form method="post" action="/logout"><?= csrf_field() ?><button class="link">Log out</button></form>
    </div>
  </aside>
  <div class="work" id="main">
    <?php foreach ($flashes as $f): ?><div class="flash <?= e($f['type']) ?>" role="status"><?= e($f['message']) ?></div><?php endforeach; ?>
    <?= $content ?>
  </div>
</div>

<?php else: ?>
<header class="site-header">
  <div class="bar">
    <a class="brand" href="/"><?= e($brand) ?><small>order &amp; reserve</small></a>
    <nav class="main-nav" aria-label="Main">
      <?= nav_link('/menu', 'Menu', $path) ?>
      <?php if ($staffUser): ?>
        <a href="/admin">Back to staff area</a>
      <?php else: ?>
        <?= nav_link('/reservations/new', 'Reserve a table', $path) ?>
        <?php if ($customerUser): ?>
          <?= nav_link('/orders', 'My orders', $path) ?>
          <?= nav_link('/reservations', 'My reservations', $path) ?>
        <?php endif; ?>
      <?php endif; ?>
    </nav>
    <div class="account">
      <?php if (!$staffUser): ?><a href="/cart">Your order (<?= (int) $cartCount ?>)</a><?php endif; ?>
      <?php if ($customerUser): ?>
        <a href="/profile"><?= e($customerUser['first_name']) ?></a>
        <form method="post" action="/logout"><?= csrf_field() ?><button class="link">Log out</button></form>
      <?php elseif ($staffUser): ?>
        <form method="post" action="/logout"><?= csrf_field() ?><button class="link">Log out</button></form>
      <?php else: ?>
        <a href="/login">Log in</a><a href="/register">Register</a><a href="/staff/login">Staff</a>
      <?php endif; ?>
    </div>
  </div>
</header>
<?php if ($isHome): ?>
  <?php foreach ($flashes as $f): ?><div class="container" style="padding-bottom:0"><div class="flash <?= e($f['type']) ?>" role="status"><?= e($f['message']) ?></div></div><?php endforeach; ?>
  <?= $content ?>
<?php else: ?>
  <main class="container" id="main">
    <?php foreach ($flashes as $f): ?><div class="flash <?= e($f['type']) ?>" role="status"><?= e($f['message']) ?></div><?php endforeach; ?>
    <?= $content ?>
  </main>
<?php endif; ?>
<footer class="site-footer">COMP 018 Database Administration project &middot; Group Binary Sisters &middot; PHP + PostgreSQL</footer>
<?php endif; ?>
</body>
</html>
