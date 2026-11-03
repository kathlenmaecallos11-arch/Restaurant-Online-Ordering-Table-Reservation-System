<?php $title = 'My orders'; ?>
<h1>My orders</h1>
<?php if (!$orders): ?><div class="empty"><strong>No orders yet.</strong><br>Browse the <a href="/menu">menu</a> and place your first order.</div><?php else: ?>
<table class="table">
  <tr><th>Order</th><th>Date</th><th>Status</th><th>Payment</th><th>Total</th></tr>
  <?php foreach ($orders as $o): ?>
    <tr>
      <td><a href="/orders/view?id=<?= (int) $o['order_id'] ?>">#<?= (int) $o['order_id'] ?></a></td>
      <td><?= e(dt($o['order_date'])) ?></td>
      <td><span class="badge <?= e($o['order_status']) ?>"><?= e(label($o['order_status'])) ?></span></td>
      <td><?= e(label((string) ($o['payment_status'] ?? 'none'))) ?></td>
      <td><?= e(money($o['total_amount'])) ?></td>
    </tr>
  <?php endforeach; ?>
</table>
<?php endif; ?>
