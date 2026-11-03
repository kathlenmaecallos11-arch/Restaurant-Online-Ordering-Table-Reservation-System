<?php $title = 'Today'; ?>
<h1>Today at the restaurant</h1>
<p class="muted">Signed in as <?= e($staff['first_name'] . ' ' . $staff['last_name']) ?> (<?= $staff['role'] === 'admin' ? 'administrator' : 'staff' ?>).</p>

<h2>Needs attention</h2>
<ul class="tasks">
  <li><span class="n"><?= (int) $stats['pending_orders'] ?></span><span class="what">Orders waiting for confirmation</span><a class="btn small secondary" href="/admin/orders?status=pending">Review orders</a></li>
  <li><span class="n"><?= (int) $stats['todays_reservations'] ?></span><span class="what">Reservations today</span><a class="btn small secondary" href="/admin/reservations?date=<?= e(date('Y-m-d')) ?>">See schedule</a></li>
  <li><span class="n"><?= (int) $stats['unpaid'] ?></span><span class="what">Payments not yet received</span><a class="btn small secondary" href="/admin/payments">Open payments</a></li>
</ul>

<h2>Latest orders</h2>
<table class="table">
  <tr><th>Order</th><th>Customer</th><th>Placed</th><th>Status</th><th class="right">Total</th></tr>
  <?php foreach ($recent as $o): ?>
    <tr>
      <td><a href="/admin/orders/view?id=<?= (int) $o['order_id'] ?>">#<?= (int) $o['order_id'] ?></a></td>
      <td><?= e($o['first_name'] . ' ' . $o['last_name']) ?></td>
      <td><?= e(dt($o['order_date'])) ?></td>
      <td><span class="badge <?= e($o['order_status']) ?>"><?= e(label($o['order_status'])) ?></span></td>
      <td class="right"><?= e(money($o['total_amount'])) ?></td>
    </tr>
  <?php endforeach; ?>
</table>
<p class="muted"><?= (int) $stats['menu_items'] ?> menu items and <?= (int) $stats['tables'] ?> tables on file.</p>
