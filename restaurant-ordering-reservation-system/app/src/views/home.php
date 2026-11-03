<?php $title = null; $tomorrow = date('Y-m-d', strtotime('+1 day')); ?>
<section class="hero">
  <div class="hero-inner">
    <div>
      <h1>Order dinner. Save a table.</h1>
      <p>Pick your dishes online and we start cooking when you confirm. Booking for a group? Check which tables are free before you set out.</p>
      <div class="actions">
        <a class="btn accent" href="/menu">See the menu</a>
        <a class="btn on-dark" href="/orders">Track my order</a>
      </div>
    </div>
    <form class="booking" method="get" action="/reservations/new">
      <h2>Find a table</h2>
      <p>A booking holds your table for 2 hours.</p>
      <div class="fields">
        <label class="wide">Date <input type="date" name="date" value="<?= e($tomorrow) ?>" min="<?= e(date('Y-m-d')) ?>" required></label>
        <label>Time
          <select name="time" required>
            <?php foreach (RESERVATION_SLOTS as $slot): ?>
              <option value="<?= e($slot) ?>" <?= $slot === '18:00' ? 'selected' : '' ?>><?= e(dt($slot, 'g:i A')) ?></option>
            <?php endforeach; ?>
          </select>
        </label>
        <label>Guests <input type="number" name="guests" value="2" min="1" max="20" required></label>
      </div>
      <button class="btn">Check availability</button>
    </form>
  </div>
</section>
<div class="container">
  <h2 style="margin-top:0">Popular right now</h2>
  <ul class="dishes">
    <?php foreach ($featured as $item): ?>
      <li class="dish">
        <div>
          <div class="dish-head">
            <a class="dish-name" href="/menu/item?id=<?= (int) $item['menu_item_id'] ?>"><?= e($item['item_name']) ?></a>
            <span class="leader" aria-hidden="true"></span>
            <span class="price"><?= e(money($item['price'])) ?></span>
          </div>
          <p class="dish-desc"><?= e($item['description']) ?></p>
        </div>
      </li>
    <?php endforeach; ?>
  </ul>
  <p style="margin-top:1.25rem"><a class="btn secondary" href="/menu">See the full menu</a></p>
</div>
