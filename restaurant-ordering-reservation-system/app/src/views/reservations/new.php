<?php $title = 'Reserve a table'; ?>
<h1>Reserve a table</h1>
<p>Choose when you are coming. We show only tables that are free for the full 2 hours and big enough for your group.</p>
<?php foreach ($errors as $err): ?><div class="flash error" role="alert"><?= e($err) ?></div><?php endforeach; ?>

<form method="get" action="/reservations/new" class="panel" style="max-width:44rem">
  <div class="form" style="max-width:none;margin:0">
    <label>Date <input type="date" name="date" value="<?= e($date) ?>" min="<?= e(date('Y-m-d')) ?>" required style="max-width:14rem"></label>
    <fieldset>
      <legend>Time</legend>
      <div class="choices">
        <?php foreach (RESERVATION_SLOTS as $slot): ?>
          <label><input type="radio" name="time" value="<?= e($slot) ?>" <?= $slot === $time ? 'checked' : '' ?> required><span><?= e(dt($slot, 'g:i A')) ?></span></label>
        <?php endforeach; ?>
      </div>
    </fieldset>
    <label>Guests <input type="number" name="guests" value="<?= (int) $guests ?>" min="1" max="20" required style="max-width:8rem"></label>
    <div><button class="btn">Check availability</button></div>
  </div>
</form>

<?php if ($tables !== null): ?>
  <h2>Free tables on <?= e(dt($date, 'l, M j')) ?> at <?= e(dt($time, 'g:i A')) ?></h2>
  <?php if (!$tables): ?>
    <div class="empty"><strong>No table is free for <?= (int) $guests ?> <?= (int) $guests === 1 ? 'guest' : 'guests' ?> at that time.</strong><br>Try another time slot or a different date.</div>
  <?php else: ?>
    <ul class="slots">
      <?php foreach ($tables as $t): ?>
        <li class="slot">
          <span class="t">Table <?= (int) $t['table_number'] ?></span>
          <span class="pips" aria-label="Seats <?= (int) $t['capacity'] ?>">
            <?php for ($n = 0; $n < min(10, (int) $t['capacity']); $n++): ?><i></i><?php endfor; ?>
            <b><?= (int) $t['capacity'] ?> seats</b>
          </span>
          <form method="post" action="/reservations" class="inline">
            <?= csrf_field() ?>
            <input type="hidden" name="table_id" value="<?= (int) $t['table_id'] ?>">
            <input type="hidden" name="date" value="<?= e($date) ?>">
            <input type="hidden" name="time" value="<?= e($time) ?>">
            <input type="hidden" name="guests" value="<?= (int) $guests ?>">
            <button class="btn small">Reserve this table</button>
          </form>
        </li>
      <?php endforeach; ?>
    </ul>
  <?php endif; ?>
<?php endif; ?>
