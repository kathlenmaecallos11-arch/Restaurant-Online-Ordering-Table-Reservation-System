<?php $title = 'Order #' . $order['order_id']; ?>
<h1>Order #<?= (int) $order['order_id'] ?></h1>
<p>Customer: <?= e($order['first_name'] . ' ' . $order['last_name']) ?> &middot; <?= e($order['email']) ?> &middot; <?= e($order['phone']) ?><br>
Placed <?= e(dt($order['order_date'])) ?> &middot; Payment: <?= e(label((string) ($order['payment_method'] ?? 'n/a'))) ?> / <?= e(label((string) ($order['payment_status'] ?? 'none'))) ?></p>
<table class="table">
  <tr><th>Item</th><th>Qty</th><th>Unit price</th><th>Subtotal</th></tr>
  <?php foreach ($lines as $l): ?>
    <tr><td><?= e($l['item_name']) ?></td><td><?= (int) $l['quantity'] ?></td><td><?= e(money($l['unit_price'])) ?></td><td><?= e(money($l['subtotal'])) ?></td></tr>
  <?php endforeach; ?>
  <tr class="total"><th colspan="3" class="right">Total</th><th class="right"><?= e(money($order['total_amount'])) ?></th></tr>
</table>
<form method="post" action="/admin/orders/status" class="form">
  <?= csrf_field() ?>
  <input type="hidden" name="order_id" value="<?= (int) $order['order_id'] ?>">
  <label>Order status
    <select name="order_status">
      <?php foreach (ORDER_STATUSES as $s): ?><option value="<?= e($s) ?>" <?= $s === $order['order_status'] ? 'selected' : '' ?>><?= e(label($s)) ?></option><?php endforeach; ?>
    </select>
  </label>
  <button class="btn">Update status</button>
</form>
<p><a href="/admin/orders">Back to all orders</a></p>
