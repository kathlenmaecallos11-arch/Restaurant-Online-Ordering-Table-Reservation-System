<?php
$title = 'Menu';
$groups = [];
foreach ($items as $i) { $groups[$i['category']][] = $i; }
$qs = static fn(array $extra): string => '/menu?' . http_build_query(array_filter(array_merge(['q' => $search, 'category' => $category], $extra), static fn($v) => $v !== ''));
?>
<div class="board-head">
  <h1 style="margin:0">Menu</h1>
  <form class="search" method="get" action="/menu" role="search">
    <?php if ($category !== ''): ?><input type="hidden" name="category" value="<?= e($category) ?>"><?php endif; ?>
    <label class="sr-only" for="q">Search dishes</label>
    <input id="q" type="search" name="q" value="<?= e($search) ?>" placeholder="Search dishes">
    <button class="btn secondary">Search</button>
  </form>
</div>
<ul class="chips" aria-label="Categories">
  <li><a href="<?= e($qs(['category' => ''])) ?>" <?= $category === '' ? 'aria-current="true"' : '' ?>>All</a></li>
  <?php foreach ($categories as $c): ?>
    <li><a href="<?= e($qs(['category' => $c['category']])) ?>" <?= $c['category'] === $category ? 'aria-current="true"' : '' ?>><?= e($c['category']) ?></a></li>
  <?php endforeach; ?>
</ul>

<?php if (!$groups): ?>
  <div class="empty"><strong>No dishes match your search.</strong><br>Clear the search or pick another category.</div>
<?php endif; ?>

<?php foreach ($groups as $cat => $dishes): ?>
  <section class="course" aria-labelledby="c-<?= e(md5($cat)) ?>">
    <h2 id="c-<?= e(md5($cat)) ?>"><?= e($cat) ?> <span><?= count($dishes) ?> <?= count($dishes) === 1 ? 'dish' : 'dishes' ?></span></h2>
    <ul class="dishes">
      <?php foreach ($dishes as $item): ?>
        <li class="dish">
          <div>
            <div class="dish-head">
              <a class="dish-name" href="/menu/item?id=<?= (int) $item['menu_item_id'] ?>"><?= e($item['item_name']) ?></a>
              <span class="leader" aria-hidden="true"></span>
              <span class="price"><?= e(money($item['price'])) ?></span>
            </div>
            <p class="dish-desc"><?= e($item['description']) ?></p>
          </div>
          <form class="add" method="post" action="/cart/add">
            <?= csrf_field() ?>
            <input type="hidden" name="menu_item_id" value="<?= (int) $item['menu_item_id'] ?>">
            <label class="sr-only" for="qty-<?= (int) $item['menu_item_id'] ?>">Quantity of <?= e($item['item_name']) ?></label>
            <input id="qty-<?= (int) $item['menu_item_id'] ?>" class="qty" type="number" name="quantity" value="1" min="1" max="20">
            <button class="btn small">Add to order</button>
          </form>
        </li>
      <?php endforeach; ?>
    </ul>
  </section>
<?php endforeach; ?>
