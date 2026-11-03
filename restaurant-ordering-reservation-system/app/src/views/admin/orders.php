<?php $title = 'Manage orders'; ?>
<h1>Orders</h1>
<form method="get" action="/admin/orders" class="filters">
  <select name="status">
    <option value="">All statuses</option>
    <?php foreach (ORDER_STATUSES as $s): ?><option value="<?= e($s) ?>" <?= $s === $status ? 'selected' : '' ?>><?= e(label($s)) ?></option><?php endforeach; ?>
  </select>
  <button class="btn small">Filter</button>
</form>
<table class="table">
  <tr><th>Order</th><th>Customer</th><th>Date</th><th>Status</th><th>Payment</th><th>Total</th></tr>
  <?php foreach ($orders as $o): ?>
    <tr>
      <td><a href="/admin/orders/view?id=<?= (int) $o['order_id'] ?>">#<?= (int) $o['order_id'] ?></a></td>
      <td><?= e($o['first_name'] . ' ' . $o['last_name']) ?></td>
      <td><?= e(dt($o['order_date'])) ?></td>
      <td><span class="badge <?= e($o['order_status']) ?>"><?= e(label($o['order_status'])) ?></span></td>
      <td><?= e(label((string) ($o['payment_status'] ?? 'none'))) ?></td>
      <td><?= e(money($o['total_amount'])) ?></td>
    </tr>
  <?php endforeach; ?>
</table>
