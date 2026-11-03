<?php $title = 'Payments'; ?>
<h1>Payments</h1>
<table class="table">
  <tr><th>Payment</th><th>Order</th><th>Customer</th><th>Method</th><th>Amount</th><th>Status</th></tr>
  <?php foreach ($payments as $p): ?>
    <tr>
      <td>#<?= (int) $p['payment_id'] ?></td>
      <td><a href="/admin/orders/view?id=<?= (int) $p['order_id'] ?>">#<?= (int) $p['order_id'] ?></a></td>
      <td><?= e($p['first_name'] . ' ' . $p['last_name']) ?></td>
      <td><?= e(label($p['payment_method'])) ?></td>
      <td><?= e(money($p['amount'])) ?></td>
      <td>
        <form method="post" action="/admin/payments/status" class="inline">
          <?= csrf_field() ?><input type="hidden" name="payment_id" value="<?= (int) $p['payment_id'] ?>">
          <select name="payment_status">
            <?php foreach (PAYMENT_STATUSES as $s): ?><option value="<?= e($s) ?>" <?= $s === $p['payment_status'] ? 'selected' : '' ?>><?= e(label($s)) ?></option><?php endforeach; ?>
          </select>
          <button class="btn small">Set</button>
        </form>
      </td>
    </tr>
  <?php endforeach; ?>
</table>
<?php if ($unpaid_orders): ?>
<h2>Record a payment for an order without one</h2>
<table class="table">
  <tr><th>Order</th><th>Customer</th><th>Amount due</th><th>Record as paid</th></tr>
  <?php foreach ($unpaid_orders as $o): ?>
    <tr>
      <td>#<?= (int) $o['order_id'] ?></td><td><?= e($o['first_name'] . ' ' . $o['last_name']) ?></td><td><?= e(money($o['total_amount'])) ?></td>
      <td>
        <form method="post" action="/admin/payments/record" class="inline">
          <?= csrf_field() ?><input type="hidden" name="order_id" value="<?= (int) $o['order_id'] ?>">
          <select name="payment_method"><?php foreach (PAYMENT_METHODS as $m): ?><option value="<?= e($m) ?>"><?= e(label($m)) ?></option><?php endforeach; ?></select>
          <button class="btn small">Record</button>
        </form>
      </td>
    </tr>
  <?php endforeach; ?>
</table>
<?php endif; ?>
