<?php $title = 'Your order'; $loggedIn = current_customer() !== null; ?>
<h1>Your order</h1>
<?php if (!$items): ?>
  <div class="empty"><strong>Your order is empty.</strong><br>Add a few dishes from the <a href="/menu">menu</a> to get started.</div>
<?php else: ?>
<div class="split">
  <form method="post" action="/cart/update">
    <?= csrf_field() ?>
    <button class="sr-only" tabindex="-1" aria-hidden="true">Update quantities</button><!-- default for the Enter key -->
    <table class="table">
      <tr><th>Dish</th><th>Price</th><th>Quantity</th><th class="right">Total</th><th></th></tr>
      <?php foreach ($items as $it): ?>
        <tr>
          <td><?= e($it['item_name']) ?><?= to_bool($it['availability']) ? '' : ' <span class="badge off">Sold out</span>' ?></td>
          <td><?= e(money($it['price'])) ?></td>
          <td><label class="sr-only" for="q<?= (int) $it['menu_item_id'] ?>">Quantity of <?= e($it['item_name']) ?></label>
              <input id="q<?= (int) $it['menu_item_id'] ?>" type="number" class="qty" name="qty[<?= (int) $it['menu_item_id'] ?>]" value="<?= (int) $it['qty'] ?>" min="0" max="20"></td>
          <td class="right"><?= e(money($it['line_total'])) ?></td>
          <td><button class="link danger" name="remove" value="<?= (int) $it['menu_item_id'] ?>" formaction="/cart/remove">Remove</button></td>
        </tr>
      <?php endforeach; ?>
    </table>
    <p class="muted">Set a quantity to 0 to remove a dish.</p>
    <button class="btn secondary">Update quantities</button>
  </form>

  <aside class="panel">
    <h2>Checkout</h2>
    <div class="sum"><span>Total</span><span><?= e(money($total)) ?></span></div>
    <?php if (!$loggedIn): ?>
      <p>Log in or create an account to place this order. Your dishes stay in your order.</p>
      <p><a class="btn" href="/login">Log in</a> <a class="btn secondary" href="/register">Register</a></p>
    <?php else: ?>
      <form method="post" action="/checkout">
        <?= csrf_field() ?>
        <fieldset>
          <legend>How will you pay?</legend>
          <div class="choices">
            <?php foreach (PAYMENT_METHODS as $k => $m): ?>
              <label><input type="radio" name="payment_method" value="<?= e($m) ?>" <?= $k === 0 ? 'checked' : '' ?>><span><?= e(label($m)) ?></span></label>
            <?php endforeach; ?>
          </div>
        </fieldset>
        <button class="btn" style="width:100%">Place order</button>
      </form>
    <?php endif; ?>
    <form method="post" action="/cart/clear" style="margin-top:1rem"><?= csrf_field() ?><button class="link danger">Empty my order</button></form>
  </aside>
</div>
<?php endif; ?>
