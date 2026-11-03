<?php $title = 'Customers'; ?>
<h1>Customers</h1>
<p class="muted">Read-only list. Password hashes are never selected for this page.</p>
<table class="table">
  <tr><th>ID</th><th>Name</th><th>Email</th><th>Phone</th><th>Registered</th><th>Orders</th></tr>
  <?php foreach ($customers as $c): ?>
    <tr><td><?= (int) $c['customer_id'] ?></td><td><?= e($c['first_name'] . ' ' . $c['last_name']) ?></td><td><?= e($c['email']) ?></td><td><?= e($c['phone']) ?></td><td><?= e(dt($c['created_at'], 'M j, Y')) ?></td><td><?= (int) $c['order_count'] ?></td></tr>
  <?php endforeach; ?>
</table>
