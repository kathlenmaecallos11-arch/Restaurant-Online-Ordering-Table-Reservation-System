<?php $title = $item['item_name']; ?>
<p><a href="/menu">Back to the menu</a></p>
<h1><?= e($item['item_name']) ?></h1>
<p class="muted"><?= e($item['category']) ?></p>
<p><?= e($item['description']) ?></p>
<p class="price" style="font-size:1.6rem"><?= e(money($item['price'])) ?></p>
<?php if (to_bool($item['availability'])): ?>
  <form class="add" method="post" action="/cart/add">
    <?= csrf_field() ?>
    <input type="hidden" name="menu_item_id" value="<?= (int) $item['menu_item_id'] ?>">
    <label class="sr-only" for="qty">Quantity</label>
    <input id="qty" class="qty" type="number" name="quantity" value="1" min="1" max="20">
    <button class="btn">Add to order</button>
  </form>
<?php else: ?>
  <p><span class="badge off">Sold out today</span></p>
<?php endif; ?>
